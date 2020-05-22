#!/usr/bin/env bash

set -ex
cd ../coreos-installer-custom-partitions
rm -f rhcosinstall-initramfs.img || true
curl https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.4/latest/rhcos-4.4.3-x86_64-installer-initramfs.x86_64.img -o rhcosinstall-initramfs.img
./combine.sh
cd -

export IMAGE=rhcos-custom-installer
export TAG=${1:-latest}

echo building $IMAGE:$TAG

container=$(buildah from registry.redhat.io/ubi8/ubi-minimal)
echo "building container with id $container"
buildah config --label maintainer="David Critch <dcritch@gmail.com>" $container
buildah copy $container ../coreos-installer-custom-partitions/rhcosinstall-initramfs.img /rhcos-installer-initramfs-custom.x86_64.img
buildah copy $container ./copy-image.sh /
buildah config --cmd /copy-image.sh $container
buildah commit --format docker $container $IMAGE:$TAG



export ROBOT_USER=gs-hosted-catalog+goldman
export ROBOT_PASSWD=V824ZJXDENA7U7LO9Q9LL6S9061ERLU539RDLIRGY2P7ZAWSAPNMTZ77TRCRGKB6
export REGISTRY=quay.io/gs-hosted-catalog
podman login -u $ROBOT_USER -p $ROBOT_PASSWD quay.io
podman tag localhost/$IMAGE:$TAG $REGISTRY/$IMAGE:$TAG
podman push $REGISTRY/$IMAGE:$TAG

