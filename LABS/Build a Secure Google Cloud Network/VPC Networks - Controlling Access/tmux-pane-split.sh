#!/bin/bash

export TMUX_S_NAME=GCP                  #Session name variable definition 
export SCRIPT=GSP213.sh

tmux new-session -d -s "$TMUX_S_NAME" \; split-window -h \; 
tmux send-keys -t "$TMUX_S_NAME:0.0" "sh $SCRIPT" Enter \;
tmux send-keys -t "$TMUX_S_NAME:0.1" "" Enter \; attach 

