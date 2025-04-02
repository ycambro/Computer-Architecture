	%include 	'macros.asm'				;Incluye el archivo utilitario "macros.asm"

section .data                                           ; Segmento de Datos
	;--Tiempo
	tiempoTotal     dd      120	
        sys_write       EQU     4
        stdout          EQU     1

	;--Filas del arreglo

	fila1		db '                          [ ] | [ ] | [ ]',10
	lenFila1	equ $ - fila1
	
	fila2		db '                          [ ] | [ ] | [ ]',10
	lenFila2	equ $ - fila2
	
	fila3		db '                          [ ] | [ ] | [ ]',10
	lenFila3	equ $ - fila3
	
	linea 		db '		    	  ===============', 10
	lenLinea    equ $ - linea

	;--Menu juego
	coord 		db 'Coordenadas: Primero fila, luego columna y finalmente número', 10
	lenCoordMenu equ $ - coord
	
	time 		db 'Tiempo restante:'
	lenTimeMenu equ $ - time
	
	esc		db 'Salir ESC',10,10
	lenEscMenu equ $ - esc

	;--Variables de impresión de mensajes
	info 		db 'Mensaje: Indica la posicion y el numero!',10
	lenInfoMenu equ $ - info
	
	info1 		db 'Mensaje: Este número ya se ha colocado!',10
	lenInfo1Menu equ $ - info1
	
	info2 		db 'Mensaje: Coordenada inválida!',10
	lenInfo2Menu equ $ - info2
	
	info4 		db 'Mensaje: Se acabó el tiempo!',10
	lenInfo4Menu equ $ - info4
	
	info5		db 'Mensaje: La posición seleccionada está ocupada!', 10
	lenInfo5Menu equ $ - info5
	
    ;--Variables de Impresion en Pantalla--

	msgMenu		db '	  Bienvenido al Sudoku peor programado de occidente!',10,10
			db '			Elija alguna opcion:', 10
			db ' 			1. Iniciar juego', 10
			db ' 			2. Salir a terminal', 10
	lenMsgMenu	equ $ - msgMenu

	numInput      	db 'Ingrese el número: '
	lenNumInput   equ $ - numInput

	msgInput1     	db 'Ingrese Fila: '
	lenMsgInput1  equ $ - msgInput1

	msgInput2     	db 'Ingrese Columna: '
	lenMsgInput2  equ $ - msgInput2

	turno 		db '0'

	ganeX 		db 'Mensaje: Has ganado! Enhorabuena', 10
	ganeXLen equ $ - ganeX
	
	tiempo		db ' 120s',10
	lenTiempo equ $ - tiempo
	
	derrota 	db 'Mensaje: La sumatoria de todos los números no es 15 en las verticales, diagonales y horizontales! Has perdido...',10
	derrotaLen equ $ - derrota
	
section .bss                                               	;Segmento de Datos no inicializados
	entrada 	resb 4                     		;Reserva espacio para 4 bytes
	col 		resb 4					;Reserva espacio para 4 bytes
	fil 		resb 4					;Reserva espacio para 4 bytes
	num		resb 4					;Reserva espacio para 4 bytes
	
	tiempo1 	resd 1                 			;Variable para primer tiempo
	tiempo2		resd 1					;Variable para segundo tiempo
	aleatorio 	resb 1    				;Variable para num aleatorio

section .text                                              	;Segmento de Codigo
   global _start                                           	;Inicio del Segmento de Codigo

_start:                                                    	;Punto de entrada del programa

	imprimeEnPantalla msgMenu, lenMsgMenu
	leeTeclado
	cmp byte [entrada],'1'
	je TIEMPO_INICIAL
	cmp byte [entrada],'2'
	je SALIR
	jne _start
	
;Funcion para obtener el tiempo al empezar la partida
TIEMPO_INICIAL:
	mov  eax, 13       					;Se obtiene el tiempo EPOCH 
	xor rbx,rbx
	int  0x80

	mov dword [tiempo1],eax					;Almacena el tiempo en una var
	jmp RANDOM 						
	
