# frozen_string_literal: true

module Jammer
  class SearchTool
    def initialize(keywords)
      @keywords = keywords
    end

    def build_command
      raise NotImplementedError, "Subclasses must implement #build_command"
    end

    def self.available?
      raise NotImplementedError, "Subclasses must implement .available?"
    end

    protected

    attr_reader :keywords
  end
end