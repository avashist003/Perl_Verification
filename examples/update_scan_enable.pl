#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
$line = "" ;
while(<>) {
	if ( $_ =~ /\s*"scan_en"\s*/ ) {
		$line = $_ ;
        $line =~ s/"scan_en"/"scan_enable"/ ;
		print $line ;
	} elsif ( $_ =~ /\[\s*list\s+reset\s+scan_en\s*\]/ ) {
		$line = $_ ;
        $line =~ s/\[\s*list\s+reset\s+scan_en\s*\]/[list reset scan_enable]/ ;
		print $line ;
	} elsif ( $_ =~ /\[\s*list\s+clk\s+reset\s+scan_en\s*\]/ ) {
		$line = $_ ;
        $line =~ s/\[\s*list\s+clk\s+reset\s+scan_en\s*\]/[list clk reset scan_enable]/ ;
		print $line ;
	} else {
		print $_ ;
	}
}

