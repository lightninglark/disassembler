************************************************************
* TEAM NEVERY LUCKY DISSASSEMBLER
* This file includes Parameter logic (Order, EA, DN/AN/LIST)
* Logic.
************************************************************

*============================================================
*================OPERAND ORDER SUBROUTINES===================
*============================================================
* WE'LL MAY STILL NEED TO IMPLEMENT SOME TYPE OF AN_SRC,
* AN_DEST, DATA_SRC (But maybe not since we'll know the 
* specific order of operands for those functions.

*---------------------EA SOURCE-----------------------------
* Logic for an EA source operand for opcodes: 
* ADD, AND, OR, SUB
*-----------------------------------------------------------
EA_SRC      JSR         GEN_EA_CODE *Deal with EA code First
            MOVE.B      #',',(A4)+
            MOVE.B      #'D',(A4)+
            JSR         REG_CODE    *Decode Dn and add number to string
            RTS

*---------------------DN SOURCE-----------------------------
* Logic for a DN source operand for opcodes:
* ADD, AND, OR, SUB
*-----------------------------------------------------------
DN_SRC      MOVE.B      #'D',(A4)+
            JSR         REG_CODE     *Decode Dn and add number to string
            MOVE.B      #',',(A4)+
            JSR         GEN_EA_CODE *Deal with EA code Second
            RTS

*---------------------MM OPERATION ORDER--------------------
* Identifies whether the order of the parameters is:
* <EA>,<list> or <list>,<EA>. It then branches to the 
* appropriate order based subroutines. This subroutine is
* for opcodes: MOVEM
*-----------------------------------------------------------
MM_OP_ORD 
            RTS

*---------------------MM EA SOURCE--------------------------
* Logic for an EA source operand for MOVEM
*-----------------------------------------------------------
MM_EA_SRC   *Deal with EA code first
            *Deal with list second
            RTS

*---------------------MM LIST SOURCE------------------------
* Logic for a LIST source operand for MOVEM
*-----------------------------------------------------------
MM_LS_SRC   *Deal with list first
            *Deal with EA code second
            RTS


*============================================================
*======================BIT ISOLATORS=========================
*============================================================

*-------------------------GEN EA CODE-----------------------
* For: SUBI, ADDI, MOVEM, LEA, JSR, ADDQ, OR, DIVU, SUB,
*     MULS, AND, ADD, ADDA
* Probably for: LSL/LSR, ASL/ASR,ROL/ROR.
*
*     - Isolates EA mode into D6
*     - Isolates EA register into D3
*     - initiates EA decode chain
*-----------------------------------------------------------
GEN_EA_CODE CLR.L       D3          *Make sure D3 is clear
            CLR.L       D6          *Make sure D6 is clear
            CLR.L       D1          *Make sure D1 is clear for shifting
            
            MOVE.W      D7,D3       *Move untouched opcode into D3
            MOVE.W      D7,D6       *Move untouched opcode into D6
            
            MOVE.B      #10,D1      *Shifting to isolate MODE
            LSL.W       D1,D6       
            MOVE.B      #13,D1
            LSR.W       D1,D6       *Move MODE bits to LSB position
            
            LSL.W       D1,D3       *Shifting to isolate REGISTER (#13 already in D1)
            LSR.W       D1,D3       *Move REG bits to LSB position (#13 already in D1)
            
            JSR         EA_TBL      *Decode MODE to select correct <EA>
            RTS
            
*-------------------------MOVE EA CODE-----------------------
* For: MOVE, MOVEA
*
*     - Isolates Source Mode and Reg into D3, D6 respec.
*     - initiates SOURCE decode chain
*     - Isolates Dest Mode and REg into D3, and D6 respec.
*     - initiates DEST decode chain
*     - Code flows like this:
*       SOURCE
*       SEPERATOR
*       DESTINATION
*-----------------------------------------------------------
MOV_EA_CODE CLR.L       D3          *Make sure D3 is clear
            CLR.L       D6          *Make sure D6 is clear
            CLR.L       D1          *Make sure D1 is clear for shifting
            
            MOVE.W      D7,D3       *Move untouched opcode into D3
            MOVE.W      D7,D6       *Move untouched opcode into D6
            
            MOVE.B      #10,D1      *Shifting to isolate MODE
            LSL.W       D1,D6       
            MOVE.B      #13,D1
            LSR.W       D1,D6       *Move MODE bits to LSB position
            
            LSL.W       D1,D3       *Shifting to isolate REGISTER (#13 already in D1)
            LSR.W       D1,D3       *Move REG bits to LSB position (#13 already in D1)
            
            JSR         EA_TBL      *Decode MODE to select correct <EA>
            
            MOVE.B      #',',(A4)+  *SEPERATOR
            
            CLR.L       D3          *Make sure D3 is clear
            CLR.L       D6          *Make sure D6 is clear
            CLR.L       D1          *Make sure D1 is clear for shifting
            
            MOVE.W      D7,D3       *Move untouched opcode into D3
            MOVE.W      D7,D6       *Move untouched opcode into D6
            
            MOVE.B      #7,D1      *Shifting to isolate MODE
            LSL.W       D1,D6       
            MOVE.B      #13,D1
            LSR.W       D1,D6       *Move MODE bits to LSB position
            
            LSL.W       #4,D3       *Shifting to isolate Dest REGISTER
            LSR.W       D1,D3       *Move REG bits to LSB position (#13 already in D1)
            
            JSR         EA_TBL      *Decode MODE to select correct <EA>
            
            RTS
            
            
*-------------------------DECODE DN--------------------------
* This function decides a DN to get the data register number
* It then adds the number to the output strings
*------------------------------------------------------------
REG_CODE    CLR.L       D3          *Make sure D3 is empty to isolate Dn register
            MOVE.W      D7,D3       *Copy untoched opcode into D3 for manipulation
            LSL.W       #4,D3       *Isolate bits and move to LSB position
            CLR.L       D2
            MOVE.B      #13,D2
            LSR.W       D2,D3
            JSR         REG_TBL     *Jump to register table.
            RTS

*============================================================
*=========================JUMP TABLES========================
*============================================================

*-------------------------EA_TBL----------------------------
* This is a jump table for selecting the correct addressing
* MODE which is in D6.
* Possible Modes: Dn = 0, An = 1, (An) = 2, (An)+ = 3,
*                  -(An) = 4, Absolutes = 111
*-----------------------------------------------------------
EA_TBL      CMP.B       #0,D6       *Select correct <EA> mode
            BEQ         DRD
            CMP.B       #1,D6
            BEQ         ARD
            CMP.B       #2,D6
            BEQ         ARI
            CMP.B       #3,D6
            BEQ         ARI_INC
            CMP.B       #4,D6
            BEQ         ARI_DEC
            CMP.B       #7,D6
            BEQ         ABS_ADDR
            JMP         INVALID     *Got here? Must be bad data.

DRD         MOVE.B      #'D',(A4)+
            JSR         REG_TBL     *Reg num should be in D3
            RTS

ARD         MOVE.B      #'A',(A4)+
            JSR         REG_TBL     *Reg num should be in D3
            RTS

ARI         MOVE.B      #'(',(A4)+
            MOVE.B      #'A',(A4)+
            JSR         REG_TBL     *Reg num should be in D3
            MOVE.B      #')',(A4)+
            RTS

ARI_INC     MOVE.B      #'(',(A4)+
            MOVE.B      #'A',(A4)+
            JSR         REG_TBL     *Reg num should be in D3
            MOVE.B      #')',(A4)+
            MOVE.B      #'+',(A4)+
            RTS

ARI_DEC     MOVE.B      #'-',(A4)+
            MOVE.B      #'(',(A4)+
            MOVE.B      #'A',(A4)+
            JSR         REG_TBL     *Reg num should be in D3
            MOVE.B      #')',(A4)+
            RTS

ABS_ADDR    JSR         ABS_TBL
            RTS
            
*-------------------------REG_TBL---------------------------
* This is a jump table for selecting register (both data and
* address) numbers. It looks for the bit value in D3
*-----------------------------------------------------------
REG_TBL     CMP.B       #0,D3       *Select correct number to add to output strings
            BEQ         NUM_0
            CMP.B       #1,D3
            BEQ         NUM_1
            CMP.B       #2,D3
            BEQ         NUM_2
            CMP.B       #3,D3
            BEQ         NUM_3
            CMP.B       #4,D3
            BEQ         NUM_4
            CMP.B       #5,D3
            BEQ         NUM_5
            CMP.B       #6,D3
            BEQ         NUM_6
            CMP.B       #7,D3
            BEQ         NUM_7
            JMP         INVALID     *Got here? Must be bad data.
            
NUM_0       MOVE.B      #'0',(A4)+
            RTS              
NUM_1       MOVE.B      #'1',(A4)+
            RTS
NUM_2       MOVE.B      #'2',(A4)+
            RTS
NUM_3       MOVE.B      #'3',(A4)+
            RTS
NUM_4       MOVE.B      #'4',(A4)+
            RTS
NUM_5       MOVE.B      #'5',(A4)+
            RTS
NUM_6       MOVE.B      #'6',(A4)+
            RTS
NUM_7       MOVE.B      #'7',(A4)+
            RTS

*-------------------------ABS_TBL----------------------------
* This is a jump table for selecting the correct ABSOLUTE
* Addressing mode [(xxx).W, (xxx).L, #<data>.
* 3 Possibilities: (xxx).W = 0, (xxx).L = 1, #<data> = 4
* Register number should be in D3
*-----------------------------------------------------------
ABS_TBL     CMP.B       #0,D3       *Select correct number to add to output strings
            BEQ         ABW
            CMP.B       #1,D3
            BEQ         ABL
            CMP.B       #4,D3
            BEQ         IDATA
            JMP         INVALID     *Got here? Must be bad data.
            
ABW         MOVE.B      #'$',(A4)+
            CLR.L       D1          *Make sure D1 is clear
            MOVE.W      (A5)+, D1   *Increment counter by WORD (grab word data)
            JSR         W_H2A       *convert absolute value to ascii and add to good string
            RTS

ABL         MOVE.B      #'$',(A4)+
            CLR.L       D1          *Make sure D1 is clear
            MOVE.L      (A5)+, D1   *Increment counter by WORD (grab word data)
            JSR         L_H2A
            RTS
            
IDATA       MOVE.B      #'#',(A4)+
            MOVE.B      #'$',(A4)+  *Immediate value will be in Hex
            JSR         IMD_TBL
            RTS
            
*-------------------------IMD_TBL---------------------------
* This is a jump table for selecting the correct Immediate
* Data output based on the size code. Size code should be in
* D4
*-----------------------------------------------------------
IMD_TBL     CMP.B       #0,D4       *Is it byte size code?
            BEQ         B_IMD       
            CMP.B       #4,D4
            BEQ         B_IMD

            CMP.B       #1,D4       *Is it a word size code?
            BEQ         W_IMD
            CMP.B       #5,D4
            BEQ         W_IMD
            
            CMP.B       #2,D4       *Is it a long word size code?
            BEQ         L_IMD
            CMP.B       #6,D4
            BEQ         L_IMD
            
            BRA         INVALID     *Got here? Must be bad data.
            
B_IMD       CLR.L       D1
            MOVE.W      (A5)+,D1    *Make sure D1 is clear
            JSR         B_H2A       *Incremeint by WORD (but translate byte only)
            RTS

W_IMD       CLR.L       D1          *Make sure D1 is clear
            MOVE.W      (A5)+, D1   *Increment counter by WORD (grab word data)
            JSR         W_H2A
            RTS

L_IMD       CLR.L       D1          *Make sure D1 is clear
            MOVE.L      (A5)+, D1   *Increment counter by LONGWORD (grab LONGWORD data)
            JSR         L_H2A
            RTS
                               


*============================================================
*=========================HELPER SUBROUTINES=================
*============================================================

*-------------------------Byte Hex to Ascii-----------------
* 
*-----------------------------------------------------------
B_H2A       CLR.L       D0          *Make sure D0 is clear (for counting)
            CLR.L       D2          *Make sure D2 is empty (each individual char)
            CLR.L       D3          *Make sure D3 is empty (for shifting source operand)
            MOVE.B      #$2,D0      *Counter
            BRA         B_ISO_DIG   *Begin isolating chars
            
B_ISO_DIG   ROL.B       #4,D1       *Move first significant hex char to least sig position
            
            MOVE.B      D1,D2       *Move to D2 to isolate least sig hex char
            
            MOVE.B      #4,D3      *Shift left 28 times
            LSL.B       D3,D2       *Isolated hex digit now is $X0000000
            ROL.B       #4,D2       *Isolated hex digit is now $0000000X
            
            CMPI.B      #$9,D2      *Is it a number?
            BLE         B_NUM       *If it is, process number
            BRA         B_LET       *If not, process letter
            
B_NUM       ADDI.B      #$30,D2     *Make it an ascii number
            BRA         B_ADD_CHAR  *add to strings and continue
            
B_LET       ADDI.B      #$37,D2     *Make it an ascii letter
            BRA         B_ADD_CHAR  *add to strings and continue

B_ADD_CHAR  MOVE.B      D2,(A4)+    *Add to the good data string
            SUBI.B      #$1,D0      *decrement counter
            CMPI.B      #$0,D0      *Check if we're done            
            BGT         B_ISO_DIG   *If not, continue tranlation   
            
            RTS

*-------------------------Word Hex to Ascii-----------------
* 
*-----------------------------------------------------------
W_H2A       CLR.L       D0          *Make sure D0 is clear (for counting)
            CLR.L       D2          *Make sure D2 is empty (each individual char)
            CLR.L       D3          *Make sure D3 is empty (for shifting source operand)
            MOVE.B      #$4,D0      *Counter
            BRA         W_ISO_DIG   *Begin isolating chars
            
W_ISO_DIG   ROL.W       #4,D1       *Move first significant hex char to least sig position
            
            MOVE.B      D1,D2       *Move to D2 to isolate least sig hex char
            
            MOVE.B      #12,D3      *Shift left 28 times
            LSL.W       D3,D2       *Isolated hex digit now is $X0000000
            ROL.W       #4,D2       *Isolated hex digit is now $0000000X
            
            CMPI.B      #$9,D2      *Is it a number?
            BLE         W_NUM       *If it is, process number
            BRA         W_LET       *If not, process letter
            
W_NUM       ADDI.B      #$30,D2     *Make it an ascii number
            BRA         W_ADD_CHAR  *add to strings and continue
            
W_LET       ADDI.B      #$37,D2     *Make it an ascii letter
            BRA         W_ADD_CHAR  *add to strings and continue

W_ADD_CHAR  MOVE.B      D2,(A4)+    *Add to the good data string
            SUBI.B      #$1,D0      *decrement counter
            CMPI.B      #$0,D0      *Check if we're done            
            BGT         W_ISO_DIG   *If not, continue tranlation   
            
            RTS
*-------------------------Long Hex to Ascii-----------------
* 
*-----------------------------------------------------------
L_H2A       CLR.L       D0          *Make sure D0 is clear (for counting)
            CLR.L       D2          *Make sure D2 is empty (each individual char)
            CLR.L       D3          *Make sure D3 is empty (for shifting source operand)
            MOVE.B      #$8,D0      *Counter
            BRA         L_ISO_DIG   *Begin isolating chars
            
L_ISO_DIG   ROL.L       #4,D1       *Move first significant hex char to least sig position
            
            MOVE.B      D1,D2       *Move to D2 to isolate least sig hex char
            
            MOVE.B      #28,D3      *Shift left 28 times
            LSL.L       D3,D2       *Isolated hex digit now is $X0000000
            ROL.L       #4,D2       *Isolated hex digit is now $0000000X
            
            CMPI.B      #$9,D2      *Is it a number?
            BLE         L_NUM       *If it is, process number
            BRA         L_LET       *If not, process letter
            
L_NUM       ADDI.B      #$30,D2     *Make it an ascii number
            BRA         L_ADD_CHAR  *add to strings and continue
            
L_LET       ADDI.B      #$37,D2     *Make it an ascii letter
            BRA         L_ADD_CHAR  *add to strings and continue

L_ADD_CHAR  MOVE.B      D2,(A4)+    *Add to the good data string
            SUBI.B      #$1,D0      *decrement counter
            CMPI.B      #$0,D0      *Check if we're done            
            BGT         L_ISO_DIG   *If not, continue tranlation   
            
            RTS





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
