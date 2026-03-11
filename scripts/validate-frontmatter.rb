#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "time"
require "date"

ROOT = File.expand_path("..", __dir__)
TAXONOMIES_PATH = File.join(ROOT, "_data", "taxonomies.yml")
POSTS_GLOB = File.join(ROOT, "_posts", "**", "*.md")
POST_IMAGES_DIR = File.join(ROOT, "assets", "images", "posts")
TAG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
ALLOWED_TYPES = %w[article tutorial case-study log reference].freeze
ALLOWED_IMPORT_MODES = %w[summary repost].freeze
IMAGE_PATH_PATTERN = /\A(?:https?:\/\/\S+|\/\S+)\z/
UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/
POST_IMAGE_INCLUDE_PATTERN = /\{%\s*include\s+post-image\.html\b([^%]*)%\}/m
FILE_ATTRIBUTE_PATTERN = /\bfile\s*=\s*["']([^"']+)["']/
MARKDOWN_IMAGE_PATTERN = /!\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/
HTML_IMAGE_PATTERN = /<img\b[^>]*\bsrc=["']([^"']+)["'][^>]*>/i

def fail_with(message)
  warn(message)
  exit(1)
end

def parse_front_matter(path)
  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  raise "missing front matter block" unless match

  front_matter = YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true)
  raise "front matter must be a YAML map" unless front_matter.is_a?(Hash)

  [front_matter, content.sub(match[0], "")]
end

def normalize_string(value)
  value.is_a?(String) ? value.strip : ""
end

def parse_time(value)
  return value if value.is_a?(Time) || value.is_a?(Date)
  Time.parse(value.to_s)
end

def relative_image_reference?(value)
  value.is_a?(String) && !value.empty? && value !~ /\Ahttps?:\/\// && !value.start_with?("/")
end

def valid_relative_image_reference?(value)
  relative_image_reference?(value) &&
    !value.include?("..") &&
    !value.start_with?("./") &&
    !value.start_with?("../")
end

def post_asset_abspath(post_id, relative_path)
  File.expand_path(relative_path, File.join(POST_IMAGES_DIR, post_id))
end

def local_site_asset_abspath(asset_path)
  File.expand_path(asset_path.sub(%r{\A/}, ""), ROOT)
end

def within_directory?(path, directory)
  path == directory || path.start_with?("#{directory}#{File::SEPARATOR}")
end

def validate_image_reference(ref:, post_id:, path:, errors:)
  image = normalize_string(ref)
  return if image.empty?
  return if image.match?(/\Ahttps?:\/\/\S+\z/)

  if image.start_with?("/")
    image_path = local_site_asset_abspath(image)
    errors << "#{path}: image asset not found: #{image}" unless File.exist?(image_path)

    if image.start_with?("/assets/images/posts/") && !post_id.empty?
      post_root = File.join(POST_IMAGES_DIR, post_id)
      errors << "#{path}: image must stay inside /assets/images/posts/#{post_id}/" unless within_directory?(image_path, post_root)
    end
    return
  end

  unless valid_relative_image_reference?(image)
    errors << "#{path}: relative image references must not use absolute segments or '..': #{image}"
    return
  end

  if post_id.empty?
    errors << "#{path}: relative image references require `post_id`: #{image}"
    return
  end

  image_path = post_asset_abspath(post_id, image)
  post_root = File.join(POST_IMAGES_DIR, post_id)

  errors << "#{path}: relative image must stay inside #{post_root}: #{image}" unless within_directory?(image_path, post_root)
  errors << "#{path}: image asset not found: /assets/images/posts/#{post_id}/#{image}" unless File.exist?(image_path)
end

def extract_local_body_images(body)
  refs = []

  body.scan(POST_IMAGE_INCLUDE_PATTERN) do |attributes|
    raw_attributes = attributes.to_s
    file_match = raw_attributes.match(FILE_ATTRIBUTE_PATTERN)
    if file_match
      refs << { ref: file_match[1], source: "include" }
    else
      refs << { ref: "", source: "include-missing-file" }
    end
  end

  body.scan(MARKDOWN_IMAGE_PATTERN) { |match| refs << { ref: match.to_s, source: "markdown" } }
  body.scan(HTML_IMAGE_PATTERN) { |match| refs << { ref: match.to_s, source: "html" } }

  refs
