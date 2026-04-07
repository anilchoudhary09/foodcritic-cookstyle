# Barclays Foodcritic Rules

These are the evolving foodcritic rules we've written here at Barclays to enforce rules on our cookbooks. These rules are to help ensure that any cookbook that goes to production:

1. Does not do anything that will break our infrastructure.
2. Follows our cookbook development standard.

These rules are expected to run while one is developing a cookbook. Thus, a cookbook developer will get feedback on whether she is breaking a rule much early in the lifecycle and will fix any violation while she is writing the cookbook. When the cookbook reaches the final review, most problems should have already been detected and fixed. This will help to reduce both the the rejection rate and effort in the final manual review, hence, help to shorten the cookbook development cycle.

---

# 🆕 Cookstyle Migration (Modern Approach)

Foodcritic is **deprecated** and no longer maintained. We have migrated all BARC rules to **Cookstyle** (RuboCop-based linting).

## Quick Start - One Command

```bash
# Install dependencies (one time)
bundle install

# Run ALL checks (standard Cookstyle + custom BARC rules)
cookstyle .

# Auto-fix correctable issues
cookstyle --autocorrect .

# Check a specific cookbook
cookstyle /path/to/your/cookbook

# JSON output for CI/CD
cookstyle --format json --out report.json .

# HTML report
cookstyle --format html --out report.html .
```

## What You Get

Running `cookstyle .` validates against:

| Category | Description |
|----------|-------------|
| **200+ Cookstyle Rules** | Modern Chef best practices, deprecations, security |
| **BARC001-BARC019** | Custom organization security policies |
| **Auto-correction** | Many violations can be auto-fixed |
| **Multiple Formats** | Progress, JSON, HTML, JUnit for CI/CD |

## Custom BARC Rules (Cookstyle)

| Rule | Severity | Description |
|------|----------|-------------|
| `Barclays/Barc001NoLocalUsers` | Error | No local user manipulation |
| `Barclays/Barc002NoLocalGroups` | Error | No local group manipulation |
| `Barclays/Barc003NoRootSsh` | Error | No root .ssh manipulation |
| `Barclays/Barc005EtcBlacklist` | Error | Protected /etc files |
| `Barclays/Barc006NoReboot` | Error | No reboot/shutdown commands |
| `Barclays/Barc007NoSelinux` | Error | No SELinux manipulation |
| `Barclays/Barc008NoKillProcess` | Warning | No kill/renice commands |
| `Barclays/Barc009NoFirewall` | Error | No firewall manipulation |
| `Barclays/Barc011NoRemoveFiles` | Warning | No rm -rf patterns |
| `Barclays/Barc016UseChefResources` | Convention | Prefer Chef resources |
| `Barclays/Barc017NoSystemServices` | Error | Protected system services |
| `Barclays/Barc019NoFindSudo` | Error | No dangerous patterns |

## Directory Structure

```
b-cookstyle-rules/
├── .rubocop.yml              # Main config - loads custom cops
├── Gemfile                   # Dependencies (cookstyle)
├── rules.rb                  # Legacy Foodcritic rules (deprecated)
├── test_recipe.rb            # Sample recipe to test violations
│
└── lib/
    ├── rubocop/cop/
    │   ├── barclays_cops.rb  # Entry point - loads all cops
    │   └── barclays/         # Custom BARC cops
    │       ├── base.rb
    │       ├── barc001_no_local_users.rb
    │       ├── barc002_no_local_groups.rb
    │       └── ... (more cops)
    │
    └── data/                 # Whitelist configurations
        ├── platform_cookbooks.yml
        ├── services.yml
        └── etc_whitelist.yml
```

## Using in Your Cookbook

**No `.rubocop.yml` needed!** Just run cookstyle with `--config` flag:

```bash
# From your cookbook directory
cookstyle . --config ../b-cookstyle-rules/.rubocop.yml

# With auto-fix
cookstyle . --config ../b-cookstyle-rules/.rubocop.yml --autocorrect

# JSON output for CI/CD
cookstyle . --config ../b-cookstyle-rules/.rubocop.yml --format json --out report.json

# From anywhere (absolute path)
cookstyle /path/to/cookbook --config /path/to/b-cookstyle-rules/.rubocop.yml
```

This loads:
- ✅ All 200+ Cookstyle Chef best practices
- ✅ All BARC001-BARC019 security rules
- ✅ Exception handling from rules.rb

## CI/CD Integration (Jenkins)

```groovy
pipeline {
    agent any
    stages {
        stage('Lint') {
            steps {
                sh 'cookstyle cookbooks/${COOKBOOK} --config cookbooks/b-cookstyle-rules/.rubocop.yml --format json --out report.json'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'report.json'
        }
    }
}
```

---

# Legacy Usage (Foodcritic - Deprecated)


Once you've cloned the repo, you can run foodcritic using the following options to test your cookbooks against these rules:

````
foodcritic -t barc -f security -I <path/to/rules.rb> cookbooks
````
You should make sure that *\<path/to/rules.rb\>* is replaced with the location of the rules.rb file in this repo.

# Regression testing for BARC foodcritic rules

There are three sets of rspec tests:
1. Rules are checked with Rubocop using customized ````.rubocop_todo.yml```` file.
2. Specially crafted cookbook ````b-foodcritic-violator```` with test cases breaking and passing all Barclays Foodcritic rules..
3. Set of different cookbooks from production in repository ````b-foodcritic-regression```` with known failures.

Both repositories are hosted in GitLab:
* https://ldndsr000005612.intranet.barcapint.com/chef/b-foodcritic-violator/
* https://ldndsr000005612.intranet.barcapint.com/chef/b-foodcritic-regression/tree/master/cookbooks

Regression testing jobs are in Rakefile. Run with:
````
rake -v
````

More @ https://confluence.barcapint.com/display/UNIX/Barclays+Foodcritic+Regression+checks

# Rules

## BARC001 - Do not manipulate users locally, use Active Directory instead

````barc```` ````unix```` ````windows```` ````security````

As a best practice, users should be managed via Active Directory. Using Active Directory makes managing user leaving easier, among many other benefits. Any form of attempts to manipulate users locally is not allowed, including:
* Using user resource
* Using execute, bash, script, or service to execute any of the following commands
  * useradd
  * usermod
  * userdel
  * passwd
  * net user
  *.create("user")


For example, the following blocks would trip this rule:

Adding a user using the user resource
````
user 'lchen' do
  action :create
end
````

Using execute resource to run useradd (three variations)
````
# useradd as resoure name
execute 'useradd lchen' do
  action :run
end

# useradd in the command attribute
execute 'use command attribute for useradd' do
  command 'useradd lchen'
end

# Full path to useradd in the command attribute
execute 'use full path to useradd in command attribute' do
  command '/bin/useradd lchen'
end
````

Adding a user using the bash resource
````
bash 'Executing command (useradd) in bash' do
  code <<-EOH
    useradd lchen
    EOH
end
````

Adding a user using the script resource
````
script 'Executing useradd with script' do
  interpreter "bash"
  code <<-EOH
    useradd lchen
    EOH
end
````
Adding a user using the bash resource
````
batch 'Create new user' do
  code <<-EOH
  md C:\user\iamnew
  Net User iamnew SecretPass01 /add /passwordreq:yes /fullname:"New User"
  EOH
end
````

Adding a user using the powershell_script resource
````
powershell_script 'Create local user' do
  code <<-EOH
  $ADSIComp = [adsi]"WinNT://localhost"
  $Username = 'app_user'
  $NewUser = $ADSIComp.CREATE('User',$Username)
  EOH
