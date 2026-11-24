# frozen_string_literal: true

Jekyll::Hooks.register :documents, :post_render do |page|
  next unless page.data["compact_claims_availability"]

  table_pattern = /<div class="table-wrapper">\s*(<table id="claims-availability">(.*?)<\/table>)\s*<\/div>/m
  source_table = page.output[table_pattern, 1]
  next unless source_table

  header = source_table[/<tr>(.*?)<\/tr>/m, 1]
  countries = header.scan(/<th>(.*?)<\/th>/m).flatten.drop(2).map { |cell| cell.gsub(/<.*?>/, "").strip }
  available_countries = countries.dup
  available_countries << "Netherlands (iDIN)" if source_table.include?("iDIN:")
  priority_countries = ["Belgium", "Netherlands", "Netherlands (iDIN)"]
  available_countries.sort_by! do |country|
    [priority_countries.index(country) || priority_countries.length, country.downcase]
  end
  rows = source_table.scan(/<tr>\s*<td>(.*?)<\/td>\s*<td>(.*?)<\/td>(.*?)<\/tr>/m)

  claims = rows.map do |claim_html, description_html, availability_html|
    statuses = availability_html.scan(/<td>(.*?)<\/td>/m).flatten
    next unless statuses.length == countries.length

    grouped = Hash.new { |hash, key| hash[key] = [] }
    notes = []

    statuses.each_with_index do |status_html, index|
      status = status_html.gsub(/<.*?>/, "").gsub(/\s+/, " ").strip
      label = ["SHALL NOT", "MAY NOT", "SHALL"].find { |candidate| status.start_with?(candidate) }
      if label
        grouped[label] << countries[index]
        note = status.delete_prefix(label).strip
        idin_status = note.match(/\AiDIN:\s*(SHALL NOT|MAY NOT|SHALL)(?:\s+(.+))?\z/)
        if countries[index] == "Netherlands" && idin_status
          grouped[idin_status[1]] << "Netherlands (iDIN)"
          explanation = idin_status[2]
          notes << { status: "", country: countries[index], text: explanation } unless explanation.nil? || explanation.empty?
        elsif !note.empty?
          notes << { status: label, country: countries[index], text: note }
        end
      elsif status == 'Only if "email" available'
        grouped["MAY NOT"] << countries[index]
        notes << { status: "MAY NOT", country: countries[index], text: status }
      else
        notes << { status: "", country: countries[index], text: status } unless status.empty?
      end
    end

    {
      claim: claim_html,
      description: description_html,
      grouped: grouped,
      notes: notes
    }
  end.compact

  status_names = ["SHALL", "MAY NOT", "SHALL NOT"]
  replacement = <<~HTML
    <p class="claims-availability__countries"><strong>Available countries:</strong> #{available_countries.join(', ')}</p>
    <div class="claims-availability__search">
      <div class="claims-availability__control" hidden>
        <label for="claims-profile">Package</label>
        <select id="claims-profile">
          <option value="full-digital" selected>Full Digital</option>
          <option value="full-check-in">Full Check-in</option>
          <option value="connect">Connect</option>
        </select>
      </div>
      <div class="claims-availability__control">
        <span id="claims-country-label" class="claims-availability__label">Country</span>
        <select id="claims-country" aria-labelledby="claims-country-label">
          <option value="all" selected>All countries</option>
          #{available_countries.each_with_index.map { |country, index| "<option value=\"#{index}\">#{country}</option>" }.join}
        </select>
        <details id="claims-country-dropdown" class="claims-availability__dropdown" hidden>
          <summary id="claims-country-selection" aria-labelledby="claims-country-label claims-country-selection">All countries</summary>
          <div class="claims-availability__dropdown-panel">
            <input id="claims-country-search" type="search" placeholder="Search countries" aria-label="Search countries" autocomplete="off">
            <ul id="claims-country-options" class="claims-availability__options">
              <li data-country-group="all"><button type="button" data-country-value="all" aria-pressed="true">All countries</button></li>
              #{available_countries.each_with_index.map do |country, index|
                group = priority_countries.include?(country) ? "priority" : "other"
                "<li data-country-group=\"#{group}\"><button type=\"button\" data-country-value=\"#{index}\" aria-pressed=\"false\">#{country}</button></li>"
              end.join}
            </ul>
            <p id="claims-country-empty" role="status" hidden>No matching countries.</p>
          </div>
        </details>
      </div>
      <div class="claims-availability__control">
        <label for="claims-search">Search claims</label>
        <input id="claims-search" type="search" placeholder="Search by claim name" autocomplete="off">
      </div>
      <p id="claims-search-empty" hidden>No matching claims.</p>
    </div>
    <table class="claims-availability" aria-label="Claim availability by issuing country">
      <thead>
        <tr>
          <th>Claim</th>
          <th>Description</th>
          <th>SHALL</th>
          <th>MAY NOT</th>
          <th>SHALL NOT</th>
        </tr>
      </thead>
      <tbody>
        #{claims.each_with_index.map do |claim, index|
          stripe_class = index.odd? ? "claims-availability__group--alternate" : "claims-availability__group--base"
          columns = status_names.map do |status|
            countries_with_status = claim[:grouped][status]
            value = if countries_with_status.empty?
                      "-"
                    elsif countries_with_status.length == countries.length
                      "All countries"
                    elsif countries_with_status.length > countries.length - 4
                      excluded = countries - countries_with_status
                      "All other countries (except #{excluded.join(', ')})"
                    else
                      countries_with_status.join(", ")
                    end
            country_indices = available_countries.each_with_index.map do |country, country_index|
              country_index.to_s if countries_with_status.include?(country)
            end.compact.join(",")
            "<td class=\"claims-availability__status claims-availability__status--#{status.downcase.gsub(' ', '-')}\" data-country-indices=\"#{country_indices}\">#{value}</td>"
          end.join
          has_notes = claim[:notes].any?
          notes = if !has_notes
                    ""
                  else
                    note_text = claim[:notes].group_by { |note| [note[:status], note[:text]] }.map do |(status, text), entries|
                      countries_for_note = entries.map { |entry| entry[:country] }
                      country_suffix = status.empty? || countries_for_note.length == countries.length ? "" : " (#{countries_for_note.join(', ')})"
                      status_prefix = status.empty? ? "" : "#{status}: "
                      "#{status_prefix}#{text}#{country_suffix}"
                    end.join("<br>")
                                    "<tr class=\"claims-availability__group #{stripe_class} claims-availability__note-row\" data-claim-index=\"#{index}\"><td colspan=\"5\"><p class=\"claims-availability__note\">#{note_text}</p></td></tr>"
                  end
          <<~CLAIM
                                  <tr class="claims-availability__group #{stripe_class}" data-claim-index="#{index}">
              <td class="claims-availability__claim">#{claim[:claim]}</td>
              <td class="claims-availability__description">#{claim[:description]}</td>
              #{columns}
            </tr>
            #{notes}
          CLAIM
        end.join}
      </tbody>
    </table>
  HTML

  page.output = page.output.sub(table_pattern, replacement)
end