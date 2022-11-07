
0 variable clipxmin
0 variable clipymin
30 variable clipxmax
10 variable clipymax
5 variable grHeight
1 variable grWidth
0 variable currentX
0 variable currentY

: grPosition ( x y -- )
;

: grLine ( c -- ) 
;

: setXY ( x y -- )
;

: grCorePrint ( addr -- )
  dup c@ grWidth !
  grHeight 0 do
    1+ dup c@ grLine
  loop
;

: grCharPrint ( c -- )
  glyph grCorePrint
;
