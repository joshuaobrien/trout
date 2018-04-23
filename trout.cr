require "http/server"
require "trie"

module Trout
  class Base
    def initialize
      @routes = Trie(-> String).new
    end

    def swim
      puts "Swimming! 🐟"
      server = HTTP::Server.new(1989) do |context|
        base = context.request.method + ":" + context.request.path.to_s

        if @routes.exists?(base.to_s)
          context.response.content_type = "text/plain"

          if (node = @routes.search(base.to_s))
            if (data = node.data)
              context.response.print data.call
            end
          end
        else
          context.response.status_code = 404
          context.response.print "Not found"
        end
      end

      server.listen
    end

    def get(route, &block : -> String)
      @routes.add("GET:" + route.to_s, block)
    end

    def post(route, &block : -> String)
      @routes.add("POST:" + route.to_s, block)
    end
  end
end