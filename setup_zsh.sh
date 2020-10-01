#!/bin/bash -xe

# To install
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/peteroneilljr/.dotfiles/master/setup_zsh.sh)"

# ---------------------------------------------------------------------------- #
# Find package manager
# ---------------------------------------------------------------------------- #
if [[ -x "/usr/bin/apt-get" ]]; then 
  PCK_MGR="/usr/bin/apt-get"
elif [[ -x "/usr/bin/yum" ]]; then 
  PCK_MGR="/usr/bin/yum"
else 
  echo "Not yum or apt exiting" 
fi
# ---------------------------------------------------------------------------- #
#   # install zsh
# ---------------------------------------------------------------------------- #
if ! command -V zsh; then 
  $PCK_MGR install zsh -y || \
    ( 
      echo "failed zsh install, attempting $PCK_MGR update"
      $PCK_MGR update -y --skip-broken
      $PCK_MGR install zsh -y 
    )
else
  echo "zsh already installed"
fi
# ---------------------------------------------------------------------------- #
#   # https://github.com/ohmyzsh/ohmyzsh
# ---------------------------------------------------------------------------- #
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
  echo "Installed oh-my-zsh"
else
  echo "oh-my-zsh already installed"
fi
# ---------------------------------------------------------------------------- #
#   # Install zsh-autosuggestions plugin
# ---------------------------------------------------------------------------- #
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
  echo "Installed zsh-autosuggestions" || echo "Install failed"
else
  echo "zsh-autosuggestions already installed"
fi
# ---------------------------------------------------------------------------- #
#   # Install zsh-syntax-highlighting plugin
# ---------------------------------------------------------------------------- #
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
  echo "Installed zsh-syntax-highlighting" || echo "Install failed"
else
  echo "zsh-syntax-highlighting already installed"
fi
# ---------------------------------------------------------------------------- #
# Download dotfiles https://github.com/peteroneilljr/.dotfiles.git
# ---------------------------------------------------------------------------- #
if [[ ! -d "$HOME/.dotfiles" ]]; then
  # Save current zshrc file if it exists
  git clone https://github.com/peteroneilljr/.dotfiles.git "$HOME"/.dotfiles && \
  echo "Installed .dotfiles" || echo "Install failed"
else
  echo ".dotfiles already installed"
fi
# ---------------------------------------------------------------------------- #
# Backup old zshrc and create a symlink to new zshrc
# ---------------------------------------------------------------------------- #
if [[ -f "$HOME/.zshrc" ]] && [[ ! -L "$HOME/.zshrc" ]]; then 
  mv "$HOME"/.zshrc "$HOME"/.zshrc.backup && \
  echo "created zshrc backup"; 
fi

if [[ -L "$HOME/.zshrc" ]]; then 
  echo ".zshrc already linked"; 
else 
  ln -sv ~/.dotfiles/.zshrc "$HOME";
fi
# ---------------------------------------------------------------------------- #
# Cleanup file ownership, change shell, and load zsh
# ---------------------------------------------------------------------------- #
if ! logname; then
  THISUSER="$USER"
else 
  THISUSER="$(logname)"
fi
if [[ "$(grep "$THISUSER" /etc/passwd | cut -d: -f7)" != *"/zsh" ]]; then
  if [[ "$THISUSER" == "root" ]]; then 
    chsh -s "/bin/zsh" "$THISUSER";
  else 
    chown -R "$THISUSER":"$THISUSER" "$HOME"
    chsh -s "/usr/bin/zsh" "$THISUSER"
  fi
fi

# ---------------------------------------------------------------------------- #
# Start zsh shell
# ---------------------------------------------------------------------------- #
if [[ -d "$HOME/.oh-my-zsh" ]] &&\
  [[ -d "$HOME/.dotfiles" ]] &&\
  [[ -L "$HOME/.zshrc" ]]; 
then 
  if [[ $SHELL != *"/zsh" ]]; then 
    zsh
  else echo "zsh already running";
  fi
else 
  echo "something went wrong"
  exit 1
fi
exit 0
