require 'tempfile'
require 'fileutils'
require_relative "../puppet_x/inifile"
require_relative "../puppet_x/secedit"
require_relative "../puppet_x/controls/ensure_policy_value"
require 'yaml'

  # export and then read the policy settings from a file into a inifile object
  # caches the IniFile object during the puppet run
  # def self.read_policy_settings(inffile=nil)
  #   inffile ||= temp_file
  #   unless @file_object
  #     export_policy_settings(inffile)
  #     File.open inffile, 'r:IBM437' do |file|
  #       # remove /r/n and remove the BOM
  #       inffile_content = file.read.force_encoding('utf-16le').encode('utf-8', :universal_newline => true).gsub("\xEF\xBB\xBF", '')
  #       @file_object ||= PuppetX::IniFile.new(:content => inffile_content)
  #     end
  #   end
  #   @file_object
  # end

mydir = File.expand_path(File.dirname(__FILE__))

Facter.add('os_compliance') do
  # TODO: work out how to use structured facts here
  confine :osfamily                  => 'Windows'
  #confine :operatingsystemmajrelease => '2012 R2'
  setcode do
    the_fact = {}

    policies = PuppetX::Secedit.get_policies
    cis_benchmark = YAML.load(File.read(File.join(mydir, '..', 'cis_windows_2012r2_member_server_2.3.0.yaml')))

    controls = {} 

    cis_benchmark.each_pair do |key, attributes|
      results = PuppetX::Os_compliance::Controls.ensure_policy_value(policies, attributes)
      if results['compliancy']
        controls[results['compliancy']] = {} unless controls[results['compliancy']]
        controls[results['compliancy']][key.gsub('.', '_')] = results
      else
        controls['errored'] = {} unless controls['errored']
        controls['errored'][key] = results
      end

    end
 
    number_controls      = cis_benchmark.length
    number_compliant     = controls['compliant'] ? controls['compliant'].length : 0
    number_noncompliant  = controls['noncompliant'] ? controls['noncompliant'].length : 0
    number_unknown       = controls['unknown'] ? controls['unknown'].length : 0
    number_unimplemented = controls['unimplemented'] ? controls['unimplemented'].length : 0
    number_exceptions    = controls['exception'] ? controls['exception'].length : 0
    percent_compliant    = number_controls > 0 ? (number_compliant * 100.0) / number_controls : nil
    percent_implemented  = number_controls > 0 ? ((number_controls - number_unimplemented) * 100.0) / number_controls : nil
    the_fact['cis_level_1'] = {
      'version'              => 'cis_windows_2012r2_member_server_2.3.0',
      'percent_compliant'    => percent_compliant,
      'percent_implemented'  => percent_implemented,
      'number_compliant'     => number_compliant,
      'number_noncompliant'  => number_noncompliant,
      'number_unknown'       => number_unknown,
      'number_unimplemented' => number_unimplemented,
      'number_exceptions'    => number_exceptions,
      'number_controls'      => number_controls,
      'controls'             => controls,
    }
    the_fact
  end
end


# module Os_compliance
#   class Control 
#     attr_reader()
#     attr_accessor(
#       :name,
#       :description,
#       :standards,
#     )

#   end

#   class Standard
#     attr_accessor(
#       :name,
#       :description,
#       :organisation,
#       :version,
#       :os_name,
#       :os_version,
#     )
#   end

#   class Standard::Cis
#   super Os_compliance::Standard
#   attr_accessor(
#     :
#   )

#   end
# end

