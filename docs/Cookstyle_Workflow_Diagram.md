# 🔄 Cookstyle Workflow with Barclays Custom Cops

## Flow Diagram (Mermaid)

Copy and paste this into Confluence with the Mermaid macro or use [mermaid.live](https://mermaid.live) to generate an image.

```mermaid
flowchart TD
    subgraph DEV["👨‍💻 Developer Machine"]
        A[Clone b-cookstyle-rules repo] --> B[Create/Edit Cookbook]
        B --> C{Run cookstyle locally}
        C -->|Violations Found| D[Fix violations]
        D --> C
        C -->|Clean| E[git push to GitHub]
    end

    subgraph GITHUB["📦 GitHub Repository"]
        E --> F[Webhook triggers Jenkins]
    end

    subgraph JENKINS["🔧 Jenkins Pipeline"]
        F --> G[Checkout Code]
        G --> H[Setup Environment]
        H --> I[Load barc_cops.rb]
        I --> J[barc_cops.rb reads rules.rb]
        J --> K[Run cookstyle with BARC cops]
        K --> L{Violations?}
        L -->|Yes| M[Generate JSON Report]
        L -->|No| N[✅ Build Success]
        M --> O[Parse & Categorize Violations]
        O --> P[Generate HTML Report]
        P --> Q{FAIL_ON_VIOLATIONS?}
        Q -->|true| R[❌ Build Failed]
        Q -->|false| S[⚠️ Build Unstable]
    end

    subgraph REPORTS["📊 Reports & Artifacts"]
        N --> T[Archive Artifacts]
        R --> T
        S --> T
        T --> U[Publish HTML Report]
        U --> V[Email Notification]
    end

    style DEV fill:#E3FCEF,stroke:#00875A
    style GITHUB fill:#DEEBFF,stroke:#0052CC
    style JENKINS fill:#FFFAE6,stroke:#FF8B00
    style REPORTS fill:#F4F5F7,stroke:#6B778C
```

---

## Detailed Process Flow

```mermaid
sequenceDiagram
    participant Dev as 👨‍💻 Developer
    participant Local as 💻 Local Machine
    participant Git as 📦 GitHub
    participant Jenkins as 🔧 Jenkins
    participant Cookstyle as 🔍 Cookstyle
    participant Rules as 📋 rules.rb
    participant Report as 📊 HTML Report

    Note over Dev,Report: Development Phase
    Dev->>Local: Clone b-cookstyle-rules repo
    Dev->>Local: Create/Edit cookbook code
    Dev->>Local: Run: cookstyle .
    Local->>Cookstyle: Load .rubocop.yml
    Cookstyle->>Cookstyle: require './barc_cops.rb'
    Cookstyle->>Rules: Read @restricted_services, @etc_whitelist
    Cookstyle-->>Local: Return violations (if any)
    Dev->>Dev: Fix violations locally
    Dev->>Git: git push

    Note over Dev,Report: CI/CD Pipeline Phase
    Git->>Jenkins: Webhook trigger
    Jenkins->>Jenkins: Checkout code
    Jenkins->>Cookstyle: cookstyle . --format json
    Cookstyle->>Rules: Load exception data
    Rules-->>Cookstyle: @restricted_services, @etc_whitelist
    Cookstyle->>Cookstyle: Apply BARC001-BARC019 cops
    Cookstyle-->>Jenkins: JSON report output
    Jenkins->>Report: Generate HTML report
    Jenkins->>Dev: Email notification with results
```

---

## Component Architecture

```mermaid
graph TB
    subgraph COOKBOOK["📁 Cookbook Being Validated"]
        CB1[recipes/default.rb]
        CB2[attributes/default.rb]
        CB3[templates/config.erb]
    end

    subgraph RULESET["📋 b-cookstyle-rules"]
        RC[.rubocop.yml]
        BC[barc_cops.rb]
        RB[rules.rb]

        RC -->|require| BC
        BC -->|reads| RB
    end

    subgraph EXCEPTIONS["🔒 Exception Data in rules.rb"]
        RS["@restricted_services\n{rsyslog => [cookbook1, cookbook2]}"]
        EW["@etc_whitelist\n{/etc/sudoers => [cookbook3]}"]
        EB["@etc_blacklist\n[/etc/passwd, /etc/shadow]"]
        SS["@system_services\n[dhcpd, ntpd, sshd]"]
    end

    subgraph COPS["👮 BARC Cops in barc_cops.rb"]
        B1[BARC001 - No Local Users]
        B2[BARC002 - No Local Groups]
        B3[BARC003 - No Root SSH]
        B5[BARC005 - Etc Blacklist]
        B6[BARC006 - No Reboot]
        B7[BARC007 - No SELinux]
        B17[BARC017 - No System Services]
    end

    RB --> RS
    RB --> EW
    RB --> EB
    RB --> SS

    BC --> B1
    BC --> B2
    BC --> B3
    BC --> B5
    BC --> B6
    BC --> B7
    BC --> B17

    B5 -.->|checks against| EB
    B5 -.->|allows if in| EW
    B17 -.->|checks against| SS
    B17 -.->|allows if in| RS

    COOKBOOK -->|validated by| COPS

    style COOKBOOK fill:#DEEBFF,stroke:#0052CC
    style RULESET fill:#E3FCEF,stroke:#00875A
    style EXCEPTIONS fill:#FFFAE6,stroke:#FF8B00
    style COPS fill:#F4F5F7,stroke:#6B778C
```

---

## ASCII Flow Diagram (Confluence Compatible)

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                           COOKSTYLE WORKFLOW WITH BARCLAYS COPS                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘

╔═══════════════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 1: LOCAL DEVELOPMENT                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                           ║
║   👨‍💻 Developer Machine                                                                    ║
║   ┌─────────────────────────────────────────────────────────────────────────────────────┐ ║
║   │                                                                                     │ ║
║   │  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │ ║
║   │  │   Clone      │───▶│   Create/    │───▶│    Run       │───▶│   Commit &   │      │ ║
║   │  │   Repo       │    │   Edit Code  │    │  cookstyle . │    │   Push       │      │ ║
║   │  └──────────────┘    └──────────────┘    └──────┬───────┘    └──────────────┘      │ ║
║   │                                                 │                                   │ ║
║   │                                                 ▼                                   │ ║
║   │                                          ┌────────────┐                             │ ║
║   │                                          │ Violations │──▶ Fix & Re-run             │ ║
║   │                                          │  Found?    │                             │ ║
║   │                                          └────────────┘                             │ ║
║   │                                                                                     │ ║
║   └─────────────────────────────────────────────────────────────────────────────────────┘ ║
║                                                                                           ║
║   📋 What happens locally:                                                                ║
║   ┌─────────────────────────────────────────────────────────────────────────────────────┐ ║
║   │  $ cookstyle .                                                                      │ ║
║   │      │                                                                              │ ║
║   │      ├──▶ Reads .rubocop.yml                                                        │ ║
║   │      │        │                                                                     │ ║
║   │      │        └──▶ require: ./barc_cops.rb                                          │ ║
║   │      │                    │                                                         │ ║
║   │      │                    └──▶ BarcRulesData.load_rules! reads rules.rb             │ ║
║   │      │                              │                                               │ ║
║   │      │                              ├── @restricted_services                        │ ║
║   │      │                              ├── @etc_whitelist                              │ ║
║   │      │                              ├── @etc_blacklist                              │ ║
║   │      │                              └── @system_services                            │ ║
║   │      │                                                                              │ ║
║   │      └──▶ Applies BARC001-BARC019 cops to cookbook                                  │ ║
║   │                                                                                     │ ║
║   └─────────────────────────────────────────────────────────────────────────────────────┘ ║
╚═══════════════════════════════════════════════════════════════════════════════════════════╝
                                            │
                                            │ git push
                                            ▼
╔═══════════════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 2: CI/CD PIPELINE                                                                  ║
╠═══════════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                           ║
║   📦 GitHub                        🔧 Jenkins EC2                                         ║
║   ┌────────────────┐               ┌─────────────────────────────────────────────────────┐║
║   │                │   Webhook     │                                                     │║
║   │  Push Event    │──────────────▶│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐│║
║   │                │               │  │Checkout │─▶│ Setup   │─▶│ Load    │─▶│  Run    ││║
║   │  main branch   │               │  │ Code    │  │ Ruby    │  │ Cops    │  │Cookstyle││║
║   │                │               │  └─────────┘  └─────────┘  └─────────┘  └────┬────┘│║
║   └────────────────┘               │                                              │     │║
║                                    │                                              ▼     │║
║                                    │  ┌───────────────────────────────────────────────┐ │║
║                                    │  │  cookstyle . --format json --out report.json  │ │║
║                                    │  └───────────────────────────────────────────────┘ │║
║                                    │                          │                         │║
║                                    │                          ▼                         │║
║                                    │                   ┌────────────┐                   │║
║                                    │                   │ Violations │                   │║
║                                    │                   │   Found?   │                   │║
║                                    │                   └─────┬──────┘                   │║
║                                    │                         │                          │║
║                                    │            ┌────────────┴────────────┐             │║
║                                    │            ▼                         ▼             │║
║                                    │      ┌──────────┐             ┌──────────┐         │║
║                                    │      │   YES    │             │    NO    │         │║
║                                    │      └────┬─────┘             └────┬─────┘         │║
║                                    │           │                        │               │║
║                                    │           ▼                        ▼               │║
║                                    │    ┌─────────────┐          ┌─────────────┐        │║
║                                    │    │ Generate    │          │   ✅ Build  │        │║
║                                    │    │ HTML Report │          │   Success   │        │║
║                                    │    └──────┬──────┘          └─────────────┘        │║
║                                    │           │                                        │║
║                                    │           ▼                                        │║
║                                    │    ┌─────────────────┐                             │║
║                                    │    │FAIL_ON_VIOLATIONS│                            │║
║                                    │    └────────┬────────┘                             │║
║                                    │             │                                      │║
║                                    │      ┌──────┴──────┐                               │║
║                                    │      ▼             ▼                               │║
║                                    │  ┌────────┐   ┌────────┐                           │║
║                                    │  │ true:  │   │ false: │                           │║
║                                    │  │❌ FAIL │   │⚠️ WARN │                           │║
║                                    │  └────────┘   └────────┘                           │║
║                                    │                                                    │║
║                                    └─────────────────────────────────────────────────────┘║
╚═══════════════════════════════════════════════════════════════════════════════════════════╝
                                            │
                                            │
                                            ▼
╔═══════════════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 3: REPORTS & NOTIFICATIONS                                                         ║
╠═══════════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                           ║
║   📊 Jenkins Artifacts                                                                    ║
║   ┌─────────────────────────────────────────────────────────────────────────────────────┐ ║
║   │                                                                                     │ ║
║   │   ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐             │ ║
║   │   │  Archive JSON    │───▶│  Publish HTML    │───▶│  Send Email      │             │ ║
║   │   │  Report          │    │  Report          │    │  Notification    │             │ ║
║   │   └──────────────────┘    └──────────────────┘    └──────────────────┘             │ ║
║   │                                                                                     │ ║
║   │   ┌─────────────────────────────────────────────────────────────────────────────┐  │ ║
║   │   │  HTML Report Contents:                                                       │  │ ║
║   │   │  ┌─────────────────────────────────────────────────────────────────────────┐│  │ ║
║   │   │  │  Summary:     15 violations found across 3 files                        ││  │ ║
║   │   │  │  ─────────────────────────────────────────────────────────────────────  ││  │ ║
║   │   │  │  BARC001:     2 violations (user resource found)                        ││  │ ║
║   │   │  │  BARC005:     5 violations (/etc/passwd modification)                   ││  │ ║
║   │   │  │  BARC017:     3 violations (system service management)                  ││  │ ║
║   │   │  │  ─────────────────────────────────────────────────────────────────────  ││  │ ║
║   │   │  │  Chef/Style:  5 warnings (built-in cookstyle rules)                     ││  │ ║
║   │   │  └─────────────────────────────────────────────────────────────────────────┘│  │ ║
║   │   └─────────────────────────────────────────────────────────────────────────────┘  │ ║
║   │                                                                                     │ ║
║   └─────────────────────────────────────────────────────────────────────────────────────┘ ║
╚═══════════════════════════════════════════════════════════════════════════════════════════╝
```

---

## Files Involved in the Workflow

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              FILE RELATIONSHIPS                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

b-cookstyle-rules/
│
├── .rubocop.yml ─────────────────────┐
│   │                                 │
│   │  require: ./barc_cops.rb  ◀─────┤
│   │                                 │
│   └─ Cop configurations             │
│      (enabled/disabled,             │
│       severity levels)              │
│                                     │
├── barc_cops.rb ◀────────────────────┘
│   │
│   ├── module BarcRulesData
│   │   │
│   │   ├── load_rules! ─────────────────────┐
│   │   │                                    │
│   │   ├── service_whitelisted?()           │
│   │   │                                    │
│   │   └── etc_path_whitelisted?()          │
│   │                                        │
│   └── Cop Classes                          │
│       ├── Barc001NoLocalUsers              │
│       ├── Barc002NoLocalGroups             │
│       ├── Barc003NoRootSsh                 │
│       ├── Barc005EtcBlacklist              │
│       ├── Barc006NoReboot                  │
│       ├── Barc007NoSelinux                 │
│       ├── Barc008NoKillProcess             │
│       ├── Barc009NoFirewall                │
│       ├── Barc011NoRemoveFiles             │
│       ├── Barc016UseChefResources          │
│       ├── Barc017NoSystemServices          │
│       └── Barc019NoFindSudo                │
│                                            │
│                                            ▼
├── rules.rb ─────────────────────────────────┐
│   │                                         │
│   │  2,800+ lines of exception data:        │
│   │                                         │
│   ├── @restricted_services = {              │
│   │     'rsyslog' => ['cookbook1', ...],    │
│   │     'docker'  => [],  # all allowed     │
│   │   }                                     │
│   │                                         │
│   ├── @etc_whitelist = {                    │
│   │     '/etc/sudoers' => ['cookbook2'],    │
│   │   }                                     │
│   │                                         │
│   ├── @etc_blacklist = [                    │
│   │     '/etc/passwd',                      │
│   │     '/etc/shadow',                      │
│   │   ]                                     │
│   │                                         │
│   └── @system_services = %w[                │
│         dhcpd ntpd sshd rsyslogd            │
│       ]                                     │
│                                             │
├── Rakefile ──────────── Pipeline tasks      │
│                                             │
├── spec/ ────────────── RSpec tests          │
│                                             │
└── Jenkinsfile ───────── Pipeline definition │
```

---

## Exception Logic Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        EXCEPTION CHECKING LOGIC                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

                          ┌──────────────────────┐
                          │  Cookbook Resource   │
                          │  e.g., service 'ntp' │
                          └──────────┬───────────┘
                                     │
                                     ▼
                          ┌──────────────────────┐
                          │  BARC017 Cop Fires   │
                          │  "System service     │
                          │   management"        │
                          └──────────┬───────────┘
                                     │
                                     ▼
                    ┌────────────────────────────────────┐
                    │  Is 'ntp' in @system_services?     │
                    └────────────────┬───────────────────┘
                                     │
                      ┌──────────────┴──────────────┐
                      │                             │
                      ▼                             ▼
                 ┌─────────┐                  ┌─────────┐
                 │   NO    │                  │   YES   │
                 └────┬────┘                  └────┬────┘
                      │                            │
                      ▼                            ▼
               ┌────────────┐         ┌────────────────────────────┐
               │  ✅ PASS   │         │  Check @restricted_services│
               │  No issue  │         │  for exceptions            │
               └────────────┘         └─────────────┬──────────────┘
                                                    │
                                      ┌─────────────┴─────────────┐
                                      │                           │
                                      ▼                           ▼
                        ┌──────────────────────┐    ┌──────────────────────┐
                        │ Cookbook in allowed  │    │ Cookbook NOT in      │
                        │ list OR list empty   │    │ allowed list         │
                        └──────────┬───────────┘    └──────────┬───────────┘
                                   │                           │
                                   ▼                           ▼
                            ┌────────────┐              ┌────────────┐
                            │  ✅ PASS   │              │  ❌ FAIL   │
                            │  Exception │              │  Violation │
                            │  Applied   │              │  Reported  │
                            └────────────┘              └────────────┘


Example from rules.rb:
─────────────────────────────────────────────────────────────────────
@restricted_services = {
  'ntp' => ['is_platform_ntp_cookbook', 'is_base_config'],  # Only these allowed
  'docker' => [],  # Empty = ALL cookbooks allowed
}

Cookbook: my-app-cookbook trying to manage 'ntp' service
  → 'ntp' is in @restricted_services
  → 'my-app-cookbook' is NOT in allowed list ['is_platform_ntp_cookbook', 'is_base_config']
  → ❌ VIOLATION: BARC017 - Cannot manage system service 'ntp'

Cookbook: is_platform_ntp_cookbook trying to manage 'ntp' service
  → 'ntp' is in @restricted_services
  → 'is_platform_ntp_cookbook' IS in allowed list
  → ✅ PASS: Exception applied (CHG ticket approved)
```

---

## Quick Reference Commands

| Environment | Command | Purpose |
|-------------|---------|---------|
| **Local** | `cookstyle .` | Run all checks |
| **Local** | `cookstyle . --only Barclays` | Run only BARC cops |
| **Local** | `cookstyle . --autocorrect` | Auto-fix issues |
| **Jenkins** | `cookstyle . --format json --out report.json` | JSON for pipeline |
| **Debug** | `cookstyle . --debug` | Verbose output |

---

*Document Version: 1.0 | Last Updated: March 2026 | Author: Chef Platform Team*
