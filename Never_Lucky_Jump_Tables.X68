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
            JSR         INVALID     *0x A is an invalid first hex digit. Jump to INVALID
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
*------------------ Helper functions ------------------------
* J_CLR4 prepares the data registers for data manipulation on the second input hex digit by isolating the next 4 bits:
* %0000 XXXX 0000 0000
J_CLR4      CLR.L       D2                                
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #4,D2       *Clear the most sig hex digit
            MOVE.B      #12,D1      *Moves 12 into D1
            LSR.W       D1,D2       *Shifts 12 right to isolate the bits we're working with
            RTS                     *Return back to JMP_Xn    
            
* J_CLR3 prepares the data registers for data manipulation by isolating the next 3 bits:
* %0000 XXX0 0000 0000 0000          
J_CLR3      CLR.L       D2          
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #4,D2       *Clear the most sig hex digit
            MOVE.B      #13,D1      *Moves 13 into D1
            LSR.W       D1,D2       *Shifts 13 right to isolate the bits we're working with 
            RTS                     *Return back to JMP_Xn  

* J_CLR1 prepares the data registers for data manipulation by isolating the rightmost bit of the second hex dig:
* %0000 000X 0000 0000 0000                   
J_CLR1  CLR.L       D2          
        MOVE.W      D7,D2           *Copies D7 contents to D2 for manipulation
        CLR.L       D1
        LSL.W       #7,D2           *Clear the most sig 7 bits
        MOVE.B      #16,D1          *Moves 16 into D1
        LSR.W       D1,D2           *Shifts 16 right to isolate the bit we're working with 
        RTS                         *Return back to JMP_Xn  
     
* J_CLR_DM prepares the data registers for data manipulation by isolating the DESTINATION MODE bits:
* %0000 000X XX00 0000 0000          
J_CLR_DM    CLR.L       D2          
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #7,D2       *Clear the most sig 7 bits
            MOVE.B      #17,D1      *Moves 17 into D1
            LSR.W       D1,D2       *Shifts 17 right to isolate the bits we're working with 
            RTS                     *Return back to JMP_Xn     
 
*---------------End Helper functions ------------------------

        
*---------------------SUBI, ADDI-----------------------------
JMP_0X      JSR         J_CLR4      *Isolate next hex digit
            CMP.B       #$4,D2      *Is the next hex digit 4?
            BEQ         J_SUBI      *Instruction is determined to be SUBI. Jump to intermediate OPCODE table jump
            CMP.B       #$5,D2      *Is the next hex digit 5?
            BEQ         J_ADDI      *Instruction is determined to be ADDI. Jump to intermediate OPCODE table jump
            JSR         INVALID     *If neither, OPCODE is invalid
            RTS

J_SUBI      JSR         OPC_04XX    *Jump to OPC_04XX in OPCODE table
            RTS
            
J_ADDI      JSR         OPC_05XX    *Jump to OPC_05XX in OPCODE table
            RTS              

*---------------------MOVE.L, MOVEA.L----------------------------- NOTE - NO INVALID CASE. Probably correct tho-
JMP_2X      JSR         J_CLR_DM    *Isolate the destination mode bits %0000 000X XX00 0000 0000  
            CMP.B       #$1,D2      *is the DEST MODE 1?
            BEQ         J_MOVEAL    *Instruction is determined to be MOVEA.L Jump to intermediate OPCODE table jump
            JSR         J_MOVEL     *Otherwise, Instruction is determined to be MOVE.L Jump to intermediate OPCODE table jump
            RTS

J_MOVEAL    JSR         OPC_MOVEAL  *Jump to OPC_MOVEAL in OPCODE table
            RTS

J_MOVEL     JSR         OPC_MOVEL   *Jump to OPC_MOVEL in OPCODE table   
            RTS                           
*---------------------MOVE.W, MOVEA.W----------------------------- NOTE - NO INVALID CASE. Probably correct tho-             
JMP_3X      JSR         J_CLR_DM    *Isolate the destination mode bits %0000 000X XX00 0000 0000  
            CMP.B       #$1,D2      *is the DEST MODE 1?
            BEQ         J_MOVEAW    *Instruction is determined to be MOVEA.W Jump to intermediate OPCODE table jump
            JSR         J_MOVEW     *Otherwise, Instruction is determined to be MOVE.W Jump to intermediate OPCODE table jump
            RTS

