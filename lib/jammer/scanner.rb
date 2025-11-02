# frozen_string_literal: true

require 'open3'

module Jammer
  class Scanner
    attr_reader :keywords, :exclude_patterns

    def initialize(keywords, exclude_patterns = [])
      @keywords = Array(keywords)
      validate_keywords
      @exclude_patterns = exclude_patterns
    end

    def keywords=(value)
      @keywords = Array(value)
      validate_keywords
    end

    def keyword
      @keywords.first
    end

    def keyword=(value)
      raise Jammer::ScannerError, 'Keyword cannot be empty' if value.to_s.strip.empty?
      raise Jammer::ScannerError, 'Keyword is too long (max 100 chars)' if value.length > 100

      @keywords = [value]
    end

    private

    def validate_keywords
      @keywords.each do |kw|
        raise Jammer::ScannerError, 'Keyword cannot be empty' if kw.to_s.strip.empty?
        raise Jammer::ScannerError, 'Keyword is too long (max 100 chars)' if kw.length > 100
      end
    end

    public

    def exists?
      occurrence_count.positive?
    end

    def occurrence_count
      matches.length
    end

    def occurrence_list
      matches.join("\n")
    end

    def matches
      command = build_command
      stdout, stderr, status = Open3.capture3(*command)

      if !status.success? && status.exitstatus != 1
        raise Jammer::ScannerError, "Error executing search command. STDERR:\n#{stderr}"
      end

      results = stdout.lines.map(&:chomp)
      filter_excluded_patterns(results)
    end

    private

    def build_command
      if Jammer::Git.inside_work_tree?
        git_command
      else
        grep_command
      end
    end

    def git_command
      cmd = ['git', 'grep', '-nI', '-w', '--cached']
      @keywords.each { |kw| cmd << '-e' << kw }
      cmd
    end

    def grep_command
      cmd = ['grep', '-RIn', '-w']
      @keywords.each { |kw| cmd << '-e' << kw }
      cmd << '.'
      cmd
    end

    def filter_excluded_patterns(results)
      return results if @exclude_patterns.empty?

      results.reject do |line|
        @exclude_patterns.any? { |pattern| line.include?(pattern) }
      end
    end
  end
end
