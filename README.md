# NeuronHub

An all-in-one AI resource hub: scripts, setups, and a simple static website you can host (or open locally) to share your AI environment tooling.

## What’s inside

- `index.html`: A responsive, offline-friendly landing page to download/copy install commands for the setup script.
- `ClaudeCode-Installation.sh`: Linux installer that sets up a local AI workflow (Ollama + Gemma model) and installs Claude Code + required tooling.
- `create-contest-user.sh`: NixOS helper script to create a restricted “contest” user and rebuild the system config.

## Quick start

### View the website locally

- Open `index.html` directly in your browser, or serve it locally to ensure copy-to-clipboard works:
  - `python3 -m http.server 8000`
  - Then open `http://localhost:8000`

### Run the Claude Code setup script

From the repo root:

- `chmod +x ClaudeCode-Installation.sh`
- `./ClaudeCode-Installation.sh`

Notes:
- The script requires internet during installation (downloads Ollama / Node.js / Claude Code and pulls the selected model).
- It may prompt for `sudo` and appends environment variables to `~/.bashrc`.

### NixOS contest user script

This script modifies `/etc/nixos/configuration.nix` and runs a rebuild:

- Review first: `less create-contest-user.sh`
- Run: `./create-contest-user.sh`

## Hosting

This repo can be hosted as a static site (for example via GitHub Pages) since the landing page is a single `index.html` at the repository root.

## Roadmap ideas

- Add more AI setup scripts (GPU, CUDA, drivers)
- Add “recipes” (prompts, aliases, tool configs)
- Add a resources directory (links, docs, models)
- Add a proper Docs site generator (later)

## License

No license file is included yet. Add a `LICENSE` if you want others to reuse this repo with clear terms.
