# Build instructions for SNM docker container

The install process for SNM can not be done unattended, it requires the user to answer some prompts
during the SNM install.pl script execution. (The script continuously loops through the interactive part,
I don't thing Docker gives it any concept of STDIN) Because of that, we can't create the docker image
in a single Dockerfile.

In an effort to automate the steps, and support different architectures, the process has been wrapped
up in the `build.sh` script.  It currently supports arm and x86_64 architectures.  Simply run the script
and answer the prompts when they come up.

The goal is to have a minimally useful monitoring system out of the box.  This means that ping times to
your router's WAN interface as well as the ISP's router will be automatically gatherered and graphed,
as well as the apache stats from inside the container.  More complex setups can be done by customizing the 
SNM config files under /etc/opt/snm/.  See http://snm.sourceforge.net/operate.html for reference.

### TODOs
  * Persistent storage for the rrd database (and config files?) (maybe just re-starting the container is enough?)

### Helpful notes
  * template `frequency` settings may need to be some exact multiple of the default frequency in config.xml
    (If you see `Error while creating <rrd file>: Invalid row count xxx.y: value has trailing garbage` that's a good indicator of the problem)

### Example RUN command
docker run -d -p 8888:80 --name snm-test \
 -e ROUTER_IP=$(ip route list match 8.8.8.8/32 | head -1 | awk '{print $3}') \
 -e WAN_IP=$(curl -s http://www.icanhazip.com) \
 -e ISP_IP=$(traceroute -nm 2 8.8.8.8 | tail -1 | awk '{print $2}') \
 -e DOCKER_IP=$(ip -o -4 addr show dev docker0 | head -1 | awk '{print$4}' | cut -d '/' -f 1) \
 snm
