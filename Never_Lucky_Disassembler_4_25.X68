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
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
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
            
F_CMP_E     CMP.B       #$E,D3
            BNE         F_CMP_F
            JSR         FIRST_E
            RTS
   
F_CMP_F     JSR         FIRST_F     *If first hex value is not 0-D, it must be F. Branch to First_F
            RTS
                        

*------------------------First_0----------------------------
*Purpose: First_0 is a subroutine of IDENTIFY. If First_0 is branched to, that means the first
*         four digits of the machine code are 0000.
*         Possible instructions are: ADDI, SUBI    
*-----------------------------------------------------------           
FIRST_0     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
S_CMP_0     CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
S_CMP_1     CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
S_CMP_2     CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
S_CMP_3     CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
S_CMP_4     CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
S_CMP_5     CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
S_CMP_6     CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
S_CMP_7     CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
S_CMP_8     CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
S_CMP_9     CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
S_CMP_A     CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
S_CMP_B     CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
S_CMP_C     CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
S_CMP_D     CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
S_CMP_E     CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
S_CMP_F     JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------First_1----------------------------
*Purpose: First_1 is a subroutine of IDENTIFY. If First_1 is branched to, that means the first
*         four digits of the machine code are 0001.
*         Possible instructions are: MOVE, MOVEA
*-----------------------------------------------------------     
FIRST_1     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_2----------------------------
*Purpose: First_2 is a subroutine of IDENTIFY. If First_2 is branched to, that means the first
*         four digits of the machine code are 0010.
*         Possible instructions are: MOVE, MOVEA
*-----------------------------------------------------------
FIRST_2     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------First_3----------------------------
*Purpose: First_3 is a subroutine of IDENTIFY. If First_3 is branched to, that means the first
*         four digits of the machine code are 0011.
*         Possible instructions are: MOVE, MOVEA
*-----------------------------------------------------------
FIRST_3     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_4----------------------------
*Purpose: First_4 is a subroutine of IDENTIFY. If First_4 is branched to, that means the first
*         four digits of the machine code are 0100.
*         Possible instructions are: NOP, MOVEM, LEA, JSR, RTS    
*-----------------------------------------------------------
FIRST_4     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_5----------------------------
*Purpose: First_5 is a subroutine of IDENTIFY. If First_5 is branched to, that means the first
*         four digits of the machine code are 0101.
*         Possible instructions are: ADDQ    
*-----------------------------------------------------------
FIRST_5     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_6----------------------------
*Purpose: First_6 is a subroutine of IDENTIFY. If First_6 is branched to, that means the first
*         four digits of the machine code are 0110.
*         Possible instructions are: BRA, Bcc    
*-----------------------------------------------------------
FIRST_6     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_7----------------------------
*Purpose: First_7 is a subroutine of IDENTIFY. If First_7 is branched to, that means the first
*         four digits of the machine code are 0111.
*         Possible instructions are: MOVEQ    
*-----------------------------------------------------------
FIRST_7     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_8----------------------------
*Purpose: First_8 is a subroutine of IDENTIFY. If First_8 is branched to, that means the first
*         four digits of the machine code are 1000.
*         Possible instructions are: DIVU, OR     
*-----------------------------------------------------------
FIRST_8     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_9----------------------------
*Purpose: First_9 is a subroutine of IDENTIFY. If First_9 is branched to, that means the first
*         four digits of the machine code are 1001.
*         Possible instructions are: SUB    
*-----------------------------------------------------------
FIRST_9     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_A----------------------------
*Purpose: First_A is a subroutine of IDENTIFY. If First_A is branched to, that means the first
*         four digits of the machine code are 1010.
*         Possible instructions are: Illegal    
*-----------------------------------------------------------
FIRST_A     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_B----------------------------
*Purpose: First_B is a subroutine of IDENTIFY. If First_B is branched to, that means the first
*         four digits of the machine code are 1011.
*         Possible instructions are: Illegal    
*-----------------------------------------------------------
FIRST_B     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------First_C----------------------------
*Purpose: First_C is a subroutine of IDENTIFY. If First_C is branched to, that means the first
*         four digits of the machine code are 1100.
*         Possible instructions are: MULS, AND    
*-----------------------------------------------------------
FIRST_C     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------First_D----------------------------
*Purpose: First_D is a subroutine of IDENTIFY. If First_D is branched to, that means the first
*         four digits of the machine code are 1101.
*         Possible instructions are: ADD, ADDA    
*-----------------------------------------------------------
FIRST_D     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------First_E----------------------------
*Purpose: First_E is a subroutine of IDENTIFY. If First_E is branched to, that means the first
*         four digits of the machine code are 1110.
*         Possible instructions are: LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR R, ASL/ASR M,
*                                    ROL/ROR R, ROL/ROR M    
*-----------------------------------------------------------
FIRST_E     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
           CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS

            
