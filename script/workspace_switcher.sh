#!/usr/bin/env bash

# *******************************************************************
# https://wezfurlong.org/wezterm/config/lua/pane/get_user_vars.html
# This function emits an OSC 1337 sequence to set a user var
# associated with the current terminal pane.
# It requires the `base64` utility to be available in the path.
# This function is included in the wezterm shell integration script, but
# is reproduced here for clarity
__wezterm_set_user_var() {
  if hash base64 2>/dev/null; then
    if [[ -z "${TMUX}" ]]; then
      printf "\033]1337;SetUserVar=%s=%s\007" "$1" $(echo -n "$2" | base64)
    else
      # <https://github.com/tmux/tmux/wiki/FAQ#what-is-the-passthrough-escape-sequence-and-how-do-i-use-it>
      # Note that you ALSO need to add "set -g allow-passthrough on" to your tmux.conf
      printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "$1" $(echo -n "$2" | base64)
    fi
  fi
}
# *******************************************************************

HOME_REPLACER=""
echo "$HOME" | grep -E "^[a-zA-Z0-9\-_/.@]+$" &>/dev/null # Chars safe to use in sed
HOME_SED_SAFE=$?
if [ $HOME_SED_SAFE -eq 0 ]; then # $HOME should be safe to use in sed
  HOME_REPLACER="s|^$HOME/|~/|"
fi



if [ $# -eq 1 ]; then
  SESSION_NAME=$(zoxide query "$1")
else

  BORDER_LABEL=" NAME "
  HEADER=" ctrl-s: Workspaces / ctrl-z: zoxide / ctrl-d: directory"
  PROMPT="zoxide> "
  SESSION_BIND="ctrl-s:change-prompt(Workspaces> )+reload(wezterm cli list --format json | sed -nr 's/\"workspace\": \"(.*)\",/\1/p' | uniq | sed -r 's/\s+//g')"
  ZOXIDE_BIND="ctrl-z:change-prompt(zoxide> )+reload(zoxide query -l | sed -e \"$HOME_REPLACER\")"

  if fd --version &>/dev/null; then # fd is installed
    DIR_BIND="ctrl-d:change-prompt(directory> )+reload(cd $HOME && echo $HOME; fd --type d --hidden --absolute-path --color never --exclude .git --exclude node_modules)"
  else # fd is not installed
    DIR_BIND="ctrl-d:change-prompt(directory> )+reload(cd $HOME && find ~+ -type d -name node_modules -prune -o -name .git -prune -o -type d -print)"
  fi


  SESSION_NAME=$((zoxide query -l  | sed -e "$HOME_REPLACER")| fzf \
    --bind "$DIR_BIND" \
    --bind "$SESSION_BIND" \
    --bind "$ZOXIDE_BIND" \
    --border-label "$BORDER_LABEL" \
    --header "$HEADER" \
    --prompt "$PROMPT"
  )
fi

if [ "$1" = "--tab-id" ]; then
  TABID=$2
fi

if [ "$SESSION_NAME" = "" ]; then # no result
  if [ -n "$TABID"  ]; then # switch to tab when complete
    wezterm cli activate-tab --tab-id $TABID
  fi
  exit 0
fi

if [ $HOME_SED_SAFE -eq 0 ]; then
  SESSION_NAME=$(echo "$SESSION_NAME" | sed -e "s|^~/|$HOME/|") # replace ~ with $HOME
fi

if [ -d $SESSION_NAME ]; then
  __wezterm_set_user_var "workspace_switch" $SESSION_NAME

  zoxide add "$SESSION_NAME" &>/dev/null # add to zoxide database
else
  __wezterm_set_user_var "workspace_switch_session_name" $SESSION_NAME
fi

sleep 1