end
````

Using the passwd command to change a user's password
````
script 'Changing password of user lchen' do
  interpreter "bash"
  code <<-EOH
    echo -e "new_password\nnew_password" | (passwd --stdin lchen)
    EOH
end
````

Even hack with the service resource
````
service 'useradd in init_command' do
  init_command 'useradd lchen'
  action :start
end
````
## BARC002 - Do not manipulate groups locally, use Active Directory instead

````barc```` ````unix```` ````windows```` ````security````

As a best practice, groups should be managed via Active Directory. Any form of attempts to manipulate groups locally is not allowed, including:
* Using group resource
* Using execute, bash, script, or service to execute any of the following commands
  * groupadd
  * groupmod
  * groupdel
  * net group
  * net localgroup
  * .create('group')

For example, the following blocks would trip this rule:

Adding a group using the group resource
````
group 'lchen' do
  action :create
end
````

Using execute resource to run groupadd (three variations)
````
# groupadd as resoure name
execute 'groupadd lchen' do
  action :run
end

# groupadd in the command attribute
execute 'use command attribute for groupadd' do
  command 'groupadd lchen'
end

# Full path to groupadd in the command attribute
execute 'use full path to groupadd in command attribute' do
  command '/bin/groupadd lchen'
end
````

Adding a group using the bash resource
````
bash 'Executing command (groupadd) in bash' do
  code <<-EOH
    groupadd lchen
    EOH
end
````

Adding a group using the batch resource
````
batch 'Create new local group' do
  code <<-EOH
  NET GROUP Group1 /ADD
  EOH
end
````

Adding a group using the powershell_script resource
````
powershell_script 'Create local group' do
  code <<-EOH
  $cn = [ADSI]"WinNT://localhost"
  $group = $cn.Create("Group","mygroup")
  $group.setinfo()
  $group.description = "Test group"
  $group.SetInfo()
  EOH
end
````

Adding a group using the script resource
````
script 'Executing groupadd with script' do
  interpreter "bash"
  code <<-EOH
    groupadd lchen
    EOH
end
````

Even hack with the service resource
````
service 'groupadd in init_command' do
  init_command 'groupadd lchen'
  action :start
end
````

## BARC003 - Do not manipulate any file in .ssh for root user

````barc```` ````security````

For security reason, modification of ssh keys, known_hosts, authorized_keys for root user is forbidden. This rule detects the attempts to make such modifications using any of the below chef resources:

* file
* template
* remote_file
* cookbook_file
* remote_directory
* directory

For example, any of the following blocks should trip this rule:

Chaning root user's private key using file (two variations)
````
file '/root/.ssh/id_rsa' do
  action :create
  content 'AMALICIOUSPRIVATEKEY'
end

file 'private key' do
  action :create
  content 'AMALICIOUSPRIVATEKEY'
  path '/root/.ssh/id_rsa'
end
````

Transferring a remote file to use as root's private key (two variations)
````
remote_file '/root/.ssh/id_rsa' do
  source 'http://somesite.com/id_rsa'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

remote_file 'download private key' do
  source 'http://somesite.com/id_rsa'
  path '/root/.ssh/id_rsa'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
````

Copying a file from cookbook to use a root's private key (two variations)
````
cookbook_file '/root/.ssh/id_rsa' do
  source 'id_rsa'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file 'override root private key' do
  source 'ntp.conf'
  path '/root/.ssh/id_rsa'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
````

Overriding root's private key with a file that is generated using chef template (two variations)
````
template '/root/.ssh/id_rsa' do
  source 'id_rsa.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template 'private key for root from template' do
  source 'id_rsa.erb'
  path '/root/.ssh/id_rsa'
  owner 'root'
  group 'root'
  mode '0755'
end
````

Transfering a directory from the cookbook to override /root/.ssh (two variations)
````
remote_directory '/root/.ssh' do
  source '.ssh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

remote_directory 'copy .ssh to root' do
  source '.ssh'
  path '/root/.ssh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
````

Changing permission of /root/.ssh (two variations)
````
directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

directory 'let every user modify /root/.ssh' do
  path '/root/.ssh'
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end
````

## BARC004 - Don't manipulate ssh keys for any user

````barc```` ````security````

This rule will alert on manipulations of ssh keys for any user. We are going to introduce a tool for centrally managing SSH keys. When this tool is introduced, we will make this rule to fail the build for any violation detected.

Attempts to modify any of the following types of keys will be captured:

* private key
* public key
* authorized_keys

However, modification to known_hosts is allowed.

Similar to the above rule, this rule detects the attempts to make ssh key modifications using any of the below chef resources:

* file
* template
* remote_file
* cookbook_file
* remote_directory
* directory

This rule also checks the use of the following commands in execute, bash, script, and service resources.
* ssh-keygen
* ssh-add

For example, the following blocks would trip this rule.

Manapulating a user's private key (two variations)
````
file '/users/unix/chelianp/.ssh/id_rsa' do
  action :create
  content 'AMALICIOUSPRIVATEKEY'
end

file 'private key for chelianp' do
  action :create
  content 'AMALICIOUSPRIVATEKEY'
  path '/users/unix/chelianp/.ssh/id_rsa'
end
````

Transferring a file from a remote location to /users/unix/chelianp/.ssh (two variations)
````
remote_file '/users/unix/chelianp/.ssh/id_rsa' do
  source 'http://somesite.com/id_rsa'
  owner 'chelianp'
  group 'chelianp'
  mode '0755'
  action :create
end

remote_file 'download private key for chelianp' do
  source 'http://somesite.com/id_rsa'
  path '/users/unix/chelianp/.ssh/id_rsa'
  owner 'chelianp'
  group 'chelianp'
  mode '0755'
  action :create
end
````

Copying a file to /users/unix/chelianp/.ssh (two variations)
````
cookbook_file '/users/unix/chelianp/.ssh/id_rsa' do
  source 'id_rsa'
  owner 'chelianp'
  group 'chelianp'
  mode '0755'
  action :create
end

cookbook_file 'override private key for chelianp' do
  source 'ntp.conf'
  path '/users/unix/chelianp/.ssh/id_rsa'
  owner 'chelianp'
  group 'chelianp'
  mode '0755'
  action :create
end
````

Overriding /users/unix/chelianp/.ssh/id_rsa with a file that is generated using chef template (two variations)
````
template '/users/unix/chelianp/.ssh/id_rsa' do
  source 'id_rsa.erb'
  owner 'chelianp'
  group 'chelianp'
  mode '0755'
end

template 'private key for chelianp from template' do
  source 'id_rsa.erb'
  path '/users/unix/chelianp/.ssh/id_rsa'
  owner 'chelianp'
  group 'chelianp'
  mode '0755'
end
````

Transfer a directory from a cookbook to /users/unix/chelianp/.ssh (two variations)
````
remote_directory '/users/unix/chelianp/.ssh' do
  source '.ssh'
  owner 'chelianp'
  group 'chelianp'
  mode '0755'
  action :create
end

remote_directory 'copy .ssh to chelianp home directory' do
  source '.ssh'
  path '/users/unix/chelianp/.ssh/id_rsa'
  owner 'chelianp'
  group 'chelianp'
  mode '0755'
  action :create
end
````

Changing permission of /users/unix/chelianp/.ssh (two variations)
````
directory '/users/unix/chelianp/.ssh' do
  owner 'chelianp'
  group 'chelianp'
  mode '0777'
  action :create
end

