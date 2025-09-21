# frozen_string_literal: true

require 'open3'

module Jammer
  class Scanner
    attr_accessor :keyword

    def initialize(keyword = '#TODO')
      @keyword = keyword
    end

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
      regex_pattern = "\b#{@keyword}\b"

      command = if Jammer::Git.inside_work_tree?
                  # Search staged files (index) with an extended regex.
                  ['git', 'grep', '-nI', '-E', '--cached', '-e', regex_pattern]
                else
                  # Fallback for non-git directories: recursive, ignore binary, show line numbers, extended regex.
                  ['grep', '-RInE', regex_pattern, '.']
                end

      stdout, stderr, status = Open3.capture3(*command)

      if !status.success? && status.exitstatus != 1
        raise Jammer::Error, "Error executing search command. STDERR:\n#{stderr}"
      end

      stdout.lines.map(&:chomp)
    end
  end
end
