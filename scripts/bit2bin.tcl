set OBITNAME reg_test
write_cfgmem -force -format bin -interface SMAPx32 \
    -disablebitswap -loadbit "up 0x0 $OBITNAME.bit" -file $OBITNAME.bin