directory 'let every user modify /users/unix/chelianp/.ssh' do
  path '/users/unix/chelianp/.ssh/id_rsa'
  owner 'chelianp'
  group 'chelianp'
  mode '0777'
  action :create
end
````
Making a new key for a user
````
execute 'Generating a new key for user chelianp' do
  command 'ssh-keygen -t dsa -f /users/unix/chelianp/.ssh/id_dsa'
end
````

It is OK to modify known_hosts for a non-root user, so the following blocks would not trip this rule.

````
file '/users/unix/chelianp/.ssh/known_hosts' do
  action :create
  content '1.1.18.15 ssh-rsa AAAAB3NzaC1yc2EBBBBBIwAAAQEApxo85CBrTx7f+dX08XaBOhfVZ9RDrMREzqPIiAUPhUpxz+KuEpWy7nqabNYv15zogSK9Lg2xyJVJrRSzU2MlioORO3b787WRDy8S05g3v0nByfOOwM5TcTaHVuFjcGzdgacqQfnQxG1qkWqBZW1fFfLbTfLa1j98U2IrFg4EYsR7hxvR2MwTzfKMGCpHYoEI1B3BM3WZ1c+gnEJus0IE3DJPlCyAOpRpndraOSGMeoG/SJ6Uev7Udwauhg7USHJBW7yeHEbzUVZlF4m1zUW4CFbMSzSRXt9rMcbg/qen3K2Xql8k9WesX7HTe+XhQ3gmJEpwn3tCCy4uLevgU4WYsQ=='
end

file 'known_hosts for chelianp' do
  action :create
  content '1.1.18.15 ssh-rsa AAAAB3NzaC1yc2EBBBBBIwAAAQEApxo85CBrTx7f+dX08XaBOhfVZ9RDrMREzqPIiAUPhUpxz+KuEpWy7nqabNYv15zogSK9Lg2xyJVJrRSzU2MlioORO3b787WRDy8S05g3v0nByfOOwM5TcTaHVuFjcGzdgacqQfnQxG1qkWqBZW1fFfLbTfLa1j98U2IrFg4EYsR7hxvR2MwTzfKMGCpHYoEI1B3BM3WZ1c+gnEJus0IE3DJPlCyAOpRpndraOSGMeoG/SJ6Uev7Udwauhg7USHJBW7yeHEbzUVZlF4m1zUW4CFbMSzSRXt9rMcbg/qen3K2Xql8k9WesX7HTe+XhQ3gmJEpwn3tCCy4uLevgU4WYsQ=='
  path '/users/unix/chelianp/.ssh/known_hosts'
end
````
## BARC005 - Do not manipulate any existing file or directory in the /etc blacklist

````barc```` ````security````

Any attempts to manipulate any file or directory in the /etc blacklist are forbidden.

This rule detects attempts to create, delete, modify files or directories in the /etc blacklist using any of the following chef resources.

* file
* template
* remote_file
* cookbook_file
* remote_directory
* directory

For example, the following blocks would trip this rule when manipulating any files or directories in the /etc blacklist.

Manapulating a file in the blacklist
````
file '/etc/hosts' do
  action :create
  content '127.0.0.1       localhost'
end

file 'etc hosts' do
  action :create
  content '127.0.0.1       localhost'
  path '/etc/hosts'
end
````

Overriding /etc/motd with a file that is generated using chef template
````
template '/etc/motd' do
  source 'motd.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template 'parameterized motd' do
  source 'motd.erb'
  path '/etc/motd'
  owner 'root'
  group 'root'
  mode '0755'
end
````

Changing permission of a directory in the /etc blacklist
````
directory '/etc/pam.d' do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

directory 'let every user modify pam.d' do
  path '/etc/pam.d'
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end
````
## BARC005a - Do not use attributes to manipulate any file or directory in the /etc blacklist

````barc```` ````security````

References to paths present in the etc/ blacklist are not allowed. The following would trip this rule.

Specify a blacklisted path in an attribute
````
default['cookbook']['naughty-etc-path'] = '/etc/ssh/'
````
## BARC006 - Do not halt, shutdown, reboot, or poweroff a node

````barc```` ````unix```` ````windows```` ````security````

Halt, shutdown, reboot, or poweroff a node is not allowed. This rule detects the use of any of the following commands in a cookbook.
* halt
* shutdown
* reboot
* poweroff
* systemctl shutdown
* systemctl poweroff
* systemctl halt
* systemctl reboot
* stop-computer
* restart-computer

The rule scans the use of these commands in any of the following chef resources
* execute
* bash
* script
* service
* batch
* powershell_script

The rule also detects the use of reboot chef resource.

For example, the following blocks would trip this rule.

Reboot a node with the reboot chef resource
````
reboot 'app_requires_reboot' do
  action :request_reboot
  reason 'Need to reboot when the run completes successfully.'
  delay_mins 5
end
````
Using execute resource to run shutdown (three variations)
````
# shutdown as resoure name
execute 'shutdown' do
  action :run
end

# shutdown in the command attribute
execute 'use command attribute for shutdown' do
  command 'shutdown'
end

# Full path to shutdown in the command attribute
execute 'use full path to shutdown in command attribute' do
  command '/bin/shutdown'
end
````
Using bash resource to execute shutdown
````
bash 'Executing shutdown in bash' do
  code <<-EOH
    shutdown
    EOH
end
````
Using the script resource to execute shutdown
````
script 'Executing shutdown with script' do
  interpreter "bash"
  code <<-EOH
    shutdown
    EOH
end
````
Using shutdown as stop_command of a service
````
service 'shutdown in stop_command' do
  stop_command 'shutdown'
  action :stop
end
````
## BARC007 - Do not manipulate SELinux

````barc```` ````security````

Changing SELinux configurations is forbidden. This rule detects attempts to manipulate SELinux configurations using any of the following commands.
* chcon
* semanage
* setenforce
* setsebool
* togglesebool
* setfiles

The rule examines the use of the above commands in all of the following chef resources.
* execute
* bash
* script
* service

For example, the following blocks would trip this rule.

Make SELinux to run in the enforcing mode by using the execute resource (three variations)
````
# setenforce as resoure name
execute 'setenforce enforcing' do
  action :run
end

# setenforce in the command attribute
execute 'use command attribute for setenforce' do
  command 'setenforce enforcing'
end

# Full path to setenforce in the command attribute
execute 'use full path to setenforce in command attribute' do
  command '/usr/sbin//setenforce enforcing'
end
````
Make SELinux to run in the enforcing mode by using the bash resource
````
bash 'Executing command setenforce in bash' do
  code <<-EOH
    setenforce enforcing
    EOH
end
````
Make SELinux to run in the enforcing mode by using the script resource
````
script 'Executing setenforce with script' do
  interpreter "bash"
  code <<-EOH
    setenforce enforcing
    EOH
end
````
Hack SELinux configuration in service
````
service 'setenforce in start_command' do
  start_command 'setenforce'
  action :start
end
````
## BARC008 - Do not kill or change the priority of a process

````barc```` ````unix```` ````windows```` ````security````

Kill a process with any of the following commands is not allowed.
* kill
* pkill
* killall
* killall5
* pskill
* taskkill

Runing a program with modified scheduling priority is forbidden. So, any of the following commands should not be used in a cookbook.
* nice
* renice

This rule detects the use of the above commands in all of the following chef resources.
* execute
* bash
* script
* service
* batch
* powershell_script

For example, the following blocks would trip this rule.

Using execute resource to give grep a high priority in process scheduling (three variations)
````
# nice as resoure name
execute 'nice --4 grep' do
  action :run
