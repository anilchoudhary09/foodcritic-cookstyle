# BARC Rules - Foodcritic to Cookstyle Migration

[![Parity](https://img.shields.io/badge/Parity-100%25-brightgreen)](cookbooks/b-cookstyle-rules/PARITY_CHECK_REPORT.html)
[![Rules](https://img.shields.io/badge/BARC%20Rules-36-blue)](cookbooks/b-cookstyle-rules/BARC_RULES_DOCUMENTATION.html)
[![Cookstyle](https://img.shields.io/badge/Cookstyle-7.32.8-orange)](https://docs.chef.io/workstation/cookstyle/)

Enterprise Chef cookbook linting with **36 custom BARC security rules** migrated from Foodcritic to Cookstyle with **100% functional parity**.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        BARC Rules System                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   rules.rb (Part 1)          barc_cops.rb          .rubocop.yml │
│   ┌─────────────────┐       ┌─────────────┐       ┌───────────┐ │
│   │ @ Variables     │  ───► │ 36 Cop      │  ◄─── │ Config    │ │
│   │ Lines 1-1767    │       │ Classes     │       │ Loader    │ │
│   │ ✅ MODIFY THIS  │       │ 1,446 lines │       └───────────┘ │
│   └─────────────────┘       │ ❌ STATIC   │                     │
│                             └─────────────┘                     │
│   rules.rb (Part 2)                                             │
│   ┌─────────────────┐                                           │
│   │ Foodcritic      │                                           │
│   │ Lines 1768-2835 │                                           │
│   │ ⚠️  DEPRECATED  │                                           │
│   └─────────────────┘                                           │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principle:** Modify `rules.rb` Part 1 (data) only. Never modify `barc_cops.rb` (engine).

## Quick Start

```bash
# Validate a cookbook
cookstyle cookbooks/my-app-cookbook \
  --config cookbooks/b-cookstyle-rules/.rubocop.yml \
  --only Barclays

# Generate JSON report
cookstyle cookbooks/my-app-cookbook \
  --config cookbooks/b-cookstyle-rules/.rubocop.yml \
  --format json --out report.json
```

## Repository Structure

```
foodcritic_cookstyle_convert/
├── Jenkinsfile                          # CI/CD pipeline
├── cookbooks/
│   ├── b-cookstyle-rules/               # BARC Rules Engine
│   │   ├── barc_cops.rb                 # 36 Cookstyle cops (1,446 lines)
│   │   ├── rules.rb                     # Data + deprecated Foodcritic
│   │   ├── .rubocop.yml                 # Config loader
│   │   ├── BARC_RULES_DOCUMENTATION.html
│   │   └── PARITY_CHECK_REPORT.html
│   ├── complaint-cookbook/              # Test cookbook with violations
│   ├── compliant-cookbook/              # Clean cookbook (passes)
│   ├── comprehensive_test_cookbook/     # Full BARC rule coverage
│   ├── bad_cookbook/                    # Violation examples
│   ├── is_uisec_unix_sudo/              # Sudoers cookbook
│   └── my-app-cookbook/                 # Demo cookbook
└── docs/                                # Additional documentation
```

## All 36 BARC Rules

| Rule | Description | Bypass Variable |
|------|-------------|-----------------|
| **Security - User/Access** |
| BARC001 | No local user manipulation | `@local_access_cookbook_whitelist` |
| BARC002 | No local group manipulation | `@local_access_cookbook_whitelist` |
| BARC003 | No /root/.ssh files | `@platform_cookbook_whitelist` |
| BARC004 | No SSH key manipulation | `@platform_cookbook_whitelist` |
| **Security - System** |
| BARC005 | /etc file restrictions | `@etc_whitelist` |
| BARC005a | /etc in attributes | `@etc_whitelist` |
| BARC006 | No reboot/shutdown | `@reboot_cookbook_whitelist` |
| BARC007 | No SELinux manipulation | `@selinux_cookbook_whitelist` |
| BARC008 | No kill/nice commands | `@platform_cookbook_whitelist` |
| BARC009 | No firewall manipulation | `@platform_cookbook_whitelist` |
| BARC010 | No init/telinit | `@platform_cookbook_whitelist` |
| **Security - Files/Disk** |
| BARC011 | No rm/rmdir/dd | `@platform_cookbook_whitelist` |
| BARC012 | No kernel manipulation | `@platform_cookbook_whitelist` |
| BARC013 | No volume/mount manipulation | `@mount_cookbook_whitelist` |
| BARC014 | No network manipulation | `@platform_cookbook_whitelist` |
| BARC015 | No root cron | `@cron_root_whitelist` |
| **Best Practices** |
| BARC016 | Use Chef resources | `@rpm_cookbook_whitelist` |
| BARC017 | System service restrictions | `@restricted_services` |
| BARC018 | Service review (informational) | `@restricted_services` |
| BARC019 | No find/sudo | `@platform_cookbook_whitelist` |
| BARC020 | No fuser/setfacl/wall/smbclient | `@platform_cookbook_whitelist` |
| **Metadata** |
| BARC021 | Exact version dependency | `@cookbook_coverage_whitelist` |
| BARC022 | No raise/fail/fatal! | `@platform_cookbook_whitelist` |
| BARC023 | Supported platform required | None |
| BARC024 | Maintainer info required | None |
| BARC025 | Node tags whitelist | `@tag_whitelist` |
| BARC026 | No node.save | `@platform_cookbook_whitelist` |
| **Packages** |
| BARC027 | Middleware packages | `@mw_cookbook_whitelist` |
| BARC028 | Restricted cookbook deps | `@restricted_cookbook_whitelist` |
| BARC029 | Community cookbook access | `@blocked_cookbooks` |
| BARC030 | Deprecated cookbooks | `@deprecated_cookbooks` |
| BARC031 | Controlled packages | `@controlled_packages` |
| **Dependencies** |
| BARC032 | Cookbook version flags | `@cookbook_minimum_versions` |
| BARC033 | Allowed pins only | `@cookbook_allowed_pins_only` |
| BARC034 | Restricted attrs in roles | `@restricted_attributes` |
| BARC035 | Restricted attributes | `@restricted_attributes` |
| BARC036 | Java version hard pin | `@orac_java_hard_pined_up` |

## Adding Exceptions

**Step 1:** Find the variable in `rules.rb` (lines 1-1767)

**Step 2:** Add your exception with a change ticket comment:

```ruby
# Example: Allow service in BARC017
@restricted_services = {
  'myservice' => ['my-cookbook'],  # CHG0012345
}

# Example: Allow /etc path in BARC005
@etc_whitelist = {
  '/etc/myapp/' => ['my-cookbook'],  # CHG0012345
}

# Example: Bypass ALL rules for platform cookbook
@platform_cookbook_whitelist = [
  'my-platform-cookbook',  # CHG0012345
]

# Example: Allow tag in BARC025
@tag_whitelist = {
  'my-cookbook' => %w[my_tag another_tag],  # CHG0012345
}
```

**Step 3:** Commit and push - rules apply immediately.

## Jenkins Pipeline

### Parameters

| Parameter | Type | Options |
|-----------|------|---------|
| `COOKBOOK_NAME` | Choice | my-app-cookbook, compliant-cookbook, complaint-cookbook, comprehensive_test_cookbook, bad_cookbook, is_uisec_unix_sudo, mysql |
| `FAIL_ON_VIOLATIONS` | Boolean | true (default) / false |

### Build Status

| Status | Meaning | Trigger |
|--------|---------|---------|
| ✅ SUCCESS | All checks passed | 0 offenses |
| ⚠️ UNSTABLE | Warnings found | Warnings, no errors |
| ❌ FAILURE | Errors found | Errors + FAIL_ON_VIOLATIONS=true |

### Usage

```bash
# Trigger build (if CLI configured)
curl -X POST "https://jenkins.example.com/job/cookstyle-poc/buildWithParameters?COOKBOOK_NAME=my-app-cookbook"
```

## Parity Achievements

| Metric | Value |
|--------|-------|
| Rules Migrated | 36 |
| Parity Score | 100% |
| Engine Lines | 1,446 |
| Test Offenses | 112 |

### Enhancements for 100% Parity

| Rule | Enhancement |
|------|-------------|
| BARC001/002 | Added .NET `create("user/group")` patterns |
| BARC021 | Added `library_cookbook?()` for Berksfile.lock check |
| BARC024 | Added regex validation (maintainer, email, source_url) |
| BARC027/031 | Added variable tracking + 1-liner resource support |
| BARC034 | Added JSON role file support |

### Cookstyle Improvements (Beyond Foodcritic)

- `service_name` attribute detection (BARC009/017/018)
- `tags` plural support (BARC025)
- Windows `shutdown` command (BARC006)
- `windows_service` resource (BARC018)
- Broader file scope (all Ruby files)

## Documentation

| Document | Description |
|----------|-------------|
| [BARC_RULES_DOCUMENTATION.html](cookbooks/b-cookstyle-rules/BARC_RULES_DOCUMENTATION.html) | Comprehensive developer guide |
| [PARITY_CHECK_REPORT.html](cookbooks/b-cookstyle-rules/PARITY_CHECK_REPORT.html) | 100% parity verification report |

## Requirements

- **Ruby** 3.1+
- **Cookstyle** 7.32.8+
- **Chef Workstation** (recommended)

## License

Internal Use - Barclays
