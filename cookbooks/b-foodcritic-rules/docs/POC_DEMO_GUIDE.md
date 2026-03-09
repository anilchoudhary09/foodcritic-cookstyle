# Cookstyle POC - Complete Developer Workflow

## Overview

This POC demonstrates the complete workflow for a developer building a Chef cookbook and validating it against:
1. **200+ Cookstyle rules** - Modern Chef best practices
2. **Custom BARC rules** - Organization security policies (BARC001-BARC019)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DEVELOPER WORKFLOW                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   Developer       Local Dev         Git Push        Jenkins (EC2)           │
│   ─────────       ─────────         ────────        ─────────────           │
│       │               │                 │                │                   │
│       │  Write Code   │                 │                │                   │
│       │───────────────>                 │                │                   │
│       │               │                 │                │                   │
│       │  cookstyle .  │                 │                │                   │
│       │<──────────────│                 │                │                   │
│       │  (Local Test) │                 │                │                   │
│       │               │                 │                │                   │
│       │  Fix Issues   │                 │                │                   │
│       │───────────────>                 │                │                   │
│       │               │                 │                │                   │
│       │               │  git push       │                │                   │
│       │               │─────────────────>                │                   │
│       │               │                 │   Webhook      │                   │
│       │               │                 │────────────────>                   │
│       │               │                 │                │                   │
│       │               │                 │   Run Cookstyle│                   │
│       │               │                 │   (All Rules)  │                   │
│       │               │                 │<───────────────│                   │
│       │               │                 │                │                   │
│       │  Build Status │                 │   Pass/Fail    │                   │
│       │<──────────────────────────────────────────────────                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Part 1: AWS EC2 Ubuntu Server Setup

### 1.1 Connect to EC2

```bash
ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
```

### 1.2 Install Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Ruby (3.0+)
sudo apt install -y ruby ruby-dev build-essential

# Install Git
sudo apt install -y git

# Verify versions
ruby --version    # Should be 3.0+
git --version
```

### 1.3 Install Cookstyle

```bash
# Install bundler
sudo gem install bundler

# Install cookstyle globally
sudo gem install cookstyle

# Verify
cookstyle --version
```

---

## Part 2: Jenkins Setup on EC2

### 2.1 Install Jenkins

```bash
# Install Java
sudo apt install -y openjdk-17-jdk

# Add Jenkins repo
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 2.2 Access Jenkins

1. Open browser: `http://<EC2-PUBLIC-IP>:8080`
2. Enter initial admin password
3. Install suggested plugins
4. Create admin user

### 2.3 Configure Jenkins for Cookstyle

```bash
# Allow jenkins user to run cookstyle
sudo -u jenkins gem install cookstyle
```

---

## Part 3: Clone the BARC Rules Repository

### 3.1 On EC2 Server

```bash
# Create workspace
mkdir -p /opt/chef-cookstyle
cd /opt/chef-cookstyle

# Clone b-foodcritic-rules (contains Cookstyle cops)
git clone <your-git-repo>/b-foodcritic-rules.git

# Install dependencies
cd b-foodcritic-rules
bundle install
```

### 3.2 Set Environment Variable

```bash
# Add to /etc/environment or Jenkins environment
export BARC_RULES_PATH=/opt/chef-cookstyle/b-foodcritic-rules
```

---

## Part 4: Create Test Cookbook (Developer Perspective)

### 4.1 Create New Cookbook

```bash
# Create test cookbook directory
mkdir -p ~/cookbooks/my-app-cookbook
cd ~/cookbooks/my-app-cookbook

# Create structure
mkdir -p recipes templates attributes
```

### 4.2 Create metadata.rb

```ruby
# ~/cookbooks/my-app-cookbook/metadata.rb
name              'my-app-cookbook'
maintainer        'DevOps Team'
maintainer_email  'devops@company.com'
license           'Proprietary'
description       'Sample application cookbook'
version           '1.0.0'
chef_version      '>= 17.0'

depends 'apt'
```

### 4.3 Create .rubocop.yml (Links to BARC Rules)

