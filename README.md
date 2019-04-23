
# os_compliance

This module implements CIS benchmarks as a Puppet custom fact for reporting, and as Puppet classes for enforcement.

# Custom Fact - os_compliance

This works by consuming a YAML file that represents the particular benchmark for the current OS version where a bunch of the interpretation of each control's recommendations has been codified and checking each one off against the output of secedit. The `tools/cis_injest_benchmark_csv.rb` script does the generation of this YAML benchmark description file.

There's still a fair way to go with this and at some point I will probably have to start writing ruby methods for individual controls rather than having a general approach all of the L1 controls. As at 19 April 2019 33% of the CIS L1 Member Server controls for Windows 2012 R2 are implemented.

Relevant pieces of the puzzle: 

- script to generate the CIS benchmark description file - https://github.com/jessereynolds/puppet-os_compliance/blob/master/tools/cis_injest_benchmark_csv.rb
- resulting CIS benchmark description file for Windows 2012 R2 - https://github.com/jessereynolds/puppet-os_compliance/blob/master/lib/cis_windows_2012r2_member_server_2.3.0.yaml
- os_compliance custom fact - https://github.com/jessereynolds/puppet-os_compliance/blob/master/lib/facter/os_compliance.rb
- implementation of `ensure_policy_value` type controls - https://github.com/jessereynolds/puppet-os_compliance/blob/master/lib/puppet_x/controls/ensure_policy_value.rb


## Acknowledgements

Props to Paul Cannon, Adam Yohrling and Brett Gray for their respective work on:

- https://forge.puppet.com/ayohrling/local_security_policy
- https://forge.puppet.com/cannonps/local_security_policy
- https://github.com/beergeek/cis

And others who've made various inroads on CIS benchmark implementations with Puppet. 

## Limitations

This module is in active development and is incomplete. Initial development is being performed on Windows 2012 R2. 
