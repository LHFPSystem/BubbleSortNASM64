;Dado un archivo que contiene n números en BPF c/signo de 8 bits (n <= 30) se pide codificar en
;assembler Intel 80x86 un programa que imprima por pantalla que movimiento se realiza (por ejemplo
;“Realizando el intercambio de valores”) y el contenido de dicho archivo ordenado en forma ascendente
;o descendente de acuerdo a lo que elija el usuario, usando un algoritmo de ordenamiento basado en
;el método de selección.

global 	main
extern 	printf
extern	gets
extern 	sscanf
extern	fopen
extern	fread
extern	fclose

section  .data
	
	fileName	    			db	"NUMEROS.dat",0
	mode		    			db	"rb",0		; modo lectura del archivo binario
	msgErrOpen	    			db  "Error en apertura de archivo",10,13,0
    msjSalida       			db  'Elemento guardado en posicion %hi: %hi',10,13,0
	msgEndOfFile   				db  "Fin de archivo",10,13,0
	msjSwap             		db  'Intercambiando de la posicion %hi a la posicion %hi el valor: %hi',10,13,0
	msjInvalido         		db  "Numero ingresado incorrecto",10,13,0
	msjIngresarOrdenMay 		db  "Ingrese 0 para mostrar orden de mayor a menor",10,13,0
	msjIngresarOrdenMen 		db  "Ingrese 1 para mostrar orden de menor a mayor",10,13,0
    numFormat					db	'%hi',10,13,0
    msjFin                      db  "Fin del programa.Ingrese algo para finalizar: ",10,13,0

	vector		                times 30	dw 0
    LONG_ELEM                   equ 2

	col                         dq 1
	curPos                      dq 1
	minPos                      dq 1
	minValue                    dw 0
	bufCOL                      dq 0
	maxCol                      dq 0
	CantidadNumeros		        dq 0
    invCol                      dq 0
    


section  .bss

	fileHandle		            resq	1
	buffer			            resb	10
	registroLeido	            resw	1
	nroIng			            resd	1

section .text

main:

	call	abrirArch
	cmp		qword[fileHandle],0				;Error en apertura?
	jle		errorOpen

	call	leerArch
	mov		qword[col],1
	
	call	IterarVector

		
endProg:

	ret

errorOpen:
	
	mov		rcx, msgErrOpen
	sub		rsp,32
	call	printf
	add		rsp,32
	jmp		endProg

abrirArch:

	mov		rcx,fileName			;Parametro 1: dir nombre del archivo
	mov		rdx,mode				;Parametro 2: dir string modo de apertura
	sub		rsp,32
	call	fopen					;ABRE el archivo y deja el handle en RAX
	add		rsp,32
	mov		qword[fileHandle],rax

	ret

leerArch:

leerReg:

	mov		rcx,registroLeido			;Parametro 1: dir area de memoria donde se copia
	mov		rdx,1						;Parametro 2: longitud del registro
	mov		r8,1						;Parametro 3: cantidad de registros
	mov		r9,qword[fileHandle]		;Parametro 4: handle del archivo
	sub		rsp,32
	call	fread						;LEO registro. Devuelve en rax la cantidad de bytes leidos
	add		rsp,32

	cmp		rax,0				;Fin de archivo?
	jle		eof

    cmp     qword[CantidadNumeros],30
    je      eof     
	add		qword[CantidadNumeros],1

	call	cargarVector
	jmp		leerReg	

eof:
;	Cierro archivo cuando llega a fin del archivo
	mov		rcx,qword[fileHandle]	;Parametro 1: handle del archivo
	sub		rsp,32
	call	fclose
	add		rsp,32
    inc     qword[CantidadNumeros]
	mov		rax,qword[CantidadNumeros]
	mov		qword[maxCol],rax
	mov		qword[col],1
	
	ret


cargarVector:
 
    mov 	rax,[col]
    dec 	rax
    imul 	rax,LONG_ELEM
    mov 	rbx,rax

	mov 	r9w,word[registroLeido]
    mov 	word[vector+rbx],r9w       ;Cargo en la matriz

    mov 	rax,[col]
    dec 	rax
    imul 	rax,LONG_ELEM
    mov 	rbx,rax

	add 	qword[col],1

	ret

;Comienza burbujeo
IterarVector:  

    mov 	rax,[col]
    dec 	rax
    imul 	rax,LONG_ELEM
    mov 	rbx,rax

    mov     qword[curPos],rbx
    mov     rax,qword[col]
    mov     qword[bufCOL],rax
    inc     qword[col]

    mov     r9w, word[vector+rbx]
    mov     word[minValue],r9w
    
    mov     qword[minPos],rbx

    mov     rax,qword[maxCol]
    cmp     qword[col],rax
    je      preIngresarOrden

    jmp     detMinimoActual

