#!/bin/bash -e

PATCHWORK_VERSION=$1
OSARCHS=( "darwin/amd64" "linux/amd64" "linux/arm" "windows/amd64" );
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

if [ "$PATCHWORK_VERSION" = "" ]; then
    PATCHWORK_VERSION="DEV"
fi

if [ -d "$DIR/release" ]; then
    rm -rf $DIR/release/*
else
    mkdir -p $DIR/release
fi


for v in "${OSARCHS[@]}"
do
    suffix=`echo "${v}" | tr / _`
    p="patchwork-toolkit-${PATCHWORK_VERSION}_${suffix}"
    d="${DIR}/release/${p}"
    mkdir -p $d

    # Compile
    pushd $d
    gox -verbose -output="device-gateway" -osarch="${v}" github.com/patchwork-toolkit/patchwork/cmd/device-gateway
    gox -verbose -output="device-catalog" -osarch="${v}" github.com/patchwork-toolkit/patchwork/cmd/device-catalog
    gox -verbose -output="service-catalog" -osarch="${v}" github.com/patchwork-toolkit/patchwork/cmd/service-catalog
    gox -verbose -output="service-registrator" -osarch="${v}" github.com/patchwork-toolkit/patchwork/cmd/service-registrator
    popd

    # Copy configuration
    mkdir -p $d/conf/devices
    mkdir -p $d/conf/services
    cp -R ${DIR}/conf/*.json $d/conf/
    cp -R ${DIR}/conf/devices/*.json $d/conf/devices/
    cp -R ${DIR}/conf/services/*.json $d/conf/services/

    # Copy examples of agent
    mkdir $d/agent-examples
    cd ${DIR}/agent-examples && git pull && git archive master | tar -x -C $d/agent-examples

    # Copy static
    mkdir -p $d/static/
    cp -R ${DIR}/static/ctx $d/static/

    # Copy dashboard
    mkdir -p $d/static/dashboard/css
    cp -R ${DIR}/static/dashboard/css/freeboard.min.css $d/static/dashboard/css/
    mkdir -p $d/static/dashboard/img
    cp -R ${DIR}/static/dashboard/img/dropdown-arrow.png $d/static/dashboard/img/
    cp -R ${DIR}/static/dashboard/img/glyphicons-halflings-white.png $d/static/dashboard/img/
    cp -R ${DIR}/static/dashboard/img/glyphicons-halflings.png $d/static/dashboard/img/
    cp -R ${DIR}/static/dashboard/index.html $d/static/dashboard/
    mkdir -p $d/static/dashboard/js
    cp -R ${DIR}/static/dashboard/js/freeboard+plugins.min.js $d/static/dashboard/js/
    cp -R ${DIR}/static/dashboard/js/freeboard+plugins.min.js.map $d/static/dashboard/js/
    cp -R ${DIR}/static/dashboard/js/freeboard.min.js $d/static/dashboard/js/
    cp -R ${DIR}/static/dashboard/js/freeboard.min.js.map $d/static/dashboard/js/
    cp -R ${DIR}/static/dashboard/js/freeboard.plugins.min.js $d/static/dashboard/js/
    cp -R ${DIR}/static/dashboard/js/freeboard.plugins.min.js.map $d/static/dashboard/js/
    cp -R ${DIR}/static/dashboard/js/freeboard.thirdparty.min.js $d/static/dashboard/js/
    mkdir -p $d/static/dashboard/plugins/freeboard
    mkdir -p $d/static/dashboard/plugins/thirdparty
    cp -R ${DIR}/static/dashboard/plugins/freeboard/freeboard.datasources.js $d/static/dashboard/plugins/freeboard/
    cp -R ${DIR}/static/dashboard/plugins/freeboard/freeboard.widgets.js $d/static/dashboard/plugins/freeboard/
    cp -R ${DIR}/static/dashboard/plugins/thirdparty/jquery.sparkline.min.js $d/static/dashboard/plugins/thirdparty/
    cp -R ${DIR}/static/dashboard/plugins/thirdparty/justgage.1.0.1.js $d/static/dashboard/plugins/thirdparty/
    cp -R ${DIR}/static/dashboard/plugins/thirdparty/raphael.2.1.0.min.js $d/static/dashboard/plugins/thirdparty/

    # Copy docs
    cp -R ${DIR}/docs $d/

    cd $DIR && /usr/bin/zip -9 -r "${p}.zip" "$p"
    cd $DIR &&  /usr/bin/tar -zcvf "${p}.tar.gz" $p
    rm -rf $d
done

echo "DONE!"
exit 0