function _print_if_no_pipe {
    if [ -t 1 ]; then
        echo $@
    fi
}

function _run_shoehorn {
    local shoehorn_filename="shoehorn-${_SHOEHORN_VERSION}-jar-with-dependencies.jar"
    local shoehorn_jar_path="${TMPDIR}/${shoehorn_filename}"
    echo "shoehorn jar path: "
    echo $shoehorn_jar_path

    _print_if_no_pipe "${_BOLD}${_TEXT_YELLOW}Using Shoehorn version ${_SHOEHORN_VERSION}${_RESET_FORMATTING}"

    if [ ! -f ${shoehorn_jar_path} ]; then
        _print_if_no_pipe "${_BOLD}${_TEXT_YELLOW}Downloading Shoehorn...${_RESET_FORMATTING}"
        curl -s "${_ARTIFACTORY}/${_ARTIFACTORY_REPOSITORY}/sonique/shoehorn/shoehorn/${_SHOEHORN_VERSION}/${shoehorn_filename}" -o ${shoehorn_jar_path}
        _print_if_no_pipe "${_BOLD}${_TEXT_YELLOW}Done${_RESET_FORMATTING}"
    fi

    java -cp ${shoehorn_jar_path} $@
}

function shoehorn {
    local goal version env app

    if [ -z "$1" ]; then
        echo "Usage: $0 {deploy|start|stop|status|clean} application [version] [environment]"
        return 1
    else
        goal="$1"
    fi

    if [ -z "$2" ]; then
        echo "Usage: ${goal} application [version] [environment]"
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

        _run_shoehorn shoehorn.ShoehornWrapper -app ${app} -compositeVersion ${version} -environment ${env}

        return $?
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
            local status_script="${app_dir}/status.sh"
            if [ -f ${status_script} ]; then
                ${status_script} -p 1>/dev/null
                local exit_code=$?
            else
                local exit_code=255
            fi

            if [ ${exit_code} = 0 ]; then
                echo "Cannot clean ${app} [${env}-${version}] while it's running"
            else
                rm -rf ${app_dir} ${log_dir} && echo "Cleaned ${app} [${env}-${version}]"
            fi
            ;;
        *)
            echo "Usage: $0 {deploy|start|stop|status|clean}"
            return 1
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

function encrypt {
    _run_shoehorn shoehorn.Encrypt $@
}

function decrypt {
    _run_shoehorn shoehorn.Decrypt $@
}

function applog {
    local app="$1"
    local version="$2"
    local logfile="$3"

    if [[ -z ${app} || -z ${version} || -z ${logfile} ]]; then
        echo "Usage: $0 app version logfile"
        return 1
    fi

    less "/logs/apps/${app}/${version}/${logfile}"
}

function appout {
    local app="$1"
    local version="$2"

    if [[ -z ${app} || -z ${version} ]]; then
        echo "Usage: $0 app version"
        return 1
    fi

    less "/data/apps/${app}/${version}/${app}.out"
}

function list-deployed-apps {
    local -a app_dirs
    app_dirs=("${(@f)$(find /data/apps -depth 2 | sed 's/\/data\/apps\///g')}")

    local -A apps

    for app_dir in ${app_dirs}; do
        local app="${app_dir%%/*}"
        local version="${app_dir#*/}"

        if [ -z ${apps[$app]} ]; then
            apps[$app]=""
        fi

        apps[$app]+="$version "
    done

    for app in "${(@k)apps}"; do
        echo "${_BOLD}${_TEXT_YELLOW}${app}${_RESET_FORMATTING}:"
        local -a app_versions
        app_versions=("${(s: :)apps[$app]}")

        for app_version in ${app_versions}; do
            local status_script="/data/apps/${app}/${app_version}/status.sh"

            if [ ! -f ${status_script} ]; then
                continue
            fi

            local description="${app_version}"

            ${status_script} -p 1>/dev/null
            local exit_code=$?

            if [ ${exit_code} = 0 ]; then
                 description+=" ${_BOLD}${_TEXT_WHITE}(running)${_RESET_FORMATTING}"
            fi

            printf '- %s\n' ${description}
        done
    done
}
