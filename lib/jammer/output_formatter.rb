# frozen_string_literal: true

# Handles all output formatting and display
module Jammer
  class OutputFormatter
    def self.version
      "Jammer version #{Jammer::VERSION}"
    end

    def self.help(parser)
      parser.to_s
    end

    def self.keywords_found(keywords)
      "Found keywords: #{keywords.join(', ')}. Aborting commit."
    end

    def self.config_created
      "✓ Created .jammer.yml"
    end

    def self.config_already_exists
      "ℹ .jammer.yml already exists"
    end

    def self.hook_created
      "✓ Successfully installed pre-commit hook"
    end

    def self.hook_already_exists
      "ℹ Git pre-commit hook already exists"
    end

    def self.not_in_git_repo
      <<~MSG

        Note: Not in a Git repository. Run 'jammer --init' from a Git repository to install the hook.
      MSG
    end

    def self.config_removed
      "✓ Removed .jammer.yml"
    end

    def self.hook_removed
      "✓ Removed Git pre-commit hook"
    end

    def self.uninstall_complete
      "Jammer has been uninstalled from this project."
    end

    def self.error(message)
      "An error occurred: #{message}"
    end

    def self.init_status(status, in_git_repo: true)
      output = String.new
      output << config_created if status[:config_created]
      output << config_already_exists unless status[:config_created]
      output << hook_status(status, in_git_repo: in_git_repo)
      output
    end

    def self.hook_status(status, in_git_repo: true)
      if status[:hook_created]
        hook_created
      elsif !in_git_repo
        not_in_git_repo
      else
        hook_already_exists
      end
    end
  end
end
