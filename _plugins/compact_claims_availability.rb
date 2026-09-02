# frozen_string_literal: true

Jekyll::Hooks.register :documents, :post_render do |page|
  next unless page.data["compact_claims_availability"]

  table_pattern = /<table id="claims-availability">(.*?)<\/table>/m
  source_table = page.output[table_pattern, 0]
  next unless source_table

  header = source_table[/<tr>(.*?)<\/tr>/m, 1]
  countries = header.scan(/<th>(.*?)<\/th>/m).flatten.drop(2).map { |cell| cell.gsub(/<.*?>/, "").strip }
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
        notes << { status: label, country: countries[index], text: note } unless note.empty?
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
    <p class="claims-availability__countries"><strong>Available countries:</strong> #{countries.join(', ')}</p>
    <div class="claims-availability__search">
      <label for="claims-search">Search claims</label>
      <input id="claims-search" type="search" placeholder="Search by claim name" autocomplete="off">
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
                      "No countries"
                    elsif countries_with_status.length == countries.length
                      "All countries"
                    elsif countries_with_status.length > countries.length - 4
                      excluded = countries - countries_with_status
                      "All other countries (except #{excluded.join(', ')})"
                    else
                      countries_with_status.join(", ")
                    end
            "<td class=\"claims-availability__status claims-availability__status--#{status.downcase.gsub(' ', '-')}\">#{value}</td>"
          end.join
          has_notes = claim[:notes].any?
          notes = if !has_notes
                    ""
                  else
                    note_text = claim[:notes].group_by { |note| [note[:status], note[:text]] }.map do |(status, text), entries|
                      countries_for_note = entries.map { |entry| entry[:country] }
                      country_suffix = countries_for_note.length == countries.length ? "" : " (#{countries_for_note.join(', ')})"
                      "#{status}: #{text}#{country_suffix}"
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