swap:

    mov     rdx,qword[minPos]

    mov     rbx,qword[curPos]
    cmp     rbx,qword[minPos]
    je      nextIteration

    mov     rbx,qword[curPos]        ;Cargo offset en RBX
    mov     r9w,[vector+rbx]        ;Minimum value
    mov     rax,qword[minPos]

    mov     rcx, msjSwap
    mov     rdx,[minPos]
    mov     r8,[curPos]
    sub     r9,r9
    mov     r9w, word[vector+rax]

    sub     rsp,8
    call    printf
    add     rsp,8

    mov     rcx, msjSwap
    mov     rdx,[curPos]
    mov     r8,[minPos]
    sub     r9,r9
    mov     r9w, word[vector+rbx]

    sub     rsp,8
    call    printf
    add     rsp,8

    mov     rbx,qword[minPos]        ;Cargo offset en RBX
    mov     r9w,word[vector+rbx]     ;Minimum value
    mov     rbx,qword[curPos]        ;
    mov     ax,[vector+rbx]
    mov     word[vector+rbx], r9w   ;Swap curPos=MinimumValue
    mov     rbx,qword[minPos] 
    mov     word[vector+rbx],ax     ;Swap minPos=curValue


nextIteration:

    mov     rbx,qword[curPos]
    add     rbx, 2
    mov     rax,qword[bufCOL]
    inc     rax
    mov     qword[col],rax
    jmp     IterarVector

increaseRow:
    
    add     qword[col],1
    mov     rax,qword[maxCol]
    cmp     qword[col],rax
    je      swap

detMinimoActual:

    mov 	rax,[col]
    dec 	rax
    imul 	rax,LONG_ELEM
    mov 	rbx,rax

    mov     r9w, word[vector+rbx]   ;n+1
    mov     rax, qword[curPos]      ;rax = offset current position
    cmp     word[minValue],r9w     ;Initial Value > current Value (I > J)
    jl      increaseRow

    mov     qword[minPos],rbx
    mov     word[minValue],r9w

    mov     rax,qword[maxCol]
    cmp     qword[col],rax
    je      swap
    jmp     increaseRow

invalido:

    mov     rcx,msjInvalido
    sub     rsp,32
    call    printf
    add     rsp,32

preIngresarOrden:

ingresarOrden:

    mov     rcx,msjIngresarOrdenMay
    sub     rsp,32
    call    printf
    add     rsp,32

    mov     rcx,msjIngresarOrdenMen
    sub     rsp,32
    call    printf
    add     rsp,32

    mov		rcx,buffer
    sub     rsp,32
    call	gets
    add     rsp,32

    mov		rcx,buffer		
	mov		rdx,numFormat	
	mov		r8,nroIng		
	sub		rsp,32
	call	sscanf
	add		rsp,32

    cmp		rax,1			
	jl		invalido

    cmp		dword[nroIng],0
	je		iteracionFinalMayor
	cmp		dword[nroIng],1
	je		iteracionFinalMenor
    jmp     invalido

iteracionFinalMenor:

    mov     qword[col],1
    mov     rbx,8

IterarVectorFinalMenor:

    mov 	rax,[col]
    dec 	rax
    imul 	rax,LONG_ELEM
    mov 	rbx,rax

    mov     rcx, msjSalida
    mov     rdx,[col]
    mov     r8,[vector+rbx]

    sub     rsp,32
    call    printf
    add     rsp,32
    
    mov     rdx,qword[maxCol]
    inc     qword[col]
    cmp     qword[col],rdx
    je      finalizar
    jmp     IterarVectorFinalMenor


iteracionFinalMayor:

    
    dec     qword[maxCol]
    mov     rdx,qword[maxCol]
    mov     qword[col],rdx
    mov     rbx,8

IterarVectorFinalMayor:

    inc     qword[invCol]
    mov 	rax,[col]
    dec 	rax
    imul 	rax,LONG_ELEM
    mov 	rbx,rax

    mov     rcx, msjSalida
    mov     rdx,[invCol]
    mov     r8,[vector+rbx]

    sub     rsp,32
    call    printf
    add     rsp,32

    dec     qword[col]

    cmp     qword[col],0
    je      finalizar
    jmp     IterarVectorFinalMayor

    
finalizar:
    mov     rcx,msjFin
    sub     rsp,32
    call	printf
    add     rsp,32
    ;Espero antes de finalizar
	mov		rcx,buffer
    sub     rsp,32
    call	gets
    add     rsp,32
    
    ret
