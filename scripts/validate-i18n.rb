#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
CONFIG_PATH = File.join(ROOT, "_config.yml")
I18N_DIR = File.join(ROOT, "_data", "i18n")

def fail_with(message)
  warn(message)
  exit(1)
end

def flatten_keys(value, prefix = "", keys = [])
  if value.is_a?(Hash)
    value.each do |k, v|
      key = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
      flatten_keys(v, key, keys)
    end
  else
    keys << prefix
  end
  keys
end

unless File.exist?(CONFIG_PATH)
  fail_with("Missing config: #{CONFIG_PATH}")
end

config = YAML.safe_load(File.read(CONFIG_PATH), aliases: true)
unless config.is_a?(Hash)
  fail_with("Invalid _config.yml format.")
end

supported_locales = config.fetch("supported_locales", [])
default_locale = config["default_locale"].to_s

unless supported_locales.is_a?(Array) && supported_locales.all? { |item| item.is_a?(String) && !item.strip.empty? }
  fail_with("`supported_locales` must be a non-empty string array in _config.yml")
end

supported_locales = supported_locales.map(&:strip).uniq
fail_with("`default_locale` must be set in _config.yml") if default_locale.empty?
fail_with("`default_locale` must be included in `supported_locales`") unless supported_locales.include?(default_locale)

locale_data = {}
supported_locales.each do |locale|
  path = File.join(I18N_DIR, "#{locale}.yml")
  fail_with("Missing locale dictionary: #{path}") unless File.exist?(path)

  data = YAML.safe_load(File.read(path), aliases: true)
  unless data.is_a?(Hash)
    fail_with("Locale dictionary must be a map: #{path}")
  end

  locale_data[locale] = data
end

baseline_keys = flatten_keys(locale_data.fetch(default_locale)).sort
errors = []

supported_locales.each do |locale|
  keys = flatten_keys(locale_data.fetch(locale)).sort
  missing = baseline_keys - keys
  extra = keys - baseline_keys

  missing.each { |key| errors << "#{locale}: missing key `#{key}`" }
  extra.each { |key| errors << "#{locale}: unexpected key `#{key}`" }
end

if errors.any?
  warn("i18n validation failed with #{errors.size} issue(s):")
  errors.each { |error| warn("  - #{error}") }
  exit(1)
end

puts("i18n validation passed for locales: #{supported_locales.join(', ')}")
