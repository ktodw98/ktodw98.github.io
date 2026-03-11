# frozen_string_literal: true

module CategoryPages
  class CategoryPage < Jekyll::Page
    def initialize(site, base, dir, category, subcategory = nil)
      @site = site
      @base = base
      @dir = dir
      @name = "index.html"

      process(@name)
      read_yaml(File.join(base, "_layouts"), "category.html")

      category_id = category["id"].to_s.strip
      category_label = category["label"].to_s.strip
      category_description = category["description"].to_s.strip
      active_subcategories = self.class.active_subcategories(category)

      data["category_id"] = category_id
      data["category_label"] = category_label
      data["category_description"] = category_description
      data["generated"] = true

      if subcategory.is_a?(Hash)
        subcategory_id = subcategory["id"].to_s.strip
        subcategory_label = subcategory["label"].to_s.strip
        subcategory_description = subcategory["description"].to_s.strip

        data["title"] = "Subcategory: #{category_label} / #{subcategory_label}"
        data["description"] = subcategory_description.empty? ? category_description : subcategory_description
        data["permalink"] = "/categories/#{category_id}/#{subcategory_id}/"
        data["subcategory_id"] = subcategory_id
        data["subcategory_label"] = subcategory_label
        data["subcategory_description"] = subcategory_description
        data["is_subcategory_page"] = true
      else
        data["title"] = "Category: #{category_label}"
        data["description"] = category_description
        data["permalink"] = "/categories/#{category_id}/"
        data["subcategories"] = active_subcategories
        data["is_subcategory_page"] = false
      end
    end

    def self.active_subcategories(category)
      subcategories = category.fetch("subcategories", [])
      return [] unless subcategories.is_a?(Array)

      subcategories
        .select { |item| item.is_a?(Hash) && item["active"] == true }
        .sort_by { |item| item["order"] || 9999 }
    end
  end

  class CategoryPageGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      taxonomies = site.data.fetch("taxonomies", {})
      categories = taxonomies.fetch("categories", [])
      return unless categories.is_a?(Array)

      categories.each do |category|
        next unless category.is_a?(Hash)
        next unless category["active"] == true

        category_id = category["id"].to_s.strip
        next if category_id.empty?

        site.pages << CategoryPage.new(site, site.source, File.join("categories", category_id), category)

        CategoryPage.active_subcategories(category).each do |subcategory|
          subcategory_id = subcategory["id"].to_s.strip
          next if subcategory_id.empty?

          site.pages << CategoryPage.new(
            site,
            site.source,
            File.join("categories", category_id, subcategory_id),
            category,
            subcategory
          )
        end
      end
    end
  end
end
