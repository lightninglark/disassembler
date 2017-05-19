************************************************************
* TEAM NEVERY LUCKY DISSASSEMBLER
* This file includes OPCODE logic (OPCODE and size decoding)
************************************************************

*============================================================
*===================ID FIRST OPCODE DIGIT====================
*============================================================

*-----------------------JMP_TBL------------------------------
* Purpose: JMP_TBL takes a data register input (D7) and navigates to the correct OPCODE table
*          entry.
*          $FF is saved to D6 if OPCode is determined to be incorrect
* Assumption: Whenever JMP_TBL is called, D7 contains the next new machine code instruction
*------------------------------------------------------------
JMP_TBL     CLR.L       D2
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            MOVE.B      #12,D1      *Moves 12 into D1
            LSR.W       D1,D2       *Shifts 12 bits so the remaining contents = the left 4 bits of D7
                        
JMP_0       CMP.B       #$0,D2      *Following section determines what hex value the first 4 digits are
            BNE         JMP_1       *If the first hex value is not 0, branch and see if its 1
            JSR         JMP_0X      *If the first hex value is 0, jump to JMP_0X to determine the next set of digits
            RTS                     *Finished all jumping; whole instruction should be identified at this point
            
JMP_1       CMP.B       #$1,D2
            BNE         JMP_2       *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         OPC_1XXX    *If the first hex value is 1, the instruction is determined to be MOVE.B. Jump to OPC_1XXX in OPCODE table.
            RTS                     *Finished all jumping; whole instruction should be identified at this point, and so on       
           
JMP_2       CMP.B       #$2,D2
            BNE         JMP_3 
            JSR         JMP_2X      *If the first hex value is 2, jump to JMP_2X to determine the next set of digits
            RTS
            
JMP_3       CMP.B       #$3,D2
            BNE         JMP_4
            JSR         JMP_3X      *If the first hex value is 3, jump to JMP_3X to determine the next set of digits
            RTS
         
JMP_4       CMP.B       #$4,D2      *Where NOP SHOULD LAND
            BNE         JMP_5
            JSR         JMP_4X      *If the first hex value is 4, jump to JMP_4X to determine the next set of digits
            RTS
            
JMP_5       CMP.B       #$5,D2
            BNE         JMP_6
            JSR         OPC_5XXX    *If the first hex digit is 5, the instruction is determined to be ADDQ. Jump to OPC_5XXX in OPCODE table.
            RTS
            
JMP_6       CMP.B       #$6,D2
            BNE         JMP_7
            JSR         JMP_6X      *If the first hex value is 6, jump to JMP_6X to determine the next set of digits
            RTS
            
JMP_7       CMP.B       #$7,D2
            BNE         JMP_8
            JSR         OPC_7XXX    *If the first hex digit is 7, the instruction is determined to be MOVEQ. Jump to OPC_7XXX in OPCODE table.
            RTS
            
JMP_8       CMP.B       #$8,D2
            BNE         JMP_9
            JSR         JMP_8X      *If the first hex value is 8, jump to JMP_8X to determine the next set of digits
            RTS
            
JMP_9       CMP.B       #$9,D2
            BNE         JMP_A
            JSR         OPC_9XXX    *If the first hex digit is 9, the instruction is determined to be SUB. Jump to OPC_9XXX in OPCODE table.
            RTS
            
JMP_A       CMP.B       #$A,D2
            BNE         JMP_B
            JSR         INVALID     *0xA is an invalid first hex digit. Jump to INVALID
            RTS
            
JMP_B       CMP.B       #$B,D2
            BNE         JMP_C
            JSR         INVALID     *0xB is an invalid first hex digit. Jump to INVALID
            RTS
            
JMP_C       CMP.B       #$C,D2
            BNE         JMP_D
            JSR         JMP_CX      *If the first hex value is C, jump to JMP_CX to determine the next set of digits
            RTS
            
JMP_D       CMP.B       #$D,D2
            BNE         JMP_E   
            JSR         JMP_DX      *If the first hex value is D, jump to JMP_DX to determine the next set of digits
            RTS
            
JMP_E       CMP.B       #$F,D2      *If first hex value is not 0-D, it must be E(valid) or F(invalid)
            BEQ         INVALID     *If first hex value is F, jump to INVALID
            JSR         JMP_EX      *If the first hex value is E, jump to JMP_EX to determine the next set of digits
            RTS
 
*============================================================
*==================ID SECOND OPCODE DIGIT====================
*============================================================

* J_CLR4 prepares the data registers for data manipulation on the second input hex digit by isolating the next 4 bits:
* %0000 XXXX 0000 0000 0000
J_CLR4      CLR.L       D2                                
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #4,D2       *Clear the most sig hex digit
            MOVE.B      #12,D1      *Moves 12 into D1
            LSR.W       D1,D2       *Shifts 12 right to isolate the bits we're working with
            RTS                     *Return back to JMP_Xn    
            
