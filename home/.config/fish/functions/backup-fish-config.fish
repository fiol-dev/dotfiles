#!/usr/bin/env fish
# Backup fish configuration to external device or network

function backup-fish-config -d "Backup fish shell configuration"
    set -l backup_dir $argv[1]
    
    if test -z "$backup_dir"
        set backup_dir "~/fish-backup-$(date +%Y%m%d-%H%M%S)"
    end
    
    set -l backup_dir (eval echo $backup_dir)
    
    echo "Backing up fish configuration to: $backup_dir"
    
    mkdir -p $backup_dir
    cp -r ~/.config/fish $backup_dir/
    cp ~/.bashrc $backup_dir/ 2>/dev/null
    cp ~/.zshrc $backup_dir/ 2>/dev/null
    
    echo "✓ Backup complete: $backup_dir"
    ls -lah $backup_dir
end