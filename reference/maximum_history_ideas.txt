# as a method

def password_history(policies = {})
  unless policies['Enforce password history']
    return {
      compliant: false,
      message: "Unable to find a policy with description: #{policy_description}",
    }
  end
  policy_value = policies['Enforce password history']['policy_value']
  unless policy_value.to_i >= 24
    return {
      compliant: false
      message: "Value is required to be 24 or greater, actual value: #{policy_value}",
    }
  end
  return { compliant: true }
end

$results['1.1.1:password_history'] = password_history(policies)
$results['1.1.2:maximum_password_age'] = maximum_password_age(policies)

# more generally: 

def ensure_policy_value (policy_value, operator, comparitor)
end

ensure_policy_value (policies, '1.1.1', 'Ensure password history', '>=', 24)

result = ensure_policy_value (
  policies:    policies, 
  title:       "(L1) Ensure 'Enforce password history' is set to '24 or more password(s)'",
  policy:      'Ensure password history', 
  operator:    '>=', # also >, ==, !=, <, <=, member, not_member
  comparitor:  24,
)

if result['compliant']
  compliant_controls[key] = result
else
  non_compliant_controls[key] = result
end

returns: 

{
  '1.1.1' => {
    'compliant' => false,
    'state'     => 2,
    'title'     =>  "(L1) Ensure 'Enforce password history' is set to '24 or more password(s)'",
  } 
}

These results can then be merged together etc.

# as a lambda

ensure_policy_value = lambda do |policy_value, operator, comparitor|
    
end

ensure_policy_value.call(policies['Enforce password history']['policy value'])

# as one big bit of code
$results = {}

$results['1.1.1:password_history']['description'] = "(L1) Ensure 'Enforce password history' is set to '24 or more password(s)'"
if policies['Enforce password history']
  policy_value = policies['Enforce password history']['policy_value']
  if policy_value
    if policy_value.to_i >= 24
      $results['1.1.1:password_history']['compliant'] = true
      $results['1.1.1:password_history']['state'] = policy_value
    else
      $results['1.1.1:password_history']['compliant'] = false
      $results['1.1.1:password_history']['state'] = policy_value
      $results['1.1.1:password_history']['message'] = "Unable to find a policy with description #{policy_description}"
    end
  else
  end
else
  $results['1.1.1:password_history']['compliant'] = false
  $results['1.1.1:password_history']['message'] = "Unable to find a policy with description #{policy_description}"
end


