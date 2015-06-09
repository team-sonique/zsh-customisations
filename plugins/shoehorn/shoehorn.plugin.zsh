_ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"

typeset -A _ARTIFACT_COORDINATES
_ARTIFACT_COORDINATES[kiki]="sky.sns.kiki:kiki-core"
_ARTIFACT_COORDINATES[gruffalo]="sonique.gruffalo:gruffalo-build"
_ARTIFACT_COORDINATES[ffestiniog]="sonique.ffestiniog:ffestiniog-core"
_ARTIFACT_COORDINATES[spm-sat]="sonique.spm-sat:spm-sat-core"
_ARTIFACT_COORDINATES[redqueen]="sonique.redqueen:redqueen-core"
_ARTIFACT_COORDINATES[superman]="sky.sns:superman-deploy"
_ARTIFACT_COORDINATES[luthor]="sonique.luthor:luthor-core"

function _get_latest_version {
    local app="$1"
    local coordinate=${_ARTIFACT_COORDINATES[$app]}

    if [ -z ${coordinate} ]; then
        local groupId="sonique.${app}"
        local artifactId="${app}-deploy"
    else
        local groupId=${coordinate%:*}
        local artifactId=${coordinate##*:}
    fi

    local app_version=`curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${artifactId}&repos=libs-releases"`
    local properties_version=`curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${app}-properties&repos=libs-releases"`

    echo "${app_version}-${properties_version}"
}

function shoehorn {
    local goal version env app

    if [ -z "$1" ]; then
        echo "usage: shoehorn goal application [version] [environment]"
        return 1
    else
        goal="$1"
    fi

    if [ -z "$2" ]; then
        echo "usage: ${goal} application [version] [environment]"
        return 1
    else
        app="$2"
    fi

    if [ -z "$3" ]; then
        version="$(_get_latest_version ${app})"
    else
        version="$3"
    fi

    if [ -z "$4" ]; then
        env="dev"
    else
        env="$4"
    fi

    mvn shoehorn:${goal} -DapplicationName=${app} -Dversion=${version} -DenvironmentName=${env}
}

function _shoehorn_local {
    local goal="$1"
    local app="$2"
    local version="${3#*-}"
    local env="${3%%-*}"

    shoehorn ${goal} ${app} ${version} ${env}
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

function _complete_goals {
    goals=(
        "deploy:Deploy an app with Shoehorn"
        "start:Start an app with Shoehorn"
        "status:Check an app's status with Shoehorn"
        "stop:Stop an app with Shoehorn"
        "clean:Remove an app with Shoehorn"
    )

    _describe -t goals 'shoehorn goals' goals
}

function _complete_apps {
    _completion_apps=(
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

    _describe -t _completion_apps 'shoehorn apps' _completion_apps
}

function _complete_versions_with_latest {
    local selected_app="$1"
    local version="$(_get_latest_version ${selected_app})"

    _versions=(
        "DEV-SNAPSHOT:The DEV-SNAPSHOT version of ${selected_app}"
        "${version}:The latest version of ${selected_app}"
    )

    _describe -t _versions 'shoehorn latest versions' _versions
}

function _complete_versions_with_deployed_ones {
    local selected_app="$1"
    local dirs="$(ls /data/apps/${selected_app} 2>/dev/null)"

    versions=("${(@f)$(echo $dirs)}")

    if [ ! -z "${versions[1]}" ]; then
        _describe -t versions 'shoehorn deployed versions' versions
    fi
}

function _complete_local_envs {
    _envs=(
        "dev:localhost"
        "dev2:dev.sns.sky.com"
        "ci:a special local environment"
        "cvf:another special local environment, wired to talk to CVF"
    )

    _describe -t _envs 'shoehorn envs' _envs
}

function _list_shoehorn_completions {
    local ret=1 state context state_descr line

    _arguments ':goal:->goal' ':app:->app' ':version:->version' ':env:->env'

    case ${state} in
        goal)
            _complete_goals && ret=0
            ;;
        app)
            _complete_apps && ret=0
            ;;
        version)
            local goal="${words[2]}"
            local app="${words[3]}"

            if [ "${goal}" = "deploy" ]; then
                _complete_versions_with_latest ${app} && ret=0
            else
                _complete_versions_with_deployed_ones ${app} && ret=0
            fi
            ;;
        env)
            local goal="${words[2]}"

            if [ "${goal}" = "deploy" ]; then
                _complete_local_envs && ret=0
            else
                ret=0
            fi
            ;;
    esac

    return ret
}

function _list_deploy_completions {
    local ret=1 state context state_descr line

    _arguments ':app:->app' ':version:->version' ':env:->env'

    case ${state} in
        app)
            _complete_apps && ret=0
            ;;
        version)
            _complete_versions_with_latest ${words[2]} && ret=0
            ;;
        env)
            _complete_local_envs && ret=0
            ;;
    esac

    return ret
}

function _list_start_stop_clean_and_status_completions {
    local ret=1 state context state_descr line

    _arguments ':app:->app' ':version:->version' && ret=0

    case ${state} in
        app)
            _complete_apps && ret=0
            ;;
        version)
            _complete_versions_with_deployed_ones ${words[2]} && ret=0
            ;;
    esac

    return ret
}

compdef _list_shoehorn_completions shoehorn
compdef _list_deploy_completions deploy

for cmd in start status stop clean
do
    compdef _list_start_stop_clean_and_status_completions ${cmd}
done
