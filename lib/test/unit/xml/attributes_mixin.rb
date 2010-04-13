module REXML
  
  # The REXML::Attributes mix-in adds methods that are useful for
  # attribute collections, but not present in the standard
  # REXML::Attributes class
  class Attributes
    
    # The +get_attribute_ns+ method retrieves a method by its namespace
    # and name. Thus it is possible to reliably identify an attribute
    # even if an XML processor has changed the prefix.
    def get_attribute_ns(namespace, name)
      each_attribute() { |attribute|
        if name == attribute.name &&
           namespace == attribute.namespace()
          return attribute
        end
      }
      nil
    end
  end
end