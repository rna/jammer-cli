# frozen_string_literal: true

require "yaml"

module Jammer
  # Handles loading and parsing the .jammer.yml configuration file.
  class Config
    DEFAULT_KEYWORD = "#TODO"
    CONFIG_FILENAME = ".jammer.yml"
    ALLOWED_KEYS = %w[keywords exclude commands].freeze

    def initialize(path = Dir.pwd)
      @config = load_config(find_config_file(path))
    end

    def self.define_config_accessor(name, default: nil)
      define_method(name) do
        @config.fetch(name.to_s, default)
      end
    end
    private_class_method :define_config_accessor

    # Dynamically define config accessors
    define_config_accessor :keywords, default: [DEFAULT_KEYWORD]
    define_config_accessor :exclude, default: []
    define_config_accessor :commands, default: []

    private

    def load_config(file_path)
      return {} unless file_path && File.exist?(file_path)

      content = YAML.safe_load_file(file_path, permitted_classes: [], aliases: false)
      return {} if content.nil?
      raise Jammer::ConfigError, "#{CONFIG_FILENAME} must be a YAML object." unless content.is_a?(Hash)

      normalized = content.transform_keys(&:to_s)
      validate_config!(normalized)
      normalized
    rescue Psych::SyntaxError => e
      raise Jammer::ConfigError, "Invalid syntax in #{CONFIG_FILENAME} at line #{e.line}: #{e.problem}"
    rescue Errno::EACCES
      raise Jammer::ConfigError, "Permission denied reading #{CONFIG_FILENAME}."
    end

    def validate_config!(content)
      unknown_keys = content.keys - ALLOWED_KEYS
      if unknown_keys.any?
        raise Jammer::ConfigError, "Unknown setting(s) in #{CONFIG_FILENAME}: #{unknown_keys.join(', ')}"
      end

      ALLOWED_KEYS.each do |key|
        next unless content.key?(key)

        validate_array_of_strings!(key, content[key])
      end
    end

    def validate_array_of_strings!(key, value)
      unless value.is_a?(Array)
        raise Jammer::ConfigError, "'#{key}' must be an array of strings in #{CONFIG_FILENAME}."
      end

      return if value.all? { |entry| entry.is_a?(String) && !entry.strip.empty? }

      raise Jammer::ConfigError, "'#{key}' must contain only non-empty strings in #{CONFIG_FILENAME}."
    end

    def find_config_file(start_path)
      current = File.expand_path(start_path)
      loop do
        path = File.join(current, CONFIG_FILENAME)
        return path if File.exist?(path)

        parent = File.dirname(current)
        break if parent == current

        current = parent
      end
      nil
    end
  end
end
