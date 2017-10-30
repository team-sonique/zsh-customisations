_ARTIFACTORY="http://repo.sns.sky.com:8081/artifactory"
_ARTIFACTORY_REPOSITORY="libs-releases-local"

non_docker_overrides=(
    luthor
)

function _get_latest_version {
    local -A artifact_coordinates
    artifact_coordinates=(
        gruffalo "sonique.gruffalo:gruffalo-build"
        ffestiniog "sonique.ffestiniog:ffestiniog-core"
        spm-sat "sonique.spm-sat:spm-sat-core"
        redqueen "sonique.redqueen:redqueen-core"
        luthor "sonique.luthor:luthor-core"
        bullwinkle "sonique.bullwinkle:bullwinkle-core"
        sherman "sonique.sherman:sherman-core"
        dudley "sonique.dudley:dudley-core"
        rocky "sonique.rocky:rocky-dist"
        felix "sonique.felix:felix-dist"
        battenberg "charts:battenberg-chart"
        marzipan "charts:marzipan-chart"
        garibaldi "charts:garibaldi-chart"
        macaroon "charts:macaroon-chart"
        eclair "charts:eclair-chart"
    )

    local -A properties_coordinates
    properties_coordinates=(
        battenberg "sonique.battenberg:battenberg-properties"
        eclair "sonique.eclair:eclair-properties"
        garibaldi "sonique.garibaldi:garibaldi-properties"
        macaroon "sonique.macaroon:macaroon-properties"
        marzipan "sonique.marzipan:marzipan-properties"
    )

    local -A artifact_version_patterns
    artifact_version_patterns=(
        battenberg "*.*"
        eclair "*.*"
        garibaldi "*.*"
        macaroon "*.*"
        marzipan "1.*"
    )

    local app="$1"
    local repository="$2"
    local coordinate=${artifact_coordinates[$app]}
    local propertiesCoordinate=${properties_coordinates[$app]}
    local appVersionPattern=${artifact_version_patterns[$app]}

    if [ -z ${repository} ]; then
        repository=${_ARTIFACTORY_REPOSITORY}
    fi

    if [ -z ${coordinate} ]; then
        local groupId="sonique.${app}"
        local artifactId="${app}-deploy"
    else
        local groupId=${coordinate%:*}
        local artifactId=${coordinate##*:}
    fi

    if [ -z ${propertiesCoordinate} ]; then
        local propertiesGroupId="sonique.${app}"
        local propertiesArtifactId="${app}-properties"
    else
        local propertiesGroupId=${propertiesCoordinate%:*}
        local propertiesArtifactId=${propertiesCoordinate##*:}
    fi

    if [ -z ${appVersionPattern} ]; then
        local versionPattern="*"
    else
        local versionPattern=${appVersionPattern}
    fi

    {
        function fetch_latest_version {
            curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=${1}&a=${2}&v=${3}&repos=${repository}"
        }

        local app_version="$(fetch_latest_version ${groupId} ${artifactId} ${versionPattern})"
        if [[ ${app_version} =~ '"status" : 404' ]]; then
            return
        fi

        local properties_version="$(fetch_latest_version ${propertiesGroupId} ${propertiesArtifactId} ${versionPattern})"
        if [[ ${properties_version} =~ '"status" : 404' ]]; then
            return
        fi

        echo "${app_version}-${properties_version}"
    } always {
        unfunction fetch_latest_version
    }
}
