# frozen_string_literal: true

#
# Cookbook:: sample-app-cookbook
# Recipe:: compliant
#
# This recipe demonstrates COMPLIANT patterns that pass all BARC rules
# Use this as a reference for writing secure Chef code
#

# ============================================================
# Application Configuration (Compliant)
# ============================================================

# Create application directories (allowed - not system directories)
directory '/opt/myapp' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/opt/myapp/config' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

directory '/opt/myapp/logs' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# ============================================================
# Package Management (Compliant)
# ============================================================

# Use Chef package resource instead of execute
package 'nginx' do
  action :install
end

package %w(curl wget vim) do
  action :install
end

# ============================================================
# Service Management (Compliant)
# ============================================================

# Use Chef service resource for application services (not system services)
service 'nginx' do
  action [:enable, :start]
end

# ============================================================
# File Management (Compliant)
# ============================================================

# Template in application directory (allowed)
template '/opt/myapp/config/app.conf' do
  source 'app.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    app_name: node['myapp']['name'],
    log_level: node['myapp']['log_level']
  )
  notifies :restart, 'service[nginx]', :delayed
end

# File in application directory (allowed)
file '/opt/myapp/config/settings.json' do
  content '{"debug": false}'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# ============================================================
# Remote Files (Compliant)
# ============================================================

# Use remote_file instead of curl/wget execute
remote_file '/opt/myapp/artifact.tar.gz' do
  source 'https://releases.example.com/myapp-1.0.tar.gz'
  owner 'root'
  group 'root'
  mode '0644'
  checksum 'abc123...'
  action :create
end

# ============================================================
# Archive Extraction (Compliant)
# ============================================================

# Use archive_file instead of tar command
archive_file '/opt/myapp/artifact.tar.gz' do
  destination '/opt/myapp'
  owner 'root'
  group 'root'
  action :extract
  not_if { ::Dir.exist?('/opt/myapp/extracted') }
end

# ============================================================
# Cron Jobs (Compliant)
# ============================================================

# Use cron resource instead of crontab command
cron 'cleanup_logs' do
  minute '0'
  hour '3'
  command '/opt/myapp/scripts/cleanup.sh'
  user 'root'
  action :create
end

# ============================================================
# Links (Compliant)
# ============================================================

# Use link resource instead of ln command
link '/usr/local/bin/myapp' do
  to '/opt/myapp/bin/myapp'
  link_type :symbolic
  action :create
end

# ============================================================
# Environment Variables (Compliant)
# ============================================================

# Profile.d scripts are allowed
file '/etc/profile.d/myapp.sh' do
  content <<~SH
    export MYAPP_HOME=/opt/myapp
    export PATH=$PATH:/opt/myapp/bin
  SH
  owner 'root'
  group 'root'
  mode '0644'
end

# ============================================================
# Log Rotation (Compliant)
# ============================================================

# logrotate.d is allowed
file '/etc/logrotate.d/myapp' do
  content <<~CONF
    /opt/myapp/logs/*.log {
        daily
        rotate 7
        compress
        delaycompress
        missingok
        notifempty
    }
  CONF
  owner 'root'
  group 'root'
  mode '0644'
end

# ============================================================
# Guards and Idempotency (Compliant)
# ============================================================

# Proper use of guards
execute 'install_app_dependencies' do
  command '/opt/myapp/scripts/install-deps.sh'
  creates '/opt/myapp/.deps_installed'
  action :run
end

# Using not_if with command
execute 'initialize_database' do
  command '/opt/myapp/scripts/init-db.sh'
  not_if '/opt/myapp/scripts/check-db.sh'
  action :run
end

# ============================================================
# Notifications (Compliant)
# ============================================================

# Proper notification chain
template '/opt/myapp/config/database.yml' do
  source 'database.yml.erb'
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
  notifies :restart, 'service[nginx]', :delayed
end

# ============================================================
# Ruby Blocks for Complex Logic (Compliant)
# ============================================================

ruby_block 'check_application_status' do
  block do
    # Complex Ruby logic here
    Chef::Log.info('Application deployment complete')
  end
  action :run
end

# ============================================================
# Data Bag Access (Compliant)
# ============================================================

ruby_block 'configure_from_data_bag' do
  block do
    # Access encrypted data bag for secrets
    # secrets = Chef::EncryptedDataBagItem.load('myapp', 'secrets')
    Chef::Log.info('Loaded configuration from data bag')
  end
  only_if { node['myapp']['use_data_bag'] }
end
