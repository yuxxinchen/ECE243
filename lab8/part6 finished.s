.global _start
_start:
				LDR 	R3, =0xff200040   		// read switches at ff200040
				LDR		R3, [r3]				// outer loop delay

/* Nested loop */
/* The outer loop with delay read from switch value */
OUTER:			LDR		R1, OUTERCOUNT
				CMP		R1, R3
				BEQ		RESETO
				B		INNER
CC:				LDR		R1, OUTERCOUNT
				ADD		R1, #1
				STR		R1, OUTERCOUNT
				B		OUTER
				
/* The inner loop with fixed delay 1000 */
INNER:			LDR		R0, INNERCOUNT
				CMP		R0, #100
				BEQ		RESETI
				ADD		R0, #1
				STR		R0, INNERCOUNT
				B		INNER
RESETI:			MOV		R0, #0
				STR		R0, INNERCOUNT
				B		CC
/* Inner loop end */

RESETO:			MOV		R1, #0
				STR		R1, OUTERCOUNT
INCREMENT:		LDR		R1, =0xff200000			// base address of LEDRs
				LDR		R2, LEDVALUE
				ADD		R2, #1
				STR		R2, LEDVALUE
				STR		R2, [R1]
				B		OUTER
/* Outer loop end */
/****************************************************************/





				.global	 LEDVALUE
LEDVALUE:		.word	 0x0

                .global  INNERCOUNT
INNERCOUNT:     .word    0x0     
				.global  OUTERCOUNT
OUTERCOUNT:     .word    0x0 
                .global  RUN
RUN:            .word    0x1                  // initial value to increment COUNT