    ;org     0x0000
RamAddr000:    
    jp      BIOS_START      ;Warm boot jump to bios
    db      0x3               ;iobyte
    DS      1               ;disk byte
    jp      BDOS_START      ;system call
    ;Restart vector 7  generally used by debuggers
	;org 0x0038
int:
	reti
    ;Bios work area
    ;org 0x0040
    db  '0000000000000000'
    ;Unused area in CP/M 2.2
    ;org 0x0050
    db  '0000000000000000'
    ;FCB Default file control block
    ;org 0x0060
    db  '0000000000000000'
    db  '0000000000000000'
    ;File buffer 128 bytes
    ;org 0x0080
    ;db  '0000000000000000000000000000000000000000000000000000000000000000'
    ;db  '0000000000000000000000000000000000000000000000000000000000000000'

