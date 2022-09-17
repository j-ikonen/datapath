TAR := tb_alu

SRC := 	vhdl/common_pkg.vhd 		\
		vhdl/alu.vhd 				\
	   	test/tb_alu.vhd

WAVEFILE = sim/$(TAR).ghw

OPT = --workdir=work --std=08
SIM = --wave=$(WAVEFILE)

all: analyse elaborate run

analyse:
	ghdl -a $(OPT) $(SRC)

elaborate:
	ghdl -e $(OPT) $(TAR)

run:
	ghdl -r $(OPT) $(TAR) $(SIM)

wave:
	gtkwave $(WAVEFILE)