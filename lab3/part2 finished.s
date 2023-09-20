.global _start
.equ  KEY_BASE, 0xFF200050
.equ  HEX_BASE, 0xFF200020
//.equ  MPCORE_PRIV_TIMER, 0xFFFEC600 // base of private timer

_start:     LDR  	R4, =KEY_BASE		// set r4 to KEY BASE
		    MOV  	R5, #BIT_CODES
			LDR  	R6, =HEX_BASE
		    MOV  	R0, #0				// R0 as a digital counter(99)
			MOV		R8, #0
			
	   


POLL:       LDR		R3, [R4, #0xc] 		// load edge capture register
			CMP		R3, #0
			BEQ		INCREMENT
			B		CHECK
CHECK:		CMP		R8, #0
			BEQ		STOP				// stop
			B		START
START:		EOR		R8, #1				// invert R8 for next time
			CMP		R3, #1
			BEQ		DISPLAY0
			CMP		R3, #2
			BEQ		DISPLAY1
			CMP		R3, #4
			BEQ		DISPLAY2
			CMP		R3, #8
			BEQ		DISPLAY3
DISPLAY0:	MOV		R3, #0x1			// turn off edge capture bit
			STR		R3, [R4, #0xc]		// by writing 1 into bit 2
			B		INCREMENT
DISPLAY1:	MOV		R3, #0x2			// turn off edge capture bit
			STR		R3, [R4, #0xc]		// by writing 1 into bit 2
			B		INCREMENT
DISPLAY2:	MOV		R3, #0x4			// turn off edge capture bit
			STR		R3, [R4, #0xc]		// by writing 1 into bit 2
			B		INCREMENT
DISPLAY3:	MOV		R3, #0x8			// turn off edge capture bit
			STR		R3, [R4, #0xc]		// by writing 1 into bit 2
			B		INCREMENT
STOP:		EOR		R8, #1				// invert R8 for next time
			CMP		R3, #1
			BEQ		STOP0
			CMP		R3, #2
			BEQ		STOP1
			CMP		R3, #4
			BEQ		STOP2
			CMP		R3, #8
			BEQ		STOP3
STOP0:		MOV		R3, #0x1			// turn off edge capture bit
			STR		R3, [R4, #0xc]		// by writing 1 into bit 2
			B		WAIT
STOP1:		MOV		R3, #0x2			// turn off edge capture bit
			STR		R3, [R4, #0xc]		// by writing 1 into bit 2
			B		WAIT
STOP2:		MOV		R3, #0x4			// turn off edge capture bit
			STR		R3, [R4, #0xc]		// by writing 1 into bit 2
			B		WAIT
STOP3:		MOV		R3, #0x8			// turn off edge capture bit
			STR		R3, [R4, #0xc]		// by writing 1 into bit 2
			B		WAIT
WAIT:		LDR		R3, [R4, #0xc]
			CMP		R3, #0
			BNE		CHECK
			B		WAIT


ZERO:		MOV		R0, #0
			B		DO_DELAY
INCREMENT:	ADD     R0, #1			    // increment the counter
			CMP		R0, #99
			BGT		ZERO
DO_DELAY:   LDR     R7, =500000
SUB_LOOP:   SUBS    R7, #1
		    BNE     SUB_LOOP			// Be equal to zero is 1 second
			B		DISPLAY	



/*Display the incremented number*/		  
DISPLAY:    BL  	DIVIDE				// tens digit in R1 (remainder in R0)
			BL      SEG7_CODE	
			LSL     R2, #8
			ORR     R2, R1				// R1 contains the bit code for HEX1-0
			STR     R2, [R6]
			B       POLL 
SEG7_CODE:  ADD     R2, R5, R2          // index into the BIT_CODES "array"
            LDRB    R2, [R2]            // load the bit pattern (to be returned)
			ADD     R1, R5, R1
			LDRB    R1, [R1]
            MOV     pc, lr  
DIVIDE:     MOV		R1, R0
	   		MOV     R2, #0
CONT:       CMP     R1, #10
            BLT     DIV_END
            SUB     R1, #10
            ADD     R2, #1
            B       CONT
DIV_END:    MOV     pc, lr              // tens digit in R2 (remainder in R1)
            


BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2                  // pad with 2 bytes to maintain word alignment
	