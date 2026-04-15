# frozen_string_literal: true

#
# Cookbook:: is_uisec_unix_sudo
# Recipe:: default
#
# This recipe manages sudoers configuration.
# It has an EXCEPTION in rules.rb for specific /etc/sudoers paths.
#
# Expected result: Should PASS cookstyle - no BARC005 violations
# Because is_uisec_unix_sudo is whitelisted for these SPECIFIC paths in @etc_whitelist:
#   - /etc/sudoers
#   - /etc/sudoers.chef
#   - /etc/opt/quest/sudo/sudoers
#   - /etc/opt/quest/sudo/sudoers.chef
#
# NOTE: /etc/sudoers.d/ is in BLACKLIST and NOT whitelisted for this cookbook
#

# Manage /etc/sudoers - WHITELISTED for this cookbook
template '/etc/sudoers' do
  source 'sudoers.erb'
  owner 'root'
  group 'root'
  mode '0440'
  action :create
end

# Manage /etc/sudoers.chef - WHITELISTED for this cookbook
file '/etc/sudoers.chef' do
  content "# Managed by Chef\n"
  owner 'root'
  group 'root'
  mode '0440'
end

# Quest sudo configuration files - WHITELISTED
file '/etc/opt/quest/sudo/sudoers' do
  content "# Quest sudoers - managed by Chef\n"
  owner 'root'
  group 'root'
  mode '0440'
end

file '/etc/opt/quest/sudo/sudoers.chef' do
  content "# Quest sudoers chef backup - managed by Chef\n"
  owner 'root'
  group 'root'
  mode '0440'
end
