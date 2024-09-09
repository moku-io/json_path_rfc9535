require_relative 'parser/raw_parser'
require_relative 'parser/transformer'

module JsonPath
  module Parser
    RAW_PARSER = RawParser.new
    TRANSFORMER = Transformer.new

    def self.compile json_path_string
      reporter = Parslet::ErrorReporter::Contextual.new
      TRANSFORMER.apply RAW_PARSER.parse(json_path_string, reporter: reporter)
    rescue Parslet::ParseFailed
      reporter.deepest_cause.raise
    end
  end
end
