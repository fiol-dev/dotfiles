function sshput -d "Upload a local file/dir to a remote host via rsync"
    argparse 'd/delete' 'n/dry-run' -- $argv
    or return 1

    if test (count $argv) -lt 2
        echo "Usage: sshput [-d|--delete] [-n|--dry-run] LOCAL_PATH HOST:REMOTE_PATH"
        echo "       sshput [-d|--delete] [-n|--dry-run] LOCAL_PATH HOST REMOTE_PATH"
        echo "Example: sshput ./build me@server:/var/www/app"
        return 1
    end

    set -l local_path $argv[1]
    set -l dest

    if test (count $argv) -ge 3
        set dest "$argv[2]:$argv[3]"
    else
        set dest $argv[2]
    end

    if not test -e $local_path
        set_color red
        echo "sshput: no such file: $local_path"
        set_color normal
        return 1
    end

    set -l opts -avz --progress -e ssh
    set -q _flag_delete; and set -a opts --delete
    set -q _flag_dry_run; and set -a opts --dry-run

    set_color yellow
    echo "→ $local_path  ⇒  $dest"
    set_color normal
    rsync $opts $local_path $dest
end
