
; -----------------------------------------------------------------------------
; Nombre de la función: Dibuja_recuadro
; -----------------------------------------------------------------------------
; Descripción: Esta función dibuja un recuadro en la pantalla. El recuadro se dibuja con espacios en blanco.
; Registros de entrada: BC, DE
;   D = posición vertical
;   E = posición horizontal
;   B = límite vertical
;   C = límite horizontal
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
LD A,SPACE                          ; Carga en A el carácter de relleno, en este caso el espacio
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
LD (HL), 7                        ; Le asigna el atributo a esa coordenada

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


; -----------------------------------------------------------------------------
; Nombre de la función: Dibuja_seccion_marco
; -----------------------------------------------------------------------------
; Descripción: Esta función dibuja el marco de un recuadro
; Registros de entrada: A, BC, DE
;   A = carácter a imprimir
;   D = posición vertical
;   E = posición horizontal
;   B = límite vertical
;   C = límite horizontal
; Registros de salida: Ninguno
; Registros sobreescritos: DE, BC, A, HL, IXH, IY
; Funciones requeridas: Print_Char
; Funciones relacionadas: Print_Char
; Fuente original : Adaptación de Serranito Online
; -----------------------------------------------------------------------------
Dibuja_seccion_marco:
PUSH DE                             ; Sube DE a la pila
POP IY                              ; Pasa DE que estaba en la pila a IY

LD IXH, A                           ; Preserva el carácter que hay que imprimir en el registro IXH
Dibuja_seccion_marco_J1:
LD A, IXH                           ; Mete el carácter que hay que imprimir en el registro A
LD HL, udg_address                  ; Carga en HL la dirección de la fuente
PUSH DE                             ; Preserva DE
PUSH BC                             ; Preserva BC
CALL Print_Char                     ; Imprimir el carácter
POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

INC E                               ; Incrementa la posición horizontal en E

LD A, E                             ; Carga la posición horizontal en A
CP C                                ; Compara la posición horizontal con el límite máximo horizontal

JR NZ, Dibuja_seccion_marco_J1      ; Si no se ha llegado todavía, salta a la siguiente iteración interna
INC D                               ; Si hemos llegado al límite horizontal, entonces incrementa la posición vertical
LD E,IYL                            ; Restaura el indicador de posición horizontal al valor inicial que estaba guardado en IYL

LD A, D                             ; Carga la posición vertical en A 
CP B                                ; Compara la posición vertical con el límite máximo vertical
JR NZ, Dibuja_seccion_marco_J1      ; Si no se ha llegado todavía, salta a la siguiente iteración más externa

RET                                 ; Si ya se ha llegado, entonces se hace que la función retorne

; -----------------------------------------------------------------------------
; Nombre de la función: Dibuja_marco
; -----------------------------------------------------------------------------
; Descripción: Esta función dibuja el marco de un recuadro
; Registros de entrada: BC, DE
;   D = posición vertical
;   E = posición horizontal
;   B = límite vertical
;   C = límite horizontal
; Registros de salida: Ninguno
; Registros sobreescritos: AF, DE, BC, HL, IX, IY
; Funciones requeridas: Dibuja_seccion_marco
; Funciones relacionadas: Print_Char
; Fuente original : Adaptación de Serranito Online
; -----------------------------------------------------------------------------
Dibuja_marco:
; PARTE SUPERIOR
PUSH DE                             ; Preserva DE en pila
PUSH BC                             ; Preserva BC en pila

LD A, BORDE_SUPERIOR                ; Prepara para imprimir el borde superior
LD B, D                             ; Carga la posición vertical en D que sera la primera posición
INC B                               ; Incrementa para que la posición y el tope tengan al menos 1 unidad de diferencia
CALL Dibuja_seccion_marco           ; Usa la función de dibujar el marco

POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

; PARTE INFERIOR
PUSH DE                             ; Preserva DE en pila
PUSH BC                             ; Preserva BC en pila

LD A, BORDE_INFERIOR                ; Prepara para imprimir el borde inferior
LD D, B                             ; Carga como posición vertical el tope vertical
DEC D                               ; Decrementa para que la posición y el tope tengan al menos 1 unidad de diferencia
CALL Dibuja_seccion_marco           ; Usa la función de dibujar el marco

POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

; PARTE IZQUIERDA
PUSH DE                             ; Preserva DE en pila
PUSH BC                             ; Preserva BC en pila

LD A, BORDE_IZQ                     ; Prepara para imprimir el borde izquierdo
LD C, E                             ; Carga la posición horizontal en C que sera la primera posición
INC C                               ; Incrementa para que la posición y el tope tengan al menos 1 unidad de diferencia
CALL Dibuja_seccion_marco           ; Usa la función de dibujar el marco

POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

; PARTE DERECHA
PUSH DE                             ; Preserva DE en pila
PUSH BC                             ; Preserva BC en pila

LD A, BORDE_DER                     ; Prepara para imprimir el borde derecho
LD E, C                             ; Carga como posición horizontal el tope horizontal
DEC E                               ; Decrementa para que la posición y el tope tengan al menos 1 unidad de diferencia
CALL Dibuja_seccion_marco           ; Usa la función de dibujar el marco

POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

; DIBUJA ESQUINAS

LD HL, udg_address                  ; En HL estará la dirección de los UDG
LD A, ESQUINA_SUPERIOR_IZQ          ; Prepara para imprimir la esquina superior izquierda
PUSH DE                             ; Preserva DE en pila
PUSH BC                             ; Preserva BC en pila
CALL Print_Char                     ; Se imprime el caracter
POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

LD HL, udg_address                  ; No aseguramos de que en HL estará la dirección de los UDG
LD A, ESQUINA_SUPERIOR_DER          ; Prepara para imprimir la esquina superior derecha
PUSH DE                             ; Preserva DE en pila
PUSH BC                             ; Preserva BC en pila
LD E,C                              ; Carga como posición horizontal el tope horizontal
DEC E                               ; Decrementa para que la posición y el tope tengan al menos 1 unidad de diferencia
CALL Print_Char                     ; Se imprime el caracter
POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

LD HL, udg_address                  ; No aseguramos de que en HL estará la dirección de los UDG
LD A, ESQUINA_INFERIOR_IZQ          ; Prepara para imprimir la esquina inferior izquierda
PUSH DE                             ; Preserva DE en pila
PUSH BC                             ; Preserva BC en pila
LD D,B                              ; Carga como posición vertical el tope vertical
DEC D                               ; Decrementa para que la posición y el tope tengan al menos 1 unidad de diferencia
CALL Print_Char                     ; Se imprime el caracter
POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

LD HL, udg_address                  ; No aseguramos de que en HL estará la dirección de los UDG
LD A, ESQUINA_INFERIOR_DER          ; Prepara para imprimir la esquina inferior derecha
PUSH DE                             ; Preserva DE en pila
PUSH BC                             ; Preserva BC en pila
PUSH BC                             ; Mete BC en pila de nuevo para pasarlo después a DE
POP DE                              ; Se ha sobreescrito DE con lo que había en BC
DEC D                               ; Decrementa para que la posición y el tope tengan al menos 1 unidad de diferencia
DEC E                               ; Decrementa para que la posición y el tope tengan al menos 1 unidad de diferencia
CALL Print_Char
;   D = coordenada Y del carácter (0-23)
;   E = coordenada X del carácter (0-31)
;   HL = dirección de memoria de la fuente
POP BC                              ; Restaura BC
POP DE                              ; Restaura DE

RET