*------------------------First_F----------------------------
*Purpose: First_F is a subroutine of IDENTIFY. If First_F is branched to, that means the first
*         four digits of the machine code are 1111.
*         Possible instructions are: ILLEGAL INSTRUCTIONS  
*-----------------------------------------------------------
FIRST_F     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #4,D2       *Shifts 4 bits so gets rid of leftmost byte
            MOVE.B      #60,D1      *Moves 60 into D1
            LSR.L       D1,D2       *Shifts 60 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         S_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         SECOND_0     *If the first hex value is 0, jump to Second_0
            RTS
            
            CMP.B       #$1,D3
            BNE         S_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         SECOND_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         S_CMP_3 
            JSR         SECOND_2
            RTS
            
            CMP.B       #$3,D3
            BNE         S_CMP_4
            JSR         SECOND_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         S_CMP_5
            JSR         SECOND_4
            RTS
            
            CMP.B       #$5,D3
            BNE         S_CMP_6
            JSR         SECOND_5
            RTS
            
            CMP.B       #$6,D3
            BNE         S_CMP_7
            JSR         SECOND_6
            RTS
            
            CMP.B       #$7,D3
            BNE         S_CMP_8
            JSR         SECOND_7
            RTS
            
            CMP.B       #$8,D3
            BNE         S_CMP_9
            JSR         SECOND_8
            RTS
            
            CMP.B       #$9,D3
            BNE         S_CMP_A
            JSR         SECOND_9
            RTS
            
            CMP.B       #$A,D3
            BNE         S_CMP_B
            JSR         SECOND_A
            RTS
            
            CMP.B       #$B,D3
            BNE         S_CMP_C
            JSR         SECOND_B
            RTS
            
            CMP.B       #$C,D3
            BNE         S_CMP_D
            JSR         SECOND_C
            RTS
            
            CMP.B       #$D,D3
            BNE         S_CMP_E
            JSR         SECOND_D
            RTS
            
            CMP.B       #$E,D3
            BNE         S_CMP_F
            JSR         SECOND_E                 
            RTS
            
            JSR         SECOND_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_0----------------------------
