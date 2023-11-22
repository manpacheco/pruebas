org $6000
include "data.asm"
include "print.asm"
Main:

LD D, 5                 ; Y position
LD E, 5                ; X position
LD HL, Mensaje
CALL Print_String         ; Print the character
RET

end Main