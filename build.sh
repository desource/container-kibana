#!/usr/bin/env sh
set -eux

KIBANA_VERSION=4.5.1
KIBANA_SHA1=355c631b77c529d3dea304d7f084e658f5cc3123

BASE=$PWD
SRC=$PWD/src
OUT=$PWD/kibana-build
ROOTFS=$PWD/rootfs

mkdir -p $OUT
mkdir -p $ROOTFS

curl -sL https://github.com/gliderlabs/docker-alpine/blob/rootfs/library-edge/versions/library-edge/rootfs.tar.gz?raw=true -o rootfs.tar.gz

tar -xf rootfs.tar.gz -C $ROOTFS

mv $ROOTFS/etc/localtime $ROOTFS/usr/share/zoneinfo
ln -s /usr/share/zoneinfo $ROOTFS/etc/localtime 

mkdir -p $ROOTFS/opt/kibana
cd $BASE
curl -sL https://download.elastic.co/kibana/kibana/kibana-$KIBANA_VERSION-linux-x64.tar.gz -o kibana-$KIBANA_VERSION-linux-x64.tar.gz
echo "$KIBANA_SHA1  kibana-$KIBANA_VERSION-linux-x64.tar.gz" | sha1sum -c
tar -xf kibana-$KIBANA_VERSION-linux-x64.tar.gz -C $ROOTFS/opt/kibana --strip-components 1

rm -rf $ROOTFS/opt/kibana/node $ROOTFS/opt/kibana/bin

cd $ROOTFS
tar -cf $OUT/rootfs.tar .

cat <<EOF > $OUT/Dockerfile
FROM scratch

ADD rootfs.tar /

RUN apk add --no-cache nodejs

ENV NODE_ENV=production

USER nobody

EXPOSE 5601

WORKDIR /opt/kibana

ENTRYPOINT ["/usr/bin/node", "src/cli"]

EOF
