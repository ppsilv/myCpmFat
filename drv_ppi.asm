INIT_PIO:
        	LD      A, 0x80 			; All ports output A,B and C
	        OUT     (PIO_M), A		; 
            RET


change_to_slot2:
    push    HL
    
    ;call    teste_na_rom
	LD      A, 0xAA    
	OUT     (PIO_A), A	
    ;call    teste_na_ram


    ; Copy the first 16k of ROM down to ram LD (DE),(HL),
	ld hl,  RamAddr000
	ld de,  0	
	ld bc,	128
	ldir
	pop    HL
    ret


;teste_na_ram:
    ;call CORE_message
    ;db 'Testing ram 1000: ',13,10,0
    ;ld  hl,1000
    ;ld  A, 0xA5    
    ;ld  (hl),a
    ;ld  A, 0x5A
    ;ld A,(hl)
    ;cp  A, 0xA5
    ;jp  NZ, cont
    ;call CORE_message
    ;db 'We are in RAM',13,10,0
    ;jp  cont2
;cont:
    ;call CORE_message
    ;db 'We are NOT in RAM',13,10,0
;    halt
;cont2:
;    pop     HL
;copy_ram:
;    ret            

;teste_na_rom:
;    call CORE_message
;    db 'Testing ram 1000: ',13,10,0
;    ld  hl,1000
;    ld  A, 0xA5    
;    ld  (hl),a
;    ld  A, 0x5A
;    ld A,(hl)
;    cp  A, 0xA5
;    jp  NZ, cont1
;    call CORE_message
;    db 'We are in RAM',13,10,0
;    jp  cont21
;cont1:
;    call CORE_message
;    db 'We are NOT in RAM',13,10,0
;cont21:
;    ret                
