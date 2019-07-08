
# os_compliance

This module implements CIS benchmarks as a Puppet custom fact for reporting, and perhaps one day as Puppet classes for enforcement. Initial implementation is against Windows 2016 and 2012 R2.

# Custom Fact - os_compliance

This works by consuming a YAML file that represents the particular benchmark for the current OS version where a bunch of the interpretation of each control's recommendations has been codified and checking each one off against the output of secedit. The `tools/cis_injest_benchmark_csv.rb` script does the generation of this YAML benchmark description file.

There's still a fair way to go with this and at some point I will probably have to start writing ruby methods for individual controls rather than having a general approach all of the L1 controls. As at 19 April 2019 33% of the CIS L1 Member Server controls for Windows 2012 R2 are implemented.

Relevant pieces of the puzzle:

- script to generate the CIS benchmark description file - https://github.com/jessereynolds/puppet-os_compliance/blob/master/tools/cis_injest_benchmark_csv.rb
- resulting CIS benchmark description file for Windows 2012 R2 - https://github.com/jessereynolds/puppet-os_compliance/blob/master/lib/cis_windows_2012r2_member_server_2.3.0.yaml
- os_compliance custom fact - https://github.com/jessereynolds/puppet-os_compliance/blob/master/lib/facter/os_compliance.rb
- implementation of `ensure_policy_value` type controls - https://github.com/jessereynolds/puppet-os_compliance/blob/master/lib/puppet_x/controls/ensure_policy_value.rb

Example fact output (snipped for brevity):

```yaml

```

## Using bolt to test fact execution

The development environment I'm using consists of:

- MacBook Pro, MacOS Mojave
- VirtualBox 6.0
- Windows 2016 and Windows 2012 R2 VMs (etc)
- puppet bolt 1.23.0 (and counting)

Bolt can be used to remotely execute the custom fact while the module is mounted from my mac's filesystem:

```
bolt command run 'facter os_compliance --yaml --custom-dir \\vboxsrv\vagrant\modules\os_compliance\lib\facter > \\vboxsrv\vagrant\modules\os_compliance\example_fact_output\os_compliance-win2016.yaml' -n win2016
```

eg:

```
os_compliance $ bolt command run 'facter os_compliance --yaml --custom-dir \\vboxsrv\vagrant\modules\os_compliance\lib\facter > \\vboxsrv\vagrant\modules\os_compliance\example_fact_output\os_compliance-win2016-debug.yaml' -n win2016
Started on windows2016cis.puppetdebug.vlan...
Finished on windows2016cis.puppetdebug.vlan:
Successful on 1 node: windows2016cis.puppetdebug.vlan
Ran on 1 node in 2.48 seconds
```

My bolt inventory includes machine aliases win2012 and win2016:

```
os_compliance $ cat ~/.puppetlabs/bolt/inventory.yaml
---
groups:
  - name: win
    groups:
      - name: win2016
        nodes:
          - windows2016cis.puppetdebug.vlan
      - name: win2012
        nodes:
          - jessewins.puppetdebug.vlan
    config:
      transport: winrm
      winrm:
        user: Administrator
        password: xxxxxxxx
        connect-timeout: 10
        ssl: false

nodes:
  - name: jessewins.puppetdebug.vlan
    config:
      winrm:
        user: vagrant
        password: vagrant
```

## Acknowledgements

Props to Paul Cannon, Adam Yohrling and Brett Gray for their respective work on:

- https://forge.puppet.com/ayohrling/local_security_policy
- https://forge.puppet.com/cannonps/local_security_policy
- https://github.com/beergeek/cis

And others who've made various inroads on CIS benchmark implementations with Puppet.

## Limitations

This module is in active development and is incomplete. Initial development is being performed on Windows 2012 R2.
