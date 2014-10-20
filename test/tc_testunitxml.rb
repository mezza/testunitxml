#! /usr/bin/env ruby

@@lib_path = File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift @@lib_path 

require 'test/unit/xml'
require 'rexml/document'
require 'stringio'

class TestTestUnitXml < Test::Unit::TestCase
  TEST_1_PATH = "test/data/test1.xml"
    
  def setup
    @file = File.new(TEST_1_PATH)
    @doc1 = REXML::Document.new(@file)
    @io1 = File.new(TEST_1_PATH)
    @io2 = File.new(TEST_1_PATH)
    @string1 = %Q{<t:root xmlns:t="urn:x-hm:test" xmlns:x="urn:x-hm:test2" id="a" t:type="test1"/>}
    @element1 = REXML::Document.new(%Q{<t:root xmlns:t="urn:x-hm:test" xmlns:x="urn:x-hm:test2" id="a" t:type="test1"/>}).root
    @element2 = REXML::Document.new(%Q{<root xmlns:t="urn:x-hm:test" xmlns:x="urn:x-hm:test2" id="a" t:type="test1"/>}).root
    @element3 = REXML::Document.new(%Q{<t:root xmlns:t="urn:x-hm:other" xmlns:x="urn:x-hm:test2" id="a" t:type="test1"/>}).root
    @element4 = REXML::Document.new(%Q{<t:root xmlns:t="urn:x-hm:test" xmlns:x="urn:x-hm:test2" id="a" x:type="test1"/>}).root
    @element5 = REXML::Document.new(%Q{<t:root xmlns:t="urn:x-hm:test" xmlns:x="urn:x-hm:test2" id="a" t:type="test2"/>}).root
    @element6 = REXML::Document.new(%Q{<t:root  id="a" xmlns:t="urn:x-hm:test" xmlns:x="urn:x-hm:test2" t:type="test1"/>}).root
    @element7 = REXML::Document.new(%Q{<s:root xmlns:s="urn:x-hm:test" xmlns:x="urn:x-hm:test" id="a" s:type="test1"/>}).root
    @element8 = REXML::Document.new(%Q{<t:root xmlns:t="urn:x-hm:test" id="a" t:type="test1"/>}).root
    @text1 = REXML::Text.new(" Q")
    @text2 = REXML::Text.new("  &#81;")
    @text3 = REXML::Text.new("  Q ")
    @cdata1 = REXML::CData.new("Test text")
    @cdata2 = REXML::CData.new("Test \ntext")
    @comment1 = REXML::Comment.new("This is a comment.")
    @comment2 = REXML::Comment.new("This is another comment.")
    @pi1 = REXML::Instruction.new('pi1', 'content')
    @pi2 = REXML::Instruction.new('pi2', 'content')
    @pi3 = REXML::Instruction.new('pi1', 'other content')
    @whitespace1 = REXML::Document.new(%Q{<r><a>Some <b>text</b>.</a></r>})
    @whitespace2 = REXML::Document.new(%Q{<r> <a>Some <b>text</b>.</a>\n  \n  </r>})
    @whitespace3 = REXML::Document.new(%Q{<r><a>Some <b> text</b>.</a></r>})
    # REXML:XMLDecl.new(version=DEFAULT_VERSION, encoding=nil, standalone=nil)   
    @xml_decl1 = REXML::XMLDecl.new(1.0, "utf-8", "yes")
    @xml_decl2 = REXML::XMLDecl.new(1.1, "utf-8", "yes")
    @xml_decl3 = REXML::XMLDecl.new(1.0, "utf-16", "yes")
    @xml_decl4 = REXML::XMLDecl.new(1.0, "utf-8", "no")
  end
  
  def teardown
  end
    
  def test_assert_xml_equal_document
    assert_xml_equal(@doc1, @doc1, "Comparing two REXML::Document objects")
  end
  
  def test_assert_xml_equal_io
    assert_xml_equal(@io1, @io2, "Comparing two IO objects")
  end

  def test_assert_xml_equal_string
    assert_xml_equal(@string1, @string1, "Comparing two XML strings")
  end
  
  def test_assert_xml_equal_element
    assert_instance_of(REXML::Element, @element1)
    assert_xml_equal(@element1, @element1)
    check_assertion_failure(@element1, @element2)
    check_assertion_failure(@element1, @element3)
    check_assertion_failure(@element1, @element4)
    check_assertion_failure(@element1, @element5)
    assert_xml_equal(@element1, @element6)
    assert_xml_equal(@element1, @element7)
    assert_xml_equal(@element1, @element8)
  end
  
  def check_assertion_failure(expected, actual)
    assert_raise(Test::Unit::AssertionFailedError) {
      assert_xml_equal(expected, actual)
    }
  end
  
  def test_assert_xml_equal_text
    assert_instance_of(REXML::Text, @text1)
    assert_instance_of(REXML::Text, @text1)
    assert_xml_equal(@text1, @text1)
    assert_xml_equal(@text1, @text2)
    check_assertion_failure(@text1, @text3)
  end
  
  def test_assert_xml_equal_cdata
    assert_instance_of(REXML::CData, @cdata1)
    assert_instance_of(REXML::CData, @cdata2)
    assert_xml_equal(@cdata1, @cdata1)
    check_assertion_failure(@cdata1, @cdata2)
  end
  
  def test_assert_xml_equal_comment
    assert_instance_of(REXML::Comment, @comment1)
    assert_instance_of(REXML::Comment, @comment2)
    assert_xml_equal(@comment1, @comment1)
    check_assertion_failure(@comment1, @comment2)
  end

  def test_assert_xml_equal_pi
    assert_instance_of(REXML::Instruction, @pi1)
    assert_instance_of(REXML::Instruction, @pi2)
    assert_instance_of(REXML::Instruction, @pi3)
    assert_xml_equal(@pi1, @pi1)
    check_assertion_failure(@pi1, @pi2)
    check_assertion_failure(@pi1, @pi3)
  end
  
  def test_assert_xml_equal_whitespace
    assert_xml_equal(@whitespace1, @whitespace1)
    assert_xml_equal(@whitespace1, @whitespace2, "Check if extraneous whitespace is skipped")
    check_assertion_failure(@whitespace1, @whitespace3)
  end
  
  def test_assert_xml_equal_xmldecl
    assert_instance_of(REXML::XMLDecl, @xml_decl1)
    assert_xml_equal(@xml_decl1, @xml_decl1)
    check_assertion_failure(@xml_decl1, @xml_decl2)
  end
  
  def test_assert_xml_equal_doctype
    string1 = <<-'XMLEND'
    <!DOCTYPE r PUBLIC "TEST1" "http://www.henrikmartensson.org/dtd1">
    <r/>
    XMLEND
    string2 = <<-'XMLEND'
    <!DOCTYPE r PUBLIC "TEST1" "http://www.henrikmartensson.org/dtd2">
    <r/>
    XMLEND
    string3 = <<-'XMLEND'
    <!DOCTYPE r PUBLIC "TEST2" "http://www.henrikmartensson.org/dtd1">
    <r/>
    XMLEND
    string4 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1">
    <r/>
    XMLEND
    string5 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "urn:x-henrikmartensson.org:dtd1">
    <r/>
    XMLEND
    string6 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "urn:x-henrikmartensson.org:dtd2">
    <r/>
    XMLEND
    assert_xml_equal(string1, string1)
    assert_xml_equal(string1, string2)
    check_assertion_failure(string1, string3)
    check_assertion_failure(string1, string4)
    check_assertion_failure(string1, string5)
    assert_xml_equal(string5, string5)
    check_assertion_failure(string5, string6)
  end
  
  def test_assert_xml_equal_internal_entity_decl
    string1 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!ENTITY internal1 "This is an internal entity">
    ]>
    <r/>
    XMLEND
    string2 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!ENTITY internal1 "This is another internal entity">
    ]>
    <r>&internal1;</r>
    XMLEND
    string3 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!ENTITY internal1 "This is an internal entity">
      <!ENTITY internal2 "This is another internal entity">
    ]>
    <r>&internal1;</r>
    XMLEND
    string4 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!ENTITY internal2 "This is another internal entity">
      <!ENTITY internal1 "This is an internal entity">
    ]>
    <r>&internal1;</r>
    XMLEND
    string5 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!ENTITY internal1 "This is an internal entity">
      <!ENTITY internal2 "This is another internal entity">
      <!ENTITY internal3 "This is a third internal entity">
    ]>
    <r>&internal1;</r>
    XMLEND
    assert_xml_equal(string1, string1)
    check_assertion_failure(string1, string2)
    check_assertion_failure(string1, string3)
    check_assertion_failure(string3, string1)
    assert_xml_equal(string3, string4,"Testing that entities may be declared in any order")
  end
  
  def test_assert_xml_equal_external_entity_decl
    string1 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!NOTATION pdf SYSTEM "pdf">
      <!NOTATION word SYSTEM "word">
      <!ENTITY external1 SYSTEM "urn:x-henrikmartensson.org:resource1" NDATA pdf>
    ]>
    <r/>
    XMLEND
    string2 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!NOTATION pdf SYSTEM "pdf">
      <!NOTATION word SYSTEM "word">
      <!ENTITY external1 SYSTEM "urn:x-henrikmartensson.org:resource1" NDATA word>
   ]>
    <r/>
    XMLEND
    string3 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!NOTATION pdf SYSTEM "pdf">
      <!ENTITY external1 SYSTEM "urn:x-henrikmartensson.org:resource1" NDATA pdf>
      <!NOTATION word SYSTEM "word">
    ]>
    <r/>
    XMLEND
    assert_xml_equal(string1, string1)
    check_assertion_failure(string1, string2)
    assert_xml_equal(string1, string3)
  end
  
  def test_assert_xml_equal_notation_decl
    string1 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!NOTATION pdf SYSTEM "pdf">
    ]>
    <r/>
    XMLEND
    string2 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!NOTATION pdf PUBLIC "pdf">
    ]>
    <r/>
    XMLEND
    string3 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!NOTATION pdf SYSTEM "word">
    ]>
    <r/>
    XMLEND
    assert_xml_equal(string1, string1)
    check_assertion_failure(string1, string2)
    check_assertion_failure(string1, string3)
  end
  
  def test_assert_xml_equal_doctype_comment
    string1 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!NOTATION pdf SYSTEM "pdf">
      <!-- A comment -->
    ]>
    <r/>
    XMLEND
    string2 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!-- A comment -->
      <!NOTATION pdf SYSTEM "pdf">
    ]>
    <r/>
    XMLEND
    string3 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!NOTATION pdf SYSTEM "pdf">
      <!-- A different comment -->
    ]>
    <r/>
    XMLEND
    string4 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!-- A comment -->
      <!-- Another comment -->
    ]>
    <r/>
    XMLEND
    string5 = <<-'XMLEND'
    <!DOCTYPE r SYSTEM "http://www.henrikmartensson.org/dtd1" [
      <!-- Another comment -->
      <!-- A comment -->
    ]>
    <r/>
    XMLEND
    assert_xml_equal(string1, string2)
    check_assertion_failure(string1, string3)
    check_assertion_failure(string4, string5)
  end
  
  def test_xml_not_equal
    assert_xml_not_equal(@element1, @element2)
    assert_xml_not_equal(@element1, @element3)
    assert_xml_not_equal(@element1, @element4)
    assert_xml_not_equal(@element1, @element5)
  end
  
  def test_entity_in_attribute
    # This test was propmpted by a bug report from
    # Paul Battley
    xml_string = '<root text="This &amp; that"/>'
    doc_original = REXML::Document.new(xml_string)
    doc_clone = doc_original.dup
    assert_xml_equal(doc_original, doc_clone)
    
    xml_different = '<root text="this &amp; that"/>'
    doc_different = REXML::Document.new(xml_different)
    assert_xml_not_equal(doc_original, doc_different)
  end
  
    
end