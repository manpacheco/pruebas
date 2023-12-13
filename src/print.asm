INK                     EQU 0x10
PAPER                   EQU 0x11
FLASH                   EQU 0x12
BRIGHT                  EQU 0x13
INVERSE                 EQU 0x14
OVER                    EQU 0x15
AT                      EQU 0x16
TAB                     EQU 0x17
CR                      EQU 0x0C
SPACE                   EQU 32
LIVE_ATTRIBUTES_ADDRESS EQU 22528
CHAR_RESOLUTION_WIDTH   EQU 32

ROM_CHARSET             EQU 15360 ; 0x3C00
RAM_CHARSET             EQU PROGRAM_ADDRESS

include "fonts/carton_bold_font.asm"
include "fonts/half_width_font.asm"
CONSTANT_HALF_WIDTH_FONT EQU half_width_font-(32*8)
CONSTANT_CARTON_BOLD_FONT EQU carton_bold_font-(32*8)
Half_width_address: DW CONSTANT_HALF_WIDTH_FONT
Carton_bold_address: DW CONSTANT_CARTON_BOLD_FONT



; -----------------------------------------------------------------------------
; Nombre de la función: Get_Char_Address
; -----------------------------------------------------------------------------
; Descripción: Calcula la posición de memoria en la zona del mapa de bits a partir de las coordenadas (Y,X) de un carácter en la cuadrícula de caracteres de la pantalla
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
LD A,D                          ; carga el valor del parámentro Y en el registro A
AND %00000111                   ; se queda en A con el módulo 8
RRA                             ; rota a la derecha con acumulador. lo hace 4 veces para pasar los 3 menos significativos a los 3 más significativos
RRA                             ; la idea es cumplir el formato LLL· ····
RRA             
RRA             
OR E                            ; lo mezcla todo con el parámetro X que venía en el registro E para llenar la parte de la columna ···C CCCC
LD E,A                          ; reescribe todo lo acumulado (en el registro A) al registro E, que ya quedará para la salida en DE
LD A,D                          ; copia de nuevo el parámetro Y (en el registro D) al registro A
AND %00011000                   ; se queda con los dos bits más significativos de los cinco que formarán como máximo el parámetro Y
OR %01000000                    ; le añade el prefijo 010 para seguir el formato 010T TSSS LLLC CCCC
LD D,A                          ; el resultado lo pasa al registro D
RET                             ; Devuelve la dirección del carácter (X,Y) de pantalla traducida a dirección de memoria en el registro DE

; -----------------------------------------------------------------------------
; Nombre de la función: Get_Attribute_Address
; -----------------------------------------------------------------------------
; Descripción:  Calcula la posición de memoria en la zona de atributos a partir de las coordenadas (Y,X) de un carácter en la cuadrícula de caracteres de la pantalla
; Registros de entrada: B, E
;   B = coordenada Y del carácter (0-23)
;   E = coordenada X del carácter (0-31)
; Registros de salida: HL
; Registros sobreescritos: A,B,C,D,E,H,L
; Funciones requeridas: Ninguna
; Funciones relacionadas: Ninguna
; Fuente original : Adaptación de Serranito Online
; -----------------------------------------------------------------------------

Get_Attribute_Address: 
LD HL, LIVE_ATTRIBUTES_ADDRESS  ; Primero carga en el registro HL la dirección base de los atributos en memoria
LD D,0                          ; Pone 0 en la parte alta de DE, ya que sería inconsistente y así se evita ensuciar el resultado
ADD HL, DE                      ; Añade el offset horizontal en E a la dirección ya calculada
LD E, CHAR_RESOLUTION_WIDTH     ; Ahora se prepara para añadir offset por la posición vertical

LD A, B                         ; Carga el valor de B en A
OR A                            ; Realiza una operación OR con el registro A. Si A es 0, se establecerá el flag de cero (Z)
RET Z                           ; Retorna si el flag de cero (Z) está establecido

Get_Attribute_Address_J1:
ADD  HL, DE                     ; Añade una fila
DJNZ Get_Attribute_Address_J1   ; Mientras no hayamos procesado toda la cantidad de filas, continúa sumando 32
RET

