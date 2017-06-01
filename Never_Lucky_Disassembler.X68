************************************************************
* Title      : Never Lucky Disassembler
* Written by : Henry Hong, Ryan Palm, Joshua Plantilla
* Date       : April 23, 2017
* Description: Final Project for CSS 422. This program
*              translates machine code into assembly (68k)
*              language.
************************************************************

START       ORG         $1000       *Start program
            JSR         INTRO       *Display Intro Message
            JSR         GET_INPUT   *Prompt user for input, convert input from ascii to hex and assign to sta_addr and end_addr
            JSR         DECODE_LOOP *Enters maine decode loop
            
               
*-----------------------INTRO-------------------------------
INTRO       LEA         NL_INTRO,A1 *Load INTRO1 message into A1
            MOVE.B      #14,D0      *Trap task 14, display intro
            TRAP        #15         
            RTS         

*--------------------GET_INPUT------------------------------
GET_INPUT   LEA         IN_WARN,A1 *Load INTRO1 message into A1
            MOVE.B      #14,D0      *Trap task 14, display intro
            TRAP        #15 

            LEA         STA_MSG,A1  *Load STA_MSG into A1
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
            
            *assuming all error checking is done before the next instruction (not yet implemented)
            
            MOVEA.L     D3,A5       *Move hex to STA_ADDR
            CLR.L       D3          *Clear D3
            RTS                     

*--------------------PROC_END-------------------------------
PROC_END    *TODO: Check for Null, bad length, odd address, range, convert to hex
            *      does not fall before start
            JSR         ASCII_HEX   *Convert input into Hex
            
            *assuming all error checking is done before the next instruction (not yet implemented)
            
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
            
*-------------------DECODE_LOOP-----------------------------
DECODE_LOOP MOVE.W      (A5)+,D7    *Move the instruction into D7        
            LEA         BAD_STR,A3  *Move Bad string constant into A3
            LEA         GOOD_STR,A4 *Move Good string constant into A4
            
            JSR         INIT_STRS   *Initialize Bad and Good Str
            
            JSR         JMP_TBL     *Start opcode identification waterfall
            
            JSR         CLEAN_GS    *end of output string.
            
PRINT_GOOD  JSR         PRINT_G     *Jump to Print good string
            BRA         CONTINUE    *Continue the loop
INVALID     JSR         PRINT_B     *Jump to Pring bad string
            BRA         CONTINUE    *Continue the loop            
            
CONTINUE    MOVE.L      A5,D1
            MOVE.L      A6,D2
            CMP.L       D1,D2
            BLE         END_OPT     *if we're done, move to end options (ask user what to do)
            
                        
            ADDQ.B      #1,D5       *Increment line counter
            CMP.B       #29,D5      *See if page is full
            BEQ         NEXT_PAGE   *Jump to next page prompt
            
            BRA         DECODE_LOOP * Continue loop

*-------------------NEXT_PAGE-----------------------------
NEXT_PAGE   LEA         NXT_PG,A1   *Load STA_MSG into A1
            CLR.L       D0          *Make sure D0 is empty
            MOVE.B      #14,D0      *Trap task 14, display start address msg
            TRAP        #15            
            
            MOVE.B      #5,D0       *Single char trap task
            TRAP        #15         
            
            CMP.B       #$D,D1      *Check if ENTER key was pressed
            BNE         NEXT_PAGE   *Force user to hit enter, or prompt again
            
            CLR.L       D5          *Reset page counter
            
            BRA         DECODE_LOOP *Continue the loop
            
*-------------------GS_CLEAN--------------------------------
* This subroutine "cleans" the end of the good string.
* Prevents the previous string from showing content in the
* current string.
*-----------------------------------------------------------
CLEAN_GS    CLR.L       D0
            MOVE.B      #15,D0      *Max 15 chars to clean

GS_LOOP     CMPI.B      #0,D0       *Add spaces to the end of string to push out old chars
            BEQ         D_CLEAN
            CLR.B       (A4)+
            SUBI.B      #$1,D0
            BRA         GS_LOOP
D_CLEAN     RTS
            
