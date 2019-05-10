#!/usr/bin/env ruby

require 'yaml'

structure = YAML.load File.read(ARGF.file)

puts "# harden_windows_server autogenerated by os_compliance"
puts "# number of controls: #{structure.length}"

puts "class harden_windows_server ("

structure.each_pair {|control, attrs|
  puts "  Boolean $#{attrs['unique_title']} = #{attrs['enforce'].to_s},"
}

puts ") {"
puts "}"
