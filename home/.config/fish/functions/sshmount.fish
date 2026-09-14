function sshmount -d "Mount a remote dir locally over SSH (sshfs)"
    if not command -v sshfs &>/dev/null
        set_color red
        echo "sshmount: sshfs is not installed (sudo pacman -S sshfs)"
        set_color normal
        return 1
    end

    if test (count $argv) -lt 2
        echo "Usage: sshmount HOST:REMOTE_DIR LOCAL_MOUNTPOINT"
        echo "Example: sshmount me@server:/srv/data ~/mnt/server-data"
        return 1
    end

    set -l remote $argv[1]
    set -l mountpoint $argv[2]

    mkdir -p $mountpoint

    if mount | grep -q " on "(realpath $mountpoint)" "
        set_color yellow
        echo "sshmount: $mountpoint is already mounted"
        set_color normal
        return 1
    end

    sshfs $remote $mountpoint -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,follow_symlinks
    and begin
        set_color green
        echo "✓ mounted $remote at $mountpoint"
        set_color normal
    end
end
