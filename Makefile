# Find all source files, create a list of corresponding object files
SRCS=$(wildcard *.f90)
OBJS=$(patsubst %.f90, %.o, $(SRCS))
LD=-lnetcdf -lnetcdff
LIB=-L/apps/netcdf/4.6.1/include

# Ditto for mods
MODS=$(wildcard mod*.f90)
MOD_OBJS=$(patsubst %.f90, %.o, $(MODS))

# Compiler/Linker settings
FC = gfortran
FLFLAGS = -g
FCFLAGS = -g -c -Wall -Wno-tabs
PROGRAM = awap_to_netcdf
PRG_OBJ = $(PROGRAM).o

# Clean the suffixes
.SUFFIXES:

# Set the suffixes we are interested in
.SUFFIXES: .f90 .o

# make without parameters will make first target found.
default : $(PROGRAM)

# Compiler steps for all objects
$(OBJS) : %.o : %.f90
	$(FC) $(FCFLAGS) -o $@ $< $(LIB) $(LD)

# Linker
$(PROGRAM) : $(OBJS)
	$(FC) $(FLFLAGS) -o $@ $^ $(LIB) $(LD)

clean:
	rm -rf $(OBJS) $(PROGRAM) $(patsubst %.o, %.mod, $(MOD_OBJS))

.PHONY: default clean

# Dependencies
type_def.o: type_def.F90
bios_io.o: bios_io.F90 type_def.o
bios_output.o: bios_output.F90 type_def.o bios_io.o cable_weathergenerator.o
cable_weathergenerator.o: cable_weathergenerator.F90
cable_bios_met_obs_params.o: cable_bios_met_obs_params.F90 type_def.o bios_io.o
awap_to_netcdf.o: awap_to_netcdf.f90 type_def.o bios_io.o bios_output.o cable_weathergenerator.o cable_bios_met_obs_params.o 

# Main program depends on all modules
$(PRG_OBJ): $(MOD_OBJS)

# Blocks and allocations depends on shared
mod_blocks.o mod_allocations.o : mod_shared.o

#LD='-lnetcdf -lnetcdff'
#LIB='-L/apps/netcdf/4.6.1/include -L/apps/netcdf/4.6.1/lib'
