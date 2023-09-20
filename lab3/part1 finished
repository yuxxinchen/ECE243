.global _start
.equ  KEY_BASE, 0xFF200050
.equ  HEX_BASE, 0xFF200020

_start:
		  LDR  R5, =KEY_BASE		// set r5 to KEY0
		  LDR  R9, =0xFF200020      // set r9 to base address of HEX3-HEX0
		  MOV  R2, #0 				// Use R2 to be the 9 counter
		  MOV  R10, #0				
		  STR  R10, [R9]			// initialize the display
		  B    POLL
	
	
POLL:     LDR  R0, [R5]				// check KEY0 first
		  CMP  R0, #1
		  BEQ  KEY0_wait			// if KET0 is pressed
		  LDR  R1, [R5]				// check KEY1
		  CMP  R1, #2
		  BEQ  KEY1_wait
		  LDR  R1, [R5]				// check KEY2
		  CMP  R1, #4
		  BEQ  KEY2_wait
		  LDR  R1, [R5]				// check KEY3
		  CMP  R1, #8
		  BEQ  KEY3_wait
		  B    POLL
	
/*If KEY0 is pressed on the board, 
should set the number displayed on HEX0 to 0*/
KEY0_wait:
		  LDR  R0, [R5]				// wait until the button is released
		  CMP  R0, #0
		  BEQ  KEY0	
		  B    KEY0_wait
KEY0:	  MOV  R0, #BIT_CODES       // set number displayed on HEX0 to 0
		  MOV  R2, #0
		  LDRB R0, [R0]             // R0 gets the bit code for value 0
		  STR  R0, [R9]             // display the number 0
		  B    POLL


/*If KEY1 is pressed, should increment the displayed number, 
but don’t let the number go above 9*/
KEY1_wait:
		  LDR  R1, [R5]				// wait until the button is released
		  CMP  R1, #0
		  BEQ  CHECK_NINE
		  B    KEY1_wait
CHECK_NINE:
		  CMP  R2, #9
		  BEQ  NINE
		  B    INCREMENT
NINE:	  MOV  R0, #BIT_CODES       // set number displayed on HEX0 to 0
		  ADD  R0, #9
		  LDRB R0, [R0]             // R0 gets the bit code for value 9
		  STR  R0, [R9]				// display the incremented number
		  B    POLL
INCREMENT:	    
		  ADD  R2, #1				// increment the counter
		  MOV  R0, #BIT_CODES       // set number displayed on HEX0 to 0
		  ADD  R0, R2
		  LDRB R0, [R0]             // R0 gets the bit code for value 0
		  STR  R0, [R9]				// display the incremented number
		  B    POLL
		  

/*If KEY2 is pressed then decrement the number, 
but don’t let the number go below 0 */
KEY2_wait:
		  LDR  R1, [R5]				// wait until the button is released
		  CMP  R1, #0
		  BEQ  CHECK_ZERO
		  B    KEY2_wait
CHECK_ZERO:
		  CMP  R2, #0
		  BEQ  ZERO
		  B    DECREMENT
ZERO:	  MOV  R0, #BIT_CODES       // set number displayed on HEX0 to 0
		  LDRB R0, [R0]             // R0 gets the bit code for value 0
		  STR  R0, [R9]             // display the number 0
		  B    POLL
DECREMENT:	    
		  SUB  R2, #1				// increment the counter
		  MOV  R0, #BIT_CODES       // set number displayed on HEX0 to 0
		  ADD  R0, R2
		  LDRB R0, [R0]             // R0 gets the bit code for value 0
		  STR  R0, [R9]				// display the incremented number
		  B    POLL


/*Pressing KEY3 should blank the display*/
KEY3_wait:
		  LDR  R1, [R5]				// wait until the button is released
		  CMP  R1, #0
		  BEQ  KEY3
		  B    KEY3_wait
KEY3:	  STR  R10, [R9]			// clear the display
		  MOV  R2, #0
		  B    RESTART  
RESTART:  LDR  R0, [R5]
		  CMP  R0, #0
		  BEQ  RESTART
		  B    KEY0_wait
	
	

//...//	
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
