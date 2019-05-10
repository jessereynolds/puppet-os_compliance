# Applies rulesets
#
# @summary A short summary of the purpose of this class
#
# @example
#   include os_compliance::apply
class os_compliance::apply (
  $rulesets = [],
) {
  $rulesets.each |$ruleset| {
    lookup("os_compliance::ruleset::${ruleset}").each |$rule, $mode| {
      $rule_class = lookup("os_compliance::rule_alias::${rule}", String)
      class { "os_compliance::rules::${rule_class}":
        mode => $mode,
        tag  => [$rule, $ruleset],
      }
    }
  }
}
