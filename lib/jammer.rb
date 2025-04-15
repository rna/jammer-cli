module Jammer
  class CLI
    attr_accessor :keyword
    #TODO
    def initialize(keyword = '#TODO')
      @keyword = keyword
    end

    def exists?
      occurrence_count.positive?
    end

    def occurrence_count
      count_cmd = "grep -Rw . -e '#{@keyword}' | wc -l"
      `#{count_cmd}`.to_i
    end

    def occurrence_list
      search_cmd = "grep -Rw . -e '#{@keyword}'"
      system(search_cmd)
    end
  end
end
