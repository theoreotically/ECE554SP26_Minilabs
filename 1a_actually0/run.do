vlib work

vlog -work work addsb_bb.v addsb.v fifo.sv mac.sv mult_mod_bb.v mult_mod.v tb.sv fifo2_bb.v fifo2.v Minilab0.v
vsim -L /home/michael2/Documents/intelFPGA/18.1/modelsim_ase/altera/verilog/altera_mf -L /home/michael2/Documents/intelFPGA/18.1/modelsim_ase/altera/verilog/220model work.tb -voptargs=+acc
run -all
exit