J_MOVEAW    JSR         OPC_MOVEAW  *Jump to OPC_MOVEAW in OPCODE table
            RTS

J_MOVEW     JSR         OPC_MOVEW   *Jump to OPC_MOVEW in OPCODE table 
            RTS
*-----------------NOP, MOVEM, LEA, JSR, RTS-----------------------
JMP_4X      JSR         J_CLR4      *Isolate next hex digit   
            CMP.B       #7,D2       *Is the next hex digit 7?
            BEQ         J_47X       *Instruction is determined to be NOP, JSR, or RTS. Jump to JMP_47X to determine.
            JSR         J_CLR1      *Otherwise, isolate the %0000 000X 0000 0000 digit
            CMP.B       #1,D2       *Is the last bit 1?
            BEQ         J_LEA       *Instruction is determined to be LEA. Jump to intermediate OPCODE table jump 
            CMP.B       #0,D2       *Is the last bit 0?
            BEQ         J_MOVEM     *Instruction is determined to be MOVEM. Jump to intermediate OPCODE table jump 
            JSR         INVALID     *If none of the above, OPCODE is invalid
            RTS
                                         
            
J_47X       JSR         JMP_47X     *Instruction is NOP, JSR, or RTS. Jump to JMP_47X to determine.
            RTS
            
J_LEA       JSR         OPC_LEA     *Jump to OPC_LEA in the OPCODE table    
            RTS
            
J_MOVEM     JSR         OPC_MOVEM   *Jump to OPC_MOVEM in the OPCODE table
            RTS
            

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

JMP_47X      
*============================================================
*==================OPCODE KNOWN, PRINTING====================
*============================================================



*--------------------MOVE.B OPCODE---------------------------
OPC_1XXX    MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'.',(A4)+
            MOVE.B      #'B',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            *YOU DO NOT NEED TO MANUALLY SET SIZE CODE IF YOU USE A
            *GET SIZE SUBROUTINE CALL.
            CLR.L       D4          *Manually set size to byte (D4 = 0)
            JSR         MOV_EA_CODE *JUMP to EACODE table for MOVE/MOVEA
            RTS

*--------------------ADDQ OPCODE----------------------------
OPC_5XXX    MOVE.B      #'A',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'Q',(A4)+
            MOVE.B      #'.',(A4)+
            *NEED to Determine sizes here
            JSR         GET_SIZE_2   *Get size code (placed in D4)
            JSR         ADD_SIZE     *Add size character to string (B/W/L)
            JSR         ADDQ_EA      *Start the EA/operand decode logic
            
            *JUMP to EACODE table
            RTS

*------------------MOVEQ OPCODE-----------------------------
OPC_7XXX    MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'Q',(A4)+
            MOVE.B      #'.',(A4)+
            MOVE.B      #'L',(A4)+
            
            JSR         MOVEQ_EA     *Start the EA/opderand decode logic for moveq
            
            *Needs special EA decode logic
            *jump to EACODE table
            RTS

*------------------SUB OPCODE-------------------------------
OPC_9XXX    MOVE.B      #'S',(A4)+
            MOVE.B      #'U',(A4)+
            MOVE.B      #'B',(A4)+
            MOVE.B      #'.',(A4)+
            *NEED to Determine sizes here (opmode 3 bits)
            JSR         GET_SIZE_3  * Size bits will be in D4 after this statement
            JSR         OR_ADD_SIZE    * This will add size characters and start operand decode sequence
            *jump to EACODE table
            RTS

*------------------LEA OPCODE-------------------------------            
OPC_LEA     RTS


*------------------MOVEM OPCODE----------------------------- 
OPC_MOVEM   RTS

*------------------MOVEA.L OPCODE----------------------------
OPC_MOVEAL  RTS

*------------------MOVEM.L OPCODE----------------------------
OPC_MOVEL   RTS

*------------------MOVEA.W OPCODE----------------------------
OPC_MOVEAW RTS

*------------------MOVE.W OPCODE----------------------------
OPC_MOVEW  RTS

*===========================================================
*=====================HELPER SUBROUTINES====================
*===========================================================

