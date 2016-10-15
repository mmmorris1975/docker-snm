#!/bin/bash -ex

# 'readlink -f' isn't available on MacOS, but we should be able to fudge it
# by using Perl's Cwd module. (I'm not thrilled with making that dependency
# but it seems the Perl module it's everywhere I need it by default)
function resolve_dir() {
  echo $(perl -MCwd -e 'print Cwd::abs_path($ARGV[0])' $1)
}

script_dir=$(resolve_dir `dirname $0`)

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
rm -rf resources && cp -Rp ../resources .
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
