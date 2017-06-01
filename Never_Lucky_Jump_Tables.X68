************************************************************
* TEAM NEVERY LUCKY DISSASSEMBLER
* This file includes OPCODE logic (OPCODE and size decoding)
************************************************************

*-----------------------JMP_TBL------------------------------
* Purpose: JMP_TBL takes a data register input (D7) and navigates to the correct OPCODE table
*          entry.
*          $FF is saved to D6 if OPCode is determined to be incorrect
* Assumption: Whenever JMP_TBL is called, D7 contains the next new machine code instruction
*------------------------------------------------------------

*============================================================
*===================ID FIRST OPCODE DIGIT====================
*============================================================
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
            JSR         OPC_MOVEB   *If the first hex value is 1, the instruction is determined to be MOVE.B. Jump to OPC_MOVEB in OPCODE table.
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
            JSR         OPC_ADDQ    *If the first hex digit is 5, the instruction is determined to be ADDQ. Jump to OPC_ADDQ in OPCODE table.
            RTS
            
JMP_6       CMP.B       #$6,D2
            BNE         JMP_7
            JSR         JMP_6X      *If the first hex value is 6, jump to JMP_6X to determine the next set of digits
            RTS
            
JMP_7       CMP.B       #$7,D2
            BNE         JMP_8
            JSR         OPC_MOVEQ    *If the first hex digit is 7, the instruction is determined to be MOVEQ. Jump to OPC_MOVEQ in OPCODE table.
            RTS
            
JMP_8       CMP.B       #$8,D2
            BNE         JMP_9
            JSR         JMP_8X      *If the first hex value is 8, jump to JMP_8X to determine the next set of digits
            RTS
            
JMP_9       CMP.B       #$9,D2
            BNE         JMP_A
            JSR         OPC_SUB    *If the first hex digit is 9, the instruction is determined to be SUB. Jump to OPC_9XXX in OPCODE table.
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
            JSR         JMP_CX
      *If the first hex value is C, jump to JMP_CX to determine the next set of digits
            RTS
            
JMP_D       CMP.B       #$D,D2
            BNE         JMP_E   
            JSR         JMP_DX      *If the first hex value is D, jump to JMP_DX to determine the next set of digits
            RTS
            
JMP_E       CMP.B       #$F,D2      *If first hex value is not 0-D, it must be E(valid) or F(invalid)
            BEQ         INVALID     *If first hex value is F, jump to INVALID
            JSR         JMP_EX      *If the first hex value is E, jump to JMP_EX to determine the next set of digits
            
            JMP         INVALID     *Got here? Must be invalid.
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
* %0000 0000 0000 XX00 0000                   
J_CLR2  CLR.L       D2          
        MOVE.W      D7,D2           *Copies D7 contents to D2 for manipulation
        CLR.L       D1
        LSL.W       #8,D2           *Clear the most sig 7 bits
        MOVE.B      #14,D1          *Moves 16 into D1
        LSR.W       D1,D2           *Shifts 16 right to isolate the bit we're working with 
        RTS     

* J_CLR1 prepares the data registers for data manipulation by isolating the rightmost bit of the second hex dig:
* %0000 000X 0000 0000 0000                   
J_CLR1  CLR.L       D2          
        MOVE.W      D7,D2           *Copies D7 contents to D2 for manipulation
        CLR.L       D1
        LSL.W       #7,D2           *Clear the most sig 7 bits
        MOVE.B      #15,D1          *Moves 16 into D1
        LSR.W       D1,D2           *Shifts 16 right to isolate the bit we're working with 
        RTS                         *Return back to JMP_Xn
        
        
J_CLR_LEA   CLR.L       D2          
            MOVE.W      D7,D2           *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #7,D2           *Clear the most sig 7 bits
            MOVE.B      #13,D1          *Moves 16 into D1
            LSR.W       D1,D2           *Shifts 16 right to isolate the bit we're working with 
            RTS    
            

J_CLR_MM    CLR.L       D2          
            MOVE.W      D7,D2           *Copies D7 contents to D2 for manipulation
            CLR.L       D1   
            MOVE.B      #11,D1          *Moves 16 into D1
            LSR.W       D1,D2           *Shifts 16 right to isolate the bit we're working with 
            RTS  
     
