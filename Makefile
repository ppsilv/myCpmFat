
#
# The files we wish to generate.
#


#all: bdos.bin bios.bin ccp.bin core.bin z80ccp.bin

#cpm: bdos.bin bios.bin ccp.bin core.bin z80ccp.bin

mon: cpm.hex




#
# This is a magic directive which allows GNU Make to perform
# a second expansion of things before running.
#
# In this case we wish to dynamically get the dependencies
# of the given .asm file.  We do that by loading a perl-script
# to look for `include "xxx"` references in the input file,
# and processing them recursively.
#
.SECONDEXPANSION:


#
# Convert an .asm file into a .bin file, via pasmo.
#
# The $$(shell ...) part handles file inclusions, so if you
# were to modify "locatoins.asm", for example, all appropriate
# binary files would be rebuilt.
#
%.bin: %.asm $$(shell ls %.asm)
	pasmo $<  $@
#	sjasmplus $<  $@
	cp	*.bin masterDisk/cpm/

%.hex: %.asm $$(shell ls %.asm)
	echo $$
	echo $@
	sjasmplus $<  --raw=$@ --lst=$@.lst

sync:
	cp *.bin *.lst
	cp *.hex 
	rsync  -vazr dist/CPM/ /media/skx/8BITSTACK/CPM/

#
# Cleanup.
#
clean:
	rm *.bin *.hex *.lst *.lst*