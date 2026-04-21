#!/bin/bash

#######################################################################
# test_local.sh
#
# Test the compliance pipeline locally without Jenkins
#
# Usage:
#   ./test_local.sh --cookbook PATH [--auto-fix]
#######################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Default values
COOKBOOK_PATH=""
AUTO_FIX=false
RULES_PATH="${WORKSPACE_DIR}/../cookbooks/b-cookstyle-rules"
OUTPUT_DIR="${WORKSPACE_DIR}/test-output"

usage() {
    cat << EOF
Local Compliance Test Runner

Usage: $0 --cookbook PATH [OPTIONS]

Required:
  --cookbook PATH    Path to the cookbook to test

Options:
  --rules PATH       Path to b-cookstyle-rules (default: ${RULES_PATH})
  --output PATH      Output directory for reports (default: ${OUTPUT_DIR})
  --auto-fix         Enable auto-correction of fixable violations
  -h, --help         Show this help

Examples:
  # Test a local cookbook
  $0 --cookbook ../cookbooks/my-cookbook

  # Test with auto-fix
  $0 --cookbook ../cookbooks/my-cookbook --auto-fix

  # Test one of the sample cookbooks
  $0 --cookbook ../cookbooks/compliant-cookbook
  $0 --cookbook ../cookbooks/bad_cookbook

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
        --auto-fix)
            AUTO_FIX=true
            shift
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

# Validate
if [[ -z "$COOKBOOK_PATH" ]]; then
    log_error "Cookbook path is required"
    usage
fi

if [[ ! -d "$COOKBOOK_PATH" ]]; then
    log_error "Cookbook directory not found: $COOKBOOK_PATH"
    exit 1
fi

if [[ ! -d "$RULES_PATH" ]]; then
    log_error "Rules directory not found: $RULES_PATH"
    log_info "Expected path: $RULES_PATH"
    exit 1
fi

# Get absolute paths
COOKBOOK_PATH="$(cd "$COOKBOOK_PATH" && pwd)"
RULES_PATH="$(cd "$RULES_PATH" && pwd)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           LOCAL COMPLIANCE TEST                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
log_info "Cookbook: $COOKBOOK_PATH"
log_info "Rules:    $RULES_PATH"
log_info "Output:   $OUTPUT_DIR"
log_info "Auto-fix: $AUTO_FIX"
echo ""

# Step 1: Install dependencies if needed
if [[ ! -d "${RULES_PATH}/vendor/bundle" ]]; then
    log_info "Installing Ruby dependencies..."
    (cd "$RULES_PATH" && bundle install --path vendor/bundle)
fi

# Step 2: Run cookstyle
log_info "Running Cookstyle compliance checks..."

AUTO_FLAG=""
if [[ "$AUTO_FIX" == true ]]; then
    AUTO_FLAG="-a"
fi

"${SCRIPT_DIR}/run_cookstyle.sh" \
    --cookbook "$COOKBOOK_PATH" \
    --rules "$RULES_PATH" \
    --output "$OUTPUT_DIR" \
    --format all \
    $AUTO_FLAG || true

# Step 3: Generate HTML report
if [[ -f "${OUTPUT_DIR}/cookstyle-output.json" ]]; then
    log_info "Generating HTML report..."

    COOKBOOK_NAME=$(basename "$COOKBOOK_PATH")

    ruby "${SCRIPT_DIR}/generate_report.rb" \
        --input "${OUTPUT_DIR}/cookstyle-output.json" \
        --output "$OUTPUT_DIR" \
        --cookbook "$COOKBOOK_NAME" \
        --template-dir "${SCRIPT_DIR}/../templates"
fi

# Step 4: Summary
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           TEST COMPLETE                                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
log_info "Reports generated in: $OUTPUT_DIR"
echo ""
echo "  📄 Console output:    ${OUTPUT_DIR}/cookstyle-console.log"
echo "  📊 JSON report:       ${OUTPUT_DIR}/cookstyle-output.json"
echo "  📋 JUnit XML:         ${OUTPUT_DIR}/cookstyle-junit.xml"
echo "  🌐 HTML report:       ${OUTPUT_DIR}/compliance-report.html"
echo "  📝 Summary:           ${OUTPUT_DIR}/summary.txt"
echo ""

# Open HTML report if on macOS
if [[ "$(uname)" == "Darwin" ]] && [[ -f "${OUTPUT_DIR}/compliance-report.html" ]]; then
    log_info "Opening HTML report..."
    open "${OUTPUT_DIR}/compliance-report.html"
fi

log_success "Done!"
