ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"

typeset -A ARTIFACT_COORDINATES
ARTIFACT_COORDINATES[kiki]="sky.sns.kiki:kiki-core"
ARTIFACT_COORDINATES[gruffalo]="sonique.gruffalo:gruffalo-build"
ARTIFACT_COORDINATES[ffestiniog]="sonique.ffestiniog:ffestiniog-core"
ARTIFACT_COORDINATES[spm-sat]="sonique.spm-sat:spm-sat-core"
ARTIFACT_COORDINATES[redqueen]="sonique.redqueen:redqueen-core"
ARTIFACT_COORDINATES[superman]="sky.sns:superman-deploy"
ARTIFACT_COORDINATES[luthor]="sonique.luthor:luthor-core"

function get_latest_version {
    local app="$1"

    local coordinate=${ARTIFACT_COORDINATES[$app]}

    if [ -z ${coordinate} ]
    then
        local groupId="sonique.${app}"
        local artifactId="${app}-deploy"
    else
        local groupId=${coordinate%:*}
        local artifactId=${coordinate##*:}
    fi

    local app_version=`curl -s "${ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${artifactId}&repos=libs-releases"`
    local properties_version=`curl -s "${ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${app}-properties&repos=libs-releases"`

    echo "${app_version}-${properties_version}"
}

function shoehorn {
    local goal="$1"
    local version
    local env
    local app

    if [ -z "$2" ]
    then
        echo "usage: ${goal} application [version] [environment]"
        return 1
    else
        app="$2"
    fi

    if [ -z "$3" ]
    then
        version="$(get_latest_version ${app})"
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

function _shoehorn_local {
    local goal=$1
    local app=$2
    local version="${3#*-}"
    local env="${3%%-*}"

    shoehorn $goal $app $version $env
}

function deploy {
    shoehorn deploy "$@"
}

function start {
    _shoehorn_local start "$@"
}

function stop {
    _shoehorn_local stop "$@"
}

function status {
    _shoehorn_local status "$@"
}

function clean {
    _shoehorn_local clean "$@"
}

completion_apps=(
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

function listDeployCompletions {
    local ret=1
    local state
    local context
    local state_descr
    local line

    _arguments ':app:->app' ':version:->version' ':env:->env' && ret=0

    case $state in
        app)
            _describe -t completion_apps 'shoehorn apps' completion_apps && ret=0
            ;;
        version)
            local selected_app="${words[2]}"
            local version=`get_latest_version ${selected_app}`

            versions=(
                "DEV-SNAPSHOT:The DEV-SNAPSHOT version of ${selected_app}"
                "${version}:The latest version of ${selected_app}"
            )
            _describe -t versions 'shoehorn versions' versions && ret=0
            ;;
        env)
            envs=(
                "dev"
                "dev2"
                "ci"
                "cvf"
            )
            _describe -t envs 'shoehorn envs' envs && ret=0
            ;;
    esac

    return ret
}

function listStartStopCleanAndStatusCompletions {
    local ret=1
    local state
    local context
    local state_descr
    local line

    _arguments ':app:->app' ':version:->version' && ret=0

    case $state in
        app)
            _describe -t completion_apps 'shoehorn apps' completion_apps && ret=0
            ;;
        version)
            local selected_app="${words[2]}"
            local dirs="$(ls /data/apps/${selected_app})"

            versions=("${(@f)$(echo $dirs)}")

            _describe -t versions 'shoehorn versions' versions && ret=0
            ;;
    esac

    return ret
}

compdef listDeployCompletions deploy

for cmd in \
    start \
    stop \
    clean \
    status
do
    compdef listStartStopCleanAndStatusCompletions ${cmd}
done
