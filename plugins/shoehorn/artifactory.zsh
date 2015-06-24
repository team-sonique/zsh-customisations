_ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"
_ARTIFACTORY_REPOSITORY="libs-releases-local"

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
