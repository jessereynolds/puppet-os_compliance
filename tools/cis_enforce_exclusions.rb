#!/usr/bin/env ruby

require 'yaml'

# (L1) Ensure 'Enforce password history' is set to '24 or more password(s)'
# ensure_enforce_password_history_is_set_to_24_or_more_passwords
def transform_control_title (title)
  title.gsub(/^\(L1\) /, '').gsub(/[()',.&:]/, '').gsub(/.scr/, '').gsub(/\s+/, '_').gsub(/[\\%-]/, '_').gsub(/_+/,'_').downcase
end

structure = YAML.load File.read(ARGF.file)

puts "number of controls: #{structure.length}"
enforce_false = structure.select { |control, attrs|
  attrs['enforce'] == false
}
puts "number of controls to not enforce: #{enforce_false.length}"

# load up the check file to ensure we are converting the title names correctly:

checkfile = File.read('../../../../github.com/autostructure/harden_windows_server/manifests/init.pp')

enforce_false.each_pair {|control, attrs|
  simple_title = transform_control_title(attrs['title'])

  if checkfile =~ /#{simple_title}/
  else
    puts "#{control} - #{simple_title}"
    #puts "             #{attrs['title']}"
  end
}

