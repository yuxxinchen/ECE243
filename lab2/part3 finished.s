/* Program that counts consecutive 1's */

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
		  B       END

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
ALTERNATE:LSR     R2, R1, #1      // perform SHIFT, followed by XOR
          EOR     R1, R1, R2      
		  B       AL_ONES
AL_ONES:  CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     AL_CHECK            
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       AL_ONES 
AL_CHECK: ADD     R0, #1
		  CMP     R0, R7		  // if larger, longest string update, else load new
		  BGT     AL_UPDATE		  
		  B       AL_LOAD
AL_UPDATE:MOV     R7, R0          // update the longest string of 1's
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
