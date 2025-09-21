# frozen_string_literal: true

require 'fileutils'
require_relative 'git'

module Jammer
  class HookManager
    HOOK_TEMPLATE_PATH = File.expand_path('../../../hooks/pre-commit', __dir__)

    def self.install(options = {})
      unless Jammer::Git.inside_work_tree?
        puts "Error: Not inside a Git repository."
        exit 1
      end

      git_dir = `git rev-parse --git-dir`.strip
      hooks_dir = File.join(git_dir, 'hooks')
      pre_commit_hook_path = File.join(hooks_dir, 'pre-commit')

      unless Dir.exist?(hooks_dir)
        puts "Error: '.git/hooks' directory not found."
        exit 1
      end

      if File.exist?(pre_commit_hook_path) && !options[:force]
        print "Warning: '#{pre_commit_hook_path}' already exists. Overwrite? [y/N] "
        overwrite = STDIN.gets.chomp.downcase
        unless overwrite == 'y'
          puts "Aborted. Use --force to overwrite."
          exit 0
        end
      end

      puts "Installing pre-commit hook..."

      begin
        # Read the hook content from the template file
        hook_content = File.read(HOOK_TEMPLATE_PATH)

        File.write(pre_commit_hook_path, hook_content)
        FileUtils.chmod('+x', pre_commit_hook_path)
        puts "Successfully installed pre-commit hook to '#{pre_commit_hook_path}'"
        exit 0
      rescue => e
        puts "Error installing hook: #{e.message}"
        exit 1
      end
    end

    def self.uninstall
      unless Jammer::Git.inside_work_tree?
        puts "Error: Not inside a Git repository."
        exit 1
      end

      git_dir = `git rev-parse --git-dir`.strip
      pre_commit_hook_path = File.join(git_dir, 'hooks', 'pre-commit')

      if File.exist?(pre_commit_hook_path)
        content = File.read(pre_commit_hook_path)
        if content.include?("# Hook installed by jammer-cli")
          begin
            File.delete(pre_commit_hook_path)
            puts "Successfully uninstalled pre-commit hook from '#{pre_commit_hook_path}'"
            exit 0
          rescue => e
            puts "Error uninstalling hook: #{e.message}"
            exit 1
          end
        else
          puts "Warning: An existing pre-commit hook was found that was not installed by jammer-cli. Skipping uninstall."
          exit 1
        end
      else
        puts "No jammer-cli pre-commit hook found to uninstall."
        exit 0
      end
    end
  end
end
