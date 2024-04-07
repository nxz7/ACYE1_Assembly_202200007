LimpiarConsola MACRO
    MOV AX, 03h
    INT 10h
ENDM

Print MACRO registroPrint
    MOV AH, 09h
    LEA DX, registroPrint
    INT 21h
ENDM

getOpcion MACRO regOpcion
    MOV AH, 01h
    INT 21h

    MOV regOpcion, AL
ENDM

ImprimirBoard MACRO
    LOCAL fila, columna
    XOR BX, BX
    XOR SI, SI

    Print columnas
    MOV CL, 0

    fila:
        Print salto
        MOV AH, 02h
        MOV DL, filas[BX]
        INT 21h

        MOV DL, 32
        INT 21h

        columna:
            MOV DL, matriz[SI]
            CMP filas[BX], 49 ;
            JE SetPValueRow1Aux
            CMP filas[BX], 50 ; fila 2
            JE SetPValueRow2Aux
            CMP filas[BX], 55 ;  7
            JE SetPValueRow7Aux
            CMP filas[BX], 56 ;8
            JE SetPValueRow8Aux
            INT 21h
            JMP CheckEndOfRowAux
        SetPValueRow2Aux:
        JMP SetPValueRow2
        SetPValueRow7Aux:
        JMP SetPValueRow7
        SetPValueRow1Aux:
        JMP SetPValueRow1
        SetPValueRow8Aux:
        JMP SetPValueRow8
        CheckEndOfRowAux:
        JMP CheckEndOfRow
        SetPValueRow1:
            MOV DL, 't' ; Column A
            CMP CL, 0
            JE PrintColumn
            MOV DL, 'c' ; Column B
            CMP CL, 1
            JE PrintColumn
            MOV DL, 'a' ; Column C
            CMP CL, 2
            JE PrintColumn
            MOV DL, 'r' ; Column D
            CMP CL, 3
            JE PrintColumn
            MOV DL, '#' ; Column E
            CMP CL, 4
            JE PrintColumn
            MOV DL, 'a' ; Column F
            CMP CL, 5
            JE PrintColumn
            MOV DL, 'c' ; Column G
            CMP CL, 6
            JE PrintColumn
            MOV DL, 't' ; Column H
            CMP CL, 7
            JE PrintColumn
            JMP CheckNextRow
        SetPValueRow2:
            MOV DL, 'p' ; valor p 
            INT 21h
            JMP CheckEndOfRow
        SetPValueRow7:
            MOV DL, 'P' ; valor P
            INT 21h
            JMP CheckEndOfRow
        SetPValueRow8:
            MOV DL, 'T' ; Column A
            CMP CL, 0
            JE PrintColumn
            MOV DL, 'C' ; Column B
            CMP CL, 1
            JE PrintColumn
            MOV DL, 'A' ; Column C
            CMP CL, 2
            JE PrintColumn
            MOV DL, 'R' ; Column D
            CMP CL, 3
            JE PrintColumn
            MOV DL, '*' ; Column E
            CMP CL, 4
            JE PrintColumn
            MOV DL, 'A' ; Column F
            CMP CL, 5
            JE PrintColumn
            MOV DL, 'C' ; Column G
            CMP CL, 6
            JE PrintColumn
            MOV DL, 'T' ; Column H
            CMP CL, 7
            JE PrintColumn
            JMP CheckNextRow
        PrintColumn:
            INT 21h
            JMP CheckEndOfRow
        columnaAux:
        JMP columna
        filaAux:
        JMP fila
        CheckNextRow:
            MOV DL, matriz[SI]
            INT 21h
        CheckEndOfRow:
            MOV DL, 124
            INT 21h

            INC CL
            INC SI

            CMP CL, 8
            JB columnaAux

            MOV CL, 0
            INC BX
            CMP BX, 8
            JB filaAux
ENDM

RowMajorMatriz MACRO
    MOV AL, row
    MOV BL, col
    
    SUB AL, 49
    SUB BL, 65
    
    MOV BH, 8
    
    MUL BH
    ADD AL, BL
    
    MOV SI, AX
    MOV matriz[SI], 80
