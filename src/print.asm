INK                     EQU 0x10
PAPER                   EQU 0x11
FLASH                   EQU 0x12
BRIGHT                  EQU 0x13
INVERSE                 EQU 0x14
OVER                    EQU 0x15
AT                      EQU 0x16
TAB                     EQU 0x17
CR                      EQU 0x0C


; -----------------------------------------------------------------------------
; Nombre de la función: Get_Char_Address
; -----------------------------------------------------------------------------
; Descripción: Calcula la posición de memoria a partir de las coordenadas (Y,X) de un carácter en la cuadrícula de caracteres de la pantalla
; Registros de entrada: D, E
;   D = coordenada Y del carácter (0-23)
;   E = coordenada X del carácter (0-31)
; Registros de salida: D, E
;   DE = dirección de memoria (en memoria de pantalla)
; Registros sobreescritos: A
; Funciones requeridas: Ninguna
; Funciones relacionadas: Ninguna
; Fuente original : http://www.breakintoprogram.co.uk/hardware/computers/zx-spectrum/assembly-language/z80-tutorials/print-in-assembly-language/2
; -----------------------------------------------------------------------------
Get_Char_Address:
LD A,D          ; carga el valor del parámentro Y en el registro A
AND %00000111   ; se queda en A con el módulo 8
RRA             ; rota a la derecha con acumulador. lo hace 4 veces para pasar los 3 menos significativos a los 3 más significativos
RRA             ; la idea es cumplir el formato LLL· ····
RRA
RRA
OR E            ; lo mezcla todo con el parámetro X que venía en el registro E para llenar la parte de la columna ···C CCCC
LD E,A          ; reescribe todo lo acumulado (en el registro A) al registro E, que ya quedará para la salida en DE
LD A,D          ; copia de nuevo el parámetro Y (en el registro D) al registro A
AND %00011000   ; se queda con los dos bits más significativos de los cinco que formarán como máximo el parámetro Y
OR %01000000    ; le añade el prefijo 010 para seguir el formato 010T TSSS LLLC CCCC
LD D,A          ; el resultado lo pasa al registro D
RET             ; Devuelve la dirección del carácter (X,Y) de pantalla traducida a dirección de memoria en el registro DE