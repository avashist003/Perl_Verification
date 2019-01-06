
#
# set design name
#
set design_name chkrpl

set my_type "_scan"

set max_path_count 10

# Turn on auto wire load selection
# (library must support this feature)
set auto_wire_load_selection true

# To account for clock network latency in external delays, you can set the
# estimate_io_latency variable to true. When this variable is set to true, the tool assigns
# clock network delay to every input or output port. The tool assumes that clock tree synthesis
# balances network latency across different clocks. Based on this assumption, the tool
# estimates off-chip clock latency with reference to the synthesized clock tree in the current
# design.
set estimate_io_latency true

file mkdir "./netlist" "./sdf" "./spf" "./report" "./report/dc" "./report/pt" "./report/pr"
set report_dir "./report/pr/"
set saif_dir "./saif/"

#/* set technology library */
source "dc/tech_config.tcl"

#
# read netlist
#
read_file -format verilog [format "%s%s"  [format "%s%s"  [format "%s%s"  "./netlist/" $design_name] $tech_lib] "${my_type}.vs"]

current_design $design_name
link

read_sdf [format "%s%s"  [format "%s%s"  [format "%s%s"  "./sdf/" $design_name] $tech_lib] "${my_type}.sdf"]

current_design $design_name

#
# apply constraints
#
source "cons/${design_name}_cons_defaults.tcl"
source "cons/${design_name}_clocks_all_cons.tcl"
source "cons/${design_name}_cons.tcl"


##################################################################
#    Clock Tree Synthesis Section                                #
##################################################################

set_propagated_clock [all_clocks]


##################################################################
#    Update_timing and check_timing Section                      #
##################################################################

set_case_analysis 0 [get_ports reset]
set_case_analysis 0 [get_ports scan_en]
set_case_analysis 0 [get_ports test_mode]

echo [concat {Power Analysis}]
current_design $design_name

if {[file exists [format "%s%s" $saif_dir "${design_name}_bw.saif"]]} {
	reset_switching_activity
	echo [concat {Reading Backwards SAIF File}]
	read_saif [format "%s%s" $saif_dir "${design_name}_bw.saif"] -strip_path test/top
}

redirect [format "%s%s"  [format "%s%s"  [format "%s%s"  $report_dir $design_name] $tech_lib] "_power_pr.rpt"] { report_power -verbose }
redirect -append [format "%s%s"  [format "%s%s"  [format "%s%s"  $report_dir $design_name] $tech_lib] "_power_pr.rpt"] { report_power -hier -verbose }

