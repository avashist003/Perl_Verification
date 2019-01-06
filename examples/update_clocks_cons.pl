#!/usr/bin/perl -wi.bak
#
# update cmp_scan.tcl
#
$flag = 1 ;
while(<>) {
	if (( $_ =~ m@^#/\*\s+\*/@ ) && $flag) {
		print <<EOF;
#/*********************************************************/
#/* Special handeling for Clock Buffers                   */

current_design \$design_name

echo [concat {>>> Searching for clock buffers}]
set clk_buffers [list "clkbuf"]
set hfo_pins [list "Y"]

foreach clk_buffer \$clk_buffers {
  foreach_in_collection this_cell [get_cells -hierarchical] {
    if {[get_attribute -quiet \$this_cell cell_footprint] == \$clk_buffer} {
      set_dont_touch \$this_cell

      foreach hfo_pin \$hfo_pins {
        foreach_in_collection this_pin [get_pins -hierarchical -of_objects \$this_cell] {
          if {[get_attribute \$this_pin direction] == "out"} {
            set_ideal_network [list \$this_pin]
            set_dont_touch_network [list \$this_pin]
            echo [concat [format "%s%s %s"  {>>>   Clock Buffer Output Pin: } [get_attribute \$this_pin full_name] [get_attribute \$this_pin direction]]]
          }
        }
      }
    }
  }
}
echo [concat {>>> Done with clock buffers}]

current_design \$design_name

EOF
		$flag = 0 ;
	} else {
		print $_ ;
	}
}

