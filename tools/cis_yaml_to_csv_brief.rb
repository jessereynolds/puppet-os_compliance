#!/usr/bin/env ruby
#

require 'csv'
require 'yaml'

controls = YAML.load File.read(ARGF.file)

rows = [['id', 'title']]
controls.each_pair do |id, details|
  rows << [id, details['title']]
end

csv_string = CSV.generate do |csv|
  rows.each {|row| csv << row }
end

puts csv_string

