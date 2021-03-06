        ORG    $3000

START       LSL.B       #$01,D0
            LSL.B       #$02,D1
            LSL.B       #$03,D2
            LSL.B       #$04,D3
            LSL.B       #$05,D4
            LSL.B       #$06,D5
            LSL.B       #$07,D6
            LSL.B       D0,D7    
            LSL.B       D1,D7  
            LSL.B       D2,D7    
            LSL.B       D3,D7 
            LSL.B       D4,D7    
            LSL.B       D5,D7
            LSL.B       D6,D7    
            LSL.B       D7,D7            
            
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
            
            ADD.B       D0,D7
            ADD.B       (A0),D1
            ADD.B       #123,D2
            ADD.B       #123,(A1)
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
            AND.B       (A1)+,D7
            AND.B       -(A2),D0
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
            AND.W       (A1)+,D7
            AND.W       -(A2),D0
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
            AND.L       (A1)+,D7
            AND.L       -(A2),D0
            AND.L       D0,$4000
            AND.L       D1,$12345678

            
            MULS.W      D0,D1            
            MULS.W      D1,D0
            MULS.W      D2,D3            
            MULS.W      D3,D2
            MULS.W      D4,D5            
            MULS.W      D5,D4
            MULS.W      D6,D7            
            MULS.W      D7,D6
            MULS.W      $1234,D1            
            MULS.W      $ABCD5678,D0
            MULS.W      #$90EF,D1            
            MULS.W      (A0),D0
            MULS.W      (A0)+,D1            
            MULS.W      -(A1),D0
            
            OR.B       D0,D1
            OR.B       (A0),D2
            OR.B       (A1)+,D3
            OR.B       -(A3),D5
            OR.B       $4000,D6
            OR.B       $12345678,D7
            OR.B       #$F,D7
            OR.B       D0,(A0)
            OR.B       #$F,(A1)+
            OR.B       #$F,-(A2)
            OR.B       (A1)+,D3
            OR.B       -(A1),D3
            OR.B       #$AF,-(A2)
            OR.B       D0,$4000
            OR.B       D1,$12345678 
            
            OR.W       D0,D1
            OR.W       (A0),D2
            OR.W       (A1)+,D3
            OR.W       -(A3),D5
            OR.W       $4000,D6
            OR.W       $12345678,D7
            OR.W       #$F,D7
            OR.W       D0,(A0)
            OR.W       (A1)+,D3
            OR.W       -(A1),D3
            OR.W       #$AAAF,-(A2)
            OR.W       #$F,(A1)+
            OR.W       #$F,-(A2)
            OR.W       D0,$4000
            OR.W       D1,$12345678
            
            OR.L       D0,D1
            OR.L       (A0),D2
            OR.L       (A1)+,D3
            OR.L       -(A3),D5
            OR.L       $4000,D6
            OR.L       $12345678,D7
            OR.L       #$F,D7
            OR.L       D0,(A0)
            OR.L       (A1)+,D3
            OR.L       -(A1),D3
            OR.L       #$AAAF,-(A2)
            OR.L       #$F,(A1)+
            OR.L       #$F,-(A2)
            OR.L       D0,$4000
            OR.L       D1,$12345678

            
            DIVU      D0,D1            
            DIVU      D1,D0
            DIVU.W      D2,D3            
            DIVU.W      D3,D2
            DIVU.W      D4,D5            
            DIVU.W      D5,D4
            DIVU.W      D6,D7            
            DIVU.W      D7,D6
            DIVU.W      $1234,D1            
            DIVU.W      $ABCD5678,D0
            DIVU.W      #$90EF,D1            
            DIVU.W      (A0),D0
            DIVU.W      (A0)+,D1            
            DIVU.W      -(A1),D0
            
            BRA         $01620040            
            BRA         $61            
            BRA         $62            
            BRA         $63            
            BRA         $64            
            BRA         $65
            BRA         $66            
            BRA         $67            
            BRA         $68            
            BRA         $69
            BRA         $6A            
            BRA         $6B            
            BRA         $6C            
            BRA         $6D            
            BRA         $6E            
            BRA         $6F
            
            BCC         $00
            BCS         $00
            BEQ         $00
            BGE         $00
            BGT         $00
            BHI         $00
            BLE         $00
            BLS         $00
            BLT         $00
            BMI         $00
            BNE         $00
            BPL         $00
            BVC         $00
            BVS         $00
            
            BCC         $FF
            BCS         $FF
            BEQ         $FF
            BGE         $FF
            BGT         $FF
            BHI         $FF
            BLE         $FF
            BLS         $FF
            BLT         $FF
            BMI         $FF
            BNE         $FF
            BPL         $FF
            BVC         $FF
            BVS         $FF
            
            BCC         $1
            BCS         $2
            BEQ         $3
            BGE         $04
            BGT         $05
            BHI         $06
            BLE         $07
            BLS         $08
            BLT         $09
            BMI         $0A
            BNE         $0B
            BPL         $0C
            BVC         $0D
            BVS         $0E


            NOP
            JSR     TEST1
