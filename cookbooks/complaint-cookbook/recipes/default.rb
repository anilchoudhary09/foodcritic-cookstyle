# frozen_string_literal: true

# Compliant cookbook - uses safe patterns

# Safe: Create a directory (not in /etc blacklist)
directory '/opt/myapp' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Safe: Deploy application file
cookbook_file '/opt/myapp/config.yml' do
  source 'config.yml'
  owner 'root'
  mode '0644'
end

# Safe: Run application commands
execute 'start_myapp' do
  command '/opt/myapp/bin/start.sh'
  action :run
end

# Safe: Log message
log 'Deployment complete' do
  level :info
end
