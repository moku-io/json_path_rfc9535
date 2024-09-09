require_relative 'parser'

module JsonPath
  class Path
    attr_reader :string
    attr_reader :proc

    def initialize json_path
      if json_path.is_a? Path
        @string = json_path.string
        @proc = json_path.proc
      else
        @string = -json_path
        @proc = Parser.compile json_path
      end
    end

    def apply node
      proc.call node
    end
  end
end
