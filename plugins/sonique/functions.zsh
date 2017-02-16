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

function goJava6 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
}

function goJava7 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
}

function goJava8 {
    if [ -z $1 ]
    then
        export JAVA_HOME=`/usr/libexec/java_home -v '1.8'`
    else
        export JAVA_HOME=`/usr/libexec/java_home -v "1.8.0_$1"`
    fi
}

function gclone {
    git clone https://git.sns.sky.com/team-sonique/$1.git
}

function setLinks {
    {
        function $0_link {
            local target=$1
            local link_name=$2

            if [ -e ${target} ]; then
                mkdir -p ${link_name%/*}

                if [ -e ${link_name} ]; then
                    rm -rf ${link_name}
                fi
                ln -sfnv ${target} ${link_name}
            fi
        }

        for linky in `ls $ZDOTDIR/dotfiles`
        do
          $0_link ${ZDOTDIR}/dotfiles/${linky} ~/.${linky}
        done

        $0_link ~/.m2/repository ~/repository
        $0_link ${ZDOTDIR}/sonique-maven-settings.xml ~/.m2/settings.xml

    } always {
        unfunction $0_link
    }
}

function rebuildDatabase {
    mvn package -pl ${PWD##*/}-sql -PrebuildDatabase
}

function upgradeDatabase {
    mvn package -pl ${PWD##*/}-sql -PupgradeDatabase
}

function startDockerDatabase {
    local app_name='oracle-12c'
    output=$(docker inspect --format='{{ .State.Status }}' $app_name 2> /dev/null)

    if [[ $? -eq 1 ]]; then
        echo 'Creating local Docker database'
        docker run --name oracle-12c -d -p 1521:1521 -p 5500:5500 --shm-size=4g --restart=unless-stopped --net=sonique-network --net-alias=oracle-12c repo.sns.sky.com:8085/sns-is-dev/oracle-12c > /dev/null
    else
        if [[ $output == 'running' ]]; then
            #do nothing
        else
            echo 'Starting local Docker database'
            docker start oracle-12c > /dev/null
        fi
    fi
    echo "Docker database running on jdbc:oracle:thin:@//localhost:1521/db1"
}

function startHazelcast {
    local app_name='hazelcast'
    output=$(docker inspect --format='{{ .State.Status }}' $app_name 2> /dev/null)

    if [[ $? -eq 1 ]]; then
        echo 'Creating local Hazelcast Instance'
        docker run --name hazelcast -d -p 5701:5701 --net=sonique-network --net-alias=hazelcast hazelcast/hazelcast > /dev/null
    else
        if [[ $output == 'running' ]]; then
            #do nothing
        else
            echo 'Starting local Hazelcast Instance'
            docker start hazelcast > /dev/null
        fi
    fi
    echo "Hazelcast Instance running at 127.0.0.1:5701"
}

function say {
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
}
