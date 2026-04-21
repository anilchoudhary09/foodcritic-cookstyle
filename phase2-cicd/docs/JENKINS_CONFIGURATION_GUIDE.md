# Jenkins Configuration Guide - Cookbook Compliance Pipeline

A step-by-step guide to configure Jenkins for running the Cookbook Compliance CI/CD Pipeline.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         JENKINS PIPELINE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌──────────────────┐    ┌──────────────────┐    ┌──────────────┐ │
│   │  chef-ci-pipeline │    │ b-cookstyle-rules│    │  cookbook    │ │
│   │  (This Repo)      │    │  (Rules Repo)    │    │  (To Test)   │ │
│   │                   │    │                  │    │              │ │
│   │  - Jenkinsfile    │    │  - barc_cops.rb  │    │  - recipes/  │ │
│   │  - Scripts        │    │  - Gemfile       │    │  - metadata  │ │
│   │  - Templates      │    │  - Rules         │    │  - etc.      │ │
│   └────────┬──────────┘    └────────┬─────────┘    └──────┬───────┘ │
│            │                        │                      │         │
│            ▼                        ▼                      ▼         │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                    JENKINS WORKSPACE                         │   │
│   │                                                              │   │
│   │   1. Checkout chef-ci-pipeline (contains Jenkinsfile)       │   │
│   │   2. Fetch cookbook from Stash → cookbook-under-test/       │   │
│   │   3. Fetch b-cookstyle-rules from Stash → b-cookstyle-rules/│   │
│   │   4. Run Cookstyle with custom rules                        │   │
│   │   5. Generate reports → reports/                            │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

REPOSITORIES (All in Stash/Bitbucket):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. chef-ci-pipeline      → Contains Jenkinsfile, scripts, templates
2. b-cookstyle-rules     → Contains custom Cookstyle rules (BARC cops)
3. <cookbook-name>       → Any cookbook to be tested
```

---

## Table of Contents

1. [Step 1: Install Required Plugins](#step-1-install-required-plugins)
2. [Step 2: Configure Credentials](#step-2-configure-credentials)
3. [Step 3: Configure Jenkins Agent](#step-3-configure-jenkins-agent)
4. [Step 4: Create the Pipeline Job](#step-4-create-the-pipeline-job)
5. [Step 5: Configure Webhook (Optional)](#step-5-configure-webhook-optional)
6. [Step 6: Test the Pipeline](#step-6-test-the-pipeline)
7. [Step 7: Configure Email Notifications](#step-7-configure-email-notifications)

---

## Step 1: Install Required Plugins

### 1.1 Navigate to Plugin Manager

```
Jenkins Dashboard → Manage Jenkins → Plugins → Available plugins
```

### 1.2 Search and Install These Plugins

| Plugin Name | Purpose |
|-------------|---------|
| **Pipeline** | Core pipeline functionality |
| **Pipeline: Stage View** | Visual stage representation |
| **Git** | Git SCM integration |
| **Credentials Binding** | Secure credential handling |
| **SSH Credentials** | SSH key support |
| **HTML Publisher** | Publish HTML reports |
| **JUnit** | Test result visualization |
| **Email Extension** | Enhanced email notifications |
| **AnsiColor** | Colored console output |
| **Timestamper** | Build timestamps |
| **Generic Webhook Trigger** | Webhook integration (optional) |

### 1.3 Installation Steps

1. In the search box, type each plugin name
2. Check the checkbox next to the plugin
3. After selecting all plugins, click **"Install"**
4. Check **"Restart Jenkins when installation is complete"**
5. Wait for Jenkins to restart

```
┌─────────────────────────────────────────────────────────────┐
│  Available plugins                              🔍 Search   │
├─────────────────────────────────────────────────────────────┤
│  ☑ Pipeline                                                 │
│  ☑ Git                                                      │
│  ☑ HTML Publisher                                           │
│  ☑ JUnit                                                    │
│  ☑ Email Extension                                          │
│  ☑ AnsiColor                                                │
│  ☑ Timestamper                                              │
│  ☑ Generic Webhook Trigger                                  │
├─────────────────────────────────────────────────────────────┤
│                                    [ Install ]              │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 2: Configure Credentials

### 2.1 Navigate to Credentials

```
Jenkins Dashboard → Manage Jenkins → Credentials → System → Global credentials (unrestricted)
```

Or use this direct path:
```
Jenkins Dashboard → Manage Jenkins → Credentials
    → Click "(global)" under "Stores scoped to Jenkins"
    → Click "Add Credentials"
```

