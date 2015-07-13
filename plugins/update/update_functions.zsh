local UPDATE_AUDIT_FILE='.sonique_lastupdate'

function updateSoniqueEnvironment() {
    echo "Updating environment"
    git -C ${ZDOTDIR} pull origin master

    echo "Removing Applications that will be reinstalled via brew Casks"
    removeNonBrewApplications

    echo "Updating homebrew"
    brew update && brew upgrade
    brew tap homebrew/bundle && brew bundle --verbose --file=${ZDOTDIR}/Brewfile

    echo "Updating antigen bundles"
    antigen update

    echo "Resetting symlinks"
    setLinks

    $(date +%s > ~/${UPDATE_AUDIT_FILE})
    echo "\n\n${RED}You will need to reopen a terminal session to benefit from any updates"
}

function uninstallHomebrewCasks() {
    brew cask list | xargs brew cask uninstall
    brew cask cleanup
}

function uninstallHomebrewFomulae() {
    brew list | xargs brew uninstall
    brew cleanup
}

function removeHomebrewTaps() {
    brew tap | xargs brew untap
}

function removeHomebrew() {
    uninstallHomebrewCasks
    uninstallHomebrewFomulae
    removeHomebrewTaps

    rm -rf /usr/local/Cellar /usr/local/.git
    brew cleanup
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
}

function removeNonBrewApplications() {
    for app in 'Dropbox' 'Atom' 'Firefox' 'IntelliJ IDEA 14' 'TextMate' 'Google Chrome' 'iTerm' 'SourceTree' 'Microsoft Lync'; do

        local appPath="/Applications/${app}.app"
        if [ -e ${appPath} ] && [ ! -h ${appPath} ]; then
            echo "Removing ${app}"
            sudo rm -rf  ${appPath}
        fi
    done
}

function timeSinceLastUpdate() {
    local now=$(date +%s)
    local last_update

    if [ -f ~/${UPDATE_AUDIT_FILE} ]; then
        last_update=$(cat ~/${UPDATE_AUDIT_FILE})
    else
        last_update=0
    fi
    echo $(expr ${now} - ${last_update})
}

function startUpdateProcess () {
    local updateThresholdDays=${1:-1}
    local day_seconds=$(expr 24 \* 60 \* 60)
    local update_frequency=$(expr ${day_seconds} \* ${updateThresholdDays})
    local time_since_update=$(timeSinceLastUpdate)
    local line

    if [ ${time_since_update} -gt ${update_frequency} ]; then
        echo "It has been $(expr ${time_since_update} / ${day_seconds}) days since your environment was updated"
        echo "Would you like to check for updates? [Y/n]: \c"
        read line
        if [ "$line" = Y ] || [ "$line" = y ]; then
            updateSoniqueEnvironment
        fi
    fi
}

function update_cleanup() {
    unfunction timeSinceLastUpdate
    unfunction startUpdateProcess

    unfunction $0
}
