# Pipeline Setup Guide

This document provides detailed instructions for setting up the Cookbook Compliance CI/CD Pipeline.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Jenkins Setup](#jenkins-setup)
3. [Credentials Configuration](#credentials-configuration)
4. [Pipeline Creation](#pipeline-creation)
5. [Running the Pipeline](#running-the-pipeline)
6. [Customization](#customization)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Software Requirements

| Component | Version | Purpose |
|-----------|---------|---------|
| Jenkins | 2.346+ | CI/CD server |
| Ruby | 3.1+ | Running Cookstyle |
| Bundler | 2.0+ | Managing Ruby gems |
| Git | 2.30+ | Source control |
| Chef Workstation | 23.0+ | Chef tools (knife) |

### Jenkins Plugins

Install these plugins via **Manage Jenkins > Plugins**:

- **Pipeline** - Core pipeline functionality
- **Git** - Git SCM integration
- **Credentials Binding** - Secure credential handling
- **HTML Publisher** - Publish HTML reports
- **JUnit** - Test result visualization
- **Email Extension** - Enhanced email notifications
- **AnsiColor** - Colored console output
- **Timestamper** - Build timestamps

### Network Requirements

- Access to Bitbucket server (for repository cloning)
- Access to Chef Server (if fetching cookbooks from Chef Server)
- Outbound HTTPS for RubyGems (gem installation)

---

## Jenkins Setup

### 1. Install Required Plugins

```groovy
// Via Jenkins Script Console (Manage Jenkins > Script Console)
Jenkins.instance.pluginManager.plugins.each{
  println ("${it.getShortName()}: ${it.getVersion()}")
}
```

Or install via CLI:
```bash
jenkins-cli install-plugin pipeline-model-definition git credentials-binding htmlpublisher junit email-ext ansicolor timestamper
```

### 2. Configure Jenkins Agent

The pipeline requires an agent with Chef Workstation installed. Options:

#### Option A: Dedicated Agent
Create a Jenkins agent with:
- Ruby 3.1+
- Chef Workstation
- Git

Label it as `chef-workstation`:

```
Jenkins > Manage Jenkins > Nodes > New Node
  Name: chef-workstation-agent
  Labels: chef-workstation
```

#### Option B: Docker Agent
Use the Chef Workstation Docker image:

```groovy
agent {
    docker {
        image 'chef/chefworkstation:latest'
        args '-u root'
    }
}
```

### 3. Configure Global Tools

Navigate to **Manage Jenkins > Tools**:

- **Ruby**: Add Ruby 3.1+ installation
- **Git**: Ensure Git is configured

---

## Credentials Configuration

### Bitbucket Credentials

1. Go to **Jenkins > Credentials > System > Global credentials**
2. Click **Add Credentials**

For **SSH Key** (recommended):
```
Kind: SSH Username with private key
ID: bitbucket-credentials
Username: git
Private Key: [Enter your SSH private key]
```

For **Username/Password**:
```
Kind: Username with password
ID: bitbucket-credentials
Username: your-username
Password: your-app-password
```

### Chef Server Credentials

1. Add **Secret File** credential:
```
Kind: Secret file
ID: chef-server-pem
File: [Upload your client.pem file]
Description: Chef Server client key
```

### Verify Credentials

Test credentials via Script Console:
```groovy
def creds = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
    com.cloudbees.plugins.credentials.common.StandardCredentials.class,
    Jenkins.instance
)
creds.each { println it.id }
```

---

## Pipeline Creation

### Method 1: Pipeline from SCM (Recommended)

1. **Create New Job**:
   - Click **New Item**
   - Enter name: `cookbook-compliance-check`
   - Select **Pipeline**
   - Click **OK**

2. **Configure Pipeline**:
   ```
   Definition: Pipeline script from SCM
   SCM: Git
   Repository URL: [your-repo-url]/b-cookstyle-rules.git
   Credentials: bitbucket-credentials
   Branch: */master
   Script Path: phase2-cicd/Jenkinsfile
   ```

3. **Save** the job

### Method 2: Inline Pipeline

1. Create Pipeline job as above
2. Select **Pipeline script**
3. Paste the contents of `Jenkinsfile`

### Configure Build Parameters

The pipeline auto-registers these parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| COOKBOOK_NAME | String | Cookbook to test (required) |
| SOURCE_TYPE | Choice | `bitbucket` or `chef-server` |
| BITBUCKET_REPO_URL | String | Repository URL |
| BRANCH | String | Git branch |
| COOKBOOK_VERSION | String | Chef Server version |
| AUTO_CORRECT | Boolean | Enable auto-fix |
| FAIL_ON_VIOLATIONS | Boolean | Fail on errors |
| NOTIFICATION_EMAIL | String | Email recipient |

---

## Running the Pipeline

### Via Jenkins UI

1. Navigate to the job
2. Click **Build with Parameters**
3. Fill in parameters:
   - **COOKBOOK_NAME**: `my-cookbook`
   - **SOURCE_TYPE**: `bitbucket`
   - **BITBUCKET_REPO_URL**: `ssh://git@bitbucket.company.com/chef/my-cookbook.git`
   - **BRANCH**: `master`
4. Click **Build**

### Via Jenkins API

```bash
curl -X POST "https://jenkins.company.com/job/cookbook-compliance-check/buildWithParameters" \
  --user "user:api-token" \
  --data-urlencode "COOKBOOK_NAME=my-cookbook" \
  --data-urlencode "SOURCE_TYPE=bitbucket" \
  --data-urlencode "BITBUCKET_REPO_URL=ssh://git@bitbucket.company.com/chef/my-cookbook.git"
```

### Via Jenkins CLI

```bash
java -jar jenkins-cli.jar -s https://jenkins.company.com/ \
  build cookbook-compliance-check \
  -p COOKBOOK_NAME=my-cookbook \
  -p SOURCE_TYPE=bitbucket \
  -p BITBUCKET_REPO_URL=ssh://git@bitbucket.company.com/chef/my-cookbook.git
```

---

## Customization

### Modify Pipeline Configuration

Edit `config/pipeline-config.yaml`:

```yaml
cookstyle:
  # Change minimum severity
  min_severity: "warning"

  # Add custom exclude patterns
  exclude_patterns:
    - "legacy/**/*"
```

### Add Custom Rules

1. Add cops to `b-cookstyle-rules/barc_cops.rb`
2. Update `.rubocop.yml` if needed
3. Test locally before deploying

### Custom Report Template

Edit `templates/email.html.erb` to customize email notifications.

### Webhook Integration

Add to Bitbucket repository settings:

```
URL: https://jenkins.company.com/generic-webhook-trigger/invoke?token=cookbook-compliance
Events: Push, Pull Request Created
```

---

## Troubleshooting

### Common Issues

#### "Cookbook not found"

```
Error: Cookbook directory not found
```

**Solution**: Verify the repository URL and credentials are correct.

#### "Permission denied (publickey)"

```
git@bitbucket.company.com: Permission denied (publickey)
```

**Solution**:
1. Verify SSH key is added to Jenkins credentials
2. Check key is added to Bitbucket user settings
3. Test SSH access: `ssh -T git@bitbucket.company.com`

#### "Chef Server authentication failed"

```
ERROR: Authentication failed
```

**Solution**:
1. Verify the .pem file is valid
2. Check Chef Server URL is correct
3. Verify the client exists on Chef Server

#### "Bundle install failed"

```
Could not locate Gemfile
```

**Solution**:
1. Ensure b-cookstyle-rules has a valid Gemfile
2. Check Ruby version compatibility
3. Try cleaning bundler cache: `bundle clean --force`

### Debug Mode

Enable debug output by adding to Jenkinsfile:

```groovy
environment {
    DEBUG = 'true'
}
```

### View Detailed Logs

1. Go to build page
2. Click **Console Output**
3. Look for error messages after `[ERROR]` tags

### Manual Testing

Test scripts locally:

```bash
# Test cookbook fetch
./scripts/fetch_cookbook.sh \
  --name my-cookbook \
  --source bitbucket \
  --repo-url git@bitbucket.company.com:chef/my-cookbook.git \
  --output ./test-output

# Test cookstyle run
./scripts/run_cookstyle.sh \
  --cookbook ./test-output/my-cookbook \
  --rules ../b-cookstyle-rules \
  --output ./reports
```

---

## Support

For issues or questions:
- Open a ticket in ServiceNow
- Contact: chef-team@company.com
- Slack: #chef-support