* J_CLR3 prepares the data registers for data manipulation on the second input hex digit by isolating the next 3 bits:
* %0000 XXX0 0000 0000 0000          
J_CLR3      CLR.L       D2          
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #4,D2       *Clear the most sig hex digit
            MOVE.B      #13,D1      *Moves 13 into D1
            LSR.W       D1,D2       *Shifts 13 right to isolate the bits we're working with 
            RTS                     *Return back to JMP_Xn  

* J_CLR_DM prepares the data registers for data manipulation on the second input hex digit by isolating the DESTINATION MODE bits:
* %0000 000X XX00 0000 0000          
J_CLR_DM    CLR.L       D2          
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #7,D2       *Clear the most sig 7 bits
            MOVE.B      #17,D1      *Moves 17 into D1
            LSR.W       D1,D2       *Shifts 17 right to isolate the bits we're working with 
            RTS                     *Return back to JMP_Xn     
         
*---------------------SUBI, ADDI-----------------------------
JMP_0X      JSR         J_CLR4      *Prepare data registers for data manipulation on the second input hex digit
            CMP.B       #$4,D2      *Is the next hex digit 4?
            BEQ         J_SUBI      *Instruction is determined to be SUBI. Jump to intermediate OPCODE table jump
            CMP.B       #$5,D2      *Is the next hex digit 5?
            BEQ         J_ADDI     *Instruction is determined to be ADDI. Jump to intermediate OPCODE table jump
            JSR         INVALID     *If neither, OPCODE is invalid
            RTS

J_SUBI      JSR         OPC_04XX    *Jump to OPC_04XX in OPCODE table
            RTS
            
J_ADDI      JSR         OPC_05XX    *Jump to OPC_05XX in OPCODE table
            RTS              

*---------------------MOVE.L, MOVEA.L-----------------------------
JMP_2X      JSR         J_CLR_DM    *Prepare data registers for data manipulation on the DEST MODE digits
            CMP.B       #$1,D2      *is the DEST MODE 1?
            BEQ         J_MOVEAL    *Instruction is determiend to be MOVEA.L                                     ================= < stopped at this point
             
JMP_3X      JSR         INVALID     *Temp, remove once implemented

JMP_4X      JSR         INVALID     *Temp, remove once implemented      

JMP_6X      JSR         INVALID     *Temp, remove once implemented

JMP_8X      JSR         INVALID     *Temp, remove once implemented

JMP_CX      JSR         INVALID     *Temp, remove once implemented

JMP_DX      JSR         INVALID     *Temp, remove once implemented

JMP_EX      JSR         INVALID     *Temp, remove once implemented

*============================================================
*==================ID THIRD OPCODE DIGIT=====================
*============================================================

OPC_04XX    JSR         INVALID     *Temp, remove once implemented

OPC_05XX    JSR         INVALID     *Temp, remove once implemented

*============================================================
*==================OPCODE KNOWN, PRINTING====================
*============================================================

J_MOVEL     JSR         INVALID         *added just for compiling, remove once implemented

J_MOVEAL    JSR         INVALID         *added just for compiling, remove once implemented


*--------------------MOVE.B OPCODE---------------------------
OPC_1XXX    MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'.',(A4)+
            MOVE.B      #'B',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            *JUMP to EACODE table
            RTS

*--------------------ADDQ OPCODE----------------------------
OPC_5XXX    MOVE.B      #'A',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'Q',(A4)+
            MOVE.B      #'.',(A4)+
            *NEED to Determine sizes here
            *JUMP to EACODE table
            RTS

*------------------MOVEQ OPCODE------------------------------
OPC_7XXX    MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'Q',(A4)+
            MOVE.B      #'.',(A4)+
            MOVE.B      #'L',(A4)+
            *jump to EACODE table
            RTS

*------------------SUB OPCODE------------------------------
OPC_9XXX    MOVE.B      #'S',(A4)+
            MOVE.B      #'U',(A4)+
            MOVE.B      #'B',(A4)+
            MOVE.B      #'.',(A4)+
            *NEED to Determine sizes here (opmode 3 bits)
            *jump to EACODE table
            RTS

*============================================================
*=====================HELPER SUBROUTINES=====================
*============================================================

*-----------------------INVALID------------------------------
* Invalid OPCODES jump here.
* $FF is moved into Data Register 6, which indicates to the program that the input is invalid.
*------------------------------------------------------------        
INVALID     MOVE.B      $FF,D6      *Invalid input flag
            RTS

*--------------------GEN SIZE CODE--------------------------
* DECODES SIZE OPCODES FOR MOST OPCODES: SUB
*-----------------------------------------------------------
SIZE_CODE

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
