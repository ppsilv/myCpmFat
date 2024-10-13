; uart routines
; These are routines connected with the 16C550 uart.

unimplemented_start_monitor:
	; Not implemented yet
	ret

;UART_FREQUENCY: EQU 1843200	; 82C50 | 16C550 CLOCK O CLOCK MÁXIMO É DE 14,9MHz
;UART_FREQUENCY: EQU 7372800	; 82C50 | 16C550 CLOCK O CLOCK MÁXIMO É DE 14,9MHz
UART_FREQUENCY: EQU 4915200	; 82C50 | 16C550 CLOCK O CLOCK MÁXIMO É DE 14,9MHz

UART_BAUD_9600:		DW	UART_FREQUENCY/(  9600 * 16)
UART_BAUD_14400:	DW	UART_FREQUENCY/( 14400 * 16)
UART_BAUD_19200:	DW	UART_FREQUENCY/( 19200 * 16)
UART_BAUD_38400:	DW  UART_FREQUENCY/( 38400 * 16)
UART_BAUD_57600:	DW	UART_FREQUENCY/( 57600 * 16)
UART_BAUD_115200:	DW	UART_FREQUENCY/(115200 * 16)

;UART_BAUD: DW $12  ; 9600 para oscilador 1843200
;UART_BAUD: DW $06  ;19200 para oscilador 1843200
;UART_BAUD: DW $03  ;38400 para oscilador 1843200
;UART_BAUD: DW $12  ;38400 para oscilador 7372800
UART_BAUD: DW $08  ;38400 para oscilador 4915200

; Initialises the 16c550c UART for input/output

flowcontrol_done:
	nop
	nop
    ret

configure_uart: 
			PUSH	AF
			LD		A,(HL)
			INC 	HL
			LD		H,(HL)
			LD 		L,A
			LD		A,$00;
			OUT (uart_IER),A	; Disable interrupts
			LD		A,$80;
			OUT (uart_LCR),A 	; Turn DLAB on
			LD		A,L;
			OUT (uart_DLL),A	; Set divisor low
			LD		A,H;
			OUT (uart_DLH),A	; Set divisor high
			POP		AF;
			OUT (uart_LCR),A	; Write out flow control bits 8,1,N
			LD 		A,$81;
			OUT (uart_ISR),A	; Turn on FIFO, with trigger level of 8.
								                ; This turn on the 16bytes buffer!
			RET

configure_uart_cpm:
			LD		H, 0x00
			LD 		L,A
			LD		A,0x00
			OUT (uart_IER),A	; Disable interrupts
			LD		A,0x80
			OUT (uart_LCR),A 	; Turn DLAB on
			LD		A,L
			OUT (uart_tx_rx),A	; Set divisor low
			LD		A,H
			OUT (uart_IER),A	; Set divisor high
			LD		A, 0x03
			OUT (uart_LCR),A	; Write out flow control bits 8,1,N
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
			AND 	$01				; Check for characters in buffer
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
LOOP_UART_TX:
			IN	A,(uart_LSR)			; Get the line status register
			AND 	$60					; Check for TX empty
			JR	NZ,	OUT_UART_TX				; If set, then TX is empty, goto transmit
			DJNZ	LOOP_UART_TX
			DEC	C
			JR NZ, LOOP_UART_TX		; Otherwise loop
			POP	AF							; We've timed out at this point so
			OR	A							; Clear the carry flag and preserve A
			POP	BC							; Restore the stack
			POP DE 
			POP	HL
			RET	
OUT_UART_TX:			
			POP	AF							; Good to send at this point, so
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
			LD     A, $FF
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

	include "cfg_port_numbers.asm"
