#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 1 ;
while(<>) {
	if (( $_ =~ /^set_clock_gating_check\s+/ ) && $flag) {
		print <<EOF;
set_clock_gating_check -setup [expr \$CLK_PERIOD * 0.05] -hold [expr \$CLK_PERIOD * 0.15] [all_clocks]
EOF
		$flag = 0 ;
	} else {
		print $_ ;
	}
}

