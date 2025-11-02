# frozen_string_literal: true

require_relative "search_tool"

module Jammer
  class GrepTool < SearchTool
    def build_command
      cmd = ["grep", "-RIn", "-w"]
      keywords.each { |kw| cmd << "-e" << kw }
      cmd << "."
      cmd
    end

    def self.available?
      true # grep is almost always available
    end
  end
end