; -----------------------------------------------------------------------------
; Nombre de la función: Print_Char
; -----------------------------------------------------------------------------
; Descripción: Esta función imprime un único carácter en la memoria de vídeo. Busca su representación en el juego de caracteres de la ROM y lo transcribe
;   a la memoria de vídeo en la posición indicada.
; Registros de entrada: A,D y E
;   A = carácter a imprimir
;   D = coordenada Y del carácter (0-23)
;   E = coordenada X del carácter (0-31)
;   HL = dirección de memoria de la fuente
; Registros de salida: Ninguno
; Registros sobreescritos: A, B, C, D, E, H, L
; Funciones requeridas: Get_Char_Address
; Funciones relacionadas: Get_Char_Address
; Fuente original : : http://www.breakintoprogram.co.uk/hardware/computers/zx-spectrum/assembly-language/z80-tutorials/print-in-assembly-language/2
; -----------------------------------------------------------------------------
Print_Char:             
LD B,0                          ; BC es el código del caracter, la parte alta siempre será 0
LD C, A                         ; Se copia a C el caracter de entrada
SLA C                           ; Se multiplica por 2 haciendo shift a la izquierda y llevando a carry el bit más significativo
RL B                            ; Se propaga la multiplicación anterior a la parte alta del valor de 16 bits
SLA C                           ; segunda multiplicación por 2 (x4 acumulado)
RL B        
SLA C                           ; tercera multiplicación por 2 (x8 acumulado)
RL B                            
ADD HL, BC                      ; Suma a la dirección de referencia el resultado anterior
CALL Get_Char_Address           ; Obtiene la dirección de memoria destino para escribir en la zona de la memoria de vídeo con el mismo D y el E iniciales
LD B,8                          ; Carga 8 por el número de iteraciones
Print_Char_L1:
LD A,(HL)                       ; Copia en el registro A el valor de la dirección de memoria apuntada por HL (que debería ser del juego de caracteres)
LD (DE),A                       ; Guarda en la memoria apuntada por DE (que estará en memoria de vídeo) el valor del registro A
INC HL                          ; Pasa a la siguiente línea del carácter
INC D                           ; Pasa a la siguiente línea del caracter en memoria de vídeo, que no estará en la posición de memoria adyacente
DJNZ Print_Char_L1              ; Seguir en el bucle mientras B no sea 0 (NZ)
RET
 
; -----------------------------------------------------------------------------
; Nombre de la función: Print_Char_Derecho
; -----------------------------------------------------------------------------
; Descripción: Esta función imprime un único carácter de 4 píxeles de ancho en la memoria de vídeo. Busca su representación en el juego de caracteres adecuado
; en RAM y lo transcribe a la memoria de vídeo en la posición indicada en la mitad izquierda. 
; Registros de entrada: A,D y E
;   A = carácter a imprimir
;   D = coordenada Y del carácter (0-23)
;   E = coordenada X del carácter (0-31)
; Registros de salida: Ninguno
; Registros sobreescritos: A, B, C, D, E, H, L
; Funciones requeridas: Get_Char_Address
; Funciones relacionadas: Get_Char_Address, Print_Char
; Fuente original : Adaptación de Serranito Online
; Observaciones : Basado en Print_Char
; -----------------------------------------------------------------------------
Print_Char_Derecho:             
LD HL, (Half_width_address)     ; Se carga en HL la dirección del juego de caracteres de la ROM
LD B,0                          ; BC es el código del caracter, la parte alta siempre será 0
LD C, A                         ; Se copia a C el caracter de entrada
SLA C                           ; Se multiplica por 2 haciendo shift a la izquierda y llevando a carry el bit más significativo
RL B                            ; Se propaga la multiplicación anterior a la parte alta del valor de 16 bits
SLA C                           ; segunda multiplicación por 2 (x4 acumulado)
RL B        
SLA C                           ; tercera multiplicación por 2 (x8 acumulado)
RL B                            
ADD HL, BC                      ; Suma a la dirección de referencia el resultado anterior
CALL Get_Char_Address           ; Obtiene la dirección de memoria destino para escribir en la zona de la memoria de vídeo con el mismo D y el E iniciales
LD B,8                          ; Carga 8 por el número de iteraciones
Print_Char_Derecho_L1:      
LD A,(DE)                       ; Copia en A lo que había en pantalla
AND %11110000                   ; Deja solamente la parte de la izquierda
LD C,A                          ; Almacena ese resultado parcial en el registro C
LD A,(HL)                       ; Carga en el registro A el valor de la dirección de memoria apuntada por HL (que debería ser del juego de caracteres)
AND %00001111                   ; Deja solamente la parte derecha del carácter
OR C                            ; Mezcla el resultado parcial anterior con la parte nueva del caracter que solo tendrá parte derecha
LD (DE),A                       ; Guarda en la memoria apuntada por DE (que estará en memoria de vídeo) el valor del registro A con el carácter compuesto ya construido
INC HL                          ; Pasa a la siguiente línea del carácter
INC D                           ; Pasa a la siguiente línea del caracter en memoria de vídeo, que no estará en la posición de memoria adyacente
DJNZ Print_Char_Derecho_L1      ; Seguir en el bucle mientras B no sea 0 (NZ)
RET


