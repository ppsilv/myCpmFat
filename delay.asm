;******************************************************************
; This routine receives delay value in BC
; BC = 1 means 20uS
; for 50ms divide 50000 / 20 = 2500 0x208D
;
delay:
	push	AF
	push	BC
    ; Clobbers A, B and C
    ;ld      bc,$2
delay01:
    dec     bc      ; 6
    ld      a,c     ; 4
    or      b     ; 4
    jp      nz,delay01   ; 10, total = 55 states/iteration
 	POP		BC
	POP		AF
	ret


;******************************************************************
; This routine has BC with a fixed value of 2 times
; BC = 1 means 20uS
; for 50ms divide 50000 / 20 = 2500 0x208D
;
delay40US:
	push	AF
	push	BC
    ; Clobbers A, B and C
    ld      bc,0x02
delay02:
    dec     bc      ; 6
    ld      a,c     ; 4
    or      b     ; 4
    jp      nz,delay02   ; 10, total = 55 states/iteration
 	POP		BC
	POP		AF
	ret

;******************************************************************
; This routine has BC with a fixed value of 2 times
; BC = 1 means 20uS
; for 50ms divide 50000 / 20 = 2500 0x208D
;
delay100US:
	push	AF
	push	BC
    ; Clobbers A, B and C
    ld      bc,0x05
delay03:
    dec     bc      ; 6
    ld      a,c     ; 4
    or      b     ; 4
    jp      nz,delay03   ; 10, total = 55 states/iteration
 	POP		BC
	POP		AF
	ret

;******************************************************************
; This routine delay 746us
delay21:
			PUSH   AF
			LD     A, 0xFF          
delay21loop: DEC    A
			JP     NZ, delay21loop  ; JUMP TO DELAYLOOP2 IF A <> 0.
			POP    AF
			RET


