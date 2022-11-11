\ Based on Tachyon Extension by Peter Jakacki 2021
\ MIT license


\ Some basic words from  Tachyon layer for mecrisp

\ pre-emptive colon definiton (an immediate)
: pre		['] : execute ['] IMMEDIATE execute ;
\ public colon definition (normal)
pre pub 	['] : execute ;
\ private colon definition (can be hidden later)
pre pri 	['] : execute ;
\ use --- as a clear separator and comment (also same as Tachyon cr response: 12 . --- 12)
pre ---		['] \ execute ;

pre } 	;
pub BOUNDS			OVER + SWAP ;
pub >>				rshift ;
pub <<				lshift ;

--- compile or stack literal value
pri LIT				state C@ IF POSTPONE literal THEN ;
: token parse-name ;
pri ASCLIT ( mask -- )		0 token BOUNDS DO 8 << OVER I C@ AND + LOOP NIP LIT  ;
--- use instead of awkward [CHAR] and CHAR
pre `				$FF ASCLIT ;
--- control char literal
pre ^				$1F ASCLIT ;


--- Tachyon standard CR is CR only whereas CRLF is CR+LF combo
\ pub CR			$0D EMIT ;
\ pub CRLF		CR $0A EMIT ;
pub CRLF CR ;
--- form feed ensures compilation listing is not overwritten by FRED
pub #FF         80 0 DO CRLF LOOP ;

	( CLEARTYPE WORDS )

--- cleartype words are aliases that stand out from single Forth symbols in source code

pub PRINT	. ;
pre PRINT"	['] ." execute ;



pub EMITD ( 0...9 -- )	9 MIN $30 + EMIT ;

pub ~				0 SWAP ! ;

( 		*** ANSI *** 		)

7 variable ~pen
0 variable ~paper
pub PEN@	~pen @ ;
pub PAPER@	~paper @ ;


--- ANSI COLORS
0	constant black
1	constant red
2	constant green
3	constant yellow
4	constant blue
5	constant magenta
6	constant cyan
7	constant white


pub ESC ( ch -- )		$1B EMIT EMIT ;
--- ESC [
pub ESC[			` [ ESC ;
--- ESC [ ch
pri CSI ( ch -- )		ESC[ EMIT ;
pub HOME			` H CSI ;

pri COL ( col fg/bg -- )	CSI ` 0 + EMIT ` m EMIT ;
\ pri COL ( col fg/bg -- )	CSI 0 <# #S #> TYPE ` m EMIT ;
pub PEN! ( col -- )		dup ~pen ! 7 AND ` 3 COL ; --- 1B 5B 33 m
pub PEN ( col -- )		DUP ~pen C@ <> IF PEN! ELSE DROP THEN ;

pub PAPER! ( col -- )		dup ~paper ! ` 4 COL ;
pub PAPER ( col -- )		DUP ~paper C@ <> IF PAPER! ELSE DROP THEN ;


pri .PAR ( n ch -- )		SWAP 0 <# #S #> TYPE EMIT ;
pri CUR ( cmd n -- )	    	ESC[ SWAP .PAR ;
pub XY ( x y -- )		` ; SWAP CUR ` H .PAR ;

\ : .PX  ESC[ ." 38;5;" ` m .PAR ;

--- Erase the screen from the current location
pub ERSCN			` 2 CSI ` J EMIT ;
--- Erase the current line
pub ERLINE			` 2 CSI ` K EMIT ;
pub CLS 			ERSCN HOME ; \ $0C EMIT ;

pri asw				IF ` h ELSE ` l THEN EMIT ;
pub CURSOR ( on/off -- )	` ? CSI ." 25" asw ;

--- 0 plain 1 bold 2 dim 3 rev 4 uline
pri ATR ( ch -- )		CSI ` m EMIT ;
\ pub PLAIN			` 0 ATR white ~pen ! ~paper ~ ;
pub PLAIN			white ~pen ! ~paper ~ ` 0 ATR ;

pub REVERSE			` 7 ATR ;
pub BOLD			` 1 ATR ;
pub UL				` 4 ATR ;
pub BLINK			` 5 ATR ;

pub WRAP ( on/off -- )		` ? CSI ` 7 EMIT asw ;

\ pub MARGINS ( top bottom -- )	ESC[ SWAP ` : .PAR ` r .PAR ;

\ E2 96 88
pub UTF8 ( code -- )        	$E2 EMIT DUP 6 >> $80 + EMIT $3F AND $80 + EMIT  ;
pub EMOJI ( ch -- )		$F0 EMIT $9F EMIT DUP 6 >> $98 + EMIT $3F AND $80 + EMIT ;



	( *** PRINT HEX & BINARY *** )

pub .HEX ( n cnt -- ) HEX  <# 0 DO # LOOP #> TYPE DECIMAL ;
pub .B		0 2 .HEX ;
pub .H		0 4 .HEX ;
pub .L	   	0 8 .HEX ;
pub .BINX
    32 OVER - ROT SWAP <<  SWAP 0
    DO I IF I 3 AND 0= IF $5F EMIT THEN  THEN ROL DUP 1 AND EMITD LOOP
    DROP ;
pub .BIN	32 .BINX ;
pub .BIN8	8 .BINX ;
pub .BYTE	` $ EMIT .B ;
