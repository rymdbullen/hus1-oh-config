#!/bin/bash
#
# this script needs a config file with the following parameters:
# REMOTE_DIR="<openhab-config-dir>"
# USER=<openhab-username>
# HOST=<openhab-ip-address>
# IPCAM_FIX_URL="<url of ipcam_fix>"
# IPCAM_DYN_URL="<url of ipcam_dyn>"
# MQTT_USER="mqtt username"
# MQTT_PWD="mqtt password"
#
TEMP_DIR=`mktemp -d`
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

# copy to staging dir
echo "copy to staging dir '$TEMP_DIR'"
rsync -avz --exclude '.git' "$LOCAL_DIR" "$TEMP_DIR"

sed -i "s/@@IPCAM_FIX_URL@@/$IPCAM_FIX_URL/g" $TEMP_DIR/sitemaps/hus1.sitemap
sed -i "s/@@IPCAM_DYN_URL@@/$IPCAM_DYN_URL/g" $TEMP_DIR/sitemaps/hus1.sitemap
sed -i "s/@@HOST@@/$HOST/g" $TEMP_DIR/sitemaps/hus1.sitemap

sed -i "s/@@MQTT_USER@@/${MQTT_USER}/g" $TEMP_DIR/openhab.cfg
sed -i "s/@@MQTT_PWD@@/${MQTT_PWD}/g" $TEMP_DIR/openhab.cfg


echo "Executing: rsync -avz --exclude '.git' -e $SSH_CMD \"$TEMP_DIR\" $CONNECTION:\"$REMOTE_DIR\""
rsync -avz --exclude '.git' -e $SSH_CMD "$TEMP_DIR/" $CONNECTION:"$REMOTE_DIR"

rm -rf $TEMP_DIR

cd -
