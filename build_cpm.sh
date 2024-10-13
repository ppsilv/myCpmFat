


#bdos.bin bios.bin ccp.bin core.bin z80ccp.bin

echo '********************* BDOS'
sjasmplus bdos.asm --raw=bdos.bin --lst=bdos.lst

echo '********************* BIOS'
sjasmplus bios.asm --raw=bios.bin --lst=bios.lst


echo '********************* CCP'
sjasmplus ccp.asm --raw=ccp.bin --lst=ccp.lst


echo '********************* CORE'
sjasmplus core.asm --raw=core.bin --lst=core.lst


echo '********************* z80ccp'
#sjasmplus z80ccp.asm --raw=z80ccp.bin --lst=z80ccp.lst
