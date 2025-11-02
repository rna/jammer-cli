# frozen_string_literal: true

require 'fileutils'
require 'open3'
require_relative 'git'
require_relative 'path_resolver'
require_relative 'config_manager'

module Jammer
  class HookManager
    HOOK_SIGNATURE = '# Hook installed by jammer-cli'

    def self.init_config(options = {})
      status = { config_created: false, hook_created: false }

      # Setup config file (independent of hook)
      status[:config_created] = ConfigManager.setup(options)

      # Setup hook file if in git repo (independent of config status)
      if Jammer::Git.inside_work_tree?
        hook_path = PathResolver.hook_path
        hook_exists = hook_path && File.exist?(hook_path)

        # Only mark as created if hook didn't exist before
        unless hook_exists && !options[:force] && hook_already_by_jammer?(hook_path)
          install_hook(options)
          status[:hook_created] = !hook_exists
        end
      end

      status
    end

    def self.uninstall_config
      config_exists = ConfigManager.exists?
      hook_path = PathResolver.hook_path
      hook_exists = hook_path && File.exist?(hook_path)

      unless config_exists || hook_exists
        raise HookError, 'Nothing to uninstall. No .jammer.yml or git hook found.'
      end

      ConfigManager.remove if config_exists
      remove_hook_file(hook_path) if hook_exists && hook_path
    end

    private

    def self.hook_already_by_jammer?(hook_path)
      return false unless hook_path && File.exist?(hook_path)

      File.read(hook_path).include?(HOOK_SIGNATURE)
    end

    def self.remove_hook_file(hook_path)
      hook_content = File.read(hook_path)

      unless hook_content.include?(HOOK_SIGNATURE)
        raise HookError, 'Custom pre-commit hook found (not created by jammer). Skipping removal.'
      end

      File.delete(hook_path)
    rescue StandardError => e
      raise HookError, "Error removing hook: #{e.message}"
    end

    def self.install_hook(options = {})
      hook_path = PathResolver.hook_path
      hooks_dir = File.dirname(hook_path)

      unless Dir.exist?(hooks_dir)
        raise HookError, '.git/hooks directory not found'
      end

      if File.exist?(hook_path) && !options[:force]
        existing_content = File.read(hook_path)

        if existing_content.include?(HOOK_SIGNATURE)
          # Jammer hook already exists - return silently (skip)
          return
        else
          raise HookError, 'A custom pre-commit hook already exists. Cannot auto-install.'
        end
      end

      hook_content_to_install = File.read(PathResolver.hook_template_path)
      write_hook_file(hook_path, hook_content_to_install)
    end

    def self.write_hook_file(hook_path, content)
      File.write(hook_path, content)
      FileUtils.chmod('+x', hook_path)
    rescue StandardError => e
      raise HookError, "Error installing hook: #{e.message}"
    end
  end
end