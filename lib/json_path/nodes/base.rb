require_relative '../path'
require_relative '../node_list'

module JsonPath
  module Nodes
    class Base
      attr_reader :path
      attr_reader :children

      def initialize path
        @path = path
        @children = []
      end

      def query json_path
        json_path = Path.new json_path

        json_path
          .apply(self)
          .then { NodeList.new _1 }
      end
    end
  end
end