end

# nice in the command attribute
execute 'use command attribute for nice' do
  command 'nice --4 grep'
end

# Full path to nice in the command attribute
execute 'use full path to nice in command attribute' do
  command '/usr/bin/nice --4 grep'
end
````
Executing kill with a bash resource
````
bash 'kill all descendant processes' do
  code <<-EOH
    list_descendants ()
    {
      local children=$(ps -o pid= --ppid "$1")

      for pid in $children
      do
        list_descendants "$pid"
      done

      echo "$children"
    }
    kill $(list_descendants $$)
    EOH
end
````
Executing kill using the script resource
````
script 'kill all descendant processes' do
  interpreter "bash"
  code <<-EOH
    list_descendants ()
    {
      local children=$(ps -o pid= --ppid "$1")

      for pid in $children
      do
        list_descendants "$pid"
      done

      echo "$children"
    }
    kill $(list_descendants $$)
    EOH
end
````
Executing taskkill using the batch resource
````
batch 'Close SEP' do
  code <<-EOH
  TASKKILL ccsvchst
  EOH
end
````
Hack with the init_command in a service
````
service 'nice in init_command' do
  init_command 'nice --4 grep'
  action :start
end
````

## BARC009 - Do not manipulate firewalls

````barc```` ````unix```` ````windows```` ````security````

To ensure security, compliance, and accessibility, manipulating firewalls is forbidden. This rule detects the use of any of the following commands for changing firewall.
* firewall-cmd
* firewall-config
* iptables
* netsh firewall
* netsh advfirewall
* set-netfirewall
* set-netipsec
* disable-netfirewall
* disable-netipsec
* enable-netipsec
* new-netfirewall
* remove-netfirewall

This rule checks the manipulation of firewalls with all of the following chef resources.
* execute
* bash
* script
* service
* batch
* powershell_script

For example, the following block would trip this rule.

Start iptables with service resource
````
service 'iptables' do
  action :start
end
````
Deleting (flushing) all the iptables rules using execute resource (three variations)
````
# iptables as resoure name
execute 'iptables -F' do
  action :run
end

# iptables in the command attribute
execute 'use command attribute for iptables' do
  command 'iptables -F'
end

# Full path to iptables in the command attribute
execute 'use full path to iptables in command attribute' do
  command '/bin/iptables -F'
end
````
Deleting (flushing) all the iptables rules using the bash resource
````
bash 'Executing command (iptables) in bash' do
  code <<-EOH
    iptables -F
    EOH
end
````
Create firewall rule using batch resource
````
batch 'Create firewall rule for myapp' do
  code <<-EOH
  netsh firewall add allowedprogram program=C:\MyApp\MyApp.exe name="My Application" mode=ENABLE scope=CUSTOM addresses=157.60.0.1,172.16.0.0/16,LocalSubnet profile=Domain
  EOH
end
````
Deleting (flushing) all the iptables rules using the script resource
````
script 'Executing iptables with script' do
  interpreter "bash"
  code <<-EOH
    iptables -F
    EOH
end
````
Or hacking with the init_command of a service resource to open a range of ports
````
service 'iptables in init_command' do
  init_command 'iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 7000:7010 -j ACCEPT'
  action :start
end
````
## BARC010 - Do not use init or telinit

````barc```` ````security````

Don't use init or telinit to change the runlevel or process control initialization. This rule detects the use of these two commands in all of the following chef resources.
* execute
* bash
* script
* service

For example, the following blocks would trip this rule.

Switch to single user mode using execute resource (three variations)
````
# telinit as resoure name
execute 'telinit S' do
  action :run
end

# telinit in the command attribute
execute 'use command attribute for telinit' do
  command 'telinit S'
end

# Full path to telinit in the command attribute
execute 'use full path to telinit in command attribute' do
  command '/sbin/telinit S'
end
````

Switch to single user mode using the bash resource
````
bash 'Executing command (telinit) in bash' do
  code <<-EOH
    telinit S
    EOH
end
````
Switch to single user mode using the script resource
````
script 'Executing telinit with script' do
  interpreter "bash"
  code <<-EOH
    telinit S
    EOH
end
````
Even hacking with the reload_command of the service resource
````
service 'chaning to single user mode with reload_command' do
  reload_command 'telinit S'
  action :reload
end
````
## BARC011 - Do not remove files/directories, or convert and copy a file

````barc```` ````unix```` ````windows```` ````security````

For security concerns, removing files or directories from the operating system is forbidden. This rule detects the use of *rm*, *rmdir*, or *dd* and DOS/Powershell commands in all of the following resources.
* execute
* bash
* script
* service
* batch
* powershell_script

For example, the following blocks would trip this rule.

Delete everything using the execute resource (three variations)
````
# rm as resoure name
execute 'rm -rf /' do
  action :run
end

# rm in the command attribute
execute 'use command attribute for rm' do
  command 'rm -rf /'
end

# Full path to rm in the command attribute
execute 'use full path to rm in command attribute' do
  command '/bin/rm -rf /'
end
````
Delete everything using the bash resource
````
bash 'Executing command (rm) in bash' do
  code <<-EOH
    rm -rf /
    EOH
end
````
Delete everything using the script resource
````
script 'Executing rm with script' do
  interpreter "bash"
  code <<-EOH
    rm -rf /
    EOH
end
````
Delete file using the batch resource
````
batch 'Delete a file' do
  code <<-EOH
  del c:\temp\file.txt
  EOH
end
````
Or hacking with the init_command of the service resource
````
service 'remove everything' do
  init_command 'rm -rf /'
  action :start
end
````
## BARC012 - Do not manipulate the Linux Kernel

````barc```` ````security````

Manipulating the Linux kernel is strictly forbidden. This rule detects any attempts to use any of the following commands to interfere the Linux Kernel.
* kexec
* sysctl
* modprobe
* insmod
* rmmod

This rules scans the following chef resources for violations.
* execute
* bash
* script
* service

As examples, the following blocks would trip this rule.

Remove the md5 module from the Linux Kernel using execute resource (three variations)
````
# rmmod as resoure name
execute 'rmmod md5' do
  action :run
end

# rmmod in the command attribute
execute 'use command attribute for rmmod' do
  command 'rmmod md5'
end

# Full path to rmmod in the command attribute
execute 'use full path to rmmod in command attribute' do
  command '/sbin/rmmod md5'
end
````

Remove the md5 module from the Linux Kernel using the bash resource
````
bash 'Executing command (rmmod) in bash' do
  code <<-EOH
    rmmod md5
    EOH
end
````

Remove the md5 module from the Linux Kernel using the script resource
````
script 'Executing rmmod with script' do
  interpreter "bash"
  code <<-EOH
    rmmod md5
    EOH
end
````
Hacking with the stop_command of the service resource will also be caught
````
service 'rmmod in stop_command' do
  stop_command 'rmmod md5'
  action :stop
end
````
## BARC013 - Do not manipulate volumes, partitions, and devices of the file system

````barc```` ````unix```` ````windows```` ````security````

To protect our infrastructure, manipulating volumes, partitions, and devices is not allowed. This rule checks the use of any of the following commands in a cookbook.
* lvremove
* pvremove
* vgremove
* mkfs
* wipefs
* umount
* mount
* delpart
* addpart
* partx
* kpartx
* parted
* partprobe
* fdisk
* fsck
* diskpart
* format
* clear-disk
* new-partition
* remove-partition
* remove-physicaldisk
* set-partition