*Purpose: Second_0 is a subroutine of IDENTIFY. If Second_0 is branched to, that means the second
*         four digits of the machine code are 0000.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    ADD, ADDA, ADDQ, SUB, 
*                                    DIVU, AND, OR, 
*                                    LSL/LSR R, ASL/ASR R,
*                                    ASL/ASR M,
*                                    ROL/ROR R, Bcc, BRA
*-----------------------------------------------------------            
SECOND_0    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
T_CMP_0     CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
T_CMP_1     CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
T_CMP_2     CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
T_CMP_3     CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
T_CMP_4     CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
T_CMP_5     CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
T_CMP_6     CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
T_CMP_7     CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
T_CMP_8     CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
T_CMP_9     CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
T_CMP_A     CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
T_CMP_B     CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
T_CMP_C     CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
T_CMP_D     CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
T_CMP_E     CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
T_CMP_F     JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------Second_1----------------------------
*Purpose: Second_1 is a subroutine of IDENTIFY. If Second_1 is branched to, that means the second
*         four digits of the machine code are 0001.
*         Possible instructions are: MOVE, MULS, LEA, ADD,
*                                    ADDA, SUB, AND, OR, Bcc
*                                    LSL/LSR R,
*                                    ASL/ASR R, ASL/ASR M,
*                                    ROL/ROR R    
*-----------------------------------------------------------            
SECOND_1    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS

            
*------------------------Second_2----------------------------
*Purpose: Second_2 is a subroutine of IDENTIFY. If Second_2 is branched to, that means the second
*         four digits of the machine code are 0010.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    ADD, ADDA, ADDQ, SUB, 
*                                    DIVU, AND, OR, 
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR R,
*                                    ROL/ROR R, Bcc, BRA  
*-----------------------------------------------------------  
SECOND_2    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------Second_3----------------------------
*Purpose: Second_3 is a subroutine of IDENTIFY. If Second_3 is branched to, that means the second
*         four digits of the machine code are 0011.
*         Possible instructions are: MOVE, ADD, ADDA,
*                                    SUB, MULS, LEA, AND,
*                                    OR, LSL/LSR R,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ROL/ROR R, Bcc
*-----------------------------------------------------------  
SECOND_3    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_4----------------------------
*Purpose: Second_4 is a subroutine of IDENTIFY. If Second_4 is branched to, that means the second
*         four digits of the machine code are 0100.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    ADD, ADDA, ADDQ, SUB,
*                                    SUBI, DIVU, AND, OR,
*                                    LSL/LSR R, ASL/ASR R
*                                    ROL/ROR R, Bcc
*-----------------------------------------------------------  
SECOND_4    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------Second_5----------------------------
*Purpose: Second_5 is a subroutine of IDENTIFY. If Second_5 is branched to, that means the second
*         four digits of the machine code are 0101.
*         Possible instructions are: MOVE, ADD, ADDA, SUB,
*                                    MULS, LEA, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc
*-----------------------------------------------------------  
SECOND_5    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_6----------------------------
*Purpose: Second_6 is a subroutine of IDENTIFY. If Second_6 is branched to, that means the second
*         four digits of the machine code are 0110.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    ADD, ADDA, ADDI, ADDQ,
*                                    SUB, DIVU, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR R, ROL/ROR R,
*                                    ROL/ROR M, Bcc
*-----------------------------------------------------------  
SECOND_6    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------Second_7----------------------------
*Purpose: Second_7 is a subroutine of IDENTIFY. If Second_7 is branched to, that means the second
*         four digits of the machine code are 0111.
*         Possible instructions are: MOVE, ADD, ADDA, SUB,
*                                    MULS, LEA, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, ROL/ROR M,
*                                    Bcc
*-----------------------------------------------------------  
SECOND_7    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_8----------------------------
*Purpose: Second_4 is a subroutine of IDENTIFY. If Second_4 is branched to, that means the second
*         four digits of the machine code are 1000.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDQ,
*                                    SUB, DIVU, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc
*-----------------------------------------------------------  
SECOND_8    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_9----------------------------
*Purpose: Second_9 is a subroutine of IDENTIFY. If Second_9 is branched to, that means the second
*         four digits of the machine code are 1001.
*         Possible instructions are: MOVE, ADD, ADDA, SUB,
*                                    MULS, LEA, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc 
*-----------------------------------------------------------  
SECOND_9    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_A----------------------------
*Purpose: Second_A is a subroutine of IDENTIFY. If Second_A is branched to, that means the second
*         four digits of the machine code are 1010.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    ADD, ADDA, ADDQ, SUB,
*                                    DIVU, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc
*-----------------------------------------------------------  
SECOND_A    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_B----------------------------
*Purpose: Second_B is a subroutine of IDENTIFY. If Second_B is branched to, that means the second
*         four digits of the machine code are 1011.
*         Possible instructions are: MOVE, ADD, ADDA, SUB,
*                                    MULS, LEA, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc
*-----------------------------------------------------------  
SECOND_B    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_C----------------------------
*Purpose: Second_C is a subroutine of IDENTIFY. If Second_C is branched to, that means the second
*         four digits of the machine code are 1100.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDQ,
*                                    SUB, DIVU, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc  
*-----------------------------------------------------------  
SECOND_C    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS



