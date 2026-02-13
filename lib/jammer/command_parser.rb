# frozen_string_literal: true

require "optparse"

# Parses command-line arguments and returns structured options
module Jammer
  class CommandParser
    KEYWORD_OPTIONS = [
      { flags: ["-a", "--keyword KEYWORD"], desc: "Assigns a new search keyword", key: :keyword },
      { flags: ["-l", "--list"], desc: "List all occurrences of the keyword", action: :list },
      { flags: ["-c", "--count"], desc: "Count all occurrences of the keyword", action: :count }
    ].freeze

    SETUP_OPTIONS = [
      { flags: ["--init"], desc: "Initialize jammer in current project (creates config + git hook)", action: :init },
      { flags: ["--uninstall"], desc: "Remove jammer from current project (removes config + git hook)",
        action: :uninstall }
    ].freeze

    OTHER_OPTIONS = [
      { flags: ["-f", "--force"], desc: "Force overwrite of existing config and hooks", key: :force, value: true },
      { flags: ["-h", "--help"], desc: "Show this message", action: :help },
      { flags: ["-v", "--version"], desc: "Show version", action: :version }
    ].freeze

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
        add_option_group(opts, "Keyword checking options:", KEYWORD_OPTIONS)
        add_option_group(opts, "Setup options:", SETUP_OPTIONS)
        add_option_group(opts, "Other options:", OTHER_OPTIONS)
      end
    end

    private

    def add_option_group(opts, title, options)
      opts.separator ""
      opts.separator title
      options.each { |opt| add_option(opts, opt) }
    end

    def add_option(opts, opt)
      flags = opt[:flags]
      desc = opt[:desc]
      block = option_block(opt)
      opts.on(*flags, desc, &block)
    end

    def option_block(opt)
      if opt[:action]
        create_action_block(opt[:action])
      elsif opt[:key] && opt[:value]
        create_flag_block(opt[:key], opt[:value])
      elsif opt[:key]
        create_value_block(opt[:key])
      else
        ->(_) {}
      end
    end

    def create_action_block(action)
      ->(_) { @options[:action] = action }
    end

    def create_flag_block(key, value)
      ->(_) { @options[key] = value }
    end

    def create_value_block(key)
      ->(val) { @options[key] = val }
    end
  end
end
