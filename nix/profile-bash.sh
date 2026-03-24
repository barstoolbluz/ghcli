if [[ "$GH_NEEDS_SETUP" == "1" ]]; then
    echo ""
    echo "Warning: GitHub CLI is not authenticated."
    echo "   Run 'ghcli-setup' to set up authentication."
    echo ""
fi

gh() {
    local helper="${XDG_CONFIG_HOME:-$HOME/.config}/gh/nix/gh-token-helper"
    local token=''
    token="$("$helper" 2>/dev/null || true)"
    if [[ -n "$token" ]]; then
        GH_TOKEN="$token" GITHUB_TOKEN="$token" command gh "$@"
    else
        command gh "$@"
    fi
}