*------------------------Second_D----------------------------
*Purpose: Second_D is a subroutine of IDENTIFY. If Second_D is branched to, that means the second
*         four digits of the machine code are 1101.
*         Possible instructions are: MOVE, ADD, ADDA, SUB,
*                                    MULS, LEA, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc
*-----------------------------------------------------------  
SECOND_D    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_E----------------------------
*Purpose: Second_E is a subroutine of IDENTIFY. If Second_E is branched to, that means the second
*         four digits of the machine code are 1110.
*         Possible instructions are: NOP, MOVE, MOVEA, 
*                                    MOVEQ, ADD, ADDA, ADDQ,
*                                    SUB, DIVU, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc,
*                                    JSR, RTS
*-----------------------------------------------------------  
SECOND_E    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Second_F----------------------------
*Purpose: Second_F is a subroutine of IDENTIFY. If Second_F is branched to, that means the second
*         four digits of the machine code are 1111.
*         Possible instructions are: MOVE, ADD, ADDA, SUB,
*                                    MULS, LEA, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    ROL/ROR R, Bcc
*----------------------------------------------------------- 
SECOND_F    MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #8,D2       *Shifts 8 bits so gets rid of leftmost 2 bytes
            MOVE.B      #64,D1      *Moves 64 into D1
            LSR.L       D1,D2       *Shifts 64 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         T_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         THIRD_0     *If the first hex value is 0, jump to Third_0
            RTS
            
            CMP.B       #$1,D3
            BNE         T_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         THIRD_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         T_CMP_3 
            JSR         THIRD_2
            RTS
            
            CMP.B       #$3,D3
            BNE         T_CMP_4
            JSR         THIRD_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         T_CMP_5
            JSR         THIRD_4
            RTS
            
            CMP.B       #$5,D3
            BNE         T_CMP_6
            JSR         THIRD_5
            RTS
            
            CMP.B       #$6,D3
            BNE         T_CMP_7
            JSR         THIRD_6
            RTS
            
            CMP.B       #$7,D3
            BNE         T_CMP_8
            JSR         THIRD_7
            RTS
            
            CMP.B       #$8,D3
            BNE         T_CMP_9
            JSR         THIRD_8
            RTS
            
            CMP.B       #$9,D3
            BNE         T_CMP_A
            JSR         THIRD_9
            RTS
            
            CMP.B       #$A,D3
            BNE         T_CMP_B
            JSR         THIRD_A
            RTS
            
            CMP.B       #$B,D3
            BNE         T_CMP_C
            JSR         THIRD_B
            RTS
            
            CMP.B       #$C,D3
            BNE         T_CMP_D
            JSR         THIRD_C
            RTS
            
            CMP.B       #$D,D3
            BNE         T_CMP_E
            JSR         THIRD_D
            RTS
            
            CMP.B       #$E,D3
            BNE         T_CMP_F
            JSR         THIRD_E                 
            RTS
            
            JSR         THIRD_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS

