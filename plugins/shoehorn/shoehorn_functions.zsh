function _print_if_no_pipe {
    if [ -t 1 ]; then
        echo $@
    fi
}

function _run_shoehorn {
    local shoehorn_filename="shoehorn-${_SHOEHORN_VERSION}-jar-with-dependencies.jar"
    local shoehorn_jar_path="${TMPDIR}/${shoehorn_filename}"

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

    if [ ${goal} = "deploy" ]; then
        if [ -d ${app_dir} ]; then
            echo "${app} [${env}-${version}] already deployed at ${app_dir}, skipping"
            return 0
        fi

        _run_shoehorn shoehorn.ShoehornWrapper -app ${app} -compositeVersion ${version} -environment ${env}

        return $?
    fi

    if [ -n _is_docker_image ]; then
        case ${goal} in
            start)
                _start_docker_app ${app}
                return 0
                ;;
            stop)
                _stop_docker_app ${app}
                return 0;
                ;;
            clean)
                _clean_docker_app ${app}
                return 0;
                ;;
            status)
                _status_docker_app ${app}
                return 0
                ;;
        esac
    else
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
                    local log_dir="/logs/apps/${app}/${env}-${version}"
                    rm -rf ${app_dir} ${log_dir} && echo "Cleaned ${app} [${env}-${version}]"
                fi
                ;;
            *)
                echo "Usage: $0 {deploy|start|stop|status|clean}"
                return 1
                ;;
        esac
    fi
}

function _is_docker_image {
    local app_name=$1
    return $(docker images | grep $app_name)
}

function _start_docker_app {
    local app_name=$1
    docker start $app_name > /dev/null

    if [[ $? -eq 0 ]]; then
        echo "$app_name started"
        return 0
    else
        echo "$app_name failed to start"
        return 1
    fi
}

function _stop_docker_app {
    local app_name=$1
    docker stop --time=10 $app_name > /dev/null

    if [[ $? -eq 0 ]]; then
        echo "$app_name stopped"
        return 0
    else
        echo "$app_name failed to stop"
        return 1
    fi
}

function _clean_docker_app {
    local app_name=$1
    docker rm -f $app_name
    return 0
}

function _status_docker_app {
    local app_name=$1
    output=$(docker inspect --format='{{ .State.Status }}' $app_name 2> /dev/null)

    if [[ $? -eq 1 ]]; then
        echo "$app_name does not exist"
    else
        echo "$app_name is $output"
    fi

    return 0
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

    if [ _is_docker_image=1 ]; then
        docker logs ${app}
        return 1;
    fi

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

    local -a docker_apps
    IFS=$'\n'
    docker_apps=($(docker ps -a | awk 'FNR > 1 {print $2}'))
    for docker_app in ${docker_apps}; do

        if [[ $docker_app == *'/'* ]]; then
            IFS=/ read repo group app_image <<< ${docker_app}
        else
            app_image=${docker_app}
        fi

        IFS=: read image version <<< ${app_image}
        echo "${_BOLD}${_TEXT_YELLOW}$image${_RESET_FORMATTING}:"

        local description=${version}

        $(docker inspect --format='{{ .State.Running }}' $image)
        if [ $? -eq 0 ]; then
            description+=" ${_BOLD}${_TEXT_WHITE}(running)${_RESET_FORMATTING}"
        fi

        printf '- %s\n' ${description}
    done
}
