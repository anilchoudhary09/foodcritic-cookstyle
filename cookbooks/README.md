# Cookbooks

This directory contains three cookbooks for the Foodcritic to Cookstyle migration demonstration.

## Directory Structure

```
cookbooks/
├── b-foodcritic-rules/      # Custom BARC Cookstyle cops library
├── my-app-cookbook/         # Demo cookbook with intentional violations
└── compliant-cookbook/      # Demo cookbook following best practices
```

## Cookbooks

### b-foodcritic-rules

The custom Cookstyle cops library containing 12 BARC security rules. This is not a runnable cookbook - it provides the RuboCop cops used by other cookbooks.

**Key files:**
- `lib/rubocop/cop/barclays/` - Custom cop implementations
- `lib/rubocop-barclays.rb` - Entry point that loads all cops

### my-app-cookbook

A demonstration cookbook with **intentional violations** for testing the BARC rules.

**Purpose:** Verify that custom cops detect violations correctly  
**Expected Result:** ❌ ~31 violations detected

**Files:**
- `recipes/violations.rb` - Intentional security violations
- `recipes/compliant.rb` - Clean code for comparison
- `scripts/generate_report.rb` - HTML report generator

### compliant-cookbook

A demonstration cookbook following all best practices with **zero violations**.

**Purpose:** Show compliant code patterns  
**Expected Result:** ✅ 0 violations

**Files:**
- `recipes/application.rb` - Application deployment recipe
- `recipes/monitoring.rb` - Monitoring setup recipe

## Usage

Each cookbook includes a `.rubocop.yml` that loads the BARC rules:

```bash
cd my-app-cookbook
cookstyle . --format progress
```

## Adding New Cookbooks

1. Copy the `.rubocop.yml` from an existing cookbook
2. Ensure the path to `b-foodcritic-rules` is correct
3. Run `cookstyle .` to validate