This rule scans the use of the above commands from all below chef resources.
* execute
* bash
* script
* service
* batch
* powershell_script

For example, the following blocks would trip this rule.

Mount a remote file system with the mount resource
````
mount '/export/www' do
  device 'nas1prod:/export/web_sites'
  fstype 'nfs'
  options 'rw'
end
````
Erase all signatures from the device /dev/sdb using the execute resource (three variations)
````
# wipefs as resoure name
execute 'wipefs --all /dev/sdb' do
  action :run
end

# wipefs in the command attribute
execute 'use command attribute for wipefs' do
  command 'wipefs --all /dev/sdb'
end

# Full path to wipefs in the command attribute
execute 'use full path to wipefs in command attribute' do
  command '/sbin/wipefs --all /dev/sdb'
end
````
Erase all signatures from the device /dev/sdb using the bash resource
````
bash 'Executing wipefs in bash' do
  code <<-EOH
    wipefs --all /dev/sdb
    EOH
end
````
Erase all signatures from the device /dev/sdb using the script resource
````
script 'Executing wipefs with script' do
  interpreter "bash"
  code <<-EOH
    wipefs --all /dev/sdb
    EOH
end
````
Attempt to create new partition using the powershell_script resource
````
powershell_script 'Create new partition' do
  code <<-EOH
    New-Partition -DiskNumber 1
    EOH
end
````
We will also catch it even if you hack it with command attribute of the service resource
````
service 'wipefs in reload_command' do
  reload_command 'wipefs --all /dev/sdb'
  action :reload
end
````
## BARC014 - Do not manipulate network

````barc```` ````unix```` ````windows```` ````security````

Do not manipulate network of the node, e.g., bring up/down an network interface, changing routing table, updating network configuration. Doing these could possibly break our infrastructure. This rule detects attempts to use any of the following commands to modify the network.
* ifup
* ifdown
* ip
* ifcfg
* ifconfig
* ifenslave
* ethtool
* route
* netsh
* set-net

This rule scans the violations from all of the following chef resources.
* execute
* bash
* script
* service
* batch
* powershell_script

For example, the following blocks would trip this rule.

Configure a network interface
````
ifconfig "33.33.33.80" do
  bootproto "dhcp"
  device "eth1"
end
````
Changing the system routing table
````
route '10.0.1.10/32' do
  gateway '10.0.0.20'
  device 'eth1'
end
````
Change the speed of Ethernet device using execute (three variations)
````
# ethtool as resoure name
execute 'ethtool -s eth0 speed 100 autoneg off' do
  action :run
end

# ethtool in the command attribute
execute 'use command attribute for ethtool' do
  command 'ethtool -s eth0 speed 100 autoneg off'
end

# Full path to ethtool in the command attribute
execute 'use full path to ethtool in command attribute' do
  command '/sbin/ethtool -s eth0 speed 100 autoneg off'
end
````
Change the speed of Ethernet device using bash
````
bash 'Executing ethtool in bash' do
  code <<-EOH
    ethtool -s eth0 speed 100 autoneg off
    EOH
end
````
Configure IP address for the adapter with powershell resource
````
batch 'Configure IP address of the adapter' do
  code <<-EOH
  Set-NetIPAddress –InterfaceIndex 12 –IPAddress 192.168.0.1
  EOH
end
````
Change the speed of Ethernet device using script
````
script 'Executing ethtool with script' do
  interpreter "bash"
  code <<-EOH
    ethtool -s eth0 speed 100 autoneg off
    EOH
end
````
Hack the change with service resource
````
service 'hack the eth configure with init_command' do
  init_command 'ethtool -s eth0 speed 100 autoneg off'
  action :start
end
````
## BARC015 - Do not manipulate cron jobs

````barc```` ````security````

Modifying cron jobs is not allowed. This rule checks the use of chef *cron* resource. It also checks the use of *crontab* command in all of the following chef resources.
* execute
* bash
* script
* service

This rule also detects the attempts to modifying crontabs by modifying files under /var/spool/cron, using any of the following chef resources.
* file
* template
* remote_file
* cookbook_file
* remote_directory
* directory

For example, the following blocks would trip this rule.

Manage cron entries for time-based job scheduling
````
cron 'cookbooks_report' do
  action node.tags.include?('cookbooks-report') ? :create : :delete
  minute '0'
  hour '0'
  weekday '1'
  user 'getchef'
  mailto 'sysadmin@example.com'
  home '/srv/supermarket/shared/system'
  command %W{
    cd /srv/supermarket/current &&
    env RUBYLIB="/srv/supermarket/current/lib"
    RAILS_ASSET_ID=`git rev-parse HEAD` RAILS_ENV="#{rails_env}"
    bundle exec rake cookbooks_report
  }.join(' ')
end
````
Remove the current crontab using execute resource (three variations)
````
# crontab as resoure name
execute 'crontab -r' do
  action :run
end

# crontab in the command attribute
execute 'use command attribute for crontab' do
  command 'crontab -r'
end

# Full path to crontab in the command attribute
execute 'use full path to crontab in command attribute' do
  command '/usr/bin/crontab -r'
end
````
Remove the current crontab using the bash resource
````
bash 'Executing crontab in bash' do
  code <<-EOH
    crontab -r
    EOH
end
````
Remove the current crontab using the script resource
````
script 'Executing crontab with script' do
  interpreter "bash"
  code <<-EOH
    crontab -r
    EOH
end
````
Hack with the stop_command of the service resource
````
service 'crontab in stop_command' do
  stop_command 'crontab -r'
  action :stop
end
````
Modification of root crontab by modifying /var/spool/cron/root (two variations)
````
file '/var/spool/cron/root' do
  action :create
  content '1 1 * * * /etc/puppet/bin/puppet-exec.sh'
end

file 'root crontab' do
  action :create
  content '1 1 * * * /etc/puppet/bin/puppet-exec.sh'
  path '/var/spool/cron/root'
end
````
Copying a crontab file from a remote location to /var/spool/cron/root (two variations)
````
remote_file '/var/spool/cron/root' do
  source 'http://somesite.com/cron/root'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

remote_file 'download a crontab for root' do
  source 'http://somesite.com/cron/root'
  path '/var/spool/cron/root'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
````
Copying a file from cookbook to /var/spool/cron/root (two variations)
````
cookbook_file '/var/spool/cron/root' do
  source 'ntp.conf'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file 'override root crontab' do
  source 'cron/root'
  path '/var/spool/cron/root'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
````
Overriding /var/spool/cron/root with a file that is generated using chef template (two variations)
````
template '/var/spool/cron/root' do
  source 'motd.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template 'Overriding root crontab' do
  source 'motd.erb'
  path '/var/spool/cron/root'
  owner 'root'
  group 'root'
  mode '0755'
end
````
Transfer a directory from a cookbook to /var/spool/cron/ (two variations)
````
remote_directory '/var/spool/cron/' do
  source 'cron'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

remote_directory 'copying crontabs over' do
  source 'cron'
  path '/var/spool/cron/'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
````

## BARC016 - Do not use service or yum command, use the corresponding chef resource instead

````barc```` ````style````

Chef provides built-in resources named service and package. It is suggested to use these chef built-in resources rather than using the service or yum command in bash, execute, or script.

For example, the following blocks would trip this rule.

Using service command in execute resource to restart tomcat (three variations)
````
# service as resoure name
execute 'service tomcat restart' do
  action :run
end

# service in the command attribute
execute 'use command attribute for service' do
  command 'service tomcat restart'
end

# Full path to service in the command attribute
execute 'use full path to service in command attribute' do
  command '/sbin/service tomcat restart'
