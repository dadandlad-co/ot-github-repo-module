#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up OpenTofu GitHub Repository Module environment...${NC}"

# Create terraform plugin cache directory
PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugin-cache"
if [[ ! -d "${PLUGIN_CACHE_DIR}" ]]; then
    echo -e "${YELLOW}📁 Creating Terraform plugin cache directory...${NC}"
    mkdir -p "${PLUGIN_CACHE_DIR}"
    echo -e "${GREEN}✅ Created ${PLUGIN_CACHE_DIR}${NC}"
else
    echo -e "${GREEN}✅ Plugin cache directory already exists${NC}"
fi

# Check if required tools are installed
check_tool() {
    local tool=$1
    local install_cmd=$2

    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✅ $tool is installed${NC}"
        return 0
    else
        echo -e "${RED}❌ $tool is not installed${NC}"
        if [[ -n "$install_cmd" ]]; then
            echo -e "${YELLOW}   Install with: $install_cmd${NC}"
        fi
        return 1
    fi
}

echo -e "\n${BLUE}🔍 Checking required tools...${NC}"

# Required tools
tools_missing=0

check_tool "tofu" "https://opentofu.org/docs/intro/install/" || ((tools_missing++))
check_tool "tflint" "brew install tflint" || ((tools_missing++))
check_tool "terraform-docs" "brew install terraform-docs" || ((tools_missing++))
check_tool "pre-commit" "pip install pre-commit" || ((tools_missing++))
check_tool "direnv" "brew install direnv" || ((tools_missing++))

# Optional but recommended tools
echo -e "\n${BLUE}🔍 Checking optional tools...${NC}"
check_tool "tfsec" "brew install tfsec" || echo -e "${YELLOW}   ⚠️  tfsec is optional but recommended for security scanning${NC}"
check_tool "shellcheck" "brew install shellcheck" || echo -e "${YELLOW}   ⚠️  shellcheck is optional for shell script linting${NC}"

# Check GitHub token
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo -e "\n${YELLOW}⚠️  GITHUB_TOKEN environment variable is not set${NC}"
    echo -e "${YELLOW}   This is required for GitHub API access${NC}"
    echo -e "${YELLOW}   Set it in your shell profile or .env file${NC}"
else
    echo -e "\n${GREEN}✅ GITHUB_TOKEN is configured${NC}"
fi

# Setup pre-commit hooks
if [[ $tools_missing -eq 0 ]]; then
    echo -e "\n${BLUE}🔗 Installing pre-commit hooks...${NC}"
    if pre-commit install; then
        echo -e "${GREEN}✅ Pre-commit hooks installed${NC}"
    else
        echo -e "${RED}❌ Failed to install pre-commit hooks${NC}"
    fi
else
    echo -e "\n${RED}❌ Cannot install pre-commit hooks - missing required tools${NC}"
fi

# Initialize OpenTofu in examples
echo -e "\n${BLUE}🏗️  Initializing OpenTofu in example directories...${NC}"
for example in examples/*/; do
    if [[ -f "${example}main.tf" ]]; then
        echo -e "${YELLOW}   Initializing ${example}...${NC}"
        (cd "$example" && tofu init -backend=false) || echo -e "${RED}   ❌ Failed to initialize ${example}${NC}"
    fi
done

echo -e "\n${GREEN}🎉 Setup complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "${YELLOW}1. Set GITHUB_TOKEN environment variable${NC}"
echo -e "${YELLOW}2. Run 'direnv allow' to load environment${NC}"
echo -e "${YELLOW}3. Run 'task' to validate the module${NC}"
