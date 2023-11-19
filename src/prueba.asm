org $6000
include "data.asm"
include "print.asm"
Main:
LD A, 33                ; Character to print
LD D, 1                 ; Y position
LD E, 15                ; X position
CALL Print_Char         ; Print the character
RET

;
; Print a single character out to a screen address
;  A: Character to print
;  D: Character Y position
;  E: Character X position
; 
Print_Char:             LD HL, 0x3C00           ; Character set bitmap data in ROM 0x3C00 = 15360
                        LD B,0                  ; BC = character code
                        LD C, A
                        SLA C                   ; Multiply by 8 by shifting
                        RL B
                        SLA C
                        RL B
                        SLA C
                        RL B
                        ADD HL, BC              ; And add to HL to get first byte of character
                        CALL Get_Char_Address   ; Get screen position in DE
                        LD B,8                  ; Loop counter - 8 bytes per character
Print_Char_L1:          LD A,(HL)               ; Get the byte from the ROM into A
                        LD (DE),A               ; Stick A onto the screen
                        INC HL                  ; Goto next byte of character
                        INC D                   ; Goto next line on screen
                        DJNZ Print_Char_L1      ; Loop around whilst it is Not Zero (NZ)
                        RET
 




LD D, 3
                        LD E, 2
                        LD HL, TEXT2
                        CALL Print_String
                        RET
;
; Text for my print routine that uses zero-terminated strings 
;
TEXT2:                  DB AT, 12, 2, INK, 1, PAPER, 6, BRIGHT, 1, "Hello World!", 0
 
;
; My print routine
; HL: Address of the string
;  D: Character Y position
;  E: Character X position
;
Print_String:           LD A, (HL)              ; Get the character
                        CP 0                    ; CP with 0
                        RET Z                   ; Ret if it is zero
                        INC HL                  ; Skip to next character in string
                        CP 32                   ; CP with 32 (space character)
                        JR C, Print_String      ; If < 32, then don't ouput
                        PUSH DE                 ; Save screen coordinates
                        PUSH HL                 ; And pointer to text string
                        CALL Print_Char         ; Print the character
                        POP HL                  ; Pop pointer to text string
                        POP DE                  ; Pop screen coordinates
                        INC E                   ; Inc to the next character position on screen
                        JR Print_String         ; Loop




end Main