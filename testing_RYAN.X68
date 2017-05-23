        ORG    $7000

START       
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

                


        END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
