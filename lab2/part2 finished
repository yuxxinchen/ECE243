/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R3, #TEST_NUM   // load the data word ...
          LDR     R1, [R3]        // into R1
          MOV     R0, #0          // R0 will hold the result
		  MOV     R5, #0		  // R5 has the final result
		  BL      ONES			  // branch and link to the subroutine ONES
		  B       END

/*Subroutine that use R1 to receive input 
data and R0 for resulting the result*/
ONES:     CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     END_CHECK            
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ONES            
	      

END_CHECK:CMP     R0, R5		  // if larger, longest string update, else load new
		  BGT     UPDATE		  
		  B       LOAD	  
		  
UPDATE:   MOV     R5, R0          // update the longest string of 1's
		  B       LOAD     

LOAD:     LDR     R1, [R3,#4]!    // r1 <- [r1+4]
		  CMP     R1, #0
		  BEQ     DONE
		  MOV     R0, #0		  // change the R0 counter back to zero 
		  B       ONES

DONE:     MOV     pc, lr

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
