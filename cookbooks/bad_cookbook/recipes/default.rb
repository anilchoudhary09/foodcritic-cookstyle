# frozen_string_literal: true

#
# Cookbook:: bad_cookbook
# Recipe:: default
#
# This cookbook has NO exceptions in rules.rb
# It attempts the same operations as is_uisec_unix_sudo but should FAIL
#
# Expected result: Should FAIL cookstyle with BARC005 violations
#

# Try to modify /etc/sudoers - NOT WHITELISTED for this cookbook
# SHOULD FAIL: BARC005
template '/etc/sudoers' do
  source 'sudoers.erb'
  owner 'root'
  group 'root'
  mode '0440'
end

# Try to manage sshd service - PROTECTED in @system_services
# SHOULD FAIL: BARC017
service 'sshd' do
  action [:enable, :start]
end

# Try to modify /etc/passwd - BLACKLISTED
# SHOULD FAIL: BARC005
file '/etc/passwd' do
  content "# bad modification\n"
  owner 'root'
  mode '0644'
end
