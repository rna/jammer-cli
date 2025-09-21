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
      command = if Jammer::Git.inside_work_tree?
                  ['git', 'grep', '-nI', '-w', '--cached', '-e', @keyword]
                else
                  ['grep', '-RInw', @keyword, '.']
                end

      stdout, stderr, status = Open3.capture3(*command)

      if !status.success? && status.exitstatus != 1
        raise Jammer::Error, "Error executing search command. STDERR:\n#{stderr}"
      end

      stdout.lines.map(&:chomp)
    end
  end
end
