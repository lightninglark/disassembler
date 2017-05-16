*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
START       ORG         $7000   *where data gets loaded into memory in disassembler

            NOP
            MOVE.B      D1,D0
            NOP                 *look for machine code at ORG

            SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