; -----------------------------------------------------------------------------
; Nombre de la función: Print_String
; -----------------------------------------------------------------------------
; Descripción: Esta función imprime una cadena de caracteres en la pantalla. Ignora los caracteres de control (códigos ASCII menores a 32) 
;   y termina cuando encuentra un carácter nulo (0).
; Registros de entrada: D,E,H,L
;   D = coordenada Y del carácter donde se imprimira la cadena (0-23)
;   E = coordenada X del carácter donde se imprimira la cadena (0-31)
;   HL = apunta a la cadena a imprimir
; Registros de salida: Ninguno
; Registros sobreescritos: A, E, HL
; Funciones requeridas: Print_Char
; Funciones relacionadas: Get_Char_Address, Print_Char
; Fuente original : : http://www.breakintoprogram.co.uk/hardware/computers/zx-spectrum/assembly-language/z80-tutorials/print-in-assembly-language/2
; -----------------------------------------------------------------------------
Print_String:           
LD A, (HL)                      ; Carga el primer caracter de la cadena apuntada por HL en el registro A
CP 0                            ; compara con 0
RET Z                           ; Si es 0 sale de la funcíon
INC HL                          ; Incrementa el registro índice de la cadena
CP SPACE                        ; Compara con el espacio (32)
JR C, Print_String              ; Si es anterior al 32, es un carácter de control (no se imprimirá nada)
PUSH DE                         ; Preserva DE en la pila
PUSH HL                         ; Preserva HL en la pila
LD HL, (Carton_bold_address)    ; Se carga en HL la dirección del juego de caracteres de la ROM
CALL Print_Char                 ; Llama a la rutina que imprime un caracter
POP HL                          ; Restaura HL que contiene el índice a la cadena
POP DE                          ; Restaura las coordenadas para imprimir la cadena
INC E                           ; Incrementa el registro E que tiene la coordenada horizontal 
JR Print_String                 ; Salta al principio en bucle

; -----------------------------------------------------------------------------
; Nombre de la función: Print_String_4px
; -----------------------------------------------------------------------------
; Descripción: Imprime una cadena de caracteres de ancho 4 pixeles en ZX Spectrum.
; Registros de entrada:
;   HL= apunta a la cadena a imprimir
;   D = coordenada Y del carácter donde se imprimira la cadena (0-23)
;   E = coordenada X del carácter donde se imprimira la cadena (0-31)
; Registros de salida: Ninguno
; Registros sobreescritos: AF, DE, HL, IX, IY
; Funciones requeridas: Print_String_4px_con_borde
; Funciones relacionadas: Print_String
; Fuente original : Adaptación de Serranito online basada en Print_String y en código de Dave Hughes
; -----------------------------------------------------------------------------

; ld a,0
; Print_String_4px:
; ld IXL,21
; ld IXH,29
; call Print_String_4px_con_borde
; ret

