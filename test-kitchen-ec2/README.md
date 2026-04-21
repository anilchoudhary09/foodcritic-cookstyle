# Test Kitchen EC2 - Chef Cookbook Testing

This project provides Test Kitchen configuration for testing Chef cookbooks on an existing EC2 instance, integrated with Jenkins CI/CD.

## Overview

- **Test Kitchen** with proxy driver connects to existing EC2 instance
- **Cookstyle** validation using BARC security rules
- **Jenkins Pipeline** for automated testing
- **Chef Client 18/19** compatibility testing

## Prerequisites

### Local Development
- Chef Workstation 25+
- SSH access to EC2 instance
- SSH private key (.pem file)

### Jenkins
- Chef Workstation installed on Jenkins agent
- Jenkins credentials configured:
  - `ec2-kitchen-host`: EC2 hostname
  - `ec2-ssh-key`: SSH private key (Secret file)

## Quick Start

### Local Usage

```bash
# Navigate to project
cd test-kitchen-ec2

# Set environment variables (or use kitchen.local.yml)
export EC2_HOST="ec2-xx-xx-xx-xx.region.compute.amazonaws.com"
export SSH_KEY_PATH="/path/to/your-key.pem"

# List available instances
kitchen list

# Run cookstyle validation first
cookstyle ../cookbooks/compliant-cookbook --config ../cookbooks/b-cookstyle-rules/.rubocop.yml

# Vendor cookbooks
berks vendor cookbooks

# Run converge
kitchen converge compliant-amazon-linux-2023

# Run full test cycle
kitchen test compliant-amazon-linux-2023

# Destroy (cleanup)
kitchen destroy
```

### Jenkins Usage

1. Create a new Pipeline job
2. Point SCM to this repository
3. Configure credentials:
   - `ec2-kitchen-host`: Your EC2 hostname
   - `ec2-ssh-key`: Your SSH private key
4. Run the pipeline with parameters:
   - **SUITE**: `compliant`, `my-app`, or `all`
   - **ACTION**: `converge`, `verify`, `test`, `destroy`
   - **RUN_COOKSTYLE**: Enable/disable Cookstyle validation
   - **COOKBOOK_TO_TEST**: Cookbook to validate

## Directory Structure

```
test-kitchen-ec2/
├── Jenkinsfile           # CI/CD pipeline
├── kitchen.yml           # Test Kitchen config
├── kitchen.local.yml     # Local overrides (git-ignored)
├── Gemfile               # Ruby dependencies
├── Berksfile             # Cookbook dependencies
├── README.md             # This file
└── cookbooks/            # Vendored cookbooks (git-ignored)
```

## Test Suites

| Suite | Cookbook | Description |
|-------|----------|-------------|
| `compliant` | compliant-cookbook | Tests compliant patterns |
| `my-app` | my-app-cookbook | Tests application cookbook |

## Configuration

### kitchen.yml

The main configuration connects to your EC2 instance:

```yaml
driver:
  name: proxy
  host: <%= ENV['EC2_HOST'] || 'your-ec2-host' %>

transport:
  name: ssh
  username: ec2-user
  ssh_key: <%= ENV['SSH_KEY_PATH'] || '~/.ssh/your-key.pem' %>
```

### kitchen.local.yml (Optional)

Create this file for local overrides (git-ignored):

```yaml
---
transport:
  ssh_key: /path/to/your-key.pem

driver:
  host: your-ec2-hostname

platforms:
  - name: amazon-linux-2023
    driver:
      host: your-ec2-hostname
    transport:
      hostname: your-ec2-hostname
```

## Jenkins Pipeline Stages

1. **Checkout** - Clone repository
2. **Environment Setup** - Verify Chef Workstation
3. **Cookstyle Validation** - Run BARC rules
4. **Prepare Kitchen Config** - Inject credentials
5. **Resolve Dependencies** - Berks vendor
6. **Kitchen List** - Show available instances
7. **Kitchen Converge** - Run convergence
8. **Kitchen Status** - Final status

## Cookstyle BARC Rules

The pipeline validates cookbooks against Barclays security rules:

```bash
# Run manually
cookstyle <cookbook> --config ../cookbooks/b-cookstyle-rules/.rubocop.yml
```

Rules include:
- BARC001-036 security checks
- No local users/groups
- No unauthorized /etc modifications
- No shell command antipatterns
- And more...

## Troubleshooting

### SSH Connection Failed
```bash
# Test SSH manually
ssh -i /path/to/key.pem ec2-user@ec2-hostname "echo Connected"
```

### Kitchen Proxy Issues
```bash
# Check kitchen config
kitchen diagnose compliant-amazon-linux-2023

# View logs
cat .kitchen/logs/compliant-amazon-linux-2023.log
```

### Chef Not Found on EC2
```bash
# SSH to EC2 and verify Chef
ssh ec2-user@ec2-hostname "chef-client --version"
```

## License

Apache-2.0

## Support

For issues with BARC rules, see `cookbooks/b-cookstyle-rules/README.md`
