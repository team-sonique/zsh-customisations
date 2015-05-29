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

ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"

typeset -A ARTIFACT_COORDINATES
ARTIFACT_COORDINATES[kiki]="sky.sns.kiki:kiki-core"
ARTIFACT_COORDINATES[gruffalo]="sonique.gruffalo:gruffalo-build"
ARTIFACT_COORDINATES[ffestiniog]="sonique.ffestiniog:ffestiniog-core"
ARTIFACT_COORDINATES[spm-sat]="sonique.spm-sat:spm-sat-core"
ARTIFACT_COORDINATES[redqueen]="sonique.redqueen:redqueen-core"
ARTIFACT_COORDINATES[superman]="sky.sns:superman-deploy"
ARTIFACT_COORDINATES[luthor]="sonique.luthor:luthor-core"

function shoehorn-properties {
    if [ -z "$2" ]
    then
        echo "usage: $1 application [version] [environment]"
        return 1
    else
        APP="$2"
    fi

    if [ -z "$3" ]
    then
        coordinate=${ARTIFACT_COORDINATES[$APP]}

        if [ -z ${coordinate} ]
        then
            groupId="sonique.${APP}"
            artifactId="${APP}-deploy"
        else
            groupId=${coordinate%:*}
            artifactId=${coordinate##*:}
        fi

        APP_VERSION=`curl -s "${ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${artifactId}&repos=libs-releases"`
        PROPERTIES_VERSION=`curl -s "${ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${APP}-properties&repos=libs-releases"`
        VERSION="${APP_VERSION}-${PROPERTIES_VERSION}"
    else
        VERSION="$3"
    fi

    if [ -z "$4" ]
    then
        ENV="dev"
    else
        ENV="$4"
    fi

    echo "-DapplicationName=${APP} -Dversion=${VERSION} -DenvironmentName=${ENV}"
}

function deploy {
    mvn shoehorn:deploy `shoehorn-properties deploy $@`
}

function start {
    mvn shoehorn:start `shoehorn-properties start $@`
}

function stop {
    mvn shoehorn:stop `shoehorn-properties stop $@`
}

function status {
    mvn shoehorn:status `shoehorn-properties status $@`
}

function clean {
    mvn shoehorn:clean `shoehorn-properties clean $@`
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