* J_CLR_DM prepares the data registers for data manipulation by isolating the DESTINATION MODE bits:
* Also alternatively known as the OPMODE bits for some OPCODES: OR, DIVU, SUB, ADDA, ADD
* %0000 000X XX00 0000 0000          
J_CLR_DM    CLR.L       D2          
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #7,D2       *Clear the most sig 7 bits
            MOVE.B      #13,D1      *Moves 17 into D1
            LSR.W       D1,D2       *Shifts 17 right to isolate the bits we're working with 
            RTS                     *Return back to JMP_Xn     
 
*---------------End Helper functions ------------------------

        
*---------------------SUBI, ADDI-----------------------------
JMP_0X      JSR         J_CLR4      *Isolate next hex digit
            CMP.B       #$4,D2      *Is the next hex digit 4?
            BEQ         J_SUBI      *Instruction is determined to be SUBI. Jump to intermediate OPCODE table jump
            CMP.B       #$6,D2      *Is the next hex digit 5?
            BEQ         J_ADDI      *Instruction is determined to be ADDI. Jump to intermediate OPCODE table jump
            JSR         INVALID     *If neither, OPCODE is invalid
            RTS

J_SUBI      JSR         OPC_SUBI    *Jump to OPC_SUBI in OPCODE table
            RTS
            
J_ADDI      JSR         OPC_ADDI    *Jump to OPC_ADDI in OPCODE table
            RTS              

*---------------------MOVE.L, MOVEA.L----------------------------- 
* NOTE - NO INVALID CASE. Probably correct tho-

JMP_2X      JSR         J_CLR_DM    *Isolate the destination mode bits %0000 000X XX00 0000 0000  
            CMP.B       #$1,D2      *is the DEST MODE 1?
            BEQ         J_MOVEAL    *Instruction is determined to be MOVEA.L Jump to intermediate OPCODE table jump
            JSR         J_MOVEL     *Otherwise, Instruction is determined to be MOVE.L Jump to intermediate OPCODE table jump
            RTS

J_MOVEAL    JSR         OPC_MOVEAL  *Jump to OPC_MOVEAL in OPCODE table
            RTS

J_MOVEL     JSR         OPC_MOVEL   *Jump to OPC_MOVEL in OPCODE table   
            RTS                           
*---------------------MOVE.W, MOVEA.W----------------------------- 
* NOTE - NO INVALID CASE. Probably correct tho- 
            
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
            CMP.B       #$E,D2      *Is the next hex digit E?
            BEQ         J_47X       *Instruction is determined to be NOP, JSR, or RTS. Jump to JMP_47X to determine.
            JSR         J_CLR1      *Otherwise, isolate the %0000 000X 0000 0000 digit
            JSR         J_CLR_LEA
            CMP.B       #7,D2       *Is the last bit 7?
            BEQ         J_LEA       *Instruction is determined to be LEA. Jump to intermediate OPCODE table jump 
            JSR         J_CLR_MM
            CMP.B       #9,D2       *Is the last bit 0?
            BEQ         J_MOVEM     *Instruction is determined to be MOVEM. Jump to intermediate OPCODE table jump 
            JSR         INVALID     *If none of the above, OPCODE is invalid
            RTS                                         
            
J_47X       JSR         JMP_47X     *Instruction is NOP, JSR, or RTS. Jump to JMP_47X to determine.
            RTS
            
J_LEA       JSR         OPC_LEA     *Jump to OPC_LEA in the OPCODE table    
            RTS
            
J_MOVEM     JSR         OPC_MOVEM   *Jump to OPC_MOVEM in the OPCODE table
            RTS
            
*------------------Bcc(BCC, BLT, BGE), BRA------------------------
JMP_6X      JSR         J_CLR4       *Isolate next hex digit 
            CMP.B       #0,D2        *Is the next hex digit 0?
            BEQ         J_BRA        *Instruction is determined to be BRA. Jump to intermediate OPCODE table jump
            JSR         J_Bcc        *Otherwise, Instruction is determined to be some form of Bcc. Jump to intermediate OPCODE table jump
            RTS
            
J_BRA       JSR         OPC_BRA      *Jump to OPC_BRA in the OPCODE table  

            RTS