end
````
Using service command in the bash resource to restart tomcat
````
bash 'Executing service in bash' do
  code <<-EOH
    service tomcat restart
    EOH
end
````
Using service command in the script resource to restart tomcat
````
script 'Executing service with script' do
  interpreter "bash"
  code <<-EOH
    service tomcat restart
    EOH
end
````

The following blocks would not trip this rule. They are recommended to use.

Starting tomcat with the service resource
````
service 'tomcat' do
  action :start
end
````

Installing apache with the package resource
````
package 'httpd' do
  action :install
  version '2.4'
end
````

## BARC017 - Do not manipulate system services

````barc```` ````unix```` ````windows```` ````security````

To protect our infrastructure, manipulating system services is not allowed. The following is a list of services that this rule checks.
* mdmonitor
* messagebus
* multipathd
* rpc.mountd
* nfsd
* rpc.rquotad
* rpc.statd
* nscd
* nslcd
* ntpd
* numad
* oddjobd
* ifdhandler
* pcscd
* portreserve
* quota_nld
* rdisc
* rngd
* rpcbind
* rpc.gssd
* rpc.idmapd
* rpc.svcgssd
* rsyslogd
* sandbox
* saslauthd
* sendmail
* sm-client
* smartd
* snmpd
* snmptrapd
* openssh-daemon
* sssd
* tcsd
* trace-cmd
* tuned
* uuidd
* vasd
* winbindd
* xinetd
* ypbind
* named
* dhcpd
* sshd
* network
* galaxy
* gmond
* vsftpd
* smb
* besclient
* eventsystem
* galaxywdsagent
* galaxycore
* policyagent
* eventlog
* rpcss
* samss
* winmgmt
* splunkforwarder
* sepmasterservice
* winrm
* netlogon
* ccmexec
* schedule
* mpssvc

This rule scans all of the following chef resources for violations.
* service
* execute
* bash
* script
* windows_service
* batch
* powershell_script

For example, the following blocks would trip this rule.

Restarting dhcp service
````
service 'dhcpd' do
  action :restart
end
````
Using execute resource to run chkconfig to enable dhcpd (three variations)
````
# chkconfig as resoure name
execute 'chkconfig dhcpd on' do
  action :run
end

# chkconfig in the command attribute
execute 'use command attribute for chkconfig' do
  command 'chkconfig dhcpd on'
end

# Full path to chkconfig in the command attribute
execute 'use full path to chkconfig in command attribute' do
  command '/sbin/chkconfig dhcpd on'
end
````
Using bash resource to execute chkconfig to enable dhcpd
````
bash 'Executing command (chkconfig) in bash' do
  code <<-EOH
    chkconfig dhcpd on
    EOH
end
````
Using powershell_script resource change startup type for SPLUNK
````
powershell_script 'Set splunkforwarder to Manual' do
  code <<-EOH
    Set-Service splunkforwarder -startuptype Manual
    EOH
end
````
Using the script resource to execute chkconfig to enable dhcpd
````
script 'Executing chkconfig with script' do
  interpreter "bash"
  code <<-EOH
    chkconfig dhcpd on
    EOH
end
````
## BARC018 - Please review this service

````barc```` ````svc````

We are maintaining a blacklist and a whitelist of services. If you use any service in the blacklist, it will be caught by rule BARC017. If you use any service in the whitelist, you will not get any message from foodcritic. If you use a service not in any of the two lists, you will receive this message. Please speak to ChefSupport to review your service and add it to one of the lists.

This rule scans all of the following chef resources for violations.
* service
* execute
* bash
* script

For example, the following blocks would trip this rule.

Starting the newsvc with service resource
````
service 'newsvc' do
  action :restart
end
````
````
service 'newsvc' do
  service_name "newsvc-#{node['type']}"
  action :restart
end
````
````
service "newsvc-#{node['type']}" do
  action :restart
end
````
Using execute resource to run chkconfig to enable newsvc (three variations)
````
# chkconfig as resoure name
execute 'chkconfig newsvc on' do
  action :run
end

# chkconfig in the command attribute
execute 'use command attribute for chkconfig' do
  command 'chkconfig newsvc on'
end

# Full path to chkconfig in the command attribute
execute 'use full path to chkconfig in command attribute' do
  command '/sbin/chkconfig newsvc on'
end
````
Using bash resource to execute chkconfig to enable newsvc
````
bash 'Executing command (chkconfig) in bash' do
  code <<-EOH
    chkconfig newsvc on
    EOH
end
````
Using the script resource to execute chkconfig to enable newsvc
````
script 'Executing chkconfig with script' do
  interpreter "bash"
  code <<-EOH
    chkconfig newsvc on
    EOH
end
````

## BARC019 - Do not use find and sudo

````barc```` ````security````

When executing on a file system that is nearly full, *find* could slow the whole system down. Because chef-client is run as root, there is no need to use *sudo*.

This rule detects the use of these two comments in all of the below chef resources.
* execute
* bash
* script
* service

For example, the following blocks would trip this rule.

Using execute resource to run find (three variations)
````
# find as resoure name
execute 'find / -name *.rb' do
  action :run
end

# find in the command attribute
execute 'use command attribute for find' do
  command 'find / -name *.rb'
end

# Full path to find in the command attribute
execute 'use full path to find in command attribute' do
  command '/bin/find / -name *.rb'
end
````
Using bash resource to execute find
````
bash 'Executing command find in bash' do
  code <<-EOH
    find / -name *.rb
    EOH
end
````
Using the script resource to execute find
````
script 'Executing find with script' do
  interpreter "bash"
  code <<-EOH
    find / -name *.rb
    EOH
end
````

## BARC020 - Do not use fuser, setfacl, wall, smbclient

````barc```` ````security````

Using the following commands in a cookbook is not allowed.
* fuser
* setfacl
* wall
* smbclient

This rule detects the use of these commands in all of the below chef resources.
* execute
* bash
* script
* service

For example, the following blocks would trip this rule.

Kill all processes using file ‘socket_serv’ by execute resource (three variations)
````
# fuser as resoure name
execute 'fuser -v -k socket_serv' do
  action :run
end

# fuser in the command attribute
execute 'use command attribute for fuser' do
  command 'fuser -v -k socket_serv'
end

# Full path to fuser in the command attribute
execute 'use full path to fuser in command attribute' do
  command '/sbin/fuser -v -k socket_serv'
end
````

Using bash resource to kill all processes using file ‘socket_serv’
````
bash 'Executing fuser in bash' do
  code <<-EOH
    fuser -v -k socket_serv
    EOH
end
````
Using the script resource to kill all processes using file ‘socket_serv’
````
script 'Executing fuser with script' do
  interpreter "bash"
  code <<-EOH
    fuser -v -k socket_serv
    EOH
end
````
Or hack with command attribute of a service resource
````
service 'fuser in stop_command' do
  stop_command 'fuser -v -k socket_serv'
  action :stop
end
````

## BARC021 - Specify the exact version in cookbook dependency

````barc```` ````security````

When use dependency in a cookbook, an exact version should be specified, as shown below.

````
depends 'java', '= 1.0'
````

The following blocks would trip this rule, because an exact version is not specified.

````
depends 'b-java', '> 2.0'
````
````
depends 'yum', '<= 1.0'
````
````
depends 'rubygems', '~> 1.0'
````
````
depends 'tomcat'
````
````
%w{foo bar baz}.each do |cbk|
  depends cbk, '< 2.0'
