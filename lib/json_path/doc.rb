require 'json'
require_relative 'nodes'

module JsonPath
  class Doc
    attr_reader :root_node

    def initialize json_string
      @root_node = Nodes.parse '$', JSON.parse(json_string)
    end
  end
end
