#!/usr/bin/env perl

use strict;
use warnings;
use HTML::Template;

my $config_dir = $ARGV[0] || '/etc/opt/snm//';
print "USING " . $config_dir;

my $config_t = HTML::Template->new(filename => 'config.xmlt');
# TODO: Need to sanitize inputs for lang & ping
$config_t->param(
  lang => $ENV{LANG}, ping => $ENV{PING_METHOD},
  freq => int($ENV{DEFAULT_FREQ}), timeout => int($ENV{DEFAULT_TIMEOUT}),
  width => int($ENV{GRAPH_WIDTH}), height => int($ENV{GRAPH_HEIGHT})
);

open(my $c_fh, '>', $config_dir . "/config.xml") || die "could not open config.xml for writing: $!";
print $c_fh $config_t->output;
close($c_fh);

my $target_t = HTML::Template->new(filename => 'targets.xmlt');
# TODO: Sanitize inputs
$target_t->param(
  router_ip => $ENV{ROUTER_IP}, wan_ip => $ENV{WAN_IP}, isp_ip => $ENV{ISP_IP}, docker_ip => $ENV{DOCKER_IP}
);

open(my $t_fh, '>', $config_dir . "/targets.xml") || die "could not open targets.xml for writing: $!";
print $t_fh $target_t->output;
close($t_fh);
