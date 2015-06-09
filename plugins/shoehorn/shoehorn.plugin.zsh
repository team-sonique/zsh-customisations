ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"

typeset -A ARTIFACT_COORDINATES
ARTIFACT_COORDINATES[kiki]="sky.sns.kiki:kiki-core"
ARTIFACT_COORDINATES[gruffalo]="sonique.gruffalo:gruffalo-build"
ARTIFACT_COORDINATES[ffestiniog]="sonique.ffestiniog:ffestiniog-core"
ARTIFACT_COORDINATES[spm-sat]="sonique.spm-sat:spm-sat-core"
ARTIFACT_COORDINATES[redqueen]="sonique.redqueen:redqueen-core"
ARTIFACT_COORDINATES[superman]="sky.sns:superman-deploy"
ARTIFACT_COORDINATES[luthor]="sonique.luthor:luthor-core"

typeset -A APP_VERSIONS

function get_latest_version {
    local app="$1"

    coordinate=${ARTIFACT_COORDINATES[$app]}

    if [ -z ${coordinate} ]
    then
        groupId="sonique.${app}"
        artifactId="${app}-deploy"
    else
        groupId=${coordinate%:*}
        artifactId=${coordinate##*:}
    fi

    local APP_VERSION=`curl -s "${ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${artifactId}&repos=libs-releases"`
    local PROPERTIES_VERSION=`curl -s "${ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${app}-properties&repos=libs-releases"`

    APP_VERSIONS[${app}]="${APP_VERSION}-${PROPERTIES_VERSION}"
}

function shoehorn {
    local goal="$1" version env app

    if [ -z "$2" ]
    then
        echo "usage: ${GOAL} application [version] [environment]"
        return 1
    else
        app="$2"
    fi

    if [ -z "$3" ]
    then
        get_latest_version ${app}
        version=${APP_VERSIONS[$app]}
    else
        version="$3"
    fi

    if [ -z "$4" ]
    then
        env="dev"
    else
        env="$4"
    fi

    mvn shoehorn:${goal} -DapplicationName=${app} -Dversion=${version} -DenvironmentName=${env}
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

function listAppCompletions {
    local ret=1 state context state_descr line
    _arguments ':app:->app' ':version:->version' ':env:->env' && ret=0

    case $state in
        app)
            apps=(
              "aview:AView"
              "ffestiniog:Ffestiniog"
              "gruffalo:Gruffalo"
              "hector:Hector"
              "kiki:Kiki"
              "luthor:Luthor"
              "optimusprimer:Optimus Primer"
              "raiden:Raiden"
              "redqueen:Red Queen"
              "shovel:Shovel"
              "spm-sat:Superman Show-and-Tell"
              "superman:Superman"
            )
            _describe -t apps 'shoehorn apps' apps && ret=0
            ;;
        version)
            local selected_app="${words[2]}"

            if [ "${COMPLETION_LAST_SELECTED_APP}" != "${selected_app}" ]
            then
                COMPLETION_LAST_SELECTED_APP="${selected_app}"
                get_latest_version ${selected_app}
            fi

            versions=(
                "DEV-SNAPSHOT:Deploy the DEV-SNAPSHOT version of ${selected_app}"
                "${APP_VERSIONS[$selected_app]}:Deploy the latest version of ${selected_app}"
            )
            _describe -t versions 'shoehorn versions' versions && ret=0
            ;;
        env)
            envs=(
                "dev"
                "dev2"
            )
            _describe -t envs 'shoehorn envs' envs && ret=0
            ;;
    esac

    return ret
}

for cmd in \
    deploy \
    deploy-snapshot \
    start \
    start-snapshot \
    stop \
    stop-snapshot \
    clean \
    clean-snapshot \
    status \
    status-snapshot
do
    compdef listAppCompletions ${cmd}
done
