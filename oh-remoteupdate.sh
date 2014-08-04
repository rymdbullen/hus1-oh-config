#!/bin/bash
#
# this script needs a config file with the following parameters:
# REMOTE_DIR="<openhab-config-dir>"
# USER=<openhab-username>
# HOST=<openhab-ip-address>
# IPCAM_FIX_URL="<url of ipcam_fix>"
# IPCAM_DYN_URL="<url of ipcam_dyn>"
#
CONFIG_FILE="../cool.cfg"
if [ ! -f $CONFIG_FILE ]; then
  echo "${CONFIG_FILE} doesn't exist"
  exit 1
fi
source ../cool.cfg

SSH_CMD='ssh '
LOCAL_DIR="./"
CONNECTION="${USER}@${HOST}"

if [ ! -d $LOCAL_DIR/persistence ]; then
  echo "${LOCAL_DIR}/persistence doesn't exist"
  exit 1
fi
if [ ! -d $LOCAL_DIR/rules ]; then
  echo "${LOCAL_DIR}/rules doesn't exist"
  exit 1
fi
if [ ! -d $LOCAL_DIR/sitemaps ]; then
  echo "${LOCAL_DIR}/sitemaps doesn't exist"
  exit 1
fi
if [ ! -f $LOCAL_DIR/openhab.cfg ]; then
  echo "${LOCAL_DIR}/openhab.cfg doesn't exist"
  exit 1
fi

echo "Config for the connection: $CONNECTION" >&2
echo "Config for the IPCAM_FIX_URL: $IPCAM_FIX_URL" >&2
echo "Config for the IPCAM_DYN_URL: $IPCAM_DYN_URL" >&2

cd $LOCAL_DIR
git pull

echo "Executing: sync -avz -e $SSH_CMD \"$LOCAL_DIR\" $CONNECTION:\"$REMOTE_DIR\""
rsync -avz --exclude '.git' -e $SSH_CMD "$LOCAL_DIR" $CONNECTION:"$REMOTE_DIR"

#ssh $CONNECTION "sed -i 's/@@IPCAM_FIX@@/http:\/\/192.168.1.18\/snapshot.cgi?user=ser_foscam\&pwd=orvar888\&count=14/g' $REMOTE_DIR/sitemaps/hus1.sitemap"
ssh $CONNECTION "sed -i 's/@@IPCAM_FIX@@/$IPCAM_FIX_URL/g' $REMOTE_DIR/sitemaps/hus1.sitemap"
#ssh $CONNECTION "sed -i 's/@@IPCAM_DYN@@/http:\/\/192.168.1.19\/snapshot.cgi?user=ser_foscam\&pwd=orvar888\&count=14/g' $REMOTE_DIR/sitemaps/hus1.sitemap"
ssh $CONNECTION "sed -i 's/@@IPCAM_DYN@@/$IPCAM_DYN_URL/g' $REMOTE_DIR/sitemaps/hus1.sitemap"

cd -
