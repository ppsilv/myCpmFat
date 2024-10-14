; monitor.asm
; The low-level monitor
ESC:     EQU 27

monitor_start:
    call monitor_init
	call clear_screen
	call show_welcome_message

monitor_restart:

	; If there is an auto-run-character defined, use that instead of a key press.
	ld a, (auto_run_char)
	cp 0
	jr nz, monitor_loop2

monitor_loop:
	ld a, '>'
	call print_a
monitor_loop1:
	call char_in			; get a char from keyboard
monitor_loop2:
	cp 0					; If it's null, ignore it
	jr z,monitor_loop1
	cp '0'					; '0' = go to page 0
	jr nz,load_program
	call goto_page_0
	jp monitor_loop
load_program:
	cp '1'					; If it's null, ignore it
	jr nz,not0
	call load_program1
	jp monitor_loop
not0:
	cp 'u'					; User light toggle
	jr nz,notu
	call message
	db 'User LED toggled!',13,10,0
	call user_toggle
	jp monitor_loop
notu:
	cp '3'					; ROM light on
	jr nz,not3
	call message
	db 'ROM light is now ON',13,10,0
	call rom_on
	jp monitor_loop
not3:
	cp '4'					; ROM light off
	jr nz,not4
	call message
	db 'ROM light is now OFF',13,10,0
	call rom_off
	jp monitor_loop
not4:
	cp 'd'					; Disk LED toggle
	jr nz,not5
	call message
	db 'DISK LED toggled!',13,10,0
	call disk_toggle
	jp monitor_loop
not5:
	cp '5'					; ROM light off
	jr nz,notd
	call message
	db 'RAM copied...',13,10,0
	call copy_ram
	jp monitor_loop
notd:
	cp 'h'					; Higher page
	jr nz,not66
	ld a,(current_page)
	inc a
	ld (current_page),a
	call show_page
	jp monitor_loop
not66:
	cp '6'					; Higher page
	jr nz,noth
	ld a, $80
	ld (current_page),a
	call show_page
	jp monitor_loop
noth:
	cp 'l'					; Lower page
	jr nz,notl
	ld a,(current_page)
	dec a
	ld (current_page),a
	call show_page
	jp monitor_loop
notl:
	cp 'm'					; Memory map
	jr nz,notm
	call show_memory_map
	jp monitor_loop

notm:
	cp '/'					; Show Menu
	jr nz,not_slash
	call clear_screen
	call show_welcome_message
	jp monitor_loop

not_slash:
	cp '6'					; Test Uart
	jr nz,not6
	;call clear_screen
	;call test_uart
	;call clear_screen
	;call show_welcome_message
	jp monitor_loop

not6:
	cp '#'					; HALT
	jr nz,not_hash
	call message
	db 'HALTing Z80. You will need to press Reset after this!',13,10,0
	halt

not_hash:
	cp 'c'					; CP/M
	jr nz, not_c
    call message 
    db 'Starting CP/M... ',13,10
	db 'Make sure you have selected MSX ',13,10
	db 'proper slot memory decoder".',13,10,0
    jp start_cpm

not_c:
	cp 't'					; Tiny Basic
	jr nz, not_t
    call check_tbasic_structure
    ;call TBSTART
	jp monitor_restart

not_t:
	cp 'g'					; Game-of-Life
	jr nz, not_g
    ;call GOFL_Begin
	jp monitor_restart

not_g:
	cp 'b'					; Burn-in test
	jr nz, not_b
    ;call burn_in
	jp monitor_restart

not_b:
	cp 'j'					; Load jupiter.bin
	jr nz, unknown_char
    jp load_jupiter_ace

unknown_char:
	call print_a			; If we don't understand it, show it!
	call newline
	jp monitor_loop
aaa
show_welcome_message:
	call message
	db 13,10
	db 27,'[42m','+----------------------------------+',13,10
	db 27,'[42m','|                                  |',13,10
	db 27,'[42m','|',27,'[41m','          Z80  Monitor',27,'[42m','            |',13,10
	db 27,'[42m','|           by pdsilva             |',13,10
	db 27,'[42m','|     Monitor  v2.01 July 2022     |',13,10
	db 27,'[42m','|',27,'[43m','   CP/M Loader  v2.01 july 2022',27,'[42m','   |',13,10
	db 27,'[42m','|                                  |',13,10
	db 27,'[42m','+----------------------------------+',13,10,13,10
	db 'c = CP/M v2.2', 13, 10
	db '0 = Dump ROM page ZERO', 13, 10
	db '6 = Dump RAM page ZERO', 13, 10
	db 'h = Move to Higher Page', 13, 10
	db 'l = Move to Lower Page', 13, 10
	db 'm = Memory Map', 13, 10
	db 'u = User led toggle', 13, 10
	db 'd = Disk led toggle', 13, 10
	db '3 = Rom led ON', 13, 10
	db '4 = Rom led OFF', 13, 10
	db '/ = Show this Menu',13,10
	;db 't = Tiny Basic',13,10
	;db 'g = Game-of-Life',13,10
	;db '5 = Copy ram', 13, 10
	;db '# = Execute HALT instruction',13,10
	;db 'j = Poor-Man''s Jupiter Ace',13,10
	db 13,10,0
	ret

