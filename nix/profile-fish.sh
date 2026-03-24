if test "$GH_NEEDS_SETUP" = "1"
    echo ""
    echo "Warning: GitHub CLI is not authenticated."
    echo "   Run 'ghcli-setup' to set up authentication."
    echo ""
end

function gh
    if test -n "$XDG_CONFIG_HOME"
        set -l config_base "$XDG_CONFIG_HOME"
    else
        set -l config_base "$HOME/.config"
    end
    set -l helper "$config_base/gh/nix/gh-token-helper"
    set -l token ("$helper" 2>/dev/null; or true)
    if test -n "$token"
        env GH_TOKEN="$token" GITHUB_TOKEN="$token" command gh $argv
    else
        command gh $argv
    end
end
