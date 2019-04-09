# Password history as per CIS 1.1.1
#
# @summary Password history as per CIS 1.1.1
#
# @example
#   include os_compliance::rules::account_policies::password_policies::history
class os_compliance::rules::account_policies::password_policies::password_history (
  Enum['enforce','monitor'] $mode         = 'monitor',
  String                    $policy_value = '24',
  Hash                      $options      = {},
) {
  if $mode == 'monitor' {
    noop()
  }

  unless $options.empty {
    warn('Parameter $options has values however options are currently not implemented in this class.')
  }
  # TODO: work out how to have this not alter a value that is already in compliance 
  # because it is higher than the minumum - use options hash
  local_security_policy { 'Enforce password history':
    ensure       => present,
    policy_value => $policy_value,
  }
}
