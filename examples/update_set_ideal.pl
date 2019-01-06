#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
$line = "" ;
while(<>) {
	if ( $_ =~ /\s+set_ideal_net\s+/ ) {
		$line = $_ ;
        $line =~ s/set_ideal_net/set_ideal_network/ ;
		print $line ;
	} else {
		print $_ ;
	}
}

