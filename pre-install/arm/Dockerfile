FROM armhf/ubuntu:xenial

RUN apt-get update && apt-get -y install \
  rrdtool librrds-perl libsnmp-base snmp libxml-simple-perl libhtml-template-perl \
  apache2 libapache2-mod-perl2 libcrypt-des-perl libauthen-sasl-perl zip unzip iputils-ping \
&& apt-get clean && rm -rf /var/lib/apt/lists/* \
&& a2dismod mpm_event && a2enmod perl cgi mpm_prefork status && mkdir /etc/opt/snm \
&& useradd -b /opt -G www-data -s /usr/sbin/nologin -c 'SNM app user' snm

COPY resources/*.xml /etc/opt/snm/
COPY resources/run-snm.sh /run-snm.sh
COPY resources/htaccess /etc/apache2/conf-enabled/snm.conf
COPY resources/templates/* /tmp/templates/
ADD  resources/snm-4.50.tar.bz2 /tmp/
