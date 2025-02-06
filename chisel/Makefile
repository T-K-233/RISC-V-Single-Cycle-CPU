VCS = vcs -full64

OUTPUT = ./simv


# $(VCS) top.v -o $(OUTPUT) -debug_access+all -kdb -lca -sverilog

# -debug_access+all enables dumping to fsdb format

build:
		mill BA30XSystem
	
sim:
		$(VCS) $(wildcard *.sv) -o $(OUTPUT) -debug_access+all -kdb -lca -sverilog
		$(OUTPUT)

clean:
		rm -rf csrc simv* ucli.key vc_hdrs.h DVEfiles Top.sv
