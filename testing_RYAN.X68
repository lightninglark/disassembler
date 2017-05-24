        ORG    $7000

START       
*            SUB.B       D0,D7
*            SUB.B       (A0),D1
*            SUB.B       #12,D2
*            SUB.B       (A1)+,D3
*            SUB.B       -(A2),D4
*            SUB.B       $1234,D5
*            SUB.B       $12345678,D6
*            SUB.B       D7,(A3)
*            SUB.B       D0,-(A4)
*            SUB.B       D0,(A5)+
*            SUB.B       D0,$1111
*            SUB.B       D0,$12345678
*            
*            SUB.W       D0,D7
*            SUB.W       (A0),D1
*            SUB.W       #123,D2
*            SUB.W       (A1)+,D3
*            SUB.W       -(A2),D4
*            SUB.W       $1234,D5
*            SUB.W       $12345678,D6
*            SUB.W       D7,(A3)
*            SUB.W       D0,-(A4)
*            SUB.W       D0,(A5)+
*            SUB.W       D0,$1111
*            SUB.W       D0,$12345678
*            
*            SUB.L       D0,D7
*            SUB.L       (A0),D1
*            SUB.L       #123569,D2
*            SUB.L       (A1)+,D3
*            SUB.L       -(A2),D4
*            SUB.L       $1234,D5
*            SUB.L       $12345678,D6
*            SUB.L       D7,(A3)
*            SUB.L       D0,-(A4)
*            SUB.L       D0,(A5)+
*            SUB.L       D0,$1111
*            SUB.L       D0,$12345678
*            
*            MOVE.B      D0,D1
*            MOVE.B      D1,D0            
*            MOVE.B      D2,D3
*            MOVE.B      D3,D2            
*            MOVE.B      D4,D5
*            MOVE.B      D5,D4            
*            MOVE.B      D6,D7
*            MOVE.B      D7,D6
*            MOVE.B      $1234,$5678            
*            MOVE.B      $ABCD1234,$EFFE5678
*            MOVE.B      #$69,D0
*            MOVE.B      -(A1),D0
*            MOVE.B      (A2)+,D0
*            MOVE.B      (A3),D0
*            
*            ADDQ.B      #1,D0
*            ADDQ.B      #2,(A0)
*            ADDQ.B      #3,(A1)+
*            ADDQ.B      #4,-(A2)
*            ADDQ.B      #5,$AAAA
*            *ADDQ.B      #6,A4
*            ADDQ.B      #7,$FFFFFFFF
*            
*            ADDQ.W      #1,D0
*            ADDQ.W      #2,(A0)
*            ADDQ.W      #3,(A1)+
*            ADDQ.W      #4,-(A2)
             ADDQ.W      #5,$AAAA
*            ADDQ.W      #$6,A4
*            ADDQ.W      #7,$FFFFFFFF
*            
*            ADDQ.L      #1,D0
*            ADDQ.L      #2,(A0)
*            ADDQ.L      #3,(A1)+
*            ADDQ.L      #4,-(A2)
            ADDQ.L      #5,$AAAA
            *ADDQ.L      #$6,A4
            ADDQ.L      #8,$EEEEEEEE


                


        END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
