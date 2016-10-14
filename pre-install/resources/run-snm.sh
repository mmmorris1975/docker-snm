#!/bin/bash

config='/etc/opt/snm/config.xml'
verbose=''

# initial start up, build config.xml and targets.xml from templates
cd /tmp/templates
perl template_processor.pl $(dirname $config)

if [ $VERBOSE -gt 0 ]
then
  verbose='-v'
fi

cd /opt/snm 

/etc/init.d/apache2 start
perl /opt/snm/snm.pl -c $config $verbose
