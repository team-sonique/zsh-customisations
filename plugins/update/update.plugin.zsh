UPDATE_AUDIT_FILE='.sonique_lastupdate'

if [ -z "$SONIQUE_UPDATE_DAYS" ]; then
  SONIQUE_UPDATE_DAYS=1
fi

function _check_interval() {
  now=$(date +%s)
  if [ -f ~/${UPDATE_AUDIT_FILE} ]; then
    last_update=$(cat ~/${UPDATE_AUDIT_FILE})
  else
    last_update=0
  fi
  interval=$(expr ${now} - ${last_update})
  echo ${interval}
}

function updateSoniqueEnvironment() {
  echo "Updating environment"
  git -C ${ZDOTDIR} pull origin master

  echo "Removing Applications that will be reinstalled via brew Casks"
  removeNonBrewApplications

  echo "Updating homebrew"
  brew update && brew upgrade
  brew tap homebrew/bundle && brew bundle --file=${ZDOTDIR}/Brewfile

  echo "Updating antigen bundles"
  antigen update

  echo "Resetting symlinks"
  setLinks

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
  for app in 'Dropbox' 'Atom' 'Firefox' 'IntelliJ IDEA 14' 'TextMate'
  do
    if [ -f /Applications/${app}.app ]; then
      echo "Removing ${app}"
      rm -rf  /Applications/${app}.app
    fi
  done
}

day_seconds=$(expr 24 \* 60 \* 60)
update_frequency=$(expr ${day_seconds} \* ${SONIQUE_UPDATE_DAYS})
time_since_update=$(_check_interval)

if [ ${time_since_update} -gt ${update_frequency} ]; then
  echo "It has been $(expr ${time_since_update} / ${day_seconds}) days since your environment was updated"
  echo "Would you like to check for updates? [Y/n]: \c"
  read line
  if [ "$line" = Y ] || [ "$line" = y ]; then
    updateSoniqueEnvironment
  fi

  $(date +%s > ~/${UPDATE_AUDIT_FILE})
fi

# clean up after ourselves
unset UPDATE_AUDIT_FILE
unset ANTIGEN_UPDATE_DAYS
unset day_seconds
unset update_frequency
unset time_since_update

unset -f _check_interval
