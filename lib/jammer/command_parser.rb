# frozen_string_literal: true

require "optparse"

# Parses command-line arguments and returns structured options
module Jammer
  class CommandParser
    def initialize(args = ARGV)
      @args = args
      @options = {}
    end

    def parse
      parser.parse!(@args)
      @options
    rescue OptionParser::InvalidOption => e
      raise Jammer::ConfigError, "#{e.message}\n\n#{parser}"
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: jammer [options]"

        opts.separator ""
        opts.separator "Keyword checking options:"

        opts.on("-a", "--keyword KEYWORD", "Assigns a new search keyword") do |keyword|
          @options[:keyword] = keyword
        end

        opts.on("-l", "--list", "List all occurrences of the keyword") do
          @options[:action] = :list
        end

        opts.on("-c", "--count", "Count all occurrences of the keyword") do
          @options[:action] = :count
        end

        opts.separator ""
        opts.separator "Setup options:"

        opts.on("--init", "Initialize jammer in current project (creates config + git hook)") do
          @options[:action] = :init
        end

        opts.on("--uninstall", "Remove jammer from current project (removes config + git hook)") do
          @options[:action] = :uninstall
        end

        opts.separator ""
        opts.separator "Other options:"

        opts.on("-f", "--force", "Force overwrite of existing config and hooks") do
          @options[:force] = true
        end

        opts.on("-h", "--help", "Show this message") do
          @options[:action] = :help
        end

        opts.on("-v", "--version", "Show version") do
          @options[:action] = :version
        end
      end
    end
  end
end
