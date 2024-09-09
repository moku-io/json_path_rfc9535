require_relative 'core'

module JsonPath
  module Parser
    class RawParser < Core
      rule(:jsonpath_query) { root_identifier >> many(segment).as(:segments) }
      root :jsonpath_query

      rule(:root_identifier) { str('$') }
      rule(:current_node_identifier) { str('@') }

      # Selectors
      rule(:selector) { name_selector | wildcard_selector | slice_selector | index_selector | filter_selector }
      rule(:name_selector) { string.as(:name) }
      rule(:wildcard_selector) { str('*').as(:wildcard) }
      rule(:index_selector) { int.as(:index) }
      rule :slice_selector do
        integer.maybe.as(:start) >>
          str(':') >> whitespace >>
          integer.maybe.as(:end) >>
          (str(':') >> whitespace >> integer.maybe.as(:step)).maybe
      end
      rule(:filter_selector) { str('?') >> whitespace >> logical_expr.as(:filter) }

      # Logical expressions
      rule(:logical_expr) { logical_or_expr }
      rule(:logical_or_expr) { some_separated(logical_and_expr.as(:logical_or_operands), symbol('||')) }
      rule(:logical_and_expr) { some_separated(basic_expr.as(:logical_and_operands), symbol('&&')) }
      rule(:basic_expr) { paren_expr | comparison_expr | test_expr }
      rule(:logical_not_op) { symbol('!') }
      rule :paren_expr do
        logical_not_op.maybe.as(:negation) >> symbol('(') >> logical_expr.as(:parenthesized_expr) >> symbol(')')
      end
      rule(:test_expr) { logical_not_op.maybe.as(:negation) >> (filter_query | function_expr).as(:test_expr) }
      rule(:filter_query) { (rel_query | jsonpath_query).as(:filter_query) }
      rule(:rel_query) { current_node_identifier >> many(segment).as(:relative_segments) }
      rule :comparison_expr do
        comparable.as(:comparable1) >> comparison_op.as(:comparison_op) >> comparable.as(:comparable2)
      end
      rule(:comparison_op) { symbol('==') | symbol('!=') | symbol('<=') | symbol('>=') | symbol('<') | symbol('>') }
      rule(:comparable) { literal | singular_query | function_expr }
      rule :literal do
        number.as(:literal_number) |
          string.as(:literal_string) |
          symbol('true').as(:literal_true) |
          symbol('false').as(:literal_false) |
          symbol('null').as(:literal_null)
      end
      rule(:singular_query) { (rel_singular_query | abs_singular_query).as(:singular_query) }
      rule :rel_singular_query do
        current_node_identifier >> many(singular_query_segment).as(:relative_segments)
      end
      rule :abs_singular_query do
        root_identifier >> many(singular_query_segment).as(:segments)
      end
      rule(:singular_query_segment) { name_segment | index_segment }
      rule(:name_segment) { ((str('[') >> name_selector >> str(']')) | (str('.') >> member_name_shorthand)).as(:child) }
      rule(:index_segment) { (str('[') >> index_selector >> str(']')).as(:child) }
      rule(:function_expr) { none }

      # Segments
      rule(:segment) { child_segment | descendant_segment }
      rule :child_segment do
        (bracketed_selection | (str('.') >> (wildcard_selector | member_name_shorthand))).as :child
      end
      rule(:bracketed_selection) { str('[') >> some_separated(selector, symbol(',')).as(:bracketed) >> str(']') }
      rule(:member_name_shorthand) { (match('[a-zA-Z_]') >> many(match('[a-zA-Z_0-9]'))).as(:name) }
      rule :descendant_segment do
        (str('..') >> (bracketed_selection | wildcard_selector | member_name_shorthand)).as :descendant
      end
    end
  end
end
