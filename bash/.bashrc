# prepend_path skips directories that do not exist and entries already on PATH,
# so re-sourcing this file cannot grow PATH without bound.
prepend_path() {
  [ -d "$1" ] || return 0
  case ":${PATH}:" in
  *":$1:"*) ;;
  *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

# Lowest priority first: the last prepend wins.
prepend_path "$HOME/.cargo/bin"
prepend_path "$HOME/.juliaup/bin"
prepend_path "$HOME/.bun/bin"
prepend_path "$HOME/.opencode/bin"
prepend_path "$HOME/.local/bin"

# Above the interactivity guard on purpose. Below the guard, PATH would
# also be missing from every non-interactive shell.
export PATH

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# History
HISTSIZE=1000
HISTFILESIZE=2000
HISTIGNORE="?:ls:la:ll:exit:pwd:clear:history"
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Case insensitive globbing
shopt -s nocaseglob

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# Autocorrect typos in path names when using cd
shopt -s cdspell

# Don't autocomplete when tabbing an empty line
shopt -s no_empty_cmd_completion

# Set default editor to Neovim
export EDITOR=nvim

alias ls='ls --color=auto'
alias l='ls'
alias la='ls -A'
alias ll='ls -Al --classify --human-readable'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../../"

alias grep='grep --color=auto'  # highlight matches
alias fgrep='grep -F'           # search for fixed strings
alias egrep='grep -E'           # extended regex
alias grepi='grep -i'           # case insensitive
alias grepv='grep -v'           # invert match
alias greph='history | grep -i' # search history

alias gs='git status'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

alias hist='history'
alias du='du --human-readable --total'
alias df='df --human-readable --total'
# alias diff='diff -u'

alias vi='nvim'
alias vim='nvim'

alias za='zathura'

# Prompt largely based on https://github.com/spindi/setup/blob/master/bash/prompt.sh

BLACK="\[\e[30m\]"
RED="\[\e[31m\]"
GREEN="\[\e[32m\]"
YELLOW="\[\e[33m\]"
BLUE="\[\e[34m\]"
PURPLE="\[\e[35m\]"
CYAN="\[\e[36m\]"
GREY="\[\e[37m\]"
RESET="\[\e[0m\]"

# Return the prompt symbol to use, colorized based on the return value of the
# previous command.
function set_prompt_symbol() {
  if [ $1 -eq 0 ]; then
    PROMPT_SYMBOL="❯"
  else
    PROMPT_SYMBOL="${RED}❯${RESET}"
  fi
}

function set_git_branch {

  # Determine the current branch, redirecting errors to /dev/null
  local branch="$(git symbolic-ref --short HEAD 2>/dev/null)"

  if [ -n "$branch" ]; then

    # Each line of the output is of the form 'XY filename', where the characters
    # X, Y denote the state of the file in the index (X) and working dir (Y)
    local status=$(git status --porcelain 2>/dev/null)

    # Set a coloured symbol to concisely indicate the status
    local symbol
    if [ -z "$status" ]; then
      # Empty string -> clean state
      symbol="${GREEN}✔" # or ✓
    else
      if [ $(echo "$status" | grep -c '^.\{1\} ') -gt 0 ]; then
        # There are staged changes ('X  filename')
        symbol="${symbol}${YELLOW}±"
      fi
      if [ $(echo "$status" | grep -c '^.\{1\}[^? ]') -gt 0 ]; then
        # There are unstaged changes (' Y filename', or 'XY filename')
        symbol="${symbol}${RED}±"
      fi
      if [ $(echo "$status" | grep -c '^??') -gt 0 ]; then
        # There are untracked files ('?? filename')
        symbol="${symbol}${RED}?"
      fi
    fi

    # Set the variable used in the prompt
    PS1_BRANCH=" ${PURPLE}${branch}${symbol}${RESET}"
  else
    # Not in a git repository
    PS1_BRANCH=""
  fi
}

function set_devbox_shell() {
  if [ $DEVBOX_SHELL_ENABLED ]; then
    PS1_DEVBOX=" ${GREY}📦$(basename "$DEVBOX_PROJECT_ROOT")${RESET}"
  else
    PS1_DEVBOX=""
  fi
}

function set_python_venv() {
  if [ -z "$VIRTUAL_ENV" ]; then
    PS1_VENV=""
  else
    # NOTE: assumes a project's virtual environments are kept in directories
    # directly under the project root.
    local project=$(basename $(dirname "$VIRTUAL_ENV"))
    local venv=$(basename "$VIRTUAL_ENV")
    PS1_VENV=" ${BLUE}(${project}/${venv})${RESET}"
  fi
}

function set_bash_prompt() {
  # Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
  # return value of the last command.
  set_prompt_symbol $?

  set_git_branch
  set_devbox_shell
  set_python_venv

  PS1="
${GREEN}\u@\h${RESET}:${YELLOW}\w${RESET}${PS1_BRANCH}${PS1_DEVBOX}${PS1_VENV}
${PROMPT_SYMBOL} "

}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt

# Completions. Ubuntu ships this enabled in /etc/bash.bashrc but commented out,
# so sourcing it here saves editing a root-owned file on every new machine.
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

# --- Hook direnv --- #
eval "$(direnv hook bash)"

# FINALLY, machine-specific or work-specific settings, never committed
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
