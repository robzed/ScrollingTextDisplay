
\ this clip variables are inclusive to be start of window/region
\ notice top/left = (1,1)
1 variable clipxmin
1 variable clipymin
70 variable clipxmax
20 variable clipymax
\ current height and width - internal
5 variable grHeight
1 variable grWidth
\ current top-left print position
1 variable currentX
1 variable currentY
\ what character is used for a 'on' pixel
\ (off pixel is a space)
` * variable grChar

\  used by clipping, should be 0 otherwise
0 variable FontWidthOffset


\ Set the postion to draw at
: grSetXY ( x y -- )
  currentY ! currentX !
;

\ move the cursor to the current position
: grCursor ( -- )
  \ ." pos=" currentX ? currentY ? cr
  currentX @ currentY @ XY
;

\ internal - draw a bitmap line
: grLine ( bitmap -- )
 \ dup hex. cr
  grCursor
 \ .BIN8 cr
  1 grWidth @ FontWidthOffset @ - 1- <<  ( this is the mask ) \ dup hex. ." <--" cr
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

\ internal - draw a character, no clipping or width setting
\ addr is address of raw font data, beyond width
: grNoClipPrint ( addr -- )
  grHeight @ 0> grWidth @ 0> AND IF
     grHeight @ 0 do
      dup
      c@ 1 << grLine
      1 currentY +!
      \ 1000 ms
      1+ \ change address
    loop
    grHeight @ negate currentY +!
  THEN
  drop
;

: endy ( -- yend )
  currentY @ grHeight @ + 1-
;
: endx ( -- xend )
  currentX @ grWidth c@ + 1-
;

\ Is the bounding rectangle supplied entirely off screen
: grEntirelyOffscreen ( -- flag )
  endy clipymin @ < IF true exit THEN ( yend before window )  
  endx clipxmin @ < IF true exit THEN ( xend before window ) 
  currentY @ clipymax @ > IF true exit THEN ( ystart after window )
  currentX @ clipxmax @ > IF true exit THEN ( xstart after window )
  false
;

\ Is the bound rectangle supplied entirely on screen
: grEntirelyOnscreen ( -- flag )
  endy clipymax @ > IF false exit THEN ( yend before-or-at end-of-window )  
  endx clipxmax @ > IF false exit THEN ( xend before-or-at end-of-window ) 
  currentY @ clipymin @ < IF false exit THEN ( ystart after-or-at start-of-window )
  currentX @ clipxmin @ < IF false exit THEN ( xstart after-or-at start-of-window )
  true
;
: getBoundingRect ( xstart ystart xend yend -- )
  currentX @ currentY @   ( startx starty ) 
  endx endy ( endx endy )
;

: doClipMinY ( addr -- addr' )
  currentY @ clipymin @ -   ( Y < min then negative result - needs clipped by that amount)
  dup 0< IF
    dup grHeight +!    \ subtract the height by that amount
    negate dup
      currentY +!  \ start later on screen
      +            \ modify font address so we start later
  ELSE
    drop
  THEN
;

: doClipMinX ( -- )
  currentX @ clipxmin @ -   ( X < min then negative result - needs clipped by that amount)
  dup 0< IF
    dup grWidth +!    \ subtract the width be that amount
    dup negate
       currentX +!      \ increase the currentX by that amount
       FontWidthOffset  \ make sure it starts further along the bitmap
  ELSE
    drop
  THEN
;

: doClipMaxY ( -- )
  clipymax @ endy -   ( Y < min then postive result - needs clipped by that amount)
  dup 0< IF
    grHeight +!    \ subtract the height be that amount so we finish earlier
  ELSE
    drop
  THEN
;

: doClipMaxX ( -- )
  clipxmax @ endx -   ( Y < min then postive result - needs clipped by that amount)
  dup 0< IF
    grWidth +!    \ subtract the width be that amount
  ELSE
    drop
  THEN
;


: grClipPrint ( addr -- )
  dup c@ 1+ grWidth !
  1+ \ skip font width byte
  grEntirelyOnscreen IF
    grNoClipPrint
  ELSE
    grEntirelyOffscreen IF
      drop
    ELSE
      grHeight @ swap   \ store height on stack
      \ clip one or two axis
      doClipMinY doClipMaxY
      doClipMinX doClipMaxY
      grNoClipPrint
      grHeight ! \ restore height
      0 FontWidthOffset !    \ make sure FontWidthOffset is zero afterwards
    THEN
  THEN
;

: grCharPrint ( c -- )
  glyph dup grClipPrint
  c@ 1+ currentX +!
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

: grDecodeColour ( c -- )
\  dup 3 <= IF 
    dup ` 0 = IF drop black PEN THEN 
    dup ` 1 = IF drop blue PEN THEN 
    dup ` 2 = IF drop red PEN THEN 
    dup ` 3 = IF drop magenta PEN THEN 
\  ELSE
    dup ` 4 = IF drop green PEN THEN 
    dup ` 5 = IF drop cyan PEN THEN 
    dup ` 6 = IF drop yellow PEN THEN 
    dup ` 7 = IF drop white PEN THEN 
\  THEN
    drop
;

\ Same as grPrint but ^1 ^2 ^3 etc changes colours
: grPrintColour ( addr n -- )
  dup IF
    0 do
      dup c@ dup ` ^ = IF
        ." not finished yet" exit
        \ throw away character and decode colour ( next character)
        drop 1+ dup c@ grDecodeColour
      ELSE
        grCharPrint
      THEN
      1+
    loop
  THEN
  drop
;

: grNextRow ( -- )
  grHeight @ currentY +!
; 

: grCR ( -- )
  grNextRow
  1 currentX !
;

\ grTest1 expected:
\   ABY on top line
\   message on second line
\   variable width test third line
\   4 zeros in tests
: grTest1
  CLS

  white PEN
  65 grCharPrint
  66 grCharPrint
  green PAPER
  ` y grCharPrint
  black PAPER
  grCR
  red PEN
  S" Rob was here" grPrint
  blue PEN
  grCR
  S" MIMN1" grPrint
  white PEN

  cr ." Stack = ".s  cr
;

: grTest2
  \ tests
  \
  \ Too high
  ." tests "
  clipxmax @ 2/ clipymin @ 1- grSetXY
  grEntirelyOnscreen . space
  ` A grCharPrint
  \ Too high
  clipxmax @ 2/ clipymax @ 1+ grSetXY
  grEntirelyOnscreen . space
  ` A grCharPrint

  \ Too left
  clipxmin @ 1- clipymax @ 2/ grSetXY
  grEntirelyOnscreen . space
  ` A grCharPrint
  \ Too right
  clipxmax @ 1+ clipymax @ 2/ grSetXY
  grEntirelyOnscreen . space
  ` A grCharPrint
  
  cr ." Stack = ".s  cr
;

grTest1


\ todo:
\   - clipping