# Publishes a raw-markdown sibling (e.g. /authentication.md) next to every HTML
# page, so pages fetched with a .md suffix return the original markdown source
# instead of rendered HTML.
module MarkdownExport
  FRONT_MATTER = /\A---\s*\n.*?\n---\s*\n/m.freeze

  def self.write(site, item)
    return unless item.respond_to?(:path) && item.path.to_s =~ /\.(md|markdown)\z/
    return unless item.url

    url = item.url.chomp("/")
    url = "/index" if url.empty?
    destination = File.join(site.dest, "#{url}.md")

    FileUtils.mkdir_p(File.dirname(destination))
    File.write(destination, File.read(item.path).sub(FRONT_MATTER, ""))
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  site.pages.each { |page| MarkdownExport.write(site, page) }
  site.collections.each_value do |collection|
    collection.docs.each { |doc| MarkdownExport.write(site, doc) }
  end
end
