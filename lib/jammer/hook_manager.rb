# frozen_string_literal: true

require "fileutils"
require "open3"
require_relative "git"
require_relative "path_resolver"
require_relative "config_manager"

module Jammer
  class HookManager
    HOOK_SIGNATURE = "# Hook installed by jammer-cli"

    def self.init_config(options = {})
      status = { config_created: false, hook_created: false }
      status[:config_created] = ConfigManager.setup(options)
      status[:hook_created] = init_hook(options) if Jammer::Git.inside_work_tree?
      status
    end

    # rubocop:disable Naming/PredicateMethod
    def self.init_hook(options = {})
      hook_path = PathResolver.hook_path
      hook_exists = hook_path && File.exist?(hook_path)

      return false if hook_exists && !options[:force] && hook_already_by_jammer?(hook_path)

      install_hook(options)
      !hook_exists
    end
    # rubocop:enable Naming/PredicateMethod

    def self.uninstall_config
      config_exists = ConfigManager.exists?
      hook_path = PathResolver.hook_path
      hook_exists = hook_path && File.exist?(hook_path)
      status = { config_removed: false, hook_removed: false }

      raise HookError, "Nothing to uninstall. No .jammer.yml or git hook found." unless config_exists || hook_exists

      remove_config_if_needed(config_exists, status)
      remove_hook_if_needed(hook_exists, hook_path, status)

      status
    end

    def self.remove_config_if_needed(config_exists, status)
      return unless config_exists

      ConfigManager.remove
      status[:config_removed] = true
    end

    def self.remove_hook_if_needed(hook_exists, hook_path, status)
      return unless hook_exists && hook_path

      remove_hook_file(hook_path)
      status[:hook_removed] = true
    end

    def self.hook_already_by_jammer?(hook_path)
      return false unless hook_path && File.exist?(hook_path)

      File.read(hook_path).include?(HOOK_SIGNATURE)
    end

    def self.remove_hook_file(hook_path)
      safe_operation("removing hook") do
        hook_content = File.read(hook_path)

        unless hook_content.include?(HOOK_SIGNATURE)
          raise HookError, "Custom pre-commit hook found (not created by jammer). Skipping removal."
        end

        File.delete(hook_path)
      end
    end

    def self.install_hook(options = {})
      hook_path = PathResolver.hook_path
      hooks_dir = File.dirname(hook_path)

      raise HookError, ".git/hooks directory not found" unless Dir.exist?(hooks_dir)

      if File.exist?(hook_path) && !options[:force]
        existing_content = File.read(hook_path)

        return if existing_content.include?(HOOK_SIGNATURE)

        # Jammer hook already exists - return silently (skip)

        raise HookError, "A custom pre-commit hook already exists. Cannot auto-install."

      end

      hook_content_to_install = File.read(PathResolver.hook_template_path)
      write_hook_file(hook_path, hook_content_to_install)
    end

    def self.write_hook_file(hook_path, content)
      safe_operation("installing hook") do
        File.write(hook_path, content)
        FileUtils.chmod("+x", hook_path)
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