```yaml
# ~/cookbooks/my-app-cookbook/.rubocop.yml

# Load custom BARC cops from central location
require:
  - /opt/chef-cookstyle/b-foodcritic-rules/lib/rubocop/cop/barclays_cops

AllCops:
  TargetRubyVersion: 3.1
  NewCops: enable
  DisplayCopNames: true

  Include:
    - '**/*.rb'

  Exclude:
    - 'vendor/**/*'
    - 'test/fixtures/**/*'

# Enable all BARC rules
Barclays/Barc001NoLocalUsers:
  Enabled: true
  Severity: error

Barclays/Barc002NoLocalGroups:
  Enabled: true
  Severity: error

Barclays/Barc003NoRootSsh:
  Enabled: true
  Severity: error

Barclays/Barc005EtcBlacklist:
  Enabled: true
  Severity: error

Barclays/Barc006NoReboot:
  Enabled: true
  Severity: error

Barclays/Barc007NoSelinux:
  Enabled: true
  Severity: error

Barclays/Barc008NoKillProcess:
  Enabled: true
  Severity: warning

Barclays/Barc009NoFirewall:
  Enabled: true
  Severity: error

Barclays/Barc011NoRemoveFiles:
  Enabled: true
  Severity: warning

Barclays/Barc016UseChefResources:
  Enabled: true
  Severity: convention

Barclays/Barc017NoSystemServices:
  Enabled: true
  Severity: error

Barclays/Barc019NoFindSudo:
  Enabled: true
  Severity: error

# Standard Cookstyle overrides
Layout/LineLength:
  Max: 120

Style/Documentation:
  Enabled: false
```

### 4.4 Create Gemfile

```ruby
# ~/cookbooks/my-app-cookbook/Gemfile
source 'https://rubygems.org'

gem 'cookstyle', '~> 7.32'
```

### 4.5 Create Default Recipe (WITH VIOLATIONS - For Demo)

```ruby
# ~/cookbooks/my-app-cookbook/recipes/default.rb
# frozen_string_literal: true

#
# Cookbook:: my-app-cookbook
# Recipe:: default
#
# This recipe has INTENTIONAL VIOLATIONS for POC demo
#

# ============================================================
# VIOLATION EXAMPLES (These will be caught by Cookstyle)
# ============================================================

# BARC001 VIOLATION - Local user creation
user 'app_user' do
  comment 'Application user'
  home '/home/app_user'
  action :create
end

# BARC005 VIOLATION - Modifying protected /etc file
file '/etc/sudoers.d/app_user' do
  content 'app_user ALL=(ALL) NOPASSWD:ALL'
  mode '0440'
end

# BARC006 VIOLATION - Reboot command
execute 'reboot_if_needed' do
  command 'reboot'
  only_if { node['needs_reboot'] }
end

# BARC009 VIOLATION - Firewall manipulation
execute 'open_port' do
  command 'iptables -A INPUT -p tcp --dport 8080 -j ACCEPT'
end

# BARC016 VIOLATION - Using command instead of Chef resource
execute 'install_nginx' do
  command 'apt-get install -y nginx'
  not_if 'which nginx'
end

# BARC017 VIOLATION - System service manipulation
service 'auditd' do
  action :stop
end

# BARC019 VIOLATION - Dangerous chmod
execute 'set_permissions' do
  command 'chmod 777 /opt/app/data'
end

# ============================================================
# COMPLIANT EXAMPLES (These will pass)
# ============================================================

# OK - Application directory
directory '/opt/myapp' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# OK - Using Chef package resource
package 'curl' do
  action :install
end

# OK - Application service (not system service)
service 'nginx' do
  action [:enable, :start]
end

# OK - Application config file
template '/opt/myapp/config.yml' do
  source 'config.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
```

### 4.6 Create Compliant Recipe

