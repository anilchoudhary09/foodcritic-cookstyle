# frozen_string_literal: true

# my-app-cookbook - This has several BARC violations

# VIOLATION: BARC001 - Local user creation
user 'appuser' do
  comment 'Application User'
  home '/home/appuser'
  shell '/bin/bash'
end

# VIOLATION: BARC005 - /etc file modification (not whitelisted)
template '/etc/myapp.conf' do
  source 'myapp.conf.erb'
  owner 'root'
  mode '0644'
end

# VIOLATION: BARC017 - System service manipulation
service 'sshd' do
  action :restart
end

# VIOLATION: BARC011 - rm command
execute 'cleanup_old_files' do
  command 'rm -rf /var/log/myapp/*.old'
end

# VIOLATION: BARC008 - kill process
execute 'kill_old_process' do
  command 'pkill -f myapp_old'
end

# Safe: This is fine
directory '/opt/myapp' do
  owner 'root'
  mode '0755'
end
