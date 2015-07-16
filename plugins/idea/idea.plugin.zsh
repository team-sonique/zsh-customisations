# taken from https://gist.github.com/chrisdarroch/7018927 and modified a bit
function idea {
    # check for where the latest version of idea is installed
    local idea="$(ls -1d /Applications/IntelliJ\ * | tail -n1)"
    local wd="$(pwd)"

    # were we given a directory?
    if [ -d "$1" ]; then
        # echo "checking for things in the working dir given"
        wd="$(ls -1d "$1" | head -n1)"
        pushd $wd > /dev/null
    fi

    # were we given a file?
    if [ -f "$1" ]; then
        # echo "opening '$1'"
        open -a "$idea" "$1"
    else
        # let's check for stuff in our working directory.
        # does our working dir have an .idea directory?
        if [ -d ".idea" ]; then
            # echo "opening via the .idea dir"
            open -a "$idea" .
        # is there an idea project file?
        elif test -n "$(find . -maxdepth 1 -name "*.ipr" -print -quit)"; then
            # echo "opening via the project file"
            open -a "$idea" "$(ls -1d *.ipr | head -n1)"
        # Is there a pom.xml?
        elif [ -f pom.xml ]; then
            # echo "importing from pom"
            open -a "$idea" "pom.xml"
        # can't do anything smart; just open idea
        else
            # echo 'cbf'
            open "$idea"
        fi
    fi
}
