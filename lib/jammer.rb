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
      count_cmd = "grep -Rw $(pwd) -e #{@keyword} | wc -l"
      system(count_cmd)
    end

    def occurrence_list
      search_cmd = "grep -Rw $(pwd) -e #{@keyword}"
      system(search_cmd)
    end
  end
end