;Esta funcion agarra los tiempos y los compara para verificar si se ha llegado a 0, de ser asi el tiempo ha acabado, dependiendo del numero se salta a un menu distinto (lo que varia es el mensaje).

TIEMPO_ACTUAL:
	xor rcx,rcx						; Limpia registro ecx
	xor rdx,rdx						; Limpia registro edx
	xor rax,rax						; Limpia registro eax

	mov  eax, 13						;Se obtiene tiempo EPOCH
	xor rbx,rbx
        int  0x80


	mov dword [tiempo2],eax					;Almacena tiempo en var2

        xor rcx,rcx                                             ; Limpia registro ecx
        xor rdx,rdx                                             ; Limpia registro edx
        xor rax,rax                                             ; Limpia registro eax

	mov ebx,dword [tiempo1]					;Se asigna ebx = tiempo1	
	mov eax,dword [tiempo2]					;Se asigna eax = tiempo2
	mov cl,byte [tiempoTotal]				;Se asigna cl = 120
	sub eax,ebx						;Obtiene delta en seg (t1-t2)
	sub ecx,eax						;Resta 120 - (tiempo2-tiempo1)
	cmp ecx, 0
	jle VERGANET						;Si es 0 o menor se acabo
	
	mov eax, ecx						
	mov ebx, tiempo
	
	;Se va al final de la variable para recorrerla al revés
	ultimo:
		inc ebx
		cmp byte[ebx], 's'
		jne ultimo
		dec ebx 					;Esto es para volver al num
	
	;Si el numero es mayor a 9, se divide entre 10, y el residuo seria el numero en la 
	;posicion actual, entonces se asigna el valor en la var tiempo
	tiempo_imprimible:
		cmp eax, 9
		jle fin_imprimible
		
		mov ecx, 10
		mov edx, 0
		div ecx
		add edx, '0'
		mov byte[ebx], dl
		dec ebx
		jmp tiempo_imprimible
	
	;Si el numero es 9 o menor, entonces se asigna el valor y al numero anterior en pos
	;se pone como un espacio vacio, para que se vea bien y no hayan problemas visuales
	fin_imprimible:
		add eax, '0'
		mov byte[ebx], al
		dec ebx
		mov byte[ebx], ' '
		jmp JUEGO
	
;Lo mismo sucede con todas estas otras versiones, solo que el numero o palabra adicional
;simbolizan a cual menu se llevara (para el mensaje) o en caso del final pues para eso
TIEMPO_ACTUAL1:
	xor rcx,rcx						; Limpia registro ecx
	xor rdx,rdx						; Limpia registro edx
	xor rax,rax						; Limpia registro eax

	mov  eax, 13						
	xor rbx,rbx
        int  0x80


	mov dword [tiempo2],eax					

        xor rcx,rcx                                             
        xor rdx,rdx                                             
        xor rax,rax                                             

	mov ebx,dword [tiempo1]						
	mov eax,dword [tiempo2]					
	mov cl,byte [tiempoTotal]				
	sub eax,ebx						
	sub ecx,eax						
	cmp ecx, 0
	jle VERGANET
	
	mov eax, ecx
	mov ebx, tiempo
	
	ultimo1:
		inc ebx
		cmp byte[ebx], 's'
		jne ultimo1
	dec ebx
	
	tiempo_imprimible1:
		cmp eax, 9
		jle fin_imprimible1
		
		mov ecx, 10
		mov edx, 0
		div ecx
		add edx, '0'
		mov byte[ebx], dl
		dec ebx
		jmp tiempo_imprimible1
	
	fin_imprimible1:
		add eax, '0'
		mov byte[ebx], al
		dec ebx
		mov byte[ebx], ' '
		jmp JUEGO1
	
