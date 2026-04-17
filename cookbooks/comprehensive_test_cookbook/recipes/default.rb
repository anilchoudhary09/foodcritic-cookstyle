# Test cookbook to verify ALL BARC rules
# Each block should trigger a specific violation

# BARC001 - user resource
user 'testuser' do
  action :create
end

# BARC002 - group resource
group 'testgroup' do
  action :create
end

# BARC003 - /root/.ssh file
file '/root/.ssh/authorized_keys' do
  content 'test'
end

# BARC004 - SSH key manipulation
execute 'make_keys' do
  command 'ssh-keygen -t rsa'
end

# BARC005 - /etc blacklist
template '/etc/passwd' do
  source 'passwd.erb'
end

# BARC006 - reboot
execute 'restart' do
  command 'reboot now'
end

# BARC007 - SELinux
execute 'selinux' do
  command 'setenforce 0'
end

# BARC008 - kill process
execute 'killer' do
  command 'kill -9 1234'
end

# BARC009 - firewall
execute 'firewall' do
  command 'firewall-cmd --add-port=80/tcp'
end

# BARC010 - init
execute 'init_level' do
  command 'init 3'
end

# BARC011 - rm command
execute 'cleanup' do
  command 'rm -rf /tmp/junk'
end

# BARC012 - kernel manipulation
execute 'kernel' do
  command 'modprobe test_module'
end

# BARC013 - mount
mount '/mnt/test' do
  device '/dev/sda1'
end

# BARC014 - network
execute 'network' do
  command 'ifconfig eth0 up'
end

# BARC015 - root cron (no user specified = root)
cron 'test_cron' do
  command 'echo test'
end

# BARC016 - shell service command
execute 'svc' do
  command 'service httpd restart'
end

# BARC017 - system service
service 'ntpd' do
  action :restart
end

# BARC019 - find/sudo
execute 'finder' do
  command 'find / -name test'
end

# BARC020 - misc commands
execute 'misc' do
  command 'fuser -k /tmp'
end
