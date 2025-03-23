# 🔐 A Flox Environment for GitHub CLI & Git Auth Using a Local Keyring

This Flox environment secures your GitHub authentication by storing GitHub Personal Access Tokens (PATs) locally using standard methods, providing seamless auth for both GitHub CLI (`gh`) and Git operations. You get two storage options:

1. **System keyring/keychain** (preferred) - Uses OS security infrastructure
2. **Encrypted local file** (fallback) - Encrypts your token with a system-derived key

## ✨ Features

- Locks down GitHub tokens in your system keyring or encrypted files
- Handles GitHub CLI auth automatically without manual token entry
- Configures Git credential helper to use the same token for Git operations
- Works across platforms (macOS, Linux)
- Hooks into Bash, Zsh, and Fish shells
- Includes a no-nonsense setup wizard that doesn't waste your time

## 🧰 Included Tools

The environment packs these essential tools:

- `gh` - GitHub CLI for fast API interactions
- `gitFull` - Version control that doesn't get in your way
- `gum` - Terminal UI toolkit powering the setup wizard
- `bat` - Better `cat` with syntax highlighting
- `curl` - Solid HTTP client for API testing
- `openssl` - Cryptography toolkit backing the security layer

## 🏁 Getting Started

### 📋 Prerequisites

- GitHub account
- GitHub Personal Access Token with proper scopes
- [Flox](https://flox.dev) installed on your system

### 💻 Installation & Activation

Jump in with:

1. Clone this repo

```sh
git clone https://github.com/barstoolbluz/ghcli && cd ghcli
```

2. Run:

```sh
flox activate
```

This command:
- Pulls in all dependencies
- Fires up the auth setup wizard
- Drops you into the Flox env with GitHub CLI and Git auth ready to go

### 🧙 Setup Wizard

First-time activation triggers a wizard that:

1. Walks you through token creation if needed
2. Locks your token in the system keyring or encrypted file
3. Sets up shell wrapper functions if required. If using a keyring, `gh` is unwrapped; if using encrypted local storage, `gh` is wrapped.
4. Detects if Git credential helper is configured and offers to set it up with your GitHub token

## 📝 Usage

After setup, you can directly run GitHub CLI commands and Git operations:

```bash
# GitHub CLI commands
gh repo list
gh repo create
gh pr list

# Git operations (no password prompts)
git clone https://github.com/username/repo.git
git push origin main
```

Auth happens automatically via your configured mechanism for both GitHub CLI and Git.

## 🔍 How It Works

### 🛡️ Security Approach

We implement a two-tiered storage strategy:

1. **Primary Storage**: System keyring/keychain
   - Uses OS security mechanisms
   - Gets the same protection as your system credentials

2. **Fallback Storage**: Encrypted file
   - Implements AES-256-CBC encryption
   - Derives keys from unique system attributes:
     - Username
     - Hostname
     - Machine ID
   - Creates deterministic but unique keys for each system

### 🐚 Shell Integration

If using an encrypted local file, the environment builds shell-specific wrappers that:

1. Pull your token from secure storage
2. Inject it as an env var for GitHub CLI
3. Clean up after command execution

### 🔑 Git Credential Helper Integration

The environment configures the appropriate Git credential helper based on your operating system:

- **macOS**: `osxkeychain` helper stores credentials in the macOS Keychain
- **Linux**: `libsecret` helper (if available) or `store` helper
- **Other**: Falls back to the `store` helper

This integration ensures that:
- Your GitHub token is used for both GitHub CLI and Git operations
- You're not prompted for credentials during Git operations
- Credentials are stored securely using your OS's recommended mechanism

## 🔧 Troubleshooting

If GitHub auth breaks:

1. **Auth fails in environment**: 
   - Exit the environment
   - Run `flox activate` again; if config is FUBAR, this will re-trigger setup
   
2. **Persistent failures**:
   - Exit the environment
   - Nuke the local repo folder
   - Either:
     - Clone the repo again, or
     - Create (`mkdir`) a new repo folder and run `flox pull --copy barstoolbluz/ghcli`
   - Enter clean environment with `flox activate`

3. **Keyring issues**: 
   - The wizard will fall back to encrypted file storage

4. **Git credential helper issues**:
   - Run `git config --list | grep credential` to check your current configuration
   - Run `flox activate` again to re-run the setup wizard
   - If problems persist, manually configure Git credential helper with:
     - macOS: `git config --global credential.helper osxkeychain`
     - Linux: `git config --global credential.helper libsecret` or `git config --global credential.helper store`

## 💻 System Compatibility

This works on:
- macOS (ARM64, x86_64)
- Linux (ARM64, x86_64)

## 🔒 Security Considerations

- Tokens never exist as plaintext
- System keyring implements OS-native security
- Encrypted files use system-derived keys that can't be easily guessed
- Network traffic only occurs during GitHub API validation
- Git credential helper offers the same level of security as your system's credential storage

**Linux Keyring Note**: 
On Linux, with both GNOME Keyring and KWallet it is possible to dump credentials if an attacker gains access to your active, unlocked session. While sufficient for most use cases, they don't match the security of dedicated password managers.

For hardened environments:
- Consider dedicated password managers for token storage
- Lock your system when you step away
