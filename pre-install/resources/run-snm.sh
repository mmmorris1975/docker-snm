#!/bin/bash

config='/etc/opt/snm/config.xml'
config_dir=$(dirname $config)
verbose=''

# initial start up, build config.xml and targets.xml from templates
template_semaphore=${config_dir}/.templates_created

if [ ! -f $template_semaphore ]
then
  cd /tmp/templates
  perl template_processor.pl $(dirname $config)
  touch $template_semaphore
fi

if [ $VERBOSE -gt 0 ]
then
  verbose='-v'
fi

cd /opt/snm 

/etc/init.d/apache2 start
perl /opt/snm/snm.pl -c $config $verbose
