# my-app-cookbook

Sample Chef cookbook for demonstrating Cookstyle + BARC rules POC.

## Quick Start

```bash
# Install dependencies
bundle install

# Run Cookstyle on all files
cookstyle .

# Run on specific recipe
cookstyle recipes/violations.rb    # Shows BARC violations
cookstyle recipes/compliant.rb     # Clean - no violations
```

## Structure

```
my-app-cookbook/
├── .rubocop.yml           # Cookstyle config (loads BARC rules)
├── Gemfile                # Dependencies
├── metadata.rb            # Cookbook metadata
├── recipes/
│   ├── default.rb         # Default recipe (includes compliant)
│   ├── violations.rb      # POC: Shows BARC rule violations
│   └── compliant.rb       # POC: Best practices example
└── templates/
    ├── app.conf.erb       # Application config template
    └── database.yml.erb   # Database config template
```

## POC Demo

### Step 1: See Violations

```bash
cookstyle recipes/violations.rb
```

Expected output: Multiple BARC violations detected (BARC001-BARC019)

### Step 2: See Clean Code

```bash
cookstyle recipes/compliant.rb
```

Expected output: No violations

### Step 3: Generate Report

```bash
cookstyle . --format json --out report.json
cookstyle . --format html --out report.html
```

## BARC Rules Tested

| Rule | Description | Recipe |
|------|-------------|--------|
| BARC001 | No local users | violations.rb |
| BARC002 | No local groups | violations.rb |
| BARC003 | No root SSH | violations.rb |
| BARC005 | Protected /etc | violations.rb |
| BARC006 | No reboot | violations.rb |
| BARC007 | No SELinux | violations.rb |
| BARC008 | No kill process | violations.rb |
| BARC009 | No firewall | violations.rb |
| BARC011 | No rm -rf | violations.rb |
| BARC016 | Use Chef resources | violations.rb |
| BARC017 | No system services | violations.rb |
| BARC019 | No chmod 777 | violations.rb |
