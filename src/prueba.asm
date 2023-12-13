PROGRAM_ADDRESS             EQU 24576 ; 0x6000


include "fonts/udg.asm"
org PROGRAM_ADDRESS
include "print.asm"
include "data.asm"
include "ui.asm"

Main:
ld a, $06 
out ($fe), a                    ; Pone el borde de color


ld d,1
ld e,11
ld b,18
ld c,17


;   D = posición vertical
;   E = posición horizontal
;   B = límite vertical
;   C = límite vertical
push de
push bc
call Dibuja_recuadro
pop bc
pop de
dec D
dec e
inc b
inc c
call Dibuja_marco

LD D, 2                        ; Y position
LD E, 15                         ; X position
LD HL, Mensaje
;CALL Print_String_4px          ; Print the character
LD IXL, 12
LD IXH, 20
CALL Print_String_4px_con_borde



RET

;; DUDA: A qué funciones se les pone soporte a códigos de INK y PAPER?

end Main
