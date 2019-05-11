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
benchmark_dir = File.join(mydir, '..')


module Windows_compliance
  def self.evaluate_benchmark(benchmark_identifier, benchmark_dir, options)

    cis_benchmark = YAML.load(File.read(File.join(benchmark_dir, "#{benchmark_identifier}.yaml")))
    policies = PuppetX::Secedit.get_policies

    controls = {} 
    cis_benchmark.each_pair do |key, attributes|
      results = PuppetX::Os_compliance::Controls.ensure_policy_value(policies, attributes, :debug => options[:debug])
      if results['compliancy']
        controls[results['compliancy']] = {} unless controls[results['compliancy']]
        controls[results['compliancy']][key.gsub('.', '_')] = results
      else
        controls['errored'] = {} unless controls['errored']
        controls['errored'][key] = results
      end
    end
    controls
  end

  def self.present_fact(controls, benchmark_identifier, options)
    counts_by_state = {}
    controls.each_pair {|state, controls_by_state|
      counts_by_state[state] = controls_by_state.length
    }
    #number_controls      = counts_by_state.values.inject {|memo, state| memo + state }
    number_controls = 0
    counts_by_state.each_pair {|state, count| number_controls += count }
    number_compliant     = counts_by_state['compliant'] || 0
    number_unimplemented = counts_by_state['unimplemented'] || 0
    percent_compliant    = number_controls > 0 ? (number_compliant * 100.0) / number_controls : nil
    percent_implemented  = number_controls > 0 ? ((number_controls - number_unimplemented) * 100.0) / number_controls : nil

    controls_summary = controls.map {|status, details|
      { status => details.keys }
    }

    the_fact = {}
    the_fact['cis_level_1'] = {
      'version'              => benchmark_identifier,
      'percent_compliant'    => percent_compliant,
      'percent_implemented'  => percent_implemented,
      'counts_by_state'      => counts_by_state,
      'number_controls'      => number_controls,
    }
    if options[:show_details]
      the_fact['cis_level_1']['controls'] = controls
    end
    if options[:show_summary]
      the_fact['cis_level_1']['controls_summary'] = controls_summary
    end
    the_fact
  end
end

options = {
  :show_details => false, # if true then the name and state and other details of each control will be include in the fact output
  :show_summary => false, # if true then the name and state and other details of each control will be include in the fact output
  :debug => false,       # if true, and the above details is true, then further debug info will be included for each control
}

Facter.add('os_compliance') do
  confine :osfamily                  => 'Windows'
  confine :operatingsystemmajrelease => '2016'
  setcode do
    benchmark_identifier = 'cis_windows_2016rtm1607_member_server_1.1.0'
    controls = Windows_compliance.evaluate_benchmark(benchmark_identifier, benchmark_dir, options)
    the_fact = Windows_compliance.present_fact(controls, benchmark_identifier, options)
  end
end

Facter.add('os_compliance') do
  confine :osfamily                  => 'Windows'
  confine :operatingsystemmajrelease => '2012 R2'
  setcode do
    benchmark_identifier = 'cis_windows_2012r2_member_server_2.3.0'
    controls = Windows_compliance.evaluate_benchmark(benchmark_identifier, benchmark_dir, options)
    the_fact = Windows_compliance.present_fact(controls, benchmark_identifier, options)
  end
end

Facter.add('os_compliance') do
  confine :osfamily                  => 'Windows'
  confine :operatingsystemmajrelease => '2008 R2'
  setcode do
    benchmark_identifier = 'cis_windows_2008r2_member_server_3.1.0'
    controls = Windows_compliance.evaluate_benchmark(benchmark_identifier, benchmark_dir, options)
    the_fact = Windows_compliance.present_fact(controls, benchmark_identifier, options)
  end
end
