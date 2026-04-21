#!/bin/bash

#######################################################################
# fetch_cookbook.sh
#
# Fetches a cookbook from Chef Server or Bitbucket
#
# Usage:
#   ./fetch_cookbook.sh --name COOKBOOK_NAME --output DIR [OPTIONS]
#
# Options:
#   --name        Cookbook name (required)
#   --version     Cookbook version (default: latest)
#   --output      Output directory (required)
#   --source      Source type: chef-server or bitbucket (default: chef-server)
#   --chef-key    Path to Chef Server client key
#   --chef-server Chef Server URL
#   --chef-user   Chef Server username
#   --repo-url    Bitbucket repository URL
#   --branch      Git branch (default: master)
#######################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VERSION="latest"
SOURCE="chef-server"
BRANCH="master"
CHEF_SERVER="${CHEF_SERVER_URL:-https://chef-server.company.com/organizations/default}"
CHEF_USER="${CHEF_USER:-jenkins}"

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
Usage: $0 --name COOKBOOK_NAME --output DIR [OPTIONS]

Required:
  --name          Cookbook name
  --output        Output directory

Options:
  --version       Cookbook version (default: latest)
  --source        Source type: chef-server or bitbucket (default: chef-server)
  --chef-key      Path to Chef Server client key
  --chef-server   Chef Server URL (default: \$CHEF_SERVER_URL)
  --chef-user     Chef Server username (default: \$CHEF_USER or jenkins)
  --repo-url      Bitbucket repository URL (for bitbucket source)
  --branch        Git branch (default: master)
  -h, --help      Show this help message

Examples:
  # Fetch from Chef Server
  $0 --name my-cookbook --version 1.2.3 --output ./cookbooks --chef-key ~/.chef/client.pem

  # Fetch from Bitbucket
  $0 --name my-cookbook --source bitbucket --repo-url git@bitbucket.com:team/cookbook.git --output ./cookbooks

EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            COOKBOOK_NAME="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --source)
            SOURCE="$2"
            shift 2
            ;;
        --chef-key)
            CHEF_KEY="$2"
            shift 2
            ;;
        --chef-server)
            CHEF_SERVER="$2"
            shift 2
            ;;
        --chef-user)
            CHEF_USER="$2"
            shift 2
            ;;
        --repo-url)
            REPO_URL="$2"
            shift 2
            ;;
        --branch)
            BRANCH="$2"
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
if [[ -z "${COOKBOOK_NAME:-}" ]]; then
    log_error "Cookbook name is required"
    usage
fi

if [[ -z "${OUTPUT_DIR:-}" ]]; then
    log_error "Output directory is required"
    usage
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

#######################################################################
# Fetch from Chef Server
#######################################################################
fetch_from_chef_server() {
    log_info "Fetching cookbook '${COOKBOOK_NAME}' from Chef Server..."

    if [[ -z "${CHEF_KEY:-}" ]]; then
        log_error "Chef Server client key is required (--chef-key)"
        exit 1
    fi

    if [[ ! -f "$CHEF_KEY" ]]; then
        log_error "Chef key file not found: $CHEF_KEY"
        exit 1
    fi

    # Create temporary knife config
    KNIFE_CONFIG=$(mktemp)
    trap "rm -f $KNIFE_CONFIG" EXIT

    cat > "$KNIFE_CONFIG" << EOF
chef_server_url '${CHEF_SERVER}'
node_name '${CHEF_USER}'
client_key '${CHEF_KEY}'
cookbook_path ['${OUTPUT_DIR}']
EOF

    # Get available versions if 'latest' is specified
    if [[ "$VERSION" == "latest" ]]; then
        log_info "Fetching latest version of cookbook..."
        VERSION=$(knife cookbook show "$COOKBOOK_NAME" -c "$KNIFE_CONFIG" 2>/dev/null | head -1 | awk '{print $2}' || echo "")

        if [[ -z "$VERSION" ]]; then
            log_error "Could not determine latest version of cookbook '${COOKBOOK_NAME}'"
            exit 1
        fi
        log_info "Latest version: $VERSION"
    fi

    # Download the cookbook
    log_info "Downloading cookbook ${COOKBOOK_NAME} version ${VERSION}..."

    knife cookbook download "$COOKBOOK_NAME" "$VERSION" \
        -d "$OUTPUT_DIR" \
        -c "$KNIFE_CONFIG" \
        --force

    # Rename the versioned directory to just the cookbook name
    VERSIONED_DIR="${OUTPUT_DIR}/${COOKBOOK_NAME}-${VERSION}"
    if [[ -d "$VERSIONED_DIR" ]]; then
        # Remove existing cookbook dir if exists
        rm -rf "${OUTPUT_DIR}/${COOKBOOK_NAME}" 2>/dev/null || true
        mv "$VERSIONED_DIR" "${OUTPUT_DIR}/${COOKBOOK_NAME}"
    fi

    log_success "Cookbook downloaded to: ${OUTPUT_DIR}/${COOKBOOK_NAME}"
}

