# frozen_string_literal: true

module ObsidianLikeLinks
  LINK_PATTERN = /\[\[([^\]\|#]+)(?:#([^\]\|]+))?(?:\|([^\]]+))?\]\]/.freeze
  CODE_PATTERN = /```[\s\S]*?```|`[^`\n]+`/.freeze

  module_function

  def normalize_key(value)
    Jekyll::Utils.slugify(value.to_s.downcase.strip)
  end

  def fallback_title(doc)
    source_name =
      if doc.respond_to?(:basename_without_ext)
        doc.basename_without_ext
      else
        File.basename(doc.path, File.extname(doc.path))
      end
    source_name.sub(/^\d{4}-\d{2}-\d{2}-/, "").tr("-", " ").strip
  end

  def display_title(doc)
    title = doc.data["title"].to_s.strip
    return title unless title.empty?

    fallback_title(doc)
  end

  def collect_documents(site)
    docs = []
    docs.concat(site.posts.docs)
    site.collections.each do |label, collection|
      next if label == "posts"

      docs.concat(collection.docs)
    end
    docs.concat(site.pages.select { |page| page.path.end_with?(".md") })
    docs.select { |doc| doc.respond_to?(:content) && !doc.content.to_s.empty? }
  end

  def build_link_index(docs)
    index = {}
    docs.each do |doc|
      url = doc.url.to_s
      next if url.empty?

      display = display_title(doc)
      slug_source = url.split("/").reject(&:empty?).last.to_s.tr("-", " ")
      keys = [
        normalize_key(display),
        normalize_key(fallback_title(doc)),
        normalize_key(slug_source)
      ].uniq

      keys.each do |key|
        next if key.empty?
        next if index.key?(key)

        index[key] = { "url" => url, "title" => display }
      end
    end
    index
  end

  def slug_anchor(anchor)
    Jekyll::Utils.slugify(anchor.to_s)
  end

  def protect_code_segments(content)
    placeholders = {}
    protected = content.gsub(CODE_PATTERN) do |match|
      key = "__WIKILINK_CODE_#{placeholders.length}__"
      placeholders[key] = match
      key
    end
    [protected, placeholders]
  end

  def restore_code_segments(content, placeholders)
    restored = content
    placeholders.each do |key, value|
      restored = restored.gsub(key, value)
    end
    restored
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  docs = ObsidianLikeLinks.collect_documents(site)
  link_index = ObsidianLikeLinks.build_link_index(docs)
  backlinks = Hash.new { |hash, key| hash[key] = [] }

  docs.each do |doc|
    source_url = doc.url.to_s
    source_title = ObsidianLikeLinks.display_title(doc)

    protected_content, placeholders = ObsidianLikeLinks.protect_code_segments(doc.content)

    replaced_content = protected_content.gsub(ObsidianLikeLinks::LINK_PATTERN) do
      raw_target = Regexp.last_match(1).to_s.strip
      anchor = Regexp.last_match(2).to_s.strip
      alias_label = Regexp.last_match(3).to_s.strip
      resolved = link_index[ObsidianLikeLinks.normalize_key(raw_target)]

      unless resolved
        label = alias_label.empty? ? raw_target : alias_label
        next "`[[#{label}]]`"
      end

      target_url = resolved["url"]
      link_label = alias_label.empty? ? raw_target : alias_label
      final_url = anchor.empty? ? target_url : "#{target_url}##{ObsidianLikeLinks.slug_anchor(anchor)}"

      if !source_url.empty? && source_url != target_url
        backlinks[target_url] << { "title" => source_title, "url" => source_url }
      end

      "[#{link_label}](#{final_url})"
    end

    doc.content = ObsidianLikeLinks.restore_code_segments(replaced_content, placeholders)
  end

  backlinks.each_value do |items|
    items.uniq! { |item| item["url"] }
  end

  site.config["backlinks"] = backlinks
end
