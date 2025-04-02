%include 	'macros.asm'				;Incluye el archivo utilitario "macros.asm"

section .data                                           ; Segmento de Datos

	;--Filas del arreglo

	fila1			db '                          [ ] | [ ] | [ ]',10
	lenFila1	equ $ - fila1
	fila2			db '                          [ ] | [ ] | [ ]',10
	lenFila2	equ $ - fila2
	fila3			db '                          [ ] | [ ] | [ ]',10
	lenFila3	equ $ - fila3

	linea 		db '		    	  ===============', 10
	lenLinea    equ $ - linea

	;--Menu juego
	menu 		db 'Jugador 1: X',10
				db 'Jugador 2: O', 10
				db 'Coordenadas: Primero fila y luego columna',10
				db 'Tecla ESC', 10, 10
	lenGameMenu equ $ - menu

    ;--Variables de Impresion en Pantalla--

	msgMenu		db '	  Bienvenido al TicTacToe peor programado de occidente!',10,10
				db '			Elija alguna opcion:', 10
				db ' 			1. Iniciar juego', 10
				db ' 			2. Salir a terminal', 10
	lenMsgMenu	equ $ - msgMenu

	msgInput1     db 'Ingrese Fila: '
	lenMsgInput1  equ $ - msgInput1

	msgInput2     db 'Ingrese Columna: '
	lenMsgInput2  equ $ - msgInput2

	turno 		db '0'

	ganeX 		db 'Ha ganado el Jugador 1! Enhorabuena', 10
	ganeXLen equ $ - ganeX
	ganeO		db 'Ha ganado el Jugador 2! Enhorabuena', 10
	ganeOLen equ $ - ganeO

	empate		db 'Esto es un empate!', 10
	empateLen equ $ - empate

section .bss                                               ; Segmento de Datos no inicializados
	entrada 		resb 4                     ; Reserva espacio para 4 bytes
	col 			resb 4					   ; Reserva espacio para 4 bytes
	fil 			resb 4					   ; Reserva espacio para 4 bytes

section .text                                              ; Segmento de Codigo
   global _start                                           ; Inicio del Segmento de Codigo

_start:                                                    ; Punto de entrada del programa

	imprimeEnPantalla msgMenu, lenMsgMenu 
	leeTeclado
	cmp byte [entrada],'1'
	je JUEGO
	cmp byte [entrada],'2'
	je SALIR
	jne _start

JUEGO:

	;Se limpian los registros para evitar problemas
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	;Se imprime en pantalla el menú
	imprimeEnPantalla fila1, lenFila1
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila2, lenFila2
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila3, lenFila3
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla menu, lenGameMenu

	;Se recibe el input, primero las filas y luego las columnas
	imprimeEnPantalla msgInput1, lenMsgInput1
	leeTeclado
	cmp byte[entrada], 27 	;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero fil 		;Sino, se guarda el numero como numero en una variable separada

	imprimeEnPantalla msgInput2, lenMsgInput2
	leeTeclado
	cmp byte[entrada], 27 	;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero col		;Sino, se guarda el numero como numero en una variable separada

	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp JUEGO

;Los movimientos guardan la fila en ebx y luego comparan para encontrar en cual columna se va a trabajar
;Dependiendo de el numero del movimiento se tiene el numero de la fila en la que se trabaja
MOVIMIENTO1:
	mov ebx, fila1
	cmp byte[col], 0
	je ACCION1
	cmp byte[col], 1
	je ACCION2
	cmp byte[col], 2
	je ACCION3
	jmp JUEGO

MOVIMIENTO2:
	mov ebx, fila2
	cmp byte[col], 0
	je ACCION1
	cmp byte[col], 1
	je ACCION2
	cmp byte[col], 2
	je ACCION3
	jmp JUEGO

MOVIMIENTO3:
	mov ebx, fila3
	cmp byte[col], 0
	je ACCION1
	cmp byte[col], 1
	je ACCION2
	cmp byte[col], 2
	je ACCION3
	jmp JUEGO

