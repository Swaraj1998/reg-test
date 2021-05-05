create_pblock pb_slicel
set_property IS_SOFT 0 [get_pblocks pb_slicel]
resize_pblock pb_slicel -add {SLICE_X0Y0:SLICE_X113Y149}
resize_pblock pb_slicel -remove [get_sites -filter {SITE_TYPE==SLICEM} -of [get_pblocks pb_slicel]]
add_cells_to_pblock pb_slicel [get_cells reg_inst] -clear_locs
add_cells_to_pblock pb_slicel [get_cells reg_inst_1] -clear_locs
