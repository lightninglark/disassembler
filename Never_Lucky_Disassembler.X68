*-----------------------------------------------------------
* Title      : Never Lucky Disassembler
* Written by : Henry Hong, Ryan Palm, Joshua Plantilla
* Date       : April 23, 2017
* Description: Final Project for CSS 422. This program
*              translates machine code into assembly (68k)
*              language.
*-----------------------------------------------------------

START       ORG         $1000       *Start program
            JSR         INTRO       *Display Intro Message
            JSR         GET_INPUT   *Prompt user for input, convert input from ascii to hex and assign to sta_addr and end_addr
            
            *Assuming all input error checking is done before the next call
            
            *JSR         INIT_LOOP   *Initialize loop variables
            *JSR         DECODE_LOOP *Enters maine decode loop
            
            JSR         IDENTIFY
            * final call of program, may need to be removed if we jump directly to DONE from the loop
            JMP         DONE        *End Program               
               
*-----------------------INTRO-------------------------------
INTRO       LEA         NL_INTRO,A1 *Load INTRO1 message into A1
            MOVE.B      #14,D0      *Trap task 14, display intro
            TRAP        #15         
            RTS         

*--------------------GET_INPUT------------------------------
GET_INPUT   LEA         STA_MSG,A1  *Load STA_MSG into A1
            MOVE.B      #14,D0      *Trap task 14, display start address msg
            TRAP        #15         
            
            LEA         STA_ADDR,A1 *Store input in STA_ADDR variable
            MOVE.B      #2,D0       *Trap task 2, collect start address from input, length in D1
            TRAP        #15         
            
            JSR         PROC_STA    *Process Start address, check for errrors and convert to HEX
            CLR.L       D1          *Clear input length from D1
            
            LEA         END_MSG,A1  *Load END_MSG into A1
            MOVE.B      #14,D0      *Trap task 14, display end address msg
            TRAP        #15
            
            LEA         END_ADDR,A1 *Store input in END_ADDR variable
            MOVE.B      #2,D0       *Trap task 2, collect end address from input, length in d1
            TRAP        #15         
            
            JSR         PROC_END    *Process End Address, check for errors and convert to HEX
            CLR.L       D1          *Clear input length from D1
            
            RTS
            
*--------------------PROC_STA-------------------------------
PROC_STA    *TODO: Check for Null, bad length, ODD address, range, convert to hex
            JSR         ASCII_HEX   *Convert input into Hex
            MOVEA.L     D3,A5       *Move hex to STA_ADDR
            CLR.L       D3          *Clear D3
            RTS                     

*--------------------PROC_END-------------------------------
PROC_END    *TODO: Check for Null, bad length, odd address, range, convert to hex
            *      does not fall before start
            JSR         ASCII_HEX   *Convert input into Hex
            MOVE.L      D3,A6       *Move hex to END_ADDR
            CLR.L       D3          *Clear D3
            RTS

*-------------------ASCII_HEX-------------------------------
ASCII_HEX   CMPI.B      #$0,D1      *See if all characters are converted
            BEQ         AH_DONE     *End subroutine if all converted
            MOVE.B      (A1)+,D2    *Move first ASCII hex value into D2
            MOVE.B      #$39,D4     *Number to compare input to to select num or letter 
            CMP.B       D4,D2       *Check if ascii code is for a number or letter
            BLE         NUM         *Codes less than $39 imply a number, so branch
            BRA         LET         *If not a number, must be a letter.            
AH_DONE     RTS

NUM         MOVE.B      #$30,D4     *move $30 into D4 (ammount to sub from value if number)
            SUB.B       D4,D2       *convert to hexadecimal number
            BRA         FORMAT      *branch to subroutine to store converted hex number
            
LET         MOVE.B      #$37,D4     *move $37 into D4 (ammount to sub from value if letter)
            SUB.B       D4,D2       *convert to hexadecimal letter
            BRA         FORMAT      *branch to subroutine to store converted hex letter

