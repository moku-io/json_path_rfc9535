module JsonPath
  class NodeList
    attr_reader :nodes

    def initialize nodes
      @nodes = nodes
    end

    def query(...)
      nodes
        .flat_map { _1.query(...) }
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
