#!/bin/bash

export TMUX_S_NAME=GCP                  #Session name variable definition 
export SCRIPT="/home/diemich/PCSE6/LABS/Build a Secure Google Cloud Network/Create an Internal Load Balancer/GSP216.sh"

tmux new-session -d -s "$TMUX_S_NAME" \; split-window -h \; 
tmux send-keys -t "$TMUX_S_NAME:0.0" "source $SCRIPT" Enter \;attach
#tmux send-keys -t "$TMUX_S_NAME:0.1" "" Enter \; attach 

