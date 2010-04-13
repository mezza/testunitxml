#! /usr/bin/ruby

@@lib_path = File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift @@lib_path 
$:.unshift File.dirname(__FILE__)

require 'test/unit'

Dir.foreach(File.dirname(__FILE__)) { |file|
  load file if file =~ /^tc.+\.rb$/
}

