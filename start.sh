#!/bin/bash
# Startup script for RunPod Serverless
# This script starts Forge API in the background, then runs the serverless handler

set -e

echo "=== LayerDiffuse Alpha API - RunPod Serverless ==="
echo "Starting Forge API server..."

# Activate virtual environment if it exists
if [ -d "/workspace/stable-diffusion-webui/venv" ]; then
    source /workspace/stable-diffusion-webui/venv/bin/activate
fi

# Start Forge API in background
cd /workspace/stable-diffusion-webui
python launch.py --nowebui --api --listen --port 7861 &

# Give it a moment to start initializing
sleep 5

echo "Forge API starting in background..."
echo "Starting RunPod Serverless handler..."

# Run the serverless handler (it will wait for Forge API to be ready)
python /workspace/stable-diffusion-webui/rp_handler.py
