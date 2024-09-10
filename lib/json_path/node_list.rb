module JsonPath
  class NodeList
    include Enumerable

    attr_reader :nodes

    def initialize nodes
      @nodes = nodes
    end

    def query(...)
      nodes
        .flat_map { _1.query(...) }
        .then { self.class.new _1 }
    end

    def each(&block)
      nodes.each(&block)
    end

    def values
      map(&:value)
    end

    def paths
      map(&:path)
    end
  end
end
