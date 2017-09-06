alias mvn='mvn-color'
alias mi='mvn clean install'
alias mist='mvn clean install -DskipTests'
alias mih2='mvn clean install -DuseH2=true'
alias mio='mvn clean install -PuseOracle'
alias mior='mvn clean install -PuseOracle,rebuildDatabase'
alias mistor='mvn package -PuseOracle,rebuildDatabase -pl ${PWD##*/}-sql'
alias idea='open . -a /Applications/IntelliJ\ IDEA.app'
alias h=history
alias deleteUnversioned='svn st | grep ^\? | grep -v ".idea" | grep -v ".iml" | grep -v ".java" | grep -v ".patch" | grep -v ".xml" | cut -c7-500 | xargs rm -rvf'
alias gs='git status --short'
alias update-bundle='brew tap homebrew/bundle && brew bundle --file=${ZDOTDIR}/Brewfile'
alias removeKnowHostBuildAgents='sed -i "" "/^ba*/d" ~/.ssh/known_hosts'


alias gws='git status --short'
alias gwS='git status'
alias gfr='git pull --rebase'
alias gia='git add'
