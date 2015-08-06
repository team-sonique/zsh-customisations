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
    export JAVA_HOME=`/usr/libexec/java_home -v '1.8.0_51'`
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
