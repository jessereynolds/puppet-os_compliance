require_relative '../lsp/security_policy.rb'

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

module PuppetX
  module Os_compliance
    module Controls
      def self.ensure_policy_value(policies, params)
        title            = params['title']
        policy           = params['policy']
        comparitor       = params['comparitor']
        operator         = params['operator']
        and_not_zero     = params['and_not_zero']
        comparitor_loose = params['comparitor_loose']

        debug = true
        
        # determine the actual policy value by looking it up in the supplied policies hash

        debug_data = {}
        if debug
          debug_data['debug_data'] = {'params' => params}
        end

        unless ['ensure_policy_value', 'ensure_policy_value_to_include'].include?(params['type'])
          return { 'compliancy' => 'unimplemented', 'state' => nil, 'title' => title, 
            'message' => "I only know how to evaluate controls with specific values. Type found: '#{params['type']}", }.merge(debug_data)
        end

        # TODO: need to determine if a policy is just missing from the secedit export or not in the list of known policies
        # Eg 'Account lockout duration' cannot exist unless 'Account lockout duration' is also set.
        valid_policy = false
        begin
          puts "policy: #{policy.inspect} #{params.inspect}" if policy.nil?
          policy_desc, policy_values = SecurityPolicy.find_mapping_from_policy_desc(policy)
          valid_policy = true
        rescue KeyError
          # policy not known in SecurityPolicy, leave valid_policy set as false
        end

        unless valid_policy
          return { 'compliancy' => 'unimplemented', 'state' => nil, 'title' => title, 
            'message' => "No policy named '#{policy}' in SecurityPolicy - perhaps not a security policy?", }.merge(debug_data)
        end

        unless policies[policy] and policies[policy][:policy_value]
          return { 'compliancy' => 'noncompliant', 'state' => nil, 'title' => title, 
            'message' => "The security policy '#{policy}' has no value.", }.merge(debug_data)
        end

        unless policies[policy] and policies[policy][:policy_value]
          return { 'compliancy' => 'unimplemented', 'state' => nil, 'title' => title, 
            'message' => "No existing policy found named '#{policy}''", }.merge(debug_data)
        end

        actual_policy_value = policies[policy][:policy_value]

        unless comparitor
          return { 'compliancy' => 'unimplemented', 'state' => actual_policy_value, 'title' => title,
            'message' => "No comparitor supplied", }.merge(debug_data)
        end

        case comparitor 
        when /^\d+$/
          comparitor_typed = comparitor.to_i
        when /^Enabled$/
          comparitor_typed = 1
        when /^Disabled$/
          comparitor_typed = 0
        else
          comparitor_typed = comparitor  
        end

        actual_policy_value_typed = case actual_policy_value
        when /^\d+$/
          actual_policy_value.to_i
        when /^((\*S[0-9-]*),?)*$/ # comma separated list of SIDs
          splits = actual_policy_value.split(',').map {|sid| 
            # Ref: https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
            case sid
            when '*S-1-5-32-544'
              'Administrators'
            else
              sid
            end
          }
          splits.length > 1 ? splits : splits.first
        when '4,0'
          0
        when '4,1'
          1
        else
          actual_policy_value_typed = actual_policy_value
        end

        if debug
          debug_data['debug_data']['comparitor']       = comparitor
          debug_data['debug_data']['comparitor_typed'] = comparitor_typed
        end

        if debug
          debug_data['debug_data']['actual_policy_value']       = actual_policy_value
          debug_data['debug_data']['actual_policy_value_typed'] = actual_policy_value_typed
        end

        begin
          case operator
          when '=='
            unless actual_policy_value_typed == comparitor_typed
              return { 'compliancy' => 'noncompliant', 'state' => actual_policy_value, 'title' => title,}.merge(debug_data)
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
              'message' => 'membership type controls are not yet implemented', }.merge(debug_data)
          else
            return { 'compliancy' => 'unimplemented', 'state' => actual_policy_value, 'title' => title, 
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
