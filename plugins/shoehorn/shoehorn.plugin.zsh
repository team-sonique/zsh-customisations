_SHOEHORN_VERSION="429"

_BOLD=$(tput bold)
_TEXT_GREEN=$(tput setaf 2)
_TEXT_YELLOW=$(tput setaf 3)
_TEXT_WHITE=$(tput setaf 7)
_RESET_FORMATTING=$(tput sgr0)

source "$(cd "$(dirname "$0")" && pwd)"/artifactory.zsh
source "$(cd "$(dirname "$0")" && pwd)"/shoehorn_functions.zsh
source "$(cd "$(dirname "$0")" && pwd)"/aggregates.zsh
source "$(cd "$(dirname "$0")" && pwd)"/completion_helpers.zsh

# :completion:function:completer:command:argument:tag
zstyle ':completion:*:*:deploy:*:*' sort false
