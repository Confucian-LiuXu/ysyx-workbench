# verilog & CPP source file
VSRCS := $(shell find $(abspath ./vsrc) -name '*.v'   -or -name '*.sv')
CSRCS := $(shell find $(abspath ./csrc) -name '*.cpp' -or -name '*.cc' -or -name '*.c')

# -I dir : Add the directory 'dir' to the list of directories to be searched for header file (before the standard system include directories)
INC_PATH := $(abspath ./csrc/include)
INCFLAGS := $(addprefix -I, $(INC_PATH))

# Verilator and Flag
VERILATOR = verilator
# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Add searching path for C/CPP header file
VERILATOR_FLAGS += -CFLAGS $(INCFLAGS)
# `include relative path
VERILATOR_FLAGS += --relative-includes
# TODO

# check verilog syntax
.PHONY: linter
linter:
	@$(VERILATOR) --relative-includes --lint-only -Wall -Wno-MULTITOP $(VSRCS)

all:
	@echo "Write this Makefile by your self."

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."

include ../Makefile
