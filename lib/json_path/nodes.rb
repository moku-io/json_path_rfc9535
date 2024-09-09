require_relative 'nodes/base'
Dir["#{__dir__}/nodes/**"].each { |filename| require_relative filename }

module JsonPath
  module Nodes
    def self.parse path, value
      case value
      when nil
        Null.new path
      when true
        True.new path
      when false
        False.new path
      when ::String
        String.new path, value
      when Numeric
        Number.new path, value
      when ::Array
        Array.new path, value
      when Hash
        Object.new path, value
      else
        raise UnrecognizedNode, "JSON value expected, #{value.class} found"
      end
    end
  end
end
