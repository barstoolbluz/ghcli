# ghcli

A Flox environment that provides a fully configured GitHub CLI (`gh`) and Git
setup with secure token management and SSH/HTTPS credential storage.

## Quick start

```bash
# Pull the environment
flox pull --copy barstoolbluz/ghcli

# Activate it
flox activate

# Run the setup wizard (first time only)
ghcli-setup
```

On activation, the environment automatically injects your stored GitHub token
into `GH_TOKEN` and `GITHUB_TOKEN` so that `gh`, `git`, and any scripts you run
all authenticate without extra configuration.

## What's included

### Packages

| Package | Purpose |
|---------|---------|
| `gh` | GitHub CLI |
| `git` | Git with all outputs |
| `ghcli-setup` | Interactive setup wizard for tokens, SSH keys, and Git credentials |
| `ghcli-reset` | Reset tool for clearing stored credentials and config |
| `openssh` | SSH client for Git SSH mode |
| `openssl` | Encryption for file-based token storage |
| `libsecret` | Keyring access (`secret-tool`) on Linux |
| `gum` | Styled terminal prompts |
| `bat`, `jq`, `curl` | Common dev utilities |
| `coreutils`, `gnused`, `gawk`, `gnugrep` | GNU core tools (cross-platform consistency) |

### Token management

`ghcli-setup` stores your GitHub personal access token using a
keyring-first strategy:

1. **Keyring** (preferred) -- macOS Keychain or Linux `secret-tool` (via D-Bus
   Secret Service)
2. **Encrypted file** (fallback) -- AES-256-CBC with a local key, for
   headless/CI machines without a keyring

Tokens are never stored in plaintext or in the environment manifest.

If the config file loses its storage keys (e.g., partial corruption), the token
helper and the Rust retrieval code probe both backends automatically so existing
tokens are not lost.

### Git authentication

The wizard offers three modes for `github.com`:

- **HTTPS** -- stores Git credentials (username + token) in the same
  keyring/file backend, configured as a Git credential helper
- **SSH** -- generates or selects an SSH keypair, optionally uploads the public
  key to GitHub, and configures routing (including `ssh.github.com:443` for
  firewalled networks)
- **Skip** -- leaves existing Git config untouched

### Shell integration

On activation, a `gh()` wrapper function is defined for bash, zsh, and fish.
It calls the token helper on each invocation so `gh` always uses the current
token. The hook also exports `GH_TOKEN`/`GITHUB_TOKEN` as environment variables
so scripts and subprocesses inherit authentication automatically.

## ghcli-setup reference

### Interactive use

```bash
ghcli-setup                  # Full interactive wizard
ghcli-setup --replace-token  # Replace an existing valid token
```

### Non-interactive / CI use

```bash
ghcli-setup --non-interactive --token ghp_xxx --git-mode ssh
ghcli-setup --non-interactive --replace-token --token ghp_newtoken
```

### Flags

| Flag | Env var | Description |
|------|---------|-------------|
| `--token` | `FLOX_GITHUB_TOKEN` | GitHub personal access token |
| `--replace-token` | `FLOX_REPLACE_TOKEN` | Discard existing token, prompt for new |
| `--non-interactive` | | Disable prompts; missing inputs become errors |
| `--yes` | | Accept default-yes prompts automatically |
| `--git-mode` | `FLOX_GIT_MODE` | `https`, `ssh`, or `skip` |
| `--git-username` | `FLOX_GIT_USERNAME` | GitHub username for HTTPS |
| `--git-password` | `FLOX_GIT_PASSWORD` | Token for HTTPS Git (defaults to `--token`) |
| `--ssh-key-path` | `FLOX_SSH_KEY_PATH` | SSH private key path |
| `--ssh-key-title` | `FLOX_SSH_KEY_TITLE` | Title for SSH key upload |
| `--git-user-name` | `FLOX_GIT_USER_NAME` | Set `git config --global user.name` |
| `--git-user-email` | `FLOX_GIT_USER_EMAIL` | Set `git config --global user.email` |
| `--file-fallback` | `FLOX_FILE_FALLBACK_POLICY` | `never`, `prompt`, or `always` |
| `--rewrite-remotes` | | Rewrite GitHub remotes after setup |
| `--repo` | | Repo path to rewrite (repeatable) |

## ghcli-reset reference

### Interactive use

```bash
ghcli-reset                  # Multi-select menu: choose what to reset
```

### Targeted flags

```bash
ghcli-reset --token          # Reset GitHub CLI token only
ghcli-reset --git            # Reset Git HTTPS credentials only
ghcli-reset --ssh            # Reset managed SSH configuration only
ghcli-reset --all            # Full reset: everything
ghcli-reset --all --yes      # Full reset, no confirmation prompt
```

### Environment trigger

```bash
RESET=1 flox activate        # Triggers ghcli-reset --all --yes on activation
```

### What each mode clears

| Mode | Clears |
|------|--------|
| `--token` | Keyring entry (`flox-github`), encrypted token file, config keys (`TOKEN_STORAGE`, `GITHUB_TOKEN_STORED`) |
| `--git` | Keyring entry (`flox-github-git`), encrypted credentials file, `credential.https://github.com.helper` from git global config, gh `git_protocol` |
| `--ssh` | Managed block in `~/.ssh/config`, config keys (`SSH_KEY_PATH`, `SSH_ROUTE`). SSH key files are **never** deleted. |
| `--all` | All of the above + generated scripts (token helper, git helper, shell wrappers) + config file + Flox environment cache (with prompt) |

### Flags

| Flag | Description |
|------|-------------|
| `--token` | Reset the stored GitHub CLI token |
| `--git` | Reset Git HTTPS credentials and config |
| `--ssh` | Reset managed SSH configuration |
| `--all` | Full reset: token + git + ssh + generated scripts + config |
| `--non-interactive` | Disable prompts; require explicit flags |
| `--yes` | Auto-confirm destructive prompts |

## Configuration files

All config is stored under `~/.config/gh/nix/`:

| File | Purpose |
|------|---------|
| `github_config` | Key-value config (TOKEN_STORAGE, GIT_MODE, SSH_KEY_PATH, etc.) |
| `gh-token-helper` | Script that retrieves the token for `gh` |
| `git-credential-flox-helper` | Git credential helper for HTTPS mode |
| `github_token.enc` | Encrypted token (file-fallback mode only) |
| `git_credentials.enc` | Encrypted Git credentials (file-fallback mode only) |
| `.local_key` | Encryption key for file-fallback mode |
| `gh_wrapper.{bash,zsh,fish}` | Shell wrapper sources |

## Man pages

Both tools include man pages:

```bash
man ghcli-setup
man ghcli-reset
```

## Platforms

Linux (x86_64, aarch64) and macOS (Apple Silicon).

## License

MIT