monitor_init:

                        ;lcd routines
          ;;              CALL    initializeDisplay
          ;;              LD      HL,MSGLCD001
          ;;              CALL    LcdPrintString
          ;;              LD      A, $40
           ;;             CALL    cursorPos
            ;;            LD      HL,MSGLCD002
             ;;           CALL    LcdPrintString

    ; Four flashes on the USER (blue) LED and disk (yellow) LED
    ld b, 4
monitor_init1:
    push bc    
	call user_off
	call disk_on
	call medium_pause
	call user_on
	call disk_off
	call medium_pause
    pop bc
    djnz monitor_init1
	call user_off

    call ram_fill
    ret

ram_fill:
    ; Copy the first 16k of ROM down to ram
	ld hl,0
	ld de,0
	ld bc, 1024*16
	ldir
    ret

copy_ram:
    ; Copy the first 16k of ROM down to ram
	ld hl,0
	ld de,	$8000
	ld bc,	1024*16
	ldir
    ret

;--------------------------------------------------------------------------------------------------

	; If this memory crosses a 1K memory boundary there is the danger
	; that the memory testing will corrupt the code that is running.
	; If memory map crashes, this is why.
	; TODO: Relocate this code to a safe location, such as 1024.

	db 'DANGER AREA STARTS '

show_memory_map:
	; Look at the first byte of each 1K block.
	; If it is ROM show one char, if RAM show another.
	call clear_screen
	call newline
	ld de,0
	ld b,64
	
map_loop:
	push bc
	
	ld a,(de)			; get initial value
	ld b,a
	
	ld a,0
	ld (de),a			; see if a 0 stores
	ld a,(de)
	cp 0
	jr nz,rom_location
	
	ld a,255
	ld (de),a			; see if a 255 stores
	ld a,(de)
	cp 255
	jr nz,rom_location
	
ram_location:
	call message
	db ' ',0
	jp shown_location
rom_location:
	call message
	db 27,'[41m','R',27,'[42m',0
shown_location:
	
	ld a,b				; restore initial value
	ld (de),a
	
	pop bc
	ld hl, 1024
	add hl,de
	ex de,hl
	djnz map_loop

	call newline
	; Now show a row all of ram
	ld b, 67
ram_loop:
	push bc
	call message
	db 27,'[44m','r',27,'[42m',0
	pop bc
	djnz ram_loop

	call newline
	call message
    db 27,'[46m',13,10
	db 'Z80 structure by pdsilva',13,10
    db 27,'[45m',13,10
	db '   |       |       |       |       |       |       |       |      |',13,10
	db '0000    2000    4000    6000    8000    A000    C000    E000   FFFF',13,10
	db '  0K      8K     16K     24K     32K     40K     48K     56K    64K',13,10,' ',13,10
	db 27,'[41m','R',27,'[0m',' = ROM    '
	db 27,'[44m','r',27,'[0m',' = RAM',13,10
    db 27,'[42m',13,10
	db '16C550C UART Ports     CH376S Module Ports',13,10
	db '-------------------    -------------------',13,10
	db 27,'[43mTX / RX.........:',27,'[41mB8',27,'[43m    Data Port...',27,'[41m.....:A0',13,10
	db 27,'[43mInterrupt Enable:',27,'[41mB9',27,'[43m    Command Port',27,'[41m.....:A1',13,10
	db 27,'[43mInterrup Status.:',13,10
	db 27,'[43mLine Control....:',13,10
	db 27,'[43mModem Control...:',27,'[41mBC',27,'[43m <---- 76543210',13,10
	db 27,'[43mLine Status.....:',27,'[41mBD',27,'[43m    Bit 0 =',27,'[41m User LED',13,10
	db 27,'[43mModem Status....:',27,'[41mBE',27,'[43m    Bit 2 =',27,'[41m Disk LED',13,10
	db 27,'[43mScratch.........:',27,'[41mBF',27,'[43m    Bit 3 =',27,'[41m ROM Enable',13,10,' '
	db 27,'[42m',13,10
	db 'I2C - Z80              PPI 8255 	',13,10
	db '-------------------    -------------------',13,10
	db 27,'[43mSCL.............:',27,'[41m80',27,'[43m    Port A........:',27,'[41m80A8',13,10
	db 27,'[43mSDA_WR..........:',27,'[41m88',27,'[43m    Port B........:',27,'[41m80A9',13,10
	db 27,'[43mSDA_RD..........:',27,'[41mB0',27,'[43m    Port C........:',27,'[41m80AA',13,10
	db 27,'[43m                       Ctrl..........:',27,'[41m  AB',13,10
	db 27,'[42m',13,10
	db 'PCF8574 - Z80              	',13,10
	db '-------------------    -------------------',13,10
    DB 27,'[43mPort............:',27,'[41m27',13,10
	db 27,'[43mThe EEPROM is an ATMEL AT29C512 ID:',27,'[41m 1F5D',13,10,' '
	db 27,'[42m',13,10,0
	ret

	db 'DANGER ENDS '
	