### 2.2 Add Stash/Bitbucket SSH Credentials

Click **"Add Credentials"** and fill in:

```
┌─────────────────────────────────────────────────────────────┐
│  Add Credentials                                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Kind:        [ SSH Username with private key      ▼]      │
│                                                             │
│  Scope:       [ Global (Jenkins, nodes, items...) ▼]       │
│                                                             │
│  ID:          [ stash-credentials                  ]        │
│               (This ID is used in the Jenkinsfile)          │
│                                                             │
│  Description: [ Stash/Bitbucket SSH access         ]        │
│                                                             │
│  Username:    [ git                                ]        │
│                                                             │
│  Private Key: ◉ Enter directly                              │
│               ○ From a file on Jenkins controller           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ -----BEGIN OPENSSH PRIVATE KEY-----                 │   │
│  │ b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAA │   │
│  │ AAAABLAAAAMwAAAAtzc2gtZWQyNTUxOQAAACBhD8Aa+tQV │   │
│  │ [Paste your private key here]                       │   │
│  │ -----END OPENSSH PRIVATE KEY-----                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Passphrase:  [ ******** ] (if key is encrypted)           │
│                                                             │
│                              [ Create ]  [ Cancel ]         │
└─────────────────────────────────────────────────────────────┘
```

**Field Values:**
| Field | Value |
|-------|-------|
| Kind | SSH Username with private key |
| Scope | Global |
| ID | `stash-credentials` |
| Description | Stash/Bitbucket SSH access |
| Username | `git` |
| Private Key | Paste your SSH private key content |

> **Important:** The credential ID must be exactly `stash-credentials` as this is referenced in the Jenkinsfile.

### 2.3 Add Chef Server Credentials (If Using Chef Server)

Click **"Add Credentials"** again:

```
┌─────────────────────────────────────────────────────────────┐
│  Add Credentials                                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Kind:        [ Secret file                        ▼]      │
│                                                             │
│  Scope:       [ Global (Jenkins, nodes, items...) ▼]       │
│                                                             │
│  ID:          [ chef-server-pem                    ]        │
│                                                             │
│  Description: [ Chef Server client key             ]        │
│                                                             │
│  File:        [ Choose File ]  client.pem                  │
│                                                             │
│                              [ Create ]  [ Cancel ]         │
└─────────────────────────────────────────────────────────────┘
```

**Field Values:**
| Field | Value |
|-------|-------|
| Kind | Secret file |
| Scope | Global |
| ID | `chef-server-pem` |
| Description | Chef Server client key |
| File | Upload your `.pem` file |

### 2.4 Verify Credentials

After adding, you should see:

```
┌─────────────────────────────────────────────────────────────┐
│  Global credentials (unrestricted)                          │
├─────────────────────────────────────────────────────────────┤
│  ID                      │ Name                             │
├─────────────────────────────────────────────────────────────┤
│  stash-credentials       │ Stash/Bitbucket SSH access       │
│  chef-server-pem         │ Chef Server client key (optional)│
└─────────────────────────────────────────────────────────────┘
```

---

## Step 3: Configure Jenkins Agent

### Option A: Use Existing Agent with Chef Workstation

If you have an agent with Chef Workstation installed:

1. Go to **Manage Jenkins → Nodes**
2. Click on your agent
3. Click **Configure**
4. Add label: `chef-workstation`
5. Save

```
┌─────────────────────────────────────────────────────────────┐
│  Configure Node                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Name:        [ linux-build-agent                  ]        │
│                                                             │
│  Labels:      [ chef-workstation linux ruby        ]        │
│               (Space-separated labels)                      │
│                                                             │
│                                    [ Save ]                 │
└─────────────────────────────────────────────────────────────┘
```

### Option B: Create New Agent

1. Go to **Manage Jenkins → Nodes → New Node**

```
┌─────────────────────────────────────────────────────────────┐
│  New Node                                                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Node name:   [ chef-workstation-agent             ]        │
│                                                             │
│  Type:        ◉ Permanent Agent                             │
│               ○ Copy Existing Node                          │
│                                                             │
│                              [ Create ]                     │
└─────────────────────────────────────────────────────────────┘
```

2. Configure the agent:

```
┌─────────────────────────────────────────────────────────────┐
│  Configure Node: chef-workstation-agent                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  # of executors:    [ 2                            ]        │
│                                                             │
│  Remote root dir:   [ /home/jenkins/agent          ]        │
│                                                             │
│  Labels:            [ chef-workstation             ]        │
│                                                             │
│  Usage:             [ Use this node as much as possible ▼] │
│                                                             │
│  Launch method:     [ Launch agent via SSH         ▼]      │
│                                                             │
│    Host:            [ agent-hostname.company.com   ]        │
│    Credentials:     [ jenkins-agent-ssh-key        ▼]      │
│                                                             │
│                                    [ Save ]                 │
└─────────────────────────────────────────────────────────────┘
```

### Option C: Use Docker Agent (No Separate Node Required)

If using Docker, the pipeline will automatically use the Chef Workstation image. Modify the Jenkinsfile agent section:

```groovy
agent {
    docker {
        image 'chef/chefworkstation:latest'
        args '-u root'
    }
}
```

---

## Step 4: Create the Pipeline Job

### 4.1 Create New Pipeline

1. From Jenkins Dashboard, click **"New Item"**

```
┌─────────────────────────────────────────────────────────────┐
│  Enter an item name                                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [ cookbook-compliance-check                       ]        │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│    📁 Freestyle project                                     │
│                                                             │
│    📋 Pipeline                              ← SELECT THIS   │
│       Orchestrates long-running activities                  │
│                                                             │
│    📁 Multi-configuration project                           │
│                                                             │
│    📁 Folder                                                │
│                                                             │
│                              [ OK ]                         │
└─────────────────────────────────────────────────────────────┘
```

2. Enter name: `cookbook-compliance-check`
3. Select **"Pipeline"**
4. Click **"OK"**

### 4.2 Configure General Settings