end

unless File.exist?(TAXONOMIES_PATH)
  fail_with("Missing taxonomy master file: #{TAXONOMIES_PATH}")
end

taxonomies_data = YAML.safe_load(File.read(TAXONOMIES_PATH), aliases: true)
unless taxonomies_data.is_a?(Hash)
  fail_with("Taxonomy master must be a YAML map: #{TAXONOMIES_PATH}")
end

categories_data = taxonomies_data["categories"]
unless categories_data.is_a?(Array) && categories_data.any?
  fail_with("Taxonomy master must include a non-empty `categories` array: #{TAXONOMIES_PATH}")
end

active_category_ids = categories_data
  .select { |item| item.is_a?(Hash) && item["active"] == true }
  .map { |item| normalize_string(item["id"]) }
  .reject(&:empty?)
  .uniq

active_subcategory_ids_by_category = categories_data.each_with_object({}) do |category, memo|
  next unless category.is_a?(Hash) && category["active"] == true

  category_id = normalize_string(category["id"])
  next if category_id.empty?

  subcategory_ids = Array(category["subcategories"])
    .select { |item| item.is_a?(Hash) && item["active"] == true }
    .map { |item| normalize_string(item["id"]) }
    .reject(&:empty?)
    .uniq

  memo[category_id] = subcategory_ids
end

if active_category_ids.empty?
  fail_with("No active categories found in #{TAXONOMIES_PATH}")
end

errors = []
warnings = []
checked_count = 0

