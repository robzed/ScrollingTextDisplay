( mecrisp emulation )

\ Makes an initialized single variable. i.e. “0 variable one-kb”
: variable  	( u|n - - )  CREATE  , ;

\ Invert all bits - same as mecrisp Forth
: not 	( x1 -- x2 ) invert ;

\ Logical left-rotation of one bit-place ( x1 -- x2 )
: ROL ( x1 -- x2 ) dup $80000000 and swap  1 lshift $FFFFFFFF and swap IF 1 or THEN ;

