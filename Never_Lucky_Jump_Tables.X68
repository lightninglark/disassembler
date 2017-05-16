*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

*============================================================
*===================ID FIRST OPCODE DIGIT====================
*============================================================

*-----------------------IDENTIFY----------------------------
* Purpose: IDENTIFY takes a data register input (D7) and identifies what instruction it is.
*          $AA is saved to D6 if OPCode is determined to be correct, or $FF if incorrect
*          ie) <D7> = input <D6> = $AA
* Assumption: Whenever IDENTIFY is called, D7 contains the next new machine code instruction
*-----------------------------------------------------------
JMP_TBL    CLR.L       D2
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            MOVE.B      #12,D1      *Moves 12 into D1
            LSR.W       D1,D2       *Shifts 12 bits so the remaining contents = the left 4 bits of D7
                        
OC_0        CMP.B       #$0,D2      *Following section determines what hex value the first 4 digits are
            BNE         OC_1        *If the first hex value is not 0, branch and see if its 1
            JSR         OPC_0       *If the first hex value is 0, jump to First_0
            RTS                     *Finished all jumping; whole instruction should be identified at this point
            
OC_1        CMP.B       #$1,D2
            BNE         OC_2        *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         OPC_1 
            RTS                     *Finished all jumping; whole instruction should be identified at this point, and so on       
           
OC_2        CMP.B       #$2,D2
            BNE         OC_3 
            JSR         OPC_2
            RTS
            
OC_3        CMP.B       #$3,D2
            BNE         OC_4
            JSR         OPC_3 
            RTS
*OC_4 USED           
OC_4        CMP.B       #$4,D2      *Where NOP SHOULD LAND
            BNE         OC_5
            JSR         OPC_4
            RTS
            
OC_5        CMP.B       #$5,D2
            BNE         OC_6
            JSR         OPC_5
            RTS
            
OC_6        CMP.B       #$6,D2
            BNE         OC_7
            JSR         OPC_6
            RTS
            
OC_7        CMP.B       #$7,D2
            BNE         OC_8
            JSR         OPC_7
            RTS
            
OC_8        CMP.B       #$8,D2
            BNE         OC_9
            JSR         OPC_8
            RTS
            
OC_9        CMP.B       #$9,D2
            BNE         OC_A
            JSR         OPC_9
            RTS
            
OC_A        CMP.B       #$A,D2
            BNE         OC_B
            JSR         OPC_A
            RTS
            
OC_B        CMP.B       #$B,D2
            BNE         OC_C
            JSR         OPC_B
            RTS
            
OC_C        CMP.B       #$C,D2
            BNE         OC_D
            JSR         OPC_C
            RTS
            
OC_D        CMP.B       #$D,D2
            BNE         OC_E
            JSR         OPC_D
            RTS
            
*Maybe not? Illegal characters like $W mind fine there way into testing file, may need a ILLEGAL else case
OC_E        JSR         OPC_E     *If first hex value is not 0-D, it must be E. Branch to First_E
            RTS
 

*============================================================
*==================ID SECOND OPCODE DIGIT====================
*============================================================
           
*------------------------OPC_0----------------------------
*Purpose: First_0 is a subroutine of IDENTIFY. If First_0 is branched to, that means the first
*         four digits of the machine code are 0000
*         Possible instructions are: ADDI, SUBI    
*-----------------------------------------------------------           
OPC_0     RTS          
OPC_1     RTS
OPC_2     RTS
OPC_3     RTS

*------------------------OPC_4----------------------------
*Purpose: First_4 is a subroutine of IDENTIFY. If First_4 is branched to, that means the first
*         four digits of the machine code are 0100
*         Possible instructions are: NOP, MOVEM, LEA, JSR, RTS
*
*         Next 3 bits of instruction code help determine what the instruction is    
*----------------------------------------------------------- 
OPC_4       CLR.L       D2
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            LSL.W       #4,D2       *Clear the most sig hex digit
            MOVE.B      #12,D1      *Moves 12 into D1
            LSR.W       D1,D2       *Shifts 12 right to isolate Digit we're working with at $0000000X
                        
OC4_0       CMP.B       #$0,D2      *Following section determines what hex value the first 4 digits are
            BNE         OC4_1       *If the first hex value is not 0, branch and see if its 1
            JSR         OPC4_0      *If the first hex value is 0, jump to First_0
            RTS                     *Finished all jumping; whole instruction should be identified at this point
            
