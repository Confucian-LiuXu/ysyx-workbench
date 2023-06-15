# verilog & CPP source file
VSRCS := $(shell find $(abspath ./vsrc) -name '*.v'   -or -name '*.sv')
CSRCS := $(shell find $(abspath ./csrc) -name '*.cpp' -or -name '*.cc' -or -name '*.c')

# -I dir : Add the directory 'dir' to the list of directories to be searched for header file (before the standard system include directories)

# ----- Verilator and Verilator Flag -----
TOPMODULE = top
TOPCLASS = V$(TOPMODULE)
EXECUTABLE = riscvCPU

BUILD_DIR = ./build

## Verilator
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif

## Verilator Flag
### Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
### Invoke the toolchain
VERILATOR_FLAGS += --build
### Acceletate compilation
VERILATOR_FLAGS += -j 0
### Add searching path for C/CPP header file
INC_PATH = $(abspath ./csrc/include)
INCFLAGS = $(addprefix -I, $(INC_PATH))
VERILATOR_FLAGS += -CFLAGS $(INCFLAGS)
### Store generated files
OBJ_DIR = $(BUILD_DIR)/obj_dir
VERILATOR_FLAGS += --Mdir $(OBJ_DIR)
### Top module
VERILATOR_FLAGS += --top-module $(TOPMODULE)
### Top module class(used in cpp file, 'Vtop' class)
VERILATOR_FLAGS += --prefix $(TOPCLASS)
### Specify the name for the final executable (default: --prefix)
VERILATOR_FLAGS += -o $(EXECUTABLE)
### Assignment for explicit 'x' in verilog source code(default: fast)
VERILATOR_FLAGS += -x-assign unique
### Initialization for all variables
VERILATOR_FLAGS += -x-initial unique
### `include relative path
VERILATOR_FLAGS += --relative-includes
# TODO

# ----------------------------------------

# --------------- Recipe -----------------
TARGET = $(OBJ_DIR)/$(EXECUTABLE)

app: $(TARGET)

## Check Verilog Syntax
LINT_FLAGS = --relative-includes --lint-only -Wall -Wno-MULTITOP
.PHONY: linter
linter:
	@$(VERILATOR) $(LINT_FLAGS) $(VSRCS)

## Generate interpreter
$(TARGET): $(VSRC) $(CSRC)
	@mkdir -p $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_FLAGS) $^

## Simulation(TODO)
sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."

## Remove all generated files
.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
# ----------------------------------------

include ../Makefile