TIEMPO_ACTUAL2:
	xor rcx,rcx						; Limpia registro ecx
	xor rdx,rdx						; Limpia registro edx
	xor rax,rax						; Limpia registro eax

	mov  eax, 13						
	xor rbx,rbx
        int  0x80


	mov dword [tiempo2],eax					

        xor rcx,rcx                                             ; Limpia registro ecx
        xor rdx,rdx                                             ; Limpia registro edx
        xor rax,rax                                             ; Limpia registro eax

	mov ebx,dword [tiempo1]					
	mov eax,dword [tiempo2]					
	mov cl,byte [tiempoTotal]				
	sub eax,ebx						
	sub ecx,eax						
	cmp ecx, 0
	jle VERGANET
	
	mov eax, ecx
	mov ebx, tiempo
	
	ultimo2:
		inc ebx
		cmp byte[ebx], 's'
		jne ultimo2
	dec ebx
	
	tiempo_imprimible2:
		cmp eax, 9
		jle fin_imprimible2
		
		mov edx, 0
		mov ecx, 10
		div ecx
		add edx, '0'
		mov byte[ebx], dl
		dec ebx
		jmp tiempo_imprimible2
	
	fin_imprimible2:
		add eax, '0'
		mov byte[ebx], al
		dec ebx
		mov byte[ebx], ' '
		jmp JUEGO2
		
TIEMPO_ACTUAL5:
	xor rcx,rcx						; Limpia registro ecx
	xor rdx,rdx						; Limpia registro edx
	xor rax,rax						; Limpia registro eax

	mov  eax, 13						
	xor rbx,rbx
        int  0x80


	mov dword [tiempo2],eax					

        xor rcx,rcx                                             ; Limpia registro ecx
        xor rdx,rdx                                             ; Limpia registro edx
        xor rax,rax                                             ; Limpia registro eax

	mov ebx,dword [tiempo1]					
	mov eax,dword [tiempo2]					
	mov cl,byte [tiempoTotal]				
	sub eax,ebx						
	sub ecx,eax						
	cmp ecx, 0
	jle VERGANET						
	
	mov eax, ecx
	mov ebx, tiempo
	
	ultimo5:
		inc ebx
		cmp byte[ebx], 's'
		jne ultimo5
	dec ebx
	
	tiempo_imprimible5:
		cmp eax, 9
		jle fin_imprimible5
		
		mov ecx, 10
		mov edx, 0
		div ecx
		add edx, '0'
		mov byte[ebx], dl
		dec ebx
		jmp tiempo_imprimible5
	
	fin_imprimible5:
		add eax, '0'
		mov byte[ebx], al
		dec ebx
		mov byte[ebx], ' '
		jmp JUEGO5
		
TIEMPO_FIN:
	xor rcx,rcx						; Limpia registro ecx
	xor rdx,rdx						; Limpia registro edx
	xor rax,rax						; Limpia registro eax

	mov  eax, 13						
	xor rbx,rbx
        int  0x80


	mov dword [tiempo2],eax					

        xor rcx,rcx                                             ; Limpia registro ecx
        xor rdx,rdx                                             ; Limpia registro edx
        xor rax,rax                                             ; Limpia registro eax

	mov ebx,dword [tiempo1]						
	mov eax,dword [tiempo2]					
	mov cl,byte [tiempoTotal]				
	sub eax,ebx						
	sub ecx,eax						
	cmp ecx, 0
	jle VERGANET
	mov eax, ecx
	mov ebx, tiempo
	
	ultimof:
		inc ebx
		cmp byte[ebx], 's'
		jne ultimo
	dec ebx
	
	tiempo_imprimiblef:
		cmp eax, 9
		jle fin_imprimiblef
		
		mov ecx, 10
		mov edx, 0
		div ecx
		add edx, '0'
		mov byte[ebx], dl
		dec ebx
		jmp tiempo_imprimiblef
	
	fin_imprimiblef:
		add eax, '0'
		mov byte[ebx], al
		dec ebx
		mov byte[ebx], ' '
		jmp VERGANE
	
;Esta funcion genera un numero aleatorio del 0 al 7 y lo guarda en la variable "aleatorio"
RANDOM:
	rdtsc 							;The rdtsc (Read Time-Stamp Counter) instruction is used to determine how many CPU ticks took place since the processor was reset. 
	and ah, 00000111b  					;hace un and para obtener numeros del 0 al 7 
	add ah,'0'     						;convierte valor numero en su equivalente ASCII para despliegue 
	mov [aleatorio],ah 					;almacena en "aleatorio" el numero obtenido
	
