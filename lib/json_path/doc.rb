require 'json'
require_relative 'nodes'
require_relative 'path'
require_relative 'node_list'

module JsonPath
  class Doc
    attr_reader :root_node

    def initialize json_string
      @root_node = Nodes.parse '$', JSON.parse(json_string)
    end

    def query json_path
      json_path = Path.new json_path

      json_path
        .apply(root_node)
        .then { NodeList.new _1 }
    end

    def value
      root_node.value
    end
  end
end
