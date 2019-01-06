#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
$line = "" ;
while(<>) {
	if ( $_ =~ /^change_names\s*$/ ) {
		print <<EOF;
change_names -hierarchy
EOF
	} else {
		print $_ ;
	}
}

