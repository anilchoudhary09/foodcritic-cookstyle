#
# Cookbook:: b-foodcritic-cookstyle
# Recipe:: cookstyle_showcase
#
# This recipe demonstrates various Cookstyle rules and best practices
# Run `cookstyle recipes/cookstyle_showcase.rb` to see violations
#

# =============================================================================
# EXAMPLE 1: Modern Resource Syntax (Chef/Modernize/ActionMethodInResource)
# =============================================================================
# Cookstyle prefers action as a property rather than a method

package 'nginx' do
  action :install
end

# =============================================================================
# EXAMPLE 2: Proper Service Resource Usage
# =============================================================================
# Using the unified_mode for Chef 18+ compatibility

service 'nginx' do
  action [:enable, :start]
  supports status: true, restart: true, reload: true
end

# =============================================================================
# EXAMPLE 3: File Resource with Proper Permissions
# =============================================================================
# Cookstyle checks for proper file permissions format

file '/etc/nginx/nginx.conf' do
  content 'user nginx;'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# =============================================================================
# EXAMPLE 4: Directory Resource
# =============================================================================

directory '/var/log/myapp' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# =============================================================================
# EXAMPLE 5: Template Resource with Variables
# =============================================================================

template '/etc/myapp/config.conf' do
  source 'config.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    app_name: 'MyApplication',
    app_port: 8080
  )
  action :create
end

# =============================================================================
# EXAMPLE 6: Execute Resource with Guards
# =============================================================================
# Cookstyle prefers guards over conditional logic

execute 'update-app-cache' do
  command '/usr/local/bin/update-cache.sh'
  user 'root'
  not_if { ::File.exist?('/var/cache/myapp/updated') }
  action :run
end

# =============================================================================
# EXAMPLE 7: Using node attributes correctly
# =============================================================================

log 'platform-info' do
  message "Running on #{node['platform']} #{node['platform_version']}"
  level :info
end

# =============================================================================
# EXAMPLE 8: Conditional Resource Execution
# =============================================================================

package 'httpd' do
  only_if { node['platform_family'] == 'rhel' }
  action :install
end

package 'apache2' do
  only_if { node['platform_family'] == 'debian' }
  action :install
end

# =============================================================================
# EXAMPLE 9: Using Ruby Blocks Properly
# =============================================================================

ruby_block 'set-environment-variable' do
  block do
    ENV['MY_APP_HOME'] = '/opt/myapp'
  end
  action :run
end

# =============================================================================
# EXAMPLE 10: Remote File Resource
# =============================================================================

remote_file '/tmp/app-installer.tar.gz' do
  source 'https://example.com/releases/app-1.0.tar.gz'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  not_if { ::File.exist?('/opt/myapp/bin/app') }
end
