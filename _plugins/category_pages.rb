# frozen_string_literal: true

module CategoryPages
  class CategoryPage < Jekyll::Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir = dir
      @name = "index.html"

      process(@name)
      read_yaml(File.join(base, "_layouts"), "category.html")

      category_id = category["id"].to_s.strip
      category_label = category["label"].to_s.strip
      category_description = category["description"].to_s.strip

      data["title"] = "Category: #{category_label}"
      data["description"] = category_description
      data["permalink"] = "/categories/#{category_id}/"
      data["category_id"] = category_id
      data["category_label"] = category_label
      data["category_description"] = category_description
      data["generated"] = true
    end
  end

  class CategoryPageGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      categories = site.data.fetch("categories", [])
      return unless categories.is_a?(Array)

      categories.each do |category|
        next unless category.is_a?(Hash)
        next unless category["active"] == true

        category_id = category["id"].to_s.strip
        next if category_id.empty?

        site.pages << CategoryPage.new(site, site.source, File.join("categories", category_id), category)
      end
    end
  end
end
