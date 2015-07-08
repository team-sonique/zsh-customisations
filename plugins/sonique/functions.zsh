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
    ./target/data/apps/supergirl/superman/dev-DEV-SNAPSHOT-DEV-SNAPSHOT/stop.sh -f
    ./target/data/apps/supergirl/ffestiniog/dev-DEV-SNAPSHOT-DEV-SNAPSHOT/stop.sh -f
}

function killMavenSupergirl {
    ./supergirl-integration/target/data/apps/supergirl/superman/dev-DEV-SNAPSHOT-DEV-SNAPSHOT/stop.sh -f
    ./supergirl-integration/target/data/apps/supergirl/ffestiniog/dev-DEV-SNAPSHOT-DEV-SNAPSHOT/stop.sh -f
}

function goJava6 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
}

function goJava7 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
}

function goJava8 {
    export JAVA_HOME=`/usr/libexec/java_home -v '1.8.0_40'`
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

function setLinks {
    for dir in ~/.m2
    do
        if [ ! -e ${dir} ]
        then
            mkdir ${dir}
        fi
    done

    for file in ~/.m2/settings.xml ~/.gitconfig ~/.gitignore ~/repository
    do
        if [ -e ${file} ]
        then
            rm -f ${file}
        fi
    done

    ln -sfnv ~/projects/sonique-env/sonique-maven-settings.xml ~/.m2/settings.xml
    ln -sfnv ~/projects/sonique-env/gitconfig ~/.gitconfig
    ln -sfnv ~/projects/sonique-env/gitignore ~/.gitignore
    ln -sfnv ~/projects/sonique-env/ansible.cfg ~/.ansible.cfg
    ln -sfnv ~/.m2/repository ~/repository
}
