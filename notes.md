# Progress

## 2019-04-19 11:38

```
{
  cis_level_1 => {
    version => "cis_windows_2012r2_member_server_2.3.0",
    percent_compliant => 13.1868,
    percent_implemented => 27.1062,
    number_compliant => 36,
    number_noncompliant => 36,
    number_unknown => 0,
    number_unimplemented => 199,
    number_exceptions => 2,
    number_controls => 273,
    controls => {
      compliant => {
        1_1_1 => {

# first unimplemented:          

        2_2_5 => {
          compliancy => "unimplemented",
          state => "*S-1-5-19,*S-1-5-20,*S-1-5-32-544",
          title => "(L1) Ensure 'Adjust memory quotas for a process' is set to 'Administrators, LOCAL SERVICE, NETWORK S
ERVICE'",
          message => "No comparitor supplied",
          debug_data => {
            params => {
              title => "(L1) Ensure 'Adjust memory quotas for a process' is set to 'Administrators, LOCAL SERVICE, NETWO
RK SERVICE'",
              type => "ensure_policy_value",
              policy => "Adjust memory quotas for a process",
              comparitor => ,
              operator => "==",
              and_not_zero => false,
              comparitor_loose => "Administrators, LOCAL SERVICE, NETWORK SERVICE"
            }
          }
        },
```

be less restrictive about comparitors - basically try allowing everything through. Now I need to split up the comparitor so the arrays of users can be compared for equality...

```
        2_2_5 => {
          compliancy => "noncompliant",
          state => "*S-1-5-19,*S-1-5-20,*S-1-5-32-544",
          title => "(L1) Ensure 'Adjust memory quotas for a process' is set to 'Administrators, LOCAL SERVICE, NETWORK S
ERVICE'",
          debug_data => {
            params => {
              title => "(L1) Ensure 'Adjust memory quotas for a process' is set to 'Administrators, LOCAL SERVICE, NETWO
RK SERVICE'",
              type => "ensure_policy_value",
              policy => "Adjust memory quotas for a process",
              comparitor => "Administrators, LOCAL SERVICE, NETWORK SERVICE",
              operator => "==",
              and_not_zero => false,
              comparitor_loose => "Administrators, LOCAL SERVICE, NETWORK SERVICE"
            },
            comparitor => "Administrators, LOCAL SERVICE, NETWORK SERVICE",
            comparitor_typed => "Administrators, LOCAL SERVICE, NETWORK SERVICE",
            actual_policy_value => "*S-1-5-19,*S-1-5-20,*S-1-5-32-544",
            actual_policy_value_typed => [
              "*S-1-5-19",
              "*S-1-5-20",
              "Administrators"
            ]
          }
        },
```

also eg: 

```
        2_2_13 => {
          compliancy => "noncompliant",
          state => "*S-1-5-19,*S-1-5-20,*S-1-5-32-544,*S-1-5-6",
          title => "(L1) Ensure 'Create global objects' is set to 'Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVI
CE'",
          debug_data => {
            params => {
              title => "(L1) Ensure 'Create global objects' is set to 'Administrators, LOCAL SERVICE, NETWORK SERVICE, S
ERVICE'",
              type => "ensure_policy_value",
              policy => "Create global objects",
              comparitor => "Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE",
              operator => "==",
              and_not_zero => false,
              comparitor_loose => "Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE"
            },
            comparitor => "Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE",
            comparitor_typed => "Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE",
            actual_policy_value => "*S-1-5-19,*S-1-5-20,*S-1-5-32-544,*S-1-5-6",
            actual_policy_value_typed => [
              "*S-1-5-19",
              "*S-1-5-20",
              "Administrators",
              "*S-1-5-6"
            ]
          }
        },
```

15:45 now we have the current status and first couple of unimplemented:

```
{
  cis_level_1 => {
    version => "cis_windows_2012r2_member_server_2.3.0",
    percent_compliant => 17.2161,
    percent_implemented => 32.6007,
    number_compliant => 47,
    number_noncompliant => 32,
    number_unknown => 0,
    number_unimplemented => 184,
    number_exceptions => 10,
    number_controls => 273,
    controls => {
      compliant => {
```

