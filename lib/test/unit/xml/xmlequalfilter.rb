#! /usr/bin/ruby

module Test
  module Unit
    module XML
      
      # This filter class accepts any node except text nodes
      # that contain non-significant whitespace
      class XmlEqualFilter
        def accept(node)
          case
          when node.kind_of?(REXML::Text)
            is_significant?(node.value)
          when node.kind_of?(REXML::Entity)
            false
          when node.kind_of?(REXML::NotationDecl)
            false
          else
            true
          end
        end
        
        private
        
        def is_significant?(string)
          string =~ /^\s*$/ ? false : true
        end
      end
    end
  end
end