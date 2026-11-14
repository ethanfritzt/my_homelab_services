#!/bin/bash
# publish-stream.sh - Stream Pi camera to MediaMTX server
# This script captures video using libcamera and streams it via RTSP

# Configuration - These values are set via environment variables by the systemd service
# SERVER_IP and STREAM_NAME should be set in the systemd service file
# They are configured during setup by init-camera-node.sh

# Get current username
CURRENT_USER=$(whoami)

# Video settings
WIDTH=640
HEIGHT=480
FRAMERATE=15

# These should be set in env
STREAM_NAME=camtwo
SERVER_IP=mediamtx.fritz3.org
PORT=5001

# Log startup
echo "Starting camera stream..."
echo "User: $CURRENT_USER"
echo "Server: $SERVER_IP"
echo "Stream: $STREAM_NAME"
echo "Resolution: ${WIDTH}x${HEIGHT} @ ${FRAMERATE}fps"

# Validate required environment variables
if [ -z "$SERVER_IP" ]; then
    echo "Error: SERVER_IP environment variable is not set"
    exit 1
fi

if [ -z "$STREAM_NAME" ]; then
    echo "Error: STREAM_NAME environment variable is not set"
    exit 1
fi

# Stream through the UDP protocol so MediaMTX can read it
rpicam-vid -t 0 --codec libav --libav-format mpegts --inline --width $WIDTH --height $HEIGHT --framerate $FRAMERATE -o udp://$SERVER_IP:$PORT?pkt_size=1316
