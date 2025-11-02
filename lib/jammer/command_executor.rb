# frozen_string_literal: true

require "open3"

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
      lines = []
      failed = failed_results

      if failed.empty?
        lines << "✓ All checks passed"
      else
        lines << "✗ Some checks failed:\n"
        failed.each do |result|
          lines << "\nCommand: #{result[:command]}"
          lines << "Exit code: #{result[:exit_code]}"
          lines << "Output:\n#{result[:output]}" if result[:output].strip.length.positive?
        end
      end

      lines.join("\n")
    end

    private

    def run_command(command)
      stdout, stderr, status = Open3.capture3(command)

      {
        command: command,
        success: status.success?,
        exit_code: status.exitstatus,
        output: (stdout + stderr).force_encoding("UTF-8").gsub("\uFFFD", "")
      }
    end
  end
end
