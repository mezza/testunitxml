=begin rdoc
This file mixes in XML assertions in the Test::Unit::TestCase
class.

See #xml_assertions.rb for information about the assertions
that are mixed in.
=end

require 'test/unit/xml/xml_assertions'

module Test
  module Unit
    
    # The module Test::Unit::XML is mixed in into the class
    # Test::Unit::TestCase
    class TestCase
      include Test::Unit::XML
    end
  end
end

