#!/usr/bin/env bash
# Smart new tab: Creates a Kitty tab locally, or a tmux window when in SSH

# Get current window info as JSON
window_info=$(kitty @ ls --match state:self 2>/dev/null)

# Check if we're in an SSH session by examining:
# 1. SSH_CONNECTION environment variable
# 2. Foreground process cmdline containing 'ssh'
is_ssh=false

# Check environment for SSH_CONNECTION
if echo "$window_info" | grep -q '"SSH_CONNECTION"'; then
    is_ssh=true
fi

# Check if foreground process is ssh
if echo "$window_info" | grep -q '"cmdline".*"ssh'; then
    is_ssh=true
fi

if [ "$is_ssh" = true ]; then
    # Send tmux new window command (Ctrl+B, C)
    kitty @ send-text --match state:self '\x02c'
else
    # Create new Kitty tab in ~/Code
    kitty @ launch --type=tab --cwd="$HOME/Code"
fi
