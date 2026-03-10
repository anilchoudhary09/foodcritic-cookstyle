# compliant-cookbook

✅ **A fully compliant Chef cookbook** demonstrating best practices and Barclays security policies.

## Compliance Status

🟢 **PASSES ALL CHECKS** - Zero violations

| Check Type | Status |
|------------|--------|
| BARC001 - No Local Users | ✅ Pass |
| BARC002 - No Local Groups | ✅ Pass |
| BARC003 - No Root SSH | ✅ Pass |
| BARC005 - Protected /etc | ✅ Pass |
| BARC006 - No Reboot | ✅ Pass |
| BARC007 - No SELinux | ✅ Pass |
| BARC008 - No Kill Process | ✅ Pass |
| BARC009 - No Firewall | ✅ Pass |
| BARC011 - No rm -rf | ✅ Pass |
| BARC016 - Use Chef Resources | ✅ Pass |
| BARC017 - No System Services | ✅ Pass |
| BARC019 - No chmod 777 | ✅ Pass |

## Quick Start

```bash
cd cookbooks/compliant-cookbook
bundle install
cookstyle .
```

Expected output: **0 offenses detected**

## Best Practices Demonstrated

### 1. Package Management
```ruby
# ✅ Use Chef package resource
package 'nginx' do
  action :install
end

# ❌ Don't use execute with apt-get
# execute 'apt-get install nginx'
```

### 2. File Management
```ruby
# ✅ Use Chef file/template resources
template '/opt/myapp/config/app.conf' do
  source 'app.conf.erb'
  mode '0644'
end

# ❌ Don't use chmod commands
# execute 'chmod 777 /opt/myapp'
```

### 3. Allowed /etc Paths
```ruby
# ✅ These /etc paths are whitelisted:
# - /etc/profile.d/
# - /etc/logrotate.d/
# - /etc/default/
# - /etc/rsyslog.d/

# ❌ These are NOT allowed:
# - /etc/sudoers
# - /etc/passwd
# - /etc/shadow
# - /etc/ssh/sshd_config
```

### 4. Service Management
```ruby
# ✅ Application services are allowed
service 'nginx' do
  action [:enable, :start]
end

# ❌ System services are protected
# service 'auditd' - NOT ALLOWED
# service 'rsyslog' - NOT ALLOWED
```

## Comparison

| Feature | my-app-cookbook | compliant-cookbook |
|---------|-----------------|-------------------|
| Violations | 33 | 0 |
| Build Status | ❌ FAIL | ✅ PASS |
| Purpose | Demo violations | Reference implementation |
