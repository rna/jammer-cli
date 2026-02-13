# frozen_string_literal: true

require "open3"
require "shellwords"

module Jammer
  class CommandExecutor
    def initialize(commands = [])
      @commands = commands
      @results = []
    end

    def run_all
      @results = []
      @commands.each do |command|
        result = run_command(command)
        @results << result
      end
      @results
    end

    def all_passed?
      @results.all? { |r| r[:success] }
    end

    def failed_results
      @results.reject { |r| r[:success] }
    end

    def report
      failed = failed_results
      failed.empty? ? success_report : failure_report(failed)
    end

    private

    def run_command(command)
      argv = parse_command(command)
      stdout, stderr, status = execute_command(argv)
      success_result(command, status, stdout, stderr)
    rescue ArgumentError => e
      failed_result(command, "Invalid command syntax: #{e.message}")
    rescue Errno::ENOENT => e
      failed_result(command, "Command not found: #{e.message}")
    rescue StandardError => e
      failed_result(command, "Error executing command: #{e.message}")
    end

    def parse_command(command)
      raise ArgumentError, "Command must be a string" unless command.is_a?(String)

      argv = Shellwords.split(command)
      raise ArgumentError, "Command cannot be empty" if argv.empty?

      argv
    end

    def execute_command(argv)
      Open3.capture3(*argv)
    end

    def success_result(command, status, stdout, stderr)
      {
        command: command,
        success: status.success?,
        exit_code: status.exitstatus,
        output: sanitize_output(stdout, stderr)
      }
    end

    def sanitize_output(stdout, stderr)
      (stdout + stderr).force_encoding("UTF-8").gsub("\uFFFD", "")
    end

    def failed_result(command, message)
      {
        command: command,
        success: false,
        exit_code: 127,
        output: message
      }
    end

    def success_report
      "✓ All checks passed"
    end

    def failure_report(failed)
      lines = ["✗ Some checks failed:\n"]
      failed.each do |result|
        lines << "\nCommand: #{result[:command]}"
        lines << "Exit code: #{result[:exit_code]}"
        lines << "Output:\n#{result[:output]}" if result[:output].strip.length.positive?
      end
      lines.join("\n")
    end
  end
end