*-------------------INIT_STRS-----------------------------
INIT_STRS   JSR         INIT_GOOD   *Initialize the good string
            JSR         INIT_BAD    *Initialize the bad string
            RTS
            
*-------------------INIT_GOOD-----------------------------
INIT_GOOD   MOVE.B      #'$',(A4)+ 
            JSR         H2A_G_ADDR *Now convert address to ASCII
            
            MOVE.B      #' ',(A4)+  *Add spaces after addr
            MOVE.B      #' ',(A4)+
            
            RTS

*-------------------INIT_BAD------------------------------            
INIT_BAD    MOVE.B      #'$',(A3)+
            JSR         H2A_B_ADDR  *Add the address to the bad string
            MOVE.B      #' ',(A3)+    
            MOVE.B      #' ',(A3)+
            
            MOVE.B      #'D',(A3)+  
            MOVE.B      #'A',(A3)+ 
            MOVE.B      #'T',(A3)+    
            MOVE.B      #'A',(A3)+ 
            
            MOVE.B      #' ',(A3)+  *Add spaces after bad code added
            MOVE.B      #' ',(A3)+
            JSR         H2A_B_OP    *Add the opcode to the bad string
            
            RTS
            
*-------------------H2A_G_ADDR-------------------------------            
H2A_G_ADDR  CLR.L       D0          *Make sure D0 is empty (Counter)
            CLR.L       D1          *Make sure D1 is empty (For shifting/Rotations)
            CLR.L       D2          *Make sure D2 is empty (each individual char)
            CLR.L       D3          *Make sure D3 is empty (for shifting source operand)
            MOVE.L      A5,D1       *Copy address into D1
            SUBI.L      #2,D1       *Move addres back one byte (for post increment)
            MOVE.B      #$8,D0      *Counter
            BRA         ISO_DIG_G   *Begin isolating chars
            
ISO_DIG_G   ROL.L       #4,D1       *Move first significant hex char to least sig position
            
            MOVE.L      D1,D2       *Move to D2 to isolate least sig hex char
            
            MOVE.B      #28,D3      *Shift left 28 times
            LSL.L       D3,D2       *Isolated hex digit now is $X0000000
            ROL.L       #4,D2       *Isolated hex digit is now $0000000X
            
            CMPI.B      #$9,D2      *Is it a number?
            BLE         NUM_G       *If it is, process number
            BRA         LET_G       *If not, process letter
            
NUM_G       ADDI.B      #$30,D2     *Make it an ascii number
            BRA         ADD_CHAR_G  *add to strings and continue
            
LET_G       ADDI.B      #$37,D2     *Make it an ascii letter
            BRA         ADD_CHAR_G  *add to strings and continue

ADD_CHAR_G  MOVE.B      D2,(A4)+    *Add to the good data string
            SUBI.B      #$1,D0      *decrement counter
            CMPI.B      #$0,D0      *Check if we're done            
            BGT         ISO_DIG_G   *If not, continue tranlation   
            
            RTS
            
*-------------------H2A_B_ADDR-------------------------------            
H2A_B_ADDR  CLR.L       D0          *Make sure D0 is empty (Counter)
            CLR.L       D1          *Make sure D1 is empty (For shifting/Rotations)
            CLR.L       D2          *Make sure D2 is empty (each individual char)
            CLR.L       D3          *Make sure D3 is empty (for shifting source operand)
            MOVE.L      A5,D1       *Copy address into D1
            SUBI.L      #2,D1       *Move addres back one byte (for post increment)
            MOVE.B      #$8,D0      *Counter
            BRA         ISO_DIG_B   *Begin isolating chars
            
ISO_DIG_B   ROL.L       #4,D1       *Move first significant hex char to least sig position
            
            MOVE.L      D1,D2       *Move to D2 to isolate least sig hex char
            
            MOVE.B      #28,D3      *Shift left 28 times
            LSL.L       D3,D2       *Isolated hex digit now is $X0000000
            ROL.L       #4,D2       *Isolated hex digit is now $0000000X
            
            CMPI.B      #$9,D2      *Is it a number?
            BLE         NUM_B       *If it is, process number
            BRA         LET_B       *If not, process letter
            
