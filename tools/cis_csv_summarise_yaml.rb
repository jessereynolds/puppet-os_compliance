#!/usr/bin/env ruby
#
# reads a CSV export of a CIS benchmark section and does stuff
#
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
last_section = ''
structure.each_pair do |key, attrs|
  is_section = attrs['recommendation #'] ? false : true
  section = attrs['section #']
  title = attrs['title'].gsub(/\s/, ' ')
  if is_section
    last_section = title
  end
  unless is_section
    summary[key] = {
      title: title,
      section: "#{section}: #{last_section}",
      short_name: '',

    }
  end
end
puts summary.to_yaml