;Funcion para encontrar caso actual segun el numero aleatorio.
INICIO:
	cmp byte[aleatorio], '1'
	jle CASO1
	
	cmp byte[aleatorio], '2'
	je CASO2
	
	cmp byte[aleatorio], '3'
	je CASO3
	
	cmp byte[aleatorio], '4'
	je CASO4
	
	jmp CASO5
	
;Los casos, dependiendo del numero aleatorio, lo que hacen es poner 4 numeros en el tablero
CASO1:
	mov ebx, fila1
	add ebx, 27
	mov byte[ebx], '4'
	
	
	add ebx, 12
	mov byte[ebx], '2'
	
	xor ebx, ebx
	mov ebx, fila2
	add ebx, 33
	mov byte[ebx], '5'
	
	xor ebx, ebx
	mov ebx, fila3
	add ebx, 39
	mov byte[ebx], '6'
	jmp JUEGO
	
CASO2:
	mov ebx, fila1
	add ebx, 33
	mov byte[ebx], '9'
	
	xor ebx, ebx
	mov ebx, fila2
	add ebx, 39
	mov byte[ebx], '7'
	
	xor ebx, ebx
	mov ebx, fila3
	add ebx, 27
	mov byte[ebx], '8'
	
	add ebx, 12
	mov byte[ebx], '6'
	jmp JUEGO

CASO3:
	mov ebx, fila1
	add ebx, 27
	mov byte[ebx], '2'
	
	
	add ebx, 12
	mov byte[ebx], '4'
	
	xor ebx, ebx
	mov ebx, fila2
	add ebx, 33
	mov byte[ebx], '5'
	
	xor ebx, ebx
	mov ebx, fila3
	add ebx, 39
	mov byte[ebx], '8'
	jmp JUEGO

CASO4:
	mov ebx, fila3
	add ebx, 27
	mov byte[ebx], '6'
	
	
	add ebx, 12
	mov byte[ebx], '8'
	
	xor ebx, ebx
	mov ebx, fila2
	add ebx, 39
	mov byte[ebx], '3'
	
	xor ebx, ebx
	mov ebx, fila1
	add ebx, 39
	mov byte[ebx], '4'
	jmp JUEGO

CASO5:
	mov ebx, fila3
	add ebx, 27
	mov byte[ebx], '2'
	
	
	add ebx, 12
	mov byte[ebx], '4'
	
	xor ebx, ebx
	mov ebx, fila2
	add ebx, 39
	mov byte[ebx], '3'
	
	xor ebx, ebx
	mov ebx, fila1
	add ebx, 39
	mov byte[ebx], '8'
	jmp JUEGO

;Imprime el tablero y el menu actual, dependiendo del numero cambia el mensaje
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
	imprimeEnPantalla coord, lenCoordMenu
	imprimeEnPantalla time, lenTimeMenu
	imprimeEnPantalla tiempo, lenTiempo
	imprimeEnPantalla info, lenInfoMenu
	imprimeEnPantalla esc, lenEscMenu

	;Se recibe el input, primero las filas y luego las columnas
	imprimeEnPantalla msgInput1, lenMsgInput1
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero fil 					;Sino, se guarda el numero como numero en una variable separada

	imprimeEnPantalla msgInput2, lenMsgInput2
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero col					;Sino, se guarda el numero como numero en una variable separada
	
	imprimeEnPantalla numInput, lenNumInput
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero num					;Sino, se guarda el numero como numero en una variable separada
	jmp NUMX
	
JUEGO1:
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
	imprimeEnPantalla coord, lenCoordMenu
	imprimeEnPantalla time, lenTimeMenu
	imprimeEnPantalla tiempo, lenTiempo
	imprimeEnPantalla info1, lenInfo1Menu
	imprimeEnPantalla esc, lenEscMenu

	;Se recibe el input, primero las filas y luego las columnas
	imprimeEnPantalla msgInput1, lenMsgInput1
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero fil 					;Sino, se guarda el numero como numero en una variable separada

	imprimeEnPantalla msgInput2, lenMsgInput2
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero col					;Sino, se guarda el numero como numero en una variable separada
	
	imprimeEnPantalla numInput, lenNumInput
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero num					;Sino, se guarda el numero como numero en una variable separada
	jmp NUMX
	