end
````
````
%w{ntp jboss}.each do |cbk|
  depends cbk, '>= 2.0'
end
````
````
%w{apache linux}.each do |cbk|
  depends cbk
end
````

We mark this rule as security because if we do not specify an exact version, when a new non-backward compatible version of a cookbook is released to prod, the new version of that cookbook could break our nodes.

## BARC022 - Do not force chef-client exit, this stops other recipes

````barc```` ````security````

When recipe uses below statements, it forces chef-client to quit.
````
Chef::Application.fatal!
raise
````

This breaks other recipes and node converge. Recipes should use return and dependent recipes must always check their requirements.
Examples that will be detected:

````
Chef::Application.fatal!("User not found")
````
````
Chef::Log.fatal("\'#{node[instance]['group']}\' group has not been defined")
raise
````

## BARC023 - Please specify the cookbook supported platform by providing "supports" setting in the metadata

````barc```` ````metadata````

The cookbook supported platform should be specified, as shown below:

````
supports 'redhat'
````

Multiple supported platforms should be specified, as shown below:

````
supports 'redhat'
supports 'aix'
supports 'windows'
````

If no platform is specified, the rule will be tripped

## BARC024 - Please specify valid maintainer, maintainer_email and source_url in the metadata

````barc```` ````metadata````

Cookbook metadata requirements for maintenance and Chef Supermarket - must contain valid maintainer, maintainer_email and source_url values.

Put valid name or team for `maintainer`, valid (team) email for `maintainer_email`.

Cookbook `source_url` must be http(s) and contain cookbook name in the url.

````
maintainer 'ChefSupport'
maintainer_email 'ChefSupport@barclayscorp.com'
source_url 'https://stash.barcapint.com:8443/projects/IS_CHEF_CKBKS/repos/is-unixeng-demo-dev-demoworld/browse'
````

If metadata entry is missing or invalid, the rule will be tripped.

## BARC025 - Only use whitelisted node tags

````barc```` ````security````

Node tags are being used to exclude certain actions within infrastructure base cookbook recipes.

If nodes need to be tagged as part of a cookbook recipe then the use of the tag(s) needs to be whitelisted for the cookbook in question.  This would need to be added to:

````
@tag_whitelist = {
  'mycookbook' => ['mytag1', 'mytag2']
}
````

To use an approved tag in your recipe specify one tag per line:

````
tag('mytag1')
````

Please use above approach to apply a tag and DO NOT specify multiple tags at the same time, use whitespace separated arrays, or tags in loops and defined by attributes/variables, e.g.:

````
tag('mytag1', 'mytag2')

tag %w(mytag1 mytag2)

['mytag1', 'mytag2'].each do |mytag|
  tag(mytag)
end
````


## BARC026 - Do not use node.save method, this updates OHAI timestamp before full run list has run

````barc```` ````windows````

Saving a node within a recipe is not allowed

## BARC027 - Only approved cookbooks can deploy Middleware owned software

````barc```` ````middleware```` ````unix````

Only cookbooks authorised by Middleware can deploy Middleware owned software.

If you are unclear as to why your cookbook is tripping this rule, please reach out to Middleware.
* BCHAT Channel: Middleware_SelfService_Cookbook_and_Image_Advice

**The tables below list the current BARC027 constraints:**

Restricted Middleware software packages |
---- |
ACE- |
BCwlserver |
BarcJBoss |
BarcJBossUtils |
BarcMW_DaffyLinux |
BarcMW_IBMIM |
BarcMW_IBMSDS |
BarcMW_ISDSLinux |
BarcMW_P2PFT_Sender |
BarcMW_WAS7 |
BarcMW_apachekafka_2_12 |
BarcMW_apachekafka_2_13 |
BarcMW_was7 |
BarcMW_was855 |
IIB- |
MQSeries |
amq- |
corporate_digital_nginx_srv |
BarcPaas-wily-epaagent-binaries-openshift10 |
jq |
httpd |
idsldap-license64 |
iibsbin |
is-mw-cd_unix-build |
jboss-a-mq |
jboss-fuse |
jws5-tomcat |
mod_security |
mod_ssl |
msgBin |
msgSbin |
msgsecexits |
msgssl |
nginx-plus |
qmaccess |
tomcat |




Approved Middleware cookbooks which can deploy Middleware software |
---- |
chef-openshift3_enterprise |
cookbook-openshift3 |
corporate_digital_nginx_srv |
is-apaaseng-osev3-b-openshift3_enterprise |
is-mw-apachehttpd-build |
is-mw-cd_unix-build |
is-mw-jboss6-build |
is-mw-tomcat-build |
is_apaas_openshift_cookbook |
is_apaasengosev3_bopenshift3enterprise_dev |
is_apaasengosev3_bopenshift3enterprise_devuat |
is_apaasengosev3_bopenshift3enterprise_pilot |
is_apaasengosev3_bopenshift3enterprise_scripts |
is_mw_ace_build |
is_mw_activemq_build |
is_mw_amq7_build02 |
is_mw_apachehttpd_build2018 |
is_mw_apachekafka_build02 |
is_mw_daffyforlinux_build |
is_mw_fuse_build |
is_mw_iib10_build |
is_mw_jboss6_build2018 |
is_mw_jboss7_build02 |
is_mw_jwstomcat9_build02 |
is_mw_mq91_build02 |
is_mw_mq9_echannel |
is_mw_mq_build |
is_mw_nginx_build |
is_mw_nginx_main |
is_mw_p2pftlinux_build |
is_mw_sds_build |
is_mw_sds_build2018 |
is_mw_tomcat8_build2018 |
is_mw_tomcat_build2018 |
is_mw_was7_build |
is_mw_was8_build |
is_mw_weblogic_build |

**end of BARC027 tables**

## BARC028 - Only whitelisted cookbooks can depend on restricted cookbooks

````barc```` ````unix```` ````windows````

To make your cookbook restricted or to authorise cookbooks to use restricted cookbooks update restricted_cookbook_whitelist hash. For example:
```
@restricted_cookbook_whitelist = {
  'is_mw_tomcatdmz_build' => ['is_test_foodcritic_dmztomcat', #CHNG000xxxxxxx
                              'integration_ckbk']
}
```
Where is_mw_tomcatdmz_build is a restricted cookbook. is_test_foodcritic_dmztomcat and integration_ckbk cookbooks are whitelisted to depend on is_mw_tomcatdmz_build.
When adding restricted cookbooks or whitelisting a cookbook please provide a CR reference.

**The table below lists the current BARC028 constraints:**

Cookbook | Allowed contingent cookbooks
---- | ----
is_mw_tomcatdmz_build | is_test_foodcritic_dmztomcat, wealth_imst_fids_tomcat6, wealth_imst_bcfs_tomcat6, bi_wholesalelending_bookbuilder_externalportal, bi_wholesalelending_dealvault_externalportal, ib_tier4_tomcat_investorsolutions, cft_wps_tomcat_barxterms, cft_wps_tomcat_barxonline, integration_ckbk

**end of BARC028 table**

## BARC029 - Unauthorised access to community cookbook

````barc```` ````unix```` ````windows```` ````metadata````

Community cookbooks are imported by the IaC team "as is". Validation and restrictions are enforced by the appropriate "wrapper" cookbook. If there is functionality that is restricted and you require talk to the IaC team with your use case.

````Server - Engineering - IaC <ServerEngineeringIaC@barclayscorp.com>````


## BARC030 - Cookbook depends on a deprecated cookbook

````barc```` ````unix```` ````windows```` ````metadata````

