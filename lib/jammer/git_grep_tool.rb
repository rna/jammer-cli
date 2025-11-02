# frozen_string_literal: true

require_relative "search_tool"
require_relative "git"

module Jammer
  class GitGrepTool < SearchTool
    def build_command
      cmd = ["git", "grep", "-nI", "-w", "--cached"]
      keywords.each { |kw| cmd << "-e" << kw }
      cmd
    end

    def self.available?
      Git.inside_work_tree?
    end
  end
end
