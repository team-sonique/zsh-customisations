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