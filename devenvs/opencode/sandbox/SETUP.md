# OpenCode Sandbox Setup Guide

## Volume Mounts

The Docker image is designed to work with mounted directories to persist configurations and data. Here's what each mount point is for:

### Required Mounts

These mounts are already configured in `docker-compose.yml`:

| Mount Point | Host Path | Purpose | Mode |
|-------------|-----------|---------|------|
| `/.agents` | `~/.agents` | Agent configurations and libraries | read-write |
| `/.config/opencode` | `~/.config/opencode` | OpenCode configuration files | read-write |
| `/.local/state/opencode` | `~/.local/state/opencode` | OpenCode runtime state | read-write |
| `/.local/share/opencode` | `~/.local/share/opencode` | OpenCode data files | read-write |
| `/.cache/opencode` | `~/.cache/opencode` | OpenCode cache | read-write |

### Optional Mounts

Uncomment in `docker-compose.yml` if needed:

```yaml
# GitHub CLI authentication
- ${HOME}/.config/gh:${HOME}/.config/gh

# SSH keys (for git over SSH)
- ${HOME}/.ssh:${HOME}/.ssh:ro

# GPG keys (for signing commits)
- ${HOME}/.gnupg:${HOME}/.gnupg:ro

# Git configuration
- ${HOME}/.gitconfig:${HOME}/.gitconfig:ro
```

## Quick Start

### Using docker-compose (recommended)

```bash
docker-compose up -d
docker-compose exec opencode bash
```

### Using Docker directly

```bash
docker build -t opencode:ubuntu-26.04 .

docker run -it --rm \
  -v $HOME/.config/opencode:$HOME/.config/opencode \
  -v $HOME/.local/state/opencode:$HOME/.local/state/opencode \
  -v $HOME/.local/share/opencode:$HOME/.local/share/opencode \
  -v $HOME/.cache/opencode:$HOME/.cache/opencode \
  -v $HOME/.agents:$HOME/.agents \
  -v $HOME/.agenix:$HOME/.agenix:ro \
  -v $(pwd):$(pwd) \
  --network host \
  opencode:ubuntu-26.04
```

## Setting Up Persistent Configurations

### GitHub CLI

First time setup inside container:

```bash
gh auth login
# Follow prompts
```

This persists to `~/.config/gh` (mounted if enabled).

### SSH Keys

If you need git over SSH:

1. Uncomment the `.ssh` mount in `docker-compose.yml`
2. Ensure keys are in `~/.ssh` on host
3. Restart container: `docker-compose restart`

### GPG for Commit Signing

1. Uncomment the `.gnupg` mount in `docker-compose.yml`
2. Ensure your GPG keys are available on host
3. Configure git inside container:
   ```bash
   git config --global user.signingkey YOUR_KEY_ID
   ```

## Troubleshooting

### Mounts not persisting

- Verify mounts exist on host: `ls -la ~/.config/opencode`
- Check docker-compose volume config: `docker-compose config`
- Ensure directories are readable/writable: `chmod 755 ~/.config/opencode`

### Permission issues

If running into permission problems:

```bash
# Fix from host
mkdir -p ~/.config/opencode ~/.local/state/opencode ~/.local/share/opencode ~/.cache/opencode ~/.agents
chmod 755 ~/.config/opencode ~/.local/state/opencode ~/.local/share/opencode ~/.cache/opencode ~/.agents
```

### Volume mount conflicts

If you get "volume already mounted" errors:

```bash
docker-compose down -v  # Remove all volumes
docker-compose up -d    # Start fresh
```

## Available Tools in Container

- **Language runtimes**: Python, Node.js, Rust (with cargo)
- **Package managers**: uv (Python), npm, cargo, cargo-binstall
- **Dev tools**: git, git-lfs, make, build-essential, binutils
- **Search/find**: ripgrep, fd-find, fzf
- **JSON/data**: jq, sqlite3
- **CLI utilities**: gh (GitHub), tmux, tree, bat, eza
- **Security**: gpg, openssh-client, openssl
- **Compression**: gzip, bzip2, xz-utils, zip, unzip
