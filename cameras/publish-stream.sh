#!/bin/bash
# publish-stream.sh - Stream Pi camera to MediaMTX server
# Captures with libcamera/rpicam-vid and pushes UDP MPEG-TS; MediaMTX serves it as RTSP

# Configuration - These values are set via environment variables by the systemd service
# SERVER_IP, STREAM_NAME, and PORT should be set in the systemd service / drop-in

# Get current username
CURRENT_USER=$(whoami)

# Video settings
WIDTH=640
HEIGHT=480
FRAMERATE=15
STREAM_NAME="${STREAM_NAME:?set STREAM_NAME}"
PORT="${PORT:?set PORT}"
SERVER_IP="${SERVER_IP:-mediamtx.fritz3.org}"

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

# Push H.264 as UDP MPEG-TS to MediaMTX (no auth); MediaMTX serves it as RTSP
rpicam-vid -t 0 --codec libav --libav-format mpegts --inline --width $WIDTH --height $HEIGHT --framerate $FRAMERATE -o udp://$SERVER_IP:$PORT?pkt_size=1316
