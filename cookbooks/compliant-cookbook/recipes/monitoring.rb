# frozen_string_literal: true

#
# Cookbook:: compliant-cookbook
# Recipe:: monitoring
#
# Sets up application monitoring following all Barclays policies
#

# ============================================================
# LOGGING SETUP (Compliant)
# ============================================================

# Create log directory
directory '/opt/myapp/logs' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Create scripts directory
directory '/opt/myapp/scripts' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# ============================================================
# HEALTH CHECK ENDPOINT (Compliant)
# ============================================================

# Create health check script
file '/opt/myapp/scripts/health_check.sh' do
  content <<~BASH
    #!/bin/bash
    # Health check script for myapp

    HEALTH_URL="http://localhost:8080/health"
    TIMEOUT=5

    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT $HEALTH_URL)

    if [ "$response" = "200" ]; then
        echo "OK: Application is healthy"
        exit 0
    else
        echo "CRITICAL: Application health check failed (HTTP $response)"
        exit 2
    fi
  BASH
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# ============================================================
# MONITORING CRON (Compliant)
# ============================================================

cron 'myapp_health_check' do
  minute '*/5'
  command '/opt/myapp/scripts/health_check.sh >> /opt/myapp/logs/health.log 2>&1'
  user 'root'
  action :create
end

# ============================================================
# LOG AGGREGATION CONFIG (Compliant - allowed /etc path)
# ============================================================

# Define rsyslog service for notification
service 'rsyslog' do
  action :nothing
end

# /etc/rsyslog.d/ is whitelisted for log forwarding
file '/etc/rsyslog.d/50-myapp.conf' do
  content <<~CONF
    # Forward myapp logs to central logging
    if $programname == 'myapp' then /opt/myapp/logs/syslog.log
    & stop
  CONF
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[rsyslog]', :delayed
  only_if { ::File.exist?('/etc/rsyslog.conf') }
end

# ============================================================
# RUBY BLOCK FOR LOGGING (Compliant)
# ============================================================

ruby_block 'log_monitoring_setup_complete' do
  block do
    Chef::Log.info('Monitoring setup completed successfully')
    Chef::Log.info('Health checks configured every 5 minutes')
  end
  action :run
end
