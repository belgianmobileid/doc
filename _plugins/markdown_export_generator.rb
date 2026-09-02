# Publishes a raw-markdown sibling (e.g. /authentication.md) next to every HTML
# page, so pages fetched with a .md suffix return the same content as the HTML
# page instead of rendered HTML. Liquid tags (e.g. include_relative) are
# resolved here since the source files are templates, not final content.
module MarkdownExport
  FRONT_MATTER = /\A---\s*\n.*?\n---\s*\n/m.freeze

  def self.write(site, item)
    return unless item.respond_to?(:path) && item.path.to_s =~ /\.(md|markdown)\z/
    return unless item.url

    url = item.url.chomp("/")
    url = "/index" if url.empty?
    destination = File.join(site.dest, "#{url}.md")

    FileUtils.mkdir_p(File.dirname(destination))
    File.write(destination, render(site, item))
  end

  def self.render(site, item)
    raw = File.read(item.path).sub(FRONT_MATTER, "")
    # item.content is already the final HTML by :post_write time, so check the
    # raw source itself for Liquid constructs instead of item.render_with_liquid?
    return raw if item.data["render_with_liquid"] == false
    return raw unless Jekyll::Utils.has_liquid_construct?(raw)

    payload = site.site_payload
    payload["page"] = item.to_liquid
    info = { :registers => { :site => site, :page => payload["page"] } }
    site.liquid_renderer.file(item.path).parse(raw).render!(payload, info)
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  site.pages.each { |page| MarkdownExport.write(site, page) }
  site.collections.each_value do |collection|
    collection.docs.each { |doc| MarkdownExport.write(site, doc) }
  end
end