; -------------------------------------------------------------------------------------------------
goto_page_0:

	ld a, $0
	ld (current_page), a
	call newline
	call show_page
	ret

; -------------------------------------------------------------------------------------------------


full_ram_test:
	; Tests all of ram.
	; Returns Z set if success.
	ld hl, $FFFF 
full_ram_test1:
	ld b, (hl)

	ld (hl), %01010101
	ld a, (hl)
	cp %01010101
	ret nz

	ld (hl), %10101010
	ld a, (hl)
	cp %10101010
	ret nz

	ld (hl), b
	dec hl 
	ld a, h
	or l
	jr nz, full_ram_test1
    cp a                                ; set zero flag for success
	ret



print_a_as_decimal:
	ld b, 0
print_a_as_decimal1:
	cp 10
	jr c, print_a_as_decimal_units
	inc b
	ld c, 10
	sub c
	jr print_a_as_decimal1

print_a_as_decimal_units:
	push af
	ld a, b
	cp 0
	jr z, print_a_as_decimal_units1
	add a, '0'
	call print_a
print_a_as_decimal_units1:
	pop af
	add a, '0'
	call print_a
	ret

load_program1:
	call message
	db 'load program...',13,10,0
load_program2:
	call UART_RX
	jr	 NC, load_program2
	cp $39
	jr   z, fim_load_program1
	call print_a
	jr   load_program2
fim_load_program1:
	ret
load_jupiter_ace:
    ; Load CORE.BIN into its proper location
    ld hl, NAME_OF_CORE
    call copy_filename_to_buffer
    ld de, $F600 							; TODO: This can't be hardcoded, can it???
    call load_bin_file
	jr z, loaded_core_file
	call message
	db 'Failed to load CORE.BIN',13,10,0
	halt

loaded_core_file:	
    call message
    db 'CORE loaded!',13,10,0

	; Get the file Jupiter.bin into memory at location 0.
    ld hl, JUPITER_ACE_NAME
    call copy_filename_to_buffer
    ld de, 0								; Load it into location $0000             
    call load_bin_file                      ; hl comes back with end location of file. Z set if success.
	jr z, load_jupiter_ace1
	call message
	db 'Failed to load jupiter ace file.',13,10,0
	halt
load_jupiter_ace1:
	call message
	db 'Loaded jupiter ace file!',13,10,0
	; Just a quick test:
	call $F600+57
	db 'Starting Juniper Deuce...',13,10,0

	; Clear the screen
	; ld hl, $2400
	; ld (hl), '#'
	; ld de, $2401
	; ld bc, 767
	; ldir

	; Now run it.
	; Now we need the ROM turned off:
	call rom_off
	jp 0									

JUPITER_ACE_NAME:
    db 'JUPITER.BIN',0

the_end:
	db 'A message at the end ****************',0
	
; ---------------------------------------------------------
; These are variables so need to be in RAM.
; Unfortunately I am dumb and initially put them in ROM.
; I have learned my lesson!	

;store_hl		equ	60000					; Temporary store for hl
;store_de 		equ 60002					; Temporary store for de
current_page 	equ 60004					; Currently displayed monitor page

test_buffer 	equ 60006					; 32 x 24 char buffer (768 bytes)

	include "printing.asm"
	include "i2cdriver.asm"
	include "Lcd_i2c.asm"
	include "delay.asm"
