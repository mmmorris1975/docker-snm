#!/bin/bash -x
#  1. `cd pre-install` and `docker build -t snm:base .` to do the basic system setup
#  2. Run an interactive container from the resulting image (docker run -it --name snm-build snm:base)
#    A. execute the snm install.pl script (cd /tmp/snm && perl install.pl) and answer the questions (defaults should be fine)
#    B. delete the un-archived snm installation files (cd / && rm -rf /tmp/snm)
#  3. exit the container
#  4. `cd ..` and do a `docker export -o snm.tar snm-build` to dump the container filesystem
#  5. Run `docker build -t snm:latest .` to build the final image
#  6. Run a container from the resulting image and test (see example below)
#  7. Clean up the 'pre-install' image and container, and the snm.tar file created from the `docker export` (rm snm.tar; docker rm snm-build; docker rmi snm:base)

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
