# frozen_string_literal: true

require 'open3'
require_relative 'search_tool'
require_relative 'git_grep_tool'
require_relative 'grep_tool'

module Jammer
  class Scanner
    attr_reader :keywords, :exclude_patterns

    def initialize(keywords, exclude_patterns = [])
      @keywords = Array(keywords)
      validate_keywords
      @exclude_patterns = exclude_patterns
      @search_tool = select_search_tool
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
      command = @search_tool.build_command
      stdout, stderr, status = Open3.capture3(*command)

      if !status.success? && status.exitstatus != 1
        raise Jammer::ScannerError, "Error executing search command. STDERR:\n#{stderr}"
      end

      results = stdout.lines.map(&:chomp)
      filter_excluded_patterns(results)
    end

    private

    def select_search_tool
      if GitGrepTool.available?
        GitGrepTool.new(@keywords)
      else
        GrepTool.new(@keywords)
      end
    end

    def filter_excluded_patterns(results)
      return results if @exclude_patterns.empty?

      results.reject do |line|
        @exclude_patterns.any? { |pattern| line.include?(pattern) }
      end
    end
  end
end