J_Bcc       JSR         OPC_Bcc      *Jump to OPC_Bcc in the OPCODE table  

            RTS
            
*------------------------OR, DIVU---------------------------------     
JMP_8X      JSR         J_CLR_DM    *Isolate the OPMODE bits %0000 000X XX00 0000 0000
            CMP.B       #3,D2       *Are the bits equivalent to $3?
            BEQ         J_DIVU      *Instruction is determined to be DIVU. Jump to intermediate OPCODE table jump
            JSR         J_OR        *Otherwise, Instruction is determined to be OR. Jump to intermediate OPCODE table jump
            RTS

J_DIVU      JSR         OPC_DIVU    *Jump to OPC_DIVU in the OPCODE table  
            RTS
            
J_OR        JSR         OPC_OR      *Jump to OPC_OR in the OPCODE table  
            RTS

*-----------------------MULS, AND---------------------------------  
JMP_CX      JSR         J_CLR_DM    *Isolate the OPMODE bits %0000 000X XX00 0000 0000
            CMP.B       #7,D2       *Are the bits equivalent to $7?
            BEQ         J_MULS      *Instruction is determined to be MULS. Jump to intermediate OPCODE table jump
            JSR         J_AND       *Otherwise, Instruction is determined to be AND. Jump to intermediate OPCODE table jump
            RTS

J_MULS      JSR         OPC_MULS    *Jump to OPC_MULS in the OPCODE table  
            RTS
            
J_AND       JSR         OPC_AND     *Jump to OPC_AND in the OPCODE table  
            RTS

*-----------------------ADD, ADDA--------------------------------
JMP_DX      JSR         J_CLR_DM    *Isolate OPMODE bits to determine if ADD or ADDA
            CLR.L       D4          *For adding size (easy to do it here).
            MOVE.B      #1,D4       *Set size to WORD
            CMP.B       #3,D2       *Is it Word ADDA?
            BEQ         OP_ADDA
            MOVE.B      #2,D4       *set size to LONG
            CMP.B       #7,D2       *is it Long ADDA?
            BEQ         OP_ADDA
            
            CLR.L       D4          *Not ADDA? Clear the manual size sets
            
            CMP.B       #0,D4       Is it ADD?
            BEQ         OP_ADD
            CMP.B       #1,D4       
            BEQ         OP_ADD
            CMP.B       #2,D4       
            BEQ         OP_ADD
            CMP.B       #4,D4 
            BEQ         OP_ADD
            CMP.B       #5,D4     
            BEQ         OP_ADD
            CMP.B       #6,D4     
            BEQ         OP_ADD       
         
            BRA         INVALID     *Got here, must be invalid data.    
            
OP_ADDA     JSR         OPC_ADDA
            RTS
            
OP_ADD      JSR         OPC_ADD
            RTS

     

*============================================================
*==================ID THIRD OPCODE DIGIT=====================
*============================================================
   
JMP_47X     CMP.W       #$4E71,D7    *Is it NOP?
            BEQ         O_NOP
            CMP.W       #$4E75,D7       *Is it RTS?
            BEQ         O_RTS
            JSR         J_CLR2       *Isolate the 6th and 7th bit
            CMP.B       #2,D2        *Is it JSR?
            BEQ         O_JSR
            JMP         INVALID      *Got here? Must be invalid data.

O_NOP       JSR         OPC_NOP
            RTS

O_RTS       JSR         OPC_RTS
            RTS

O_JSR       JSR         OPC_JSR
            RTS
         

*============================================================
*=====================OPCODE TABLE===========================
*================OPCODE KNOWN, PRINTING======================
*============================================================
* IF YOU DO NOT USE A GET_SIZE_X SUBROUTINE, YOU MUST
* MANUALLY SET THE SIZE CODE IN D4. (0 = B, 1 = W, 2 = L)

*---------------------SUBI OPCODE----------------------------
OPC_SUBI    MOVE.B      #'S',(A4)+
            MOVE.B      #'U',(A4)+
            MOVE.B      #'B',(A4)+
            MOVE.B      #'I',(A4)+
            MOVE.B      #'.',(A4)+
            
            JSR         GET_SIZE_2  *Get 2 bit size code
            JSR         ADD_SIZE    *Add the size character based on size code
            
            JSR         IDATASRC_EA *Jump to #<data>,<ea> operand flow.
            
            RTS