*------------------------Third_0----------------------------
*Purpose: Third_0 is a subroutine of IDENTIFY. If Third_0 is branched to, that means the third
*         four digits of the machine code are 0000.
*         Possible instructions are: MOVE, MOVEQ, ADD,
*                                    ADDA, ADDI, ADDQ, SUB,
*                                    SUBI, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_0     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            MOVE.B      #12,D1      *Moves 68 into D1
            LSL.L       D1,D2       *Shifts 12 bits so gets rid of leftmost 3 bytes
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
FO_CMP_0    CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
FO_CMP_1    CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
FO_CMP_2    CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
FO_CMP_3    CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
FO_CMP_4    CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
FO_CMP_5    CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
FO_CMP_6    CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
FO_CMP_7    CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
FO_CMP_8    CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
FO_CMP_9    CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
FO_CMP_A    CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
FO_CMP_B    CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
FO_CMP_C    CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
FO_CMP_D    CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
FO_CMP_E    CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
FO_CMP_F    JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_1----------------------------
*Purpose: Third_1 is a subroutine of IDENTIFY. If Third_1 is branched to, that means the third
*         four digits of the machine code are 0001.
*         Possible instructions are: MOVE, MOVEQ, ADD, ADDA,
*                                    ADDI, ADDQ, SUB, SUBI,
*                                    AND, OR, ROL/ROR R,
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_1     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            MOVE.B      #12,D1      *Moves 68 into D1
            LSL.L       D1,D2       *Shifts 12 bits so gets rid of leftmost 3 bytes
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_2----------------------------
*Purpose: Third_2 is a subroutine of IDENTIFY. If Third_2 is branched to, that means the third
*         four digits of the machine code are 0010.
*         Possible instructions are: MOVE, MOVEQ, ADD,
*                                    ADDA, ADDI, ADDQ, SUB,
*                                    SUBI, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_2     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            MOVE.B      #12,D1      *Moves 68 into D1
            LSL.L       D1,D2       *Shifts 12 bits so gets rid of leftmost 3 bytes
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_3----------------------------
*Purpose: Third_3 is a subroutine of IDENTIFY. If Third_3 is branched to, that means the third
*         four digits of the machine code are 0011.
*         Possible instructions are: MOVE, MOVEQ, ADD, ADDA,
*                                    ADDI, ADDQ, SUB, SUBI,
*                                    AND, OR, ROL/ROR R,
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_3     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            MOVE.B      #12,D1      *Moves 68 into D1
            LSL.L       D1,D2       *Shifts 12 bits so gets rid of leftmost 3 bytes
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_4----------------------------
*Purpose: Third_4 is a subroutine of IDENTIFY. If Third_4 is branched to, that means the third
*         four digits of the machine code are 0100.
*         Possible instructions are: MOVE, MOVEA, MOVEQ, 
*                                    ADD,
*                                    ADDA, ADDI, ADDQ, SUB,
*                                    SUBI, AND, OR,
*                                    LSL/LSR R, ASL/ASR R,
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_4     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_5----------------------------
*Purpose: Third_5 is a subroutine of IDENTIFY. If Third_5 is branched to, that means the third
*         four digits of the machine code are 0101.
*         Possible instructions are: MOVE, MOVEA, MOVEQ, 
*                                    ADD, ADDA,
*                                    ADDI, ADDQ, SUB, SUBI,
*                                    AND, OR, ROL/ROR R,
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_5     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_6----------------------------
*Purpose: Third_6 is a subroutine of IDENTIFY. If Third_6 is branched to, that means the third
*         four digits of the machine code are 0110.
*         Possible instructions are: MOVE, MOVEA, MOVEQ, 
*                                    ADD,
*                                    ADDA, ADDI, ADDQ, SUB,
*                                    SUBI, DIVU, AND, OR,
*                                    LSL/LSR R, LSL/LSR M, 
*                                    ASL/ASR R, ASL/ASR M,
*                                    ROL/ROR M, Bcc, BRA
*----------------------------------------------------------- 
THIRD_6     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_7---------------------------
*Purpose: Third_7 is a subroutine of IDENTIFY. If Third_7 is branched to, that means the third
*         four digits of the machine code are 0111.
*         Possible instructions are: NOP, MOVE, MOVEA, 
*                                    MOVEQ, ADD,
*                                    ADDA, ADDI, ADDQ, SUB,
*                                    SUBI, DIVU, AND, OR,
*                                    LSL/LSR M, ASL/ASR M,
*                                    ROL/ROR R, ROL/ROR M,
*                                    Bcc, RTS, BRA
*----------------------------------------------------------- 
THIRD_7     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_8---------------------------
*Purpose: Third_8 is a subroutine of IDENTIFY. If Third_8 is branched to, that means the third
*         four digits of the machine code are 1000.
*         Possible instructions are: MOVE, MOVEM, MOVEQ, 
*                                    ADD, ADDA, ADDI, ADDQ, 
*                                    SUB,
*                                    AND, OR, LSL/LSR R,
*                                    ASL/ASR R, Bcc, JSR,
*                                    BRA
*----------------------------------------------------------- 
THIRD_8     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_9---------------------------
*Purpose: Third_9 is a subroutine of IDENTIFY. If Third_9 is branched to, that means the third
*         four digits of the machine code are 1001.
*         Possible instructions are: MOVE, MOVEM, MOVEQ, 
*                                    ADD, ADDA, ADDI, ADDQ, 
*                                    SUB,
*                                    AND, OR, ROL/ROR R,
*                                    Bcc, JSR, BRA
*----------------------------------------------------------
THIRD_9     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_A---------------------------
*Purpose: Third_A is a subroutine of IDENTIFY. If Third_A is branched to, that means the third
*         four digits of the machine code are 1010.
*         Possible instructions are: MOVE, MOVEM, MOVEQ, ADD, 
*                                    ADDA, ADDI, ADDQ, SUB,
*                                    AND, OR, LSL/LSR R,
*                                    ASL/ASR R, Bcc, JSR,
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_A     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_B---------------------------
*Purpose: Third_B is a subroutine of IDENTIFY. If Third_B is branched to, that means the third
*         four digits of the machine code are 1011.
*         Possible instructions are: MOVE, MOVEM, MOVEQ, 
*                                    ADD, ADDA, ADDI, ADDQ, 
*                                    SUB,
*                                    AND, OR, ROL/ROR R,
*                                    Bcc, JSR, Bcc, BRA
*----------------------------------------------------------- 
THIRD_B     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_C---------------------------
*Purpose: Third_C is a subroutine of IDENTIFY. If Third_C is branched to, that means the third
*         four digits of the machine code are 1100.
*         Possible instructions are: MOVE, MOVEQ, MOVEM,
*                                    ADD, ADDA, ADDI, ADDQ,
*                                    SUB, SUBI, MULS, DIVU,
*                                    LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR R, ASL/ASR M,
*                                    ROL/ROR M, Bcc, BRA
*----------------------------------------------------------- 
THIRD_C     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_D---------------------------
*Purpose: Third_D is a subroutine of IDENTIFY. If Third_D is branched to, that means the third
*         four digits of the machine code are 1101.
*         Possible instructions are: MOVE, MOVEQ, MOVEM,
*                                    ADD, ADDA, ADDI, ADDQ,
*                                    SUB, SUBI, MULS, DIVU,
*                                    LEA, AND, OR,
*                                    ROL/ROR R, ROL/ROR M, 
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_D     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS


