# This is a Puppet custom fact which evaluates the machine for compliance against the relevant CIS benchmark.
# Initially this is being developed to support Windows 2012 R2 and following on from that other Windows server OSes.
# It works by calling secedit to export all the current security policy values and then comparing 
# that with the recommendations in the CIS L1 Member Server benchmark.
#
# Each CIS benchmark is expressed in a YAML file of a format like the following example: 
#
# 1.1.1:
#   title: "(L1) Ensure 'Enforce password history' is set to '24 or more password(s)'"
#   type: ensure_policy_value
#   policy: Enforce password history
#   comparitor_loose: 24 or more password(s)
#   comparitor: 24
#   operator: ">="
#   and_not_zero: false
# 1.1.2:
#   title: "(L1) Ensure 'Maximum password age' is set to '60 or fewer days, but not
#     0'"
#   type: ensure_policy_value
#   policy: Maximum password age
#   comparitor_loose: 60 or fewer days, but not 0
#   comparitor: 60
#   operator: "<="
#   and_not_zero: true

require 'tempfile'
require 'fileutils'
require_relative "../puppet_x/inifile"
require_relative "../puppet_x/secedit"
require_relative "../puppet_x/controls/ensure_policy_value"
require 'yaml'

# export and then read the policy settings from a file into a inifile object
 
mydir = File.expand_path(File.dirname(__FILE__))

# if true then the name and state and other details of each control will be include in the fact output
show_details = true

# if true, and the above details is true, then further debug info will be included for each control
debug = false

Facter.add('os_compliance') do
  confine :osfamily                  => 'Windows'
  #confine :operatingsystemmajrelease => '2012 R2'
  setcode do
    the_fact = {}

    policies = PuppetX::Secedit.get_policies
    cis_benchmark = YAML.load(File.read(File.join(mydir, '..', 'cis_windows_2012r2_member_server_2.3.0.yaml')))

    controls = {} 

    cis_benchmark.each_pair do |key, attributes|
      results = PuppetX::Os_compliance::Controls.ensure_policy_value(policies, attributes, :debug => debug)
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

    controls_summary = controls.map {|status, details|
      { status => details.keys }
    }

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
      'controls_summary'     => controls_summary,
    }
    if show_details
      the_fact['cis_level_1']['controls'] = controls
    end
    the_fact
  end
end
