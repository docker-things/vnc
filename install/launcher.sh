#!/bin/bash

# # Remove VNC lock (if process already killed)
# rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# Add startup config
if [ ! -f ~/.vnc/xstartup ]; then
    mkdir -p ~/.vnc
    cp /scripts/user/xstartup ~/.vnc/
fi

# Add password
if [ ! -f ~/.vnc/passwd ]; then
    mkdir -p ~/.vnc
    cp /scripts/user/passwd ~/.vnc/
fi

# Cleanup logs & pids
if [ -d ~/.vnc ]; then
    rm -f \
        ~/.vnc/*.log \
        ~/.vnc/*.pid
fi

# Run VNC server with tail in the foreground
vncserver :1 -geometry $VNC_GEOMETRY -depth $VNC_DEPTH && tail -F ~/.vnc/*.log
