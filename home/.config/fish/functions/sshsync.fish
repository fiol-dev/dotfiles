function sshsync -d "Two-way-ish rsync between a local dir and a remote dir"
    argparse 'n/dry-run' -- $argv
    or return 1

    if test (count $argv) -lt 2
        echo "Usage: sshsync [-n|--dry-run] LOCAL_DIR HOST:REMOTE_DIR"
        echo "Pulls remote changes first, then pushes local changes. No --delete,"
        echo "so nothing is ever removed on either side automatically."
        return 1
    end

    set -l local_dir (string trim -r -c / -- $argv[1])/
    set -l remote_dir (string trim -r -c / -- $argv[2])/
    set -l opts -avzu --progress -e ssh
    set -q _flag_dry_run; and set -a opts --dry-run

    mkdir -p $local_dir

    set_color yellow; echo "== pull: $remote_dir -> $local_dir =="; set_color normal
    rsync $opts $remote_dir $local_dir

    set_color yellow; echo "== push: $local_dir -> $remote_dir =="; set_color normal
    rsync $opts $local_dir $remote_dir
end
