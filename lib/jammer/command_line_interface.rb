# frozen_string_literal: true

require_relative "../jammer"
require_relative "command_parser"
require_relative "output_formatter"

module Jammer
  # rubocop:disable Metrics/ClassLength
  class CommandLineInterface
    @action_handlers = {}
    @default_action_handler = nil

    def self.register_action(name, method_name:, takes_options: false)
      @action_handlers[name] = { method_name: method_name, takes_options: takes_options }
    end

    def self.register_default_action(method_name:, takes_options: false)
      @default_action_handler = { method_name: method_name, takes_options: takes_options }
    end

    def self.handler_for_action(action)
      @action_handlers[action] || @default_action_handler
    end

    # Register action handlers
    register_action :help, method_name: :handle_help, takes_options: false
    register_action :version, method_name: :handle_version, takes_options: false
    register_action :list, method_name: :handle_list, takes_options: false
    register_action :count, method_name: :handle_count, takes_options: false
    register_action :init, method_name: :handle_init, takes_options: true
    register_action :uninstall, method_name: :handle_uninstall, takes_options: false
    register_default_action method_name: :handle_keyword_check, takes_options: true

    def initialize(args = ARGV, config: nil)
      @args = args
      @config = config
      @scanner = nil
    end

    def run
      initialize_runtime
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

    def initialize_runtime
      @config ||= Jammer::Config.new
      @scanner ||= Jammer::Scanner.new(@config.keywords, @config.exclude)
    end

    def execute_command(options)
      handler = action_handler(options[:action])
      handler.call(options)
    end

    def action_handler(action)
      handler_config = self.class.handler_for_action(action)
      method_name = handler_config[:method_name]
      takes_options = handler_config[:takes_options]

      if takes_options
        ->(o) { send(method_name, o) }
      else
        ->(_) { send(method_name) }
      end
    end

    def handle_help
      exit_with OutputFormatter.help(CommandParser.new.parser)
    end

    def handle_version
      exit_with OutputFormatter.version
    end

    def handle_list
      exit_with @scanner.occurrence_list
    end

    def handle_count
      exit_with @scanner.occurrence_count
    end

    def exit_with(output, code = 0)
      puts output
      exit code
    end

    def handle_keyword_check(options)
      @scanner.keyword = options[:keyword] if options[:keyword]
      return exit 1 if keyword_found?

      run_commands_if_configured
      exit 0
    end

    def keyword_found?
      return false unless @scanner.exists?

      puts OutputFormatter.keywords_found(@scanner.keywords)
      true
    end

    def run_commands_if_configured
      commands = @config.commands
      return unless commands.any?

      executor = Jammer::CommandExecutor.new(commands)
      executor.run_all

      return if executor.all_passed?

      puts executor.report
      exit 1
    end

    def handle_init(options)
      status = Jammer::HookManager.init_config(options)
      puts OutputFormatter.init_status(status, in_git_repo: Jammer::Git.inside_work_tree?)
      exit 0
    rescue Jammer::HookError => e
      warn "Error: #{e.message}"
      exit 1
    end

    def handle_uninstall
      status = Jammer::HookManager.uninstall_config
      puts OutputFormatter.config_removed if status[:config_removed]
      puts OutputFormatter.hook_removed if status[:hook_removed]
      puts OutputFormatter.uninstall_complete
      exit 0
    rescue Jammer::HookError => e
      warn "Error: #{e.message}"
      exit 1
    end
  end
  # rubocop:enable Metrics/ClassLength
end
