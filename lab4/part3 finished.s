               .equ      EDGE_TRIGGERED,    0x1
               .equ      LEVEL_SENSITIVE,   0x0
               .equ      CPU0,              0x01    // bit-mask; bit 0 represents cpu0
               .equ      ENABLE,            0x1

               .equ      KEY0,              0b0001
               .equ      KEY1,              0b0010
               .equ      KEY2,              0b0100
               .equ      KEY3,              0b1000

               .equ      IRQ_MODE,          0b10010
               .equ      SVC_MODE,          0b10011

               .equ      INT_ENABLE,        0b01000000
               .equ      INT_DISABLE,       0b11000000

/*********************************************************************************
 * Initialize the exception vector table
 ********************************************************************************/
                .section .vectors, "ax"

                B        _start             // reset vector
                .word    0                  // undefined instruction vector
                .word    0                  // software interrrupt vector
                .word    0                  // aborted prefetch vector
                .word    0                  // aborted data vector
                .word    0                  // unused vector
                B        IRQ_HANDLER        // IRQ interrupt vector
                .word    0                  // FIQ interrupt vector

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly code. The program 
 * responds to interrupts from a timer and the pushbutton KEYs in the FPGA.
 *
 * The interrupt service routine for the timer increments a counter that is shown
 * on the red lights LEDR by the main program. The counter can be stopped/run by 
 * pressing any of the KEYs.
 ********************************************************************************/
                .text
                .global  _start
_start:                                         
/* Set up stack pointers for IRQ and SVC processor modes */
                  MOV	   R1, #0b11010010
				  MSR	   CPSR_c, R1
				  LDR      SP, =0x40000
				  
				  MOV      R1, #0b11010011
				  MSR      CPSR_c, R1
				  LDR      SP, =0x20000

                  BL       CONFIG_GIC         // configure the ARM generic
                                              // interrupt controller
                  BL       CONFIG_PRIV_TIMER  // configure A9 Private Timer
                  BL       CONFIG_KEYS        // configure the pushbutton
                                              // KEYs port

/* Enable IRQ interrupts in the ARM processor */
                  MOV      R0, #0b01010011    // IRQ unmasked, MODE = SVC
             	  MSR      CPSR_c, R0
                  LDR      R5, =0xFF200000    // LEDR base address

/*main program*/
LOOP:             LDR      R3, COUNT          // global variable
                  STR      R3, [R5]           // write to the LEDR lights
                  B        LOOP                
          

/* Global variables */
                .global  COUNT
COUNT:          .word    0x0                  // used by timer
                .global  RUN
RUN:            .word    0x1                  // initial value to increment COUNT

