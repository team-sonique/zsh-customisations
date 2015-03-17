# Sets the name of your OS X Terminal Tab
function tabname {
    if [ -z $1 ]
    then
        export DISABLE_AUTO_TITLE="false"
    else
        export DISABLE_AUTO_TITLE="true"
        printf "\e]1;$1\a"
        if [ ! -z $2 ]
        then
            printf "\e]2;$2\a"
        fi
    fi
}

function killIdeaSupergirl {
    ./target/data/apps/supergirl/superman/dev-NETSTREAM-SNAPSHOT/stop.sh -f
    ./target/data/apps/supergirl/superman/ffestyready-NETSTREAM-SNAPSHOT/stop.sh -f
    ./target/data/apps/supergirl/ffestiniog/dev-DEV-SNAPSHOT/stop.sh -f
}

function killMavenSupergirl {
    ./supergirl-integration/target/data/apps/supergirl/superman/dev-NETSTREAM-SNAPSHOT/stop.sh -f
    ./supergirl-integration/target/data/apps/supergirl/dnr/developers-multipleTomcats-NETSTREAM-SNAPSHOT/stop.sh -f
    ./supergirl-integration/target/data/apps/supergirl/superman/ffestyready-NETSTREAM-SNAPSHOT/stop.sh -f
}

function goMvn3 {
    ln -sfn ~/tools/apache-maven-$MAVEN3_VER ~/tools/mvn
    export M2_HOME=~/tools/mvn
    export M2=$M2_HOME/bin
    export MAVEN_OPTS="-Xmx1G"
    export PATH=`echo $PATH | sed -e s/apache-maven-$MAVEN2_VER/apache-maven-$MAVEN3_VER/g`
}

function goMvn2 {
    ln -sfn ~/tools/apache-maven-$MAVEN2_VER ~/tools/mvn
    export M2_HOME=~/tools/mvn
    export M2=$M2_HOME/bin
    export MAVEN_OPTS="-Xmx1G"
    export PATH=`echo $PATH | sed -e s/apache-maven-$MAVEN3_VER/apache-maven-$MAVEN2_VER/g`
}

function goJava6 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
}

function goJava7 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
}

function goJava8 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
}

function gclone {
    git clone https://git.sns.sky.com/team-sonique/$1.git
}

# Assurance View Functions
function aview_deploy {
    if [ -z "$1" ]
    then
        REVISION="DEV-SNAPSHOT"
    else
        REVISION="$1"
    fi

    ~/projects/assuranceview/aview-pipeline/src/test/shell/deploy-aview.sh $REVISION dev revert
    ~/projects/assuranceview/aview-pipeline/src/test/shell/deploy-aview.sh $REVISION dev deploy
}

function aview_start {
    /data/apps/aview/dev/start.sh
}

function aview_stop {
    /data/apps/aview/dev/stop.sh
}

function optimusprimer_deploy {
    if [ -z "$1" ]
    then
        REVISION="DEV-SNAPSHOT"
    else
        REVISION="$1"
    fi

    ~/projects/assuranceview/optimusprimer-pipeline/src/test/shell/deploy-optimusprimer.sh $REVISION dev revert
    ~/projects/assuranceview/optimusprimer-pipeline/src/test/shell/deploy-optimusprimer.sh $REVISION dev deploy
}

function optimusprimer_start {
    /data/apps/optimusprimer/dev/start.sh
}

function optimusprimer_stop {
    /data/apps/optimusprimer/dev/stop.sh
}

function setLinks {
    for dir in ~/.m2 ~/.gradle
    do
        if [ ! -e ${dir} ]
        then
            mkdir ${dir}
        fi
    done

    for file in ${TOOLS} ~/.m2/settings.xml ~/.gitconfig ~/.gitignore ~/gradle/init.gradle
    do
        if [ -e ${file} ]
        then
            rm -f ${file}
        fi
    done

    ln -sfnv ~/trunk/netstream-tools ${TOOLS}
    ln -sfnv ~/projects/sonique-env/sonique-maven-settings.xml ~/.m2/settings.xml
    ln -sfnv ~/projects/sonique-env/gitconfig ~/.gitconfig
    ln -sfnv ~/projects/sonique-env/gitignore ~/.gitignore
    ln -sfnv ~/projects/sonique-env/sonique-init.gradle ~/.gradle/init.gradle
    ln -sfnv ~/projects/sonique-env/ansible.cfg ~/.ansible.cfg
}