FORMAT      SUBI.B      #$1,D1      *Decrement D2 counter, one character has been converted
            ADD.B       D2,D3       *Store converted number in D3
            CMPI.B      #$0,D1      *Check if we're all done converting
            BEQ         ASCII_HEX   *If not continue conversion
            ASL.L       #4,D3       *Shift bits to the left to correct position
            BRA         ASCII_HEX   *Branch back to label
            
*-------------------INIT_LOOP-------------------------------
*INIT_LOOP   MOVEA.L     

*-----------------------IDENTIFY----------------------------
* Purpose: IDENTIFY_LOOP takes a data register input (D7) and identifies what instruction it is.
*          $AA is saved to D6 if OPCode is determined to be correct, or $FF if incorrect
*          ie) <D7> = input <D6> = $AA
* Assumption: When loop is called, D7 contains the next new machine code instruction
*-----------------------------------------------------------
IDENTIFY    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2      *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
F_CMP_0     CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         F_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FIRST_0     *If the first hex value is 0, jump to First_0
            RTS
            
F_CMP_1     CMP.B       #$1,D3
            BNE         F_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FIRST_1 
            RTS
           
F_CMP_2     CMP.B       #$2,D3
            BNE         F_CMP_3 
            JSR         FIRST_2
            RTS
            
F_CMP_3     CMP.B       #$3,D3
            BNE         F_CMP_4
            JSR         FIRST_3 
            RTS
           
F_CMP_4     CMP.B       #$4,D3
            BNE         F_CMP_5
            JSR         FIRST_4
            RTS
            
F_CMP_5     CMP.B       #$5,D3
            BNE         F_CMP_6
            JSR         FIRST_5
            RTS
            
F_CMP_6     CMP.B       #$6,D3
            BNE         F_CMP_7
            JSR         FIRST_6
            RTS
            
F_CMP_7     CMP.B       #$7,D3
            BNE         F_CMP_8
            JSR         FIRST_7
            RTS
            
F_CMP_8     CMP.B       #$8,D3
            BNE         F_CMP_9
            JSR         FIRST_8
            RTS
            
F_CMP_9     CMP.B       #$9,D3
            BNE         F_CMP_A
            JSR         FIRST_9
            RTS
            
F_CMP_A     CMP.B       #$A,D3
            BNE         F_CMP_B
            JSR         FIRST_A
            RTS
            
F_CMP_B     CMP.B       #$B,D3
            BNE         F_CMP_C
            JSR         FIRST_B
            RTS
            
F_CMP_C     CMP.B       #$C,D3
            BNE         F_CMP_D
            JSR         FIRST_C
            RTS
            
F_CMP_D     CMP.B       #$D,D3
            BNE         F_CMP_E
            JSR         FIRST_D
            RTS
            
F_CMP_E     JSR         FIRST_E     *If first hex value is not 0-D, it must be E. Branch to First_E
            RTS
                        

*------------------------First_0----------------------------
*Purpose: First_0 is a subroutine of IDENTIFY. If First_0 is branched to, that means the first
*         four digits of the machine code are 0000.
*         Possible instructions are: ADDI, SUBI    
*-----------------------------------------------------------           
FIRST_0 RTS *Placeholder
          
FIRST_1
FIRST_2
FIRST_3
FIRST_4
FIRST_5
FIRST_6
FIRST_7
FIRST_8
FIRST_9
FIRST_A
FIRST_B
FIRST_C
FIRST_D
FIRST_E
            
*-----------------------DONE--------------------------------
DONE        MOVE.B      #9,D0       *Load 9 into D0 (trap task)
            TRAP        #15         *Halt program, Trap#15 task 9
            
*---------------Variables and Constants---------------------
CR          EQU         $0D
LF          EQU         $0A

NL_INTRO    DC.B        '------------TEAM NEVER LUCKY------------',CR,LF
            DC.B        'Henry Hong, Ryan Palm, Joshua Plantilla',CR,LF
            DC.B        'CSS 422 Final Project: 68k Disassembler',CR,LF
            DC.B        '----------------------------------------',CR,LF,0
            
STA_MSG     DC.B        'Enter starting address (ALL CAPS):',0
END_MSG     DC.B        'Enter ending address (ALL CAPS):',0

STA_ADDR    DS.B        80
END_ADDR    DS.B        80
            

            END         START       *LAST LINE




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
