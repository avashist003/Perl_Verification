#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
$line = "" ;
while(<>) {
	if ( $_ =~ /^\s*read_sdf/ ) {
		$line = $_ ;
		print <<EOF;

current_design \$design_name

EOF
		print $line ;

	} else {
		print $_ ;
	}
}

