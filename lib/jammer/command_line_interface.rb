# frozen_string_literal: true

require_relative '../jammer'
require_relative 'command_parser'
require_relative 'output_formatter'

module Jammer
  class CommandLineInterface
    def initialize(args = ARGV, config: nil)
      @args = args
      @config = config || Jammer::Config.new
      @scanner = Jammer::Scanner.new(@config.keywords, @config.exclude)
    end

    def run
      options = CommandParser.new(@args).parse
      execute_command(options)
    rescue Jammer::ConfigError => e
      warn OutputFormatter.error(e.message)
      exit 1
    rescue Jammer::Error => e
      warn OutputFormatter.error(e.message)
      exit 2
    end

    private

    def execute_command(options)
      case options[:action]
      when :help
        puts OutputFormatter.help(CommandParser.new.parser)
        exit 0
      when :version
        puts OutputFormatter.version
        exit 0
      when :list
        puts @scanner.occurrence_list
        exit 0
      when :count
        puts @scanner.occurrence_count
        exit 0
      when :init
        handle_init(options)
      when :uninstall
        handle_uninstall
      else
        handle_keyword_check(options)
      end
    end

    def handle_keyword_check(options)
      # Apply custom keyword if provided
      @scanner.keyword = options[:keyword] if options[:keyword]

      if @scanner.exists?
        puts OutputFormatter.keywords_found(@scanner.keywords)
        exit 1
      end

      # Run configured commands if any
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

    def handle_init(options)
      status = Jammer::HookManager.init_config(options)

      puts OutputFormatter.config_created if status[:config_created]
      puts OutputFormatter.config_already_exists unless status[:config_created]

      if status[:hook_created]
        puts OutputFormatter.hook_created
      elsif !Jammer::Git.inside_work_tree?
        puts OutputFormatter.not_in_git_repo
      else
        puts OutputFormatter.hook_already_exists
      end

      exit 0
    rescue Jammer::HookError => e
      warn "Error: #{e.message}"
      exit 1
    end

    def handle_uninstall
      Jammer::HookManager.uninstall_config
      puts OutputFormatter.config_removed
      puts OutputFormatter.hook_removed
      puts OutputFormatter.uninstall_complete
      exit 0
    rescue Jammer::HookError => e
      warn "Error: #{e.message}"
      exit 1
    end
  end
end
