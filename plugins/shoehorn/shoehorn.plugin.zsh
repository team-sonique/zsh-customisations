_SHOEHORN_VERSION="386"

_BOLD=`tput bold`
_TEXT_GREEN=`tput setaf 2`
_RESET_FORMATTING=`tput sgr0`

source "$(cd "$(dirname "$0")" && pwd)"/artifactory.zsh
source "$(cd "$(dirname "$0")" && pwd)"/shoehorn_functions.zsh
source "$(cd "$(dirname "$0")" && pwd)"/aggregates.zsh
source "$(cd "$(dirname "$0")" && pwd)"/compdefs.zsh
