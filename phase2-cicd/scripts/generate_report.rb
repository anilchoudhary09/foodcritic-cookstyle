#!/usr/bin/env ruby
# frozen_string_literal: true

#######################################################################
# generate_report.rb
#
# Generates formatted HTML compliance reports from Cookstyle JSON output
#
# Usage:
#   ruby generate_report.rb --input FILE --output DIR --cookbook NAME
#######################################################################

require 'json'
require 'erb'
require 'optparse'
require 'fileutils'
require 'time'

class ComplianceReportGenerator
  VERSION = '1.0.0'

  SEVERITY_COLORS = {
    'refactor' => '#6c757d',
    'convention' => '#17a2b8',
    'warning' => '#ffc107',
    'error' => '#dc3545',
    'fatal' => '#721c24'
  }.freeze

  SEVERITY_ICONS = {
    'refactor' => '🔧',
    'convention' => '📝',
    'warning' => '⚠️',
    'error' => '❌',
    'fatal' => '💀'
  }.freeze

  def initialize(options)
    @input_file = options[:input]
    @output_dir = options[:output]
    @cookbook_name = options[:cookbook]
    @template_dir = options[:template_dir] || File.join(__dir__, '..', 'templates')
    @data = nil
  end

  def run
    puts "📊 Generating Compliance Report..."
    puts "   Input:    #{@input_file}"
    puts "   Output:   #{@output_dir}"
    puts "   Cookbook: #{@cookbook_name}"
    puts ""

    load_data
    generate_html_report
    generate_summary_json
    generate_badge
    puts ""
    puts "✅ Reports generated successfully!"
  end

  private

  def load_data
    unless File.exist?(@input_file)
      raise "Input file not found: #{@input_file}"
    end

    @data = JSON.parse(File.read(@input_file))
    puts "   Loaded #{@data['files']&.length || 0} files from input"
  end

  def summary
    @data['summary'] || {}
  end

  def files
    @data['files'] || []
  end

  def total_offenses
    summary['offense_count'] || 0
  end

  def inspected_files
    summary['inspected_file_count'] || 0
  end

  def correctable_offenses
    summary['correctable_offense_count'] || 0
  end

  def offenses_by_severity
    result = Hash.new(0)
    files.each do |file|
      (file['offenses'] || []).each do |offense|
        result[offense['severity']] += 1
      end
    end
    result
  end

  def offenses_by_cop
    result = Hash.new { |h, k| h[k] = { count: 0, severity: nil, correctable: 0 } }
    files.each do |file|
      (file['offenses'] || []).each do |offense|
        cop = offense['cop_name']
        result[cop][:count] += 1
        result[cop][:severity] = offense['severity']
        result[cop][:correctable] += 1 if offense['correctable']
      end
    end
    result.sort_by { |_, v| -v[:count] }.to_h
  end

  def files_with_offenses
    files.select { |f| (f['offenses'] || []).any? }
  end

  def compliance_percentage
    return 100.0 if total_offenses.zero? || inspected_files.zero?

    files_with_issues = files_with_offenses.length
    ((inspected_files - files_with_issues).to_f / inspected_files * 100).round(1)
  end

  def status_class
    return 'success' if total_offenses.zero?
    return 'danger' if offenses_by_severity['error']&.positive? || offenses_by_severity['fatal']&.positive?
    'warning'
  end

  def generate_html_report
    puts "   Generating HTML report..."

    template = html_template
    erb = ERB.new(template, trim_mode: '-')

    # Bind variables for template
    cookbook_name = @cookbook_name
    report_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    html = erb.result(binding)

    output_file = File.join(@output_dir, 'compliance-report.html')
    File.write(output_file, html)
    puts "   ✓ HTML report: #{output_file}"
  end

  def generate_summary_json
    puts "   Generating summary JSON..."

    summary_data = {
      cookbook: @cookbook_name,
      generated_at: Time.now.iso8601,
      compliance_percentage: compliance_percentage,
      status: status_class,
      summary: {
        total_files: inspected_files,
        files_with_violations: files_with_offenses.length,
        total_violations: total_offenses,
        correctable: correctable_offenses
      },
      by_severity: offenses_by_severity,
      by_cop: offenses_by_cop.transform_values { |v| v[:count] },
      top_violations: offenses_by_cop.first(10).map { |cop, data| { cop: cop, count: data[:count] } }
    }

    output_file = File.join(@output_dir, 'compliance-summary.json')
    File.write(output_file, JSON.pretty_generate(summary_data))
    puts "   ✓ Summary JSON: #{output_file}"
  end

  def generate_badge
    puts "   Generating status badge..."

    color = case status_class
            when 'success' then 'green'
            when 'warning' then 'yellow'
            else 'red'
            end

    status_text = total_offenses.zero? ? 'passing' : "#{total_offenses} violations"

    badge_svg = <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="150" height="20">
        <linearGradient id="b" x2="0" y2="100%">
          <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
          <stop offset="1" stop-opacity=".1"/>
        </linearGradient>
        <mask id="a">
          <rect width="150" height="20" rx="3" fill="#fff"/>
        </mask>
        <g mask="url(#a)">
          <rect width="70" height="20" fill="#555"/>
          <rect x="70" width="80" height="20" fill="#{color}"/>
          <rect width="150" height="20" fill="url(#b)"/>
        </g>
        <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
          <text x="35" y="15" fill="#010101" fill-opacity=".3">cookstyle</text>
          <text x="35" y="14">cookstyle</text>
          <text x="109" y="15" fill="#010101" fill-opacity=".3">#{status_text}</text>
          <text x="109" y="14">#{status_text}</text>
        </g>
      </svg>
    SVG

    output_file = File.join(@output_dir, 'compliance-badge.svg')
    File.write(output_file, badge_svg)
    puts "   ✓ Badge SVG: #{output_file}"
  end

  def html_template
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cookstyle Compliance Report - <%= cookbook_name %></title>
        <style>
          :root {
            --primary: #0066cc;
            --success: #28a745;
            --warning: #ffc107;
            --danger: #dc3545;
            --dark: #343a40;
            --light: #f8f9fa;
            --border: #dee2e6;
          }

          * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
          }

          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background: var(--light);
            padding: 20px;
          }

          .container {
            max-width: 1200px;
            margin: 0 auto;
          }

          header {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 20px;
          }

          header h1 {
            font-size: 2rem;
            margin-bottom: 10px;
          }

          .meta {
            opacity: 0.8;
            font-size: 0.9rem;
          }

          .status-badge {
            display: inline-block;
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 1rem;
            margin-top: 15px;
          }

          .status-badge.success { background: var(--success); }
          .status-badge.warning { background: var(--warning); color: #333; }
          .status-badge.danger { background: var(--danger); }

          .cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
          }

          .card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }

          .card h3 {
            font-size: 0.9rem;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 10px;
          }

          .card .value {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--dark);
          }

          .card .value.success { color: var(--success); }
          .card .value.warning { color: var(--warning); }
          .card .value.danger { color: var(--danger); }

          .section {
            background: white;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }

          .section h2 {
            color: var(--dark);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--border);
          }

          table {
            width: 100%;
            border-collapse: collapse;
          }

          th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border);
          }

          th {
            background: var(--light);
            font-weight: 600;
            color: var(--dark);
          }

          tr:hover {
            background: #f5f5f5;
          }

          .severity {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: bold;
            color: white;
          }

          .severity.refactor { background: #6c757d; }
          .severity.convention { background: #17a2b8; }
          .severity.warning { background: #ffc107; color: #333; }
          .severity.error { background: #dc3545; }
          .severity.fatal { background: #721c24; }

          .file-path {
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 0.85rem;
            color: var(--primary);
          }

          .offense-details {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
            border-left: 4px solid var(--primary);
          }

          .offense-message {
            font-family: monospace;
            font-size: 0.9rem;
          }

          .offense-location {
            font-size: 0.8rem;
            color: #666;
            margin-top: 5px;
          }

          .progress-bar {
            height: 10px;
            background: #e9ecef;
            border-radius: 5px;
            overflow: hidden;
            margin-top: 10px;
          }

          .progress-bar .fill {
            height: 100%;
            transition: width 0.3s ease;
          }

          .progress-bar .fill.success { background: var(--success); }
          .progress-bar .fill.warning { background: var(--warning); }
          .progress-bar .fill.danger { background: var(--danger); }

          .chart-container {
            display: flex;
            gap: 30px;
            flex-wrap: wrap;
          }

          .chart {
            flex: 1;
            min-width: 250px;
          }

          .bar-chart .bar-item {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
          }

          .bar-chart .bar-label {
            width: 100px;
            font-size: 0.85rem;
            color: #666;
          }

          .bar-chart .bar-container {
            flex: 1;
            height: 25px;
            background: #e9ecef;
            border-radius: 3px;
            overflow: hidden;
          }

          .bar-chart .bar {
            height: 100%;
            display: flex;
            align-items: center;
            padding-left: 10px;
            color: white;
            font-weight: bold;
            font-size: 0.8rem;
          }

          .no-violations {
            text-align: center;
            padding: 50px;
            color: var(--success);
          }

          .no-violations h3 {
            font-size: 3rem;
            margin-bottom: 10px;
          }

          footer {
            text-align: center;
            padding: 20px;
            color: #666;
            font-size: 0.85rem;
          }

          .collapsible {
            cursor: pointer;
            user-select: none;
          }

          .collapsible::before {
            content: '▶ ';
            display: inline-block;
            transition: transform 0.2s;
          }

          .collapsible.open::before {
            transform: rotate(90deg);
          }

          .collapse-content {
            display: none;
            padding: 15px;
          }

          .collapse-content.show {
            display: block;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <header>
            <h1>🍳 Cookstyle Compliance Report</h1>
            <div class="meta">
              <strong>Cookbook:</strong> <%= cookbook_name %> |
              <strong>Generated:</strong> <%= report_time %>
            </div>
            <span class="status-badge <%= status_class %>">
              <% if total_offenses.zero? %>
                ✓ All Checks Passed
              <% else %>
                ✗ <%= total_offenses %> Violation<%= total_offenses == 1 ? '' : 's' %> Found
              <% end %>
            </span>
          </header>

          <div class="cards">
            <div class="card">
              <h3>Compliance Score</h3>
              <div class="value <%= status_class %>"><%= compliance_percentage %>%</div>
              <div class="progress-bar">
                <div class="fill <%= status_class %>" style="width: <%= compliance_percentage %>%"></div>
              </div>
            </div>
            <div class="card">
              <h3>Files Scanned</h3>
              <div class="value"><%= inspected_files %></div>
            </div>
            <div class="card">
              <h3>Total Violations</h3>
              <div class="value <%= total_offenses.zero? ? 'success' : 'danger' %>"><%= total_offenses %></div>
            </div>
            <div class="card">
              <h3>Auto-Correctable</h3>
              <div class="value"><%= correctable_offenses %></div>
            </div>
          </div>

          <% unless total_offenses.zero? %>
          <div class="section">
            <h2>📊 Violations by Severity</h2>
            <div class="chart-container">
              <div class="chart bar-chart">
                <% offenses_by_severity.each do |severity, count| %>
                <div class="bar-item">
                  <span class="bar-label"><%= severity.capitalize %></span>
                  <div class="bar-container">
                    <div class="bar severity <%= severity %>" style="width: <%= (count.to_f / total_offenses * 100).round %>%">
                      <%= count %>
                    </div>
                  </div>
                </div>
                <% end %>
              </div>
            </div>
          </div>

          <div class="section">
            <h2>🔍 Violations by Rule</h2>
            <table>
              <thead>
                <tr>
                  <th>Rule (Cop)</th>
                  <th>Severity</th>
                  <th>Count</th>
                  <th>Correctable</th>
                </tr>
              </thead>
              <tbody>
                <% offenses_by_cop.each do |cop, data| %>
                <tr>
                  <td><code><%= cop %></code></td>
                  <td><span class="severity <%= data[:severity] %>"><%= data[:severity] %></span></td>
                  <td><%= data[:count] %></td>
                  <td><%= data[:correctable] > 0 ? "✓ #{data[:correctable]}" : '—' %></td>
                </tr>
                <% end %>
              </tbody>
            </table>
          </div>

          <div class="section">
            <h2>📁 Files with Violations</h2>
            <% files_with_offenses.each do |file| %>
            <div style="margin-bottom: 20px;">
              <h4 class="collapsible file-path" onclick="toggleCollapse(this)">
                <%= file['path'] %>
                <span class="severity <%= file['offenses'].first['severity'] %>">
                  <%= file['offenses'].length %> issue<%= file['offenses'].length == 1 ? '' : 's' %>
                </span>
              </h4>
              <div class="collapse-content">
                <% (file['offenses'] || []).each do |offense| %>
                <div class="offense-details">
                  <span class="severity <%= offense['severity'] %>"><%= SEVERITY_ICONS[offense['severity']] %> <%= offense['severity'] %></span>
                  <strong><%= offense['cop_name'] %></strong>
                  <% if offense['correctable'] %><span style="color: var(--success);">🔧 Auto-correctable</span><% end %>
                  <div class="offense-message"><%= offense['message'] %></div>
                  <div class="offense-location">
                    Line <%= offense.dig('location', 'line') || '?' %>, Column <%= offense.dig('location', 'column') || '?' %>
                  </div>
                </div>
                <% end %>
              </div>
            </div>
            <% end %>
          </div>
          <% else %>
          <div class="section">
            <div class="no-violations">
              <h3>🎉</h3>
              <p>Excellent! No compliance violations found.</p>
              <p>This cookbook meets all Barclays Cookstyle standards.</p>
            </div>
          </div>
          <% end %>

          <footer>
            <p>Generated by Barclays Cookstyle Compliance Pipeline v<%= VERSION %></p>
            <p>Report includes checks from b-cookstyle-rules with BARC custom cops</p>
          </footer>
        </div>

        <script>
          function toggleCollapse(element) {
            element.classList.toggle('open');
            const content = element.nextElementSibling;
            content.classList.toggle('show');
          }

          // Auto-expand first file
          const firstCollapsible = document.querySelector('.collapsible');
          if (firstCollapsible) {
            toggleCollapse(firstCollapsible);
          }
        </script>
      </body>
      </html>
    HTML
  end
end

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on('-i', '--input FILE', 'Input JSON file from Cookstyle') do |v|
    options[:input] = v
  end

  opts.on('-o', '--output DIR', 'Output directory for reports') do |v|
    options[:output] = v
  end

  opts.on('-c', '--cookbook NAME', 'Cookbook name') do |v|
    options[:cookbook] = v
  end

  opts.on('-t', '--template-dir DIR', 'Template directory') do |v|
    options[:template_dir] = v
  end

  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit
  end
end.parse!

# Validate required options
%i[input output cookbook].each do |opt|
  unless options[opt]
    puts "Error: --#{opt} is required"
    exit 1
  end
end

# Ensure output directory exists
FileUtils.mkdir_p(options[:output])

# Generate report
begin
  generator = ComplianceReportGenerator.new(options)
  generator.run
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.first(5).join("\n") if ENV['DEBUG']
  exit 1
end