*------------------------Third_E---------------------------
*Purpose: Third_E is a subroutine of IDENTIFY. If Third_E is branched to, that means the third
*         four digits of the machine code are 1110.
*         Possible instructions are: MOVE, MOVEQ, MOVEM,
*                                    ADD, ADDA, ADDI, ADDQ,
*                                    SUB, SUBI, MULS, DIVU,
*                                    LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR R, ASL/ASR M,
*                                    ROL/ROR M, Bcc, BRA
*----------------------------------------------------------- 
THIRD_E     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS

    
*------------------------Third_F---------------------------
*Purpose: Third_F is a subroutine of IDENTIFY. If Third_F is branched to, that means the third
*         four digits of the machine code are 1111.
*         Possible instructions are: MOVE, MOVEQ, MOVEM,
*                                    ADD, ADDA, ADDI, ADDQ,
*                                    SUB, SUBI, MULS, DIVU,
*                                    LEA, AND, OR,
*                                    ROL/ROR R, ROL/ROR M, 
*                                    Bcc, BRA
*----------------------------------------------------------- 
THIRD_F     MOVE.L      D7,D2       *Copies D7 contents to D2 for manipulation
            LSL.L       #12,D2       *Shifts 12 bits so gets rid of leftmost 3 byteS
            MOVE.B      #68,D1      *Moves 68 into D1
            LSR.L       D1,D2       *Shifts 68 bits so the remaining contents = the left 4 bits of D7
            ADD.B       D2,D3       *Copies those 4 bits (ie leftmost 4 bits of D7) into D3
            
            CMP.B       #$0,D3      *Following section determines what hex value the first 4 digits are
            BNE         FO_CMP_1     *If the first hex value is not 0, branch and see if its 1
            JSR         FOURTH_0     *If the first hex value is 0, jump to Fourth_0
            RTS
            
            CMP.B       #$1,D3
            BNE         FO_CMP_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         FOURTH_1 
            RTS
           
            CMP.B       #$2,D3
            BNE         FO_CMP_3 
            JSR         FOURTH_2
            RTS
            
            CMP.B       #$3,D3
            BNE         FO_CMP_4
            JSR         FOURTH_3 
            RTS
           
            CMP.B       #$4,D3
            BNE         FO_CMP_5
            JSR         FOURTH_4
            RTS
            
            CMP.B       #$5,D3
            BNE         FO_CMP_6
            JSR         FOURTH_5
            RTS
            
            CMP.B       #$6,D3
            BNE         FO_CMP_7
            JSR         FOURTH_6
            RTS
            
            CMP.B       #$7,D3
            BNE         FO_CMP_8
            JSR         FOURTH_7
            RTS
            
            CMP.B       #$8,D3
            BNE         FO_CMP_9
            JSR         FOURTH_8
            RTS
            
            CMP.B       #$9,D3
            BNE         FO_CMP_A
            JSR         FOURTH_9
            RTS
            
            CMP.B       #$A,D3
            BNE         FO_CMP_B
            JSR         FOURTH_A
            RTS
            
            CMP.B       #$B,D3
            BNE         FO_CMP_C
            JSR         FOURTH_B
            RTS
            
            CMP.B       #$C,D3
            BNE         FO_CMP_D
            JSR         FOURTH_C
            RTS
            
            CMP.B       #$D,D3
            BNE         FO_CMP_E
            JSR         FOURTH_D
            RTS
            
            CMP.B       #$E,D3
            BNE         FO_CMP_F
            JSR         FOURTH_E                 
            RTS
            
            JSR         FOURTH_F     *If first hex value is not 0-E, it must be F. Branch to Second_F
            RTS

