#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
$line = "" ;
while(<>) {
	if ( $_ =~ /set_case_analysis\s+0\s+.+get_ports scan_en\s*/ ) {
		$line = $_ ;
        $line =~ s/scan_en/scan_enable/ ;
		print $line ;
		print <<EOF;
set_case_analysis 0 [get_ports test_mode]
EOF

	} elsif ( $_ =~ /\s*get_ports scan_en\s*/ ) {
		$line = $_ ;
        $line =~ s/scan_en/scan_enable/ ;
		print $line ;
	} else {
		print $_ ;
	}
}

