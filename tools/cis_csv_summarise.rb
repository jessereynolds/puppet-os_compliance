#!/usr/bin/env ruby
#
# Converts a CSV to YAML hash using second column as the key
# Assumes that the first row contains field names

require 'csv'
require 'yaml'

fields = []
row_number = 0
structure = CSV.new(ARGF.file).inject({}) do |memo, row|

  row_number += 1
  if row_number == 1
    # set the field names
    unless row[-1].is_a?(String)
      row.pop
    end
    fields = row.map do |item|
      field = item.gsub(/^\W+/, '')
      field
    end
  else
    next unless row.length > 2
    key = "#{row[1] or row[0]}"
    next unless key.is_a? String

    hashy = {}
    fields.each_with_index do |field, index|
      next unless field and index < row.length
      hashy[field] = row[index]
    end
    memo[key] = hashy
  end
  memo
end

summary = {}
structure.each_pair do |key, attrs|
  next unless attrs['recommendation #']
  section = attrs['section #']
  title = attrs['title'].gsub(/\s/, ' ')
  puts "#{section} #{key} #{title}"
end


