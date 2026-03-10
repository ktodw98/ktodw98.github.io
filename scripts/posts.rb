#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "securerandom"
require "time"
require "yaml"

ROOT = File.expand_path("..", __dir__)
TAXONOMIES_PATH = File.join(ROOT, "_data", "taxonomies.yml")
TEMPLATES_DIR = File.join(ROOT, "templates", "posts")
POSTS_DIR = File.join(ROOT, "_posts")
POST_IMAGES_DIR = File.join(ROOT, "assets", "images", "posts")

TYPE_BY_TEMPLATE = {
  "article" => "article",
  "tutorial" => "tutorial",
  "case-study" => "case-study",
  "log" => "log",
  "reference" => "reference",
  "study-note" => "reference",
  "import-summary" => "reference",
  "import-repost" => "reference"
}.freeze

IMPORT_MODES = {
  "import-summary" => "summary",
  "import-repost" => "repost"
}.freeze

DEFAULT_DESCRIPTION_BY_TEMPLATE = {
  "article" => "Replace with a one-line summary.",
  "tutorial" => "Replace with the learning goal and outcome.",
  "case-study" => "Replace with the problem, decision, and result.",
  "log" => "Replace with the change summary and impact.",
  "reference" => "Replace with the definition or lookup summary.",
  "study-note" => "Replace with the chapter summary, key concepts, and your takeaways.",
  "import-summary" => "Replace with a summary of the source article and your takeaways.",
  "import-repost" => "Replace with a repost summary and source attribution."
}.freeze

DEFAULT_TAGS_BY_TEMPLATE = {
  "import-summary" => ["reference", "summary"],
  "import-repost" => ["reference", "repost"]
}.freeze

def fail_with(message)
  warn(message)
  exit(1)
end

def load_taxonomies
  fail_with("Missing taxonomy file: #{TAXONOMIES_PATH}") unless File.exist?(TAXONOMIES_PATH)

  data = YAML.safe_load(File.read(TAXONOMIES_PATH), aliases: true)
  fail_with("Taxonomy file must be a YAML map.") unless data.is_a?(Hash)

  categories = data["categories"]
  recommended_tags = data["recommended_tags"]

  fail_with("`categories` must be a non-empty array.") unless categories.is_a?(Array) && categories.any?
  fail_with("`recommended_tags` must be an array.") unless recommended_tags.is_a?(Array)

  [categories, recommended_tags]
end

def slugify(value)
  value.to_s
    .downcase
    .strip
    .gsub(/[^a-z0-9]+/, "-")
    .gsub(/\A-+|-+\z/, "")
    .gsub(/-{2,}/, "-")
end

def list_templates
  template_files = Dir.glob(File.join(TEMPLATES_DIR, "*.md")).sort
  fail_with("No templates found in #{TEMPLATES_DIR}") if template_files.empty?

  template_files.each do |path|
    puts(File.basename(path, ".md"))
  end
end

def list_categories
  categories, = load_taxonomies
  categories.sort_by { |item| item["order"] || 9999 }.each do |category|
    next unless category.is_a?(Hash)
    next unless category["active"] == true

    puts("#{category['id']}\t#{category['label']}\t#{category['description']}")
  end
end

def list_tags
  _, recommended_tags = load_taxonomies
  recommended_tags.each { |tag| puts(tag) }
end

def env!(key)
  value = ENV[key].to_s.strip
  fail_with("Missing required variable: #{key}") if value.empty?

  value
end

def optional_env(key, default = nil)
  value = ENV[key].to_s.strip
  value.empty? ? default : value
end

def normalize_tags(raw)
  raw.to_s.split(",").map(&:strip).reject(&:empty?).uniq
end

def yaml_array(values)
  values.to_json
end

def normalize_series(value)
  value.to_s
    .strip
    .downcase
    .gsub(/[^a-z0-9]+/, "-")
    .gsub(/\A-+|-+\z/, "")
    .gsub(/-{2,}/, "-")
end

def image_block(image)
  image = image.to_s.strip
  return "# image: \"cover.png\"" if image.empty?

  "image: #{image.to_json}"
end

def generate_post_id
  SecureRandom.uuid
end

def parse_series_fields(template_name)
  series = optional_env("SERIES", "")
  series_order = optional_env("SERIES_ORDER", "")

  if template_name == "study-note"
    fail_with("Missing required variable: SERIES") if series.empty?
    fail_with("Missing required variable: SERIES_ORDER") if series_order.empty?
  end

  if series.empty? != series_order.empty?
    fail_with("SERIES and SERIES_ORDER must be provided together.")
  end

  return ["", ""] if series.empty?

  normalized_series = normalize_series(series)
  fail_with("SERIES must contain at least one alphanumeric character.") if normalized_series.empty?

  begin
    order = Integer(series_order)
    fail_with("SERIES_ORDER must be a positive integer.") if order <= 0
  rescue ArgumentError
    fail_with("SERIES_ORDER must be a positive integer.")
  end

  [normalized_series, order.to_s]
