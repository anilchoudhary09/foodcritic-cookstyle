# frozen_string_literal: true

#
# Cookbook:: my-app-cookbook
# Recipe:: violations
#
# ⚠️  THIS RECIPE IS FOR POC DEMONSTRATION ONLY
# It contains INTENTIONAL violations to show how Cookstyle + BARC rules work
#
# Run: cookstyle recipes/violations.rb
# Expected: Multiple violations detected
#

# ============================================================
# BARC001 VIOLATION - Local User Creation
# ============================================================
# Organization policy: Users must be managed via Active Directory/LDAP
# This creates a local user which is NOT allowed

user 'app_user' do
  comment 'Application service account'
  home '/home/app_user'
  shell '/bin/bash'
  action :create
end

# Also detected: Using shell command for user management
execute 'create_backup_user' do
  command 'useradd -m -s /bin/bash backup_user'
  not_if 'id backup_user'
end

# ============================================================
# BARC002 VIOLATION - Local Group Creation
# ============================================================
# Organization policy: Groups must be managed via AD/LDAP

group 'app_group' do
  members ['app_user']
  action :create
end

# ============================================================
# BARC003 VIOLATION - Root SSH Manipulation
# ============================================================
# Organization policy: Root SSH access managed by security team only

directory '/root/.ssh' do
  mode '0700'
  owner 'root'
end

file '/root/.ssh/authorized_keys' do
  content 'ssh-rsa AAAAB3NzaC1yc2E... admin@example.com'
  mode '0600'
  owner 'root'
end

# ============================================================
# BARC005 VIOLATION - Protected /etc Files
# ============================================================
# Organization policy: Certain /etc files are protected

file '/etc/sudoers.d/app_user' do
  content 'app_user ALL=(ALL) NOPASSWD:ALL'
  mode '0440'
end

template '/etc/ssh/sshd_config' do
  source 'sshd_config.erb'
  mode '0600'
end

# ============================================================
# BARC006 VIOLATION - Reboot Commands
# ============================================================
# Organization policy: No automated reboots allowed

execute 'reboot_after_update' do
  command 'reboot'
  only_if { node['needs_reboot'] }
end

reboot 'restart_system' do
  action :reboot_now
  reason 'Kernel update'
end

# ============================================================
# BARC007 VIOLATION - SELinux Manipulation
# ============================================================
# Organization policy: SELinux managed by security team

execute 'disable_selinux' do
  command 'setenforce 0'
  only_if 'getenforce | grep -i enforcing'
end

# ============================================================
# BARC008 VIOLATION - Process Killing
# ============================================================
# Organization policy: Use proper service management

execute 'kill_hanging_process' do
  command 'pkill -9 -f stuck_process'
  only_if 'pgrep -f stuck_process'
end

execute 'force_kill' do
  command 'kill -9 $(cat /var/run/app.pid)'
  only_if { ::File.exist?('/var/run/app.pid') }
end

# ============================================================
# BARC009 VIOLATION - Firewall Manipulation
# ============================================================
# Organization policy: Firewall managed by network team

execute 'open_app_port' do
  command 'iptables -A INPUT -p tcp --dport 8080 -j ACCEPT'
  not_if 'iptables -L | grep 8080'
end

execute 'add_firewall_rule' do
  command 'firewall-cmd --add-port=443/tcp --permanent'
end

# ============================================================
# BARC011 VIOLATION - File Removal
# ============================================================
# Organization policy: No destructive rm -rf operations

execute 'cleanup_old_files' do
  command 'rm -rf /var/log/old_logs/*'
  only_if { ::Dir.exist?('/var/log/old_logs') }
end

directory '/opt/old_app' do
  action :delete
  recursive true
end

# ============================================================
# BARC016 VIOLATION - Use Chef Resources
# ============================================================
# Best practice: Use Chef resources instead of shell commands

execute 'install_packages' do
  command 'apt-get update && apt-get install -y nginx curl wget'
  not_if 'which nginx'
end

execute 'start_service' do
  command 'systemctl start nginx'
  not_if 'systemctl is-active nginx'
end

execute 'create_directory' do
  command 'mkdir -p /opt/myapp/data'
  not_if { ::Dir.exist?('/opt/myapp/data') }
end

execute 'set_ownership' do
  command 'chown -R app_user:app_group /opt/myapp'
end

execute 'download_file' do
  command 'curl -o /tmp/artifact.tar.gz https://example.com/artifact.tar.gz'
  not_if { ::File.exist?('/tmp/artifact.tar.gz') }
end

# ============================================================
# BARC017 VIOLATION - Protected System Services
# ============================================================
# Organization policy: System services managed by platform team only

service 'auditd' do
  action :stop
end

service 'rsyslog' do
  action [:stop, :disable]
end

execute 'stop_crowdstrike' do
  command 'systemctl stop falcon-sensor'
end

# ============================================================
# BARC019 VIOLATION - Dangerous Patterns
# ============================================================
# Security policy: Dangerous command patterns not allowed

execute 'find_and_delete' do
  command 'sudo find /tmp -name "*.log" -exec rm {} \;'
end

execute 'world_writable' do
  command 'chmod 777 /opt/app/uploads'
end

execute 'recursive_world_writable' do
  command 'chmod -R 777 /opt/app/data'
end