*---------------------ADDI OPCODE----------------------------
OPC_ADDI    MOVE.B      #'A',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'I',(A4)+
            MOVE.B      #'.',(A4)+
            
            JSR         GET_SIZE_2  *Get 2 bit size code
            JSR         ADD_SIZE    *Add the size character based on size code
            
            JSR         IDATASRC_EA *Jump to #<data>,<ea> operand flow.
            
            RTS

*--------------------MOVE.B OPCODE---------------------------
OPC_MOVEB   MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'.',(A4)+


            CLR.L       D4          *Manually set size to byte (D4 = 0)
            JSR         ADD_SIZE    *Add size characters
            
            JSR         MOV_EA_CODE *JUMP to EACODE table for MOVE/MOVEA
            
            RTS

*--------------------ADDQ OPCODE----------------------------
OPC_ADDQ    MOVE.B      #'A',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'Q',(A4)+
            MOVE.B      #'.',(A4)+

            JSR         GET_SIZE_2   *Get size code (placed in D4)
            JSR         ADD_SIZE     *Add size character to string (B/W/L)
            
            JSR         ADDQ_EA      *Start the EA/operand decode logic
 
            RTS

*------------------MOVEQ OPCODE-----------------------------
OPC_MOVEQ   MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'Q',(A4)+
            
            JSR         MOVEQ_EA     *Start the EA/opderand decode logic for moveq
          
            RTS

*------------------SUB OPCODE-------------------------------
OPC_SUB     MOVE.B      #'S',(A4)+
            MOVE.B      #'U',(A4)+
            MOVE.B      #'B',(A4)+
            MOVE.B      #'.',(A4)+

            JSR         GET_SIZE_3  * Size bits will be in D4 after this statement
            
            JSR         OR_ADD_SIZE    * This will add size characters and start operand decode sequence

            RTS

*------------------LEA OPCODE-------------------------------            
OPC_LEA     MOVE.B      #'L',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'A',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            
            CLR.L       D4          *Manually set size to byte (D4 = 0)
            MOVE.B      #2,D4       *Manually set size to long.
            
            JSR         EASRC_ADES
            
            RTS
            
*------------------MOVEM OPCODE----------------------------- 
OPC_MOVEM   MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'M',(A4)+
            MOVE.B      #'.',(A4)+
            
            JSR         GET_SIZE_1
            
            CMP.B       #0,D4       *Change size code so it matches standard formatting
            BEQ         MM_WORD
            CMP.B       #1,D4
            BEQ         MM_LONG

MM_WORD     MOVE.B      #1,D4
            BRA         MM_ADD_S

MM_LONG     MOVE.B      #2,D4
       
MM_ADD_S    JSR         ADD_SIZE
            JSR         MM_OP_ORD
            
            RTS


*------------------MOVEA.L OPCODE----------------------------
OPC_MOVEAL  MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'A',(A4)+
            MOVE.B      #'.',(A4)+

            CLR.L       D4          *Manually set size to byte (D4 = 0)
            MOVE.B      #2,D4       *Set size code to long
            JSR         ADD_SIZE    *Add size characters
            
            JSR         MOV_EA_CODE *JUMP to EACODE table for MOVE/MOVEA
            RTS


*------------------MOVEM.L OPCODE----------------------------
OPC_MOVEL   MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'.',(A4)+

            CLR.L       D4          *Manually set size to byte (D4 = 0)
            MOVE.B      #2,D4       *Set size code to long
            JSR         ADD_SIZE    *Add size characters
            
            JSR         MOV_EA_CODE *JUMP to EACODE table for MOVE/MOVEA
            RTS

*------------------MOVEA.W OPCODE----------------------------
OPC_MOVEAW  MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'A',(A4)+
            MOVE.B      #'.',(A4)+

            CLR.L       D4          *Manually set size to byte (D4 = 0)
            MOVE.B      #1,D4       *Set size code to word
            JSR         ADD_SIZE    *Add size characters
            
            JSR         MOV_EA_CODE *JUMP to EACODE table for MOVE/MOVEA
            RTS