JUEGO2:
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
	imprimeEnPantalla coord, lenCoordMenu
	imprimeEnPantalla time, lenTimeMenu
	imprimeEnPantalla tiempo, lenTiempo
	imprimeEnPantalla info2, lenInfo2Menu
	imprimeEnPantalla esc, lenEscMenu

	;Se recibe el input, primero las filas y luego las columnas
	imprimeEnPantalla msgInput1, lenMsgInput1
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero fil 					;Sino, se guarda el numero como numero en una variable separada

	imprimeEnPantalla msgInput2, lenMsgInput2
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero col					;Sino, se guarda el numero como numero en una variable separada
	
	imprimeEnPantalla numInput, lenNumInput
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaASCII num					;Sino, se guarda el numero como numero en una variable separada
	jmp NUMX
	
JUEGO5:
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
	imprimeEnPantalla coord, lenCoordMenu
	imprimeEnPantalla time, lenTimeMenu
	imprimeEnPantalla tiempo, lenTiempo
	imprimeEnPantalla info5, lenInfo5Menu
	imprimeEnPantalla esc, lenEscMenu

	;Se recibe el input, primero las filas y luego las columnas
	imprimeEnPantalla msgInput1, lenMsgInput1
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero fil 					;Sino, se guarda el numero como numero en una variable separada

	imprimeEnPantalla msgInput2, lenMsgInput2
	leeTeclado
	cmp byte[entrada], 27 	;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero col					;Sino, se guarda el numero como numero en una variable separada
	
	imprimeEnPantalla numInput, lenNumInput
	leeTeclado
	cmp byte[entrada], 27 					;Si es un ESC entonces se sale
	je LIMPIAR
	capturaNumero num					;Sino, se guarda el numero como numero en una variable separada
	jmp NUMX
	
;Se verifica que el numero digitado no se haya colocado, para eso existen 3 funciones diferentes para cada numero, es decir 30 funciones en si, lo que hacen es observar si el valor se encuentra en el tablero y sino continua, pero si esta en el tablero entonces se carga un menu mostrando un mensaje de error respectivo.
HORIZONTAL11:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL12

HORIZONTAL12:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL13

HORIZONTAL13:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '1'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2
	
HORIZONTAL21:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL22

HORIZONTAL22:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL23

HORIZONTAL23:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '2'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2

HORIZONTAL31:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL32

HORIZONTAL32:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL33

HORIZONTAL33:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '3'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2

HORIZONTAL41:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL42

HORIZONTAL42:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL43

HORIZONTAL43:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '4'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2

HORIZONTAL51:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL52

HORIZONTAL52:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL53

HORIZONTAL53:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '5'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2
	
HORIZONTAL61:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL62

HORIZONTAL62:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL63

HORIZONTAL63:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '6'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2
	
HORIZONTAL71:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL72

HORIZONTAL72:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL73

HORIZONTAL73:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '7'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2
	
HORIZONTAL81:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL82

HORIZONTAL82:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL83

HORIZONTAL83:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '8'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2
	
HORIZONTAL91:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL92

HORIZONTAL92:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL93

HORIZONTAL93:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '9'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2

HORIZONTAL01:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL02

HORIZONTAL02:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1
	
	jmp HORIZONTAL03

HORIZONTAL03:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '0'
	je TIEMPO_ACTUAL1
	
	;Se verifica que la posicion sea correcta y en caso de ser asi se procede a realizar un salto dependiendo de la fila seleccionada, si la posicion no es valida, se muestra un menu con el mensaje respectivo (pero antes se carga el tiempo actual)
	cmp byte[fil], 0
	je MOVIMIENTO1

	cmp byte[fil], 1
	je MOVIMIENTO2

	cmp byte[fil], 2
	je MOVIMIENTO3
	jmp TIEMPO_ACTUAL2