NUM_B       ADDI.B      #$30,D2     *Make it an ascii number
            BRA         ADD_CHAR_B  *add to strings and continue
            
LET_B       ADDI.B      #$37,D2     *Make it an ascii letter
            BRA         ADD_CHAR_B  *add to strings and continue

ADD_CHAR_B  MOVE.B      D2,(A3)+    *Add to the good data string
            SUBI.B      #$1,D0      *decrement counter
            CMPI.B      #$0,D0      *Check if we're done            
            BGT         ISO_DIG_B    *If not, continue tranlation   
            
            RTS
            
*-------------------H2A_B_OP--------------------------------
H2A_B_OP    CLR.L       D0          *Make sure D0 is empty (Counter)
            CLR.L       D1          *Make sure D1 is empty (For shifting/Rotations)
            CLR.L       D2          *Make sure D2 is empty (each individual char)
            CLR.L       D3          *Make sure D3 is empty (for shifting source operand)
            MOVE.W      D7,D1       *Copy opcode into D0 for working with
            MOVE.B      #$4,D0      *Counter
            BRA         ISODIG_BO   *Begin isolating chars
            
ISODIG_BO   ROL.W       #4,D1       *Move first significant hex char to least sig position
            
            MOVE.L      D1,D2       *Move to D2 to isolate least sig hex char
            
            MOVE.B      #28,D3      *Shift left 28 times
            LSL.L       D3,D2       *Isolated hex digit now is $X0000000
            ROL.L       #4,D2       *Isolated hex digit is now $0000000X
            
            CMPI.B      #$9,D2      *Is it a number?
            BLE         NUM_BO      *If it is, process number
            BRA         LET_BO      *If not, process letter

NUM_BO      ADDI.B      #$30,D2     *Make it an ascii number
            BRA         ADD_CHAR_BO *add to strings and continue
            
LET_BO      ADDI.B      #$37,D2     *Make it an ascii letter
            BRA         ADD_CHAR_BO *add to strings and continue
            
ADD_CHAR_BO MOVE.B      D2,(A3)+    *Add to bad data string
            SUBI.B      #$1,D0      *decrement counter
            CMPI.B      #$0,D0      *Check if we're done            
            BGT         ISODIG_BO  *If not, continue tranlation   
            
            RTS
            
*-------------------PRINT_G---------------------------------
PRINT_G     MOVE.B      #' ',(A4)+
            MOVE.B      #$00,(A3)+  *Move null to end of string for printing
            LEA         GOOD_STR,A1 *Load good data for printing
            MOVE.B      #13,D0      *Trap task 13, display null terminated string
            TRAP        #15         *Display string
          
            RTS 

*-------------------PRINT_B---------------------------------
PRINT_B     MOVE.B      #' ',(A4)+
            MOVE.B      #$00,(A4)+  *Move null to end of string for printing
            LEA         BAD_STR,A1  *Load good data for printing
            MOVE.B      #13,D0      *Trap task 13, display null terminated string
            TRAP        #15         *Display string
            
            RTS 
            
*-------------------PRG_RESET-------------------------------
PRG_RESET   MOVEA.L     #$01000000,A7   *Reset the stack pointer
            
            MOVEA.L     #$00000000,A0   *Clear Address Registers
            MOVEA.L     #$00000000,A1
            MOVEA.L     #$00000000,A2
            MOVEA.L     #$00000000,A3
            MOVEA.L     #$00000000,A4
            MOVEA.L     #$00000000,A5
            MOVEA.L     #$00000000,A6
            
            CLR.L       D0              *Reset Data registers
            CLR.L       D1
            CLR.L       D2
            CLR.L       D3
            CLR.L       D4
            CLR.L       D5
            CLR.L       D6
            CLR.L       D7

            MOVE.B      #11,D0          *Clear Screen
            MOVE.W      #$FF00,D1
            TRAP        #15
            
            CLR.L       D1
            
            JMP         START           *Restart the program

