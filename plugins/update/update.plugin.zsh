local UPDATE_AUDIT_FILE='.sonique_lastupdate'

if [ -z "$SONIQUE_UPDATE_DAYS" ]; then
  local SONIQUE_UPDATE_DAYS=1
fi

source "$(cd "$(dirname "$0")" && pwd)"/update_functions.zsh

startUpdateProcess

# clean up after ourselves
update_cleanup
