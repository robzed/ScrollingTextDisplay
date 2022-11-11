
1 variable clipxmin
1 variable clipymin
30 variable clipxmax
10 variable clipymax
5 variable grHeight
1 variable grWidth
1 variable currentX
1 variable currentY
` * variable grChar

: grPosition ( x y -- )
  currentY ! currentX !
;

: setXY ( x y -- )
  currentY ! currentX !
;

: grCursor ( -- )
  \ ." pos=" currentX ? currentY ? cr
  currentX @ currentY @ XY
;

: grLine ( bitmap -- )
 \ dup hex. cr
  grCursor
 \ .BIN8 cr
  1 grWidth @ 1- <<  ( this is the mask ) \ dup hex. ." <--" cr
  grWidth @ 0 do
    \ 2dup hex. hex.
    2dup and IF
      grChar @ EMIT
    ELSE
      SPACE \ ` _ EMIT
    THEN
    1 >>
  loop
  2drop
;
: grCorePrint ( addr -- )
  dup c@ 1+ grWidth !
  grHeight @ 0 do
    1+ dup
    c@ 1 << grLine
    1 currentY +!
    \ 1000 ms
  loop
  drop
  grWidth @ currentX +!
  grHeight @ negate currentY +!
;

\ assumes graphic is smaller than window
: grInBounds ( xstart ystart xend yend -- flag )
;

: grOffscreen ( xstart ystart xend yend -- flag )
  clipymin @ < IF 1 exit THEN ( yend before window )  
  clipxmax @ < IF 1 exit THEN ( xend before window ) 
  clipymax @ > IF 1 exit THEN ( ystart after window )
  clipxmax @ > IF 1 exit THEN ( xstart after window )
  0
;

: grEntirelyOnscreen ( xstart ystart xend yend -- flag )
 wip** clipymin @ >= IF 0 exit THEN ( yend before window )  
 wip** clipxmax @ < IF 0 exit THEN ( xend before window ) 
 wip** clipymax @ > IF 0 exit THEN ( ystart after window )
 wip** clipxmax @ > IF 0 exit THEN ( xstart after window )
  1
;

: grCharPrint ( c -- )
  glyph grCorePrint
;

: grPrint ( addr n -- )
  dup IF
    0 do
      dup c@ grCharPrint
      1+
    loop
  THEN
  drop
;

: grNextRow ( -- )
  grHeight @ currentY +!
; 


: grTest
  CLS
  cr
  white PEN
  65 grCharPrint
  66 grCharPrint
  green PAPER
  ` y grCharPrint
  black PAPER
  grNextRow
  1 currentX !
  red PEN
  S" Rob was here" grPrint
  white PEN
  cr .s
  cr
;

grTest

\ todo:
\   - clipping
\   - colours
