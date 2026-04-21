# frozen_string_literal: true

#
# Cookbook:: my-app-cookbook
# Recipe:: compliant
#
# ✅ THIS RECIPE FOLLOWS ALL BEST PRACTICES
# It demonstrates the correct way to write Chef cookbooks
#
# Run: cookstyle recipes/compliant.rb
# Expected: No violations (or only style suggestions)
#

# ============================================================
# APPLICATION DIRECTORY SETUP (Compliant)
# ============================================================

# Create application directories - these are allowed
directory '/opt/myapp' do
  owner 'abc'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

directory '/opt/myapp/config' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/opt/myapp/logs' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/opt/myapp/data' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# ============================================================
# PACKAGE MANAGEMENT (Compliant)
# ============================================================

# Use Chef package resource instead of execute with apt-get
package 'nginx' do
  action :install
end

package %w(curl wget vim htop) do
  action :install
end

# ============================================================
# SERVICE MANAGEMENT (Compliant)
# ============================================================

# Application services are allowed (not system services like auditd)
service 'nginx' do
  action [:enable, :start]
end

# ============================================================
# FILE MANAGEMENT (Compliant)
# ============================================================

# Template in application directory - allowed
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

# File in application directory - allowed
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
# ALLOWED /etc PATHS (Compliant)
# ============================================================

# /etc/profile.d/ is whitelisted for environment setup
file '/etc/profile.d/myapp.sh' do
  content <<~SHELL
    export MYAPP_HOME=/opt/myapp
    export PATH=$PATH:/opt/myapp/bin
    export MYAPP_ENV=production
  SHELL
  owner 'root'
  group 'root'
  mode '0644'
end

# /etc/logrotate.d/ is whitelisted for log rotation
file '/etc/logrotate.d/myapp' do
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
# REMOTE FILES (Compliant)
# ============================================================

# Use remote_file resource with create_if_missing action
remote_file '/opt/myapp/artifact.tar.gz' do
  source 'https://releases.example.com/myapp-1.0.tar.gz'
  owner 'root'
  group 'root'
  mode '0644'
  action :create_if_missing
end

# ============================================================
# ARCHIVE EXTRACTION (Compliant)
# ============================================================

# Use archive_file instead of tar execute
archive_file 'extract_myapp' do
  path '/opt/myapp/artifact.tar.gz'
  destination '/opt/myapp'
  owner 'root'
  group 'root'
  action :extract
  not_if { ::Dir.exist?('/opt/myapp/bin') }
end

# ============================================================
# CRON JOBS (Compliant)
# ============================================================

# Use cron resource instead of crontab execute
cron 'myapp_cleanup' do
  minute '0'
  hour '3'
  command '/opt/myapp/scripts/cleanup.sh >> /opt/myapp/logs/cleanup.log 2>&1'
  user 'root'
  action :create
end

cron 'myapp_health_check' do
  minute '*/5'
  command '/opt/myapp/scripts/health_check.sh'
  user 'root'
  action :create
end

# ============================================================
# SYMBOLIC LINKS (Compliant)
# ============================================================

# Use link resource instead of ln execute
link '/usr/local/bin/myapp' do
  to '/opt/myapp/bin/myapp'
  link_type :symbolic
  action :create
end

# ============================================================
# EXECUTE WITH PROPER GUARDS (Compliant)
# ============================================================

# Execute is allowed when used properly with guards
execute 'initialize_myapp_database' do
  command '/opt/myapp/scripts/init-db.sh'
  creates '/opt/myapp/data/.db_initialized'
  action :run
end

execute 'run_myapp_migrations' do
  command '/opt/myapp/scripts/migrate.sh'
  cwd '/opt/myapp'
  environment(
    'MYAPP_ENV' => 'production',
    'MYAPP_LOG' => '/opt/myapp/logs/migrate.log'
  )
  not_if '/opt/myapp/scripts/check-migrations.sh'
  action :run
end

# ============================================================
# NOTIFICATIONS (Compliant)
# ============================================================

# Proper notification chain for config changes
template '/opt/myapp/config/database.yml' do
  source 'database.yml.erb'
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
  notifies :restart, 'service[nginx]', :delayed
end

# ============================================================
# RUBY BLOCKS FOR COMPLEX LOGIC (Compliant)
# ============================================================

ruby_block 'log_deployment_complete' do
  block do
    Chef::Log.info('MyApp deployment completed successfully')
    Chef::Log.info("Version: #{node['myapp']['version'] || '1.0.0'}")
  end
  action :run
end
