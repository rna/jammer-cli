# frozen_string_literal: true

require 'fileutils'
require_relative 'git'

module Jammer
  class HookManager
    HOOK_SIGNATURE = '# Hook installed by jammer-cli'

    def self.hook_template_path
      gem_spec = Gem.loaded_specs['jammer-cli']
      raise HookError, 'jammer-cli gem specification not found' unless gem_spec

      File.join(gem_spec.full_gem_path, 'hooks', 'pre-commit')
    end

    def self.config_example_path
      gem_spec = Gem.loaded_specs['jammer-cli']
      raise HookError, 'jammer-cli gem specification not found' unless gem_spec

      File.join(gem_spec.full_gem_path, '.jammer.yml.example')
    end

    def self.init_config(options = {})
      config_path = File.join(Dir.pwd, '.jammer.yml')

      if File.exist?(config_path) && !options[:force]
        raise HookError, '.jammer.yml already exists. Use --force to overwrite.'
      end

      begin
        example_content = File.read(config_example_path)
        File.write(config_path, example_content)
      rescue StandardError => e
        raise HookError, "Error creating config file: #{e.message}"
      end

      # Return early if not in git repo, but don't fail
      return unless Jammer::Git.inside_work_tree?

      install_hook(options)
    end

    def self.uninstall_config
      config_path = File.join(Dir.pwd, '.jammer.yml')
      hook_path = get_hook_path

      config_exists = File.exist?(config_path)
      hook_exists = hook_path && File.exist?(hook_path)

      unless config_exists || hook_exists
        raise HookError, 'Nothing to uninstall. No .jammer.yml or git hook found.'
      end

      remove_config_file(config_path) if config_exists
      remove_hook_file(hook_path) if hook_exists && hook_path
    end

    private

    def self.get_hook_path
      return nil unless Jammer::Git.inside_work_tree?

      git_dir = `git rev-parse --git-dir`.strip
      File.join(git_dir, 'hooks', 'pre-commit')
    end

    def self.remove_config_file(config_path)
      File.delete(config_path)
    rescue StandardError => e
      raise HookError, "Error removing config file: #{e.message}"
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
      git_dir = `git rev-parse --git-dir`.strip
      hooks_dir = File.join(git_dir, 'hooks')
      pre_commit_hook_path = File.join(hooks_dir, 'pre-commit')

      unless Dir.exist?(hooks_dir)
        raise HookError, '.git/hooks directory not found'
      end

      hook_content_to_install = File.read(hook_template_path)

      if File.exist?(pre_commit_hook_path) && !options[:force]
        handle_existing_hook(pre_commit_hook_path, hook_content_to_install)
      end

      write_hook_file(pre_commit_hook_path, hook_content_to_install)
    end

    def self.handle_existing_hook(hook_path, hook_content)
      existing_content = File.read(hook_path)

      if existing_content.include?(HOOK_SIGNATURE)
        raise HookError, 'A jammer-cli hook already exists. Use --force to overwrite.'
      else
        raise HookError, 'A custom pre-commit hook already exists. Cannot auto-install.'
      end
    end

    def self.write_hook_file(hook_path, content)
      File.write(hook_path, content)
      FileUtils.chmod('+x', hook_path)
    rescue StandardError => e
      raise HookError, "Error installing hook: #{e.message}"
    end
  end
end