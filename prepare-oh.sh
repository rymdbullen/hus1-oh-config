#!/bin/bash
#
#

##
## Setting up parameters
##
INSTALL_HABMIN=${INSTALL_HABMIN:-true}
HABMIN_VERSION=${HABMIN_VERSION:-master}
ZIP_FILE_HABMIN="habmin.zip"
DL_DIR="/root"
CURL_DL_CMD="curl --silent -k -L"

BASE_DIR="$(dirname "$(readlink -f "$0")")"
URL=$(curl --silent -kIXGET https://github.com/openhab/openhab/releases/latest | grep Location)
AFTER_SLASH=$(basename "$URL" | tr -d '\r')
VERSION_OH=${AFTER_SLASH:1}
VERSION_OH=1.7.1

echo ""
echo "Version found: ${VERSION_OH}"
echo ""


if [ -d /opt/oh-${VERSION_OH} ]; then
    echo "Doing nothing: /opt/oh-${VERSION_OH} already exist"
    exit 0
fi

if [ "${HABMIN_VERSION}" == "master" ]; then
    URL_HABMIN="https://github.com/cdjackson/HABmin/archive/master.zip"
else
    URL=$(curl --silent -kIXGET https://github.com/cdjackson/HABmin/releases/latest | grep Location)
    AFTER_SLASH=$(basename "$URL" | tr -d '\r')
    VERSION_HABMIN=${AFTER_SLASH:0}
    URL_HABMIN="https://github.com/cdjackson/HABmin/releases/download/${VERSION_HABMIN}/habmin.zip"
fi

ZIP_FILE_RUNTIME="distribution-${VERSION_OH}-runtime.zip"
ZIP_FILE_ADDONS="distribution-${VERSION_OH}-addons.zip"
ZIP_FILE_GREENT="distribution-${VERSION_OH}-greent.zip"
BASE_URL="https://github.com/openhab/openhab/releases/download/v${VERSION_OH}"
BASE_URL='https://bintray.com/artifact/download/openhab/bin'
URL_RUNTIME="${BASE_URL}/${ZIP_FILE_RUNTIME}"
URL_ADDONS="${BASE_URL}/${ZIP_FILE_ADDONS}"
URL_GREENT="${BASE_URL}/${ZIP_FILE_GREENT}"

#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

##
## prepare temp dirs
##
TMP_OH_DIR=$(mktemp -d)
TMP_HABMIN_DIR=$(mktemp -d)
mkdir ${TMP_OH_DIR}/addons-available

##
## wget OH
##
if [ ! -f ${DL_DIR}/${ZIP_FILE_RUNTIME} ]; then
    ${CURL_DL_CMD} ${URL_RUNTIME} -o ${DL_DIR}/${ZIP_FILE_RUNTIME}
fi
if [ ! -f ${DL_DIR}/${ZIP_FILE_ADDONS} ]; then
    ${CURL_DL_CMD} ${URL_ADDONS} -o ${DL_DIR}/${ZIP_FILE_ADDONS}
fi
if [ ! -f ${DL_DIR}/${ZIP_FILE_GREENT} ]; then
    ${CURL_DL_CMD} ${URL_GREENT} -o ${DL_DIR}/${ZIP_FILE_GREENT}
fi
if [ "${INSTALL_HABMIN}" == "true" ]; then
  if [ ! -f ${DL_DIR}/${ZIP_FILE_HABMIN} ]; then
    ${CURL_DL_CMD} ${URL_HABMIN} -o ${DL_DIR}/${ZIP_FILE_HABMIN}
  fi
fi

##
## unzip
##
unzip ${DL_DIR}/${ZIP_FILE_RUNTIME} -d ${TMP_OH_DIR}/
unzip ${DL_DIR}/${ZIP_FILE_GREENT}  -d ${TMP_OH_DIR}/webapps
unzip ${DL_DIR}/${ZIP_FILE_ADDONS}  -d ${TMP_OH_DIR}/addons-available

if [ "${HABMIN_VERSION}" == "master" ]; then
    unzip ${DL_DIR}/${ZIP_FILE_HABMIN} -d ${TMP_OH_DIR}/webapps
    mv ${TMP_OH_DIR}/webapps/HABmin-master ${TMP_OH_DIR}/webapps/habmin
    cd ${TMP_OH_DIR}/addons
    ADDONS=$(ls ${TMP_OH_DIR}/webapps/habmin/addons/*.jar)
    for f in ${ADDONS}
    do
        ln -s ../addons-available/$(basename ${f}) .
    done
    mv ${TMP_OH_DIR}/webapps/habmin/addons/*.jar ${TMP_OH_DIR}/addons-available/
    rmdir ${TMP_OH_DIR}/webapps/habmin/addons
else
    unzip ${DL_DIR}/${ZIP_FILE_HABMIN} -d ${TMP_OH_DIR}/
    ln -s ../addons-available/*.habmin*.jar .
    ln -s ../addons-available/org.openhab.binding.zwave-${VERSION_OH}.jar .
fi


##
## remove zip files
##
#rm ${TMP_OH_DIR}/${ZIP_FILE_RUNTIME}
#rm ${TMP_OH_DIR}/${ZIP_FILE_GREENT}
#rm ${TMP_OH_DIR}/${ZIP_FILE_ADDONS}


##
## cleanup
##
#rm -rf $TMP_OH_DIR
rm ${TMP_OH_DIR}/*.bat
chown -R openhab:openhab ${TMP_OH_DIR}

mv ${TMP_OH_DIR} /opt/oh-${VERSION_OH}

cowsay "Done preparing Openhab version ${VERSION_OH} in /opt/oh-${VERSION_OH}"
