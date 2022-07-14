; port_numbers.asm

; Here are the port numbers for various UART registers:
uart_tx_rx 		equ   0xB8   ; 	8
uart_IER 		equ   0xB9   ; 	9
uart_ISR 		equ   0xBA   ;  10  ; Also known as FCR
uart_LCR 		equ   0xBB   ;  11
uart_MCR 		equ   0xBC   ;  12  ; modem control reg
uart_LSR 		equ   0xBD   ;  13
uart_MSR 		equ   0xBE   ;  14
uart_scratch 	equ   0xBF   ;  15