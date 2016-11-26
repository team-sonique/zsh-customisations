function exportHomebrewOptions() {
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
}

function updateSoniqueEnvironment {
    echo "${RED} Should use new 'updateEnvironment' command ${RED}"
    updateEnvironment
}

function updateEnvironment {
    exportHomebrewOptions

    echo "Updating environment"
    git -C ${ZDOTDIR} pull origin master

    echo "Updating homebrew"
    brew update && brew upgrade
    brew tap homebrew/bundle && brew bundle --verbose --file=${ZDOTDIR}/Brewfile

    echo "Updating antigen bundles"
    antigen update

    echo "Resetting symlinks"
    setLinks

    addSshKeys

    $(date +%s > ~/.environment_lastupdate)
    echo "\n\n${RED}You will need to reopen a terminal session to benefit from any updates"
}

function uninstallHomebrewCasks {
    brew cask list | xargs brew cask uninstall
    brew cask cleanup
}

function uninstallHomebrewFomulae {
    brew list | xargs brew uninstall
    brew cleanup
}

function removeHomebrewTaps {
    brew tap | xargs brew untap
}

function removeHomebrew {
    uninstallHomebrewCasks
    uninstallHomebrewFomulae
    removeHomebrewTaps

    rm -rf /usr/local/Cellar /usr/local/.git
    brew cleanup
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
}

function timeSinceLastUpdate {
    local now=$(date +%s)
    local last_update

    if [ -f ~/.environment_lastupdate ]; then
        last_update=$(cat ~/.environment_lastupdate)
    else
        last_update=0
    fi
    echo $(expr ${now} - ${last_update})
}

function checkForEnvUpdates {
    local url="$(git -C ${ZDOTDIR} config --get remote.origin.url)"
    local remote_version="$(git ls-remote ${url} HEAD | awk '{print $1}')"
    local local_version="$(git -C ${ZDOTDIR} rev-parse HEAD)"

    local bold=$(tput bold)
    local text_yellow=$(tput setaf 3)
    local reset_formatting=$(tput sgr0)

    if [ ${remote_version} != ${local_version} ]; then
        echo "${bold}${text_yellow}Your ${ZDOTDIR} is out of sync${reset_formatting}"
    fi
}

function startUpdateProcess {
    local updateThresholdDays=${1:-6}
    local day_seconds=$(expr 24 \* 60 \* 60)
    local update_frequency=$(expr ${day_seconds} \* ${updateThresholdDays})
    local time_since_update=$(timeSinceLastUpdate)
    local line

    echo "It has been $(expr ${time_since_update} / ${day_seconds}) days since your environment was updated"
    if [ ${time_since_update} -gt ${update_frequency} ]; then
        echo "Would you like to check for updates? [Y/n]: \c"
        read line
        if [ "${line}" = Y ] || [ "${line}" = y ]; then
            updateEnvironment
        fi
    else
        checkForEnvUpdates
    fi
}

function addSshKeys {
    if ( [ -d ${ZDOTDIR}/ssh ] ); then
        echo "Adding SSH keys"
        for identityFile in `ls ${ZDOTDIR}/ssh/*_rsa`
        do
            chmod 600 ${identityFile}
            ssh-add -K ${identityFile}
        done
    fi
}

function update_cleanup {
    unfunction timeSinceLastUpdate
    unfunction startUpdateProcess
    unfunction checkForEnvUpdates

    unfunction $0
}
