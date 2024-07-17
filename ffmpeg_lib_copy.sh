#!/bin/bash

# Create directory if it doesn't exist
mkdir -p ~/ffmpeg_lib/libs

# Extract library paths from ldd output
ffmpeg_path=$(which ffmpeg)
ffprobe_path=$(which ffprobe)
ffplay_path=$(which ffplay)
libraries=$(ldd $ffmpeg_path $ffprobe_path $ffplay_path| grep -o '/.*/lib[^ ]*')

# Copy libraries to ~/ffmpeg_lib/libs
for lib in $libraries; do
    cp "$lib" ~/ffmpeg_lib/libs/
done

# Copy ffmpeg and ffprobe binaries
cp $ffmpeg_path ~/ffmpeg_lib/
cp $ffprobe_path ~/ffmpeg_lib/
cp $ffplay_path ~/ffmpeg_lib/
# Optionally, you can also copy any other necessary files (e.g., configuration files, presets)
# cp <source> <destination>

echo "FFmpeg, ffprobe, ffplay and their dependencies copied to ~/ffmpeg_lib successfully."
