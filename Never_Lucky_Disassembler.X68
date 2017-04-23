*-----------------------------------------------------------
* Title      : Never Lucky Disassembler
* Written by : Henry Hong, Ryan Palm, Joshua Plantillia
* Date       : April 23, 2017
* Description: Final Project for CSS 422. This program
*              translates machine code into assembly (68k)
*              language.
*-----------------------------------------------------------

START       ORG         $1000       *Start program
            JSR         INTRO       *Display Intro Message
            JSR         GET_INPUT   *Prompt user for input
            
            *TODO: Loop over machine code line by line
            *analyzing each line for instructions, and dumping data lines.
            
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
            MOVE.L      D3,STA_ADDR *Move hex to STA_ADDR
            CLR.L       D3          *Clear D2
            RTS                     

*--------------------PROC_END-------------------------------
PROC_END    *TODO: Check for Null, bad length, odd address, range, convert to hex
            *      does not fall before start
            JSR         ASCII_HEX   *Convert input into Hex
            MOVE.L      D3,END_ADDR *Move hex to END_ADDR
            CLR.L       D3          *Clear D2
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
            
*-----------------------DONE--------------------------------
DONE        MOVE.B      #9,D0       *Load 9 into D0 (trap task)
            TRAP        #15         *Halt program, Trap#15 task 9
            
*---------------Variables and Constants---------------------
CR          EQU         $0D
LF          EQU         $0A

NL_INTRO    DC.B        '------------TEAM NEVER LUCKY------------',CR,LF
            DC.B        'Henery Hong, Ryan Palm, Joshua Plantilla',CR,LF
            DC.B        'CSS 422 Final Project: 68k Disassembler',CR,LF
            DC.B        '----------------------------------------',CR,LF,0
            
STA_MSG     DC.B        'Enter starting address (ALL CAPS):',0
END_MSG     DC.B        'Enter ending address (ALL CAPS):',0

STA_ADDR    DS.B        40
END_ADDR    DS.B        40
            

            END         START       *LAST LINE

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