```
      unimplemented => {
        2_2_2 => {
          compliancy => "unimplemented",
          state => ,
          title => "(L1) Configure 'Access this computer from the network'",
          message => "I only know how to evaluate controls with specific values. Type found: 'ensure_some_configuration"
,
          debug_data => {
            params => {
              title => "(L1) Configure 'Access this computer from the network'",
              type => "ensure_some_configuration",
              policy => "Access this computer from the network",
              comparitor => ,
              operator => ,
              and_not_zero => false,
              comparitor_loose =>
            }
          }
        },
        2_2_7 => {
          compliancy => "unimplemented",
          state => ,
          title => "(L1) Configure 'Allow log on through Remote Desktop Services'",
          message => "I only know how to evaluate controls with specific values. Type found: 'ensure_some_configuration"
,
          debug_data => {
            params => {
              title => "(L1) Configure 'Allow log on through Remote Desktop Services'",
              type => "ensure_some_configuration",
              policy => "Allow log on through Remote Desktop Services",
              comparitor => ,
              operator => ,
              and_not_zero => false,
              comparitor_loose =>
            }
          }
```

Oh, so here the automatic parsing falls down as the value to set to differs between member server and domain controller:

```
2.2.2:
  'section #': '2.2'
  'recommendation #': 2.2.2
  title: "(L1) Configure 'Access this computer from the network'"
  status: accepted
  scoring status: full
  description: |-
    This policy setting allows other users on the network to connect to the computer and is required by various network protocols that include Server Message Block (SMB)-based protocols, NetBIOS, Common Internet File System (CIFS), and Component Object Model Plus (COM+).

    - **Level 1 - Domain Controller.** The recommended state for this setting is: `Administrators, Authenticated Users, ENTERPRISE DOMAIN CONTROLLERS`.
    - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators, Authenticated Users`.
```

and

```
2.2.7:
  'section #': '2.2'
  'recommendation #': 2.2.7
  title: "(L1) Configure 'Allow log on through Remote Desktop Services'"
  status: accepted
  scoring status: full
  description: |-
    This policy setting determines which users or groups have the right to log on as a Remote Desktop Services client. If your organization uses Remote Assistance as part of its help desk strategy, create a group and assign it this user right through Group Policy. If the help desk in your organization does not use Remote Assistance, assign this user right only to the `Administrators` group or use the Restricted Groups feature to ensure that no user accounts are part of the `Remote Desktop Users` group.

    Restrict this user right to the `Administrators` group, and possibly the `Remote Desktop Users` group, to prevent unwanted users from gaining access to computers on your network by means of the Remote Assistance feature.

    - **Level 1 - Domain Controller.** The recommended state for this setting is: `Administrators`.
    - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators, Remote Desktop Users`.
```

So, how to deal with this? Need to override the definition that the csv injestion script generates for this control to include the actual specifics for the specific benchmark. Urgh.

Could do this automatically, eg search for lines matching `**Level 1 - Member Server.** The recommended state for this setting is: ` in the description: 

```
**Level 1 - Member Server.** The recommended state for this setting is: `Administrators, Authenticated Users`.
```


```

To summarise all the controls that need to be treated in this manner: 

- 2.2.2 - see above
- 2.2.7 - see above
- 2.2.15 - "(L1) Configure 'Create symbolic links'"
```
    - **Level 1 - Domain Controller.** The recommended state for this setting is: `Administrators`.
    - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators` and (when the _Hyper-V_ Role is installed) `NT VIRTUAL MACHINE\Virtual Machines`.
- 2.2.17 - "(L1) Configure 'Deny access to this computer from the network'"
```
    - **Level 1 - Domain Controller.** The recommended state for this setting is to include: `Guests`.
    - **Level 1 - Member Server.** The recommended state for this setting is to include: `Guests, Local account and member of Administrators group`.
