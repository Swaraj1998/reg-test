# Build the project and generate bitstream (with register-slice mappings)
mkdir -p build
cd build && vivado -mode batch -source ../vivado.tcl

# Generate minimal slice-lut db from master db
echo "generating minimal bitstream info database..."
cd ../scripts
python gen_slice_lut_db_min.py
echo "done"