*------------------------Fourth_0---------------------------
*Purpose: Fourth_0 is a subroutine of IDENTIFY. If Fourth_0 is branched to, that means the fourth
*         four digits of the machine code are 0000.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ASL/ASR M, ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------             
FOURTH_0    RTS

*------------------------Fourth_1---------------------------
*Purpose: Fourth_1 is a subroutine of IDENTIFY. If Fourth_1 is branched to, that means the fourth
*         four digits of the machine code are 0001.
*         Possible instructions are: NOP, MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ASL/ASR M, ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_1    RTS

*------------------------Fourth_2---------------------------
*Purpose: Fourth_2 is a subroutine of IDENTIFY. If Fourth_2 is branched to, that means the fourth
*         four digits of the machine code are 0010.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ASL/ASR M, ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_2    RTS

*------------------------Fourth_3---------------------------
*Purpose: Fourth_3 is a subroutine of IDENTIFY. If Fourth_3 is branched to, that means the fourth
*         four digits of the machine code are 0011.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ASL/ASR M, ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_3    RTS

*------------------------Fourth_4---------------------------
*Purpose: Fourth_4 is a subroutine of IDENTIFY. If Fourth_4 is branched to, that means the fourth
*         four digits of the machine code are 0100.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ASL/ASR M, ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_4    RTS

