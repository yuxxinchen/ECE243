          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R3, #TEST_NUM   // load the data word ...
          LDR     R1, [R3]        // into R1
          MOV     R0, #0          // R0 will hold the result
		  MOV     R5, #0		  // R5 has the final result
		  BL      ONES			  // branch and link to the subroutine ONES
		  MVN	  R1, R1		  // flip the whole number
		  BL      ZEROS			  // branch and link to the subroutine ZEROS
		  BL      ALTERNATE		  // branch and link to the subroutine ALTERNATE
		  BL      DISPLAY
		  
		  
/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0 */
DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, #10
            BLT    DIV_END
            SUB    R0, #10
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR
			
/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit pattern to be written to the HEX display*/
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment


/*subroutine for counting longest 1's*/
ONES:     CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     ONES_END_CHECK            
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ONES            		  
ONES_END_CHECK:
		  CMP     R0, R5		  // if larger, longest string update, else load new
		  BGT     ONES_UPDATE		  
		  B       ONES_LOAD	  		  
ONES_UPDATE:   
		  MOV     R5, R0          // update the longest string of 1's
		  B       ONES_LOAD     
ONES_LOAD:     
		  LDR     R1, [R3,#4]!    // r1 <- [r3+4]
		  CMP     R1, #0
		  BEQ     DONE
		  MOV     R0, #0		  // change the R0 counter back to zero 
		  B       ONES

/*subroutine for counting longest 0's*/
ZEROS:	  CMP     R1, #0		  // loop until the data contains no more 0's
		  BEQ	  ZEROS_END_CHECK
		  LSR     R2, R1, #1      // perform SHIFT, followed by OR
		  AND	  R1, R1, R2
		  ADD     R0, #1          // count the string length so far
		  B       ZEROS
ZEROS_END_CHECK:
		  CMP     R0, R6		  // if larger, longest string update, else load new
		  BGT     ZEROS_UPDATE		  
		  B       ZEROS_LOAD	  		  
ZEROS_UPDATE:
		  MOV     R6, R0          // update the longest string of 0's
		  B       ZEROS_LOAD     
ZEROS_LOAD:
		  LDR     R1, [R3,#4]!    // r1 <- [r3+4]
		  CMP     R1, #0
		  MVN     R1, R1
		  BEQ     DONE
		  MOV     R0, #0		  // change the R0 counter back to zero
		  B       ZEROS

/*subroutine for counting longest alternating 1's and 0's*/
ALTERNATE:LDR     R2, #MAX    // perform SHIFT, followed by XOR
          EOR     R1, R1, R2
		  MOV     R4, #0
		  MVN     R8, R1
		  B       AL_ONES
AL_ONES:  CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     AL_ZEROS           
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1,R1, R2      
          ADD     R0, #1          // R0 has the longest string of 0's
          B       AL_ONES 
AL_ZEROS: CMP     R8, #0
		  BEQ     AL_CHECK            
          LSR     R2, R8, #1      // perform SHIFT, followed by AND
          AND     R8, R8, R2      
          ADD     R4, #1          // R4 has the longest string of 0's
          B       AL_ZEROS 		  
AL_CHECK: CMP     R0, R4		  // determine zero or one dominate
		  BGE     AL_CMP	
		  MOV     R7, R4
		  B       AL_LOAD
AL_CMP:	  MOV     R2, R0          // update the longest string of 1's
		  CMP     R2, R7
		  BGT     AL_UPDATE
		  B       AL_LOAD
AL_UPDATE:MOV     R7, R2
		  B       AL_LOAD
AL_LOAD:  LDR     R1, [R3,#4]!    // r1 <- [r3+4]
		  CMP     R1, #0
		  BEQ     DONE
		  MOV     R0, #0		  // change the R0 counter back to zero 
		  B       ALTERNATE
		  

DONE:     MOV     R3, #TEST_NUM
		  LDR     R1, [R3]		  //reload R1
		  MOV	  R0, #0		  //reload R0
	      MOV     pc, lr

END:      B       END             

/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            MOV     R0, R5          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R4, R0			// R4 contains the bit code for HEX1-0
            //...
            MOV     R0, R6			// display R6 on HEX3-2
			BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
			MOV     R9, R1			// save the tens digit
		    BL      SEG7_CODE 
			MOV     R5, R0			// save bit code for ones digit in R5
			MOV     R0, R9			// R0 has the tens digit
			BL      SEG7_CODE		// R0 now has the bit code for tens digit
			LSL     R0, #24
			LSL     R5, #16
			ORR     R5, R0
			ORR     R4, R5
            //...
            STR     R4, [R8]        // display the numbers from R6 and R5
            LDR     R8, =0xFF200030 // base address of HEX5-HEX4
            //...
            MOV     R0, R7			// display R6 on HEX5-4
			BL      DIVIDE
			MOV     R9, R1			// save the tens digit
			BL      SEG7_CODE
			MOV     R6, R0			//save bit code for ones digit in R6
			MOV     R0, R9			// R0 has the tens digit
			BL      SEG7_CODE		// R0 now has the bit code for tens digit
			LSL     R0, #8
			ORR     R4, R6, R0
            //...
            STR     R4, [R8]        // display the number from R7
			B       END


MAX:      .word   1431655765
TEST_NUM: .word   0x103fe00f
	      .word   0x9957a585
		  .word   0x99FFA581
		  .word   0x99802581
		  .word   0x998AA591
		  .word   0xDBAAA791
		  .word   0xD82AA781
		  .word   0xC02A8780
		  .word   0xCF2A87AE
		  .word   0xCFFF87AE
		  .word   0
		  
		  .end                      