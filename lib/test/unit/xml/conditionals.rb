
module Test
  module Unit
    module XML
      
      # This singleton class compares all types of REXML nodes.
      class Conditionals
        
        private_class_method :new
        @@conditionals = nil
        
        # The +create+ method is used to create a singleton instance
        # of the Conditionals class.
        def Conditionals.create
          @@conditionals = new unless @@conditionals
          @@conditionals
        end
        
        # The method compares two REXML nodes representing an XML document,
        # or part of a document. If the nodes are equal, the method returns
        # +true+. If the nodes are not equal, the method returns +false+.
        # If the nodes have child nodes, for example if the nodes are
        # +Element+ nodes with content, they will _not_ be recursively compared.
        def compare_xml_nodes(expected_node, actual_node)
          return false unless actual_node.instance_of? expected_node.class
          case actual_node
          when REXML::Document
            # TODO: Implement Document comparison
            true
          when REXML::DocType
            compare_doctypes(expected_node, actual_node)
          when REXML::Element
            compare_elements(expected_node, actual_node)
          when REXML::CData
            compare_texts(expected_node, actual_node)
          when REXML::Text
            compare_texts(expected_node, actual_node)
          when REXML::Comment
            compare_comments(expected_node, actual_node)
          when REXML::Instruction
            compare_pi(expected_node, actual_node)
          when REXML::XMLDecl
            compare_xml_declaration(expected_node, actual_node)
          #when REXML::Entity
          #  compare_xml_entities(expected_node, actual_node)
          else
            puts "Unknown node type #{actual_node.class}"
            false
          end
        end
        
        private
        
        def compare_doctypes(expected_node, actual_node)
          return compare_system_id(expected_node.system, actual_node.system) &&
            expected_node.public == actual_node.public &&
            compare_xml_internal_dtd_subset(expected_node, actual_node)
        end
        
        def compare_system_id(expected_id, actual_id)
          is_expected_urn = expected_id =~ /^urn:/i
          is_actual_urn = actual_id =~ /^urn:/i
          if is_expected_urn || is_actual_urn
            expected_id == actual_id
          else
            true
          end
        end
        
        def compare_elements(expected_node, actual_node)
          return  expected_node.name == actual_node.name &&
                  expected_node.namespace() == actual_node.namespace() &&
                  compare_attributes(expected_node.attributes, actual_node.attributes)
        end
              
        def compare_attributes(expected_attributes, actual_attributes)
          return false unless attribute_count(expected_attributes) == attribute_count(actual_attributes)
          expected_attributes.each_attribute do |expected_attribute|
            expected_prefix = expected_attribute.prefix()
            unless expected_prefix == 'xmlns' then
              expected_name = expected_attribute.name
              expected_namespace = expected_attribute.namespace
              actual_attribute = actual_attributes.get_attribute_ns(expected_namespace, expected_name)
              return false unless actual_attribute
              return false if expected_attribute.value() != actual_attribute.value()
            end
          end
          true
        end
        
        def attribute_count(attributes)
          # Do not count namespace declarations
          attributes.size - attributes.prefixes.size
        end
            
        def compare_texts(expected_node, actual_node)
          expected_node.value.eql?(actual_node.value)
        end  
        
        def compare_comments(expected_node, actual_node)
          expected_node == actual_node
        end
        
        def compare_pi(expected_pi, actual_pi)
          return expected_pi.target == actual_pi.target &&
                expected_pi.content == actual_pi.content
        end
        
        def compare_xml_declaration(expected_decl, actual_decl)
          return expected_decl == actual_decl
        end
        
        def compare_xml_internal_dtd_subset(expected_node, actual_node)
          expected_subset = expected_node.children()
          actual_subset = actual_node.children()
          return false unless expected_subset.length == actual_subset.length
          expected_subset.inject(true) { |memo, expected_decl|
            case expected_decl
            when REXML::Entity
              memo &&
              expected_decl.value == actual_node.entities[expected_decl.name].value &&
              expected_decl.ndata == actual_node.entities[expected_decl.name].ndata
            when REXML::NotationDecl
              actual_notation_decl = actual_node.notation(expected_decl.name)
              memo &&
              actual_notation_decl != nil &&
              expected_decl.name == actual_notation_decl.name &&
              expected_decl.public == actual_notation_decl.public &&
              expected_decl.system == actual_notation_decl.system
            when REXML::Comment
              true
            else
              raise "Unexpected node type in internal DTD subset of expected document: " + expected_decl.inspect
            end
          }
        end
        
      end
    end
  end
end