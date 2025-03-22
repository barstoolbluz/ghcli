# 🔐 A Flox Environment for GitHub CLI Auth Using a Local Keyring

This Flox environment secures your GitHub CLI (`gh`) authentication by storing GitHub Personal Access Tokens (PATs) locallly using standard methods. You get two storage options:

1. **System keyring/keychain** (preferred) - Uses OS security infrastructure
2. **Encrypted local file** (fallback) - Encrypts your token with a system-derived key

## ✨ Features

- Locks down GitHub tokens in your system keyring or encrypted files
- Handles GitHub CLI auth automatically without manual token entry
- Works across platforms (macOS, Linux)
- Hooks into Bash, Zsh, and Fish shells
- Includes a no-nonsense setup wizard that doesn't waste your time

## 🧰 Included Tools

The environment packs these essential tools:

- `gh` - GitHub CLI for fast API interactions
- `git` - Version control that doesn't get in your way
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
- Drops you into the Flox env with GitHub CLI ready to go

### 🧙 Setup Wizard

First-time activation triggers a wizard that:

1. Walks you through token creation if needed
2. Locks your token in the system keyring or encrypted file
3. Sets up shell wapper functions if required. If using a keyring, `gh` is unwrapped; if using encrypted local storage, `gh` is wrapped.

## 📝 Usage

After setup, you directly run GitHub CLI commands:

```bash
# List repos
gh repo list

# Create repo
gh repo create

# View PRs
gh pr list
```

Auth happens automatically via your configured mechanism.

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

## 💻 System Compatibility

This works on:
- macOS (ARM64, x86_64)
- Linux (ARM64, x86_64)

## 🔒 Security Considerations

- Tokens never exist as plaintext
- System keyring implements OS-native security
- Encrypted files use system-derived keys that can't be easily guessed
- Network traffic only occurs during GitHub API validation

**Linux Keyring Note**: 
On Linux, with both GNOME Keyring and KWallet it is possible to dump credentials if an attacker gains access to your active, unlocked session. While sufficient for most use cases, they don't match the security of dedicated password managers.

For hardened environments:
- Consider dedicated password managers for token storage
- Lock your system when you step away
