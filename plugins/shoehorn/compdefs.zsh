source "$(cd "$(dirname "$0")" && pwd)"/completion_helpers.zsh

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

compdef _list_shoehorn_completions shoehorn
compdef _list_deploy_completions deploy
compdef _list_start_stop_clean_and_status_completions start status stop clean
compdef _list_applog_completions applog