```ruby
# ~/cookbooks/my-app-cookbook/recipes/compliant.rb
# frozen_string_literal: true

#
# Cookbook:: my-app-cookbook
# Recipe:: compliant
#
# This recipe follows all best practices
#

# Create application directory
directory '/opt/myapp' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Install packages using Chef resource
package %w(curl wget vim) do
  action :install
end

# Deploy application config
template '/opt/myapp/app.conf' do
  source 'app.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    app_port: 8080,
    log_level: 'info'
  )
  notifies :restart, 'service[nginx]', :delayed
end

# Manage application log directory
directory '/opt/myapp/logs' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Log rotation (allowed /etc path)
file '/etc/logrotate.d/myapp' do
  content <<~CONF
    /opt/myapp/logs/*.log {
        daily
        rotate 7
        compress
        missingok
    }
  CONF
  owner 'root'
  group 'root'
  mode '0644'
end

# Environment profile (allowed /etc path)
file '/etc/profile.d/myapp.sh' do
  content <<~SH
    export MYAPP_HOME=/opt/myapp
    export PATH=$PATH:/opt/myapp/bin
  SH
  owner 'root'
  group 'root'
  mode '0644'
end

# Remote file download using Chef resource
remote_file '/opt/myapp/artifact.tar.gz' do
  source 'https://releases.example.com/myapp-1.0.tar.gz'
  owner 'root'
  mode '0644'
  action :create
  not_if { ::File.exist?('/opt/myapp/artifact.tar.gz') }
end

# Cron job using Chef resource
cron 'myapp_cleanup' do
  minute '0'
  hour '3'
  command '/opt/myapp/scripts/cleanup.sh'
  user 'root'
  action :create
end
```

### 4.7 Create Template Files

```bash
# Create templates directory
mkdir -p ~/cookbooks/my-app-cookbook/templates

# Create config template
cat > ~/cookbooks/my-app-cookbook/templates/config.yml.erb << 'EOF'
# Application Configuration
app:
  name: myapp
  version: 1.0.0
  port: 8080
EOF

cat > ~/cookbooks/my-app-cookbook/templates/app.conf.erb << 'EOF'
# Application Config
port = <%= @app_port %>
log_level = <%= @log_level %>
EOF
```

---

## Part 5: Run Cookstyle (Developer Local Testing)

### 5.1 Install Dependencies

```bash
cd ~/cookbooks/my-app-cookbook
bundle install
```

### 5.2 Run Cookstyle - See All Violations

```bash
# Run against default recipe (with violations)
cookstyle recipes/default.rb
```

**Expected Output:**
```
Inspecting 1 file
E

Offenses:

recipes/default.rb:16:1: E: Barclays/Barc001NoLocalUsers: BARC001: Local user manipulation is not allowed.
user 'app_user' do
^^^^^^^^^^^^^^^^

recipes/default.rb:23:1: E: Barclays/Barc005EtcBlacklist: BARC005: Modification of /etc/sudoers.d/app_user is not allowed.
file '/etc/sudoers.d/app_user' do
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

recipes/default.rb:30:3: E: Barclays/Barc006NoReboot: BARC006: Reboot/shutdown commands are not allowed.
  command 'reboot'
  ^^^^^^^^^^^^^^^^

... (more violations)

1 file inspected, 7 offenses detected
```

### 5.3 Run Against Compliant Recipe

```bash
cookstyle recipes/compliant.rb
```

**Expected Output:**
```
Inspecting 1 file
.

1 file inspected, no offenses detected
```

### 5.4 Run Against Entire Cookbook

```bash
# Check all files
cookstyle .

# With summary
cookstyle . --format simple

# Generate JSON report
cookstyle . --format json --out report.json

# Generate HTML report (visual)
cookstyle . --format html --out report.html
```

### 5.5 Auto-correct What Can Be Fixed

```bash
# Auto-correct safe issues
cookstyle --autocorrect .

# See what was corrected
git diff
```

---

## Part 6: Jenkins Pipeline Integration

### 6.1 Create Jenkinsfile in Cookbook

