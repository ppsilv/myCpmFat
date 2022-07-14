; uart routines
; These are routines connected with the 16C550 uart.

unimplemented_start_monitor:
	; Not implemented yet
	ret

UART_FREQUENCY: EQU 19660800	; 82C50 | 16C550 CLOCK

UART_BAUD_9600:		DW	UART_FREQUENCY/(9600 * 16)
UART_BAUD_14400:	DW	UART_FREQUENCY/(14400 * 16)
UART_BAUD_19200:	DW	UART_FREQUENCY/(19200 * 16)
UART_BAUD_38400:	DW	UART_FREQUENCY/(38400 * 16)
UART_BAUD_57600:	DW	UART_FREQUENCY/(57600 * 16)
UART_BAUD_115200:	DW	UART_FREQUENCY/(115200 * 16)

; Initialises the 16c550c UART for input/output
;configure_uart:
	; Configure the UART 16550 after a reset.
	; For the sake of definitely getting the job done, let's pause here for ages before doing it.
	; Without this pause the Z80 can get started before the UART is ready.
	; Don't ask me how I know this.
	;
	; Pass in the required BAUD rate divisor in b.
	; Pass in the required hardware flow control in c.
;	push bc
;	call long_pause
;	pop bc

;	LD		A,	0x00
;	OUT 	(uart_IER),A			; Disable interrupts

;    ld 		A,	80H                 ; Go into "Divisor Latch Setting mode"
;    out 	(uart_LCR),a            ; by writing 1 into bit 7 of the Line Control register
;    nop								; These tiny "nop" pauses probably do nothing. TODO: Try removing them!

;    ld 		A, b                    ; low byte of divisor
;    out 	(uart_tx_rx), A
;    nop
;    ld 		A, 0                          ; high byte
;    out 	(uart_IER), A
;    nop

;    ld a,03H                        ; Configure stop bits etc, and exit
                                    ; "Divisor latch setting mode"

;    out (uart_LCR),a                ; 8 bits, no parity, 1 stop bit, bit 7 = 0
;	nop								; a slight pause to allow the UART to get going

;	ld a, 0x81 						;%10000001					; Turn on FIFO, with trigger level of 8.
;	out (uart_ISR), a				; This definitely helps receive 16 chars very fast!

	;ld a, c
	;cp 0
	;jr z, flowcontrol_done
    
	;LD      A,0x00                  ;no flow control
	;ld a, %00100010
	;out (uart_MCR), a				; Enable auto flow control for /RTS and /CTS
;	ret
flowcontrol_done:
	nop
	nop
    ret

configure_uart: 
UART_INIT:	PUSH	AF
			LD		A,(HL)
			INC 	HL
			LD		H,(HL)
			LD 		L,A
			LD		A,0x00: OUT (uart_IER),A	; Disable interrupts
			LD		A,0x80: OUT (uart_LCR),A 	; Turn DLAB on
			LD		A,L:	OUT (uart_tx_rx),A	; Set divisor low
			LD		A,H:	OUT (uart_IER),A	; Set divisor high
			POP		AF:		OUT (uart_LCR),A	; Write out flow control bits 8,1,N
			LD 		A, 0x81						; Turn on FIFO, with trigger level of 8.
			OUT (uart_ISR), A					; This turn on the 16bytes buffer!	
			RET

UART_TX_WAIT		EQU	600		; Count before a TX times out

; A: Data read
; Returns:
; F = C if character read
; F = NC if no character read
;
UART_RX:	IN	A,(uart_LSR)		; Get the line status register
			AND 	0x01				; Check for characters in buffer
			ret	Z					; Just ret (with carry clear) if no characters
			IN	A,(uart_tx_rx)		; Read the character from the UART receive buffer
			SCF 						; Set the carry flag
			RET

; Read a character - waits for input
; NB is the non-blocking variant
;  A: ASCII character read
;  F: NC if no character read (non-blocking)
;  F:  C if character read (non-blocking)
;
Read_Char:              CALL    UART_RX
                        JR      NC,Read_Char
                        RET
; Read a character - NO waits for input
; NB is the non-blocking variant
;  A: ASCII character read
;  F: NC if no character read (non-blocking)
;  F:  C if character read (non-blocking)
Read_Char_NB:           JP      UART_RX

