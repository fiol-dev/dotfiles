set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

set -gx SSH_ASKPASS /usr/lib/ssh/ssh-askpass
set -gx SSH_ASKPASS_REQUIRE force
