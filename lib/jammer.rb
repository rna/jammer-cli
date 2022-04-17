module Jammer
  class CLI
    def initialize
      @hello = '....Started Searching.....'
    end

    def search(query)
      puts @hello
      search_cmd = "grep -Rw $(pwd) -e #{query}"
      system(search_cmd)
    end
  end
end