*------------------MOVE.W OPCODE----------------------------
OPC_MOVEW   MOVE.B      #'M',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #'.',(A4)+

            CLR.L       D4          *Manually set size to byte (D4 = 0)
            MOVE.B      #1,D4       *Set size code to word
            JSR         ADD_SIZE    *Add size characters
            
            JSR         MOV_EA_CODE *JUMP to EACODE table for MOVE/MOVEA
            RTS


*---------------------BRA OPCODE----------------------------
OPC_BRA     MOVE.B      #'B',(A4)+
            MOVE.B      #'R',(A4)+
            MOVE.B      #'A',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            
            JSR         ABW       *Grab the next word value (BRA bug)
                        
            RTS

*---------------------Bcc OPCODE----------------------------
OPC_Bcc     MOVE.B      #'B',(A4)+
            *BCC bug, does not use 8bit displacment, but is next word value (ABSW)
            JSR         BCC_CODE    *Get condition code and start decoding
            
            RTS

*--------------------DIVU OPCODE----------------------------
OPC_DIVU    MOVE.B      #'D',(A4)+
            MOVE.B      #'I',(A4)+
            MOVE.B      #'V',(A4)+
            MOVE.B      #'U',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            
            CLR.L       D4          *Manually set size to byte (D4 = 0)
            MOVE.B      #1,D4       *Set size code to word
            
            JSR         EASRC_DDES  *Start operand <ea>,Dn
            
            
            RTS

*---------------------OR OPCODE-----------------------------
OPC_OR      MOVE.B      #'O',(A4)+
            MOVE.B      #'R',(A4)+
            MOVE.B      #'.',(A4)+

            JSR         GET_SIZE_3  * Size bits will be in D4 after this statement
            
            JSR         OR_ADD_SIZE    * This will add size characters and start operand decode sequence

            RTS

*---------------------MULS  OPCODE--------------------------
OPC_MULS    MOVE.B      #'M',(A4)+
            MOVE.B      #'U',(A4)+
            MOVE.B      #'L',(A4)+
            MOVE.B      #'S',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            
            CLR.L       D4          *Manually set size to byte (D4 = 0)
            MOVE.B      #1,D4       *Set size code to word
            
            JSR         EASRC_DDES  *Jump to <ea>,Dn
            
            RTS

*---------------------AND  OPCODE---------------------------
OPC_AND     MOVE.B      #'A',(A4)+
            MOVE.B      #'N',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'.',(A4)+

            JSR         GET_SIZE_3  * Size bits will be in D4 after this statement
            
            JSR         OR_ADD_SIZE *This will add size characters and start operand decode sequence

            RTS
            
*-------------------ADDA OPCODE-----------------------------
OPC_ADDA    MOVE.B      #'A',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'A',(A4)+
            MOVE.B      #'.',(A4)+
            
            JSR         ADD_SIZE    *Size should already be in D4 (special case for ADDA)
            
            JSR         EASRC_ADES  *Start operand decode for <ea>,An format
            
            RTS

*--------------------ADD OPCODE-----------------------------
OPC_ADD     MOVE.B      #'A',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'D',(A4)+
            MOVE.B      #'.',(A4)+

            JSR         GET_SIZE_3  * Size bits will be in D4 after this statement
            
            JSR         OR_ADD_SIZE *This will add size characters and start operand decode sequence

            RTS

*--------------------JSR OPCODE-----------------------------
OPC_JSR     MOVE.B      #'J',(A4)+
            MOVE.B      #'S',(A4)+
            MOVE.B      #'R',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         GEN_EA_CODE *Get EA code
            
            RTS

*--------------------NOP OPCODE-----------------------------
OPC_NOP     MOVE.B      #'N',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'P',(A4)+
            
            RTS

*--------------------RTS OPCODE-----------------------------
OPC_RTS     MOVE.B      #'R',(A4)+
            MOVE.B      #'T',(A4)+
            MOVE.B      #'S',(A4)+
            
            RTS

*===========================================================
*=====================HELPER SUBROUTINES====================
*===========================================================

