#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
my $flag = 0 ;
my $line = "" ;

while(<>) {
	if ( $_ =~ /^\s*set\s+hdlin_enable_presto\s+false\s*$/ ) {
		print $_ ;
		print <<EOF;
set hdlin_keep_signal_name all
EOF
	} else {
		print $_ ;
	}
}

