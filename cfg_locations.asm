; locations.asm
; Stores the ORG values for the CCP, BDOS, BIOS and CORE

;CORE_START  equ $F600    ; $FFFF - 2.5K
;BIOS_START  equ $F400    ; $F600 - 0.5K
;BDOS_START  equ $EA00    ; $F400 - 2.5K
;CCP_START   equ $DE00    ; $EA00 - 3.0K

CORE_START  equ $EC00    ; 5119
BIOS_START  equ $DC00    ; 4096
BDOS_START  equ $D000    ; 3072
CCP_START   equ $B000    ; 8192

CORE_SIZE   equ 0xFFFF-CORE_START 
BIOS_SIZE   equ CORE_START-BIOS_START
BDOS_SIZE   equ BIOS_START-BDOS_START
CCP_SIZE    equ BDOS_START-CCP_START