#!/bin/bash
#
# this script needs a config file with the following parameters:
#

JAVA_MAJOR_VERSION=8
JAVA_SECURITY_VERSION=33
JAVA_UPDATE=16
JAVA_ARCH=arm-vfp-hflt

RUN pacman -Suy --noconfirm

wget -O /tmp/jdk-linux.tar.gz \
--no-cookies \
--no-check-certificate \
--header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u${JAVA_SECURITY_VERSION}-b${JAVA_UPDATE}/jdk-8u${JAVA_SECURITY_VERSION}-linux-arm-vfp-hflt.tar.gz"

# tar creates /opt/jdk1.8.0_06
tar -zxC /opt -f /tmp/jdk-linux.tar.gz
ln -s /opt/jdk1.8.0_0${JAVA_UPDATE} /opt/jdk8
~                  
