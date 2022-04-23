module Jammer
  class CLI
    attr_accessor :keyword

    def initialize(keyword = 'TODO')
      @keyword = keyword
    end

    def exists?
      occurence_count.positive?
    end

    def occurence_count
      count_cmd = "grep -Rw $(pwd) -e #{@keyword} | wc -l"
      system(count_cmd)
    end

    def occurence_list
      search_cmd = "grep -Rw $(pwd) -e #{@keyword}"
      system(search_cmd)
    end
  end
end
