#!/usr/bin/env ruby
#

require 'yaml'
require 'csv'

files = ARGV

benchmarks = []
controls = {}
files.each {|file|
  benchmark = File.basename(file, ".yaml")
  benchmarks << benchmark
  structure = YAML.load File.read(file)
  structure.each_pair {|control, attrs|
    #unique_title = attrs['unique_title']
    unique_title = attrs['title']
    controls[unique_title] = {} unless controls[unique_title]
    controls[unique_title][benchmark] = control
  }
}

benchmark_particular = {}
benchmarks.each {|benchmark|
  # find controls that are in this benchmark only
  benchmark_particular[benchmark] = controls.select {|title, benchmarks|
    benchmarks.length == 1 && benchmarks[benchmark]
  }
}


#puts benchmark_particular.to_yaml

rows = [['in this set only', 'id', 'control']]
benchmark_particular.each_pair do |benchmark, controls|
  controls.each_pair do |control, details|
    rows << [benchmark, details[benchmark], control]
  end
end

csv_string = CSV.generate do |csv|
  rows.each {|row| csv << row }
end

puts csv_string

