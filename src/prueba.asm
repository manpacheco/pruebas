PROGRAM_ADDRESS             EQU 24576 ; 0x6000

org PROGRAM_ADDRESS
include "print.asm"
include "data.asm"
Main:

LD D, 5                 ; Y position
LD E, 5                ; X position
LD HL, Mensaje
CALL Print_String         ; Print the character
RET

end Main