# frozen_string_literal: true

require 'fileutils'
require_relative 'git'

module Jammer
  class HookManager
    HOOK_TEMPLATE_PATH = File.expand_path('../../../hooks/pre-commit', __dir__)
    HOOK_SIGNATURE = '# Hook installed by jammer-cli'

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

      hook_content_to_install = File.read(HOOK_TEMPLATE_PATH)

      if File.exist?(pre_commit_hook_path) && !options[:force]
        existing_content = File.read(pre_commit_hook_path)

        # Check if the existing hook was installed
        if existing_content.include?(HOOK_SIGNATURE)
          print "Warning: A jammer-cli hook already exists at '#{pre_commit_hook_path}'. Overwrite? [y/N] "
          overwrite = STDIN.gets.chomp.downcase
          unless overwrite == 'y'
            puts "Aborted. Use --force to overwrite."
            exit 0
          end
        else
          # If it's a custom hook, refuse to overwrite and provide manual instructions.
          warn "Warning: A custom pre-commit hook already exists."
          warn "To avoid overwriting it, jammer-cli will not install the hook automatically."
          warn "\nPlease add the following script block to your existing '#{pre_commit_hook_path}' file to enable jammer:\n\n"
          warn "---"
          warn hook_content_to_install.strip
          warn "---\n"
          exit 1
        end
      end

      puts "Installing pre-commit hook..."

      begin
        File.write(pre_commit_hook_path, hook_content_to_install)
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

      unless File.exist?(pre_commit_hook_path)
        puts "No jammer-cli pre-commit hook found to uninstall."
        exit 0
      end

      existing_content = File.read(pre_commit_hook_path)

      # Only proceed if the hook seems to be one we installed.
      unless existing_content.include?(HOOK_SIGNATURE)
        puts "Warning: An existing pre-commit hook was found that was not installed by jammer-cli. Skipping uninstall."
        exit 1
      end

      # To prevent data loss, compare the existing hook with the template.
      # If they are different, the user may have customized it.
      template_content = File.read(HOOK_TEMPLATE_PATH)

      # Use strip to ignore potential trailing newline differences.
      if existing_content.strip == template_content.strip
        # Contents are identical, so it's safe to delete.
        begin
          File.delete(pre_commit_hook_path)
          puts "Successfully uninstalled pre-commit hook from '#{pre_commit_hook_path}'"
          exit 0
        rescue => e
          puts "Error uninstalling hook: #{e.message}"
          exit 1
        end
      else
        # Contents are different, so refuse to delete and warn the user.
        warn "Warning: Your pre-commit hook has been modified and will not be removed automatically."
        warn "To complete the uninstallation, please manually remove the jammer-cli script block from:"
        warn "  '#{pre_commit_hook_path}'"
        exit 1
      end
    end
  end
end
