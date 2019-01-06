
.SUFFIXES:            # Delete the default suffixes
.SUFFIXES: .asm .obj  # Define TDSP Assembler suffix list

PERL	= /usr/bin/perl
TASM	= tdspasm
ASM	= $(PERL) $(TASM)
POP	= getop
GETOP	= $(PERL) $(POP)

OBJECTS		= dtmf_tdsp.obj humm.obj humm_loc.obj
LISTINGS	= dtmf_tdsp.lst humm.lst humm_loc.lst
SYMBOLS		= dtmf_tdsp.sym humm.sym humm_loc.sym

all:	$(OBJECTS)

opcodes:
	$(GETOP) ../dtmf+humm/include/* ../dtmf+humm/src/*

clean:
	\rm -f $(OBJECTS) $(LISTINGS) $(SYMBOLS)

dtmf_tdsp.obj:	Makefile dtmf_tdsp.asm

humm.obj:	Makefile humm.asm

humm_loc.obj:	Makefile humm_loc.asm

# custom TDSP Assembler rule
.asm.obj:
	$(ASM) $<


