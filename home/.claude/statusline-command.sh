#!/bin/bash
# Status line generated from ~/.bashrc PS1: '[\u@\h \W]\$ '
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

user=$(whoami)
host=$(hostname -s)
dir=$(basename "$cwd")

printf "[%s@%s %s]" "$user" "$host" "$dir"
