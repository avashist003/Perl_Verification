#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
$line = "" ;
while(<>) {
	if ( $_ =~ /\s*DFT\s+ERROR\s+/ ) {
		$line = $_ ;
		$line =~ s/DFT\s+ERROR/DFT WARNING/ ;
		print $line ;
		$flag = 1 ;
	} elsif (( $_ =~ /^\s+exit\s+0\s*$/ ) && ($flag == 1)) {
		$flag = 2 ;
	} elsif (( $_ =~ /^}$/ ) && ($flag == 2)) {
		print <<EOF;
} else {
EOF
		$flag = 3 ;
	} elsif (( $_ =~ /^set_dft_signal\s+/ ) && ($flag == 3)) {
		print $_ ;
		print <<EOF;
}
EOF
	} else {
		print $_ ;
	}
}

