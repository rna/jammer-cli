# frozen_string_literal: true

require 'optparse'
require_relative '../jammer'

module Jammer
  class CommandLineInterface
    def initialize(args = ARGV)
      @args = args
      @options = {}
      @scanner = Jammer::Scanner.new
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
        opts.banner = "Usage: jammer [options]"

        opts.separator ""
        opts.separator "Keyword checking options:"

        opts.on('-a', '--keyword KEYWORD', 'Assigns a new search keyword') do |keyword|
          @scanner.keyword = keyword
        end

        opts.on('-l', '--list', 'List all occurrences of the keyword') do
          @options[:action] = :list
        end

        opts.on('-c', '--count', 'Count all occurrences of the keyword') do
          @options[:action] = :count
        end

        opts.separator ""
        opts.separator "Git Hook options:"

        opts.on('--install-hook', 'Install the pre-commit hook in the current Git repository') do
          @options[:action] = :install_hook
        end

        opts.on('--uninstall-hook', 'Uninstall the pre-commit hook') do
          @options[:action] = :uninstall_hook
        end

        opts.separator ""
        opts.separator "Other options:"

        opts.on('-f', '--force', 'Force overwrite of existing git hooks') do
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
      when :install_hook
        Jammer::HookManager.install(@options)
        exit 0
      when :uninstall_hook
        Jammer::HookManager.uninstall
        exit 0
      else
        check_keywords
      end
    end

    def check_keywords
      if @scanner.exists?
        puts "Found keywords like '#{@scanner.keyword}'. Aborting commit."
        exit 1
      else
        exit 0
      end
    end
  end
end
