ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"

typeset -A ARTIFACT_COORDINATES
ARTIFACT_COORDINATES[kiki]="sky.sns.kiki:kiki-core"
ARTIFACT_COORDINATES[gruffalo]="sonique.gruffalo:gruffalo-build"
ARTIFACT_COORDINATES[ffestiniog]="sonique.ffestiniog:ffestiniog-core"
ARTIFACT_COORDINATES[spm-sat]="sonique.spm-sat:spm-sat-core"
ARTIFACT_COORDINATES[redqueen]="sonique.redqueen:redqueen-core"
ARTIFACT_COORDINATES[superman]="sky.sns:superman-deploy"
ARTIFACT_COORDINATES[luthor]="sonique.luthor:luthor-core"

function shoehorn {
    GOAL="$1"

    if [ -z "$2" ]
    then
        echo "usage: ${GOAL} application [version] [environment]"
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

    mvn shoehorn:${GOAL} -DapplicationName=${APP} -Dversion=${VERSION} -DenvironmentName=${ENV}
}

function deploy {
    shoehorn deploy "$@"
}

function start {
    shoehorn start "$@"
}

function stop {
    shoehorn stop "$@"
}

function status {
    shoehorn status "$@"
}

function clean {
    shoehorn clean "$@"
}

function shoehorn-snapshot {
    $1 "$2" "DEV-SNAPSHOT-DEV-SNAPSHOT" "$3"
}

function deploy-snapshot {
    shoehorn-snapshot "deploy" "$@"
}

function start-snapshot {
    shoehorn-snapshot "start" "$@"
}

function stop-snapshot {
    shoehorn-snapshot "stop" "$@"
}

function status-snapshot {
    shoehorn-snapshot "status" "$@"
}

function clean-snapshot {
    shoehorn-snapshot "clean" "$@"
}
