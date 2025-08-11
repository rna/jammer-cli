#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'jammer/version'
require 'jammer/git'

module Jammer
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
      puts matches.join("\n")
    end

    def matches
      if Jammer::Git.inside_work_tree?
        # Search staged files (index) to align with pre-commit use case
        stdout, _stderr, status = Open3.capture3('git', 'grep', '-nI', '--cached', '-e', @keyword)
        return [] unless status.success?
        stdout.lines.map(&:chomp)
      else
        # Fallback for non-git directories: recursive, ignore binary, show line numbers
        stdout, _stderr, status = Open3.capture3('grep', '-RIn', @keyword, '.')
        return [] unless status.success?
        stdout.lines.map(&:chomp)
      end
    end
  end
end
