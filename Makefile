#
# The files we wish to generate.
#

#To be compiled with pasmo
all: bdos.bin bios.bin ccp.bin core.bin ccpZ80.bin cpm.bin

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
	@echo 'Compiling with pasmo: ' $< ' to ' $@
	pasmo $<  $@
	@echo 'Coping: ' $< ' to masterDisk/cpm/'$@
	@cp	*.bin masterDisk/cpm/

sync:
	cp *.bin *.lst
	cp *.hex 
	rsync  -vazr dist/CPM/ /media/skx/8BITSTACK/CPM/
grava:
	minipro  -p AT29C512 -s -w cpm.bin
#
# Cleanup.
#
clean:
	rm *.bin *.lst

