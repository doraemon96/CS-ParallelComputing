# Binary file
BIN = tiny_mc
ODIR = bin

# Flags
CFLAGS = -Wall -Wextra -Werror
LDFLAGS = -lm -fopenmp

# Default Values
SHELLS = 101
PHOTONS = 32768
# Output filename when make run
OFILE = [CPU,$(PHOTONS),$(SHELLS)].dat

# Simulation Parameters
PARAMETERS = -DPHOTONS=$(PHOTONS) -DSHELLS=$(SHELLS)

# Compilers
CC = gcc-9
LINKER = gcc-9

# Files
MAKEFILE = Makefile
C_SOURCES = $(BIN).c
HEADERS =
C_OBJS = $(patsubst %.c, %.o, $(C_SOURCES))

# Rules
$(BIN): clean $(C_OBJS) $(HEADERS) $(MAKEFILE)
	$(LINKER) -o $(ODIR)/$(BIN) $(C_OBJS) $(LDFLAGS) $(INCLUDES) $(LIBS)

$(C_OBJS): $(C_SOURCES) $(HEADERS) $(MAKEFILE)
	$(CC) -c $(C_SOURCES) $(CFLAGS) $(INCLUDES) $(PARAMETERS)

run: $(BIN)
	./$(BIN) > $(OFILE) &

clean:
	rm -f $(BIN) *.o
