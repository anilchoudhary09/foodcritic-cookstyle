#
# Cookbook:: b-foodcritic-cookstyle
# Recipe:: custom_rules_demo
#
# This recipe demonstrates violations that would be caught by
# our CUSTOM Cookstyle cops defined in .rubocop/cops/custom_cops.rb
#

# =============================================================================
# VIOLATION 1: Custom::RequireResourceDescription
# This resource has no comment above it
# =============================================================================
package 'curl' do
  action :install
end

# =============================================================================
# VIOLATION 2: Custom::RequireExplicitAction
# This resource relies on default action (no explicit action specified)
# =============================================================================
# Install wget for downloading files
package 'wget' do
  # Missing explicit action - relies on default :install
end

# =============================================================================
# VIOLATION 3: Custom::NoHardcodedPasswords
# This resource has a hardcoded password
# =============================================================================
# Create application user
user 'appuser' do
  comment 'Application User'
  home '/home/appuser'
  shell '/bin/bash'
  password 'supersecretpassword123'  # BAD: Hardcoded password!
  action :create
end

# =============================================================================
# PROPER FIX: Use data bags for passwords
# =============================================================================
# Create secure user with password from data bag
# user 'secureuser' do
#   comment 'Secure User'
#   home '/home/secureuser'
#   shell '/bin/bash'
#   password data_bag_item('users', 'secureuser')['password']
#   action :create
# end

# =============================================================================
# VIOLATION 4: Custom::RequireGuardClause
# Execute resource without guard clause (not idempotent)
# =============================================================================
# Run database migration
execute 'run-db-migration' do
  command '/opt/app/bin/migrate.sh'
  user 'appuser'
  cwd '/opt/app'
  # Missing not_if or only_if guard!
end

# =============================================================================
# PROPER FIX: Execute with guard clause
# =============================================================================
# Run database migration with proper guard
execute 'run-db-migration-properly' do
  command '/opt/app/bin/migrate.sh'
  user 'appuser'
  cwd '/opt/app'
  not_if { ::File.exist?('/opt/app/.migrated') }
  action :run
end

# =============================================================================
# VIOLATION 5: Custom::PreferPlatformHelpers
# Using node attribute comparison instead of helper
# =============================================================================
# Install package based on platform
ruby_block 'check-platform-bad' do
  block do
    if node['platform'] == 'ubuntu'
      Chef::Log.info('Running on Ubuntu')
    end
  end
  action :run
end

# =============================================================================
# PROPER FIX: Use platform helpers
# =============================================================================
# Install package using platform helper
ruby_block 'check-platform-good' do
  block do
    if platform?('ubuntu')
      Chef::Log.info('Running on Ubuntu')
    end
  end
  action :run
end

# =============================================================================
# MORE EXAMPLES OF GOOD PRACTICES
# =============================================================================

# Create application directory with proper permissions
directory '/opt/myapp' do
  owner 'appuser'
  group 'appuser'
  mode '0755'
  recursive true
  action :create
end

# Download application artifact with guard
remote_file '/tmp/myapp.tar.gz' do
  source 'https://releases.example.com/myapp-1.0.tar.gz'
  owner 'appuser'
  group 'appuser'
  mode '0644'
  not_if { ::File.exist?('/opt/myapp/bin/myapp') }
  action :create
end

# Extract application with guard
execute 'extract-myapp' do
  command 'tar -xzf /tmp/myapp.tar.gz -C /opt/myapp'
  user 'appuser'
  creates '/opt/myapp/bin/myapp'
  action :run
end