;Una vez encontrada la posicion, se revisa si es turno de X o de O, donde 0 = X y 1 = O, el numero de la accion varia segun en la columna que se trabaja
ACCION1:
	add ebx, 27
	cmp byte[turno], '0'
	je ADDX
	jmp ADDO

ACCION2:
	add ebx, 33
	cmp byte[turno], '0'
	je ADDX
	jmp ADDO

ACCION3:
	add ebx, 39
	cmp byte[turno], '0'
	je ADDX
	jmp ADDO

;Si se va a añadir X, entonces se verifica que el espacio sea vacio y luego se realiza lo demás, que sería en si, poner la X, sumar uno al contador y cambiar el turno
ADDX:
	cmp byte[ebx], ' '
	jne JUEGO
	mov byte[ebx], 'X'
	xor byte[turno], 1
	jmp HORIZONTALX1

;Lo mismo sucede si se va a añadir O
ADDO:
	cmp byte[ebx], ' '
	jne JUEGO
	mov byte[ebx], 'O'
	xor byte[turno], 1
	jmp HORIZONTALO1

;Se verifica el gane de X, primero con todos los posibles ganes en horizontal, luego vertical y finalmente diagonal, si no se ha ganado entonces el juego continua, pero si se ganó entonces se salta a GANEX
;Para las verificaciones, lo que se hace es recorrer las filas y columnas en las distintas posiciones para ver si hay una X ahí
HORIZONTALX1:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], 'X'
	jne HORIZONTALX2

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], 'X'
	jne HORIZONTALX2

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], 'X'
	jne HORIZONTALX2
	
	jmp GANEX

HORIZONTALX2:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], 'X'
	jne HORIZONTALX3

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], 'X'
	jne HORIZONTALX3

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], 'X'
	jne HORIZONTALX3
	
	jmp GANEX

HORIZONTALX3:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], 'X'
	jne VERTICALX1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], 'X'
	jne VERTICALX1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], 'X'
	jne VERTICALX1
	
	jmp GANEX

VERTICALX1:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], 'X'
	jne VERTICALX2

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], 'X'
	jne VERTICALX2

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], 'X'
	je GANEX
	jmp VERTICALX2

VERTICALX2:
	mov ebx, fila1
	add ebx, 33
	cmp byte[ebx], 'X'
	jne VERTICALX3

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 33
	cmp byte[ebx], 'X'
	jne VERTICALX3

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 33
	cmp byte[ebx], 'X'
	je GANEX
	jmp VERTICALX3

VERTICALX3:
	mov ebx, fila1
	add ebx, 39
	cmp byte[ebx], 'X'
	jne DIAGONALX1

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 39
	cmp byte[ebx], 'X'
	jne DIAGONALX1

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 39
	cmp byte[ebx], 'X'
	je GANEX
	jmp DIAGONALX1

DIAGONALX1:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], 'X'
	jne DIAGONALX2

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 33
	cmp byte[ebx], 'X'
	jne DIAGONALX2

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 39
	cmp byte[ebx], 'X'
	jne DIAGONALX2
	jmp GANEX

DIAGONALX2:
	mov ebx, fila1
	add ebx, 39
	cmp byte[ebx], 'X'
	jne VEREMPATE

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 33
	cmp byte[ebx], 'X'
	jne VEREMPATE

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], 'X'
	jne VEREMPATE
	jmp GANEX

;Se verifica el gane de O, primero con todos los posibles ganes en horizontal, luego vertical y finalmente diagonal, si no se ha ganado entonces el juego continua, pero si se ganó entonces se salta a GANEO
;Para las verificaciones, lo que se hace es recorrer las filas y columnas en las distintas posiciones para ver si hay una O ahí
HORIZONTALO1:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], 'O'
	jne HORIZONTALO2

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], 'O'
	jne HORIZONTALO2

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], 'O'
	jne HORIZONTALO2
	
	jmp GANEO

HORIZONTALO2:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], 'O'
	jne HORIZONTALO3

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], 'O'
	jne HORIZONTALO3

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], 'O'
	jne HORIZONTALO3
	
	jmp GANEO

HORIZONTALO3:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], 'O'
	jne VERTICALO1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], 'O'
	jne VERTICALO1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], 'O'
	jne VERTICALO1
	
	jmp GANEO

