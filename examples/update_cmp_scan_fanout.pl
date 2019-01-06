#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
while(<>) {
	if ( $_ =~ /^redirect\s+.+\s+report_clocks\s+/ ) {
		print <<EOF;
redirect -append [format "%s%s"  [format "%s%s"  [format "%s%s" \$report_dir \$design_name] \$tech_lib] "_dc.rpt"] { report_net_fanout -high_fanout }
EOF
		print $_ ;
	} else {
		print $_ ;
	}
}