; Print A to the screen as an ASCII character, preserving all registers.
print_a:
UART_TX:	PUSH 	HL 
			PUSH 	DE 
			PUSH	BC						; Stack BC
			PUSH	AF 						; Stack AF
			LD	B,low  UART_TX_WAIT			; Set CB to the transmit timeout
			LD	C,high UART_TX_WAIT
1:			IN	A,(uart_LSR)			; Get the line status register
			AND 	0x60					; Check for TX empty
			JR	NZ,2F						; If set, then TX is empty, goto transmit
			DJNZ	1B: DEC	C: JR NZ,1B		; Otherwise loop
			POP	AF							; We've timed out at this point so
			OR	A							; Clear the carry flag and preserve A
			POP	BC							; Restore the stack
			POP DE 
			POP	HL
			RET	
2:			POP	AF							; Good to send at this point, so
			OUT	(uart_tx_rx),A			; Write the character to the UART transmit buffer
			call	delay2
			POP	BC							; Restore the stack
			POP DE 
			POP	HL
			SCF								; Set the carry flag
			RET
;******************************************************************
; This routine delay 746us
delay2:
			PUSH   AF
			LD     A, 0xFF          
delay2loop: DEC    A              
			JP     NZ, delay2loop  ; JUMP TO DELAYLOOP2 IF A <> 0.
			POP    AF
			RET

;    push af                         ; Store A for a bit
;print_a1:
;    in a,(uart_LSR)                 ; check UART is ready to send.
;    bit 5,a                         ; zero flag set to true if bit 5 is 0
;    jp z, print_a1                  ; non-zero = ready for next char.;

;    pop af                          ; UART IS READY, GET OLD "A" BACK
;    out (uart_tx_rx),a              ; AND SEND IT OUT
;	ret

newline:
	ld a,13
	call print_a
	ld a,10
	call print_a
	ret
	
space:
	ld a,32
	call print_a
	ret

; To receive a char over Serial we need to check if there is one. If not we return 0.
; If there is, we get it and return it (in a).
char_in:
	in a,(uart_LSR)			; get status from Line Status Register
	bit 0,a					; zero flag set to true if bit 0 is 0 (bit 0 = Receive Data Ready)
							; "logic 0 = no data in receive holding register."
	jp z,char_in1    		; zero = no char received
	in a,(uart_tx_rx)		; Get the incoming char
	ret						; Return it in A
char_in1:
	ld a,0					; Return a zero in A
	ret

char_available:
	in a,(uart_LSR)			; get status from Line Status Register
	bit 0,a					; zero flag set to true if bit 0 is 0 (bit 0 = Receive Data Ready)
							; "logic 0 = no data in receive holding register."
	jp z,char_available1	; zero = no char received
	ld a, $FF		        ; return true
	ret						; in A
char_available1:
	ld a,0					; Return a zero in A
	ret


long_pause:
	ld bc,65000
    jr pause0
medium_pause:
	ld bc,45000
    jr pause0
short_pause:
	ld bc,100
pause0:
	dec bc
	ld a,b
	or c
	jp nz,pause0
	ret

disk_toggle:
	in a, (uart_MCR)
	and %00000100
	jr z, disk_on
	; fall through to...
disk_off:
 	; disk light off
	in a, (uart_MCR)
	and %11111011
	out (uart_MCR), a
	ret

disk_on:
	; disk light on
	in a, (uart_MCR)
	or %00000100
	out (uart_MCR), a
	ret

user_on:
	; user light on
	in a, (uart_MCR)
	or %00000001
	out (uart_MCR), a
	ret
	
user_toggle:
	; user1 light invert
	in a, (uart_MCR)
	and %00000001
	jr z, user_on
	; fall through to...
user_off:
 	; user light off
	in a, (uart_MCR)
	and %11111110
	out (uart_MCR), a
	ret

rom_toggle:
	in a, (uart_MCR)
	and %00001000
	jr z, rom_off
	; fall through to...
rom_on:
	; rom light on
	in a, (uart_MCR)
	and %11110111
	out (uart_MCR), a
	ret
	
rom_off:
	; rom light off
	in a, (uart_MCR)
	or %00001000
	out (uart_MCR), a
	ret

	include "port_numbers.asm"
