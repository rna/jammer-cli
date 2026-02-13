# frozen_string_literal: true

require_relative "path_resolver"

# Manages configuration file operations
module Jammer
  class ConfigManager
    # rubocop:disable Naming/PredicateMethod
    def self.setup(options = {})
      config_path = PathResolver.config_path
      config_exists = File.exist?(config_path)

      unless config_exists && !options[:force]
        create_config_file(config_path)
        return true
      end

      false
    end
    # rubocop:enable Naming/PredicateMethod

    def self.remove
      config_path = PathResolver.config_path

      raise HookError, "No .jammer.yml found to remove." unless File.exist?(config_path)

      safe_operation("removing config file") do
        File.delete(config_path)
      end
    end

    def self.exists?
      File.exist?(PathResolver.config_path)
    end

    def self.create_config_file(config_path)
      safe_operation("creating config file") do
        example_content = File.read(PathResolver.config_example_path)
        File.write(config_path, example_content)
      end
    end

    def self.safe_operation(operation_name)
      yield
    rescue StandardError => e
      raise HookError, "Error #{operation_name}: #{e.message}"
    end
    private_class_method :safe_operation
  end
end
