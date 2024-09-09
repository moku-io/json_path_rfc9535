require 'parslet'

module JsonPath
  module Parser
    class Core < Parslet::Parser
      # Never matches
      rule(:none) { match('').absent? }
      # Always matches, but doesn't consume any input
      rule(:empty) { str('') }

      def many parser
        parser.repeat
      end

      def some parser
        parser.repeat 1
      end

      rule(:digit) { match('[0-9]') }
      rule(:digits) { digit.repeat(1) }
      rule(:double_quoted_string_char) { match('[^\\\\"]') | str('\\\\') | str('\\"') }
      rule(:single_quoted_string_char) { match("[^\\\\']") | str('\\\\') | str("\\'") }
      rule(:whitespace) { match('[\s]').repeat }

      rule(:int) { str('-').maybe >> digits }
      rule :num do
        int >>
          (str('.') >> digits).maybe >>
          (str('e') >> (str('-') | str('+')).maybe >> digits).maybe
      end

      rule(:double_quoted_string) { token(str('"') >> many(double_quoted_string_char).as(:string) >> str('"')) }
      rule(:single_quoted_string) { token(str("'") >> many(single_quoted_string_char).as(:string) >> str("'")) }

      rule(:true_constant) { symbol('true') }
      rule(:false_constant) { symbol('false') }
      rule(:integer) { token(int) }
      rule(:number) { token(num) }
      rule(:string) { double_quoted_string | single_quoted_string }

      def symbol string
        token(str(string))
      end

      def many_separated parser, separator_parser
        some_separated(parser, separator_parser).maybe
      end

      def some_separated parser, separator_parser
        parser >> many(separator_parser >> parser)
      end

      def any_unless parser
        parser.absent? >> any
      end

      def any_until parser, prefix_name=nil
        prefix_parser = some(any_unless(parser))
        prefix_parser = prefix_parser.as(prefix_name) if prefix_name.present?
        prefix_parser
      end

    protected

      # Takes a block which needs to be a predicate over strings
      def predicate parser
        parser.capture(:input) >> dynamic { |_, c| yield(c.captures[:input].to_s) ? empty : none }
      end

      def token parser
        whitespace.maybe >> parser >> whitespace
      end
    end
  end
end
