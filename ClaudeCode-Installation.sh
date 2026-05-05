#!/bin/bash

# -------------------------------
# Pre-checks & Safety
# -------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "[!] This script may require sudo privileges."
fi

set -euo pipefail

# Colors
GREEN="\e[32m"
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"

# Loading animation
loading() {
    echo -n "[*] Processing"
    for i in {1..3}; do
        echo -n "."
        sleep 0.5
    done
    echo ""
}

# Internet check
if ! ping -c 1 google.com &> /dev/null; then
    echo -e "${RED}[!] No internet connection detected. Exiting...${RESET}"
    exit 1
fi

echo ""
echo -e "${CYAN}==============================${RESET}"
echo -e "${GREEN} Claude-Code SETUP STARTING...${RESET}"
echo -e "${CYAN}==============================${RESET}"

# -------------------------------
# 1. Install Ollama
# -------------------------------
echo ""
echo -e "${CYAN}✴️[1/5] Installing Ollama...${RESET}"
echo ""

if ! command -v ollama &> /dev/null
then
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo -e "${GREEN}Ollama already installed${RESET}"
fi

echo "Checking Ollama version..."
ollama --version

# -------------------------------
# 2. Choose and Download Gemma 4
# -------------------------------
echo ""
echo -e "${CYAN}✴️[2/5] Select Gemma 4 model based on your system RAM${RESET}"

TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
echo -e "Detected RAM: ${GREEN}${TOTAL_RAM}GB${RESET}"

if [ "$TOTAL_RAM" -le 8 ]; then
    SUGGESTED="gemma4:e2b"
elif [ "$TOTAL_RAM" -le 16 ]; then
    SUGGESTED="gemma4:e4b"
else
    SUGGESTED="gemma4:26b"
fi

echo -e "Recommended model: ${GREEN}$SUGGESTED${RESET}"

echo ""
echo "Choose a model:"
echo "1) gemma4:e2b  (~3GB)  → 8GB RAM"
echo "2) gemma4:e4b  (~7GB)  → 16GB RAM"
echo "3) gemma4:26b (~18GB) → 32GB RAM"
echo ""

read -p "Enter choice (1/2/3) or press ENTER for recommended: " choice

if [ -z "${choice:-}" ]; then
    MODEL="$SUGGESTED"
else
    case $choice in
        1) MODEL="gemma4:e2b" ;;
        2) MODEL="gemma4:e4b" ;;
        3) MODEL="gemma4:26b" ;;
        *) 
            echo -e "${RED}Invalid choice! Using recommended.${RESET}"
            MODEL="$SUGGESTED"
            ;;
    esac
fi

echo ""
echo -e "Selected model: ${GREEN}$MODEL${RESET}"

# Prevent re-download
if ! ollama list | grep -q "$MODEL"; then
    echo "Downloading model..."
    loading
    ollama pull $MODEL
else
    echo -e "${GREEN}Model already exists. Skipping download.${RESET}"
fi

echo ""
echo "Verifying model installation..."
ollama list

# -------------------------------
# 3. Install Node.js
# -------------------------------
echo ""
echo -e "${CYAN}✴️[3/5] Checking Node.js...${RESET}"
echo ""

if ! command -v node &> /dev/null
then
    echo "Installing Node.js LTS..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo -e "${GREEN}Node.js already installed${RESET}"
fi

node --version

# -------------------------------
# 4. Install Claude Code
# -------------------------------
echo ""
echo -e "${CYAN}✴️[4/5] Installing Claude Code...${RESET}"
echo ""

if ! command -v claude &> /dev/null
then
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo -e "${GREEN}✴️ Claude Code already installed${RESET}"
fi

echo "Checking Claude version..."
claude --version || echo -e "${RED}Claude install verification failed${RESET}"

# -------------------------------
# 5. Configure Environment
# -------------------------------
echo ""
echo -e "${CYAN}✴️[5/5] Setting environment variables...${RESET}"

SHELL_CONFIG="$HOME/.bashrc"

grep -qxF 'export ANTHROPIC_AUTH_TOKEN=ollama' $SHELL_CONFIG || echo 'export ANTHROPIC_AUTH_TOKEN=ollama' >> $SHELL_CONFIG
grep -qxF 'export ANTHROPIC_API_KEY=""' $SHELL_CONFIG || echo 'export ANTHROPIC_API_KEY=""' >> $SHELL_CONFIG
grep -qxF 'export ANTHROPIC_BASE_URL=http://localhost:11434' $SHELL_CONFIG || echo 'export ANTHROPIC_BASE_URL=http://localhost:11434' >> $SHELL_CONFIG

grep -qxF "export ANTHROPIC_DEFAULT_HAIKU_MODEL=$MODEL" $SHELL_CONFIG || echo "export ANTHROPIC_DEFAULT_HAIKU_MODEL=$MODEL" >> $SHELL_CONFIG
grep -qxF "export ANTHROPIC_DEFAULT_SONNET_MODEL=$MODEL" $SHELL_CONFIG || echo "export ANTHROPIC_DEFAULT_SONNET_MODEL=$MODEL" >> $SHELL_CONFIG
grep -qxF "export ANTHROPIC_DEFAULT_OPUS_MODEL=$MODEL" $SHELL_CONFIG || echo "export ANTHROPIC_DEFAULT_OPUS_MODEL=$MODEL" >> $SHELL_CONFIG

echo "Reloading shell config..."
source $SHELL_CONFIG

# -------------------------------
# FINAL TEST
# -------------------------------
echo ""
echo -e "${CYAN}=========================================${RESET}"
echo -e "${GREEN} ⚡ SYSTEM INITIALIZATION COMPLETE ⚡${RESET}"
echo -e "${CYAN}=========================================${RESET}"

echo ""
echo -e "${GREEN}[✴️] Ollama Engine        : ONLINE${RESET}"
echo -e "${GREEN}[✴️] Gemma 4 Model        : LOADED ($MODEL)${RESET}"
echo -e "${GREEN}[✴️] Claude Code Interface: READY${RESET}"

echo ""
echo -e "${CYAN}>> Local AI environment deployed successfully${RESET}"
echo -e "${CYAN}>> Running fully OFFLINE${RESET}"

echo ""
echo "-----------------------------------------"
echo "   ACCESS GRANTED — WELCOME OPERATOR"
echo "-----------------------------------------"

loading

USERNAME=$(whoami)

ollama run $MODEL "Hello I am '$USERNAME'. You will Address me as '$USERNAME'"


echo ""
echo -e "${CYAN}✴️>> Do you want to run Claude Code locally now? (y/n)${RESET}"
read -r RUN_CLAUDE
echo ""
case "$RUN_CLAUDE" in
    [yY]|[yY][eE][sS])
        echo ""
        echo -e "${GREEN}[+] Launching Claude Code with model: $MODEL${RESET}"
        echo "-----------------------------------------"
        sleep 1
        ollama launch claude --model "$MODEL"
        ;;
    [nN]|[nN][oO])
        echo ""
        echo -e "${CYAN}✴️>> You can start it anytime using:${RESET}"
        echo "ollama launch claude --model $MODEL"
        ;;
    *)
        echo ""
        echo -e "${RED}[!] Invalid input. Skipping auto-launch.${RESET}"
        echo "Run manually:"
        echo "ollama launch claude --model $MODEL"
        echo "OR manually:"
	echo "claude --model $MODEL"
        ;;
esac


# Script by Istiak Alam
