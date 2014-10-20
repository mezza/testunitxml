#! /usr/bin/env ruby
# encoding: utf-8

require 'rexml/document'
require 'test/unit/xml/attributes_mixin' # Must be required after rexml/document
require 'test/unit/xml/doctype_mixin' # Must be required after rexml/document
require 'test/unit/xml/notationdecl_mixin' # Must be required after rexml/document
require 'test/unit'
require 'test/unit/xml/conditionals'
require 'test/unit/xml/xmlequalfilter'
require 'test/unit/xml/nodeiterator'

=begin rdoc
This module contains assertions about XML documents. The assertions are
meant to be mixed in to test classes such as Test::Unit::TestCase.
=end
module Test
  module Unit
    module XML
      
      # This method checks whether two well-formed XML documents are equal.
      # Two XML documents are considered equal if:
      # * They contain the same type of nodes, in the same order,
      #   except for text nodes that are empty, or contain only
      #   whitespace. Such text nodes are ignored.
      # * The corresponding nodes in the two documents are equal.
      #
      # Nodes are tested for equality as follows:
      # XML Declarations::
      #      XML declarations are equal if they have the same version,
      #      encoding, and stand-alone pseudo-attributes.
      # Doctype::
      #      Doctypes are equal if they fulfill all of the following conditions:
      #      * They have the same public identifier, or neither has a public identifier
      #      * If one of the doctypes has a system identifier that is a URN,
      #        the other doctype must have a system identifier that is the same URN.
      #        System identifiers that are URLs are ignored for comparison purposes.
      #        The reason is that the same DTD is very often stored in many different
      #        locations (for example different directories on different computers).
      #        Therefore the physical location of the DTD does not say anything useful
      #        about whether two documents are equal.
      #      * An entity declaration present in one of the doctype declarations
      #        must also be present in the other.
      #      * A notation declaration present in one of the doctype declarations
      #        must also be present in the other.
      # Internal General Entity Declaration::
      #      Internal General entity declarations are equal if they have the same name,
      #      and the same value.
      # External General Entity Declaration::
      #      External general entity declarations are equal if they have the same name,
      #      and if the identifiers are of the same type (PUBLIC or SYSTEM) and have
      #      the same value. Note that if the identifiers are URLs, a comparison may
      #      fail even though both URLS point to the same resource, for example if one
      #      URL is relative and the other is absolute.
      # Notation Declaration::
      #      Notation declarations are equal if they have the same name,
      #      and if the identifiers are of the same type (PUBLIC or SYSTEM) and have
      #      the same value. 
      # Elements::
      #      Elements are considered equal if they have the same generic
      #      identifier (tag name), belong to the same namespace, and have the same
      #      attributes. Note that the namespace _prefixes_ of two elements may be different
      #      as long as they belong to the same namespace.
      # Attributes::
      #      Attributes are equal if they belong to the same namespace,
      #      have the same name, and the same value.
      # Namespace Declarations::
      #      Namespace _declarations_ (attributes named <tt>xmlns:<em>prefix</em></tt>)
      #      are ignored. There are several reasons for this:
      #      - As long as two elements or attributes
      #        belong to the same namespace, it does not matter what prefixes
      #        are used. XML processors may also change prefixes in unpredictable
      #        ways without this being an error.
      #      - XML processors may _move_ namespace
      #        declarations from one element to another (usually an ancestor,
      #        sometimes a descendant) without this being an error, or under
      #        control by the programmer.
      #      - XML processors may _add_ extraneous namespace declarations
      #        in a manner that is hard for programmers to control.
      # Processing Instructions::
      #      Processing instructions are considered equal if the string
      #      values of their targets and contents are equal.
      # Text::
      #      Text nodes are equal if their values are equal. However, empty
      #      text nodes, and text nodes containing only whitespace are ignored.
      # CDATA::
      #      CDATA nodes are equal if their text content is equal. Whitespace
      #      is _not_ normalized.
      # Comments::
      #      Comments are equal if they have the same content.
      #
      # The +expected_doc+ and +actual_doc+ arguments to this method may be of
      # the following types:
      # * A +REXML+ node, usually a <tt>REXML::Document</tt> or <tt>REXML::Element</tt>
      # * A +File+ or other +IO+ object representing an XML document
      # * A string containing an XML document
      def assert_xml_equal(expected_doc, actual_doc, message = nil)
        expected_doc = parse_xml(expected_doc)
        actual_doc = parse_xml(actual_doc)
        _wrap_assertion do
          full_message = build_message(message, <<EOT, actual_doc.inspect, expected_doc.inspect)

<?> expected to be equal to
<?> but was not.
EOT
          assert_block(full_message){are_equal?(expected_doc, actual_doc)}
        end
      end
      
      
      # This method compares two XML documents and returns +true+ if they are
      # _not_ equal, +false+ otherwise. This is the inverse of assert_xml_equal.
      def assert_xml_not_equal(expected_doc, actual_doc, message = nil)
        expected_doc = parse_xml(expected_doc)
        actual_doc = parse_xml(actual_doc)
        _wrap_assertion do
          full_message = build_message(message, <<EOT, actual_doc.inspect, expected_doc.inspect)

<?> expected not to be equal to
<?> but was equal.
EOT
          assert_block(full_message){ ! are_equal?(expected_doc, actual_doc)}
        end
      end
      
      
      private
      
      def parse_xml(xml)
        case xml
        when IO
          REXML::Document.new(xml)
        when String
          REXML::Document.new(xml)
        else
          xml
        end
      end
      
      def are_equal?(expected_doc, actual_doc)
        comparator = Conditionals.create
        iterate(expected_doc, actual_doc) do |expected_node, actual_node|
          unless comparator.compare_xml_nodes(expected_node, actual_node)
            return false
          end
        end
        true
      end
      
      def iterate(expected_doc, actual_doc)
        filter = Test::Unit::XML::XmlEqualFilter.new()
        expected_iterator = NodeIterator.new(expected_doc, filter)
        actual_iterator = NodeIterator.new(actual_doc, filter)
        while expected_iterator.has_next()
          expected_node = expected_iterator.next()
          actual_node = actual_iterator.next()
          yield expected_node, actual_node
        end
      end

    end
  end
end

