/* Program that converts a binary number to decimal */
           
           .text               // executable code follows
           .global _start
_start:
            MOV    R4, #N
            MOV    R5, #Digits  // R5 points to the decimal digits storage location
            LDR    R4, [R4]     // R4 holds N
            MOV    R0, R4       // parameter for DIVIDE goes in R0
	    MOV    R6, #0
	    MOV    R3, #3       // decrement the decimal digits storage location
            MOV    R7, #Divisor // pass the first divisor to the subroutine
	    LDR    R1, [R7]
            BL     DIVIDE
            STRB   R0, [R5]     // Ones digit is in R0
END:        B      END

/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0 */

DIVIDE:     MOV    R2, #0  	    
CONT:       CMP    R0, R1     // R0 has the remainder left, R1 has the updated devisor
            BLT    DIV_END
            SUB    R0, R1
            ADD    R2, #1     // R2 has the corresponding digit
            B      CONT

DIV_END:   
	    ADD    R6, R5, R3 // R6<-R5+R3
            STRB   R2, [R6]
	    SUBS   R3, #1
	    BEQ    DONE	      // if result is equal to 0, branch to DONE
            LDR    R1, [R7, #4]! // get the new devisor
	    B      DIVIDE
	    

DONE:
	    MOV    R6, #0
	    MOV    R7, #Divisor     
	    MOV    PC, LR

N:          .word  1111       // the decimal number to be converted
Digits:     .space 4          // storage space for the decimal digits
Divisor:    .word 1000, 100, 10    // the decimal number devisor for the division
 
            
            .end

