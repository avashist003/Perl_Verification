#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
$line = "" ;
while(<>) {
	if ( $_ =~ /hfo_nets\s+.+\s+"scan_en"\s*/ ) {
		$line = $_ ;
        $line =~ s/"scan_en"/"scan_enable" "test_mode"/ ;
		print $line ;
	} else {
		print $_ ;
	}
}

