#
# read ram/rom technology libraries for dtmf_recvr_core
#

set techs [list "fast" "typical" "slow"]

set all_libs [list \
"ram_128x16" \
"ram_16x16" \
"ram_256x16" \
"ram_512x16" \
"rom_512x16" \
]

echo ""
echo "Reading RAM/ROM Technology Libraries"
echo ""

foreach tech $techs {
foreach this_lib $all_libs {
	remove_lib -all
	read_lib [format "%s%s%s%s"  $this_lib "_" $tech "_syn.lib"] 
	set library_name [format "%s%s%s"  $this_lib "_" $tech]
	set target_library [format "%s%s"  $library_name ".db"]
	write_lib $library_name -format db -output $target_library 
}
}

