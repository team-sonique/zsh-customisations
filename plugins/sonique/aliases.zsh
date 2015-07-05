alias mvn='mvn-color'
alias mi='mvn clean install'
alias mist='mvn clean install -DskipTests -DskipAcceptance'
alias mih2='mvn clean install -DuseH2=true'
alias opom='open . -a /Applications/IntelliJ\ IDEA\ 14.app'
alias h=history
alias deleteUnversioned='svn st | grep ^\? | grep -v ".idea" | grep -v ".iml" | grep -v ".java" | grep -v ".patch" | grep -v ".xml" | cut -c7-500 | xargs rm -rvf'
alias gs='git status --short'
alias update-bundle='brew tap homebrew/bundle && brew bundle --file=${ZDOTDIR}/Brewfile'
