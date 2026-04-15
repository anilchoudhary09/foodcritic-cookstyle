# frozen_string_literal: true

#
# Cookbook:: mysql
# Recipe:: default
#
# This recipe manages MySQL database service.
# mysql service has [] (empty array) in rules.rb meaning ALL cookbooks can manage it.
#
# Expected result: Should PASS cookstyle - no BARC017 violations
# Because mysql/mysqld services are whitelisted with [] in @restricted_services
#
# NOTE: /etc/my.cnf is in blacklist and needs specific whitelist entry
#       Using alternative config location to avoid BARC005
#

# Install MySQL packages
package 'mysql-server' do
  action :install
end

package 'mysql-client' do
  action :install
end

# Manage mysql service - WHITELISTED ([] = all cookbooks allowed)
service 'mysql' do
  action [:enable, :start]
end

# Alternative service name - also WHITELISTED
service 'mysqld' do
  action [:enable, :start]
end

# Create MySQL data directory (not in /etc - safe)
directory '/var/lib/mysql' do
  owner 'mysql'
  group 'mysql'
  mode '0750'
  action :create
end

# MySQL log directory (not in /etc - safe)
directory '/var/log/mysql' do
  owner 'mysql'
  group 'mysql'
  mode '0750'
  action :create
end

# MySQL config in user home (not in /etc/my.cnf blacklist)
directory '/root/.mysql' do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

file '/root/.my.cnf' do
  content "[client]\nuser=root\n"
  owner 'root'
  group 'root'
  mode '0600'
end
