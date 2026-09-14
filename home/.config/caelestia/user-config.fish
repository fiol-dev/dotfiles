if status is-interactive
    set -gx GPG_TTY (tty)
    gpg-connect-agent updatestartuptty /bye >/dev/null
end

/home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source