*------------------------Fourth_5---------------------------
*Purpose: Fourth_5 is a subroutine of IDENTIFY. If Fourth_5 is branched to, that means the fourth
*         four digits of the machine code are 0101.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ASL/ASR M, ROL/ROR M,
*                                    Bcc, JSR, RTS, BRA
*-----------------------------------------------------------
FOURTH_5    RTS

*------------------------Fourth_6---------------------------
*Purpose: Fourth_6 is a subroutine of IDENTIFY. If Fourth_6 is branched to, that means the fourth
*         four digits of the machine code are 0110.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ASL/ASR M, ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_6    RTS

*------------------------Fourth_7---------------------------
*Purpose: Fourth_7 is a subroutine of IDENTIFY. If Fourth_7 is branched to, that means the fourth
*         four digits of the machine code are 0111.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR M, ASL/ASR R,
*                                    ASL/ASR M, ROR/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_7    RTS

*------------------------Fourth_8---------------------------
*Purpose: Fourth_8 is a subroutine of IDENTIFY. If Fourth_8 is branched to, that means the fourth
*         four digits of the machine code are 1000.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR M, ROL/ROR R, 
*                                    ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_8    RTS

*------------------------Fourth_9---------------------------
*Purpose: Fourth_9 is a subroutine of IDENTIFY. If Fourth_9 is branched to, that means the fourth
*         four digits of the machine code are 1001.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR M, ROL/ROR R, 
*                                    ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_9    RTS

*------------------------Fourth_A---------------------------
*Purpose: Fourth_A is a subroutine of IDENTIFY. If Fourth_A is branched to, that means the fourth
*         four digits of the machine code are 1010.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR M, ROL/ROR R, 
*                                    ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_A    RTS

*------------------------Fourth_B---------------------------
*Purpose: Fourth_B is a subroutine of IDENTIFY. If Fourth_B is branched to, that means the fourth
*         four digits of the machine code are 1011.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR M, ROL/ROR R, 
*                                    ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_B    RTS

*------------------------Fourth_C---------------------------
*Purpose: Fourth_C is a subroutine of IDENTIFY. If Fourth_C is branched to, that means the fourth
*         four digits of the machine code are 1100.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR M, ROL/ROR R, 
*                                    ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_C    RTS

*------------------------Fourth_D---------------------------
*Purpose: Fourth_D is a subroutine of IDENTIFY. If Fourth_D is branched to, that means the fourth
*         four digits of the machine code are 1101.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR M, ROL/ROR R, 
*                                    ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_D    RTS

*------------------------Fourth_E---------------------------
*Purpose: Fourth_E is a subroutine of IDENTIFY. If Fourth_E is branched to, that means the fourth
*         four digits of the machine code are 1110.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR M, ROL/ROR R, 
*                                    ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_E    RTS

*------------------------Fourth_F---------------------------
*Purpose: Fourth_F is a subroutine of IDENTIFY. If Fourth_F is branched to, that means the fourth
*         four digits of the machine code are 1111.
*         Possible instructions are: MOVE, MOVEA, MOVEQ,
*                                    MOVEM, ADD, ADDA, ADDI,
*                                    ADDQ, SUB, SUBI, MULS,
*                                    DIVU, LEA, AND, OR,
*                                    LSL/LSR R, LSL/LSR M,
*                                    ASL/ASR M, ROL/ROR R, 
*                                    ROL/ROR M,
*                                    Bcc, JSR, BRA
*-----------------------------------------------------------
FOURTH_F    RTS

            
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