;Los movimientos guardan la fila en ebx y luego comparan para encontrar en cual columna se va a trabajar
;Dependiendo de el numero del movimiento se tiene el numero de la fila en la que se trabaja
;Si la columna indicada no existe entonces se sale a un menu con su mensaje de error respectivo
MOVIMIENTO1:
	mov ebx, fila1
	cmp byte[col], 0
	je ACCION1
	cmp byte[col], 1
	je ACCION2
	cmp byte[col], 2
	je ACCION3
	jmp TIEMPO_ACTUAL2

MOVIMIENTO2:
	mov ebx, fila2
	cmp byte[col], 0
	je ACCION1
	cmp byte[col], 1
	je ACCION2
	cmp byte[col], 2
	je ACCION3
	jmp TIEMPO_ACTUAL2

MOVIMIENTO3:
	mov ebx, fila3
	cmp byte[col], 0
	je ACCION1
	cmp byte[col], 1
	je ACCION2
	cmp byte[col], 2
	je ACCION3
	jmp TIEMPO_ACTUAL2

;Una vez encontrada la posicion se añade un valor segun la columna seleccionada, el numero de la accion varia segun en la columna que se trabaja, y luego se realiza un salto a NUM
ACCION1:
	add ebx, 27
	jmp NUM

ACCION2:
	add ebx, 33
	jmp NUM

ACCION3:
	add ebx, 39
	jmp NUM
	
;Esta funcion verifica el numero dado y bajo ese numero se salta a una funcion para añadir, dependiendo del numero se salta a una funcion específica para añadir el numero en cuestión.
NUM:
	cmp byte[num], 1
	je ADD1
	cmp byte[num], 2
	je ADD2
	cmp byte[num], 3
	je ADD3
	cmp byte[num], 4
	je ADD4
	cmp byte[num], 5
	je ADD5
	cmp byte[num], 6
	je ADD6
	cmp byte[num], 7
	je ADD7
	cmp byte[num], 8
	je ADD8
	cmp byte[num], 9
	je ADD9
	cmp byte[num], 0
	je ADD0
	jmp JUEGO2
	
;Esta funcion verifica cual fue el numero añadido y dependiendo del resultado se salta a una verificacion de si ese numero ya fue añadido
NUMX:
	cmp byte[num], 1
	je HORIZONTAL11
	cmp byte[num], 2
	je HORIZONTAL21
	cmp byte[num], 3
	je HORIZONTAL31
	cmp byte[num], 4
	je HORIZONTAL41
	cmp byte[num], 5
	je HORIZONTAL51
	cmp byte[num], 6
	je HORIZONTAL61
	cmp byte[num], 7
	je HORIZONTAL71
	cmp byte[num], 8
	je HORIZONTAL81
	cmp byte[num], 9
	je HORIZONTAL91
	cmp byte[num], 0
	je HORIZONTAL01
	jmp TIEMPO_ACTUAL2

;Si se va a añadir un numero, entonces se verifica que el espacio sea vacio y luego se realiza lo demás, que sería en si, poner el numero y verificar si ya termino el juego.
ADD1:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '1'
	jmp VERFINAL
	
ADD2:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '2'
	jmp VERFINAL
	
ADD3:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '3'
	jmp VERFINAL
	
ADD4:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '4'
	jmp VERFINAL
	
ADD5:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '5'
	jmp VERFINAL
	
ADD6:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '6'
	jmp VERFINAL
	
ADD7:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '7'
	jmp VERFINAL
	
ADD8:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '8'
	jmp VERFINAL
	
ADD9:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '9'
	jmp VERFINAL
	
ADD0:
	cmp byte[ebx], ' '
	jne TIEMPO_ACTUAL5
	mov byte[ebx], '0'
	jmp VERFINAL
	

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

