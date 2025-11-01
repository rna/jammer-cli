# frozen_string_literal: true

require 'fileutils'
require_relative 'git'

module Jammer
  class HookManager
    HOOK_SIGNATURE = '# Hook installed by jammer-cli'

    def self.hook_template_path
      gem_spec = Gem.loaded_specs['jammer-cli']
      raise 'Could not find jammer-cli gem specification' unless gem_spec

      File.join(gem_spec.full_gem_path, 'hooks', 'pre-commit')
    end

    def self.config_example_path
      gem_spec = Gem.loaded_specs['jammer-cli']
      raise 'Could not find jammer-cli gem specification' unless gem_spec

      File.join(gem_spec.full_gem_path, '.jammer.yml.example')
    end

    def self.init_config(options = {})
      config_path = File.join(Dir.pwd, '.jammer.yml')

      if File.exist?(config_path) && !options[:force]
        puts "Error: .jammer.yml already exists. Use --force to overwrite."
        exit 1
      end

      begin
        example_content = File.read(config_example_path)
        File.write(config_path, example_content)
        puts "✓ Created .jammer.yml"
      rescue StandardError => e
        puts "Error creating config file: #{e.message}"
        exit 1
      end

      if Jammer::Git.inside_work_tree?
        puts "✓ Setting up Git pre-commit hook..."
        install_hook(options)
      else
        puts ""
        puts "Note: Not in a Git repository. Run 'jammer --init' from a Git repository to install the hook."
        exit 0
      end
    end

    def self.uninstall_config
      config_path = File.join(Dir.pwd, '.jammer.yml')
      hook_path = get_hook_path

      config_exists = File.exist?(config_path)
      hook_exists = hook_path && File.exist?(hook_path)

      unless config_exists || hook_exists
        puts "Nothing to uninstall. No .jammer.yml or git hook found."
        exit 0
      end

      if config_exists
        begin
          File.delete(config_path)
          puts "✓ Removed .jammer.yml"
        rescue StandardError => e
          puts "Error removing config file: #{e.message}"
          exit 1
        end
      end

      if hook_exists && hook_path
        begin
          hook_content = File.read(hook_path)
          if hook_content.include?(HOOK_SIGNATURE)
            File.delete(hook_path)
            puts "✓ Removed Git pre-commit hook"
          else
            puts "Note: Custom pre-commit hook found (not created by jammer). Skipping removal."
          end
        rescue StandardError => e
          puts "Error removing hook: #{e.message}"
          exit 1
        end
      end

      puts "Jammer has been uninstalled from this project."
      exit 0
    end

    private

    def self.get_hook_path
      return nil unless Jammer::Git.inside_work_tree?

      git_dir = `git rev-parse --git-dir`.strip
      File.join(git_dir, 'hooks', 'pre-commit')
    end

    def self.install_hook(options = {})
      git_dir = `git rev-parse --git-dir`.strip
      hooks_dir = File.join(git_dir, 'hooks')
      pre_commit_hook_path = File.join(hooks_dir, 'pre-commit')

      unless Dir.exist?(hooks_dir)
        puts "Error: '.git/hooks' directory not found."
        exit 1
      end

      hook_content_to_install = File.read(hook_template_path)

      if File.exist?(pre_commit_hook_path) && !options[:force]
        existing_content = File.read(pre_commit_hook_path)

        if existing_content.include?(HOOK_SIGNATURE)
          print "Warning: A jammer-cli hook already exists. Overwrite? [y/N] "
          overwrite = STDIN.gets.chomp.downcase
          unless overwrite == 'y'
            puts 'Aborted. Use --force to overwrite.'
            exit 0
          end
        else
          warn 'Warning: A custom pre-commit hook already exists.'
          warn 'To avoid overwriting it, jammer-cli will not install the hook automatically.'
          warn "\nPlease manually add jammer to your existing hook."
          exit 1
        end
      end

      begin
        File.write(pre_commit_hook_path, hook_content_to_install)
        FileUtils.chmod('+x', pre_commit_hook_path)
        puts "✓ Successfully installed pre-commit hook"
        exit 0
      rescue StandardError => e
        puts "Error installing hook: #{e.message}"
        exit 1
      end
    end
  end
end
