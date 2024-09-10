require 'json'
require_relative 'nodes'

module JsonPath
  class Doc
    attr_reader :root_node

    def initialize json_string, parse_json: json_string.is_a?(String)
      json = (parse_json ? JSON.parse(json_string) : json_string)
      @root_node = Nodes.parse '$', json
    end

    def query(...)
      root_node.query(...)
    end

    def value
      root_node.value
    end
  end
end
