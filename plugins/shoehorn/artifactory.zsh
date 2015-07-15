_ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"
_ARTIFACTORY_REPOSITORY="libs-releases-local"

function _get_latest_version {
    local -A artifact_coordinates
    artifact_coordinates=(
        gruffalo "sonique.gruffalo:gruffalo-build"
        ffestiniog "sonique.ffestiniog:ffestiniog-core"
        spm-sat "sonique.spm-sat:spm-sat-core"
        redqueen "sonique.redqueen:redqueen-core"
        superman "sky.sns:superman-deploy"
        luthor "sonique.luthor:luthor-core"
    )

    local app="$1"
    local coordinate=${artifact_coordinates[$app]}

    if [ -z ${coordinate} ]; then
        local groupId="sonique.${app}"
        local artifactId="${app}-deploy"
    else
        local groupId=${coordinate%:*}
        local artifactId=${coordinate##*:}
    fi

    {
        function fetch_latest_version {
            curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=$1&a=$2&repos=${_ARTIFACTORY_REPOSITORY}"
        }

        local app_version=$(fetch_latest_version ${groupId} ${artifactId})
        local properties_version=$(fetch_latest_version ${groupId} "${app}-properties")

        echo "${app_version}-${properties_version}"
    } always {
        unfunction fetch_latest_version
    }
}
