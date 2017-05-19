************************************************************
* TEAM NEVERY LUCKY DISSASSEMBLER
* This file includes Parameter logic (Order, EA, DN/AN/LIST)
* Logic.
************************************************************

*============================================================
*=====================OP_ORDER SUBROUTINES===================
*============================================================


*------------------------OPERATION ORDER--------------------
* Identifies whether the order of the parameters is:
* <EA>,DN or DN,<EA>. It then branches to the appropriate
* order based subroutines. This subroutine is for opcodes:
* ADD, AND, OR, SUB 
*-----------------------------------------------------------
OP_ORD

*---------------------MM OPERATION ORDER--------------------
* Identifies whether the order of the parameters is:
* <EA>,<list> or <list>,<EA>. It then branches to the 
* appropriate order based subroutines. This subroutine is
* for opcodes: MOVEM
*-----------------------------------------------------------
MM_OP_ORD

*---------------------EA SOURCE-----------------------------
* Logic for an EA source operand for opcodes: 
* ADD, AND, OR, SUB
*-----------------------------------------------------------
EA_SRC

*---------------------DN OPERATION ORDER--------------------
* Logic for a DN source operand for opcodes:
* ADD, AND, OR, SUB
*-----------------------------------------------------------
DN_SRC

*---------------------MM OPERATION ORDER--------------------
* Logic for an EA source operand for MOVEM
*-----------------------------------------------------------
MM_EA_SRC

*---------------------MM OPERATION ORDER--------------------
* Logic for a LIST source operand for MOVEM
*-----------------------------------------------------------
MM_LS_SRC


*============================================================
*=====================EA CODES ABLES=========================
*============================================================

*-------------------------GEN EA CODE-----------------------
* For: SUBI, ADDI, MOVEM, LEA, JSR, ADDQ, OR, DIVU, SUB,
*     MULS, AND, ADD, ADDA
* Probably for: LSL/LSR, ASL/ASR,ROL/ROR.
*
*     - Isolates EA mode and EA reg into D3 and D4 respec.
*     - initiates EA decode chain
*-----------------------------------------------------------
GEN_EA_CODE CLR.L       D3          *Make sure D3 is clear
            CLR.L       D4          *Make sure D4 is clear
            
            MOVE.W      D7,D3       *Move untouched opcode into D3
            MOVE.W      D7,D4       *Move untouched opcode into D4
            
            MOVE.B      #10,D1      *Shifting to isolate register
            LSL.W       D1,D3
            MOVE.B      #13,D1
            LSR.W       D1,D3
            
            
*-------------------------MOVE EA CODE-----------------------
* For: MOVE, MOVEA
*
*     - Isolates Source Mode and Reg into D3, D4 respec.
*     - initiates SOURCE decode chain
*     - Isolates Dest Mode and REg into D3, and D4 respec.
*     - initiates DEST decode chain
*-----------------------------------------------------------
MOV_EA_CODE

*============================================================
*=====================EA DECODE CHAIN========================
*============================================================


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
