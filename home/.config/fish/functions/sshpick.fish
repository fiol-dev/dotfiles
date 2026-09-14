function sshpick -d "fzf-pick a remote file under a path and download it here"
    if not command -v fzf &>/dev/null
        set_color red
        echo "sshpick: fzf is not installed (sudo pacman -S fzf)"
        set_color normal
        return 1
    end

    if test (count $argv) -lt 1
        echo "Usage: sshpick HOST [REMOTE_START_DIR]"
        echo "Example: sshpick me@server /var/log"
        return 1
    end

    set -l host $argv[1]
    set -l start_dir (test (count $argv) -ge 2; and echo $argv[2]; or echo .)

    set -l picked (ssh $host "find $start_dir -maxdepth 6 -type f 2>/dev/null" | fzf --prompt="$host > ")
    if test -z "$picked"
        return 1
    end

    sshget "$host:$picked" .
end
