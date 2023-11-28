PROGRAM_ADDRESS             EQU 24576 ; 0x6000

org PROGRAM_ADDRESS
include "print.asm"
include "data.asm"
Main:

LD D, 5                 ; Y position
LD E, 5                ; X position
LD HL, Mensaje
CALL Print_String         ; Print the character
LD D, 7                 ; Y position
LD E, 26                ; X position
LD HL, Mensaje
CALL Print_String_4px         ; Print the character
RET

end Main