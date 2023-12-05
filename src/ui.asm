
; -----------------------------------------------------------------------------
; Nombre de la función: Dibuja_recuadro
; -----------------------------------------------------------------------------
; Descripción: Esta función dibuja un recuadro en la pantalla. El recuadro se dibuja con espacios en blanco.
; Registros de entrada: DE
;   D = posición vertical
;   E = posición horizontal
;   B = límite vertical
;   C = límite vertical
; Registros de salida: Ninguno
; Registros sobreescritos: DE, BC, A, HL, IY
; Funciones requeridas: Print_Char
; Funciones relacionadas: Print_Char
; Fuente original : Adaptación de Serranito Online
; -----------------------------------------------------------------------------
Dibuja_recuadro:
PUSH DE                             ; Sube DE a la pila
POP IY                              ; Pasa DE que estaba en la pila a IY


Dibuja_recuadro_J1:
LD A,33                             ; Carga en A el carácter de relleno, en este caso el espacio
LD HL, (Carton_bold_address)        ; Carga en HL la dirección de la fuente
PUSH DE                             ; Preserva DE
PUSH BC                             ; Preserva BC
CALL Print_Char                     ; Imprimir el carácter
POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

;   B = coordenada Y del carácter (0-23)
;   E = coordenada X del carácter (0-31)
PUSH BC                             ; Se preserva BC
PUSH DE                             ; Se preserva DE
LD B, D                             ; Carga en B la coordenada Y
CALL Get_Attribute_Address          ; Calcula la posición de memoria del atributo a modificar. La coordenada X ya va en el registro E
POP DE                              ; Restaura el registro DE
POP BC                              ; Restaura el registro BC
LD (HL), 7                          ; Le asigna el atributo a esa coordenada

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TO DO: Documentar y revisar documentación anterior
;;;; TO DO: Añadir marco del recuadro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INC E                               ; Incrementa la posición horizontal en E
LD A, E                             ; Carga la posición horizontal en A
CP C                                ; Compara la posición horizontal con el límite máximo horizontal
JR NZ, Dibuja_recuadro_J1           ; Si no se ha llegado todavía, salta a la siguiente iteración interna
INC D                               ; Si hemos llegado al límite horizontal, entonces incrementa la posición vertical
LD E,IYL                            ; Restaura el indicador de posición horizontal al valor inicial que estaba guardado en IYL
LD A, D                             ; Carga la posición vertical en A 
CP B                                ; Compara la posición vertical con el límite máximo vertical
JR NZ, Dibuja_recuadro_J1           ; Si no se ha llegado todavía, salta a la siguiente iteración más externa
RET                                 ; Si ya se ha llegado, entonces se hace que la función retorne