*-------------------------BCC_DECODE------------------------
* Isolates the 4 bit condition code for BCC OPCODES
*-----------------------------------------------------------
BCC_CODE    CLR.L       D3          *Make sure D3 is empty to hold condition code
            MOVE.W      D7,D3       *Move in original address to be shifted
            LSL.W       #4,D3
            CLR.L       D2
            MOVE.B      #12,D2
            LSR.W       D2,D3
            JSR         BCC_TABLE   *Jump to BCC table now that condition code is in D3
            RTS

*-------------------------BCC_TABLE-------------------------
* This jump table looks at the condition code in D3 to
* select the correct B"CC" for the BCC OPCODE. After the
* correct condition code is selected, it then jumps to the
* 8 bit displacment.
*-----------------------------------------------------------
BCC_TABLE   CMP.B       #$2,D3      *Is it BHI?
            BEQ         BCC_HI
            CMP.B       #$3,D3      *Is it BLS?
            BEQ         BCC_LS      
            CMP.B       #$4,D3      *Is it BCC?
            BEQ         BCC_CC
            CMP.B       #$5,D3      *Is it BCS?
            BEQ         BCC_CS
            CMP.B       #$6,D3      *Is it BNE?
            BEQ         BCC_NE
            CMP.B       #$7,D3      *Is it BEQ?
            BEQ         BCC_EQ
            CMP.B       #$8,D3      *Is it BVC?
            BEQ         BCC_VC      
            CMP.B       #$9,D3      *Is it BVS?
            BEQ         BCC_VS
            CMP.B       #$A,D3      *Is it BPL?
            BEQ         BCC_PL
            CMP.B       #$B,D3      *Is it BMI?
            BEQ         BCC_MI
            CMP.B       #$C,D3      *Is it BGE?
            BEQ         BCC_GE
            CMP.B       #$D,D3      *Is it BLT?
            BEQ         BCC_LT
            CMP.B       #$E,D3      *Is it BGT?
            BEQ         BCC_GT      
            CMP.B       #$F,D3      *Is it BLE?
            BEQ         BCC_LE
            JMP         INVALID     *Got here? Something is wrong.

BCC_HI      MOVE.B      #'H',(A4)+
            MOVE.B      #'I',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS

BCC_LS      MOVE.B      #'L',(A4)+
            MOVE.B      #'S',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS

BCC_CC      MOVE.B      #'C',(A4)+
            MOVE.B      #'C',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_CS      MOVE.B      #'C',(A4)+
            MOVE.B      #'S',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_NE      MOVE.B      #'N',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_EQ      MOVE.B      #'E',(A4)+
            MOVE.B      #'Q',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_VC      MOVE.B      #'V',(A4)+
            MOVE.B      #'C',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS

BCC_VS      MOVE.B      #'V',(A4)+
            MOVE.B      #'S',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_PL      MOVE.B      #'P',(A4)+
            MOVE.B      #'L',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_MI      MOVE.B      #'M',(A4)+
            MOVE.B      #'I',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_GE      MOVE.B      #'G',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_LT      MOVE.B      #'L',(A4)+
            MOVE.B      #'T',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_GT      MOVE.B      #'G',(A4)+
            MOVE.B      #'T',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS
            
BCC_LE      MOVE.B      #'L',(A4)+
            MOVE.B      #'E',(A4)+
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         ABW         *Add absolute word in next word address.
            RTS


*--------------------ADD SIZE-------------------------------
* A simple helper that looks at the size code in D4 to add
* the appropriate B,W,L to the string.
*-----------------------------------------------------------
ADD_SIZE    CMP.B       #0,D4       *Is it a B, <ea>,dn/an
            BEQ         B_SIZE
            CMP.B       #1,D4       *Is it a W, <ea>,dn/an
            BEQ         W_SIZE
            CMP.B       #2,D4       *Is it a L, <ea>,dn/an
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
* size implies GET_SIZE_3). Bit(s) are isolated into D4)
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
            JSR         EASRC_DDES *Move to EA_SRC to start parameter decode sequence
            RTS

W_EA        MOVE.B      #'W',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         EASRC_DDES *Move to EA_SRC to start parameter decode sequence
            RTS

L_EA        MOVE.B      #'L',(A4)+  *Add size character to good string
            MOVE.B      #' ',(A4)+
            MOVE.B      #' ',(A4)+
            JSR         EASRC_DDES *Move to EA_SRC to start parameter decode sequence
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