; -----------------------------------------------------------------------------
; Nombre de la función: Print_String_4px_con_borde
; -----------------------------------------------------------------------------
; Descripción: Imprime una cadena de caracteres de ancho 4 pixeles en ZX Spectrum.
; Registros de entrada:
;   HL= apunta a la cadena a imprimir
;   D = coordenada Y del carácter donde se imprimira la cadena (0-23)
;   E = coordenada X del carácter donde se imprimira la cadena (0-31)
;   IXL = límite inferior en la coordenada X
;   IXH = límite máximo en la coordenada X
; Registros de salida: Ninguno
; Registros sobreescritos: AF, DE, HL
; Funciones requeridas: Print_Char, Print_Char_Derecho
; Funciones relacionadas: Print_String
; Fuente original : Adaptación de Serranito online basada en Print_String y en código de Dave Hughes
; ------------------------------        -----------------------------------------------
Print_String_4px_con_borde:                   
LD A, (HL)                              ; Carga el primer caracter de la cadena apuntada por HL en el registro A
CP 0                                    ; compara con 0
RET Z                                   ; Si es 0 sale de la funcíon
INC HL                                  ; Incrementa el registro índice de la cadena
CP SPACE                                ; Compara con el espacio (32)
JR C, Print_String_4px_con_borde        ; Si es anterior al 32, es un carácter de control (no se imprimirá nada)
PUSH DE                                 ; Preserva DE en la pila
PUSH HL                                 ; Preserva HL en la pila
LD HL, (Half_width_address)             ; Se carga en HL la dirección del juego de caracteres de la ROM
CALL Print_Char                         ; Llama a la rutina que imprime un caracter
POP HL                                  ; Restaura HL que contiene el índice a la cadena
POP DE                                  ; Restaura las coordenadas para imprimir la cadena

LD A, (HL)                              ; Carga el siguiente caracter de la cadena apuntada por HL en el registro A
PUSH AF                                 ; Preserva AF en la pila
CP 0                                    ; Nos ha pillado el fin de cadena en mitad de la impresión?
JR Z, Print_String_4px_J1               ; Si es así, ejecuta lo que hay dentro del salto J1

CP SPACE                                ; Compara con el espacio (32)
JR C, Print_String_4px_con_borde        ; Si es anterior al 32, es un carácter de control (no se imprimirá nada)
JR Print_String_4px_J2                  ; En las ejecuciones normales va al salto J2

Print_String_4px_J1:        
LD A, SPACE                             ; Si hace falta imprime como despedida un espacio en blanco
Print_String_4px_J2:        
PUSH DE                                 ; Preserva DE en la pila
PUSH HL                                 ; Preserva HL en la pila
CALL Print_Char_Derecho             
POP HL                                  ; Restaura HL que contiene el índice a la cadena
POP DE                                  ; Restaura las coordenadas para imprimir la cadena
POP AF                                  ; Restaura AF con el caracter que se tenía que imprimir
CP 0                                    ; Si el caracter era 0
RET Z                                   ; Se sale de la función


LD A, E                                 ; Copia la coordenada X al registro A para hacer comparación
CP IXH                                  ; Compara la coordenada X actual con el límite máximo
JR NZ, Print_String_4px_J4              ; Si no se ha llegado, sigue igual
LD E, IXL                               ; En caso de que estemos justo en el límite, incrementa hace algo como un retorno de carro
DEC E                                   ; Le resta uno para compensar el INC que va después
INC D                                   ; Salta a la siguiente fila

PUSH HL                                 ; Pasa HL a la pila para cargarlo en IY
POP IY                                  ; Recupera IY de la pila con lo que se subió (que es HL)
LD A, (IY+1)                            ; Mira lo que viene después de la posición actual
CP SPACE                                ; Compara con el espacio a ve si es
JR NZ, Print_String_4px_J4              ; Si no es el espacio, salta y no hagas el ajuste

INC HL                                  ; el ajuste es que salta el siguiente carácter para ignorar el espacio
Print_String_4px_J4:        
INC E                                   ; Incrementa el registro E que tiene la coordenada horizontal 
INC HL                                  ; Incrementa el registro índice de la cadena
JR Print_String_4px_con_borde           ; Salta al principio en bucle
