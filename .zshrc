export ZSH="$HOME/.oh-my-zsh"
[[ -d "$HOME/.cache/.bun/bin" ]] && export PATH="$HOME/.cache/.bun/bin:$PATH"
ZSH_THEME="afowler"

plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-history-substring-search
)


# Solo si la shell es interactiva
[[ $- != *i* ]] && return

source $ZSH/oh-my-zsh.sh

# Pronmpt configuration

function dir_icon {
	if [[ "$PWD" == "$HOME" ]]; then
		echo "%B%F{black}%f%b"
	else
		echo "%B%F{cyan}%f%b"
	fi
}

function parse_git_branch {
	local branch
	branch=$(git symbolic-ref --short HEAD 2> /dev/null)
	if [ -n "$branch" ]; then
		echo " [$branch]"
	fi
}

PROMPT='%F{cyan}󰣇 %F{blue}%n%f $(dir_icon) %F{blue}%~%f%${vcs_info_msg_0_} %F{yellow}$(parse_git_branch)%f %(?.%B%F{green}.%F{red})%f%b '

# Mostrar fastfetch al iniciar
#fastfetch

# Funciones personalizadas
spt() {
  GDK_BACKEND=x11 \
  QT_QPA_PLATFORM=xcb \
  ELECTRON_OZONE_PLATFORM_HINT=x11 \
  flatpak run com.spotify.Client --force-device-scale-factor=1.0 &!
}

pp() {
  playerctl -p spotify play-pause
}

nx() {
  playerctl -p spotify next
}

pr() {
  playerctl -p spotify previous
}

song() {
  playerctl metadata --format '{{ artist }} - {{ title }}'
}

idea() {
  intellij-idea-ultimate-edition > /dev/null 2>&1 &
}

cli() {
  clion > /dev/null 2>&1 &
}

bra() {
  GDK_BACKEND=x11 \
  QT_QPA_PLATFORM=xcb \
  ELECTRON_OZONE_PLATFORM_HINT=x11 \
  flatpak run com.brave.Browser --force-device-scale-factor=1.0 &!
}

actpy() {
  source ~/venvs/pyopengl-env/bin/activate
}

if command -v eza >/dev/null 2>&1; then
  alias l="eza -lh --icons=auto"
  alias ls="eza -ha --icons=auto --sort=name --group-directories-first"
fi

if command -v pokemon-colorscripts >/dev/null 2>&1; then
  alias pokemon="pokemon-colorscripts --no-title -n"
  pokemon-colorscripts --no-title -r 1,2,3
fi

if [[ -x "$HOME/.config/fastfetch/scripts/fastfetch-ramdom-logo.sh" ]]; then
  alias fastfetch="$HOME/.config/fastfetch/scripts/fastfetch-ramdom-logo.sh"
fi

alias nv="nvim"

if command -v zen-browser >/dev/null 2>&1; then
  alias zen='zen-browser &'
elif command -v zen >/dev/null 2>&1; then
  alias zen='zen &'
elif [[ -x "$HOME/.tarball-installations/zen/zen" ]]; then
  alias zen='$HOME/.tarball-installations/zen/zen &'
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[[ -d /opt/mssql-tools/bin ]] && export PATH="$PATH:/opt/mssql-tools/bin"
export PATH="$HOME/.local/bin:$PATH"
if [[ -d "$HOME/Android/Sdk" ]]; then
  export ANDROID_HOME=$HOME/Android/Sdk
  export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
fi
[[ -d /usr/lib/jvm/java-17-openjdk ]] && export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
if [[ -d /opt/android-sdk ]]; then
  export ANDROID_HOME=/opt/android-sdk
  export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
fi
