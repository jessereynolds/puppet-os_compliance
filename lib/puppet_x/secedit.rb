require_relative 'lsp/security_policy.rb'

module PuppetX
  module Secedit
    # converts any values that might be of a certain type specified in the mapping
    # converts everything to a string
    # returns the value
    def self.fixup_value(value, type)
      value = value.to_s.strip
      case type
        when :quoted_string
          value = "\"#{value}\""
      end
      value
    end

    # export the policy settings to the specified file and return the filename
    def self.get_policies
      return @policies if @policies

      tempfile = Tempfile.new('os_compliance_')
      inffile_winpath = tempfile.path.gsub('/', '\\')

      # puts "Exporting policies to inifile #{inffile_winpath}"

      Facter::Core::Execution.execute("secedit /export /cfg #{inffile_winpath} /quiet")

      unless File.exist?(inffile_winpath)
        raise "secedit export file does not exist at #{inffile_winpath}"
      end

      #puts File.read(tempfile).inspect
        
      @inifile = nil
      File.open tempfile, 'r:IBM437' do |file|
        content_ibm437 = file.read
        content_utf8 = content_ibm437.encode('utf-8')
        @inifile = PuppetX::Inifile.new(:content => content_utf8)
      end

      policies = {}

      @inifile.each do |section, parameter_name, parameter_value|
        # need to find the policy, section_header, policy_setting, policy_value and reg_type
        # puts "    section: #{section} param: #{parameter_name}, value: #{parameter_value}"
        next if section == 'Unicode'
        next if section == 'Version'
        begin
          ensure_value = parameter_value.nil? ? :absent : :present
          policy_desc, policy_values = SecurityPolicy.find_mapping_from_policy_name(parameter_name)
          policy_hash = {
              :ensure => ensure_value,
              :policy_type => section ,
              :policy_setting => parameter_name,
              :policy_value => fixup_value(parameter_value, policy_values[:data_type])
          }
          policies[policy_desc] = policy_hash
        end
      end
      policies
    end

  end
end