OC4_1       CMP.B       #$1,D2
            BNE         OC4_2       *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         OPC4_1 
            RTS                     *Finished all jumping; whole instruction should be identified at this point, and so on       
           
OC4_2       CMP.B       #$2,D2
            BNE         OC4_3 
            JSR         OPC4_2
            RTS
            
OC4_3       CMP.B       #$3,D2
            BNE         OC4_4
            JSR         OPC4_3 
            RTS
           
OC4_4       CMP.B       #$4,D2 
            BNE         OC4_5
            JSR         OPC4_4
            RTS
            
OC4_5       CMP.B       #$5,D2
            BNE         OC4_6
            JSR         OPC4_5
            RTS
            
OC4_6       CMP.B       #$6,D2
            BNE         OC4_7
            JSR         OPC4_6
            RTS
            
OC4_7       CMP.B       #$7,D2
            BNE         OC4_8
            JSR         OPC4_7
            RTS
            
OC4_8       CMP.B       #$8,D2
            BNE         OC4_9
            JSR         OPC4_8
            RTS
            
OC4_9       CMP.B       #$9,D2
            BNE         OC4_A
            JSR         OPC4_9
            RTS
            
OC4_A       CMP.B       #$A,D2
            BNE         OC4_B
            JSR         OPC4_A
            RTS
            
OC4_B       CMP.B       #$B,D2
            BNE         OC4_C
            JSR         OPC4_B
            RTS
            
OC4_C       CMP.B       #$C,D2
            BNE         OC4_D
            JSR         OPC4_C
            RTS
            
OC4_D       CMP.B       #$D,D2
            BNE         OC4_E
            JSR         OPC4_D
            RTS
            
*Maybe not? Illegal characters like $W mind fine there way into testing file, may need a ILLEGAL else case
*OC4_E USED                         WHERE NOP LANDS
OC4_E       JSR         OPC4_E     *If first hex value is not 0-D, it must be E. Branch to First_E
            RTS
                                              
OPC_5       RTS
OPC_6       RTS
OPC_7       RTS
OPC_8       RTS
OPC_9       RTS
OPC_A       RTS
OPC_B       RTS
OPC_C       RTS
OPC_D       RTS
OPC_E       RTS

*============================================================
*===================ID THIRD OPCODE DIGIT====================
*============================================================

OPC4_0      RTS
OPC4_1      RTS
OPC4_2      RTS
OPC4_3      RTS
OPC4_4      RTS
OPC4_5      RTS
OPC4_6      RTS
OPC4_7      RTS
OPC4_8      RTS
OPC4_9      RTS
OPC4_A      RTS
OPC4_B      RTS
OPC4_C      RTS
OPC4_D      RTS

*-------------------NOP LANDS HERE---------------------------------
OPC4_E      CLR.L       D2
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1      
            LSL.L       #8,D2       *Clear the two most significant hex digits
            MOVE.B      #12,D1      *Moves 12 into D1 for shifting
            LSR.W       D1,D2       *Shifts 12 to the right, THIRD hex digit lands $0000000X
                        
OC4E_0      CMP.B       #$0,D2      *Following section determines what hex value the first 4 digits are
            BNE         OC4E_1      *If the first hex value is not 0, branch and see if its 1
            JSR         OPC4E_0     *If the first hex value is 0, jump to First_0
            RTS                     *Finished all jumping; whole instruction should be identified at this point
            
OC4E_1      CMP.B       #$1,D2
            BNE         OC4E_2      *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         OPC4E_1 
            RTS                     *Finished all jumping; whole instruction should be identified at this point, and so on       
           
OC4E_2      CMP.B       #$2,D2
            BNE         OC4E_3 
            JSR         OPC4E_2
            RTS
            
OC4E_3      CMP.B       #$3,D2
            BNE         OC4E_4
            JSR         OPC4E_3 
            RTS
           
OC4E_4      CMP.B       #$4,D2      
            BNE         OC4E_5
            JSR         OPC4E_4
            RTS
            
OC4E_5      CMP.B       #$5,D2
            BNE         OC4E_6
            JSR         OPC4E_5
            RTS
            
OC4E_6      CMP.B       #$6,D2
            BNE         OC4E_7
            JSR         OPC4E_6
            RTS
*OC4E_7 USED            
OC4E_7      CMP.B       #$7,D2      *NOP LANDS HERE
            BNE         OC4E_8
            JSR         OPC4E_7
            RTS
            
OC4E_8      CMP.B       #$8,D2
            BNE         OC4E_9
            JSR         OPC4E_8
            RTS
            