VERTICALO1:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], 'O'
	jne VERTICALO2

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], 'O'
	jne VERTICALO2

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], 'O'
	je GANEO
	jmp VERTICALO2

VERTICALO2:
	mov ebx, fila1
	add ebx, 33
	cmp byte[ebx], 'O'
	jne VERTICALO3

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 33
	cmp byte[ebx], 'O'
	jne VERTICALO3

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 33
	cmp byte[ebx], 'O'
	je GANEO
	jmp VERTICALO3

VERTICALO3:
	mov ebx, fila1
	add ebx, 39
	cmp byte[ebx], 'O'
	jne DIAGONALO1

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 39
	cmp byte[ebx], 'O'
	jne DIAGONALO1

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 39
	cmp byte[ebx], 'O'
	je GANEO
	jmp DIAGONALO1

DIAGONALO1:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], 'O'
	jne DIAGONALO2

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 33
	cmp byte[ebx], 'O'
	jne DIAGONALO2

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 39
	cmp byte[ebx], 'O'
	jne DIAGONALO2
	jmp GANEO

DIAGONALO2:
	mov ebx, fila1
	add ebx, 39
	cmp byte[ebx], 'O'
	jne VEREMPATE

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 33
	cmp byte[ebx], 'O'
	jne VEREMPATE

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], 'O'
	jne VEREMPATE
	jmp GANEO

;Aqui se limpia el arreglo para reiniciar el juego, lo cual sucede al dar ESC, se pasa por todas las posiciones y se cambia el valor por vacio, que seria un espacio
LIMPIAR:
	mov ebx, fila1
	add ebx, 27
	mov byte[ebx], ' '

	add ebx, 6
	mov byte[ebx], ' '

	add ebx, 6
	mov byte[ebx], ' '

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 27
	mov byte[ebx], ' '

	add ebx, 6
	mov byte[ebx], ' '

	add ebx, 6
	mov byte[ebx], ' '

	xor ebx, ebx
	mov ebx, fila3
	add ebx, 27
	mov byte[ebx], ' '

	add ebx, 6
	mov byte[ebx], ' '

	add ebx, 6
	mov byte[ebx], ' '

	jmp _start

;Si gana X, se imprime el mensaje y se sale
GANEX:
	;Se imprime en pantalla el menú
	imprimeEnPantalla fila1, lenFila1
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila2, lenFila2
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila3, lenFila3
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla menu, lenGameMenu
	imprimeEnPantalla ganeX, ganeXLen
	jmp SALIR

;Si gana O, se imprime el mensaje y se sale
GANEO:
	;Se imprime en pantalla el menú
	imprimeEnPantalla fila1, lenFila1
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila2, lenFila2
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila3, lenFila3
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla menu, lenGameMenu
	imprimeEnPantalla ganeO, ganeOLen
	jmp SALIR

;Si todas las posiciones han sido ocupadas, entonces significa que es un empate
VEREMPATE:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], ' '
	je JUEGO

	add ebx, 6
	cmp byte[ebx], ' '
	je JUEGO

	add ebx, 6
	cmp byte[ebx], ' '
	je JUEGO

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], ' '
	je JUEGO

	add ebx, 6
	cmp byte[ebx], ' '
	je JUEGO

	add ebx, 6
	cmp byte[ebx], ' '
	je JUEGO


	xor ebx, ebx
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], ' '
	je JUEGO

	add ebx, 6
	cmp byte[ebx], ' '
	je JUEGO

	add ebx, 6
	cmp byte[ebx], ' '
	je JUEGO
	jmp EMPATE

;Si nadie gana, se imprime el mensaje y se sale
EMPATE:
	;Se imprime en pantalla el menú
	imprimeEnPantalla fila1, lenFila1
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila2, lenFila2
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila3, lenFila3
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla menu, lenGameMenu
	imprimeEnPantalla empate, empateLen
	jmp SALIR

;Si se selecciona salir en el menu inicial, entonces se hace un salto a FIN que lo que hace es directamente salir
SALIR:
	jmp FIN

FIN:	
	salir 