*-------------------END_OPT---------------------------------
END_OPT     LEA         END_PGR,A1  *Display Ending messages
            CLR.L       D0          
            MOVE.B      #14,D0      
            TRAP        #15             
            
            MOVE.B      #5,D0       *Single char trap task
            TRAP        #15         
            
            CMP.B       #$20,D1     *Check if SPACE key was pressed
            BEQ         PRG_RESET   *Decode another memory image if enter is pressed
            
            CMP.B       #$1B,D1     *Check if ESC key was pressed
            BEQ         DONE        *End program
            
            BRA         END_OPT     *Else, loop (force space or esc)
            
*-----------------------DONE--------------------------------
DONE        MOVE.B      #9,D0       *Load 9 into D0 (trap task)
            TRAP        #15         *Halt program, Trap#15 task 9
 
           
*---------------Variables and Constants---------------------
            INCLUDE     'Never_Lucky_Jump_Tables.x68'   *Include jump tables file
            INCLUDE     'Never_Lucky_EA_Codes.x68'      *Include ea code (tables)

CR          EQU         $0D
LF          EQU         $0A

NL_INTRO    DC.B        '------------TEAM NEVER LUCKY------------',CR,LF
            DC.B        'Henry Hong, Ryan Palm, Joshua Plantilla',CR,LF
            DC.B        'CSS 422 Final Project: 68k Disassembler',CR,LF
            DC.B        '----------------------------------------',CR,LF,0

IN_WARN     DC.B        'You MUST follow the following input rules:',CR,LF
            DC.B        '1. Your starting address must be greater than or equal to $3000',CR,LF
            DC.B        '   (this means your data file must be orged at $3000 or greater)',CR,LF
            DC.B        '2. Your ending address must be greater than your starting address',CR,LF
            DC.B        '3. You must enter something for both starting and ending (no NULL inputs)',CR,LF
            DC.B        '4. Both your starting and ending address must be in the range of:',CR,LF
            DC.B        '   [$3000,$FFFFFFFF) (interval notation)',CR,LF
            DC.B        '5. Your inputs for both addresses may NOT be ODD values.',CR,LF
            DC.B        '6. Your inputs for both must ONLY contain standard hexidecimal characters:',CR,LF
            DC.B        '   0 1 2 3 4 5 6 7 8 9 A B C D E F (Do NOT include spaces or $)',CR,LF
            DC.B        'Failure to follow these instructions WILL result in crash or unexpected behavior.',CR,LF,CR,LF,0
 
            
STA_MSG     DC.B        'Enter starting address (ALL CAPS):',0
END_MSG     DC.B        'Enter ending address (ALL CAPS):',0

NXT_PG      DC.B        CR,LF,'Press ENTER key to contiune reading',CR,CR,LF,0

END_PGR     DC.B        CR,LF,'Prese SPACE to decode another memory image.',CR,LF
            DC.B        'Press ESC key to QUIT.',CR,LF,0

STA_ADDR    DS.B        40
END_ADDR    DS.B        40


BAD_STR     DC.L        1

SPACER11    DC.L        80
SPACER22    DC.L        80
SPACER33    DC.L        80
SPACER44    DC.L        80
SPACER55    DC.L        80
SPACER66    DC.L        80
SPACER77    DC.L        80
SPACER88    DC.L        80
SPACER99    DC.L        80
SPACERAA    DC.L        80
SPACERBB    DC.L        80
SPACERCC    DC.L        80
SPACERDD    DC.L        80
SPACEREE    DC.L        80
SPACERFF    DC.L        80

GOOD_STR    DC.L        1

SPACER1     DC.L        80
SPACER2     DC.L        80
SPACER3     DC.L        80
SPACER4     DC.L        80
SPACER5     DC.L        80
SPACER6     DC.L        80
SPACER7     DC.L        80
SPACER8     DC.L        80
SPACER9     DC.L        80
SPACERA     DC.L        80
SPACERB     DC.L        80
SPACERC     DC.L        80
SPACERD     DC.L        80
SPACERE     DC.L        80
SPACERF     DC.L        80

            END         START       *LAST LINE













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
