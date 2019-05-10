#!/usr/bin/env ruby
#

require 'yaml'

files = ARGV

benchmarks = {}
files.each {|file|
  benchmark = File.basename(file, ".yaml")
  structure = YAML.load File.read(file)
  structure.each_pair {|control, attrs|
    unique_title = attrs['unique_title']
    benchmarks[unique_title] = {} unless benchmarks[unique_title]
    benchmarks[unique_title][benchmark] = control
  }
}

puts benchmarks.to_yaml
#benchmarks.each_pair {|title, details|
#  puts title
#  details.each_pair {|benchmark, number|
#    puts "  #{number} #{benchmark}"
#  }
#}
