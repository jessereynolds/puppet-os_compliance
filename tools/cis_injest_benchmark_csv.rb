#!/usr/bin/env ruby
#
# reads a CSV export of a CIS benchmark section, processes it for easier consumption by algorithms,
# spits it back out as YAML
#
# takes the CSV on STDIN or give the path to the CSV file as the first argument to the script, eg:
#
#    bin/cis_injest_benchmark_csv.rb \
#      /path/to/CIS_Microsoft_Windows_Server_2012_R2_Benchmark_v2.3.0.csv \
#      > lib/cis_windows_2012r2_member_server_2.3.0.yaml
#
# the os_compliance fact will read these yaml benchmark descriptor files when evaluating compliance.

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
  title = title.gsub(/\s/, ' ')
  unless is_section
    type = nil
    policy = nil
    comparitor_loose = nil
    comparitor = nil
    operator = nil
    and_not_zero = false
    case title
    when /Ensure '(.*)' is set to '(.*)'/
      type = 'ensure_policy_value'
      policy = $1
      comparitor_loose = $2
      case comparitor_loose
      #when /^(Enabled|Disabled|Administrators)$/
      #  comparitor = comparitor_loose
      #  operator   = '=='
      when /^(\d+).*or (more|fewer)(.*)$/
        comparitor = $1.to_i
        operator = ($2 == 'more') ? '>=' : '<='
        and_not_zero = ($3 =~ /but not 0/) ? true : false
      else
        comparitor = comparitor_loose
        operator = '=='
      end
    when /Ensure \'(.*)\' to include \'(.*)\'/
      type = 'ensure_policy_value_to_include'
      policy = $1
      comparitor_loose = $2
      operator = 'member'
    when /Configure \'(.*)\'/
      type = 'ensure_some_configuration'
      policy = $1
    else
      type = 'snowflake'
    end

    summary[key] = {
      'title'            => title,
      'type'             => type,
      'policy'           => policy,
      'comparitor'       => comparitor,
      'operator'         => operator,
      'and_not_zero'     => and_not_zero,
      'comparitor_loose' => comparitor_loose,
    }
  end
end
puts summary.to_yaml


