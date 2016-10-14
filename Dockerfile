FROM scratch

MAINTAINER Me

CMD /run-snm.sh
EXPOSE 80
STOPSIGNAL SIGTERM

# config.xml vars mapping
# SNM_LANG = language, DEFAULT_FREQ = default frequency, DEFAULT_TIMEOUT = default timeout, ATTR_REFRESH_PERIOD = attributes frequency
# PING_METHOD = ping method, GRAPH_WIDTH = image width, GRAPH_HEIGHT = image height
#
# targets.xml vars
# ROUTER_IP, WAN_IP, ISP_IP, DOCKER_IP will all be used for substitutions in the template to provide default ping stats and graphs
# (should probably provide examples on how to auto-detect when executing `docker run`)
#
# daemon vars
# VERBOSE = add the '-v' flag when running snm.pl
#
ENV VERBOSE=0 ROUTER_IP='127.0.0.1' WAN_IP='127.0.0.1' ISP_IP='127.0.0.1' DOCKER_IP='127.0.0.1' SNM_LANG='en' DEFAULT_FREQ='300' \
  DEFAULT_TIMEOUT='5' ATTR_REFRESH_PERIOD='24' PING_METHOD='internal' GRAPH_WIDTH='400' GRAPH_HEIGHT='100' 

ADD snm.tar /

RUN touch /var/log/snm.log /var/log/snm.log.old && \
 chgrp www-data /var/www/html/snm/ /var/www/html/snm/rrd/ /var/www/html/snm/graphs/ /var/www/html/snm/snm.cgi /var/log/snm.* && \
 chmod o-w /var/www/html/snm/ /var/www/html/snm/rrd/ /var/www/html/snm/graphs/ /var/www/html/snm/snm.cgi /var/log/snm.* && \
 chmod g+w /var/www/html/snm/ /var/www/html/snm/rrd/ /var/www/html/snm/graphs/ /var/log/snm.*