OC4E_9      CMP.B       #$9,D2
            BNE         OC4E_A
            JSR         OPC4E_9
            RTS
            
OC4E_A      CMP.B       #$A,D2
            BNE         OC4E_B
            JSR         OPC4E_A
            RTS
            
OC4E_B      CMP.B       #$B,D2
            BNE         OC4E_C
            JSR         OPC4E_B
            RTS
            
OC4E_C      CMP.B       #$C,D2
            BNE         OC4E_D
            JSR         OPC4E_C
            RTS
            
OC4E_D      CMP.B       #$D,D2
            BNE         OC4E_E
            JSR         OPC4E_D
            RTS
            
*Maybe not? Illegal characters like $W mind fine there way into testing file, may need a ILLEGAL else case
OC4E_E      JSR         OPC4_E     *If first hex value is not 0-D, it must be E. Branch to First_E
            RTS

*============================================================
*==================ID FOURTH OPCODE DIGIT====================
*============================================================
OPC4E_0     RTS
OPC4E_1     RTS
OPC4E_2     RTS
OPC4E_3     RTS
OPC4E_4     RTS
OPC4E_5     RTS
OPC4E_6     RTS
*---------------------WHERE NOP LANDS--------------------
OPC4E_7     CLR.L       D2
            MOVE.W      D7,D2       *Copies D7 contents to D2 for manipulation
            CLR.L       D1
            MOVE.B      #12,D1      *Move 12 into D1 for shifting
            LSL.W       D1,D2       *Clear the three most significant hex digits
            LSR.W       D1,D2       *Shift right 12 spaces to make working digit $0000000X
                        
OC4E7_0     CMP.B       #$0,D2      *Following section determines what hex value the first 4 digits are
            BNE         OC4E7_1     *If the first hex value is not 0, branch and see if its 1
            JSR         OPC4E7_0    *If the first hex value is 0, jump to First_0
            RTS                     *Finished all jumping; whole instruction should be identified at this point
*OC4E7_1 USED            
OC4E7_1     CMP.B       #$1,D2      *NOP LANDS HERE
            BNE         OC4E7_2     *If the first hex value is not 2, branch and see if its 3, and so on
            JSR         OPC4E7_1 
            RTS                     *Finished all jumping; whole instruction should be identified at this point, and so on       
           
OC4E7_2     CMP.B       #$2,D2
            BNE         OC4E7_3 
            JSR         OPC4E7_2
            RTS
            
OC4E7_3     CMP.B       #$3,D2
            BNE         OC4E7_4
            JSR         OPC4E7_3 
            RTS
           
OC4E7_4     CMP.B       #$4,D2      
            BNE         OC4E7_5
            JSR         OPC4E7_4
            RTS
            
OC4E7_5     CMP.B       #$5,D2
            BNE         OC4E7_6
            JSR         OPC4E7_5
            RTS
            
OC4E7_6     CMP.B       #$6,D2
            BNE         OC4E7_7
            JSR         OPC4E7_6
            RTS
            
OC4E7_7     CMP.B       #$7,D2
            BNE         OC4E7_8
            JSR         OPC4E7_7
            RTS
            
OC4E7_8     CMP.B       #$8,D2
            BNE         OC4E7_9
            JSR         OPC4E7_8
            RTS
            
OC4E7_9     CMP.B       #$9,D2
            BNE         OC4E7_A
            JSR         OPC4E7_9
            RTS
            
OC4E7_A     CMP.B       #$A,D2
            BNE         OC4E7_B
            JSR         OPC4E7_A
            RTS
            
OC4E7_B     CMP.B       #$B,D2
            BNE         OC4E7_C
            JSR         OPC4E7_B
            RTS
            
OC4E7_C     CMP.B       #$C,D2
            BNE         OC4E7_D
            JSR         OPC4E7_C
            RTS
            
OC4E7_D     CMP.B       #$D,D2
            BNE         OC4E7_E
            JSR         OPC4E7_D
            RTS
            
*Maybe not? Illegal characters like $W mind fine there way into testing file, may need a ILLEGAL else case
OC4E7_E     JSR         OPC4E7_E     *If first hex value is not 0-D, it must be E. Branch to First_E
            RTS


OPC4E_8     RTS
OPC4E_9     RTS
OPC4E_A     RTS
OPC4E_B     RTS
OPC4E_C     RTS
OPC4E_D     RTS
OPC4E_E     RTS

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
