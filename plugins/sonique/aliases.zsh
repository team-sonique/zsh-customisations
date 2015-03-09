alias mi='mvn clean install'
alias mist='mvn clean install -DskipTests -DskipAcceptance'
alias mih2='mvn clean install -DuseH2=true'
alias opom='open . -a /Applications/IntelliJ\ IDEA\ 14.app'
alias h=history
alias csm='mvn -Pmulti-tomcat,cargo cargo:start -DskipTests'
alias csm-cvf='mvn -Pmulti-tomcat,cvf,cargo cargo:start -DskipTests'
alias deleteUnversioned='svn st | grep ^\? | grep -v ".idea" | grep -v ".iml" | grep -v ".java" | grep -v ".patch" | grep -v ".xml" | cut -c7-500 | xargs rm -rvf'
alias gs='git status --short'
