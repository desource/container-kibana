#!/usr/bin/env sh
set -eux

# KIBANA_VERSION=4.5.1
# KIBANA_SHA1=355c631b77c529d3dea304d7f084e658f5cc3123
KIBANA_VERSION=4.5.1
KIBANA_SHA1=355c631b77c529d3dea304d7f084e658f5cc3123

BASE=$PWD
SRC=$PWD/src
OUT=$PWD/out
ROOTFS=$PWD/rootfs

mkdir -p $OUT $ROOTFS/opt/kibana
cd $BASE
curl -sOL https://download.elastic.co/kibana/kibana/kibana-$KIBANA_VERSION-linux-x64.tar.gz
echo "$KIBANA_SHA1  kibana-$KIBANA_VERSION-linux-x64.tar.gz" | sha1sum -c
tar -xf kibana-$KIBANA_VERSION-linux-x64.tar.gz -C $ROOTFS/opt/kibana --strip-components 1

rm -rf $ROOTFS/opt/kibana/node $ROOTFS/opt/kibana/bin
chown -R root:root $ROOTFS/opt
chown -R nobody:root $ROOTFS/opt/kibana/optimize

cd $ROOTFS
tar -cf $OUT/rootfs.tar .

cat <<EOF > $OUT/Dockerfile
FROM quay.io/desource/nodejs

ADD rootfs.tar /

EXPOSE 5601

USER nobody

WORKDIR /opt/kibana

ENTRYPOINT ["/usr/bin/node", "src/cli"]

EOF

