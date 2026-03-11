#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "date"
require "time"

ROOT = File.expand_path("..", __dir__)
POSTS_GLOB = File.join(ROOT, "_posts", "**", "*.md")

def parse_front_matter(path)
  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  raise "missing front matter block" unless match

  front_matter = YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true)
  raise "front matter must be a YAML map" unless front_matter.is_a?(Hash)

  front_matter
end

drafts = []

Dir.glob(POSTS_GLOB).sort.each do |path|
  begin
    front_matter = parse_front_matter(path)
  rescue StandardError => e
    warn("Skipping #{path}: #{e.message}")
    next
  end

  next unless front_matter["draft"] == true

  title = front_matter["title"].to_s.strip
  date = front_matter["date"].to_s.strip
  category = Array(front_matter["categories"]).first.to_s.strip
  subcategory = front_matter["subcategory"].to_s.strip
  relative_path = path.sub("#{ROOT}/", "")
  taxonomy = [category, subcategory].reject(&:empty?).join("/")
  drafts << [date, title, taxonomy, relative_path]
end

if drafts.empty?
  puts("No draft posts found.")
  exit(0)
end

drafts.each do |date, title, category, relative_path|
  puts("#{date}\t#{category}\t#{title}\t#{relative_path}")
end
