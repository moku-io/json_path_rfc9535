module JsonPath
  module Nodes
    class Array < Base
      alias elements children

      def initialize path, values
        super path
        @children = values
                      .map.with_index do |value, i|
                        Nodes.parse "#{path}[#{i}]", value
                      end
      end

      def value
        elements.map(&:value)
      end
    end
  end
end
