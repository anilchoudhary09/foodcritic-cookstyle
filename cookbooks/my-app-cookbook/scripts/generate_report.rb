#!/usr/bin/env ruby
# frozen_string_literal: true

# Beautiful HTML Report Generator for Cookstyle
# Usage: ruby scripts/generate_report.rb cookstyle-report.json > cookstyle-report.html

require 'json'
require 'cgi'

json_file = ARGV[0] || 'cookstyle-report.json'
report = JSON.parse(File.read(json_file))

summary = report['summary']
files = report['files']

# Count by severity
severity_counts = { 'error' => 0, 'warning' => 0, 'convention' => 0, 'refactor' => 0, 'fatal' => 0 }
files.each do |file|
  file['offenses'].each do |offense|
    severity_counts[offense['severity']] = (severity_counts[offense['severity']] || 0) + 1
  end
end

errors = severity_counts['error'] + severity_counts['fatal']
warnings = severity_counts['warning']
conventions = severity_counts['convention'] + severity_counts['refactor']

# Group violations by cop
violations_by_cop = Hash.new(0)
files.each do |file|
  file['offenses'].each do |offense|
    violations_by_cop[offense['cop_name']] += 1
  end
end

html = <<~HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cookstyle Report - Chef Cookbook Analysis</title>
    <style>
        :root {
            --primary: #2563eb;
            --error: #dc2626;
            --warning: #f59e0b;
            --convention: #3b82f6;
            --success: #10b981;
            --bg: #f8fafc;
            --card-bg: #ffffff;
            --text: #1e293b;
            --text-muted: #64748b;
            --border: #e2e8f0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: var(--bg);
            color: var(--text);
            line-height: 1.6;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }

        header {
            background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }

        header h1 {
            font-size: 2rem;
            font-weight: 600;
        }

        header p {
            opacity: 0.9;
            margin-top: 0.5rem;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border-left: 4px solid var(--primary);
        }

        .stat-card.error { border-left-color: var(--error); }
        .stat-card.warning { border-left-color: var(--warning); }
        .stat-card.convention { border-left-color: var(--convention); }
        .stat-card.success { border-left-color: var(--success); }

        .stat-card h3 {
            font-size: 0.875rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .stat-card .value {
            font-size: 2.5rem;
            font-weight: 700;
            margin-top: 0.5rem;
        }

        .stat-card.error .value { color: var(--error); }
        .stat-card.warning .value { color: var(--warning); }
        .stat-card.convention .value { color: var(--convention); }
        .stat-card.success .value { color: var(--success); }

        .section {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .section h2 {
            font-size: 1.25rem;
            margin-bottom: 1rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid var(--border);
        }

        .file-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem;
            background: #f1f5f9;
            border-radius: 8px;
            margin-bottom: 1rem;
            cursor: pointer;
        }

        .file-header:hover {
            background: #e2e8f0;
        }

        .file-name {
            font-weight: 600;
            font-family: 'Monaco', 'Menlo', monospace;
        }

        .badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .badge-error { background: #fef2f2; color: var(--error); }
        .badge-warning { background: #fffbeb; color: #b45309; }
        .badge-convention { background: #eff6ff; color: var(--convention); }

        .offense {
            padding: 1rem;
            border-left: 3px solid var(--border);
            margin-bottom: 0.75rem;
            background: #fafafa;
            border-radius: 0 8px 8px 0;
        }

        .offense.error { border-left-color: var(--error); background: #fef2f2; }
        .offense.warning { border-left-color: var(--warning); background: #fffbeb; }
        .offense.convention, .offense.refactor { border-left-color: var(--convention); background: #eff6ff; }

        .offense-header {
            display: flex;
            gap: 0.75rem;
            align-items: center;
            margin-bottom: 0.5rem;
        }

        .offense-line {
            font-family: monospace;
            font-size: 0.875rem;
            color: var(--text-muted);
        }

        .offense-cop {
            font-weight: 600;
            font-size: 0.875rem;
        }

        .offense-message {
            color: var(--text);
        }

        .code-snippet {
            background: #1e293b;
            color: #e2e8f0;
            padding: 0.75rem 1rem;
            border-radius: 6px;
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 0.875rem;
            overflow-x: auto;
            margin-top: 0.75rem;
        }

        .top-violations {
            display: grid;
            gap: 0.5rem;
        }

        .violation-row {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 1rem;
            background: #f8fafc;
            border-radius: 6px;
        }

        .violation-row:hover {
            background: #f1f5f9;
        }

        .violation-count {
            font-weight: 700;
            color: var(--error);
        }

        footer {
            text-align: center;
            padding: 2rem;
            color: var(--text-muted);
            font-size: 0.875rem;
        }

        .barc-badge {
            background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%);
            color: white;
        }

        .chef-badge {
            background: linear-gradient(135deg, #ea580c 0%, #f97316 100%);
            color: white;
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>🍳 Cookstyle Inspection Report</h1>
            <p>Chef Cookbook Analysis with Barclays Security Rules</p>
        </div>
    </header>

    <div class="container">
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Files Inspected</h3>
                <div class="value">#{summary['inspected_file_count']}</div>
            </div>
            <div class="stat-card #{errors > 0 ? 'error' : 'success'}">
                <h3>Errors</h3>
                <div class="value">#{errors}</div>
            </div>
            <div class="stat-card warning">
                <h3>Warnings</h3>
                <div class="value">#{warnings}</div>
            </div>
            <div class="stat-card convention">
                <h3>Conventions</h3>
                <div class="value">#{conventions}</div>
            </div>
        </div>

        <div class="section">
            <h2>📊 Top Violations</h2>
            <div class="top-violations">
HTML

violations_by_cop.sort_by { |_, count| -count }.first(10).each do |cop, count|
  is_barc = cop.start_with?('Barclays/')
  badge_class = is_barc ? 'barc-badge' : 'chef-badge'
  badge_text = is_barc ? 'BARC' : 'Chef'
  html += <<~ROW
                <div class="violation-row">
                    <span><span class="badge #{badge_class}">#{badge_text}</span> #{CGI.escapeHTML(cop)}</span>
                    <span class="violation-count">#{count}</span>
                </div>
  ROW
end

html += <<~HTML
            </div>
        </div>

        <div class="section">
            <h2>📁 Files with Offenses</h2>
HTML

files.select { |f| f['offenses'].any? }.each do |file|
  offense_count = file['offenses'].size
  html += <<~FILE
            <div class="file-header">
                <span class="file-name">#{CGI.escapeHTML(file['path'])}</span>
                <span class="badge badge-error">#{offense_count} offense#{offense_count > 1 ? 's' : ''}</span>
            </div>
  FILE

  file['offenses'].each do |offense|
    severity = offense['severity']
    cop_name = offense['cop_name']
    is_barc = cop_name.start_with?('Barclays/')
    badge_class = is_barc ? 'barc-badge' : 'chef-badge'
    badge_text = is_barc ? 'BARC' : 'Chef'

    html += <<~OFFENSE
            <div class="offense #{severity}">
                <div class="offense-header">
                    <span class="offense-line">Line #{offense['location']['line']}</span>
                    <span class="badge #{badge_class}">#{badge_text}</span>
                    <span class="badge badge-#{severity}">#{severity.upcase}</span>
                </div>
                <div class="offense-cop">#{CGI.escapeHTML(cop_name)}</div>
                <div class="offense-message">#{CGI.escapeHTML(offense['message'])}</div>
    OFFENSE

    if offense['source'] && !offense['source'].empty?
      html += <<~CODE
                <div class="code-snippet">#{CGI.escapeHTML(offense['source'])}</div>
      CODE
    end

    html += "            </div>\n"
  end
end

html += <<~HTML
        </div>
    </div>

    <footer>
        <p>Generated by Cookstyle with Barclays Custom Rules</p>
        <p>#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</p>
    </footer>
</body>
</html>
HTML

puts html
