#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'jammer/version'
require 'jammer/git'

module Jammer
  class Error < StandardError; end

  class CLI
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
      command = if Jammer::Git.inside_work_tree?
                  # Search staged files (index) to align with pre-commit use case
                  ['git', 'grep', '-nI', '--cached', '-e', @keyword]
                else
                  # Fallback for non-git directories: recursive, ignore binary, show line numbers
                  ['grep', '-RIn', @keyword, '.']
                end

      stdout, stderr, status = Open3.capture3(*command)

      if !status.success? && status.exitstatus != 1
        raise Jammer::Error, "Error executing search command. STDERR:\n#{stderr}"
      end

      stdout.lines.map(&:chomp)
    end
  end
end
