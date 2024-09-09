module JsonPath
  module Nodes
    class String < Base
      attr_reader :value

      def initialize path, value
        super path
        @value = value
      end
    end
  end
end
