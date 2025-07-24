vlib work
vlog *.*v
vsim -voptargs=+acc work.MIPS_SC_TB
do wave.do
run -all