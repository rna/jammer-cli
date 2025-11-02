# frozen_string_literal: true

require 'optparse'
require_relative '../jammer'

module Jammer
  class CommandLineInterface
    def initialize(args = ARGV, config: nil)
      @args = args
      @options = {}
      @config = config || Jammer::Config.new
      @scanner = Jammer::Scanner.new(@config.keywords, @config.exclude)
    end

    def run
      parse_options
      execute_command
    rescue Jammer::Error => e
      warn "An error occurred: #{e.message}" # Using warn prints to STDERR
      exit 2
    end

    private

    def parse_options
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: jammer [options]'

        opts.separator ''
        opts.separator 'Keyword checking options:'

        opts.on('-a', '--keyword KEYWORD', 'Assigns a new search keyword') do |keyword|
          @scanner.keyword = keyword
        end

        opts.on('-l', '--list', 'List all occurrences of the keyword') do
          @options[:action] = :list
        end

        opts.on('-c', '--count', 'Count all occurrences of the keyword') do
          @options[:action] = :count
        end

        opts.separator ''
        opts.separator 'Setup options:'

        opts.on('--init', 'Initialize jammer in current project (creates config + git hook)') do
          @options[:action] = :init
        end

        opts.on('--uninstall', 'Remove jammer from current project (removes config + git hook)') do
          @options[:action] = :uninstall
        end

        opts.separator ''
        opts.separator 'Other options:'

        opts.on('-f', '--force', 'Force overwrite of existing config and hooks') do
          @options[:force] = true
        end

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit 0
        end

        opts.on('-v', '--version', 'Show version') do
          puts "Jammer version #{Jammer::VERSION}"
          exit 0
        end
      end

      parser.parse!(@args)
    rescue OptionParser::InvalidOption => e
      puts "Error: #{e.message}"
      puts parser
      exit 1
    end

    def execute_command
      case @options[:action]
      when :list
        puts @scanner.occurrence_list
        exit 0
      when :count
        puts @scanner.occurrence_count
        exit 0
      when :init
        handle_init
      when :uninstall
        handle_uninstall
      else
        check_keywords_and_commands
      end
    end

    def handle_init
      status = Jammer::HookManager.init_config(@options)

      if status[:config_created]
        puts "✓ Created .jammer.yml"
      else
        puts "ℹ .jammer.yml already exists"
      end

      if status[:hook_created]
        puts "✓ Successfully installed pre-commit hook"
      elsif !Jammer::Git.inside_work_tree?
        puts ""
        puts "Note: Not in a Git repository. Run 'jammer --init' from a Git repository to install the hook."
      else
        puts "ℹ Git pre-commit hook already exists"
      end

      exit 0
    rescue Jammer::HookError => e
      warn "Error: #{e.message}"
      exit 1
    end

    def handle_uninstall
      Jammer::HookManager.uninstall_config
      puts "✓ Removed .jammer.yml"
      puts "✓ Removed Git pre-commit hook"
      puts "Jammer has been uninstalled from this project."
      exit 0
    rescue Jammer::HookError => e
      warn "Error: #{e.message}"
      exit 1
    end

    def check_keywords_and_commands
      if @scanner.exists?
        keywords_str = @scanner.keywords.join(", ")
        puts "Found keywords: #{keywords_str}. Aborting commit."
        exit 1
      end

      commands = @config.commands
      if commands.any?
        executor = Jammer::CommandExecutor.new(commands)
        executor.run_all

        unless executor.all_passed?
          puts executor.report
          exit 1
        end
      end

      exit 0
    end
  end
end
