#!/bin/bash

# Comprehensive Codespace Verification Script
# This script performs non-destructive checks to verify the development environment
# is properly configured and all dependencies are available.

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables to track results
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=()

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_check() {
    echo -e "${YELLOW}Checking: $1${NC}"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED_CHECKS+=("$1")
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check disk usage
check_disk_space() {
    local usage=$(df . | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$usage" -lt 90 ]; then
        print_success "Disk usage: ${usage}% (below 90% threshold)"
    else
        print_fail "Disk usage: ${usage}% (exceeds 90% threshold)"
    fi
}

# Check memory
check_memory() {
    if command_exists free; then
        local mem_info=$(free -h | grep "Mem:")
        print_info "Memory status: $mem_info"
        print_success "Memory information retrieved"
    else
        print_info "Memory check not available on this system"
        print_success "Memory check skipped (not critical)"
    fi
}

# Check CPU load
check_cpu_load() {
    if [ -f /proc/loadavg ]; then
        local load_avg=$(cat /proc/loadavg | cut -d' ' -f1-3)
        print_info "CPU load average (1m 5m 15m): $load_avg"
        print_success "CPU load information retrieved"
    else
        print_info "CPU load check not available on this system"
        print_success "CPU load check skipped (not critical)"
    fi
}

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                 CODESPACE VERIFICATION SCRIPT                ║${NC}"
echo -e "${BLUE}║              Comprehensive Environment Check                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

# ============================================================================
# SECTION 1: SYSTEM RESOURCE CHECK
# ============================================================================
print_header "Section 1: System Resource Check"

print_check "Disk space usage"
check_disk_space

print_check "Memory status"
check_memory

print_check "CPU load average"
check_cpu_load

# ============================================================================
# SECTION 2: CORE DEPENDENCY VERIFICATION
# ============================================================================
print_header "Section 2: Core Dependency Verification"

print_check "Git installation and version"
if command_exists git; then
    local git_version=$(git --version)
    print_success "Git found: $git_version"
else
    print_fail "Git not found in PATH"
fi

print_check "Python3 installation and version"
if command_exists python3; then
    local python_version=$(python3 --version)
    print_success "Python3 found: $python_version"
else
    print_fail "Python3 not found in PATH"
fi

print_check "pip3 installation and version"
if command_exists pip3; then
    local pip_version=$(pip3 --version)
    print_success "pip3 found: $pip_version"
else
    print_fail "pip3 not found in PATH"
fi

print_check "Node.js installation and version"
if command_exists node; then
    local node_version=$(node --version)
    print_success "Node.js found: $node_version"
else
    print_fail "Node.js not found in PATH"
fi

print_check "npm installation and version"
if command_exists npm; then
    local npm_version=$(npm --version)
    print_success "npm found: v$npm_version"
else
    print_fail "npm not found in PATH"
fi

print_check "Docker installation and daemon status"
if command_exists docker; then
    local docker_version=$(docker --version)
    print_info "Docker found: $docker_version"
    
    if docker info >/dev/null 2>&1; then
        print_success "Docker daemon is running"
    else
        print_fail "Docker daemon is not running or not accessible"
    fi
else
    print_fail "Docker not found in PATH"
fi# =====
=======================================================================
# SECTION 3: PROJECT CONFIGURATION & ENVIRONMENT VARIABLES
# ============================================================================
print_header "Section 3: Project Configuration & Environment Variables"

print_check "Backend .env file existence"
if [ -f "backend/.env" ]; then
    print_success "Backend .env file found"
    
    # Check essential environment variables
    print_check "Backend environment variables"
    local missing_vars=()
    
    if ! grep -q "^DATABASE_URL=" backend/.env || [ -z "$(grep "^DATABASE_URL=" backend/.env | cut -d'=' -f2-)" ]; then
        missing_vars+=("DATABASE_URL")
    fi
    
    if ! grep -q "^SECRET_KEY=" backend/.env || [ -z "$(grep "^SECRET_KEY=" backend/.env | cut -d'=' -f2-)" ]; then
        missing_vars+=("SECRET_KEY")
    fi
    
    if ! grep -q "^GOOGLE_API_KEY=" backend/.env || [ -z "$(grep "^GOOGLE_API_KEY=" backend/.env | cut -d'=' -f2-)" ]; then
        missing_vars+=("GOOGLE_API_KEY")
    fi
    
    if [ ${#missing_vars[@]} -eq 0 ]; then
        print_success "All essential backend environment variables are set"
    else
        print_fail "Missing or empty backend environment variables: ${missing_vars[*]}"
    fi
else
    print_fail "Backend .env file not found"
fi

print_check "Frontend .env.local file existence"
if [ -f "frontend/.env.local" ]; then
    print_success "Frontend .env.local file found"
    
    print_check "Frontend environment variables"
    if grep -q "^NEXT_PUBLIC_API_URL=" frontend/.env.local && [ -n "$(grep "^NEXT_PUBLIC_API_URL=" frontend/.env.local | cut -d'=' -f2-)" ]; then
        print_success "NEXT_PUBLIC_API_URL is set"
    else
        print_fail "NEXT_PUBLIC_API_URL is missing or empty in frontend/.env.local"
    fi
else
    print_fail "Frontend .env.local file not found"
fi

# ============================================================================
# SECTION 4: PROJECT DEPENDENCY HEALTH
# ============================================================================
print_header "Section 4: Project Dependency Health"

print_check "Backend Python dependencies"
if [ -d "backend" ]; then
    cd backend
    
    # Check if virtual environment exists and activate it
    if [ -d "venv" ]; then
        print_info "Activating virtual environment..."
        source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
        
        if command_exists pip; then
            local pip_check_output=$(pip check 2>&1)
            if [ $? -eq 0 ]; then
                print_success "Backend dependencies are consistent"
            else
                print_fail "Backend dependency issues found: $pip_check_output"
            fi
        else
            print_fail "pip not available in virtual environment"
        fi
        
        deactivate 2>/dev/null || true
    else
        print_fail "Backend virtual environment (venv) not found"
    fi
    
    cd ..
else
    print_fail "Backend directory not found"
fi

print_check "Frontend Node.js dependencies"
if [ -d "frontend" ]; then
    cd frontend
    
    if [ -f "package.json" ] && [ -d "node_modules" ]; then
        local npm_ls_output=$(npm ls --depth=0 2>&1)
        if echo "$npm_ls_output" | grep -q "UNMET DEPENDENCY\|missing\|invalid"; then
            print_fail "Frontend dependency issues detected"
            print_info "Run 'npm install' in frontend directory to fix"
        else
            print_success "Frontend dependencies appear healthy"
        fi
    else
        if [ ! -f "package.json" ]; then
            print_fail "Frontend package.json not found"
        else
            print_fail "Frontend node_modules not found - run 'npm install'"
        fi
    fi
    
    cd ..
else
    print_fail "Frontend directory not found"
fi

# ============================================================================
# SECTION 5: NETWORK & SERVICE CONNECTIVITY
# ============================================================================
print_header "Section 5: Network & Service Connectivity"

print_check "General internet connectivity"
if curl -s --connect-timeout 10 https://www.google.com >/dev/null 2>&1; then
    print_success "Internet connectivity confirmed"
else
    print_fail "No internet connectivity or Google is unreachable"
fi

print_check "GitHub connectivity (port 443)"
if command_exists nc; then
    if nc -z -w5 github.com 443 2>/dev/null; then
        print_success "GitHub (port 443) is reachable"
    else
        print_fail "Cannot connect to GitHub on port 443"
    fi
elif command_exists telnet; then
    if timeout 5 telnet github.com 443 </dev/null >/dev/null 2>&1; then
        print_success "GitHub (port 443) is reachable"
    else
        print_fail "Cannot connect to GitHub on port 443"
    fi
else
    print_info "Neither nc nor telnet available - skipping GitHub connectivity test"
fi

print_check "Google Gemini API connectivity"
# Extract API key from backend/.env if it exists
if [ -f "backend/.env" ]; then
    local api_key=$(grep "^GOOGLE_API_KEY=" backend/.env | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    if [ -n "$api_key" ]; then
        print_info "Testing Gemini API with configured key..."
        local api_response=$(curl -s -w "%{http_code}" -o /dev/null \
            -H "Content-Type: application/json" \
            -d '{"contents":[{"parts":[{"text":"Hello"}]}]}' \
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$api_key")
        
        if [ "$api_response" = "200" ]; then
            print_success "Gemini API is accessible and API key is valid"
        else
            print_fail "Gemini API test failed (HTTP $api_response) - check API key and network"
        fi
    else
        print_fail "GOOGLE_API_KEY is empty - cannot test Gemini API"
    fi
else
    print_fail "Cannot test Gemini API - backend/.env not found"
fi

print_check "Docker container status"
if command_exists docker && docker info >/dev/null 2>&1; then
    local running_containers=$(docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null)
    if [ -n "$running_containers" ]; then
        print_success "Docker containers are running:"
        echo "$running_containers" | while read line; do
            print_info "  $line"
        done
    else
        print_info "No Docker containers currently running"
        print_success "Docker is available (no containers required to be running)"
    fi
else
    print_fail "Cannot check Docker containers - Docker not available"
fi# ==
==========================================================================
# SECTION 6: APPLICATION SANITY CHECK
# ============================================================================
print_header "Section 6: Application Sanity Check"

print_check "Backend code linting"
if [ -d "backend" ]; then
    cd backend
    
    # Check if ruff is available
    if command_exists ruff; then
        local ruff_output=$(ruff check . 2>&1)
        if [ $? -eq 0 ]; then
            print_success "Backend code passes linting checks"
        else
            print_fail "Backend linting issues found"
            print_info "Run 'ruff check .' in backend directory for details"
        fi
    elif [ -f "venv/bin/ruff" ] || [ -f "venv/Scripts/ruff.exe" ]; then
        source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
        local ruff_output=$(ruff check . 2>&1)
        if [ $? -eq 0 ]; then
            print_success "Backend code passes linting checks"
        else
            print_fail "Backend linting issues found"
        fi
        deactivate 2>/dev/null || true
    else
        print_info "Ruff linter not found - skipping backend linting check"
        print_success "Backend linting check skipped (optional)"
    fi
    
    cd ..
else
    print_fail "Backend directory not found for linting check"
fi

print_check "Frontend code linting"
if [ -d "frontend" ]; then
    cd frontend
    
    if [ -f "package.json" ]; then
        # Check if lint script exists in package.json
        if grep -q '"lint"' package.json; then
            if [ -d "node_modules" ]; then
                local lint_output=$(npm run lint 2>&1)
                if [ $? -eq 0 ]; then
                    print_success "Frontend code passes linting checks"
                else
                    print_fail "Frontend linting issues found"
                    print_info "Run 'npm run lint' in frontend directory for details"
                fi
            else
                print_fail "Frontend node_modules not found - cannot run linting"
            fi
        else
            print_info "No lint script found in frontend package.json"
            print_success "Frontend linting check skipped (not configured)"
        fi
    else
        print_fail "Frontend package.json not found"
    fi
    
    cd ..
else
    print_fail "Frontend directory not found for linting check"
fi

# ============================================================================
# FINAL SUMMARY REPORT
# ============================================================================
print_header "Verification Summary Report"

echo -e "\n${BLUE}📊 SUMMARY STATISTICS:${NC}"
echo -e "   Total checks performed: $TOTAL_CHECKS"
echo -e "   Checks passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "   Checks failed: ${RED}$((TOTAL_CHECKS - PASSED_CHECKS))${NC}"

if [ ${#FAILED_CHECKS[@]} -gt 0 ]; then
    echo -e "\n${RED}❌ FAILED CHECKS:${NC}"
    for failed_check in "${FAILED_CHECKS[@]}"; do
        echo -e "   • $failed_check"
    done
fi

echo -e "\n${BLUE}🔧 QUICK FIXES:${NC}"
echo -e "   • Missing .env files: Copy from .env.example templates"
echo -e "   • Missing dependencies: Run setup.bat or follow DEVELOPMENT_GUIDE.md"
echo -e "   • Docker issues: Ensure Docker Desktop is running"
echo -e "   • Network issues: Check firewall and proxy settings"

# Final verdict
echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    echo -e "${BLUE}║${NC} ${GREEN}✅ CODESPACE VERIFICATION COMPLETE: ALL CHECKS PASSED${NC}     ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}    Your development environment is ready to use!           ${BLUE}║${NC}"
    exit_code=0
else
    echo -e "${BLUE}║${NC} ${RED}❌ CODESPACE VERIFICATION FAILED: ISSUES DETECTED${NC}        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}    Please review and fix the errors listed above.          ${BLUE}║${NC}"
    exit_code=1
fi
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}💡 TIP: Run this script anytime to verify your environment${NC}"
echo -e "${YELLOW}   For detailed setup instructions, see: DEVELOPMENT_GUIDE.md${NC}"

exit $exit_code