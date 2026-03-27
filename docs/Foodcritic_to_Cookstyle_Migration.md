# 🔄 Foodcritic to Cookstyle Migration Guide

> **Purpose:** This document describes the modernization of `b-cookstyle-rules` from the deprecated Foodcritic tool to the actively maintained Cookstyle (RuboCop-based) framework, while preserving all existing exception configurations.

---

## 📋 Executive Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Tool** | ⛔ Foodcritic (Deprecated 2019) | ✅ Cookstyle (Active) |
| **Built-in Rules** | ~100 rules | 200+ Chef best practices |
| **Auto-fix Capability** | ❌ No | ✅ Yes |
| **Exception File (rules.rb)** | 2,800+ lines | 🔒 **PRESERVED** - Same file |
| **Pipeline Changes** | - | Minimal - same structure |

---

## 📁 Directory Structure Comparison

| File | OLD (Foodcritic) | NEW (Cookstyle) | Notes |
|------|------------------|-----------------|-------|
| `.rubocop.yml` | 1 line (inherit only) | 50+ lines | Enhanced with cop configurations |
| `rules.rb` | 2,800+ lines | Same file | 🔒 **PRESERVED** - Contains all exceptions |
| `barc_cops.rb` | ❌ Does not exist | 🆕 ~400 lines | Cookstyle cops reading rules.rb |
| `Rakefile` | ✅ | ✅ Same | Pipeline compatible |
| `spec/` | ✅ | ✅ Same | Pipeline compatible |

---

## 🔧 Technology Migration Details

| Aspect | OLD (Foodcritic) | NEW (Cookstyle) |
|--------|------------------|-----------------|
| **Tool** | Foodcritic (deprecated 2019) | Cookstyle (RuboCop-based) |
| **Command** | `foodcritic -I rules.rb cookbooks` | `cookstyle .` |
| **Rule Syntax** | DSL with `rule 'BARC001' do ... end` | RuboCop Cop classes |
| **AST Parser** | Custom Foodcritic parser | RuboCop AST (more powerful) |
| **Auto-fix** | ❌ No | ✅ Yes (where possible) |
| **Output Formats** | Text only | JSON, HTML, Progress, etc. |
| **Built-in Rules** | ~100 | 200+ Chef best practices |

---

## 📝 Rule Definition Syntax Change

### OLD Foodcritic Syntax (rules.rb)

```ruby
rule 'BARC001', 'Do not manipulate users locally' do
  tags %w[barc unix windows security]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_resources(ast, type: 'user')
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end
```

### NEW Cookstyle Syntax (barc_cops.rb)

```ruby
class Barc001NoLocalUsers < Base
  MSG = 'BARC001: Do not create local users. Use Active Directory instead.'
  USER_COMMANDS = %w[useradd adduser usermod userdel passwd].freeze

  def on_block(node)
    add_offense(node.send_node) if user_resource?(node)

    return unless execute_resource?(node) || bash_resource?(node)
    find_command_strings(node).each do |cmd_node, cmd|
      add_offense(cmd_node) if USER_COMMANDS.any? { |c| cmd =~ /\b#{c}\b/ }
    end
  end
end
```

---

## 🔒 Exception Handling (PRESERVED)

> ✅ **Key Innovation:** All existing exceptions are preserved in the same `rules.rb` file format. No re-approval needed for 500+ CHG tickets.

### Exception Data Structures (Unchanged)

```ruby
# rules.rb - UNCHANGED from original
@restricted_services = {
  'rsyslog' => ['is-apaaseng-osev3-b-openshift3_enterprise',
                'is_mw_iib10_build', ...],
  'docker' => [],  # Empty array = allowed for ALL cookbooks
  ...
}

@etc_whitelist = {
  '/etc/sudoers' => ['is_uisec_unix_sudo', 'is_mw_tomcat8_build2018', ...],
  '/etc/rsyslog.d/' => [],  # Empty = allowed for all
  ...
}

@system_services = %w[
  dhcpd ntpd sshd rsyslogd auditd ...
]
```

### How barc_cops.rb Reads Exceptions

```ruby
module BarcRulesData
  def load_rules!
    context.instance_eval(File.read('rules.rb'))
    @restricted_services = context.restricted_services
    @etc_whitelist = context.etc_whitelist
  end

  def service_whitelisted?(service_name, cookbook_name)
    key = find_service_key(service_name)
    allowed = @restricted_services[key]
    allowed.empty? || allowed.include?(cookbook_name)
  end
end
```

