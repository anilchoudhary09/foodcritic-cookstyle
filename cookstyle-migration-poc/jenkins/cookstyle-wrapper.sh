#!/bin/bash
#
# cookstyle-wrapper.sh - Wrapper script for running Cookstyle with custom rules
#
# This script provides a consistent interface for running Cookstyle with
# the b-cookstyle-rules gem across different environments (local dev, CI/CD).
#
# Usage:
#   ./cookstyle-wrapper.sh [options] [cookbook_paths...]
#
# Options:
#   -h, --help          Show this help message
#   -f, --fix           Auto-correct violations where possible
#   -s, --strict        Fail on warnings (not just errors)
#   -q, --quiet         Minimal output
#   -v, --verbose       Verbose output
#   --format FORMAT     Output format (progress, json, html, simple)
#   --output FILE       Write report to file
#   --config FILE       Use specific .rubocop.yml config
#   --no-custom         Skip custom rules (standard Cookstyle only)
#
# Examples:
#   ./cookstyle-wrapper.sh cookbooks/my-cookbook
#   ./cookstyle-wrapper.sh --fix --strict cookbooks/
#   ./cookstyle-wrapper.sh --format json --output report.json cookbooks/
#

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_RULES_GEM="b_cookstyle_rules"
DEFAULT_FORMAT="progress"
DEFAULT_CONFIG=".rubocop.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
AUTO_FIX=false
STRICT_MODE=false
QUIET_MODE=false
VERBOSE_MODE=false
OUTPUT_FORMAT="${DEFAULT_FORMAT}"
OUTPUT_FILE=""
CONFIG_FILE=""
USE_CUSTOM_RULES=true
COOKBOOK_PATHS=()

# Logging functions
log_info() {
    [[ "${QUIET_MODE}" == "false" ]] && echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    [[ "${QUIET_MODE}" == "false" ]] && echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    [[ "${VERBOSE_MODE}" == "true" ]] && echo -e "[DEBUG] $*"
}

# Show help
show_help() {
    sed -n '/^# Usage:/,/^[^#]/p' "$0" | grep '^#' | sed 's/^# //' | head -n -1
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -f|--fix)
                AUTO_FIX=true
                shift
                ;;
            -s|--strict)
                STRICT_MODE=true
                shift
                ;;
            -q|--quiet)
                QUIET_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE_MODE=true
                shift
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --no-custom)
                USE_CUSTOM_RULES=false
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                ;;
            *)
                COOKBOOK_PATHS+=("$1")
                shift
                ;;
        esac
    done

    # Default to current directory if no paths specified
    if [[ ${#COOKBOOK_PATHS[@]} -eq 0 ]]; then
        COOKBOOK_PATHS=(".")
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Ruby
    if ! command -v ruby &> /dev/null; then
        log_error "Ruby is not installed"
        exit 1
    fi
    log_debug "Ruby version: $(ruby --version)"

    # Check Bundler
    if ! command -v bundle &> /dev/null; then
        log_warn "Bundler not found, installing..."
        gem install bundler --no-document
    fi

    # Check if gems are installed
    if ! bundle check &> /dev/null; then
        log_info "Installing gem dependencies..."
        bundle install --quiet
    fi

    # Check for custom rules gem
    if [[ "${USE_CUSTOM_RULES}" == "true" ]]; then
        if ! bundle exec ruby -e "require '${CUSTOM_RULES_GEM}'" &> /dev/null; then
            log_warn "Custom rules gem '${CUSTOM_RULES_GEM}' not found"
            log_warn "Running with standard Cookstyle rules only"
            USE_CUSTOM_RULES=false
        fi
    fi

    log_success "Prerequisites check passed"
}

# Build cookstyle command
build_command() {
    local cmd="bundle exec cookstyle"

    # Add format options
    cmd+=" --format ${OUTPUT_FORMAT}"

    # Add output file if specified
    if [[ -n "${OUTPUT_FILE}" ]]; then
        cmd+=" --out ${OUTPUT_FILE}"
        # Also show progress to console
        cmd+=" --format progress"
    fi

    # Add config file if specified
    if [[ -n "${CONFIG_FILE}" ]]; then
        cmd+=" --config ${CONFIG_FILE}"
    fi

    # Add custom rules
    if [[ "${USE_CUSTOM_RULES}" == "true" ]]; then
        cmd+=" --require ${CUSTOM_RULES_GEM}"
    fi

    # Add auto-fix option
    if [[ "${AUTO_FIX}" == "true" ]]; then
        cmd+=" --autocorrect"
    fi

    # Add fail level
    if [[ "${STRICT_MODE}" == "true" ]]; then
        cmd+=" --fail-level warning"
    else
        cmd+=" --fail-level error"
    fi

    # Add extra options for different modes
    if [[ "${VERBOSE_MODE}" == "true" ]]; then
        cmd+=" --debug"
    fi

    # Add cookbook paths
    cmd+=" ${COOKBOOK_PATHS[*]}"

    echo "${cmd}"
}

# Run cookstyle
run_cookstyle() {
    local cmd
    cmd=$(build_command)

    log_info "Running Cookstyle analysis..."
    log_debug "Command: ${cmd}"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                     COOKSTYLE LINTING ANALYSIS                        ║"
    echo "╠═══════════════════════════════════════════════════════════════════════╣"
    echo "║  Cookbooks: ${COOKBOOK_PATHS[*]}"
    echo "║  Custom Rules: ${USE_CUSTOM_RULES}"
    echo "║  Auto-Fix: ${AUTO_FIX}"
    echo "║  Strict Mode: ${STRICT_MODE}"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo ""

    # Execute cookstyle
    local exit_code=0
    eval "${cmd}" || exit_code=$?

    echo ""

    # Interpret exit code
    case ${exit_code} in
        0)
            log_success "No violations found!"
            ;;
        1)
            log_error "Cookstyle found violations"
            ;;
        2)
            log_error "Cookstyle terminated with errors"
            ;;
        *)
            log_error "Unknown exit code: ${exit_code}"
            ;;
    esac

    return ${exit_code}
}

# Generate summary report
generate_summary() {
    if [[ -n "${OUTPUT_FILE}" && -f "${OUTPUT_FILE}" && "${OUTPUT_FORMAT}" == "json" ]]; then
        log_info "Generating summary from ${OUTPUT_FILE}..."

        bundle exec ruby -r json -e '
            data = JSON.parse(File.read(ARGV[0]))
            summary = data["summary"]

            puts "\nSUMMARY"
            puts "=" * 50
            puts "Files inspected: #{summary["inspected_file_count"]}"
            puts "Total offenses: #{summary["offense_count"]}"
            puts "Auto-corrected: #{summary["corrected_count"] || 0}"

            if data["files"]
                by_cop = Hash.new(0)
                data["files"].each do |f|
                    f["offenses"].each { |o| by_cop[o["cop_name"]] += 1 }
                end

                unless by_cop.empty?
                    puts "\nTop Violations:"
                    by_cop.sort_by { |_, c| -c }.first(10).each do |cop, count|
                        puts "  #{count.to_s.rjust(4)} - #{cop}"
                    end
                end
            end
        ' "${OUTPUT_FILE}"
    fi
}

# Main execution
main() {
    parse_args "$@"
    check_prerequisites

    local exit_code=0
    run_cookstyle || exit_code=$?

    generate_summary

    exit ${exit_code}
}

# Run main function
main "$@"
