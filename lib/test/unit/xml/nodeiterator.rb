#! /usr/bin/ruby
# encoding: utf-8

module Test
  module Unit
    module XML
      class NodeIterator
        
        class NullNodeFilter
          def accept(node)
            true
          end
        end
        
        # This class method takes a node as an argument and locates the
        # next node. The first argument is a node. The second argument
        # is an optional node filter.
        def NodeIterator.find_next_node(node, node_filter = NullNodeFilter.new)
          next_node = nil
          if NodeIterator.has_children?(node) then
            next_node = node[0] # The index should be 1 according to the REXML docs
          elsif node.next_sibling_node
            next_node = node.next_sibling_node
          elsif NodeIterator.has_parent_with_sibling?(node)
            next_node = node.parent.next_sibling_node
          end
          return next_node if node_filter.accept(next_node) || next_node == nil
          find_next_node(next_node, node_filter)
        end
        
        
        def initialize(node, node_filter = NullNodeFilter.new)
          @node_filter = node_filter
          @next_node = node
        end
        
        def has_next()
          @next_node ? true : false
        end
        
        def next
          node = @next_node
          @next_node = NodeIterator.find_next_node(node, @node_filter)
          node
        end
        
        
        
        
        private
        
        def NodeIterator.has_children?(node)
         node.respond_to?(:[]) && node.respond_to?(:size) && node.size > 0
        end
        
        def NodeIterator.has_parent_with_sibling?(node)
          node.parent && node.parent.next_sibling_node
        end
      end
    end
  end
end