*--------------------ADD SIZE-------------------------------
* A simple helper that looks at the size code in D4 to add
* the appropriate B,W,L to the string.
*-----------------------------------------------------------
ADD_SIZE    CMP.B       #0,D4       *Is it a B, <ea>,dn
            BEQ         B_SIZE
            CMP.B       #1,D4       *Is it a W, <ea>,dn
            BEQ         W_SIZE
            CMP.B       #2,D4       *Is it a L, <ea>,dn
            BEQ         L_SIZE 
            
B_SIZE      MOVE.B      #'B',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            RTS

W_SIZE      MOVE.B      #'W',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            RTS

L_SIZE      MOVE.B      #'L',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            RTS

*--------------------GET SIZE CODE--------------------------
* The following three subroutines isolate the size bits for
* all opcodes. They are by number of bits (e.g. 3 bits for
* size implies GET_SIZE_3)
*-----------------------------------------------------------
GET_SIZE_3  CLR.L       D4          *Make sure D4 is clear to isolate size bits.
            MOVE.W      D7,D4       *Copy untouched opcode into D4
            LSL.W       #7,D4       *Clear more significant bits
            CLR.L       D3          *Make sure D3 is clear for shifting
            MOVE.B      #13,D3      *Shifting 13 times
            LSR.W       D3,D4       *Move size bits to LSB position
            RTS

GET_SIZE_2  CLR.L       D4          *Make sure D4 is clear to isolate size bits.
            MOVE.W      D7,D4       *Copy untouched opcode into D4
            LSL.W       #8,D4       *Clear more significant bits
            CLR.L       D3          *Make sure D3 is clear for shifting
            MOVE.B      #14,D3      *Shifting 14 times
            LSR.W       D3,D4       *Move size bits to LSB position
            RTS

GET_SIZE_1  CLR.L       D4          *Make sure D4 is clear to isolate size bits.
            MOVE.W      D7,D4       *Copy untouched opcode into D4
            CLR.L       D3          *Make sure D3 is clear for shifting
            MOVE.B      #9,D3       *Shift 9 times to the left
            LSL.W       D3,D4       *Clear more significant bits
            CLR.L       D3          *Make sure D3 is clear for shifting
            MOVE.B      #15,D3      *Shifting 15 times
            LSR.W       D3,D4       *Move size bits to LSB position
            RTS

*--------------------ADD SIZE (Pseudo JMP TABLE)------------
* This subroutine is for ADD, AND, OR, SUB.
* It adds the appropriate "B", "W", "L" and space characters
* to the output strings. It then starts the parameter decode
* sequence for the above 4 subroutines.
* Values 0, 1, 2 => B, W, L => <ea>,Dn => JSR EA_SRC
* Values 4, 5, 6 => B, W, L => Dn,<ea> => JSR DN_SRC
*-----------------------------------------------------------
OR_ADD_SIZE CMP.B       #0,D4       *Is it a B, <ea>,dn
            BEQ         B_EA
            CMP.B       #1,D4       *Is it a W, <ea>,dn
            BEQ         W_EA
            CMP.B       #2,D4       *Is it a L, <ea>,dn
            BEQ         L_EA

            CMP.B       #4,D4       *Is it a B, dn,<ea>
            BEQ         B_DN
            CMP.B       #5,D4       *Is it a W, dn,<ea>
            BEQ         W_DN
            CMP.B       #6,D4       *Is it a L, dn,<ea>
            BEQ         L_DN        
            BRA         INVALID     *Got here, must be invalid data.
            
B_EA        MOVE.B      #'B',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         EA_SRC_DDES *Move to EA_SRC to start parameter decode sequence
            RTS

W_EA        MOVE.B      #'W',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         EA_SRC_DDES *Move to EA_SRC to start parameter decode sequence
            RTS

L_EA        MOVE.B      #'L',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         EA_SRC_DDES *Move to EA_SRC to start parameter decode sequence
            RTS

B_DN        MOVE.B      #'B',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         DN_SRC      *Move to DN_SRC to start parameter decode sequence
            RTS

W_DN        MOVE.B      #'W',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         DN_SRC      *Move to DN_SRC to start parameter decode sequence
            RTS

L_DN        MOVE.B      #'L',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         DN_SRC      *Move to DN_SRC to start parameter decode sequence
            RTS            
            
            
            
            
            
            
            



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
