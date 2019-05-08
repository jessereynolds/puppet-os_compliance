#!/usr/bin/env ruby

require 'yaml'

# (L1) Ensure 'Enforce password history' is set to '24 or more password(s)'
# ensure_enforce_password_history_is_set_to_24_or_more_passwords
def transform_control_title (title)
  title.gsub(/^\(L1\) /, '').gsub(/[()',.&:+\/"]/, '').gsub(/.scr/, '').gsub(/\s+/, '_').gsub(/[\\%-]/, '_').gsub(/_+/,'_').downcase
end

structure = YAML.load File.read(ARGF.file)

puts "# number of controls: #{structure.length}"

# load up the check file to ensure we are converting the title names correctly:

checkfile = File.read('../../../../github.com/autostructure/harden_windows_server/manifests/init.pp')

puts "class harden_windows_server ("

structure.each_pair {|control, attrs|
  # this delightful special casing is based on the 2008 R2 Member Server v3.1.0 benchmark
  # and is required because there are three CIS control titles that are duplicated in
  # different sections in the benchmark.
  #ensure_allow_basic_authentication_is_set_to_disabled'
	#18.9.97.1.1 - winrm client
	#18.9.97.2.1 - winrm service
	#ensure_allow_unencrypted_traffic_is_set_to_disabled
	#18.9.97.1.2 - winrm client
	#18.9.97.2.3 - winrm service
	#ensure_always_install_with_elevated_privileges_is_set_to_disabled
	#19.7.40.1 under Windows Installer
	#19 - Administrative Templates (User)
	#19.7 - Windows Components
	#19.7.40 - Windows Installer
	#18.9.85.2 under
	#18 - Administrative Templates (Computer)
	#18.9 - Windows Components
	#18.9.85 - Windows Installer


  simple_title = transform_control_title(attrs['title'])
  additional_context = case control
                       when /^18.9.97.1.1/
                         'winrm_client'
                       when /^18.9.97.1.2/
                         'winrm_client'
                       when /^18.9.97.2.1/
                         'winrm_server'
                       when /^18.9.97.2.3/
                         'winrm_server'
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

  puts "  Boolean $#{unique_title} = #{attrs['enforce'].to_s},"
}

puts ") {"
puts "}"

