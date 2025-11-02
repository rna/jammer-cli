# frozen_string_literal: true

require_relative "path_resolver"

# Manages configuration file operations
module Jammer
  class ConfigManager
    def self.setup(options = {})
      config_path = PathResolver.config_path
      config_exists = File.exist?(config_path)

      unless config_exists && !options[:force]
        create_config_file(config_path)
        return true
      end

      false
    end

    def self.remove
      config_path = PathResolver.config_path

      raise HookError, "No .jammer.yml found to remove." unless File.exist?(config_path)

      File.delete(config_path)
    rescue StandardError => e
      raise HookError, "Error removing config file: #{e.message}"
    end

    def self.exists?
      File.exist?(PathResolver.config_path)
    end

    def self.create_config_file(config_path)
      example_content = File.read(PathResolver.config_example_path)
      File.write(config_path, example_content)
    rescue StandardError => e
      raise HookError, "Error creating config file: #{e.message}"
    end
  end
end
