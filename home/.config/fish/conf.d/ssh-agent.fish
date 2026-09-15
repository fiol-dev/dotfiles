set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

set -gx SSH_ASKPASS "$HOME/.local/bin/caelestia-ssh-askpass"
set -gx SSH_ASKPASS_REQUIRE force
