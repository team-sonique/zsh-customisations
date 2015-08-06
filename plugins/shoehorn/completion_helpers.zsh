function _complete_app_goals {
    local -a goals
    goals=(
        "deploy:Deploy an app with Shoehorn"
        "start:Start an app with Shoehorn"
        "status:Check an app's status with Shoehorn"
        "stop:Stop an app with Shoehorn"
        "clean:Remove an app with Shoehorn"
    )

    _describe -t goals 'shoehorn app goals' goals
}

function _complete_aggregate_goals {
    local -a goals
    goals=(
        "deploy:Deploy an aggregate with Shoehorn"
        "start:Start an aggregate with Shoehorn"
        "status:Check an aggregate's status with Shoehorn"
        "stop:Stop an aggregate with Shoehorn"
        "clean:Remove an aggregate with Shoehorn"
    )

    _describe -t goals 'shoehorn aggregate goals' goals
}

function _complete_apps {
    local -a completion_apps
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

    _describe -t completion_apps 'shoehorn apps' completion_apps
}

function _complete_aggregates {
    local -a completion_aggregates
    completion_aggregates=(
        "provisioning:Kiki, Raiden, Gruffalo, Shovel"
        "landlineassurance:AView, Optimus Primer"
        "assurance:Superman, Ffestiniog, Luthor, Superman Show-and-Tell"
    )

    _describe -t completion_aggregates 'shoehorn aggregates' completion_aggregates
}

function _complete_versions_with_latest {
    local selected_app="$1"
    local -a versions

    local latest_dev_version="$(_get_latest_version ${selected_app})"

    versions=(
        "${latest_dev_version}:The latest dev version of ${selected_app} (default)"
    )

    local test_releases_repository="test-releases-local"
    local latest_signed_off_version="$(_get_latest_version ${selected_app} ${test_releases_repository})"

    if [ ! -z ${latest_signed_off_version} ]; then
        versions+=("${latest_signed_off_version}:The signed-off version of ${selected_app}")
    fi

    versions+=("DEV-SNAPSHOT:The DEV-SNAPSHOT version of ${selected_app}")

    _describe -t versions 'shoehorn latest versions' versions
}

function _complete_versions_with_deployed_ones {
    local basedir="$1"
    local selected_app="$2"
    local app_dirs="$(ls /${basedir}/apps/${selected_app} 2>/dev/null)"

    local -a versions
    versions=("${(@f)$(echo $app_dirs)}")

    if [ ! -z "${versions[1]}" ]; then
        _describe -t versions 'shoehorn deployed versions' versions
    fi
}

function _complete_versions_with_deployed_and_running_ones {
    local basedir="$1"
    local selected_app="$2"
    local -a app_dirs
    app_dirs=("${(@f)$(ls /${basedir}/apps/${selected_app} 2>/dev/null)}")

    local -a running_apps

    for app_dir in $app_dirs; do
        local status_script="/${basedir}/apps/${selected_app}/${app_dir}/status.sh"
        if [ ! -f ${status_script} ]; then
            continue
        fi

        ${status_script} -p 1>/dev/null
        local exit_code=$?

        if [ ${exit_code} = 0 ]; then
            running_apps+=($app_dir)
        fi
    done

    if [ ! -z "${running_apps[1]}" ]; then
        _describe -t running_apps 'shoehorn deployed and running versions' running_apps
    fi
}

function _complete_local_envs {
    local -a envs
    envs=(
        "dev:localhost (default)"
        "dev2:dev2.sns.sky.com"
        "ci:a special local environment"
        "cvf:another special local environment, wired to talk to CVF"
        "external-integration:another special environment, wired to talk to BT CVF and TalkTalk Saturn"
        "staging:another special local environment, wired to talk to PACE"
    )

    _describe -t envs 'shoehorn envs' envs
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
