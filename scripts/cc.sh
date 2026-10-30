#!/bin/bash
# cc - Universal Claude Code Launcher (macOS/Linux)
# Cross-platform launcher with proxy support and API fallback
#
# Usage: cc [args]   (extra args pass through to claude)

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
  CONFIG_DIR="$HOME/Library/Application Support/claude-launcher"
else
  CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/claude-launcher"
fi

CONFIG_FILE="$CONFIG_DIR/config.json"
STATE_FILE="$CONFIG_DIR/subscription-state.json"
STATE_TTL=300

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# ============================================================================
# Helper Functions
# ============================================================================

print_status() {
  echo -e "\033[36m==> $1\033[0m"
}

print_success() {
  echo -e "\033[32m==> $1\033[0m"
}

print_warn() {
  echo -e "\033[33m==> $1\033[0m"
}

print_error() {
  echo -e "\033[31m==> ERROR: $1\033[0m" >&2
}

# Load configuration
load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    cat "$CONFIG_FILE"
  else
    # Default configuration
    cat <<EOF
{
  "apiProvider": "anthropic",
  "customApiBase": "",
  "apiKey": "",
  "proxy": {
    "enabled": false,
    "url": "http://127.0.0.1:7890"
  },
  "defaults": {
    "model": "claude-opus-5-5",
    "effort": "medium"
  },
  "subscriptionCache": {
    "enabled": true,
    "ttl": 300
  }
}
EOF
  fi
}

# Get config value using jq
get_config() {
  local key="$1"
  local default="${2:-}"
  local value
  value=$(echo "$CONFIG" | jq -r "$key // empty" 2>/dev/null || echo "")
  if [[ -z "$value" ]]; then
    echo "$default"
  else
    echo "$value"
  fi
}

