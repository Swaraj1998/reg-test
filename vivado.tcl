# vivado.tcl
#	MicroZed simple build script
#	Version 1.0
#
# Copyright (C) 2013 H.Poetzl
# Copyright (C) 2021 Swaraj Hota

set ODIR .
set OBITNAME reg_test

# set_param project.enableVHDL2008 1

# STEP#1: setup design sources and constraints

read_vhdl -vhdl2008 ../top.vhd
read_vhdl -vhdl2008 ../ps7_stub.vhd
read_vhdl -vhdl2008 ../reg.vhd

read_vhdl -vhdl2008 ../vivado_pkg.vhd

read_xdc ../reg.xdc
# read_xdc ../top.xdc
#read_xdc ../fclk.xdc
#read_xdc ../pin_i2c.xdc
#read_xdc ../pin_rf.xdc

set_property PART xc7z020clg400-1 [current_project]
set_property BOARD_PART em.avnet.com:microzed_7020:part0:1.1 [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]

# STEP#2: run synthesis, write checkpoint design

synth_design -top top -flatten rebuilt
write_checkpoint -force $ODIR/post_synth

# STEP#3: run placement and logic optimzation, write checkpoint design

opt_design -propconst -sweep -retarget -remap

write_checkpoint -force $ODIR/pre_place

place_design
phys_opt_design -critical_cell_opt -critical_pin_opt -placement_opt -hold_fix -rewire -retime
power_opt_design
write_checkpoint -force $ODIR/post_place

# STEP#4: run router, write checkpoint design

route_design
write_checkpoint -force $ODIR/post_route

report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -setup
report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -hold

# STEP#4b: load and route probes

#source ../vivado_probes.tcl
#route_design -preserve

# STEP#5: generate a bitstream

set_property BITSTREAM.GENERAL.COMPRESS False [current_design]
set_property BITSTREAM.CONFIG.USERID "DEADC0DE" [current_design]
#set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property BITSTREAM.READBACK.ACTIVERECONFIG Yes [current_design]

set_property BITSTREAM.GENERAL.PERFRAMECRC Yes [current_design]
#set_property BITSTREAM.GENERAL.CRC DISABLE [current_design]
#set_property BITSTREAM.SEU.ESSENTIALBITS Yes [current_design]

write_bitstream -force $ODIR/$OBITNAME.bit
write_cfgmem -force -format bin -interface SMAPx32 \
    -disablebitswap -loadbit "up 0x0 $OBITNAME.bit" -file $OBITNAME.bin

# STEP#6: generate reports

report_clocks

report_utilization -hierarchical -file utilization.rpt
report_clock_utilization -file utilization.rpt -append
report_datasheet -file datasheet.rpt
report_timing_summary -file timing.rpt

####################################
## Export register-to-slice mappings
####################################

set fp [open "reg_slice_map.db" w]

set reg_cells [get_cells -filter {REG_NAME!=""}]
foreach rc $reg_cells {
    set bels [get_property REG_NAME [get_cells $rc]]
    append bels " "
    for {set i 0} {$i < 16} {incr i} {
        set tmp [get_bels -quiet -of [get_cells -quiet $rc/GEN_REG[$i].LUT6_2_inst]]
        append bels $tmp " "
    }
    puts $fp [string trim $bels]
}

close $fp

puts "all done."