```
┌─────────────────────────────────────────────────────────────┐
│  General                                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ☑ Discard old builds                                       │
│    Strategy: Log Rotation                                   │
│    Days to keep builds: [ 30    ]                          │
│    Max # of builds to keep: [ 50 ]                         │
│                                                             │
│  ☑ This project is parameterized                            │
│    (Parameters will be auto-created from Jenkinsfile)       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Configure Pipeline Section

Scroll down to **"Pipeline"** section:

```
┌─────────────────────────────────────────────────────────────┐
│  Pipeline                                                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Definition: [ Pipeline script from SCM            ▼]      │
│                                                             │
│  SCM:        [ Git                                 ▼]      │
│                                                             │
│  Repositories:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Repository URL:                                      │   │
│  │ [ ssh://git@stash.company.com:7999/chef/chef-ci-pipeline.git ]│
│  │  ↑ This is the PIPELINE repo, NOT b-cookstyle-rules │   │
│  │                                                      │   │
│  │ Credentials:                                         │   │
│  │ [ stash-credentials (Stash/Bitbucket SSH access) ▼] │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Branches to build:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Branch Specifier: [ */master                     ]   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Script Path:   [ phase2-cicd/Jenkinsfile          ]        │
│                                                             │
│  ☐ Lightweight checkout                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Fill in these values:**

| Field | Value |
|-------|-------|
| Definition | Pipeline script from SCM |
| SCM | Git |
| Repository URL | `ssh://git@stash.company.com:7999/chef/chef-ci-pipeline.git` |
| Credentials | stash-credentials |
| Branch Specifier | `*/master` |
| Script Path | `phase2-cicd/Jenkinsfile` |

> **Note:** The Repository URL should point to the **pipeline repository** (chef-ci-pipeline), NOT to b-cookstyle-rules. The pipeline will fetch b-cookstyle-rules separately during execution.

### 4.4 Save the Job

Click **"Save"** at the bottom of the page.

---

## Step 5: Configure Webhook (Optional)

For automatic triggers when code is pushed to Bitbucket:

### 5.1 Create Webhook Job

Repeat Step 4 to create another pipeline job named `cookbook-compliance-webhook` but use:

| Field | Value |
|-------|-------|
| Script Path | `phase2-cicd/Jenkinsfile.webhook` |

### 5.2 Get Webhook URL

After creating the job, the webhook URL is:

```
https://jenkins.company.com/generic-webhook-trigger/invoke?token=cookbook-compliance-webhook
```

### 5.3 Configure Bitbucket Webhook

1. Go to Bitbucket repository settings
2. Navigate to **Webhooks**
3. Click **Create webhook**

```
┌─────────────────────────────────────────────────────────────┐
│  Create Webhook                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Name:   [ Jenkins Compliance Check               ]         │
│                                                             │
│  URL:    [ https://jenkins.company.com/generic-webhook-trigger/invoke?token=cookbook-compliance-webhook ]│
│                                                             │
│  Status: ◉ Active  ○ Inactive                               │
│                                                             │
│  Events:                                                    │
│    Repository:                                              │
│      ☑ Push                                                 │
│    Pull Request:                                            │
│      ☑ Opened                                               │
│      ☑ Source branch updated                                │
│                                                             │
│                              [ Create ]                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 6: Test the Pipeline

### 6.1 Run First Build

1. Go to your pipeline job: `cookbook-compliance-check`
2. Click **"Build with Parameters"**

```
┌─────────────────────────────────────────────────────────────┐
│  Build with Parameters                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ═══════════════════════════════════════════════════════   │
│  COOKBOOK PARAMETERS                                        │
│  ═══════════════════════════════════════════════════════   │
│                                                             │
│  COOKBOOK_NAME *                                            │
│  [ my-application-cookbook                         ]        │
│  Name of the cookbook to test (required)                    │
│                                                             │
│  COOKBOOK_REPO_URL *                                        │
│  [ ssh://git@stash.company.com:7999/chef/my-application-cookbook.git ]│
│  Stash repository URL for the cookbook                      │
│                                                             │
│  COOKBOOK_BRANCH                                            │
│  [ master                                          ]        │
│  Branch of the cookbook to test                             │
│                                                             │
│  COOKBOOK_SUBDIRECTORY                                      │
│  [                                                 ]        │
│  Subdirectory within repo if cookbook is not at root        │
│  (e.g., "cookbooks/my-cookbook" - leave empty if at root)   │
│                                                             │
│  ═══════════════════════════════════════════════════════   │
│  COOKSTYLE RULES PARAMETERS                                 │
│  ═══════════════════════════════════════════════════════   │
│                                                             │
│  COOKSTYLE_RULES_REPO                                       │
│  [ ssh://git@stash.company.com:7999/chef/b-cookstyle-rules.git ]│
│  Stash URL for b-cookstyle-rules repository                 │
│                                                             │
│  COOKSTYLE_RULES_BRANCH                                     │
│  [ master                                          ]        │
│  Branch of b-cookstyle-rules to use                         │
│                                                             │
│  ═══════════════════════════════════════════════════════   │
│  PIPELINE BEHAVIOR                                          │
│  ═══════════════════════════════════════════════════════   │
│                                                             │
│  AUTO_CORRECT                                               │
│  ☐ Attempt to auto-correct fixable violations              │
│                                                             │
│  FAIL_ON_VIOLATIONS                                         │
│  ☑ Fail the build if violations are found                  │
│                                                             │
│  SEVERITY_THRESHOLD                                         │
│  [ convention                                      ▼]      │
│                                                             │
│  NOTIFICATION_EMAIL                                         │
│  [ team@company.com                                ]        │
│  Email address for notifications (optional)                 │
│                                                             │
│                              [ Build ]                      │
└─────────────────────────────────────────────────────────────┘
```

### Example: Testing a Cookbook in a Subdirectory

If your cookbook is inside a monorepo structure like:
```
my-repo/
├── cookbooks/
│   ├── web-server/
│   │   ├── metadata.rb
│   │   └── recipes/
│   └── database/
│       ├── metadata.rb
│       └── recipes/
└── scripts/
```

To test the `web-server` cookbook:
- **COOKBOOK_NAME:** `web-server`
- **COOKBOOK_REPO_URL:** `ssh://git@stash.company.com:7999/chef/my-repo.git`
- **COOKBOOK_SUBDIRECTORY:** `cookbooks/web-server`

### 6.2 Monitor Build Progress

Click on the build number to see progress:

```
┌─────────────────────────────────────────────────────────────┐
│  #1 - cookbook-compliance-check                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┬──────────────┬──────────────┬───────────┐│
│  │   Validate   │   Checkout   │    Fetch     │   Setup   ││
│  │  Parameters  │    Rules     │   Cookbook   │   Env     ││
│  │      ✓       │      ✓       │      ✓       │    ⟳     ││
│  │    2s        │     15s      │     20s      │  running  ││
│  └──────────────┴──────────────┴──────────────┴───────────┘│
│                                                             │
│  ┌──────────────┬──────────────┬──────────────┐            │
│  │     Run      │   Generate   │   Publish    │            │
│  │  Cookstyle   │   Reports    │   Results    │            │
│  │   pending    │   pending    │   pending    │            │
│  └──────────────┴──────────────┴──────────────┘            │
│                                                             │
│  Console Output  │  Pipeline Steps  │  Compliance Report    │
└─────────────────────────────────────────────────────────────┘
```

### 6.3 View Results

After completion:

1. **Console Output**: Full build log
2. **Cookstyle Compliance Report**: HTML report (left sidebar)
3. **Test Results**: JUnit test visualization

---

## Step 7: Configure Email Notifications

### 7.1 Configure SMTP Settings

```
Jenkins Dashboard → Manage Jenkins → System → E-mail Notification
```

```
┌─────────────────────────────────────────────────────────────┐
│  E-mail Notification                                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  SMTP server:          [ smtp.company.com          ]        │
│                                                             │
│  Default user e-mail suffix: [ @company.com        ]        │
│                                                             │
│  ☑ Use SMTP Authentication                                  │
│    User Name:          [ jenkins-notifications     ]        │
│    Password:           [ ********                  ]        │
│                                                             │
│  ☑ Use SSL                                                  │
│                                                             │
│  SMTP Port:            [ 465                       ]        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Configure Extended E-mail Notification

```
Jenkins Dashboard → Manage Jenkins → System → Extended E-mail Notification
```

```
┌─────────────────────────────────────────────────────────────┐
│  Extended E-mail Notification                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  SMTP server:          [ smtp.company.com          ]        │
│  SMTP Port:            [ 465                       ]        │
│                                                             │
│  ☑ Use SSL                                                  │
│                                                             │
│  Default Content Type: [ HTML (text/html)          ▼]      │
│                                                             │
│  Default Recipients:   [ chef-team@company.com     ]        │
│                                                             │
│  Default Subject:      [ $PROJECT_NAME - Build #$BUILD_NUMBER - $BUILD_STATUS ]│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7.3 Test Email Configuration

1. In E-mail Notification section, click **"Test configuration by sending test e-mail"**
2. Enter your email address
3. Click **"Test configuration"**
4. Check if you receive the test email

---

## Quick Reference Card

### Repository Structure

| Repository | Purpose | Contains |
|------------|---------|----------|
| `chef-ci-pipeline` | Pipeline repository | Jenkinsfile, scripts, templates |
| `b-cookstyle-rules` | Custom rules | barc_cops.rb, Gemfile |
| `<cookbook-name>` | Cookbook to test | metadata.rb, recipes/, etc. |

### Credentials to Create

| ID | Type | Purpose |
|----|------|---------|
| `stash-credentials` | SSH Username with private key | Clone all repositories from Stash |
| `chef-server-pem` | Secret file | Chef Server access (optional) |

### Pipeline Jobs to Create

| Job Name | Repository | Jenkinsfile Path |
|----------|------------|------------------|
| `cookbook-compliance-check` | chef-ci-pipeline | `phase2-cicd/Jenkinsfile` |
| `cookbook-compliance-webhook` | chef-ci-pipeline | `phase2-cicd/Jenkinsfile.webhook` |

### Required Build Parameters

| Parameter | Required | Example |
|-----------|----------|---------|
| `COOKBOOK_NAME` | Yes | `my-app-cookbook` |
| `COOKBOOK_REPO_URL` | Yes | `ssh://git@stash.company.com:7999/chef/my-app.git` |
| `COOKBOOK_BRANCH` | No | `master` |
| `COOKBOOK_SUBDIRECTORY` | No | `cookbooks/my-app` |
| `COOKSTYLE_RULES_REPO` | No | `ssh://git@stash.company.com:7999/chef/b-cookstyle-rules.git` |
| `COOKSTYLE_RULES_BRANCH` | No | `master` |

### Stash URL Format

```
ssh://git@stash.company.com:7999/<PROJECT>/<REPO>.git

Examples:
ssh://git@stash.company.com:7999/CHEF/my-cookbook.git
ssh://git@stash.company.com:7999/CHEF/b-cookstyle-rules.git
ssh://git@stash.company.com:7999/INFRA/web-server-cookbook.git
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "Permission denied (publickey)" | Check SSH credentials with ID `stash-credentials` |
| "Could not find agent" | Verify agent label is `chef-workstation` |
| "Bundle install fails" | Ensure Ruby 3.1+ is installed on agent |
| "Cookbook not found" | Verify COOKBOOK_REPO_URL and COOKBOOK_SUBDIRECTORY |
| "No metadata.rb found" | Check if COOKBOOK_SUBDIRECTORY is needed |

---

## Next Steps

1. ✅ Verify credentials are configured
2. ✅ Verify agent is available with `chef-workstation` label
3. ✅ Create and test pipeline job
4. ✅ Configure webhook for automatic triggers
5. ✅ Set up email notifications
6. 📋 Add more cookbook repositories to test

For troubleshooting, see [SETUP.md](SETUP.md).
