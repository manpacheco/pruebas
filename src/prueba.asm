PROGRAM_ADDRESS             EQU 24576 ; 0x6000

org PROGRAM_ADDRESS
include "print.asm"
include "data.asm"
Main:
ld a, $06 
out ($fe), a            ; Pone el borde de color
LD D, 5                 ; Y position
LD E, 5                 ; X position
LD HL, Mensaje
;CALL Print_String       ; Print the character
LD D, 7                 ; Y position
LD E, 26                ; X position
LD HL, Mensaje
;CALL Print_String_4px         ; Print the character
LD IX, 0x1C00
CALL Print_String_4px_con_borde
RET

end Main