;Si gana, se imprime el mensaje, el tablero y se sale
GANEX:
	;Se imprime en pantalla el menú
	imprimeEnPantalla fila1, lenFila1
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila2, lenFila2
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila3, lenFila3
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla coord, lenCoordMenu
	imprimeEnPantalla time, lenTimeMenu
	imprimeEnPantalla tiempo, lenTiempo
	imprimeEnPantalla ganeX, ganeXLen
	jmp SALIR

;Si todas las posiciones han sido ocupadas, entonces terminó la partida asi que se carga el tiempo final y se verifica si gano, sino se sigue
VERFINAL:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL

	add ebx, 6
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL

	add ebx, 6
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL

	xor ebx, ebx
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL

	add ebx, 6
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL

	add ebx, 6
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL


	xor ebx, ebx
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL

	add ebx, 6
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL

	add ebx, 6
	cmp byte[ebx], ' '
	je TIEMPO_ACTUAL
	jmp TIEMPO_FIN
	
;Si el tiempo se acabo se imprime el mensaje, se carga el tiempo y se verifica si ganó
VERGANET:
	imprimeEnPantalla info4, lenInfo4Menu
	mov ebx, tiempo
	
	ciclo:
		mov byte[ebx], '0'
		inc ebx
		cmp byte[ebx], 's'
		jne ciclo
	
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '4'
	jne VERGANEA

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '9'
	jne VERGANEA

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '2'
	jne VERGANEA
	
	jmp VERGANE1
	
;Ya que solo existen pocas posibilidades de gane, se verifica si el tablero esta como alguno de los que aqui se encuentran, de no ser asi entonces perdio
VERGANE:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '4'
	jne VERGANEA

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '9'
	jne VERGANEA

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '2'
	jne VERGANEA
	
	jmp VERGANE1
	
VERGANE1:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '3'
	jne VERGANEA

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '5'
	jne VERGANEA

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '7'
	jne VERGANEA
	
	jmp VERGANE2

VERGANE2:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '8'
	jne VERGANEA

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '1'
	jne VERGANEA

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '6'
	jne VERGANEA
	
	jmp GANEX

VERGANEA:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '2'
	jne VERGANEB

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '9'
	jne VERGANEB

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '4'
	jne VERGANEB
	
	jmp VERGANEA1

VERGANEA1:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '7'
	jne VERGANEB

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '5'
	jne VERGANEB

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '3'
	jne VERGANEB
	
	jmp VERGANEA2

VERGANEA2:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '6'
	jne VERGANEB

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '1'
	jne VERGANEB

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '8'
	jne VERGANEB
	
	jmp GANEX

VERGANEB:
	mov ebx, fila1
	add ebx, 27
	cmp byte[ebx], '6'
	jne DERROTAX

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '1'
	jne DERROTAX

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '8'
	jne DERROTAX
	
	jmp VERGANEB1

VERGANEB1:
	mov ebx, fila2
	add ebx, 27
	cmp byte[ebx], '7'
	jne DERROTAX

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '5'
	jne DERROTAX

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '3'
	jne DERROTAX
	
	jmp VERGANEB2

VERGANEB2:
	mov ebx, fila3
	add ebx, 27
	cmp byte[ebx], '2'
	jne DERROTAX

	sub ebx, 27
	add ebx, 33
	cmp byte[ebx], '9'
	jne DERROTAX

	sub ebx, 33
	add ebx, 39
	cmp byte[ebx], '4'
	jne DERROTAX
	
	jmp GANEX
	
;Si perdio, se imprime el tablero con el mensaje y se sale
DERROTAX:
	;Se imprime en pantalla el menú
	imprimeEnPantalla fila1, lenFila1
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila2, lenFila2
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla fila3, lenFila3
	imprimeEnPantalla linea, lenLinea
	imprimeEnPantalla coord, lenCoordMenu
	imprimeEnPantalla time, lenTimeMenu
	imprimeEnPantalla tiempo, lenTiempo
	imprimeEnPantalla derrota, derrotaLen
	jmp SALIR

;Si se selecciona salir en el menu inicial, entonces se hace un salto a FIN que lo que hace es directamente salir
SALIR:
	jmp FIN

FIN:	
	salir 