```groovy
// ~/cookbooks/my-app-cookbook/Jenkinsfile

pipeline {
    agent any

    environment {
        BARC_RULES_PATH = '/opt/chef-cookstyle/b-foodcritic-rules'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    bundle install --path vendor/bundle
                '''
            }
        }

        stage('Cookstyle Lint') {
            steps {
                script {
                    def exitCode = sh(
                        script: '''
                            bundle exec cookstyle . \
                                --format json --out cookstyle-report.json \
                                --format html --out cookstyle-report.html \
                                --format progress
                        ''',
                        returnStatus: true
                    )

                    if (exitCode != 0) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }

        stage('Parse Results') {
            steps {
                script {
                    if (fileExists('cookstyle-report.json')) {
                        def report = readJSON file: 'cookstyle-report.json'
                        def summary = report.summary

                        echo """
                        ╔════════════════════════════════════════╗
                        ║      COOKSTYLE ANALYSIS RESULTS        ║
                        ╠════════════════════════════════════════╣
                        ║  Files Inspected: ${summary.inspected_file_count}
                        ║  Total Offenses:  ${summary.offense_count}
                        ║  Errors:          ${report.files.collect { it.offenses.findAll { o -> o.severity == 'error' } }.flatten().size()}
                        ║  Warnings:        ${report.files.collect { it.offenses.findAll { o -> o.severity == 'warning' } }.flatten().size()}
                        ╚════════════════════════════════════════╝
                        """

                        // Fail on errors
                        def errors = report.files.collect {
                            it.offenses.findAll { o -> o.severity == 'error' }
                        }.flatten()

                        if (errors.size() > 0) {
                            error "Found ${errors.size()} error-level violations. Build failed."
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // Archive reports
            archiveArtifacts artifacts: 'cookstyle-report.*', allowEmptyArchive: true

            // Publish HTML report
            publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'cookstyle-report.html',
                reportName: 'Cookstyle Report'
            ])
        }

        success {
            echo '✅ Cookstyle validation passed!'
        }

        failure {
            echo '❌ Cookstyle validation failed. Check report for details.'
        }
    }
}
```

### 6.2 Create Jenkins Job

1. **New Item** → **Pipeline**
2. **Pipeline from SCM** → Git
3. Enter repository URL
4. Script Path: `Jenkinsfile`
5. **Save**

### 6.3 Configure Git Webhook (Optional)

1. In your Git repository settings
2. Add webhook: `http://<EC2-IP>:8080/github-webhook/`
3. Content type: `application/json`
4. Events: Push events

---

## Part 7: Complete Demo Script

### 7.1 Run Full Demo

```bash
#!/bin/bash
# demo.sh - Complete POC demonstration

echo "═══════════════════════════════════════════════════════════"
echo "  COOKSTYLE POC DEMONSTRATION"
echo "═══════════════════════════════════════════════════════════"
echo ""

cd ~/cookbooks/my-app-cookbook

echo "📁 Step 1: Cookbook Structure"
echo "─────────────────────────────"
find . -type f -name "*.rb" | head -10
echo ""

echo "🔍 Step 2: Running Cookstyle on VIOLATING recipe"
echo "─────────────────────────────────────────────────"
cookstyle recipes/default.rb --format simple 2>&1 | head -30
echo ""

echo "✅ Step 3: Running Cookstyle on COMPLIANT recipe"
echo "─────────────────────────────────────────────────"
cookstyle recipes/compliant.rb
echo ""

echo "📊 Step 4: Generate JSON Report"
echo "─────────────────────────────────"
cookstyle . --format json --out report.json
echo "Report saved to report.json"
cat report.json | python3 -m json.tool | head -40
echo ""

echo "📋 Step 5: Summary"
echo "──────────────────"
cat report.json | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f\"Files: {data['summary']['inspected_file_count']}\")
print(f\"Offenses: {data['summary']['offense_count']}\")
"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  DEMO COMPLETE"
echo "═══════════════════════════════════════════════════════════"
```

---

## Part 8: Expected Results

### Violations Detected

| Rule | Count | Severity | Description |
|------|-------|----------|-------------|
| BARC001 | 1 | Error | User creation |
| BARC005 | 1 | Error | /etc/sudoers modification |
| BARC006 | 1 | Error | Reboot command |
| BARC009 | 1 | Error | iptables command |
| BARC016 | 1 | Convention | apt-get instead of package |
| BARC017 | 1 | Error | auditd service |
| BARC019 | 1 | Error | chmod 777 |

### Build Status

- **Errors found** → Build **FAILS** (blocks merge)
- **Only warnings** → Build **UNSTABLE** (allows merge with review)
- **No violations** → Build **SUCCESS** (auto-merge allowed)

---

## Quick Reference Commands

```bash
# Basic check
cookstyle .

# Auto-fix
cookstyle --autocorrect .

# Specific file
cookstyle recipes/default.rb

# JSON report
cookstyle --format json --out report.json .

# HTML report
cookstyle --format html --out report.html .

# Fail on warnings too
cookstyle --fail-level warning .

# Show cop names
cookstyle --format offenses .

# List all cops
cookstyle --show-cops
```
