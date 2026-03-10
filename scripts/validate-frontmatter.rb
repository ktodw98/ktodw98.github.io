#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "time"
require "date"

ROOT = File.expand_path("..", __dir__)
TAXONOMIES_PATH = File.join(ROOT, "_data", "taxonomies.yml")
POSTS_GLOB = File.join(ROOT, "_posts", "**", "*.md")
TAG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
ALLOWED_TYPES = %w[article tutorial case-study log reference].freeze
ALLOWED_IMPORT_MODES = %w[summary repost].freeze
IMAGE_PATH_PATTERN = /\A(?:https?:\/\/\S+|\/\S+)\z/

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

  front_matter
end

def normalize_string(value)
  value.is_a?(String) ? value.strip : ""
end

def parse_time(value)
  return value if value.is_a?(Time) || value.is_a?(Date)
  Time.parse(value.to_s)
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

if active_category_ids.empty?
  fail_with("No active categories found in #{TAXONOMIES_PATH}")
end

errors = []
checked_count = 0

Dir.glob(POSTS_GLOB).sort.each do |path|
  checked_count += 1
  begin
    fm = parse_front_matter(path)
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

  unless fm["image"].nil?
    image = normalize_string(fm["image"])
    if image.empty?
      errors << "#{path}: `image` must not be blank when provided"
    elsif !IMAGE_PATH_PATTERN.match?(image)
      errors << "#{path}: `image` must be an absolute path like /assets/images/... or an http/https URL"
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
end

if checked_count.zero?
  fail_with("No post files found in #{POSTS_GLOB}")
end

if errors.any?
  warn("Front matter validation failed with #{errors.size} issue(s):")
  errors.each { |error| warn("  - #{error}") }
  exit(1)
end

puts("Front matter validation passed for #{checked_count} post(s).")