end

def category_exists?(categories, category_id)
  categories.any? do |category|
    category.is_a?(Hash) && category["active"] == true && category["id"].to_s == category_id
  end
end

def build_post(template_name)
  categories, = load_taxonomies
  template_path = File.join(TEMPLATES_DIR, "#{template_name}.md")
  fail_with("Unknown template: #{template_name}") unless File.exist?(template_path)

  title = env!("TITLE")
  category = env!("CATEGORY")
  fail_with("Unknown category: #{category}") unless category_exists?(categories, category)

  tags = normalize_tags(optional_env("TAGS", ""))
  if tags.empty?
    tags = DEFAULT_TAGS_BY_TEMPLATE.fetch(template_name, [])
  end
  fail_with("At least one tag is required. Example: TAGS=\"go,api\"") if tags.empty?

  slug = optional_env("SLUG", slugify(title))
  fail_with("Could not derive slug from TITLE. Pass SLUG=... explicitly.") if slug.to_s.empty?

  now = Time.now
  date_str = now.strftime("%Y-%m-%d %H:%M:%S %z")
  file_date = now.strftime("%Y-%m-%d")
  description = optional_env("DESCRIPTION", DEFAULT_DESCRIPTION_BY_TEMPLATE.fetch(template_name, "Replace with a summary."))
  image = optional_env("IMAGE", "")
  post_id = generate_post_id
  source_url = optional_env("SOURCE_URL", "")
  source_name = optional_env("SOURCE_NAME", "")
  import_mode = IMPORT_MODES.fetch(template_name, "")
  series, series_order = parse_series_fields(template_name)

  if import_mode.empty?
    fail_with("SOURCE_URL is only supported for import templates.") unless source_url.empty?
    fail_with("SOURCE_NAME is only supported for import templates.") unless source_name.empty?
  else
    fail_with("Missing required variable: SOURCE_URL") if source_url.empty?
    fail_with("Missing required variable: SOURCE_NAME") if source_name.empty?
  end

  category_dir = File.join(POSTS_DIR, category)
  post_images_dir = File.join(POST_IMAGES_DIR, post_id)
  filename = "#{file_date}-#{slug}.md"
  path = File.join(category_dir, filename)
  fail_with("Post already exists: #{path}") if File.exist?(path)

  template = File.read(template_path)
  replacements = {
    "__TITLE__" => title,
    "{{TITLE}}" => title,
    "__DATE__" => date_str,
    "{{DATE}}" => date_str,
    "__POST_ID__" => post_id,
    "{{POST_ID}}" => post_id,
    "__TYPE__" => TYPE_BY_TEMPLATE.fetch(template_name, "article"),
    "{{TYPE}}" => TYPE_BY_TEMPLATE.fetch(template_name, "article"),
    "__CATEGORY__" => category,
    "{{CATEGORY}}" => category,
    "__TAGS__" => yaml_array(tags),
    "{{TAGS}}" => yaml_array(tags),
    "__DESCRIPTION__" => description,
    "{{DESCRIPTION}}" => description,
    "# __IMAGE_BLOCK__" => image_block(image),
    "{{IMAGE_BLOCK}}" => image_block(image),
    "__SERIES__" => series,
    "{{SERIES}}" => series,
    "__SERIES_ORDER__" => series_order,
    "{{SERIES_ORDER}}" => series_order,
    "__SLUG__" => slug,
    "{{SLUG}}" => slug,
    "__SOURCE_URL__" => source_url,
    "{{SOURCE_URL}}" => source_url,
    "__SOURCE_NAME__" => source_name,
    "{{SOURCE_NAME}}" => source_name,
    "__IMPORT_MODE__" => import_mode,
    "{{IMPORT_MODE}}" => import_mode
  }

  content = replacements.reduce(template) do |memo, (placeholder, value)|
    memo.gsub(placeholder, value)
  end

  FileUtils.mkdir_p(category_dir)
  FileUtils.mkdir_p(post_images_dir)
  File.write(path, content)

  puts(path)
end

command = ARGV[0].to_s

case command
when "list-templates"
  list_templates
when "list-categories"
  list_categories
when "list-tags"
  list_tags
when "new"
  build_post(env!("TEMPLATE"))
when "import-summary", "import-repost"
  build_post(command)
else
  fail_with("Unknown command: #{command}")
end
