############################################################################
# 'A Generic Makefile for Building Multiple main() Targets in $PWD'
# Author:  Robert A. Nader (2012)
# Email: naderra at some g
# Web: xiberix
############################################################################
#  The purpose of this makefile is to compile to executable all C source
#  files in CWD, where each .c file has a main() function, and each object
#  links with a common LDFLAG.
#
#  This makefile should suffice for simple projects that require building
#  similar executable targets.  For example, if your CWD build requires
#  exclusively this pattern:
#
#  cc -c $(CFLAGS) main_01.c
#  cc main_01.o $(LDFLAGS) -o main_01
#
#  cc -c $(CFLAGS) main_2..c
#  cc main_02.o $(LDFLAGS) -o main_02
#
#  etc, ... a common case when compiling the programs of some chapter,
#  then you may be interested in using this makefile.
#
#  What YOU do:
#
#  Set PRG_SUFFIX_FLAG below to either 0 or 1 to enable or disable
#  the generation of a .exe suffix on executables
#
#  Set CFLAGS and LDFLAGS according to your needs.
#
#  What this makefile does automagically:
#
#  Sets SRC to a list of *.c files in PWD using wildcard.
#  Sets PRGS BINS and OBJS using pattern substitution.
#  Compiles each individual .c to .o object file.
#  Links each individual .o to its corresponding executable.
#
###########################################################################
#
CC=clang
CXX=g++
CU=nvcc
LDFLAGS := 
CFLAGS_INC := -std=c11
CFLAGS := -g -Wall $(CFLAGS_INC)
CXXFLAGS_INC := -std=c++11
CXXFLAGS := -g -Wall $(CXXFLAGS_INC)
CUFLAGS_INC := -std=c++11
SMS ?= 35 52 61
$(foreach sm,$(SMS),$(eval CUGENCODE_FLAGS += -gencode arch=compute_$(sm),code=sm_$(sm)))
CUFLAGS := -g $(CUFLAGS_INC) $(CUGENCODE_FLAGS)

#
## ==================- NOTHING TO CHANGE BELOW THIS LINE ===================
##
OUTPUT := bin

C_SRCS := $(wildcard src/main/c/*.c)
C_OBJS := $(patsubst %.c,%.o,$(C_SRCS))
C_BINS := $(addprefix $(OUTPUT)/, $(notdir $(patsubst %.c,%,$(C_SRCS))))

CXX_SRCS := $(wildcard src/main/cxx/*.cpp)
CXX_OBJS := $(patsubst %.cpp,%.o,$(CXX_SRCS))
CXX_BINS := $(addprefix $(OUTPUT)/, $(notdir $(patsubst %.cpp,%,$(CXX_SRCS))))

CU_SRCS := $(wildcard src/main/cu/*.cu)
CU_OBJS := $(patsubst %.cu,%.o,$(CU_SRCS))
CU_BINS := $(addprefix $(OUTPUT)/, $(notdir $(patsubst %.cu,%,$(CU_SRCS))))

## OBJS are automagically compiled by make.
OBJS := 
BINS := $(C_BINS) $(CXX_BINS) $(CU_BINS)

##
all : $(BINS)
##
## For clarity sake we make use of:
.SECONDEXPANSION:
SRC_C = $(addprefix src/main/c/, $(notdir $(patsubst %,%.c,$@)))
SRC_CXX = $(addprefix src/main/cxx/, $(notdir $(patsubst %,%.cpp,$@)))
SRC_CU = $(addprefix src/main/cu/, $(notdir $(patsubst %,%.cu,$@)))
OBJ = $(patsubst %,%.o,$@)
BIN = $(addprefix $(OUTPUT)/, $(notdir $@))

## Compile the executables
$(C_BINS) : $(C_SRCS)
	$(CC) $(SRC_C) $(CFLAGS) $(LDFLAGS) -o $(BIN)

$(CXX_BINS) : $(CXX_SRCS)
	$(CXX) $(SRC_CXX) $(CXXFLAGS) $(LDFLAGS) -o $(BIN)

$(CU_BINS) : $(CU_SRCS)
ifdef CUDA_HOME
	$(CU) $(SRC_CU) $(CUFLAGS) -o $(BIN)
endif
##
## $(OBJS) should be automagically removed right after linking.
##
clean:
	$(RM) $(BINS)
##
rebuild: clean all
##
## eof Generic_Multi_Main_PWD.makefile