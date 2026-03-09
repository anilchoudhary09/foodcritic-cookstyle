# frozen_string_literal: true

#
# Cookbook:: sample-app-cookbook
# Recipe:: violations
#
# This recipe demonstrates various BARC rule violations
# for testing the migrated Cookstyle cops
#

# ============================================================
# BARC001 Violations: Local User Manipulation
# ============================================================

# Violation: Creating local user with user resource
user 'myapp_user' do
  comment 'Application user'
  home '/home/myapp_user'
  shell '/bin/bash'
  action :create
end

# Violation: Using useradd command
execute 'create_backup_user' do
  command 'useradd -m backup_user'
  not_if 'id backup_user'
end

# ============================================================
# BARC002 Violations: Local Group Manipulation
# ============================================================

# Violation: Creating local group
group 'myapp_group' do
  members ['myapp_user']
  action :create
end

# Violation: Using groupadd command
execute 'create_admin_group' do
  command 'groupadd admin_group'
  not_if 'getent group admin_group'
end

# ============================================================
# BARC003 Violations: Root SSH Manipulation
# ============================================================

# Violation: Creating root .ssh directory
directory '/root/.ssh' do
  mode '0700'
  owner 'root'
  group 'root'
end

# Violation: Managing root authorized_keys
file '/root/.ssh/authorized_keys' do
  content 'ssh-rsa AAAAB3NzaC1...'
  mode '0600'
  owner 'root'
end

# ============================================================
# BARC005 Violations: /etc Blacklist
# ============================================================

# Violation: Modifying /etc/passwd
file '/etc/passwd' do
  content 'root:x:0:0:root:/root:/bin/bash'
  mode '0644'
end

# Violation: Modifying /etc/sudoers
template '/etc/sudoers' do
  source 'sudoers.erb'
  mode '0440'
end

# Violation: Modifying PAM configuration
file '/etc/pam.d/system-auth' do
  content '# Custom PAM config'
end

# ============================================================
# BARC006 Violations: Reboot/Shutdown Commands
# ============================================================

# Violation: Using reboot resource
reboot 'restart_machine' do
  action :reboot_now
  reason 'System update requires reboot'
end

# Violation: Using reboot command
execute 'force_reboot' do
  command 'reboot -f'
  action :run
end

# Violation: Using shutdown command
execute 'shutdown_system' do
  command 'shutdown -h now'
  only_if { node['emergency_shutdown'] }
end

# ============================================================
# BARC007 Violations: SELinux Manipulation
# ============================================================

# Violation: Disabling SELinux
execute 'disable_selinux' do
  command 'setenforce 0'
  only_if 'getenforce | grep -i enforcing'
end

# Violation: Modifying SELinux config
file '/etc/selinux/config' do
  content 'SELINUX=disabled'
end

# ============================================================
# BARC008 Violations: Kill/Process Priority
# ============================================================

# Violation: Killing processes
execute 'kill_zombie_processes' do
  command 'kill -9 $(ps aux | grep defunct | awk \'{print $2}\')'
  only_if 'ps aux | grep defunct'
end

# Violation: Using pkill
execute 'stop_app' do
  command 'pkill -f myapp'
  only_if 'pgrep -f myapp'
end

# Violation: Changing process priority
execute 'increase_priority' do
  command 'renice -n -10 $(pgrep myapp)'
  only_if 'pgrep myapp'
end

# ============================================================
# BARC009 Violations: Firewall Manipulation
# ============================================================

# Violation: Using iptables
execute 'open_port_8080' do
  command 'iptables -A INPUT -p tcp --dport 8080 -j ACCEPT'
  not_if 'iptables -L | grep 8080'
end

# Violation: Using firewall-cmd
execute 'add_firewall_rule' do
  command 'firewall-cmd --add-port=8080/tcp --permanent'
  notifies :run, 'execute[reload_firewall]', :immediately
end

# Violation: Modifying firewall config file
file '/etc/sysconfig/iptables' do
  content '# Custom firewall rules'
end

# ============================================================
# BARC011 Violations: File/Directory Removal
# ============================================================

# Violation: Using rm -rf
execute 'clean_temp' do
  command 'rm -rf /tmp/myapp_cache/*'
  only_if { ::Dir.exist?('/tmp/myapp_cache') }
end

# Violation: Recursive directory deletion
directory '/app/old_logs' do
  action :delete
  recursive true
end

# ============================================================
# BARC016 Violations: Use Chef Resources
# ============================================================

# Violation: Using yum install instead of package resource
execute 'install_nginx' do
  command 'yum install -y nginx'
  not_if 'rpm -q nginx'
end

# Violation: Using systemctl instead of service resource
execute 'start_nginx' do
  command 'systemctl start nginx'
  not_if 'systemctl is-active nginx'
end

# Violation: Using mkdir instead of directory resource
execute 'create_app_dir' do
  command 'mkdir -p /opt/myapp/data'
  not_if { ::Dir.exist?('/opt/myapp/data') }
end

# Violation: Using chown instead of file resource
execute 'set_ownership' do
  command 'chown -R myapp:myapp /opt/myapp'
end

# Violation: Using curl to download instead of remote_file
execute 'download_config' do
  command 'curl -o /opt/myapp/config.tar.gz https://example.com/config.tar.gz'
  not_if { ::File.exist?('/opt/myapp/config.tar.gz') }
end

# ============================================================
# BARC017 Violations: System Service Manipulation
# ============================================================

# Violation: Stopping security agent
service 'falcon-sensor' do
  action :stop
end

# Violation: Disabling audit daemon
service 'auditd' do
  action [:stop, :disable]
end

# Violation: Using systemctl to stop monitoring
execute 'stop_splunk' do
  command 'systemctl stop splunkforwarder'
end

# ============================================================
# BARC019 Violations: Dangerous Commands
# ============================================================

# Violation: sudo find
execute 'find_with_sudo' do
  command 'sudo find /var/log -name "*.log" -exec rm {} \;'
end

# Violation: chmod 777
execute 'bad_permissions' do
  command 'chmod 777 /opt/myapp'
end

# Violation: chmod -R 777
execute 'very_bad_permissions' do
  command 'chmod -R 777 /opt/myapp/public'
end