TEST1       RTS
            MOVE.W      D0,D1
            MOVE.W      D1,D0            
            MOVE.W      D2,D3
            MOVE.W      D3,D2            
            MOVE.W      D4,D5
            MOVE.W      D5,D4            
            MOVE.W      D6,D7
            MOVE.W      D7,D6
            MOVE.W      $1234,$5678            
            MOVE.W      $ABCD1234,$EFFE5678
            MOVE.W      #$69,D0
            MOVE.W      -(A1),D0
            MOVE.W      (A2)+,D0
            MOVE.W      (A3),D0
            
            MOVE.L      D0,D1
            MOVE.L      D1,D0            
            MOVE.L      D2,D3
            MOVE.L      D3,D2            
            MOVE.L      D4,D5
            MOVE.L      D5,D4            
            MOVE.L      D6,D7
            MOVE.L      D7,D6
            MOVE.L      $1234,$5678            
            MOVE.L      $ABCD1234,$EFFE5678
            MOVE.L      #$69,D0
            MOVE.L      -(A1),D0
            MOVE.L      (A2)+,D0
            MOVE.L      (A3),D0
            
            MOVEA.W     D0,A0
            MOVEA.W     D1,A1
            MOVEA.W     D2,A2
            MOVEA.W     D3,A3
            MOVEA.W     D4,A4
            MOVEA.W     D5,A5
            MOVEA.W     D6,A6
            MOVEA.W     D7,A7
            MOVEA.W     A0,A1
            MOVEA.W     A1,A0
            MOVEA.W     A2,A3
            MOVEA.W     A3,A2
            MOVEA.W     A4,A5
            MOVEA.W     A5,A4
            MOVEA.W     A6,A7
            MOVEA.W     A7,A6
            MOVEA.W     (A0),A1
            MOVEA.W     (A1),A0
            MOVEA.W     (A2),A3
            MOVEA.W     (A3),A2
            MOVEA.W     (A4),A5
            MOVEA.W     (A5),A4
            MOVEA.W     (A6),A7
            MOVEA.W     (A7),A6
            MOVEA.W     (A0)+,A1
            MOVEA.W     (A1)+,A0
            MOVEA.W     (A2)+,A3
            MOVEA.W     (A3)+,A2
            MOVEA.W     (A4)+,A5
            MOVEA.W     (A5)+,A4
            MOVEA.W     (A6)+,A7
            MOVEA.W     (A7)+,A6
            MOVEA.W     -(A0),A1
            MOVEA.W     -(A1),A0
            MOVEA.W     -(A2),A3
            MOVEA.W     -(A3),A2
            MOVEA.W     -(A4),A5
            MOVEA.W     -(A5),A4
            MOVEA.W     -(A6),A7
            MOVEA.W     -(A7),A6
            MOVEA.W     $1234,A0
            MOVEA.W     $5678CDEF,A0
            MOVEA.W     #$ABCD,A0

            MOVEA.L     D0,A0
            MOVEA.L     D1,A1
            MOVEA.L     D2,A2
            MOVEA.L     D3,A3
            MOVEA.L     D4,A4
            MOVEA.L     D5,A5
            MOVEA.L     D6,A6
            MOVEA.L     D7,A7
            MOVEA.L     A0,A1
            MOVEA.L     A1,A0
            MOVEA.L     A2,A3
            MOVEA.L     A3,A2
            MOVEA.L     A4,A5
            MOVEA.L     A5,A4
            MOVEA.L     A6,A7
            MOVEA.L     A7,A6
            MOVEA.L     (A0),A1
            MOVEA.L     (A1),A0
            MOVEA.L     (A2),A3
            MOVEA.L     (A3),A2
            MOVEA.L     (A4),A5
            MOVEA.L     (A5),A4
            MOVEA.L     (A6),A7
            MOVEA.L     (A7),A6
            MOVEA.L     (A0)+,A1
            MOVEA.L     (A1)+,A0
            MOVEA.L     (A2)+,A3
            MOVEA.L     (A3)+,A2
            MOVEA.L     (A4)+,A5
            MOVEA.L     (A5)+,A4
            MOVEA.L     (A6)+,A7
            MOVEA.L     (A7)+,A6
            MOVEA.L     -(A0),A1
            MOVEA.L     -(A1),A0
            MOVEA.L     -(A2),A3
            MOVEA.L     -(A3),A2
            MOVEA.L     -(A4),A5
            MOVEA.L     -(A5),A4
            MOVEA.L     -(A6),A7
            MOVEA.L     -(A7),A6
            MOVEA.L     $1234,A0
            MOVEA.L     $5678CDEF,A0
            MOVEA.L     #$ABCD,A0

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
            
            SUBI.B      #123,D2
            SUBI.B      #100,(A0)
            SUBI.B      #$FF,(A1)+
            SUBI.B      #77,-(A2)
            SUBI.B      #$90,$5000
            SUBI.B      #$F,$FFFFFFFF
            
            SUBI.W      #123,D2
            SUBI.W      #100,(A0)
            SUBI.W      #$FF,(A1)+
            SUBI.W      #77,-(A2)
            SUBI.W      #$90,$5000
            SUBI.W      #$F,$FFFFFFFF
            
            SUBI.L      #12345678,D2
            SUBI.L      #100,(A0)
            SUBI.L      #$FFFF,(A1)+
            SUBI.L      #77,-(A2)
            SUBI.L      #$90,$5000
            SUBI.L      #$F,$FFFFFFFF
 
            LEA         $8000,A0
            LEA         (A0),A1
            LEA         $800,A2
            LEA         (A1),A3
            LEA         (A3),A4
            LEA         (A4),A5
            LEA         (A6),A7
            LEA         (A7),A2
            LEA         (A2),A0
            
            SUB.B       D0,D7
            SUB.B       (A0),D1
            SUB.B       #12,D2
            SUB.B       (A1)+,D3
            SUB.B       -(A2),D4
            SUB.B       $1234,D5
            SUB.B       $12345678,D6
            SUB.B       D7,(A3)
            SUB.B       D0,-(A4)
            SUB.B       D0,(A5)+
            SUB.B       D0,$1111
            SUB.B       D0,$12345678
            
            SUB.W       D0,D7
            SUB.W       (A0),D1
            SUB.W       #123,D2
            SUB.W       (A1)+,D3
            SUB.W       -(A2),D4
            SUB.W       $1234,D5
            SUB.W       $12345678,D6
            SUB.W       D7,(A3)
            SUB.W       D0,-(A4)
            SUB.W       D0,(A5)+
            SUB.W       D0,$1111
            SUB.W       D0,$12345678
            
            SUB.L       D0,D7
            SUB.L       (A0),D1
            SUB.L       #123569,D2
            SUB.L       (A1)+,D3
            SUB.L       -(A2),D4
            SUB.L       $1234,D5
            SUB.L       $12345678,D6
            SUB.L       D7,(A3)
            SUB.L       D0,-(A4)
            SUB.L       D0,(A5)+
            SUB.L       D0,$1111
            SUB.L       D0,$12345678
            
            MOVE.B      D0,D1
            MOVE.B      D1,D0            
            MOVE.B      D2,D3
            MOVE.B      D3,D2            
            MOVE.B      D4,D5
            MOVE.B      D5,D4            
            MOVE.B      D6,D7
            MOVE.B      D7,D6
            MOVE.B      $1234,$5678            
            MOVE.B      $ABCD1234,$EFFE5678
            MOVE.B      #$69,D0
            MOVE.B      -(A1),D0
            MOVE.B      (A2)+,D0
            MOVE.B      (A3),D0
            
            ADDQ.B      #1,D0
            ADDQ.B      #2,(A0)
            ADDQ.B      #3,(A1)+
            ADDQ.B      #4,-(A2)
            ADDQ.B      #5,$AAAA
            *ADDQ.B      #6,A4
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
            ADDQ.L      #8,$EEEEEEEE

            MOVEQ     #$9,D0           
            MOVEQ.L     #$69,D1           
            MOVEQ.L     #$69,D2       
            MOVEQ.L     #$69,D3           
            MOVEQ.L     #$69,D4       
            MOVEQ.L     #$69,D5           
            MOVEQ.L     #$69,D6       
            MOVEQ.L     #$69,D7
              

                


        END    START








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
