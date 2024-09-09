require 'parslet'
require_relative '../multiple_values_returned_by_singular_query'

module JsonPath
  module Parser
    class Transformer < Parslet::Transform
      EMPTY = ::Object.new

      rule segments: sequence(:segments) do
        proc do |root|
          segments.reduce [root] do |nodes, segment|
            segment.call nodes, root
          end
        end
      end

      rule(child: simple(:segment)) { segment }

      rule descendant: simple(:segment) do
        proc do |nodes, root|
          recursive_application = proc do |node|
            segment.call([node], root) + node.children.flat_map(&recursive_application)
          end

          nodes.flat_map(&recursive_application)
        end
      end

      rule(bracketed: simple(:segment)) { segment }

      rule bracketed: sequence(:segments) do
        proc do |nodes, root|
          segments.flat_map { _1.call nodes, root }
        end
      end

      rule name: simple(:name) do
        proc do |nodes|
          nodes.filter_map do |node|
            node.hash[name.to_s] if node.is_a? Nodes::Object
          end
        end
      end

      rule wildcard: simple(:x) do
        proc do |nodes|
          nodes.flat_map(&:children)
        end
      end

      rule index: simple(:index) do
        proc do |nodes|
          nodes.filter_map do |node|
            node.elements[Integer(index)] if node.is_a? Nodes::Array
          end
        end
      end

      rule start: simple(:slice_start),
           end: simple(:slice_end),
           step: simple(:slice_step) do
             proc do |nodes|
               slice_step = Integer(self.slice_step) || 1

               next [] if slice_step.zero?

               nodes.flat_map do |node|
                 next [] unless node.is_a? Nodes::Array

                 len = node.elements.size

                 slice_start, slice_end = if slice_step.positive?
                                            [
                                              Integer(self.slice_start) || 0,
                                              Integer(self.slice_end) || len
                                            ]
                                          else
                                            [
                                              Integer(self.slice_start) || (len - 1),
                                              Integer(self.slice_end) || (-len - 1)
                                            ]
                                          end

                 slice_start += len if slice_start.negative?
                 slice_end += len if slice_end.negative?

                 lower, upper = if slice_step.positive?
                                  [
                                    [[slice_start, 0].max, len].min,
                                    [[slice_end, 0].max, len].min
                                  ]
                                else
                                  [
                                    [[slice_end, -1].max, len - 1].min,
                                    [[slice_start, -1].max, len - 1].min
                                  ]
                                end

                 # This is horrible, but it's also the easiest way to implement the semantics from the RFC
                 [].tap do |result|
                   if slice_step.positive?
                     i = lower
                     while i < upper
                       result << node.elements[i] if (0...node.elements.size).include? i
                       i += slice_step
                     end
                   else
                     i = upper
                     while i > lower
                       result << node.elements[i] if (0...node.elements.size).include? i
                       i += step
                     end
                   end
                 end
               end
             end
           end

      rule filter: simple(:filter) do
        proc do |nodes, root|
          nodes.flat_map do |node|
            case node
            when Nodes::Array
              node.elements
            when Nodes::Object
              node.hash.values
            else
              []
            end
              .filter { filter.call root, _1 }
          end
        end
      end

      rule(logical_or_operands: simple(:operand)) { operand }
      rule(logical_and_operands: simple(:operand)) { operand }

      rule logical_or_operands: sequence(:operands) do
        proc do |*args, **kwargs, &block|
          operands.any? { _1.call(*args, **kwargs, &block) }
        end
      end

      rule logical_and_operands: sequence(:operands) do
        proc do |*args, **kwargs, &block|
          operands.all? { _1.call(*args, **kwargs, &block) }
        end
      end

      rule negation: simple(:negation),
           test_expr: simple(:expr) do
             expr >> proc { negation ? !_1 : _1 }
           end

      rule filter_query: simple(:query) do
        query >> proc { !_1.empty? }
      end

      rule negation: simple(:negation),
           parenthesized_expr: simple(:expr) do
             expr >> proc { negation ? !_1 : _1 }
           end

      rule comparable1: simple(:comp1),
           comparison_op: simple(:op),
           comparable2: simple(:comp2) do
             proc do |*args, **kwargs, &block|
               [comp1.call(*args, **kwargs, &block), comp2.call(*args, **kwargs, &block)]
             end >> proc { _1.public_send op.to_sym, _2 }
           end

      rule relative_segments: sequence(:segments) do
        proc do |root, current_node|
          segments.reduce [current_node] do |nodes, segment|
            segment.call nodes, root
          end
        end
      end

      rule literal_number: simple(:num) do
        proc { eval num }
      end

      rule literal_string: simple(:string) do
        proc { string.to_s }
      end

      rule literal_true: simple(:x) do
        proc { true }
      end

      rule literal_false: simple(:x) do
        proc { false }
      end

      rule literal_null: simple(:x) do
        proc {}
      end

      rule string: simple(:string) do
        string
      end

      rule singular_query: simple(:query) do
        proc do |*args, **kwargs, &block|
          nodes = query.call(*args, **kwargs, &block)

          if nodes.empty?
            EMPTY
          elsif nodes.size == 1
            nodes.first.value
          else
            raise MultipleValuesReturnedBySingularQuery, 'Singular query must return single value'
          end
        end
      end
    end
  end
end
