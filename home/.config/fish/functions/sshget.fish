function sshget -d "Download a remote file/dir to here via rsync"
    argparse 'd/delete' 'n/dry-run' -- $argv
    or return 1

    if test (count $argv) -lt 1
        echo "Usage: sshget [-d|--delete] [-n|--dry-run] HOST:REMOTE_PATH [LOCAL_PATH]"
        echo "       sshget [-d|--delete] [-n|--dry-run] HOST REMOTE_PATH [LOCAL_PATH]"
        echo "Example: sshget me@server:/var/log/app.log ./logs/"
        return 1
    end

    set -l src
    set -l local_path .

    if string match -qr ':' -- $argv[1]
        # host:path form
        set src $argv[1]
        test (count $argv) -ge 2; and set local_path $argv[2]
    else
        # host path form
        if test (count $argv) -lt 2
            set_color red
            echo "sshget: REMOTE_PATH is required when HOST doesn't contain ':'"
            set_color normal
            return 1
        end
        set src "$argv[1]:$argv[2]"
        test (count $argv) -ge 3; and set local_path $argv[3]
    end

    set -l opts -avz --progress -e ssh
    set -q _flag_delete; and set -a opts --delete
    set -q _flag_dry_run; and set -a opts --dry-run

    set_color yellow
    echo "→ $src  ⇒  $local_path"
    set_color normal
    rsync $opts $src $local_path
end
