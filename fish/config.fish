gpgconf --launch gpg-agent
set -e SSH_AUTH_SOCK
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
set -gx GPG_TTY (tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
if status is-interactive
    # Commands to run in interactive sessions can go here
end
