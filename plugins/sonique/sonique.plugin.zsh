# ZSH options
setopt INTERACTIVECOMMENTS

local sonique_plugin_path="$(cd "$(dirname "$0")" && pwd)"

source ${sonique_plugin_path}/exports.zsh
source ${sonique_plugin_path}/aliases.zsh
source ${sonique_plugin_path}/functions.zsh

goJava8