```
- 2.2.21 - "(L1) Configure 'Deny log on through Remote Desktop Services'"
```
    - **Level 1 - Domain Controller.** The recommended state for this setting is: `Guests`.
    - **Level 1 - Member Server.** The recommended state for this setting is: `Guests, Local account`.
```
- 2.2.22 - "(L1) Configure 'Enable computer and user accounts to be trusted for delegation'"
```
    - **Level 1 - Domain Controller.** The recommended state for this setting is: `Administrators`.

    - **Level 1 - Member Server.** The recommended state for this setting is: `No One`.
```
- 2.2.25 - "(L1) Configure 'Impersonate a client after authentication'"
```
    - **Level 1 - Domain Controller.** The recommended state for this setting is: ``Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE``.
    - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE` and (when the _Web Server (IIS)_ Role with _Web Services_ Role Service is installed) `IIS_IUSRS`.
```
- 2.2.30 - "(L1) Configure 'Manage auditing and security log'"
```
    - **Level 1 - Domain Controller.** The recommended state for this setting is: `Administrators` and (when Exchange is running in the environment) `Exchange Servers`.
    - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators`.
```

## Perhaps not a security policy?

Next problem is this kind of thing:

```
        2_3_1_3 => {
          compliancy => "unimplemented",
          state => ,
          title => "(L1) Ensure 'Accounts: Guest account status' is set to 'Disabled' (MS only)",
          message => "No policy named 'Accounts: Guest account status' in SecurityPolicy - perhaps not a security policy
?",
          debug_data => {
            params => {
              title => "(L1) Ensure 'Accounts: Guest account status' is set to 'Disabled' (MS only)",
              type => "ensure_policy_value",
              policy => "Accounts: Guest account status",
              comparitor => "Disabled",
              operator => "==",
              and_not_zero => false,
              comparitor_loose => "Disabled"
            }
          }
        },
```
But it's in the lookup in SecurityPolicy as 'EnableGuestAccount'

https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/accounts-guest-account-status

- FIXED by correcting the mapping in security_policy.rb


```
        2_3_1_5 => {
          compliancy => "unimplemented",
          state => ,
          title => "(L1) Configure 'Accounts: Rename administrator account'",
          message => "I only know how to evaluate controls with specific values. Type found: 'ensure_some_configuration"
,
          debug_data => {
            params => {
              title => "(L1) Configure 'Accounts: Rename administrator account'",
              type => "ensure_some_configuration",
              policy => "Accounts: Rename administrator account",
              comparitor => ,
              operator => ,
              and_not_zero => false,
              comparitor_loose =>
            }
          }
        },
