set fish_greeting ""

if status is-interactive
    # Run nitch only once per terminal window (not per tab/pane)
    if not set -q NITCH_SHOWN
        clear
        nitch
        set -g NITCH_SHOWN true    # ← changed from -Ux to -g
    end

    starship init fish | source
    atuin init fish | source

    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end

# Use systemd's user ssh-agent
set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# Add your key once per session if not already added
if not ssh-add -l > /dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519
end
export QT_QPA_PLATFORM=xcb
alias packettracer 'QT_QPA_PLATFORM=xcb /opt/pt/packettracer'
