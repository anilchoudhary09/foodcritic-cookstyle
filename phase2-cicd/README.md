# Phase 2: CI/CD Pipeline for Cookbook Compliance Testing

This phase implements a Jenkins-based CI/CD pipeline for automated cookbook compliance testing using Cookstyle with Barclays custom rules.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    STASH/BITBUCKET REPOSITORIES                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  chef-ci-pipeline   │  │ b-cookstyle-rules│  │  Cookbook   │ │
│  │  (THIS REPO)        │  │  (Rules)         │  │  (To Test)  │ │
│  │                     │  │                  │  │             │ │
│  │  • Jenkinsfile      │  │  • barc_cops.rb  │  │  • recipes  │ │
│  │  • scripts/         │  │  • Gemfile       │  │  • metadata │ │
│  │  • templates/       │  │  • rules.rb      │  │  • etc.     │ │
│  └─────────┬───────────┘  └────────┬─────────┘  └──────┬──────┘ │
│            │                       │                    │        │
└────────────┼───────────────────────┼────────────────────┼────────┘
             │                       │                    │
             ▼                       ▼                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                         JENKINS PIPELINE                         │
├─────────────────────────────────────────────────────────────────┤
│  1. Checkout chef-ci-pipeline (Jenkinsfile + scripts)           │
│  2. Fetch cookbook from Stash                                   │
│  3. Fetch b-cookstyle-rules from Stash                          │
│  4. Run Cookstyle compliance checks                             │
│  5. Generate HTML/JSON/JUnit reports                            │
│  6. Publish results                                              │
└─────────────────────────────────────────────────────────────────┘
```

## Overview

The pipeline automates the following workflow:
1. Accept cookbook repository URL and branch as parameters
2. Fetch the cookbook from Stash/Bitbucket
3. Fetch the b-cookstyle-rules from Stash/Bitbucket
4. Run Cookstyle compliance checks with custom BARC rules
5. Generate formatted reports (HTML, JSON, JUnit)

## Directory Structure

```
phase2-cicd/
├── Jenkinsfile                    # Main Jenkins pipeline
├── config/
│   ├── pipeline-config.yaml       # Pipeline configuration
│   └── credentials-template.yaml  # Credentials template (do not commit actual creds)
├── scripts/
│   ├── fetch_cookbook.sh          # Fetch cookbook from Chef Server/Bitbucket
│   ├── run_cookstyle.sh           # Run cookstyle with custom rules
│   └── generate_report.rb         # Generate formatted reports
├── templates/
│   ├── report.html.erb            # HTML report template
│   └── email.html.erb             # Email notification template
└── docs/
    └── SETUP.md                   # Setup instructions
```

## Prerequisites

- Jenkins 2.x with Pipeline support
- Ruby 2.7+ with Bundler
- Chef Workstation (for knife commands)
- Git access to Bitbucket
- Chef Server access (optional)

## Quick Start

1. **Configure credentials in Jenkins:**
   - `stash-credentials`: Stash/Bitbucket SSH key for cloning all repos

2. **Create a new Pipeline job in Jenkins**

3. **Point it to this repository's `phase2-cicd/Jenkinsfile`**
   - Repository: `ssh://git@stash.company.com:7999/chef/chef-ci-pipeline.git`
   - Script Path: `phase2-cicd/Jenkinsfile`

4. **Run with parameters:**
   - `COOKBOOK_NAME`: Name of the cookbook to test
   - `COOKBOOK_REPO_URL`: Stash URL of the cookbook repository
   - `COOKBOOK_BRANCH`: Branch name (default: master)
   - `COOKBOOK_SUBDIRECTORY`: Path if cookbook is in a subdirectory (optional)

### Example Run Parameters

```
COOKBOOK_NAME:         my-web-app
COOKBOOK_REPO_URL:     ssh://git@stash.company.com:7999/chef/my-web-app.git
COOKBOOK_BRANCH:       feature/new-recipe
COOKSTYLE_RULES_REPO:  ssh://git@stash.company.com:7999/chef/b-cookstyle-rules.git
```

## Pipeline Stages

| Stage | Description |
|-------|-------------|
| Validate Parameters | Verify required parameters are provided |
| Setup Workspace | Create directories, copy scripts |
| Fetch Sources | Clone cookbook and b-cookstyle-rules from Stash (parallel) |
| Verify Cookbook | Validate cookbook structure (metadata.rb exists) |
| Setup Ruby Environment | Install bundler and cookstyle dependencies |
| Run Cookstyle | Execute compliance checks |
| Generate Reports | Create HTML, JSON, JUnit reports |
| Publish Results | Archive artifacts and publish reports |
| Quality Gate | Fail build if violations found (configurable) |

## Configuration

### Build Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `COOKBOOK_NAME` | Yes | - | Name of the cookbook |
| `COOKBOOK_REPO_URL` | Yes | - | Stash URL of cookbook repo |
| `COOKBOOK_BRANCH` | No | `master` | Branch to test |
| `COOKBOOK_SUBDIRECTORY` | No | - | Subdirectory path if cookbook not at root |
| `COOKSTYLE_RULES_REPO` | No | (configured) | Stash URL for b-cookstyle-rules |
| `COOKSTYLE_RULES_BRANCH` | No | `master` | Rules branch |
| `AUTO_CORRECT` | No | `false` | Auto-fix violations |
| `FAIL_ON_VIOLATIONS` | No | `true` | Fail build on errors |
| `NOTIFICATION_EMAIL` | No | - | Email for notifications |

### Credentials Required

| Credential ID | Type | Purpose |
|---------------|------|---------|
| `stash-credentials` | SSH Key | Access to all Stash repositories |

## Reports

The pipeline generates multiple report formats:
- **HTML Report**: Visual report with color-coded violations
- **JSON Report**: Machine-readable format for integration
- **JUnit XML**: For Jenkins test result visualization

## Troubleshooting

See [docs/SETUP.md](docs/SETUP.md) for detailed setup and troubleshooting guides.
