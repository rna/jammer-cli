# frozen_string_literal: true

require 'yaml'

module Jammer
  # Handles loading and parsing the .jammer.yml configuration file.
  class Config
    DEFAULT_KEYWORD = '#TODO'
    CONFIG_FILENAME = '.jammer.yml'

    def initialize(path = Dir.pwd)
      @config = load_config(find_config_file(path))
    end

    def keywords
      @config.fetch('keywords', [DEFAULT_KEYWORD])
    end

    def exclude
      @config.fetch('exclude', [])
    end

    def commands
      @config.fetch('commands', [])
    end

    private

    def load_config(file_path)
      return {} unless file_path && File.exist?(file_path)

      content = YAML.safe_load(File.read(file_path), permitted_classes: [])
      return {} unless content.is_a?(Hash)

      content
    rescue Psych::SyntaxError => e
      warn "Warning: Invalid syntax in #{CONFIG_FILENAME} at line #{e.line}: #{e.message}. Using default configuration."
      {}
    rescue Errno::EACCES
      warn "Warning: Permission denied reading #{CONFIG_FILENAME}. Using default configuration."
      {}
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