# Read subscription state
read_subscription_state() {
  local enabled
  enabled=$(get_config '.subscriptionCache.enabled' 'true')

  if [[ "$enabled" != "true" || ! -f "$STATE_FILE" ]]; then
    echo ""
    return
  fi

  local checked_at status age now checked_epoch
  checked_at=$(jq -r '.checkedAtUtc // empty' "$STATE_FILE" 2>/dev/null || echo "")
  status=$(jq -r '.status // empty' "$STATE_FILE" 2>/dev/null || echo "")

  if [[ -z "$checked_at" || -z "$status" ]]; then
    echo ""
    return
  fi

  now=$(date +%s)
  checked_epoch=$(date -d "$checked_at" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${checked_at%.*}" +%s 2>/dev/null || echo "0")
  age=$((now - checked_epoch))

  if [[ $age -ge 0 && $age -lt $STATE_TTL ]]; then
    echo "$status"
  else
    echo ""
  fi
}

# Write subscription state
write_subscription_state() {
  local status="$1"
  local enabled
  enabled=$(get_config '.subscriptionCache.enabled' 'true')

  if [[ "$enabled" != "true" ]]; then
    return
  fi

  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
  echo "{\"status\":\"$status\",\"checkedAtUtc\":\"$now\"}" > "$STATE_FILE"
}

# Test subscription availability
test_subscription_available() {
  local probe_out probe_model probe_effort
  probe_out=$(mktemp)
  probe_model=$(get_config '.defaults.model' 'claude-opus-5-5')
  probe_effort=$(get_config '.defaults.effort' 'medium')

  # Override from command line args
  for ((i=0; i<${#CLAUDE_ARGS[@]}; i++)); do
    if [[ "${CLAUDE_ARGS[i]}" == "--model" && $((i+1)) -lt ${#CLAUDE_ARGS[@]} ]]; then
      probe_model="${CLAUDE_ARGS[$((i+1))]}"
    elif [[ "${CLAUDE_ARGS[i]}" == "--effort" && $((i+1)) -lt ${#CLAUDE_ARGS[@]} ]]; then
      probe_effort="${CLAUDE_ARGS[$((i+1))]}"
    fi
  done

  claude --safe-mode --print --no-session-persistence \
    --model "$probe_model" --effort "$probe_effort" \
    "Reply with exactly OK" > "$probe_out" 2>&1

  local exit_code=$?
  rm -f "$probe_out"
  return $exit_code
}

# Test proxy connection
test_proxy_connection() {
  local proxy_url="$1"
  local host port

  # Extract host and port from URL
  host=$(echo "$proxy_url" | sed -E 's|^[a-z]+://||' | cut -d: -f1)
  port=$(echo "$proxy_url" | sed -E 's|^[a-z]+://||' | cut -d: -f2 | cut -d/ -f1)

  if command -v nc >/dev/null 2>&1; then
    nc -z -w2 "$host" "$port" 2>/dev/null
    return $?
  else
    # Fallback: try curl
    curl -s -x "$proxy_url" --max-time 2 https://www.google.com >/dev/null 2>&1
    return $?
  fi
}

# Get exit IP
get_exit_ip() {
  local proxy_url="$1"
  curl -s -x "$proxy_url" --max-time 5 https://checkip.amazonaws.com 2>/dev/null || echo ""
}

# Check if command is a management command
is_management_command() {
  local cmd="$1"
  case "$cmd" in
    attach|stop|login|logout|auth|update|mcp|plugin|doctor|help|version)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# ============================================================================
# Main
# ============================================================================

print_status "Claude Code Launcher"

# Load configuration
CONFIG=$(load_config)

# Override from environment variables
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  CONFIG=$(echo "$CONFIG" | jq --arg key "$ANTHROPIC_API_KEY" '.apiKey = $key')
fi
if [[ -n "${ANTHROPIC_BASE_URL:-}" ]]; then
  CONFIG=$(echo "$CONFIG" | jq --arg url "$ANTHROPIC_BASE_URL" '.customApiBase = $url')
fi
if [[ -n "${HTTPS_PROXY:-}" ]]; then
  CONFIG=$(echo "$CONFIG" | jq --arg url "$HTTPS_PROXY" '.proxy.enabled = true | .proxy.url = $url')
fi

# Parse arguments
CLAUDE_ARGS=("$@")
RUN_ARGS=()
PRINT_MODE=false
USE_FALLBACK=false
MANAGEMENT_COMMAND=false

# Check for management command
if [[ ${#CLAUDE_ARGS[@]} -gt 0 ]]; then
  if is_management_command "${CLAUDE_ARGS[0]}"; then
    MANAGEMENT_COMMAND=true
  fi
fi

# Check for --print / -p flag
for arg in "${CLAUDE_ARGS[@]}"; do
  if [[ "$arg" == "--print" || "$arg" == "-p" ]]; then
    PRINT_MODE=true
    break
  fi
done

# Build run args with defaults (unless management command)
if [[ "$MANAGEMENT_COMMAND" == "false" ]]; then
  # Check if --model is already provided
  has_model=false
  for ((i=0; i<${#CLAUDE_ARGS[@]}; i++)); do
    if [[ "${CLAUDE_ARGS[i]}" == "--model" || "${CLAUDE_ARGS[i]}" == "-m" ]]; then
      has_model=true
      break
    fi
  done

  if [[ "$has_model" == "false" ]]; then
    default_model=$(get_config '.defaults.model' 'claude-opus-5-5')
    RUN_ARGS+=("--model" "$default_model")
  fi

  # Check if --effort is already provided
  has_effort=false
  for arg in "${CLAUDE_ARGS[@]}"; do
    if [[ "$arg" == "--effort" ]]; then
      has_effort=true
      break
    fi
  done

  if [[ "$has_effort" == "false" ]]; then
    default_effort=$(get_config '.defaults.effort' 'medium')
    RUN_ARGS+=("--effort" "$default_effort")
  fi
fi

RUN_ARGS+=("${CLAUDE_ARGS[@]}")

# Configure proxy if enabled
proxy_enabled=$(get_config '.proxy.enabled' 'false')
if [[ "$proxy_enabled" == "true" ]]; then
  proxy_url=$(get_config '.proxy.url' 'http://127.0.0.1:7890')
  print_status "Proxy: $proxy_url"

  if test_proxy_connection "$proxy_url"; then
    export HTTPS_PROXY="$proxy_url"
    export HTTP_PROXY="$proxy_url"
    export NO_PROXY="localhost,127.0.0.1,::1"

    exit_ip=$(get_exit_ip "$proxy_url")
    if [[ -n "$exit_ip" ]]; then
      print_success "Exit IP = $exit_ip"
    else
      print_warn "Proxy configured but exit IP check failed"
    fi
  else
    print_warn "Proxy not reachable: $proxy_url"
  fi
fi

# Check subscription availability (if using official API)
api_provider=$(get_config '.apiProvider' 'anthropic')
if [[ "$api_provider" == "anthropic" && "$PRINT_MODE" == "false" ]]; then
  state=$(read_subscription_state)
  if [[ "$state" == "unavailable" ]]; then
    USE_FALLBACK=true
  elif [[ -z "$state" ]]; then
    print_status "Checking subscription availability..."
    if test_subscription_available; then
      write_subscription_state "available"
    else
      write_subscription_state "unavailable"
      USE_FALLBACK=true
    fi
  fi
fi

# Launch Claude Code
print_status "Launching Claude Code..."

if [[ "$USE_FALLBACK" == "true" || "$api_provider" != "anthropic" ]]; then
  # Use custom API gateway
  api_key=$(get_config '.apiKey' '')
  custom_base=$(get_config '.customApiBase' '')

  if [[ -z "$api_key" ]]; then
    print_error "API key not configured. Please edit: $CONFIG_FILE"
    exit 1
  fi

  if [[ -z "$custom_base" ]]; then
    print_error "Custom API base URL not configured. Please edit: $CONFIG_FILE"
    exit 1
  fi

  print_warn "Using custom API gateway: $custom_base"
  export ANTHROPIC_BASE_URL="$custom_base"
  export ANTHROPIC_AUTH_TOKEN="$api_key"
  unset ANTHROPIC_API_KEY
fi

claude "${RUN_ARGS[@]}"
EXIT_CODE=$?

exit $EXIT_CODE
