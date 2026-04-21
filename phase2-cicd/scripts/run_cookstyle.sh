#!/bin/bash

#######################################################################
# run_cookstyle.sh
#
# Runs Cookstyle with custom Barclays rules on a cookbook
#
# Usage:
#   ./run_cookstyle.sh --cookbook PATH --rules PATH --output PATH [OPTIONS]
#
# Options:
#   --cookbook    Path to cookbook directory (required)
#   --rules       Path to b-cookstyle-rules directory (required)
#   --output      Output directory for reports (required)
#   --format      Output format: json, html, junit, all (default: all)
#   -a            Auto-correct fixable violations
#   --severity    Minimum severity to report: info, warning, error (default: info)
#######################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
FORMAT="all"
AUTO_CORRECT=false
SEVERITY="info"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Usage function
usage() {
    cat << EOF
Usage: $0 --cookbook PATH --rules PATH --output PATH [OPTIONS]

Required:
  --cookbook      Path to cookbook directory
  --rules         Path to b-cookstyle-rules directory
  --output        Output directory for reports

Options:
  --format        Output format: json, html, junit, all (default: all)
  -a, --auto      Auto-correct fixable violations
  --severity      Minimum severity: info, warning, error (default: info)
  -h, --help      Show this help message

Examples:
  $0 --cookbook ./my-cookbook --rules ./b-cookstyle-rules --output ./reports

  $0 --cookbook ./my-cookbook --rules ./b-cookstyle-rules --output ./reports -a

EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --cookbook)
            COOKBOOK_PATH="$2"
            shift 2
            ;;
        --rules)
            RULES_PATH="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        -a|--auto)
            AUTO_CORRECT=true
            shift
            ;;
        --severity)
            SEVERITY="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "${COOKBOOK_PATH:-}" ]]; then
    log_error "Cookbook path is required"
    usage
fi

if [[ -z "${RULES_PATH:-}" ]]; then
    log_error "Rules path is required"
    usage
fi

if [[ -z "${OUTPUT_DIR:-}" ]]; then
    log_error "Output directory is required"
    usage
fi

# Validate paths exist
if [[ ! -d "$COOKBOOK_PATH" ]]; then
    log_error "Cookbook directory not found: $COOKBOOK_PATH"
    exit 1
fi

if [[ ! -d "$RULES_PATH" ]]; then
    log_error "Rules directory not found: $RULES_PATH"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get cookbook name from metadata
get_cookbook_name() {
    if [[ -f "${COOKBOOK_PATH}/metadata.rb" ]]; then
        grep -E "^name\s+" "${COOKBOOK_PATH}/metadata.rb" | sed -E "s/^name\s+['\"]([^'\"]+)['\"].*/\1/" || basename "$COOKBOOK_PATH"
    else
        basename "$COOKBOOK_PATH"
    fi
}

COOKBOOK_NAME=$(get_cookbook_name)

#######################################################################
# Create .rubocop.yml configuration for the cookbook
#######################################################################
create_rubocop_config() {
    log_info "Creating Cookstyle configuration..."

    cat > "${COOKBOOK_PATH}/.rubocop.yml" << EOF
# Auto-generated Cookstyle configuration for CI/CD pipeline
# This file configures Cookstyle to use Barclays custom rules

require:
  - ${RULES_PATH}/barc_cops.rb

AllCops:
  TargetChefVersion: 18.0
  NewCops: enable
  Include:
    - '**/*.rb'
  Exclude:
    - 'vendor/**/*'
    - 'test/**/*'
    - 'spec/**/*'
    - 'files/**/*'
    - 'Berksfile'
    - 'Gemfile'
    - 'Rakefile'
    - 'Guardfile'
    - 'Vagrantfile'

# Include all BARC rules
BARC:
  Enabled: true
EOF

    log_success "Cookstyle configuration created"
}

#######################################################################
# Run Cookstyle
#######################################################################
run_cookstyle() {
    log_info "Running Cookstyle compliance checks..."

    local auto_flag=""
    if [[ "$AUTO_CORRECT" == true ]]; then
        auto_flag="--autocorrect"
        log_info "Auto-correct mode enabled"
    fi

    # Build format options based on requested format
    local format_options=""
    case "$FORMAT" in
        json)
            format_options="--format json --out ${OUTPUT_DIR}/cookstyle-output.json"
            ;;
        junit)
            format_options="--format junit --out ${OUTPUT_DIR}/cookstyle-junit.xml"
            ;;
        html)
            format_options="--format html --out ${OUTPUT_DIR}/cookstyle-output.html"
            ;;
        all)
            format_options="--format json --out ${OUTPUT_DIR}/cookstyle-output.json"
            ;;
    esac

    # Run cookstyle
    cd "$RULES_PATH"

    local exit_code=0
    bundle exec cookstyle \
        --config "${COOKBOOK_PATH}/.rubocop.yml" \
        --format progress \
        $format_options \
        $auto_flag \
        "$COOKBOOK_PATH" 2>&1 | tee "${OUTPUT_DIR}/cookstyle-console.log" || exit_code=$?

    return $exit_code
}

