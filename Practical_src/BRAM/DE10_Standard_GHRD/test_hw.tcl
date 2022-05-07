# TCL File Generated by Component Editor 18.1
# Thu Jun 10 01:51:25 EET 2021
# DO NOT MODIFY


# 
# MMul_master "Matrix Multiplication Master" v1.0
#  2021.06.10.01:51:25
# MMul master controller that regulates loading and unloading of inp/ker matrices
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module MMul_master
# 
set_module_property DESCRIPTION "MMul master controller that regulates loading and unloading of inp/ker matrices"
set_module_property NAME MMul_master
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "Matrix Multiplication Master"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL MMul_master
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file MMul_master.vhdl VHDL PATH ip/MMul_master/MMul_master.vhdl TOP_LEVEL_FILE
add_fileset_file adder.vhd VHDL PATH ip/MMul_master/adder.vhd
add_fileset_file adder_res.vhd VHDL PATH ip/MMul_master/adder_res.vhd
add_fileset_file comparator.vhd VHDL PATH ip/MMul_master/comparator.vhd
add_fileset_file control.vhd VHDL PATH ip/MMul_master/control.vhd
add_fileset_file datapath.vhd VHDL PATH ip/MMul_master/datapath.vhd
add_fileset_file inp_ram.vhd VHDL PATH ip/MMul_master/inp_ram.vhd
add_fileset_file interface_level.vhd VHDL PATH ip/MMul_master/interface_level.vhd
add_fileset_file ker_ram.vhd VHDL PATH ip/MMul_master/ker_ram.vhd
add_fileset_file multiplier.vhd VHDL PATH ip/MMul_master/multiplier.vhd
add_fileset_file mux2x1.vhd VHDL PATH ip/MMul_master/mux2x1.vhd
add_fileset_file mux3x1.vhd VHDL PATH ip/MMul_master/mux3x1.vhd
add_fileset_file out_ram.vhd VHDL PATH ip/MMul_master/out_ram.vhd
add_fileset_file outmux.vhd VHDL PATH ip/MMul_master/outmux.vhd
add_fileset_file reg.vhd VHDL PATH ip/MMul_master/reg.vhd
add_fileset_file toplevel.vhd VHDL PATH ip/MMul_master/toplevel.vhd


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point avs_s0
# 
add_interface avs_s0 avalon end
set_interface_property avs_s0 addressUnits WORDS
set_interface_property avs_s0 associatedClock clock
set_interface_property avs_s0 associatedReset reset
set_interface_property avs_s0 bitsPerSymbol 8
set_interface_property avs_s0 burstOnBurstBoundariesOnly false
set_interface_property avs_s0 burstcountUnits WORDS
set_interface_property avs_s0 explicitAddressSpan 0
set_interface_property avs_s0 holdTime 0
set_interface_property avs_s0 linewrapBursts false
set_interface_property avs_s0 maximumPendingReadTransactions 0
set_interface_property avs_s0 maximumPendingWriteTransactions 0
set_interface_property avs_s0 readLatency 0
set_interface_property avs_s0 readWaitTime 1
set_interface_property avs_s0 setupTime 0
set_interface_property avs_s0 timingUnits Cycles
set_interface_property avs_s0 writeWaitTime 0
set_interface_property avs_s0 ENABLED true
set_interface_property avs_s0 EXPORT_OF ""
set_interface_property avs_s0 PORT_NAME_MAP ""
set_interface_property avs_s0 CMSIS_SVD_VARIABLES ""
set_interface_property avs_s0 SVD_ADDRESS_GROUP ""

add_interface_port avs_s0 avs_s0_address address Input 4
add_interface_port avs_s0 avs_s0_read read Input 1
add_interface_port avs_s0 avs_s0_write write Input 1
add_interface_port avs_s0 avs_s0_readdata readdata Output 16
add_interface_port avs_s0 avs_s0_writedata writedata Input 16
set_interface_assignment avs_s0 embeddedsw.configuration.isFlash 0
set_interface_assignment avs_s0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avs_s0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avs_s0 embeddedsw.configuration.isPrintableDevice 0
