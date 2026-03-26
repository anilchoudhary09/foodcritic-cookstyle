# frozen_string_literal: true

#
# Cookbook:: compliant-cookbook
# Recipe:: application
#
# Sets up the application following all Barclays security policies
#

# ============================================================
# DIRECTORY SETUP (Compliant - using /opt for applications)
# ============================================================

%w(/opt/myapp /opt/myapp/config /opt/myapp/logs /opt/myapp/data /opt/myapp/bin).each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end
end

# ============================================================
# PACKAGE MANAGEMENT (Compliant - using Chef package resource)
# ============================================================

# Use package resource instead of execute with apt-get/yum
package 'nginx' do
  action :install
end

package %w(curl wget vim) do
  action :install
end

# ============================================================
# SERVICE MANAGEMENT (Compliant - application services only)
# ============================================================

# Managing nginx is allowed (not a protected system service)
service 'nginx' do
  action %i(enable start)
end

# ============================================================
# FILE MANAGEMENT (Compliant - application config files)
# ============================================================

# Template in application directory
template '/opt/myapp/config/app.conf' do
  source 'app.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    app_name: 'myapp',
    app_port: 8080,
    log_level: 'info'
  )
  notifies :reload, 'service[nginx]', :delayed
end

# Application configuration file
file '/opt/myapp/config/settings.json' do
  content JSON.pretty_generate(
    debug: false,
    max_connections: 100,
    timeout: 30
  )
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# ============================================================
# ALLOWED /etc PATHS (Compliant - whitelisted directories)
# ============================================================

# /usr/profile.d/ is whitelisted for environment setup
file '/usr/profile.d/myapp.sh' do
  content <<~SHELL
    export MYAPP_HOME=/opt/myapp
    export PATH=$PATH:/opt/myapp/bin
    export MYAPP_ENV=production
  SHELL
  owner 'root'
  group 'root'
  mode '0644'
end

# /usr/logrotate.d/ is whitelisted for log rotation
file '/usr/logrotate.d/myapp' do
  content <<~CONF
    /opt/myapp/logs/*.log {
        daily
        rotate 7
        compress
        delaycompress
        missingok
        notifempty
        create 0644 root root
    }
  CONF
  owner 'root'
  group 'root'
  mode '0644'
end

# /etc/default/ is whitelisted for service defaults
file '/etc/default/myapp' do
  content <<~CONF
    MYAPP_USER=root
    MYAPP_GROUP=root
    MYAPP_OPTS="-c /opt/myapp/config/app.conf"
  CONF
  owner 'root'
  group 'root'
  mode '0644'
end

# ============================================================
# REMOTE FILES (Compliant - using remote_file resource)
# ============================================================

# Use remote_file instead of curl/wget execute
remote_file '/opt/myapp/artifact.tar.gz' do
  source 'https://releases.example.com/myapp-1.0.tar.gz'
  owner 'root'
  group 'root'
  mode '0644'
  action :create_if_missing
end

# ============================================================
# ARCHIVE EXTRACTION (Compliant - using archive_file resource)
# ============================================================

archive_file 'extract_myapp' do
  path '/opt/myapp/artifact.tar.gz'
  destination '/opt/myapp'
  owner 'root'
  group 'root'
  action :extract
  not_if { ::Dir.exist?('/opt/myapp/bin/myapp') }
end

# ============================================================
# CRON JOBS (Compliant - using cron resource)
# ============================================================

cron 'myapp_cleanup' do
  minute '0'
  hour '3'
  command '/opt/myapp/scripts/cleanup.sh >> /opt/myapp/logs/cleanup.log 2>&1'
  user 'root'
  action :create
end

# ============================================================
# SYMBOLIC LINKS (Compliant - using link resource)
# ============================================================

link '/usr/local/bin/myapp' do
  to '/opt/myapp/bin/myapp'
  link_type :symbolic
  action :create
end

# ============================================================
# EXECUTE WITH PROPER GUARDS (Compliant)
# ============================================================

execute 'initialize_myapp_database' do
  command '/opt/myapp/scripts/init-db.sh'
  creates '/opt/myapp/data/.db_initialized'
  action :run
end
