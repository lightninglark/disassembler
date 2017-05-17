*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
START       ORG         $7000   *where data gets loaded into memory in disassembler

*-----------------------------------------------------
            ADD.B       D0,D7
            ADD.B       (A0),D1
            ADD.B       #123,D2
            ADD.B       (A1)+,D3
            ADD.B       -(A2),D4
            ADD.B       $1234,D5
            ADD.B       $12345678,D6
            ADD.B       D7,(A3)
            ADD.B       D0,-(A4)
            ADD.B       D0,(A5)+
            ADD.B       D0,$1111
            ADD.B       D0,$12345678
            
            ADD.W       D0,D7
            ADD.W       (A0),D1
            ADD.W       #123,D2
            ADD.W       (A1)+,D3
            ADD.W       -(A2),D4
            ADD.W       $1234,D5
            ADD.W       $12345678,D6
            ADD.W       D7,(A3)
            ADD.W       D0,-(A4)
            ADD.W       D0,(A5)+
            ADD.W       D0,$1111
            ADD.W       D0,$12345678
            
            ADD.L       D0,D7
            ADD.L       (A0),D1
            ADD.L       #123,D2
            ADD.L       (A1)+,D3
            ADD.L       -(A2),D4
            ADD.L       $1234,D5
            ADD.L       $12345678,D6
            ADD.L       D7,(A3)
            ADD.L       D0,-(A4)
            ADD.L       D0,(A5)+
            ADD.L       D0,$1111
            ADD.L       D0,$12345678
            
            ADDA.W      D0,A0
            ADDA.W      A1,A2
            ADDA.W      (A3)+,A4
            ADDA.W      -(A5),A6
            ADDA.W      #$AAAA,A0
            ADDA.W      $FFFF,A0
            ADDA.W      $11111111,A0
            
            ADDA.L      D0,A0
            ADDA.L      A1,A2
            ADDA.L      (A3)+,A4
            ADDA.L      -(A5),A6
            ADDA.L      #$AAAA,A0
            ADDA.L      $FFFF,A0
            ADDA.L      $11111111,A0
            
            ADDI.B      #123,D2
            ADDI.B      #100,(A0)
            ADDI.B      #$FF,(A1)+
            ADDI.B      #77,-(A2)
            ADDI.B      #$90,$5000
            ADDI.B      #$F,$FFFFFFFF
            
            ADDI.W      #1234,D2
            ADDI.W      #1001,(A0)
            ADDI.W      #$FF,(A1)+
            ADDI.W      #77,-(A2)
            ADDI.W      #$90,$5000
            ADDI.W      #$F,$FFFFFFFF
            
            ADDI.L      #12345678,D2
            ADDI.L      #100,(A0)
            ADDI.L      #$FFFF,(A1)+
            ADDI.L      #77,-(A2)
            ADDI.L      #$90,$5000
            ADDI.L      #$F,$FFFFFFFF
            
            ADDQ.B      #1,D0
            ADDQ.B      #2,(A0)
            ADDQ.B      #3,(A1)+
            ADDQ.B      #4,-(A2)
            ADDQ.B      #5,$AAAA
            *ADDQ.B      #$6,A4
            ADDQ.B      #7,$FFFFFFFF
            
            ADDQ.W      #1,D0
            ADDQ.W      #2,(A0)
            ADDQ.W      #3,(A1)+
            ADDQ.W      #4,-(A2)
            ADDQ.W      #5,$AAAA
            ADDQ.W      #$6,A4
            ADDQ.W      #7,$FFFFFFFF
            
            ADDQ.L      #1,D0
            ADDQ.L      #2,(A0)
            ADDQ.L      #3,(A1)+
            ADDQ.L      #4,-(A2)
            ADDQ.L      #5,$AAAA
            ADDQ.L      #$6,A4
            ADDQ.L      #7,$FFFFFFFF
            
            AND.B       D0,D1
            AND.B       (A0),D2
            AND.B       (A1)+,D3
            AND.B       -(A3),D5
            AND.B       $4000,D6
            AND.B       $12345678,D7
            AND.B       #$F,D7
            AND.B       D0,(A0)
            AND.B       #$F,(A1)+
            AND.B       #$F,-(A2)
            AND.B       D0,$4000
            AND.B       D1,$12345678
            
            AND.W       D0,D1
            AND.W       (A0),D2
            AND.W       (A1)+,D3
            AND.W       -(A3),D5
            AND.W       $4000,D6
            AND.W       $12345678,D7
            AND.W       #$F,D7
            AND.W       D0,(A0)
            AND.W       #$F,(A1)+
            AND.W       #$F,-(A2)
            AND.W       D0,$4000
            AND.W       D1,$12345678
            
            AND.L       D0,D1
            AND.L       (A0),D2
            AND.L       (A1)+,D3
            AND.L       -(A3),D5
            AND.L       $4000,D6
            AND.L       $12345678,D7
            AND.L       #$F,D7
            AND.L       D0,(A0)
            AND.L       #$F,(A1)+
            AND.L       #$F,-(A2)
            AND.L       D0,$4000
            AND.L       D1,$12345678
            
            
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
