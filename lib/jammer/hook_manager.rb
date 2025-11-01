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
        puts "Created .jammer.yml in #{Dir.pwd}"
        puts "Edit it to customize keywords and exclude patterns for your project."
        exit 0
      rescue StandardError => e
        puts "Error creating config file: #{e.message}"
        exit 1
      end
    end

    def self.install(options = {})
      unless Jammer::Git.inside_work_tree?
        puts 'Error: Not inside a Git repository.'
        exit 1
      end

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

        # Check if the existing hook was installed
        if existing_content.include?(HOOK_SIGNATURE)
          print "Warning: A jammer-cli hook already exists at '#{pre_commit_hook_path}'. Overwrite? [y/N] "
          overwrite = STDIN.gets.chomp.downcase
          unless overwrite == 'y'
            puts 'Aborted. Use --force to overwrite.'
            exit 0
          end
        else
          # If it's a custom hook, refuse to overwrite and provide manual instructions.
          warn 'Warning: A custom pre-commit hook already exists.'
          warn 'To avoid overwriting it, jammer-cli will not install the hook automatically.'
          warn "\nPlease add the following script block to your existing '#{pre_commit_hook_path}' file to enable jammer:\n\n"
          warn '---'
          warn hook_content_to_install.strip
          warn "---\n"
          exit 1
        end
      end

      puts 'Installing pre-commit hook...'

      begin
        File.write(pre_commit_hook_path, hook_content_to_install)
        FileUtils.chmod('+x', pre_commit_hook_path)
        puts "Successfully installed pre-commit hook to '#{pre_commit_hook_path}'"
        exit 0
      rescue StandardError => e
        puts "Error installing hook: #{e.message}"
        exit 1
      end
    end

    def self.uninstall
      unless Jammer::Git.inside_work_tree?
        puts 'Error: Not inside a Git repository.'
        exit 1
      end

      git_dir = `git rev-parse --git-dir`.strip
      pre_commit_hook_path = File.join(git_dir, 'hooks', 'pre-commit')

      unless File.exist?(pre_commit_hook_path)
        puts 'No jammer-cli pre-commit hook found to uninstall.'
        exit 0
      end

      existing_content = File.read(pre_commit_hook_path)

      # Only proceed if the hook seems to be one we installed.
      unless existing_content.include?(HOOK_SIGNATURE)
        puts 'Warning: An existing pre-commit hook was found that was not installed by jammer-cli. Skipping uninstall.'
        exit 1
      end
      # To prevent data loss, compare the existing hook with the template.
      # If they are different, the user may have customized it.
      template_content = File.read(hook_template_path)

      # Use strip to ignore potential trailing newline differences.
      if existing_content.strip == template_content.strip
        # Contents are identical, so it's safe to delete.
        begin
          File.delete(pre_commit_hook_path)
          puts "Successfully uninstalled pre-commit hook from '#{pre_commit_hook_path}'"
          exit 0
        rescue StandardError => e
          puts "Error uninstalling hook: #{e.message}"
          exit 1
        end
      else
        # Contents are different, so refuse to delete and warn the user.
        warn 'Warning: Your pre-commit hook has been modified and will not be removed automatically.'
        warn 'To complete the uninstallation, please manually remove the jammer-cli script block from:'
        warn "  '#{pre_commit_hook_path}'"
        exit 1
      end
    end
  end
end
