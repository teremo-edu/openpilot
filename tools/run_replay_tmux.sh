#!/usr/bin/env bash
#
# Tmux script to run replay with UI and watch3 tools.
# Usage: ./tools/run_replay_tmux.sh [route]
#   route: optional route name (default: --demo)
#
# Example with demo route:
#   ./tools/run_replay_tmux.sh
#
# Example with specific route:
#   ./tools/run_replay_tmux.sh 'a2a0ccea32023010|2023-07-27--13-01-19'
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENPILOT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$OPENPILOT_ROOT"

ROUTE="${1:---demo}"

# Kill existing session if any
tmux kill-session -t openpilot-replay 2>/dev/null || true

# Create new session with replay in first pane
tmux new-session -d -s openpilot-replay -n replay -c "$OPENPILOT_ROOT"
tmux send-keys -t openpilot-replay "source .venv/bin/activate 2>/dev/null || true" C-m
tmux send-keys -t openpilot-replay "tools/replay/replay $ROUTE --all --dcam --ecam" C-m

# Split right for ui.py
tmux split-window -h -t openpilot-replay -c "$OPENPILOT_ROOT"
tmux send-keys -t openpilot-replay.1 "source .venv/bin/activate 2>/dev/null || true" C-m
tmux send-keys -t openpilot-replay.1 "sleep 2 && python selfdrive/ui/ui.py" C-m

# Split bottom for watch3.py (all 3 cameras)
tmux split-window -v -t openpilot-replay.1 -c "$OPENPILOT_ROOT"
tmux send-keys -t openpilot-replay.2 "source .venv/bin/activate 2>/dev/null || true" C-m
tmux send-keys -t openpilot-replay.2 "sleep 3 && python selfdrive/ui/watch3.py" C-m

# Balance panes and attach
tmux select-layout -t openpilot-replay tiled
tmux attach -t openpilot-replay
