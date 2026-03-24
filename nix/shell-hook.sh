# RESET=1 triggers a full credential wipe
if [[ "${RESET:-0}" == "1" ]]; then
    if command -v ghcli-reset >/dev/null 2>&1; then
        ghcli-reset --all --yes
    else
        echo "Error: ghcli-reset not found on PATH" >&2
    fi
    return 0
fi

export GH_NEEDS_SETUP=0

_ghcli_config="${XDG_CONFIG_HOME:-$HOME/.config}/gh/nix/github_config"
_ghcli_helper="${XDG_CONFIG_HOME:-$HOME/.config}/gh/nix/gh-token-helper"

# Use the SSH key path from config for git operations (avoids needing ~/.ssh/config to match)
_ssh_key="$(awk -F= '$1 == "SSH_KEY_PATH" {print $2}' "$_ghcli_config" 2>/dev/null)"
if [[ -n "$_ssh_key" && -f "$_ssh_key" ]]; then
    export GIT_SSH_COMMAND="ssh -i '${_ssh_key}'"
fi
unset _ssh_key
_ghcli_token=""
if [[ -x "$_ghcli_helper" ]]; then
    _ghcli_token="$("$_ghcli_helper" 2>/dev/null || true)"
fi
if [[ -n "$_ghcli_token" ]]; then
    export GH_TOKEN="$_ghcli_token"
    export GITHUB_TOKEN="$_ghcli_token"
else
    if ! command gh auth status >/dev/null 2>&1; then
        export GH_NEEDS_SETUP=1
    fi
fi
unset _ghcli_config _ghcli_helper _ghcli_token
