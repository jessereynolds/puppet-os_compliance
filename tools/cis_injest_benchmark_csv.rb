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

def transform_control_title (title)
  title.gsub(/^\(L1\) /, '').gsub(/[()',.&:+\/"]/, '').gsub(/.scr/, '').gsub(/\s+/, '_').gsub(/[\\%-]/, '_').gsub(/_+/,'_').downcase
end


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
      field = item.gsub(/^\W+/, '').downcase
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
unique_titles = []

structure.each_pair do |key, attrs|
  is_section = attrs['recommendation #'] ? false : true
  unless is_section
    section = attrs['section #']
    title = attrs['title'].gsub(/\s/, ' ')
    title = title.gsub(/\s/, ' ')
    type = nil
    policy = nil
    comparitor_loose = nil
    comparitor = nil
    operator = nil
    and_not_zero = false
    deep_operator = nil
    deep_comparitor = nil

    if attrs['description'] =~ /\*\*Level 1 - Member Server\.\*\* The recommended state for this setting (is|is to include): (.*)\./
      deep_operator = $1
      deep_comparitor = $2
    end

    # There are nine 'Configure ...' in 2012 R2 L1 Member Server which have the following details embedded in the description. They are of the following types, syntactically:
    #
    # - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators, Authenticated Users`.
    # - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators` and (when the _Hyper-V_ Role is installed) `NT VIRTUAL MACHINE\Virtual Machines`.
    # - **Level 1 - Member Server.** The recommended state for this setting is to include: `Guests, Local account and member of Administrators group`.
    # - **Level 1 - Member Server.** The recommended state for this setting is: `` (i.e. None), or (when the legacy _Computer Browser_ service is enabled) `BROWSER`.

    monitor = false
    enforce = false
    if attrs['action'].is_a?(String)
      monitor = true if attrs['action'].downcase =~ /monitor/
      enforce = true if attrs['action'].downcase =~ /enforce/
    end

    case title
    when /Ensure '(.*)' is set to '(.*)'/
      type = 'ensure_policy_value'
      policy = $1
      comparitor_loose = $2
      case comparitor_loose
      when /^(\d+).*or (more|fewer)(.*)$/
        comparitor = $1.to_i
        operator = ($2 == 'more') ? '>=' : '<='
        and_not_zero = ($3 =~ /but not 0/) ? true : false
      when /\w.*,.*\w/ # words separated by commas
        splits = comparitor_loose.split(',').map {|comp|
          comp.gsub!(/^\s*/, '')
          comp.gsub!(/\s*$/, '')
        }
        splits.select! {|c| c and c =~ /\w+/ }
        comparitor = splits.length > 1 ? splits : splits.first
        operator = '=='
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
      policy = $1
      case deep_operator
      when 'is'
        type = 'ensure_policy_value'
        operator = '=='
        comparitor_loose = deep_comparitor
      when 'is to include'
        type = 'ensure_policy_value_to_include'
        operator = 'member'
        comparitor_loose = deep_comparitor
      else
        type = 'ensure_some_configuration'
      end
      if deep_comparitor and deep_comparitor.count('`') == 2
        # remove quotes if we have just single pair of quotes (backticks)
        comparitor = /`(.*)`/.match(deep_comparitor)[1]
      end

    else
      type = 'snowflake'
    end

  simple_title = transform_control_title(title)
  # Assumes 2018 R2 benchmark version 3.1.0 ... numbers may differ in other versions / oses
  additional_context = case key
                       when /^18.9.97.1.1/
                         'winrm_client'
                       when /^18.9.97.1.2/
                         'winrm_client'
                       when /^18.9.97.2.1/
                         'winrm_service'
                       when /^18.9.97.2.3/
                         'winrm_service'
                       when '18.9.85.2'
                         'computer'
                       when '19.7.40.1'
                         'user'
                       else
                         ''
                       end

  unique_title = case additional_context
                 when ''
                   simple_title
                 else
                   "#{simple_title}_#{additional_context}"
                 end
    if unique_titles.include?(unique_title)
      raise "unique title is not so unique: #{unique_title}"
    end
    unique_titles << unique_title

    summary[key] = {
      'title'            => title,
      'unique_title'     => unique_title,
      'type'             => type,
      'policy'           => policy,
      'comparitor'       => comparitor,
      'operator'         => operator,
      'and_not_zero'     => and_not_zero,
      'comparitor_loose' => comparitor_loose,
      'deep_operator'    => deep_operator,
      'deep_comparitor'  => deep_comparitor,
      'monitor'          => monitor,
      'enforce'          => enforce,
    }
  end
end
puts summary.to_yaml


