TAR := tb_alu

SRC := vhdl/alu.vhd 		\
	   test/tb_alu.vhd

OPT = --workdir=work --std=08
SIM = --wave=sim/$(ENT).ghw

all: analyse elaborate run

analyse:
	ghdl -a $(OPT) $(SRC)

elaborate:
	ghdl -e $(OPT) $(TAR)

run:
	ghdl -r $(OPT) $(TAR) $(SIM)