/* Configure the A9 Private Timer to create interrupts at 0.25 second intervals */
CONFIG_PRIV_TIMER:                             
            	LDR		 R0, =0xFFFEC600  // base address of a9 private timer
				LDR		 R1, =50000000	   		// counter will be loaded with 2M -> 1 sec count down
				STR      R1, [r0]		   		// put it into the Load Register of the Counter
				MOV		 R1, #0b111	    		
				STR		 R1, [R0, #8]		    // turn on I, A and E bits in counter control register
				MOV      PC, LR
				
				
                   
/* Configure the pushbutton KEYS to generate interrupts */
CONFIG_KEYS:                                    
                LDR      R0, =0xFF200050	    // pushbutton KEY base address
				MOV      R1, #0x7
				STR      R1, [R0, #0x8]
                MOV      PC, LR

/*--- IRQ ---------------------------------------------------------------------*/
IRQ_HANDLER:	PUSH     {R0-R7, LR}
				/* Read the ICCIAR from the CPU interface */
          	  	LDR      R4, =0xFFFEC100	    // 0xFFFEC100 is the base of CPU interface
           		LDR      R5, [R4, #0xC]         // read from ICCIAR
CHECK_INTERRUPT:CMP      R5, #73
				BEQ		 KEY_ISR			    // KEYS caused interrupt
				CMP      R5, #29
				BEQ		 PRIV_TIMER_ISR			// A9 Private Timer caused interrupt
				B		 CHECK_INTERRUPT				
EXIT_IRQ:		/* Write to the End of Interrupt Register (ICCEOIR) */
             	STR      R5, [R4, #0x10]        // write to ICCEOIR
				POP      {R0-R7, LR}
				SUBS     PC, LR, #4

/****************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine toggles the RUN global variable.
 ***************************************************************************************/
                .global  KEY_ISR
KEY_ISR:        LDR		 R0, =0xFF200050		// base address of KEY
				LDR		 R2, [R0, #0xc]			// read Edgecapture
				STR		 R2, [R0, #0xc]			// clear the interrupt
				CMP 	 R2, #1
				BEQ		 STOP
				CMP 	 R2, #2
				BEQ		 DOUBLE
				CMP 	 R2, #4
				BEQ		 HALVED
				
STOP:			LDR		 R1, RUN				// R1 now has the value of RUN
				EOR		 R1, #1					// invert the value of RUN
				STR		 R1, RUN				// update the RUN value
				LDR		 R3, COUNT
				ADD		 R1, R3
				STR		 R1, COUNT
				LDR		 R0, =0xFF200050
				STR		 R2, [R0, #0xc]			// clear the interrupt
                B		 EXIT_IRQ
				
DOUBLE:			/*Reconfigure the A9 Private Timer*/
				LDR		 R0, =0xFFFEC600  		// base address of a9 private timer
				LDR		 R1, [R0]
				LSR		 R1, #1					// shift left by 1 bit divide the# by 2
				STR		 R1, [R0]
				
				LDR		 R0, =0xFF200050
				STR		 R2, [R0, #0xc]			// clear the interrupt
				B		 EXIT_IRQ
				
HALVED:			/*Reconfigure the A9 Private Timer*/
				LDR		 R0, =0xFFFEC600  		// base address of a9 private timer
				LDR		 R1, [R0]
				LSL		 R1, #1					// shift right by 1 bit multiply the# by 2
				STR      R1, [r0]

				LDR		 R0, =0xFF200050
				STR		 R2, [R0, #0xc]			// clear the interrupt
				B		 EXIT_IRQ
				
/******************************************************************************
 * A9 Private Timer interrupt service routine
 *                                                                          
 * This code toggles performs the operation COUNT = COUNT + RUN
 *****************************************************************************/
                .global    TIMER_ISR
PRIV_TIMER_ISR:	// 0.25s reached, increment operation
				LDR		 R0, =0xFFFEC600
				LDR		 R1, COUNT
				LDR		 R2, RUN
				ADD		 R1, R2
				STR		 R1, COUNT				// update COUNT global variable
				MOV		 R3, #0x1
				STR		 R3, [R0, #0xC]	    	// reset interrupt status register
                B		 EXIT_IRQ
				//MOV      PC, LR
/* 
 * Configure the Generic Interrupt Controller (GIC)
*/
                .global  CONFIG_GIC
CONFIG_GIC:
                PUSH     {LR}
                MOV      R0, #29
                MOV      R1, #CPU0
                BL       CONFIG_INTERRUPT
                
                /* Enable the KEYs interrupts */
                MOV      R0, #73
                MOV      R1, #CPU0
                /* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
                BL       CONFIG_INTERRUPT

                /* configure the GIC CPU interface */
                LDR      R0, =0xFFFEC100        // base address of CPU interface
                /* Set Interrupt Priority Mask Register (ICCPMR) */
                LDR      R1, =0xFFFF            // enable interrupts of all priorities levels
                STR      R1, [R0, #0x04]
                /* Set the enable bit in the CPU Interface Control Register (ICCICR). This bit
                 * allows interrupts to be forwarded to the CPU(s) */
                MOV      R1, #1
                STR      R1, [R0]
    
                /* Set the enable bit in the Distributor Control Register (ICDDCR). This bit
                 * allows the distributor to forward interrupts to the CPU interface(s) */
                LDR      R0, =0xFFFED000
                STR      R1, [R0]    
    
                POP      {PC}
/* 
 * Configure registers in the GIC for an individual interrupt ID
 * We configure only the Interrupt Set Enable Registers (ICDISERn) and Interrupt 
 * Processor Target Registers (ICDIPTRn). The default (reset) values are used for 
 * other registers in the GIC
 * Arguments: R0 = interrupt ID, N
 *            R1 = CPU target
*/
CONFIG_INTERRUPT:
                PUSH     {R4-R5, LR}
    
                /* Configure Interrupt Set-Enable Registers (ICDISERn). 
                 * reg_offset = (integer_div(N / 32) * 4
                 * value = 1 << (N mod 32) */
                LSR      R4, R0, #3               // calculate reg_offset
                BIC      R4, R4, #3               // R4 = reg_offset
                LDR      R2, =0xFFFED100
                ADD      R4, R2, R4               // R4 = address of ICDISER
    
                AND      R2, R0, #0x1F            // N mod 32
                MOV      R5, #1                   // enable
                LSL      R2, R5, R2               // R2 = value

                /* now that we have the register address (R4) and value (R2), we need to set the
                 * correct bit in the GIC register */
                LDR      R3, [R4]                 // read current register value
                ORR      R3, R3, R2               // set the enable bit
                STR      R3, [R4]                 // store the new register value

                /* Configure Interrupt Processor Targets Register (ICDIPTRn)
                  * reg_offset = integer_div(N / 4) * 4
                  * index = N mod 4 */
                BIC      R4, R0, #3               // R4 = reg_offset
                LDR      R2, =0xFFFED800
                ADD      R4, R2, R4               // R4 = word address of ICDIPTR
                AND      R2, R0, #0x3             // N mod 4
                ADD      R4, R2, R4               // R4 = byte address in ICDIPTR

                /* now that we have the register address (R4) and value (R2), write to (only)
                 * the appropriate byte */
                STRB     R1, [R4]
    
                POP      {R4-R5, PC}
                .end   
