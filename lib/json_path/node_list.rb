require_relative 'path'

module JsonPath
  class NodeList
    attr_reader :nodes

    def initialize nodes
      @nodes = nodes
    end

    def query json_path
      json_path = Path.new json_path

      nodes
        .flat_map { json_path.apply _1 }
        .then { self.class.new _1 }
    end

    def values
      nodes.map(&:value)
    end

    def paths
      nodes.map(&:path)
    end
  end
end
