# ZSH options
setopt INTERACTIVECOMMENTS

source "$(cd "$(dirname "$0")" && pwd)"/exports.zsh
source "$(cd "$(dirname "$0")" && pwd)"/aliases.zsh
source "$(cd "$(dirname "$0")" && pwd)"/kubectl_auto_complete.zsh
source "$(cd "$(dirname "$0")" && pwd)"/functions.zsh

goJava8
