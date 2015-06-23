_ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"
_ARTIFACTORY_REPOSITORY="libs-releases-local"
_SHOEHORN_VERSION="386"

typeset -A _ARTIFACT_COORDINATES
_ARTIFACT_COORDINATES=(
    kiki "sky.sns.kiki:kiki-core"
    gruffalo "sonique.gruffalo:gruffalo-build"
    ffestiniog "sonique.ffestiniog:ffestiniog-core"
    spm-sat "sonique.spm-sat:spm-sat-core"
    redqueen "sonique.redqueen:redqueen-core"
    superman "sky.sns:superman-deploy"
    luthor "sonique.luthor:luthor-core"
)

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

    local app_version=`curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${artifactId}&repos=${_ARTIFACTORY_REPOSITORY}"`
    local properties_version=`curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=${groupId}&a=${app}-properties&repos=${_ARTIFACTORY_REPOSITORY}"`

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

    local app_dir="/data/apps/${app}/${env}-${version}"
    local log_dir="/logs/apps/${app}/${env}-${version}"

    if [ ${goal} = "deploy" ]; then
        if [ -d ${app_dir} ]; then
            echo "${app} [${env}-${version}] already deployed at ${app_dir}, skipping"
            return 0
        fi

        local shoehorn_filename="shoehorn-${_SHOEHORN_VERSION}-jar-with-dependencies.jar"
        local shoehorn_jar_path="${TMPDIR}/${shoehorn_filename}"

        echo "Using Shoehorn version ${_SHOEHORN_VERSION}"

        if [ ! -f ${shoehorn_jar_path} ]; then
            echo "Downloading Shoehorn..."
            curl -s "${_ARTIFACTORY}/${_ARTIFACTORY_REPOSITORY}/sonique/shoehorn/shoehorn/${_SHOEHORN_VERSION}/${shoehorn_filename}" -o ${shoehorn_jar_path}
            echo "Done"
        fi

        java -jar ${shoehorn_jar_path} -app ${app} -compositeVersion ${version} -environment ${env}

        return 0
    fi

    if [ ! -d ${app_dir} ]; then
        echo "No ${app} [${env}-${version}] found"
        return 2
    fi

    case ${goal} in
        start)
            ${app_dir}/start.sh
            ;;
        stop)
            ${app_dir}/stop.sh
            ;;
        status)
            ${app_dir}/status.sh
            ;;
        clean)
            ${app_dir}/status.sh -p 1>/dev/null
            local exit_code=$?

            if [ ${exit_code} = 0 ]; then
                echo "Cannot clean ${app} [${env}-${version}] while it's running"
            else
                rm -rf ${app_dir} ${log_dir} && echo "Cleaned ${app} [${env}-${version}]"
            fi
            ;;
    esac
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

function applog {
    local app="$1"
    local version="$2"
    local logfile="$3"

    less /logs/apps/${app}/${version}/${logfile}
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
    local basedir="$1"
    local selected_app="$2"
    local dirs="$(ls /${basedir}/apps/${selected_app} 2>/dev/null)"

    versions=("${(@f)$(echo $dirs)}")

    if [ ! -z "${versions[1]}" ]; then
        _describe -t versions 'shoehorn deployed versions' versions
    fi
}

function _complete_local_envs {
    _envs=(
        "dev:localhost"
        "dev2:dev2.sns.sky.com"
        "ci:a special local environment"
        "cvf:another special local environment, wired to talk to CVF"
        "staging:another special local environment, wired to talk to PACE"
    )

    _describe -t _envs 'shoehorn envs' _envs
}

function _complete_logfiles {
    local selected_app="$1"
    local version="$2"
    local logfile_paths="$(ls /logs/apps/${selected_app}/${version} 2>/dev/null)"

    logfiles=("${(@f)$(echo $logfile_paths)}")

    if [ ! -z "${logfiles[1]}" ]; then
        _describe -t logfiles 'shoehorn app logfiles' logfiles
    fi
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
                _complete_versions_with_deployed_ones "data" ${app} && ret=0
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
            _complete_versions_with_deployed_ones "data" ${words[2]} && ret=0
            ;;
    esac

    return ret
}

function _list_applog_completions {
    local ret=1 state context state_descr line

    _arguments ':app:->app' ':version:->version' ':logfile:->logfile' && ret=0

    case ${state} in
        app)
            _complete_apps && ret=0
            ;;
        version)
            _complete_versions_with_deployed_ones "logs" ${words[2]} && ret=0
            ;;
        logfile)
            _complete_logfiles ${words[2]} ${words[3]} && ret=0
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

compdef _list_applog_completions applog