```

How does one know what the policy key names as spat out by secedit corresopnd to as group policy paths / names? Eg the above is NewGuestName according to SecurityPolicy but where does one look that up? 

Anyhow, this one needs the key NewGuestName to be checked that exists and is set to something other than 'Administrator'. Where to configure this rule? Similar issue to the 8 above. Maybe it's enough just to check that this policy has been set to anything? Then this could be automated and generalised. 

Similarly: 
- 2.3.1.6 - (L1) Configure 'Accounts: Rename guest account'
- 2.3.7.4 - (L1) Configure 'Interactive logon: Message text for users attempting to log on'
- 2.3.7.5 - (L1) Configure 'Interactive logon: Message title for users attempting to log on'
- 2.3.10.6 - (L1) Configure 'Network access: Named Pipes that can be accessed anonymously'
- 2.3.10.7 - (L1) Configure 'Network access: Remotely accessible registry paths'
- 2.3.10.8 - (L1) Configure 'Network access: Remotely accessible registry paths and sub-paths'


Here's another policy not recognised: 'Network security: Allow Local System to use computer identity for NTLM' 

```
        2_3_11_1 => {
          compliancy => "unimplemented",
          state => ,
          title => "(L1) Ensure 'Network security: Allow Local System to use computer identity for NTLM' is set to 'Enab
led'",
          message => "No policy named 'Network security: Allow Local System to use computer identity for NTLM' in Securi
tyPolicy - perhaps not a security policy?",
          debug_data => {
```

Actually that one turned out to be a typo in SecurityPolicy lookup table, s/All/Allow/

But the next one seems to be just completely missing from the lookup table in SecurityPolicy.

```
        2_3_11_2 => {
          compliancy => "unimplemented",
          state => ,
          title => "(L1) Ensure 'Network security: Allow LocalSystem NULL session fallback' is set to 'Disabled'",
          message => "No policy named 'Network security: Allow LocalSystem NULL session fallback' in SecurityPolicy - p
rhaps not a security policy?",
          debug_data => {
            params => {
              title => "(L1) Ensure 'Network security: Allow LocalSystem NULL session fallback' is set to 'Disabled'",
              type => "ensure_policy_value",
              policy => "Network security: Allow LocalSystem NULL session fallback",
              comparitor => "Disabled",
              operator => "==",
              and_not_zero => false,
              comparitor_loose => "Disabled"
            }
          }
        },
```

Checking on accuracy this one looks suspect as the NT SERVICE\WdiServiceHost SID is not being translated in the code (yet).

```
        2_2_35 => {
          compliancy => "compliant",
          state => [
            "Administrators",
            "*S-1-5-80-3139157870-2983391045-3678747466-658725712-1809340420"
          ],
          title => "(L1) Ensure 'Profile system performance' is set to 'Administrators, NT SERVICE\WdiServiceHost'"
        },
```

Attemping to run the fact on Windows 2016 datacentre, by relaxing the constraint in the fact, I get this error: 

```
PS E:\> facter --custom-dir .\modules\os_compliance\lib\facter os_compliance --no-color --trace
2019-04-23 17:33:25.521835 ERROR puppetlabs.facter - error while resolving custom fact "os_compliance": SeDelegateSessionUserImpersonatePrivilege is not a valid policy
backtrace:
E:/modules/os_compliance/lib/puppet_x/lsp/security_policy.rb:222:in `find_mapping_from_policy_name'
E:/modules/os_compliance/lib/puppet_x/secedit.rb:48:in `block in get_policies'
E:/modules/os_compliance/lib/puppet_x/inifile.rb:226:in `block (2 levels) in each'
E:/modules/os_compliance/lib/puppet_x/inifile.rb:225:in `each'
E:/modules/os_compliance/lib/puppet_x/inifile.rb:225:in `block in each'
E:/modules/os_compliance/lib/puppet_x/inifile.rb:224:in `each'
E:/modules/os_compliance/lib/puppet_x/inifile.rb:224:in `each'
E:/modules/os_compliance/lib/puppet_x/secedit.rb:41:in `get_policies'
E:/modules/os_compliance/lib/facter/os_compliance.rb:32:in `block (2 levels) in <top (required)>'
```

Looks like this is a new policy in 2016, need to research it so it can be added, or perhaps it does not feature in CIS L1 for 2016, not sure. For now I will skip this policy. 

## Windows 2012 unimplemented analysis: 

15 - "unhandled_type:ensure_some_configuration"
3 - 'unhandled_type:snowflake'
164 - invalid_policy

Breaking down invalid_policy a bit:

26 - invalid_policy:Windows Firewall*
23 - invalid_policy:Audit *

## Settings that depend on whether services are enabled: 

Use a separate fact to report on the relevant services? (All services?)

I think there's only the one of these:

```
2.3.10.6:
  'section #': 2.3.10
  'recommendation #': 2.3.10.6
  title: "(L1) Configure 'Network access: Named Pipes that can be accessed anonymously'"
  ...
      - **Level 1 - Member Server.** The recommended state for this setting is: `` (i.e. None), or (when the legacy _Computer Browser_ service is enabled) `BROWSER`
```

## Settings that depend on whether a role is installed:

```
2.2.15:
  'section #': '2.2'
  'recommendation #': 2.2.15
  title: "(L1) Configure 'Create symbolic links'"
  ...
    # - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators` and (when the _Hyper-V_ Role is installed) `NT VIRTUAL MACHINE\Virtual Machines`.
```

## Settings that depend on a role and role service being installed 

```
2.2.25:
  'section #': '2.2'
  'recommendation #': 2.2.25
  title: "(L1) Configure 'Impersonate a client after authentication'"
  ...
    - **Level 1 - Member Server.** The recommended state for this setting is: `Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE` and (when the _Web Server (IIS)_ Role with _Web Services_ Role Service is installed) `IIS_IUSRS`.
```

After doing the deep operator and comparitor detection we have 35% implemented, with 176 unimplemented. Previously there was 33.3% implemented, with 182 unimplemented. 

## 2019-04-28 19:17

```yaml
    os_compliance:
      cis_level_1:
        version: cis_windows_2012r2_member_server_2.3.0
        percent_compliant: 14.65201465201465
        percent_implemented: 35.53113553113553
        number_compliant: 40
        number_noncompliant: 57
        number_unknown: 0
        number_unimplemented: 176
        number_exceptions: 0
        number_controls: 273
```

however some of the newly implemented ones are incorrect eg: 

```yaml
            2_2_30:
              compliancy: noncompliant
              state: "*S-1-5-32-544"
              title: (L1) Configure 'Manage auditing and security log'
              debug_data:
                params:
                  title: (L1) Configure 'Manage auditing and security log'
                  type: ensure_policy_value
                  policy: Manage auditing and security log
                  comparitor: Administrators
                  operator: ==
                  and_not_zero: false
                  comparitor_loose: "`Administrators`"
                  deep_operator: is
                  deep_comparitor: "`Administrators`"
                comparitor: Administrators
                comparitor_typed: Administrators
                actual_policy_value: "*S-1-5-32-544"
                actual_policy_value_typed: Administrators
                deep_operator: is
                deep_comparitor: "`Administrators`"
```

OK fixed a logic problem with string equality, now we have:

```
        percent_compliant: 17.94871794871795
        percent_implemented: 35.53113553113553
        number_compliant: 49
        number_noncompliant: 48
        number_unknown: 0
        number_unimplemented: 176
        number_exceptions: 0
        number_controls: 273
```

Next issue: 'No one' comes up as an empty policy setting so needs to be allowed, eg this one is actually compliant: 

```
            2_2_1:
              compliancy: noncompliant
              state: ~
              title: (L1) Ensure 'Access Credential Manager as a trusted caller' is set to 'No One'
              message: The security policy 'Access Credential Manager as a trusted caller' has no value.
              debug_data:
                params:
                  title: (L1) Ensure 'Access Credential Manager as a trusted caller' is set to 'No One'
                  type: ensure_policy_value
                  policy: Access Credential Manager as a trusted caller
                  comparitor: No One
                  operator: ==
                  and_not_zero: false
                  comparitor_loose: No One
                  deep_operator: ~
                  deep_comparitor: ~
```

seem to have introduced the following exceptions: 

```
      exception:
        1_2_1:
          compliancy: exception
          state: ~
          title: (L1) Ensure 'Account lockout duration' is set to '15 or more minute(s)'
          message: "NoMethodError - undefined method `>=' for nil:NilClass"
        1_2_3:
          compliancy: exception
          state: ~
          title: (L1) Ensure 'Reset account lockout counter after' is set to '15 or more minute(s)'
          message: "NoMethodError - undefined method `>=' for nil:NilClass"
        2_3_7_3:
          compliancy: exception
          state: ~
          title: "(L1) Ensure 'Interactive logon: Machine inactivity limit' is set to '900 or fewer second(s), but not 0'"
          message: "NoMethodError - undefined method `<=' for nil:NilClass"
```

Fixed. Now we have 2.2.7 and probably others 

```
        2_2_7:
          compliancy: noncompliant
          state: "*S-1-5-32-544,*S-1-5-32-555"
          message: comparitor is a String but actual value is not (it's a Array), or the downcased strings do not match
          title: (L1) Configure 'Allow log on through Remote Desktop Services'
          debug_data:
            params:
              title: (L1) Configure 'Allow log on through Remote Desktop Services'
              type: ensure_policy_value
              policy: Allow log on through Remote Desktop Services
              comparitor: Administrators, Remote Desktop Users
              operator: ==
              and_not_zero: false
              comparitor_loose: "`Administrators, Remote Desktop Users`"
              deep_operator: is
              deep_comparitor: "`Administrators, Remote Desktop Users`"
            comparitor: Administrators, Remote Desktop Users
            comparitor_typed: Administrators, Remote Desktop Users
            actual_policy_value: "*S-1-5-32-544,*S-1-5-32-555"
            actual_policy_value_typed:
              - Administrators
              - Remote Desktop Users
            deep_operator: is
            deep_comparitor: "`Administrators, Remote Desktop Users`"
```

2019-06-21

There are 180 controls that are unimplemented because of "invalid_policy". Here's the first one: 

```
        2_3_10_11:
          compliancy: unimplemented
          state: ~
          title: "(L1) Ensure 'Network access: Restrict clients allowed to make remote calls to SAM' is set to 'Administrators: Remote Access: Allow' (MS only)"
          unimplemented_reason: "invalid_policy:Network access: Restrict clients allowed to make remote calls to SAM"
          message: "No policy named 'Network access: Restrict clients allowed to make remote calls to SAM' in SecurityPolicy - perhaps not a security policy?"
          debug_data:
            params:
              title: "(L1) Ensure 'Network access: Restrict clients allowed to make remote calls to SAM' is set to 'Administrators: Remote Access: Allow' (MS only)"
              unique_title: ensure_network_access_restrict_clients_allowed_to_make_remote_calls_to_sam_is_set_to_administrators_remote_access_allow_ms_only
              type: ensure_policy_value
              policy: "Network access: Restrict clients allowed to make remote calls to SAM"
              comparitor: "Administrators: Remote Access: Allow"
              operator: ==
              and_not_zero: false
              comparitor_loose: "Administrators: Remote Access: Allow"
              deep_operator: ~
              deep_comparitor: ~
              monitor: true
              enforce: false
```

Ok so the above is 2016 only. It is registry key lookup, the devsec inspec implements it as follows:

```ruby
  only_if('Only for Windows Server 2016, 2019 and if attribute(\'ms_or_dc\') is set to MS') do
    (((os[:name].include? '2016') || (os[:name].include? '2019')) && attribute('ms_or_dc') == 'MS')
  end
  describe registry_key('HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Lsa') do
    it { should have_property 'restrictremotesam' }
    its('restrictremotesam') { should eq 'O:BAG:BAD:(A;;RC;;;BA)' }
  end
```

https://github.com/dev-sec/windows-baseline/blob/master/controls/local_policies.rb


Current 
https://gist.github.com/jessereynolds/c0bb0e617052f930b677bd10d810e41d

How best to read this value? Is it in security manager or group policy or some such or should it be just a registry key read? 

Here's the whole detail from the CIS benchmark yaml: 

```yaml
2.3.10.11:
  'section #': 2.3.10
  'recommendation #': 2.3.10.11
  title: "(L1) Ensure 'Network access: Restrict clients allowed to make remote calls
    to SAM' is set to 'Administrators: Remote Access: Allow' (MS only)"
  status: published
  scoring status: full
  description: |-
    This policy setting allows you to restrict remote RPC connections to SAM.

    The recommended state for this setting is: `Administrators: Remote Access: Allow`.

    **Note:** A Windows 10 R1607, Server 2016 or newer OS is required to access and set this value in Group Policy.
  rationale statement: To ensure that an unauthorized user cannot anonymously list
    local account names or groups and use the information to attempt to guess passwords
    or perform social engineering attacks. (Social engineering attacks try to deceive
    users in some way to obtain passwords or some form of security information.)
  remediation procedure: |-
    To establish the recommended configuration via GP, set the following UI path to `Administrators: Remote Access: Allow`:

     ```
    Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network access: Restrict clients allowed to make remote calls to SAM
    ```
  audit procedure: |-
    Navigate to the UI Path articulated in the Remediation section and confirm it is set as prescribed. This group policy setting is backed by the following registry location:

     ```
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa:restrictremotesam
    ```
  impact statement: None - this is the default behavior.
  notes: 
  CIS controls: TITLE:Minimize And Sparingly Use Administrative Privileges CONTROL:5.1
    DESCRIPTION:Minimize administrative privileges and only use administrative accounts
    when they are required. Implement focused auditing on the use of administrative
    privileged functions and monitor for anomalous behavior.;TITLE:Limit Open Ports,
    Protocols, and Services CONTROL:9.1 DESCRIPTION:Ensure that only ports, protocols,
    and services with validated business needs are running on each system.;TITLE:Ensure
    Only Approved Ports, Protocols and Services Are Running CONTROL:9.2 DESCRIPTION:Ensure
    that only network ports, protocols, and services listening on a system with validated
    business needs, are running on each system.;
  CCE-ID: 
  references: 
```

Glenn: "Also note that secedit can do file and registry security and auditing settings, while GP can't. it's a venn diagram"

MS doc on the above control: https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-access-restrict-clients-allowed-to-make-remote-sam-calls

So by default this policy is not set, and therefore you do not see it in the output of secedit. Once it is set as prescribed you get the following line:

```
#secedit output:
MACHINE\System\CurrentControlSet\Control\Lsa\RestrictRemoteSAM=1,"O:BAG:BAD:(A;;RC;;;BA)"

#registry key and value:
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa:restrictremotesam

#use reg command over bolt to read registry key value
$ bolt command run 'reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictRemoteSAM' -n win2016
Started on windows2016cis.puppetdebug.vlan...
Finished on windows2016cis.puppetdebug.vlan:
  STDOUT:

    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa
        RestrictRemoteSAM    REG_SZ    O:BAG:BAD:(A;;RC;;;BA)
```

So `O:BAG:BAD:(A;;RC;;;BA)` is an SDDL - Security Descriptor of the Security Descriptor Definition Language - SDDL - https://en.wikipedia.org/wiki/Security_descriptor

`REG_SZ` is a registry value symbolic type name. It means a string value, normally stored and exposed in UTF-16LE.

https://en.wikipedia.org/wiki/Windows_Registry#Keys_and_values


I added the policy to security_policy.rb as follows:

```
            'Network access: Restrict clients allowed to make remote calls to SAM' => {
                :name => 'MACHINE\System\CurrentControlSet\Control\Lsa\RestrictRemoteSAM',
                :reg_type => '1',
                :policy_type => 'Registry Values',
            },
```

however this is now coming up as noncompliant due to a mismatch:

```
            2_3_10_11:
              compliancy: noncompliant
              state: "1,\"O:BAG:BAD:(A"
              message: comparitor is a String but actual value is not (it's a String), or the downcased strings do not match
              title: "(L1) Ensure 'Network access: Restrict clients allowed to make remote calls to SAM' is set to 'Administrators: Remote Access: Allow' (MS only)"
              debug_data:
                params:
                  title: "(L1) Ensure 'Network access: Restrict clients allowed to make remote calls to SAM' is set to 'Administrators: Remote Access: Allow' (MS only)"
                  unique_title: ensure_network_access_restrict_clients_allowed_to_make_remote_calls_to_sam_is_set_to_administrators_remote_access_allow_ms_only
                  type: ensure_policy_value
                  policy: "Network access: Restrict clients allowed to make remote calls to SAM"
                  comparitor: "Administrators: Remote Access: Allow"
                  operator: ==
                  and_not_zero: false
                  comparitor_loose: "Administrators: Remote Access: Allow"
                  deep_operator: ~
                  deep_comparitor: ~
                  monitor: true
                  enforce: false
                comparitor: "Administrators: Remote Access: Allow"
                comparitor_typed: "Administrators: Remote Access: Allow"
                actual_policy_value: "1,\"O:BAG:BAD:(A"
                actual_policy_value_typed: "1,\"O:BAG:BAD:(A"
```

Added handling in ensure_policy_value.rb to recognise a value like "1,somestring" which hasn't helped much:

```
                actual_policy_value: "1,\"O:BAG:BAD:(A"
                actual_policy_value_typed: "\"O:BAG:BAD:(A"
```

need to remove the escaping of the quotes and stuff. Hrm. 

Gave up and put in a dodgy regex to match this one, it is a one-off I think. 

OK, here's the next invalid policy one:

```
            2_3_11_2:
              compliancy: unimplemented
              state: ~
              title: "(L1) Ensure 'Network security: Allow LocalSystem NULL session fallback' is set to 'Disabled'"
              unimplemented_reason: "invalid_policy:Network security: Allow LocalSystem NULL session fallback"
              message: "No policy named 'Network security: Allow LocalSystem NULL session fallback' in SecurityPolicy - perhaps not a security policy?"
              debug_data:
                params:
                  title: "(L1) Ensure 'Network security: Allow LocalSystem NULL session fallback' is set to 'Disabled'"
                  unique_title: ensure_network_security_allow_localsystem_null_session_fallback_is_set_to_disabled
                  type: ensure_policy_value
                  policy: "Network security: Allow LocalSystem NULL session fallback"
                  comparitor: Disabled
                  operator: ==
                  and_not_zero: false
                  comparitor_loose: Disabled
                  deep_operator: ~
                  deep_comparitor: ~
                  monitor: true
                  enforce: false
```

https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-allow-localsystem-null-session-fallback

Location
Computer Configuration\Windows Settings\Security Settings\Local Policies\Security Options

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0:AllowNullSessionFallback

```
os_compliance $ bolt command run 'reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v allownullsessionfallback' -n win2016
Started on windows2016cis.puppetdebug.vlan...
Finished on windows2016cis.puppetdebug.vlan:
  STDOUT:

    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0
        allownullsessionfallback    REG_DWORD    0x1
```

Fixed by adding the policy to to security_policy.rb


Next one that's invalid:

```
            2_3_11_3:
              compliancy: unimplemented
              state: ~
              title: "(L1) Ensure 'Network Security: Allow PKU2U authentication requests to this computer to use online identities' is set to 'Disabled'"
              unimplemented_reason: "invalid_policy:Network Security: Allow PKU2U authentication requests to this computer to use online identities"
              message: "No policy named 'Network Security: Allow PKU2U authentication requests to this computer to use online identities' in SecurityPolicy - perhaps not a security policy?"
              debug_data:
                params:
                  title: "(L1) Ensure 'Network Security: Allow PKU2U authentication requests to this computer to use online identities' is set to 'Disabled'"
                  unique_title: ensure_network_security_allow_pku2u_authentication_requests_to_this_computer_to_use_online_identities_is_set_to_disabled
                  type: ensure_policy_value
                  policy: "Network Security: Allow PKU2U authentication requests to this computer to use online identities"
                  comparitor: Disabled
                  operator: ==
                  and_not_zero: false
                  comparitor_loose: Disabled
                  deep_operator: ~
                  deep_comparitor: ~
                  monitor: true
                  enforce: false
```

Location
Computer Configuration\Windows Settings\Security Settings\Local Policies\Security Options

   HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\pku2u:AllowOnlineID



os_compliance $ bolt command run 'reg query " HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" /v SupportedEncryptionTypes' -n win2016
Started on windows2016cis.puppetdebug.vlan...
Finished on windows2016cis.puppetdebug.vlan:
  STDOUT:

    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters
        SupportedEncryptionTypes    REG_DWORD    0x4


os_compliance $ bolt command run 'secedit /export /cfg secedit_dump.txt' -n win2016
Started on windows2016cis.puppetdebug.vlan...
Finished on windows2016cis.puppetdebug.vlan:
  STDOUT:

    The task has completed successfully.
    See log %windir%\security\logs\scesrv.log for detail info.
Successful on 1 node: windows2016cis.puppetdebug.vlan
Ran on 1 node in 0.85 seconds
os_compliance $ bolt command run 'cat secedit_dump.txt' -n win2016 | grep -i kerberos
    MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\SupportedEncryptionTypes=4,2147483640

wow. that's with the correct setting 'AES128_HMAC_SHA1, AES256_HMAC_SHA1, Future encryption types' - one huge number. 

