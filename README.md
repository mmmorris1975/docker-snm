# Build instructions for SNM docker container

The install process for SNM can not be done unattended, it requires the user to answer some prompts
during the install.pl script execution. (The script continuously loops through the interactive part,
I don't thing Docker gives it any concept of STDIN) Because of that, we can't create the docker image
in a single Dockerfile.

The steps will go something like:
  1. `cd pre-install` and `docker build -t snm:base .` to do the basic system setup
  2. Run an interactive container from the resulting image (docker run -it --name snm-build snm:base)
    A. execute the snm install.pl script (cd /tmp/snm && perl install.pl) and answer the questions (defaults should be fine)
    B. delete the un-archived snm installation files (cd / && rm -rf /tmp/snm)
  3. exit the container
  4. `cd ..` and do a `docker export -o snm.tar snm-build` to dump the container filesystem
  5. Run `docker build -t snm:latest .` to build the final image
  6. Run a container from the resulting image and test (see example below)
  7. Clean up the 'pre-install' image and container, and the snm.tar file created from the `docker export` (rm snm.tar; docker rm snm-build; docker rmi snm:base)

### TODOs
  * Persistent storage for the rrd database (and config files?) (maybe just re-starting the container is enough?)

### Helpful notes
  * template `frequency` settings may need to be some exact multiple of the default frequency in config.xml
    (If you see `Error while creating <rrd file>: Invalid row count xxx.y: value has trailing garbage` that's a good indicator of the problem)


docker run -d -p 8888:80 --name snm-test \
 -e ROUTER_IP=$(ip route list match 8.8.8.8/32 | head -1 | awk '{print $3}') \
 -e WAN_IP=$(curl -s http://www.icanhazip.com) \
 -e ISP_IP=$(traceroute -nm 2 8.8.8.8 | tail -1 | awk '{print $2}') \
 -e DOCKER_IP=$(ip -o -4 addr show dev docker0 | head -1 | awk '{print$4}' | cut -d '/' -f 1) \
 snm