---

## 📊 BARC Rules Implemented

| Rule | Description | Severity |
|------|-------------|----------|
| `BARC001` | Do not create local users - use Active Directory | Error |
| `BARC002` | Do not create local groups - use Active Directory | Error |
| `BARC003` | Do not modify root .ssh files | Error |
| `BARC005` | Do not modify protected /etc paths | Error |
| `BARC006` | Do not reboot/halt/shutdown nodes | Error |
| `BARC007` | Do not modify SELinux configuration | Error |
| `BARC008` | Do not kill processes | Warning |
| `BARC009` | Do not modify firewall rules | Error |
| `BARC011` | Do not use dangerous file removal (rm -rf) | Error |
| `BARC016` | Use Chef resources instead of shell commands | Convention |
| `BARC017` | Do not manage system services | Error |
| `BARC019` | Do not use find/sudo/chmod 777 | Error |

---

## 🚀 Usage Comparison

### OLD Command
```bash
foodcritic -t barc -f security -I rules.rb cookbooks/my-cookbook
```

### NEW Commands
```bash
# Run all checks
cookstyle .

# JSON output for CI/CD
cookstyle . --format json --out cookstyle-report.json

# Auto-fix where possible
cookstyle . --autocorrect

# Generate HTML report
ruby scripts/generate_report.rb cookstyle-report.json > report.html
```

---

## ✅ What Was Modernized

| Change | Benefit |
|--------|---------|
| RuboCop AST patterns | More precise node matching, fewer false positives |
| `def_node_matcher` | Pattern-based resource detection |
| Class-based cops | Reusable, testable, maintainable code |
| `.rubocop.yml` configuration | Enable/disable cops, set severity per rule |
| Integrated with Cookstyle | Get 200+ built-in Chef rules FREE |
| JSON output | CI/CD friendly, beautiful HTML reports |
| Auto-correction | Some issues can be auto-fixed |

---

## 🔄 What Was Preserved

| Item | Reason |
|------|--------|
| `rules.rb` with all exceptions | No re-approval needed for 500+ CHG tickets |
| `@restricted_services` format | Same hash structure, same cookbook lists |
| `@etc_whitelist` format | Same hash structure |
| `@system_services` list | Same array of restricted services |
| `spec/` folder | Existing pipeline runs RSpec tests |
| `Rakefile` | Same pipeline tasks work |

---

## 🎯 Migration Benefits Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    MODERNIZATION BENEFITS                    │
├─────────────────────────────────────────────────────────────┤
│ ✅ Foodcritic deprecated → Cookstyle actively maintained    │
│ ✅ 200+ additional Chef best practice rules FREE            │
│ ✅ Auto-fix capability for many violations                  │
│ ✅ Better IDE integration (VS Code, RubyMine)              │
│ ✅ JSON output for Jenkins HTML reports                     │
│ ✅ Same exceptions file (rules.rb) - no re-approvals        │
│ ✅ Same pipeline structure - minimal changes                │
│ ✅ More precise AST matching (fewer false positives)        │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Jenkins Pipeline Integration

> The Jenkins pipeline supports dynamic cookbook selection with parameter-based builds.

### Pipeline Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `COOKBOOK_NAME` | Choice | Select cookbook to validate |
| `FAIL_ON_VIOLATIONS` | Boolean | Fail build if violations found (default: true) |

### Pipeline Stages

1. **Checkout** - Clone repository
2. **Setup** - Verify Ruby and Cookstyle versions
3. **Cookstyle Lint** - Run validation with JSON output
4. **Analyze Results** - Parse JSON, categorize violations
5. **Post Actions** - Archive artifacts, publish HTML report

---

## 📚 Adding New Cookbook Exceptions

To add a new cookbook exception, edit `rules.rb` (same as before):

```ruby
# Add service exception
@restricted_services = {
  'my-new-service' => ['my_cookbook_name'],  # CHG123456789
  ...
}

# Add /etc path exception
@etc_whitelist = {
  '/etc/myapp/config.conf' => ['my_cookbook_name'],  # CHG123456789
  ...
}
```

> ⚠️ **Note:** All exceptions must be approved via Change Request (CHG) and documented with the ticket number.

---
