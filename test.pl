#!/usr/bin/env perl
use strict;

my @ipset = qx/'sudo ipset -L | grep -e "Name: BAN" -e "94.158.95.186" | sed -e "s/ timeout.*//g" -e "s/Name: //g" | grep -P "^\d+" -B 1 | grep -v "^--" | head -n 2'/;
print @ipset; 

#foreach (@ipset) { print ; }
