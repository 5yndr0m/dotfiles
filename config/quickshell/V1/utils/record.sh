#!/bin/bash

SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"

# Check if gpu-screen-recorder is already running
if pgrep -f "gpu-screen-recorder" > /dev/null; then
    # Stop recording gracefully
    pkill -INT -x "gpu-screen-recorder"
    notify-send "Recorder" "Recording saved to $SAVE_DIR" -i video-display
    exit 0
fi

# Start recording
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
FILENAME="$SAVE_DIR/recording_$TIMESTAMP.mp4"

notify-send "Recorder" "Recording started..." -i video-record

# Execute the recorder
# -w screen: Whole screen
# -f 60: 60 FPS
# -a: Default audio
exec gpu-screen-recorder -w screen -f 60 -a default_output -o "$FILENAME"
