#!/bin/bash -x

script_dir=$(readlink -f `dirname $0`)

# setup
rm -f $script_dir/snm.tar

case $(uname -m) in
  armv7*) build_dir=arm
  ;;
  *) build_dir=x86_64
  ;;
esac

# build base
cd ${script_dir}/pre-install/${build_dir}
docker build -t snm:base .

# run base and do snm install
docker run -it --name snm-build -w /tmp/snm snm:base perl install.pl
docker start snm-build
docker exec snm-build rm -rf /tmp/snm
docker stop snm-build

# build final image
cd $script_dir
docker export -o snm.tar snm-build
docker build -t snm:latest .

# cleanup
cd $script_dir
rm snm.tar
docker rm snm-build
docker rmi snm:base
