# Sets the name of your OS X Terminal Tab
function tabname {
    if [ -z $1 ]
    then
        export DISABLE_AUTO_TITLE="false"
    else
        export DISABLE_AUTO_TITLE="true"
        printf "\e]1;$1\a"
        if [ ! -z $2 ]
        then
            printf "\e]2;$2\a"
        fi
    fi
}

function goJava6 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
}

function goJava7 {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
}

function goJava8 {
    if [ -z $1 ]
    then
        export JAVA_HOME=`/usr/libexec/java_home -v '1.8'`
    else
        export JAVA_HOME=`/usr/libexec/java_home -v "1.8.0_$1"`
    fi
}

function gclone {
    git clone https://git.sns.sky.com/team-sonique/$1.git
}

function setLinks {
    {
        function $0_link {
            local target=$1
            local link_name=$2

            if [ -e ${target} ]; then
                mkdir -p ${link_name%/*}

                if [ -e ${link_name} ]; then
                    rm -rf ${link_name}
                fi
                ln -sfnv ${target} ${link_name}
            fi
        }

        for linky in `ls $ZDOTDIR/dotfiles`
        do
          $0_link ${ZDOTDIR}/dotfiles/${linky} ~/.${linky}
        done

        $0_link ~/.m2/repository ~/repository
        $0_link ${ZDOTDIR}/sonique-maven-settings.xml ~/.m2/settings.xml

    } always {
        unfunction $0_link
    }
}

function rebuildDatabase {
    mvn package -pl ${PWD##*/}-sql -PrebuildDatabase
}

function upgradeDatabase {
    mvn package -pl ${PWD##*/}-sql -PupgradeDatabase
}

function startDatabases {
    startDockerDatabase
    startVdcDatabase
}

function startDockerDatabase {
    local app_name='oracle-12c'
    output=$(docker inspect --format='{{ .State.Status }}' $app_name 2> /dev/null)

    if [[ $? -eq 1 ]]; then
        echo 'Creating local Docker database for Mobile apps'
        docker run --name oracle-12c -d -p 1521:1521 -p 5500:5500 --shm-size=4g --restart=unless-stopped --net=sonique-network --net-alias=oracle-12c repo.sns.sky.com:8085/sns-is-dev/oracle-12c:125 > /dev/null
    else
        if [[ $output == 'running' ]]; then
            #do nothing
        else
            echo 'Starting local Docker database for Mobile apps'
            docker start oracle-12c > /dev/null
        fi
    fi
    echo "Docker database for Mobile apps running on jdbc:oracle:thin:@//localhost:1521/db1"
}

function startVdcDatabase {
    local app_name='oracle-12c-vdc'
    output=$(docker inspect --format='{{ .State.Status }}' $app_name 2> /dev/null)

    if [[ $? -eq 1 ]]; then
        echo 'Creating local Docker database for VDC apps'
        docker run --name oracle-12c-vdc -d -p 1525:1521 -p 5505:5500 --shm-size=2g --restart=unless-stopped --net=sonique-network --net-alias=oracle-12c-vdc repo.sns.sky.com:8085/dost/oracle-12c-vdc:73 > /dev/null
    else
        if [[ $output == 'running' ]]; then
            #do nothing
        else
            echo 'Starting local Docker database for VDC apps'
            docker start oracle-12c-vdc > /dev/null
        fi
    fi
    echo "Docker database for VDC apps running on jdbc:oracle:thin:@//localhost:1525/db1"
}

function startHazelcast {
    local app_name='hazelcast'
    output=$(docker inspect --format='{{ .State.Status }}' $app_name 2> /dev/null)

    if [[ $? -eq 1 ]]; then
        echo 'Creating local Hazelcast Instance'
        docker run --name hazelcast -d -p 5701:5701 --net=sonique-network --net-alias=hazelcast hazelcast/hazelcast > /dev/null
    else
        if [[ $output == 'running' ]]; then
            #do nothing
        else
            echo 'Starting local Hazelcast Instance'
            docker start hazelcast > /dev/null
        fi
    fi
    echo "Hazelcast Instance running at 127.0.0.1:5701"
}

function runBattenbergLoaderJob {
    local battenberg_loader_version=$1
    if [ -e ${battenberg_loader_version} ]; then
        battenberg_loader_version=$(curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=sonique.battenberg&a=battenberg-loader&repos=libs-releases-local")
    fi
    echo "Running Battenberg Loader Job version $battenberg_loader_version"
    ip_addr=$(ipconfig getifaddr en0)

    (set -x; docker run --rm --name battenberg-loader --net=sonique-network --net-alias=battenberg-loader -v /data:/app/data  -e "cluster.host=sonique-cluster.sns.sky.com" -e "npr.volume.mount.path=/app/npr" -e "replicas=3" -e "npr.volume.host.server=vm002544.bskyb.com" -e "repo.host=repo.sns.sky.com" -e "npr.volume.host.path=/home/sonique/nfs/npr" -e "npr.volume.name=npr-ftp" -e "limits.memory=4Gi" -e "nodePort=30030" -e "repo.port=8085" -e "jdbc.transaction.context.factory.class=sonique.sql.transaction.factory.OracleTransactionContextFactory" -e "service.summary.status.path=status" -e "app.data.integrity.ignore.window.mins=15" -e "app.data.retention.period.in.days=30" -e "loader.schedule=*/1 * * * *" -e "jdbc.connection.user=battenberg_user" -e "app.file.directory=/app/data/npr" -e "jdbc.connection.password=battenberg" -e "jdbc.connection.url=jdbc:oracle:thin:@//oracle-12c-vdc:1521/db1" -e "app.port=8087" -e "jdbc.connection.driver=oracle.jdbc.pool.OracleDataSource" -e "database.edition=BATTENBERG_2" -e "service.summary.lookup.path=service" -e "service.summary.base.uri=http://$ip_addr:11565/repoman/" -e "app.expected.file.receival.time=11:00:00" -e TZ=Europe/London repo.sns.sky.com:8085/sns-is-dev/battenberg-loader:$battenberg_loader_version)
}

function runBullwinkleWriterJob {
    local bullwinkle_writer_version=$1
    if [ -e ${bullwinkle_writer_version} ]; then
        bullwinkle_writer_version=$(curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=sonique.bullwinkle&a=bullwinkle-file-writer&repos=libs-releases-local")
    fi
    echo "Running Bullwinkle File Writer Job version $bullwinkle_writer_version"

    (set -x; docker run --rm --name bullwinkle-file-writer --net=sonique-network --net-alias=bullwinkle-file-writer -v /data:/app/data -e "jdbc.transaction.context.factory.class=sonique.sql.transaction.factory.OracleTransactionContextFactory" -e "app.maxEntries=30000" -e "app.port=8080" -e "app.notificationDeliveryAttemptLimit=5" -e "app.requestTimeoutInMinutes=5" -e "jdbc.connection.user=bullwinkle_user" -e "jdbc.connection.url=jdbc:oracle:thin:@//oracle-12c:1521/db1" -e "jdbc.connection.password=bullwinkle" -e "jdbc.connection.driver=oracle.jdbc.pool.OracleDataSource" -e "database.edition=BULLWINKLE_6" -e TZ=Europe/London -e "tuk.record.actionUnblock=R" -e "tuk.record.operator=SKY" -e "tuk.record.blockReasonCode=0011" -e "tuk.record.filePrefix=SKY_CEIR_" -e "tuk.record.unblockSource=Removed on behalf of Sky" -e "tuk.record.headerIdentifier=10" -e "tuk.record.recordSpecificationVersion=01" -e "tuk.record.createdDatePattern=yyMMdd" -e "tuk.record.colouredList=B" -e "tuk.record.unblockReasonCode=0014" -e "tuk.record.actionBlock=I" -e "tuk.record.blockSource=Blocked on behalf of Sky" -e "tuk.record.organisationId=GBRKY" -e "tuk.record.bodyIdentifier=55" -e "tuk.record.destinationDir=/app/data/ftphome/ceir/tuk/tukceir01" -e "tuk.record.footerIdentifier=90" -e "tuk.record.fileExtension=UPD" repo.sns.sky.com:8085/sns-is-dev/bullwinkle-file-writer:$bullwinkle_writer_version)
}

function runBullwinkleReaderJob {
    local bullwinkle_reader_version=$1
    if [ -e ${bullwinkle_reader_version} ]; then
        bullwinkle_reader_version=$(curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=sonique.bullwinkle&a=bullwinkle-file-reader&repos=libs-releases-local")
    fi
    echo "Running Bullwinkle File Reader Job version $bullwinkle_reader_version"

    (set -x; docker run --rm --name bullwinkle-file-reader --net=sonique-network --net-alias=bullwinkle-file-reader -v /data:/app/data -e "jdbc.transaction.context.factory.class=sonique.sql.transaction.factory.OracleTransactionContextFactory" -e "jdbc.connection.user=bullwinkle_user" -e "jdbc.connection.url=jdbc:oracle:thin:@//oracle-12c:1521/db1" -e "jdbc.connection.password=bullwinkle" -e "jdbc.connection.driver=oracle.jdbc.pool.OracleDataSource"  -e "database.edition=BULLWINKLE_6" -e TZ=Europe/London -e "tuk.record.filePrefix=SKY_CEIR_" -e "file.retentionPeriodInDays=7" -e "tuk.record.destinationDir=/app/data/ftphome/ceir/tuk/tukceir01" repo.sns.sky.com:8085/sns-is-dev/bullwinkle-file-reader:$bullwinkle_reader_version)
}

function runBullwinkleNotifierJob {
    local bullwinkle_notifier_version=$1
    if [ -e ${bullwinkle_notifier_version} ]; then
        bullwinkle_notifier_version=$(curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=sonique.bullwinkle&a=bullwinkle-notifier&repos=libs-releases-local")
    fi
    echo "Running Bullwinkle Notifier Job version $bullwinkle_notifier_version"
    (set -x; docker run --rm --name bullwinkle-notifier '--net=sonique-network' '--net-alias=bullwinkle-notifier' -v /data:/app/data -e 'jdbc.transaction.context.factory.class=sonique.sql.transaction.factory.OracleTransactionContextFactory' -e 'jdbc.connection.user=bullwinkle_user' -e 'jdbc.connection.url=jdbc:oracle:thin:@//oracle-12c:1521/db1' -e 'jdbc.connection.password=bullwinkle' -e 'jdbc.connection.driver=oracle.jdbc.pool.OracleDataSource' -e 'database.edition=BULLWINKLE_6' -e TZ=Europe/London -e 'operator.port=11565' -e "operator.hostAddress=http://docker.for.mac.localhost" -e 'operator.writeEndpoint=/troll/llustreamplus/web/showAndTellController.html' -e 'operator.statusEndpoint=/troll/status' -e "app.maxEntries=30000" -e "app.port=8080" -e "app.notificationDeliveryAttemptLimit=5" -e "app.requestTimeoutInMinutes=5" repo.sns.sky.com:8085/sns-is-dev/bullwinkle-notifier:$bullwinkle_notifier_version)
}

function runBullwinkleStaleRequestsJob {
    local bullwinkle_stale_requests_version=$1
    if [ -e ${bullwinkle_stale_requests_version} ]; then
        bullwinkle_stale_requests_version=$(curl -s "${_ARTIFACTORY}/api/search/latestVersion?g=sonique.bullwinkle&a=bullwinkle-stale-requests&repos=libs-releases-local")
    fi
    echo "Running Bullwinkle Stale Requests Job version $bullwinkle_stale_requests_version"
    (set -x; docker run --rm --name bullwinkle-stale-requests '--net=sonique-network' '--net-alias=bullwinkle-stale-requests' -v /data:/app/data -e 'jdbc.transaction.context.factory.class=sonique.sql.transaction.factory.OracleTransactionContextFactory' -e 'jdbc.connection.user=bullwinkle_user' -e 'jdbc.connection.url=jdbc:oracle:thin:@//oracle-12c:1521/db1' -e 'jdbc.connection.password=bullwinkle' -e 'jdbc.connection.driver=oracle.jdbc.pool.OracleDataSource' -e 'database.edition=BULLWINKLE_6' -e TZ=Europe/London -e 'operator.port=11565' -e "operator.hostAddress=http://docker.for.mac.localhost" -e 'operator.writeEndpoint=/troll/llustreamplus/web/showAndTellController.html' -e 'operator.statusEndpoint=/troll/status' -e "app.maxEntries=30000" -e "app.port=8080" -e "app.notificationDeliveryAttemptLimit=5" -e "app.requestTimeoutInMinutes=5" repo.sns.sky.com:8085/sns-is-dev/bullwinkle-stale-requests:$bullwinkle_stale_requests_version)
}

function say {
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
    echo "SHUT UP Benjamin!!!"
}
