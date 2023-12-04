PROGRAM_ADDRESS             EQU 24576 ; 0x6000

org PROGRAM_ADDRESS
include "print.asm"
include "data.asm"
include "ui.asm"
Main:
ld a, $06 
out ($fe), a                    ; Pone el borde de color
; LD D, 8                        ; Y position
LD D, 2                        ; Y position
LD E, 15                         ; X position
LD HL, Mensaje
;CALL Print_String_4px          ; Print the character
LD IXL, 12
LD IXH, 20
CALL Print_String_4px_con_borde

ld d,0
ld e,10
ld b,19
ld c,18


;   D = posición vertical
;   E = posición horizontal
;   B = límite vertical
;   C = límite vertical
call Dibuja_recuadro

RET


;;; TO TO: Lo siguiente: hacer una función para hacer un cuadro de texto
;; y luego añadirle que ponga bordes 

;; DUDA: A qué funciones se les pone soporte a códigos de INK y PAPER?

end Main