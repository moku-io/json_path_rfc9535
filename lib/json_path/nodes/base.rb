module JsonPath
  module Nodes
    class Base
      attr_reader :path
      attr_reader :children

      def initialize path
        @path = path
        @children = []
      end
    end
  end
end
