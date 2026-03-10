# frozen_string_literal: true

module PostAssets
  POSTS_IMAGE_ROOT = "/assets/images/posts".freeze

  module_function

  def external_url?(value)
    value.to_s.match?(%r!\Ahttps?://!)
  end

  def normalize_relative_path(value)
    value.to_s.strip.sub(%r!\A/+!, "").gsub(%r!/{2,}!, "/")
  end

  def post_asset_path(post_id, relative_path)
    relative = normalize_relative_path(relative_path)
    return if post_id.to_s.strip.empty? || relative.empty?

    "#{POSTS_IMAGE_ROOT}/#{post_id}/#{relative}"
  end

  def resolve_post_image(page_like, input)
    value = input.to_s.strip
    return nil if value.empty?
    return value if external_url?(value) || value.start_with?("/")

    post_asset_path(page_like["post_id"], value)
  end

  def media_url(site, path)
    return path if path.to_s.empty? || external_url?(path)

    media_baseurl = site.config.fetch("media_baseurl", "").to_s.strip.sub(%r!/+\z!, "")
    return "#{media_baseurl}#{path}" unless media_baseurl.empty?

    baseurl = site.baseurl.to_s.strip.sub(%r!/+\z!, "")
    baseurl.empty? ? path : "#{baseurl}#{path}"
  end
end

module Jekyll
  module PostAssetFilters
    def post_asset_url(input)
      site = @context.registers[:site]
      page = @context.registers[:page] || {}
      resolved = PostAssets.resolve_post_image(page, input)
      return input if resolved.nil?

      PostAssets.media_url(site, resolved)
    end
  end

  class PostAssetGenerator < Generator
    safe true
    priority :low

    def generate(site)
      site.posts.docs.each do |doc|
        image = doc.data["image"]
        next unless image.is_a?(String)

        resolved = PostAssets.resolve_post_image(doc.data, image)
        next if resolved.nil?

        doc.data["image"] = PostAssets.media_url(site, resolved)
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::PostAssetFilters)
