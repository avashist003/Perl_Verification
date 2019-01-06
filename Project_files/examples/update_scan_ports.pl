#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
my $flag = 0 ;
my $line = "" ;

while(<>) {
	if ( $_ =~ /^\s*echo\s+\[concat\s+\{FOUND\s+\}\s+\$t_scan_in\s+\{\s+IN\s+CURRENT\s+DESIGN\s*\}\s*\]\s*$/ ) {
		print <<EOF;
  echo [format "%s %s %s" "FOUND" [get_attribute -quiet \$t_scan_in full_name] "IN CURRENT DESIGN"]
EOF
	} elsif ( $_ =~ /^\s*echo\s+\[concat\s+\{FOUND\s+\}\s+\$t_scan_out\s+\{\s+IN\s+CURRENT\s+DESIGN\s*\}\s*\]\s*$/ ) {
		print <<EOF;
  echo [format "%s %s %s" "FOUND" [get_attribute -quiet \$t_scan_out full_name] "IN CURRENT DESIGN"]
EOF
	} else {
		print $_ ;
	}
}

