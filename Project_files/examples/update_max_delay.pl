#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
my $flag = 0 ;
my $line = "" ;

while(<>) {
	if ( $_ =~ /^\s*set_output_delay\s+\$OUTPUT_DELAY\s+-clock\s+clk\s+\[list\s+\[all_outputs\]\]\s*$/ ) {
		print $_ ;
		print <<EOF;
set_max_delay -from clk -to [list [all_outputs]] \$OUTPUT_DELAY
EOF
	} else {
		print $_ ;
	}
}

