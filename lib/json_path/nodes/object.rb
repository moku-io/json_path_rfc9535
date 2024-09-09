module JsonPath
  module Nodes
    class Object < Base
      attr_reader :hash

      def initialize path, hash
        super path
        @hash = hash.to_h do |key, value|
          [key, Nodes.parse("#{path}['#{key}']", value)]
        end
        @children = self.hash.values
      end

      def value
        hash.transform_values(&:value)
      end
    end
  end
end