#######################################################################
# Generate summary
#######################################################################
generate_summary() {
    local json_output="${OUTPUT_DIR}/cookstyle-output.json"

    if [[ ! -f "$json_output" ]]; then
        log_warn "JSON output not found, skipping summary generation"
        return
    fi

    log_info "Generating summary..."

    # Parse JSON and create summary using Ruby
    ruby -rjson << EOF > "${OUTPUT_DIR}/summary.txt"
require 'json'

data = JSON.parse(File.read('${json_output}'))
summary = data['summary'] || {}

offense_count = summary['offense_count'] || 0
file_count = summary['inspected_file_count'] || 0
corrected = summary['corrected_offense_count'] || 0

# Count by severity
by_severity = Hash.new(0)
(data['files'] || []).each do |file|
  (file['offenses'] || []).each do |offense|
    by_severity[offense['severity']] += 1
  end
end

puts "║ Cookbook:      ${COOKBOOK_NAME}"
puts "║ Files checked: #{file_count}"
puts "║ Violations:    #{offense_count}"
puts "║ Corrected:     #{corrected}" if corrected > 0
puts "║"
puts "║ By Severity:"
by_severity.each do |sev, count|
  puts "║   #{sev.capitalize}: #{count}"
end
EOF

    log_success "Summary generated"
}

#######################################################################
# Convert to JUnit XML format
#######################################################################
convert_to_junit() {
    local json_output="${OUTPUT_DIR}/cookstyle-output.json"
    local junit_output="${OUTPUT_DIR}/cookstyle-junit.xml"

    if [[ ! -f "$json_output" ]]; then
        log_warn "JSON output not found, skipping JUnit conversion"
        return
    fi

    log_info "Converting to JUnit XML format..."

    ruby -rjson << EOF > "$junit_output"
require 'json'
require 'cgi'

data = JSON.parse(File.read('${json_output}'))
summary = data['summary'] || {}
files = data['files'] || []

total_tests = summary['inspected_file_count'] || 0
failures = summary['offense_count'] || 0
time = 0

puts '<?xml version="1.0" encoding="UTF-8"?>'
puts "<testsuite name=\"Cookstyle\" tests=\"#{total_tests}\" failures=\"#{failures}\" errors=\"0\" time=\"#{time}\">"

files.each do |file|
  file_path = file['path']
  offenses = file['offenses'] || []

  if offenses.empty?
    puts "  <testcase name=\"#{CGI.escapeHTML(file_path)}\" classname=\"Cookstyle\" time=\"0\"/>"
  else
    offenses.each do |offense|
      cop_name = offense['cop_name']
      message = offense['message']
      line = offense['location']['line'] rescue 0
      severity = offense['severity']

      puts "  <testcase name=\"#{CGI.escapeHTML(file_path)}:#{line}\" classname=\"#{CGI.escapeHTML(cop_name)}\" time=\"0\">"
      puts "    <failure message=\"#{CGI.escapeHTML(message)}\" type=\"#{severity}\">"
      puts "      File: #{CGI.escapeHTML(file_path)}"
      puts "      Line: #{line}"
      puts "      Cop: #{CGI.escapeHTML(cop_name)}"
      puts "      Severity: #{severity}"
      puts "      Message: #{CGI.escapeHTML(message)}"
      puts "    </failure>"
      puts "  </testcase>"
    end
  end
end

puts "</testsuite>"
EOF

    log_success "JUnit XML created: $junit_output"
}

#######################################################################
# Print results
#######################################################################
print_results() {
    local json_output="${OUTPUT_DIR}/cookstyle-output.json"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              COOKSTYLE COMPLIANCE RESULTS                     ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"

    if [[ -f "${OUTPUT_DIR}/summary.txt" ]]; then
        cat "${OUTPUT_DIR}/summary.txt"
    fi

    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║ Output Files:                                                 ║"
    echo "║   - ${OUTPUT_DIR}/cookstyle-output.json"
    echo "║   - ${OUTPUT_DIR}/cookstyle-junit.xml"
    echo "║   - ${OUTPUT_DIR}/cookstyle-console.log"
    echo "║   - ${OUTPUT_DIR}/summary.txt"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

#######################################################################
# Main
#######################################################################
main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              COOKSTYLE COMPLIANCE CHECKER                     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    log_info "Cookbook:    $COOKBOOK_PATH"
    log_info "Rules:       $RULES_PATH"
    log_info "Output:      $OUTPUT_DIR"
    log_info "Format:      $FORMAT"
    log_info "Auto-fix:    $AUTO_CORRECT"
    echo ""

    create_rubocop_config

    local exit_code=0
    run_cookstyle || exit_code=$?

    generate_summary

    if [[ "$FORMAT" == "all" ]] || [[ "$FORMAT" == "junit" ]]; then
        convert_to_junit
    fi

    print_results

    if [[ $exit_code -eq 0 ]]; then
        log_success "All compliance checks passed!"
    else
        log_warn "Compliance violations found (exit code: $exit_code)"
    fi

    exit $exit_code
}

main
