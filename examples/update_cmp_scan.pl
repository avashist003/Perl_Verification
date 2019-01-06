#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 0 ;
while(<>) {
	if ( $_ =~ /^set\s+my_type\s+/ ) {
		print $_ ;
		print "set my_input_type \"_rtl\"\n" ;
		$flag++ ;
	} elsif (( $_ =~ /^read_file\s+-format\s+/ ) && $flag ) {
		print <<EOF;
read_file -format verilog [list [format "%s%s%s%s" "netlist/" \$design_name \$tech_lib "\${my_input_type}.vs"]]
EOF
		$flag++ ;
	} elsif (( $_ =~ /^set\s+t_scan_en\s+/ ) && $flag ) {
		print <<EOF;
set t_test_mode [find port "test_mode"]

if { [get_object_name \$t_test_mode] != "test_mode" } {
   echo [concat {DFT ERROR : NO TEST_MODE SIGNAL FOUND IN CURRENT DESIGN}]
  exit 0
}

set_dft_signal -view existing_dft -port \$t_test_mode -type TestMode -active_state 1

EOF
		print $_ ;
		$flag++ ;
	} elsif ( $_ =~ /^set\s+my_input_type\s+/ ) {
		print $_ ;
		print STDERR "ERROR: my_input_type already found!\n" ;
	} else {
		print $_ ;
	}
}

