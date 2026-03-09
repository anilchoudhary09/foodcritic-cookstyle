# frozen_string_literal: true

#
# Sample Test Recipe - Demonstrates BARC rule violations
# Run: cookstyle . to see violations detected
#

# BARC001 - User manipulation (VIOLATION)
user 'test_user' do
  action :create
end

# BARC002 - Group manipulation (VIOLATION)
group 'test_group' do
  action :create
end

# BARC003 - Root SSH (VIOLATION)
directory '/root/.ssh' do
  mode '0700'
end

# BARC005 - /etc blacklist (VIOLATION)
file '/etc/sudoers' do
  content '# test'
end

# BARC006 - Reboot (VIOLATION)
execute 'reboot_system' do
  command 'reboot'
end

# BARC007 - SELinux (VIOLATION)
execute 'disable_selinux' do
  command 'setenforce 0'
end

# BARC008 - Kill process (VIOLATION)
execute 'kill_app' do
  command 'pkill -f myapp'
end

# BARC009 - Firewall (VIOLATION)
execute 'open_port' do
  command 'iptables -A INPUT -p tcp --dport 8080 -j ACCEPT'
end

# BARC011 - Remove files (VIOLATION)
execute 'cleanup' do
  command 'rm -rf /tmp/cache'
end

# BARC016 - Use Chef resources (VIOLATION)
execute 'install_pkg' do
  command 'yum install -y nginx'
end

# BARC017 - System services (VIOLATION)
service 'auditd' do
  action :stop
end

# BARC019 - Dangerous patterns (VIOLATION)
execute 'bad_perms' do
  command 'chmod 777 /opt/app'
end

# ============================================================
# COMPLIANT EXAMPLES (These should pass)
# ============================================================

# OK - Application directory
directory '/opt/myapp' do
  mode '0755'
end

# OK - Using package resource
package 'httpd' do
  action :install
end

# OK - Application service
service 'httpd' do
  action [:enable, :start]
end

# OK - Application file
file '/opt/myapp/config.yml' do
  content 'key: value'
  mode '0644'
end
