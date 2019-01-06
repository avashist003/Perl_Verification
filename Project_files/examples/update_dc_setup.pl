#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
$line = "" ;
while(<>) {
	if ( $_ =~ /^\s*set\s+auto_wire_load_selection\s+true\s*$/ ) {
		print $_ ;
		print <<EOF;

# If your design contains parameters, you can indicate that
# the design should be read in as a template
set hdlin_auto_save_templates true
EOF
	} else {
		print $_ ;
	}
}

