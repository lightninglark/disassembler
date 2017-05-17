*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

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
         
* Possible instructions at JMP_0X are: SUBI, ADDI
JMP_0X      JSR         J_CLR4      *Prepare data registers for data manipulation on the second input hex digit
            CMP.B       #$4,D2      *Is the next hex digit 4?
            BEQ         J_SUBI      *Instruction is determined to be SUBI. Jump to intermediate OPCODE table jump
            CMP.B       #$5,D2      *Is the next hex digit 5?
            BEQ         J_OADDI     *Instruction is determined to be ADDI. Jump to intermediate OPCODE table jump
            JSR         INVALID     *If neither, OPCODE is invalid
            RTS

J_SUBI      JSR         OPC_04XX    *Jump to OPC_04XX in OPCODE table
            RTS
            
J_ADDI      JSR         OPC_05XX    *Jump to OPC_05XX in OPCODE table
            RTS              

* Possible instructions at JMP_2X are: MOVE.L, MOVEA.L
JMP_2X      JSR         J_CLR_DM    *Prepare data registers for data manipulation on the DEST MODE digits
            CMP.B       #$1,D2      *is the DEST MODE 1?
            BEQ         J_MOVEAL    *Instruction is determiend to be MOVEA.L                                     ================= < stopped at this point
             

J_MOVEL

J_MOVEAL

JMP_3X

JMP_4X

JMP_6X

JMP_8X

JMP_CX

JMP_DX

JMP_EX


*-----------------------INVALID------------------------------
* Invalid OPCODES jump here.
* $FF is moved into Data Register 6, which indicates to the program that the input is invalid.
*------------------------------------------------------------        
INVALID     MOVE.B      $FF,D6      *Invalid input flag
            RTS
*============================================================
*==================OPCODE KNOWN, PRINTING====================
*============================================================

OPC4E7_0     RTS

*-------------------NOP LANDS HERE (4E71)--------------------
OPC4E7_1    MOVE.B      #$AA,D6     *Set good data flag. IF THIS WAS A PARAMERTARIZED INSTRUCTION, NEEDS TO HAPPEN AFTER <EA>/Dn/An...

            MOVE.B      #'N',(A4)+
            MOVE.B      #'O',(A4)+
            MOVE.B      #'P',(A4)+
            
            *IF this was a  paramertarize instruction, we'd jump to <EA> decode here
            RTS

OPC4E7_2     RTS
OPC4E7_3     RTS
OPC4E7_4     RTS
OPC4E7_5     RTS
OPC4E7_6     RTS
OPC4E7_7     RTS
OPC4E7_8     RTS
OPC4E7_9     RTS
OPC4E7_A     RTS
OPC4E7_B     RTS
OPC4E7_C     RTS
OPC4E7_D     RTS
OPC4E7_E     RTS


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
