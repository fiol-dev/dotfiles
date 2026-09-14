function sshumount -d "Unmount a directory mounted with sshmount"
    if test (count $argv) -lt 1
        echo "Usage: sshumount LOCAL_MOUNTPOINT"
        return 1
    end

    set -l mountpoint $argv[1]

    if command -v fusermount3 &>/dev/null
        fusermount3 -u $mountpoint
    else if command -v fusermount &>/dev/null
        fusermount -u $mountpoint
    else
        umount $mountpoint
    end
    and begin
        set_color green
        echo "✓ unmounted $mountpoint"
        set_color normal
    end
end
