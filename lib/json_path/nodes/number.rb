module JsonPath
  module Nodes
    class Number < Base
      attr_reader :value

      def initialize path, value
        super path
        @value = value
      end
    end
  end
end
