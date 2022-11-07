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
pub CR			$0D EMIT ;
pub CRLF		CR $0A EMIT ;
--- form feed ensures compilation listing is not overwritten by FRED
pub #FF         80 0 DO CRLF LOOP ;

	( CLEARTYPE WORDS )

--- cleartype words are aliases that stand out from single Forth symbols in source code

pub PRINT	. ;
pre PRINT"	['] ." execute ;



pub EMITD ( 0...9 -- )	9 MIN $30 + EMIT ;


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
