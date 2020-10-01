#!/bin/bash






#paara ejecutar el TeamViewerQS
LC_ALL=C ./teamviewer

#para liberar el terminal de la ejecucion del TeamViewerQS
ZOOM_PATH="/opt/zoom/ZoomLauncher"
ZOOM_LOGS="$HOME/.zoom/logs"

mkdir -p $ZOOM_LOGS

nohup "$ZOOM_PATH" "$@" >> "$ZOOM_LOGS/zoom-terminal.log" 2>&1 &