Dir.glob(POSTS_GLOB).sort.each do |path|
  checked_count += 1
  begin
    fm, body = parse_front_matter(path)
  rescue StandardError => e
    errors << "#{path}: #{e.message}"
    next
  end

  title = normalize_string(fm["title"])
  errors << "#{path}: `title` is required" if title.empty?

  begin
    date_value = fm["date"]
    raise "missing" if date_value.nil?
    parse_time(date_value)
  rescue StandardError
    errors << "#{path}: `date` is required and must be parseable"
  end

  description = normalize_string(fm["description"])
  errors << "#{path}: `description` is required" if description.empty?

  post_id = normalize_string(fm["post_id"])
  if post_id.empty?
    errors << "#{path}: `post_id` is required"
  elsif !UUID_PATTERN.match?(post_id)
    errors << "#{path}: `post_id` must be a UUID"
  end

  unless fm["image"].nil?
    image = normalize_string(fm["image"])
    if image.empty?
      errors << "#{path}: `image` must not be blank when provided"
    elsif !IMAGE_PATH_PATTERN.match?(image) && !relative_image_reference?(image)
      errors << "#{path}: `image` must be an absolute path, relative asset filename, or an http/https URL"
    else
      validate_image_reference(ref: image, post_id: post_id, path: path, errors: errors)
    end
  end

  unless [true, false].include?(fm["draft"])
    errors << "#{path}: `draft` is required and must be boolean"
  end

  post_type = normalize_string(fm["type"])
  if post_type.empty?
    errors << "#{path}: `type` is required"
  elsif !ALLOWED_TYPES.include?(post_type)
    errors << "#{path}: `type` must be one of #{ALLOWED_TYPES.join(', ')}"
  end

  categories = fm["categories"]
  unless categories.is_a?(Array) && categories.size == 1 && categories.first.is_a?(String)
    errors << "#{path}: `categories` must be an array with exactly one category id"
  end

  category_id = categories.is_a?(Array) ? normalize_string(categories.first) : ""
  if category_id.empty?
    errors << "#{path}: category id cannot be blank"
  elsif !active_category_ids.include?(category_id)
    errors << "#{path}: category `#{category_id}` is not in active category master"
  end

  subcategory_id = ""
  unless fm["subcategory"].nil?
    unless fm["subcategory"].is_a?(String)
      errors << "#{path}: `subcategory` must be a string when provided"
    end

    subcategory_id = normalize_string(fm["subcategory"])
    if subcategory_id.empty?
      errors << "#{path}: `subcategory` must not be blank when provided"
    elsif category_id.empty?
      errors << "#{path}: `subcategory` requires a valid category"
    elsif !active_subcategory_ids_by_category.fetch(category_id, []).include?(subcategory_id)
      errors << "#{path}: subcategory `#{subcategory_id}` is not active under category `#{category_id}`"
    end
  end

  tags = fm["tags"]
  unless tags.is_a?(Array) && !tags.empty?
    errors << "#{path}: `tags` must be a non-empty array"
    tags = []
  end

  if tags.size > 5
    errors << "#{path}: `tags` must contain at most 5 values"
  end

  normalized_tags = tags.map { |tag| normalize_string(tag) }
  if normalized_tags.any?(&:empty?)
    errors << "#{path}: tags cannot contain blank values"
  end

  invalid_tags = normalized_tags.reject { |tag| TAG_PATTERN.match?(tag) }
  unless invalid_tags.empty?
    errors << "#{path}: invalid tag format #{invalid_tags.uniq.join(', ')} (use lowercase kebab-case)"
  end

  if normalized_tags.uniq.size != normalized_tags.size
    errors << "#{path}: duplicate tags are not allowed"
  end

  series = normalize_string(fm["series"])
  has_series = !series.empty?
  has_series_order = !fm["series_order"].nil?

  if has_series != has_series_order
    errors << "#{path}: `series` and `series_order` must be set together"
  end

  if has_series
    unless TAG_PATTERN.match?(series)
      errors << "#{path}: `series` must use lowercase kebab-case"
    end

    begin
      order = Integer(fm["series_order"])
      raise ArgumentError if order <= 0
    rescue StandardError
      errors << "#{path}: `series_order` must be a positive integer"
    end
  end

  source_url = normalize_string(fm["source_url"])
  source_name = normalize_string(fm["source_name"])
  import_mode = normalize_string(fm["import_mode"])
  import_fields = [source_url.empty?, source_name.empty?, import_mode.empty?]

  if import_fields.uniq.length > 1
    errors << "#{path}: `source_url`, `source_name`, and `import_mode` must be set together"
  end

  unless import_mode.empty?
    unless ALLOWED_IMPORT_MODES.include?(import_mode)
      errors << "#{path}: `import_mode` must be one of #{ALLOWED_IMPORT_MODES.join(', ')}"
    end

    errors << "#{path}: `source_url` must be a valid http/https URL" unless source_url.match?(/\Ahttps?:\/\/\S+\z/)
    errors << "#{path}: `source_name` is required for imported posts" if source_name.empty?
  end

  extract_local_body_images(body).each do |entry|
    ref = entry.fetch(:ref)
    source = entry.fetch(:source)

    if source == "include-missing-file"
      errors << "#{path}: `{% include post-image.html ... %}` must provide a `file=\"...\"` attribute"
      next
    end

    next if ref.start_with?("#")

    validate_image_reference(ref: ref, post_id: post_id, path: path, errors: errors)

    if source != "include" && relative_image_reference?(ref)
      warnings << "#{path}: prefer `{% include post-image.html file=\"#{ref}\" %}` instead of a raw local image reference"
      next
    end

    next unless source != "include" && ref.start_with?("/assets/images/posts/")

    warnings << "#{path}: prefer `{% include post-image.html file=\"...\" %}` instead of a hard-coded post asset path: #{ref}"
  end
end

if checked_count.zero?
  fail_with("No post files found in #{POSTS_GLOB}")
end

if errors.any?
  warn("Front matter validation failed with #{errors.size} issue(s):")
  errors.each { |error| warn("  - #{error}") }
  exit(1)
end

if warnings.any?
  warn("Front matter validation warnings:")
  warnings.each { |warning| warn("  - #{warning}") }
end

puts("Front matter validation passed for #{checked_count} post(s).")
