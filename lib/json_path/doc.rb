require 'json'
require_relative 'nodes'
require_relative 'path'
require_relative 'node_list'

module JsonPath
  class Doc
    attr_reader :root_node

    def initialize json_string, parse_json: json_string.is_a?(String)
      json = (parse_json ? JSON.parse(json_string) : json_string)
      @root_node = Nodes.parse '$', json
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
