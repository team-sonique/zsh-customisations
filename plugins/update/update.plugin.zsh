
source "$(cd "$(dirname "$0")" && pwd)"/update_functions.zsh

startUpdateProcess ${SONIQUE_UPDATE_DAYS}

# clean up after ourselves
update_cleanup
