# Foodcritic to Cookstyle Migration

This repository demonstrates the migration from **Foodcritic** (deprecated) to **Cookstyle** for Chef cookbook linting, including custom BARC (Barclays) security rules.

## Overview

Foodcritic was deprecated in 2019 and is no longer maintained. This project migrates existing Foodcritic rules to Cookstyle (RuboCop-based), providing:

- **200+ built-in Chef best practice rules**
- **Auto-correction capabilities** for many violations
- **Custom BARC security rules** (organization policies)
- **Jenkins CI/CD integration** with HTML reports
- **Dynamic cookbook selection** via pipeline parameters

## Repository Structure

```
foodcritic_cookstyle_convert/
├── Jenkinsfile                    # Dynamic pipeline with cookbook selection
├── cookbooks/
│   ├── b-cookstyle-rules/        # Custom BARC Cookstyle cops
│   │   └── lib/rubocop/cop/barclays/
│   ├── my-app-cookbook/           # Demo cookbook with VIOLATIONS
│   └── compliant-cookbook/        # Demo cookbook that PASSES
└── README.md
```

## Custom BARC Rules

The following custom Cookstyle cops enforce organizational security policies:

| Rule | Description | Severity |
|------|-------------|----------|
| `Barclays/Barc001NoLocalUsers` | Prohibits local user creation | Error |
| `Barclays/Barc002NoLocalGroups` | Prohibits local group creation | Error |
| `Barclays/Barc003NoRootSsh` | No SSH as root user | Error |
| `Barclays/Barc005EtcBlacklist` | Protected paths in /etc | Error |
| `Barclays/Barc006NoReboot` | No system reboots | Error |
| `Barclays/Barc007NoSelinux` | No SELinux modifications | Error |
| `Barclays/Barc008NoKillProcess` | No killing processes | Warning |
| `Barclays/Barc009NoFirewall` | No firewall/iptables changes | Error |
| `Barclays/Barc011NoRemoveFiles` | No dangerous file removal | Error |
| `Barclays/Barc016UseChefResources` | Use Chef resources, not shell | Warning |
| `Barclays/Barc017NoSystemServices` | No critical system services | Error |
| `Barclays/Barc019NoFindSudo` | No chmod 777 or find/sudo abuse | Error |

## Quick Start

### Local Usage

```bash
# Navigate to cookbook
cd cookbooks/my-app-cookbook

# Run cookstyle with custom rules
cookstyle . --format progress

# Generate JSON report
cookstyle . --format json --out cookstyle-report.json
```

### Jenkins Pipeline

The pipeline supports dynamic cookbook selection:

1. **Build with Parameters** → Select cookbook from dropdown
2. Choose `my-app-cookbook` (violations) or `compliant-cookbook` (clean)
3. View HTML report in build artifacts

#### Pipeline Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `COOKBOOK_NAME` | Choice | Select cookbook to validate |
| `FAIL_ON_VIOLATIONS` | Boolean | Fail build on errors (default: true) |

## Configuration

### Cookbook .rubocop.yml

Each cookbook includes a `.rubocop.yml` that loads the BARC rules:

```yaml
require:
  - ../b-cookstyle-rules/lib/rubocop-barclays

AllCops:
  TargetChefVersion: 18.0
  NewCops: enable
```

### Jenkins Requirements

- **Ruby 3.x** installed
- **Cookstyle** gem installed (`gem install cookstyle`)
- **HTML Publisher Plugin** for reports

## Test Cookbooks

### my-app-cookbook (Violations)

Intentionally contains violations for testing:
- Local user/group creation (BARC001, BARC002)
- System reboots (BARC006)
- Protected file modifications (BARC005)
- Dangerous shell commands (BARC011, BARC019)

**Expected Result:** ❌ BUILD FAILURE with 30+ violations

### compliant-cookbook (Clean)

Demonstrates compliant patterns:
- Uses Chef resources properly
- No security policy violations
- Follows best practices

**Expected Result:** ✅ BUILD SUCCESS

## Migration Guide

### Converting Foodcritic Rules to Cookstyle

1. **Create cop file** in `lib/rubocop/cop/barclays/`
2. **Inherit from** `RuboCop::Cop::Base`
3. **Define node matchers** using RuboCop AST patterns
4. **Register offenses** with `add_offense`

Example:
```ruby
module RuboCop
  module Cop
    module Barclays
      class Barc001NoLocalUsers < Base
        MSG = 'BARC001: Do not create local users'

        def_node_matcher :user_resource?, <<~PATTERN
          (block (send nil? :user ...) ...)
        PATTERN

        def on_block(node)
          return unless user_resource?(node)
          add_offense(node)
        end
      end
    end
  end
end
```

## HTML Reports

The pipeline generates beautiful HTML reports showing:
- Summary statistics (files, offenses, severity breakdown)
- BARC vs Chef violation categorization
- File-by-file violation details
- Color-coded severity indicators

Reports are archived and accessible via Jenkins build artifacts.

## Contributing

1. Add new cops to `cookbooks/b-cookstyle-rules/lib/rubocop/cop/barclays/`
2. Register in `rubocop-barclays.rb`
3. Add test cases to `my-app-cookbook/recipes/violations.rb`
4. Run pipeline to verify detection

## License

MIT License - See [LICENSE](LICENSE) for details.
