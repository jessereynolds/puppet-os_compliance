# Determins whether a compliance control of type `ensure_policy_value` is
# compliant given a set of all policy settings passed to it.

require_relative '../lsp/security_policy.rb'

module PuppetX
  module Os_compliance
    module Controls
      def self.ensure_policy_value(policies, params, options)
        title            = params['title']
        policy           = params['policy']
        comparitor       = params['comparitor']
        operator         = params['operator']
        and_not_zero     = params['and_not_zero']
        comparitor_loose = params['comparitor_loose']
        deep_operator    = params['deep_operator']
        deep_comparitor  = params['deep_comparitor']

        debug = (options[:debug] == true)

        # determine the actual policy value by looking it up in the supplied policies hash

        debug_data = {}
        if debug
          debug_data['debug_data'] = {'params' => params}
        end

        unless ['ensure_policy_value', 'ensure_policy_value_to_include'].include?(params['type'])
          return {
            'compliancy'           => 'unimplemented',
            'state'                => nil,
            'title'                => title,
            'unimplemented_reason' => "unhandled_type:#{params['type']}",
            'message'              => "I only know how to evaluate controls with specific values. Type found: '#{params['type']}",
          }.merge(debug_data)
        end

        # TODO: need to determine if a policy is just missing from the secedit export or not in the list of known policies
        # Eg 'Account lockout duration' cannot exist unless 'Account lockout duration' is also set.
        valid_policy = false
        begin
          puts "policy: #{policy.inspect} #{params.inspect}" if policy.nil?
          policy_mapping = SecurityPolicy.find_mapping_from_policy_desc(policy)
          policy_name = policy_mapping[:name]
          policy_type = policy_mapping[:policy_type]
          valid_policy = true
        rescue KeyError
          # policy not known in SecurityPolicy, leave valid_policy set as false
        end

        unless valid_policy
          return {
            'compliancy'           => 'unimplemented',
            'state'                => nil,
            'title'                => title,
            'unimplemented_reason' => "invalid_policy:#{policy}",
            'message'              => "No policy named '#{policy}' in SecurityPolicy - perhaps not a security policy?",
          }.merge(debug_data)
        end

        # FIXME: Actually this is valid for policies needing to be set to 'No One' and maybe other values
        # unless policies[policy] and policies[policy][:policy_value]
        #   return { 'compliancy' => 'noncompliant', 'state' => nil, 'title' => title,
        #     'message' => "The security policy '#{policy}' has no value.", }.merge(debug_data)
        # end

        actual_policy_value = (policies[policy] and policies[policy][:policy_value]) ? policies[policy][:policy_value] : nil

        unless comparitor
          return { 'compliancy' => 'unimplemented', 'state' => actual_policy_value, 'title' => title,
            'unimplemented_reason' => "no_comparitor_supplied",
            'message' => "No comparitor supplied", }.merge(debug_data)
        end

        case comparitor
        when /^\d+$/
          comparitor_typed = comparitor.to_i
        when /^Enabled$/
          comparitor_typed = 1
        when /^Disabled$/
          comparitor_typed = 0
        when /^No One$/
          comparitor_typed = nil
        else
          comparitor_typed = comparitor
        end

        actual_policy_value_typed = case actual_policy_value
        when '4,2147483640'
          if policy_name =~ /SupportedEncryptionTypes/
            ['AES128_HMAC_SHA1', 'AES256_HMAC_SHA1', 'Future encryption types']
          else
            2147483640
          end
        when /^\d+$/
          actual_policy_value.to_i
        when /^((\*S[0-9-]*),?)*$/ # comma separated list of SIDs
          splits = actual_policy_value.split(',').map {|sid|
            # Ref: https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
            case sid
            when '*S-1-5-6'
              'Service'
            when '*S-1-5-19'
              'Local Service'
            when '*S-1-5-20'
              'Network Service'
            when '*S-1-5-32-544'
              'Administrators'
            when '*S-1-5-32-555'
              'Remote Desktop Users'
            else
              sid
            end
          }
          splits.length > 1 ? splits : splits.first
        when /4,(\d+)/
          $1.to_i
        when /O:BAG:BAD:/ # TODO: inifile lib is truncating this a the semi-colon for some reason
          'Administrators: Remote Access: Allow'
        # when /^1,(.+)$/
        #   $1
        else
          actual_policy_value
        end

        if debug
          debug_data['debug_data']['comparitor']                = comparitor
          debug_data['debug_data']['comparitor_typed']          = comparitor_typed
          debug_data['debug_data']['actual_policy_value']       = actual_policy_value
          debug_data['debug_data']['actual_policy_value_typed'] = actual_policy_value_typed
          debug_data['debug_data']['deep_operator']             = deep_operator   if deep_operator
          debug_data['debug_data']['deep_comparitor']           = deep_comparitor if deep_comparitor
          debug_data['debug_data']['policy_name']               = policy_name
          debug_data['debug_data']['policy_type']               = policy_type
        end

        begin
          if ['>=', '<='].include?(operator) and
            [actual_policy_value_typed, comparitor_typed].include?(nil)
            return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value,
              'message' => "actual value or comparitor is nil",
              'title' => title,}.merge(debug_data)
          end
          case operator
          when '=='
            case comparitor_typed
            when String
              if ! actual_policy_value_typed.is_a?(String) or
                actual_policy_value_typed.downcase != comparitor_typed.downcase
                return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value,
                  'message' => "comparitor is a String but actual value is not (it's a #{actual_policy_value_typed.class}), or the downcased strings do not match",
                  'title' => title,}.merge(debug_data)
              end
            when Array
              if actual_policy_value_typed.is_a?(Array)
                unless actual_policy_value_typed.map {|a| a.is_a?(String) ? a.downcase : a }.sort ==
                    comparitor_typed.map {|a| a.is_a?(String) ? a.downcase : a }.sort
                  return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value,
                    'message' => "the arrays are not equivalent",
                    'title' => title,}.merge(debug_data)
                end
              else
                return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value,
                  'message' => "comparitor is an Array but the actual value is not (it's a #{actual_policy_value_typed.class})",
                  'title' => title,}.merge(debug_data)
              end
            else
              unless actual_policy_value_typed == comparitor_typed
                return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value,
                  'message' => 'Comparitor is not a String or Array and is not equal to the actual policy value',
                  'title' => title,}.merge(debug_data)
              end
            end
          when '>='
            unless actual_policy_value_typed >= comparitor_typed
              return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value, 'title' => title,}.merge(debug_data)
            end
          when '<='
            unless actual_policy_value_typed <= comparitor_typed
              return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value, 'title' => title,}.merge(debug_data)
            end
          when 'member'
            return { 'compliancy' => 'unimplemented', 'state' => actual_policy_value, 'title' => title,
              'unimplemented_reason' => 'membership_controls_unimplemented',
              'message' => 'membership type controls are not yet implemented', }.merge(debug_data)
          else
            return { 'compliancy' => 'unimplemented', 'state' => actual_policy_value, 'title' => title,
              'unimplemented_reason' => 'controls_with_no_operator_unimplemented',
              'message' => 'controls with no operator are not yet implemented', }.merge(debug_data)
          end
        rescue StandardError => e
          message = "#{e.class} - #{e}"
          return { 'compliancy' => 'exception', 'state' => actual_policy_value, 'title' => title, 'message' => message}.merge(debug_data)
        end

        #unless actual_policy_value
        if actual_policy_value_typed == 0 and and_not_zero
          return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value, 'title' => title, }.merge(debug_data)
        end

        return { 'compliancy' => 'compliant', 'state' => actual_policy_value_typed, 'title' => title, }.merge(debug_data)

      end
    end
  end
end
