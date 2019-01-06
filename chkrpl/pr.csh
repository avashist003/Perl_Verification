#!/bin/csh -f

if (-e /tools/rhel6/env/synopsys_env.csh) then
        source /tools/rhel6/env/synopsys_env.csh
endif 

set base = pr
set scr = power_scan 
${base}_shell < ${base}/${scr}.tcl |& tee ${base}_shell_${scr}.log