Cookbook has a dependency on a dependent cookbook which has been flagged as deprecated, no longer supported or incompatible with the current version of Chef.

**The table below lists the current BARC030 constraints:**

Deprecated | Migration Path | Notes
---- | ---- | ----
b-java | b_iac_cc_java | incompatible with Chef 13 see link [Confluence link](https://confluence.barcapint.com/display/CHEFPL01/b_iac_cc_java+-+Management+of+JDK+or+JRE+on+Linux)
java | b_iac_cc_java | incompatible with Chef 13 see link [Confluence link](https://confluence.barcapint.com/display/CHEFPL01/b_iac_cc_java+-+Management+of+JDK+or+JRE+on+Linux)

**end of BARC030 table**

## BARC031 - Cookbook uses controlled packages

````barc```` ````unix````

Your cookbook is using a `package` resource which has been flagged as controlled and cannot be installed.
The package may be controlled for a number of reasons which include:

 - Audit and Security risks
 - Areas of responsibility - the package may be managed by a dedicated team which handle this area
 - Licensing

Typically a  [`library`](http://chefsupermarket/cookbooks?utf8=%E2%9C%93&q=&platforms%5B%5D=b_cookbook_pipeline_library) cookbook has been developed to manage the desired service where often the cookbook will contain functionality to deliver upgrades, notifications, auditing and licensing.
Below is a list of controlled packages and the suggested cookbook to manage the package/service:

Application    | Package Name  | Cookbook        | Notes
 ------------- | ------------- | :-------------: | :--------------:
 Java          | jre           | b_iac_cc_java   | [Confluence link](https://confluence.barcapint.com/display/CHEFPL01/b_iac_cc_java+-+Management+of+JDK+or+JRE+on+Linux)
 Java          | jdk           | b_iac_cc_java   | [Confluence link](https://confluence.barcapint.com/display/CHEFPL01/b_iac_cc_java+-+Management+of+JDK+or+JRE+on+Linux)


## BARC032 - Cookbook depends on a cookbook version flagged as no longer supported or incompatible

````barc```` ````unix```` ````windows```` ````metadata````

Cookbooks especially  [`library`](http://chefsupermarket/cookbooks?utf8=%E2%9C%93&q=&platforms%5B%5D=b_cookbook_pipeline_library) cookbooks are often consumed by multiple teams. As time go by; various teams may be still using an older version of the cookbook. Often with `library` cookbook's new functionality is added to support auditing, security/compliance or management requirements. In order for this newer functionality to be delivered without impacting production systems, this foodcritic rule has been created to flag and attempt to remediate these issues. This foodcritic rule should not be used to force contingent cookbook consumers to upgrade to the latest version

When depending on [`library`](http://chefsupermarket/cookbooks?utf8=%E2%9C%93&q=&platforms%5B%5D=b_cookbook_pipeline_library) cookbooks, due to the strict testing requirements, the build pipeline allows for un-pinned dependencies. where the latest approved version will always be applied. To un-pin a library cookbook see the example below

Pinned dependency in metadata.rb:
```ruby
depends 'library_cookbook_name', '=0.1.0'
```

Un-Pinned dependency in metadata.rb:
```ruby
depends 'library_cookbook_name'
```

**The table below lists the current BARC032 constraints:**

Cookbook | Minimum Version
---- | ----
b_iac_cc_java | 0.2.10
ib_cto_ca_nolio | 6.6.10

**end of BARC032 table**

## BARC033 - Cookbook must depend on a cookbook with allowed pin only

````barc```` ````unix```` ````windows```` ````metadata````

Base Infrastructure, Middleware or other library cookbooks are consumed by 1 or more dependent cookbooks. To ensure upgrade path for [`library cookbooks`](https://confluence.barcapint.com/display/CHEFPL01/Chef+Pipeline+Library+Cookbooks). Resource owners, can demand specific usage patterns.

BARC033 rule enforces [`soft-pin dependency pinning`](https://confluence.barcapint.com/display/CHEFPL01/Chef+Pipeline+Cookbook+dependencies#ChefPipelineCookbookdependencies-Softdependencypinning) for specific library cookbooks.

Example with Infrastructure controlled library cookbooks `b-vas_manage` and `b-users_manage`.

Hard-Pinned dependency in metadata.rb is caught as violation | Un-Pinned/Soft-Pinned dependency in metadata.rb is allowed |
 ------------------  | :-------: |
 `depends 'b-vas_manage', '= 0.2.0'` | `depends 'b-vas_manage'` |
 `depends 'b-users_manage', '= 0.1.0'` | `depends 'b-users_manage', '>= 1.2.0'` |

**The table below lists the current BARC033 constraints:**

Cookbook | Pin requirements with priority
---- | ----
b-auth | >=, ~>
b-build-compliance | >=, ~>
b-identification | >=, ~>
b-monitoring | >=, ~>
b-omnibus_updater | >=, ~>
b-rhel7-build | >=, ~>
b-rhel7-latest | >=, ~>
b-users_manage | >=, ~>
b-vas_manage | >=, ~>
b_all_production_blocker | >=, ~>
b_unix_base_common | >=, ~>
b_unix_base_core | >=, ~>
b_unix_base_ech | >=, ~>
barclays-incident-fixes | >=, ~>
barclays-security-audit-rhel | >=, ~>
chef-client | >=, ~>
chef_handler | >=, ~>
iaas_unix_ilmt_agent | >=, ~>
iaas_unix_sysipcpr_local | >=, ~>
insv_eme_tanium_client | >=, ~>
is_iaas_unix_estatescripts | >=, ~>
is_iaas_unix_fixhptools | >=, ~>
is_iaas_unix_ntp | >=, ~>
is_iaas_unix_remediation | >=, ~>
is_iaas_unix_ssl | >=, ~>
is_iaas_unix_syslog | >=, ~>
is_mw_software_compliance | >=, ~>
is_uisec_service_watch | >=, ~>
is_uisec_unix_sudo | >=, ~>
paas_mw_corebase_prod | >=, ~>
unix-audit-remediation | >=, ~>

**end of BARC033 table**

## BARC034 - Restricted attributes check[Roles]

````barc```` ````unix````

Restircted usage for attributes listed under @restricted_attributes map inside roles.

If you are using any restricted attributes from @restricted_attributes then you must whitelist your cookbook for its usage.

Example for whitelisting restricted attribute sudo_custom_polices in your cookbook.

```
@restricted_attributes = {
  'enable_custom_sudoers_policies' => ['yourcookbookname']
}
```
**end of BARC034 table**

## BARC035 - Restricted attributes check[Attributes|Recipes|Provider|Library]

````barc```` ````unix````

Restricted usage for attributes listed under @restricted_attributes map inside attributes/recipes/providers/librray.

If you are using any restricted attributes from @restricted_attributes then you must whitelist your cookbook for its usage.

Example for whitelisting restricted attribute sudo_custom_polices in your cookbook.

```
@restricted_attributes = {
  'enable_custom_sudoers_policies' => ['yourcookbookname']
}
```
**end of BARC035 table**

## BARC036 - Java version hard pined up DWB/ORAC required

````barc```` ````unix```` ````java````

Restricted usage for attributes update_number on b_iac_cc_java resource which is used to pined up to a specfic java version.

If you still wants to pined up your java to specfic version then you must whitelist your cookbook for its usage.

Example for whitelisting restricted attribute orac_java_hard_pined_up in your cookbook.

```
@orac_java_hard_pined_up = {
  'yourcookbook' => 'ORAC'
}
```
**end of BARC036 table**