ENDM
.MODEL small
.STACK 64h
.DATA
    salto db 10, 13, "$" ; \n
    mensajeInicio db " Universidad De San Carlos De Guatemala", 10, 13, " Facultad De Ingenieria", 10, 13, " Escuela de ciencias y sistemas", 10, 13," Arquitectura de computadores y ensambladores 1", 10, 13," SECCION A", 10, 13, "$"
    mensajeDatos db " PRIMER SEMESTRE 2024", 10, 13, " Natalia Mariel Calderon Echeverria", 10, 13, " ----> 202200007 - PRACTICA 3", 10, 13, "$"
    mensajeSeparacion db "========================================", 10, 13, "$"
    mensajeTitulo db " ========CHESS - NATALIA MARIEL =========", 10, 13, "$"
    mensajeMenuContinuar db "Desea Continuar? (y/n): ", "$"
    mensajeMenu db "l -->(1) Nuevo Juego      l", 10, 13, "l -->(2) Puntajes           l", 10, 13, "l -->(3) Reportes          l", 10, 13, "l -->(4) Salir              l", 10, 13, " --->>>>> Seleccione del menu: ", "$"
    msg1 db 10, 13, 10, 13, "Ingrese la fila: ", "$"
    msg2 db 10, 13, "Ingrese la columna: ", "$"
    matriz db 64 dup(32)
    columnas db "  A B C D E F G H","$"
    filas db "12345678","$"
    msgSalida db "Saliendo Del Programa...", "$"
    msgEFila db 10, 13, "La Fila Ingresada Es Incorrecta", "$"
    msgEColumna db 10, 13, "La Columna Ingresada Es Incorrecta", "$"
    opcionContinuar db 1 dup("$")
    jugador_message db 10, 13, "natalia ========= $"
    opcion db 1 dup("$")
    row db 1 dup("$")
    col db 1 dup("$")
    counter_units db 0   ; unidad
    counter_tens db 0    ; decena
.CODE
    MOV AX, @data
    MOV DS, AX
    call Main
; aumentar
IncrementCounter PROC
    mov al, [counter_units]
    inc al
    cmp al, 10      ; ver si 10
    jne NoReset     ; si no salta el reset
    mov al, 0       ; unidad 0
    inc byte ptr [counter_tens] ; decena
NoReset:
    mov [counter_units], al
    ret
IncrementCounter ENDP

; mostrar
DisplayCounter PROC
    ; Print "Jugador ========= "
    mov ah, 09h       
    mov dx, offset jugador_message 
    int 21h           
        
    mov ah, 02h       ; 
    mov al, [counter_tens] ; decena
    add al, 30h       ; ASCII
    mov dl, al
    int 21h           ; 10
    
    mov al, [counter_units] ; unidad
    add al, 30h       ; ASCII
    mov dl, al
    int 21h           ; unidad
    ret
DisplayCounter ENDP
;--------------------------------------
    ; se imprime todo
    Main PROC
        LimpiarConsola
        Print mensajeSeparacion
        Print mensajeInicio
        Print mensajeSeparacion
        Print mensajeDatos
        Print mensajeSeparacion
        Menu:
            Print mensajeTitulo
            Print mensajeMenu
            getOpcion opcion ; OPCION
            CMP opcion, 49 ; 1 - NUEVO JUEGI
            JE JUEGO
            ;--------------------------------
            CMP opcion, 50 ; 2 - PUNTAJES
            JE ImprimirPuntajesaux
            ;-------------------------------
            CMP opcion, 51 ; 3 - REPORTES
            JE ImprimirReportesAux
            ;-----------------------------
            CMP opcion, 52 ; 4 - SALIR
            JE SalirAux
            
        ImprimirPuntajesaux:
        JMP ImprimirPuntajes
        ImprimirReportesAux:
        JMP ImprimirReportes
        SalirAux:
        JMP Salir
        JUEGO:
            LimpiarConsola
            ImprimirBoard
            call IncrementCounter
            call DisplayCounter
            Print salto
            JMP PedirOpcionFila
            JMP Menu

        PedirOpcionFila:
            Print msg1
            call IncrementCounter
            getOpcion row 
            CMP row, 49
            JB ErrorFila
            CMP row, 56
            JA ErrorFila
            JMP PedirOpcionColumna
            
        ErrorFila:
            Print msgEFila
            getOpcion opcion
            JMP PedirOpcionFila
        
        PedirOpcionColumna:
            Print msg2
            call IncrementCounter
            getOpcion col 
            
            CMP col, 65
            JB ErrorColumna
            
            CMP col, 72
            JA ErrorColumna
            JMP PosicionarMatriz

        ErrorColumna:
            Print msgEColumna
            getOpcion opcion
            JMP PedirOpcionColumna

    PosicionarMatriz:
        RowMajorMatriz
        ;ImprimirBoard
        Print salto

        ; si desea continuar
        Print mensajeMenuContinuar
        getOpcion opcionContinuar
        
        CMP opcionContinuar, 121 ; 'y'
        
        JNE NoContinuar

        ; seguir
        JMP JUEGO

    NoContinuar:
        ; salir a menu --> reportes
        JMP Menu

        
        ImprimirPuntajes:
        call IncrementCounter
        call DisplayCounter
        JMP Menu

        ImprimirReportes:

        Salir:
            MOV AX, 4C00h 
            INT 21h
    Main ENDP
END