#######################################################################
# Fetch from Bitbucket
#######################################################################
fetch_from_bitbucket() {
    log_info "Fetching cookbook '${COOKBOOK_NAME}' from Bitbucket..."

    if [[ -z "${REPO_URL:-}" ]]; then
        log_error "Repository URL is required for Bitbucket source (--repo-url)"
        exit 1
    fi

    COOKBOOK_PATH="${OUTPUT_DIR}/${COOKBOOK_NAME}"

    # Remove existing directory if exists
    if [[ -d "$COOKBOOK_PATH" ]]; then
        log_warn "Removing existing directory: $COOKBOOK_PATH"
        rm -rf "$COOKBOOK_PATH"
    fi

    # Clone the repository
    log_info "Cloning repository from $REPO_URL (branch: $BRANCH)..."

    git clone \
        --depth 1 \
        --single-branch \
        --branch "$BRANCH" \
        "$REPO_URL" \
        "$COOKBOOK_PATH"

    # Remove .git directory to save space
    rm -rf "${COOKBOOK_PATH}/.git"

    log_success "Cookbook cloned to: $COOKBOOK_PATH"
}

#######################################################################
# Verify cookbook structure
#######################################################################
verify_cookbook() {
    local cookbook_path="${OUTPUT_DIR}/${COOKBOOK_NAME}"

    log_info "Verifying cookbook structure..."

    # Check for metadata.rb or metadata.json
    if [[ ! -f "${cookbook_path}/metadata.rb" ]] && [[ ! -f "${cookbook_path}/metadata.json" ]]; then
        log_error "Invalid cookbook: missing metadata.rb or metadata.json"
        exit 1
    fi

    # Check for recipes directory (optional but common)
    if [[ ! -d "${cookbook_path}/recipes" ]]; then
        log_warn "No recipes directory found (this may be intentional for library cookbooks)"
    fi

    # Output cookbook info
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  COOKBOOK INFORMATION"
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Name:     ${COOKBOOK_NAME}"
    echo "  Path:     ${cookbook_path}"
    echo "  Source:   ${SOURCE}"

    if [[ "$SOURCE" == "chef-server" ]]; then
        echo "  Version:  ${VERSION}"
    else
        echo "  Branch:   ${BRANCH}"
    fi

    # Count files
    local file_count=$(find "$cookbook_path" -type f | wc -l | tr -d ' ')
    local recipe_count=$(find "$cookbook_path/recipes" -name "*.rb" 2>/dev/null | wc -l | tr -d ' ')

    echo "  Files:    ${file_count}"
    echo "  Recipes:  ${recipe_count}"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    log_success "Cookbook verification passed"
}

#######################################################################
# Main
#######################################################################
main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              COOKBOOK FETCH UTILITY                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    case "$SOURCE" in
        chef-server)
            fetch_from_chef_server
            ;;
        bitbucket)
            fetch_from_bitbucket
            ;;
        *)
            log_error "Unknown source type: $SOURCE"
            log_error "Valid options: chef-server, bitbucket"
            exit 1
            ;;
    esac

    verify_cookbook

    log_success "Cookbook fetch completed successfully!"
}

main
