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
            JE SetPValueRow1
            CMP filas[BX], 50 ; fila 2
            JE SetPValueRow2
            CMP filas[BX], 55 ;  7
            JE SetPValueRow7
            CMP filas[BX], 56 ;8
            JE SetPValueRow8
            INT 21h
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
        CheckNextRow:
            MOV DL, matriz[SI]
            INT 21h
        CheckEndOfRow:
            MOV DL, 124
            INT 21h

            INC CL
            INC SI

            CMP CL, 8
            JB columna

            MOV CL, 0
            INC BX
            CMP BX, 8
            JB fila
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

CrearArchivo MACRO nombreArchivo, handler
    LOCAL ManejarError, FinCrearArchivo
    MOV AH, 3Ch ; REG LLAMADA
    MOV CX, 00h ; AT
    LEA DX, nombreArchivo ; nombre puntajes.txt
    INT 21h

    MOV handler, AX ; HANDLER
    RCL BL, 1
    AND BL, 1
    CMP BL, 1
    JE ManejarError
    JMP FinCrearArchivo

    ManejarError:
        Print salto
        Print errorCrearArchivo
        getOpcion opcion
    ;si si esta bien
    FinCrearArchivo:
ENDM

AbrirArchivo MACRO nombreArchivo, handler
    LOCAL ManejarError, FinAbrirArchivo
    MOV BL, 0

    MOV AH, 3Dh ; codigo de interrupcion
    MOV AL, 00h ; modo de apertura del archivo, 0 -> Lectura | 1 -> Escritura | 2 -> Lectura/Escritura
    LEA DX, nombreArchivo ; Nombre del archivo
    INT 21h

    MOV handler, AX ; Capturar el handler asignado al archivo (16 bits)
    RCL BL, 1
    CMP BL, 1
    JE ManejarError
    JMP FinAbrirArchivo

    ManejarError:
        Print salto
        Print errorAbrirArchivo
        getOpcion opcion

    FinAbrirArchivo:
ENDM

CerrarArchivo MACRO handler
    LOCAL ManejarError, FinCerrarArchivo

    MOV AH, 3Eh ; Codigo de interrupcion
    MOV BX, handler ; handler del archivo
    INT 21h

    RCL BL, 1
    AND BL, 1
    CMP BL, 1
    JE ManejarError
    JMP FinCerrarArchivo

    ManejarError:
        Print salto
        Print errorCerrarArchivo
        getOpcion opcion

    FinCerrarArchivo:
ENDM

LeerArchivo MACRO buffer, handler
    LOCAL ManejarError, FinLeerArchivo

    MOV AH, 3Fh ; Codigo de interrupcion
    MOV BX, handler ; handler del archivo
    MOV CX, 300 ; Cantidad de bytes que se van a leer
    LEA DX, buffer ; Posicion en memoria del buffer donde se almacenara el texto leido
    INT 21h

    MOV BL, 0
    RCL BL, 1
    CMP BL, 1
    JE ManejarError
    JMP FinLeerArchivo

    ManejarError:
        Print salto
        Print errorLeerArchivo
        getOpcion opcion
    
    FinLeerArchivo:
ENDM

EscribirArchivo MACRO cadena, handler
    LOCAL ManejarError, FinEscribirArchivo

    MOV AH, 40h ; Codigo de interrupcion
    MOV BX, handler ; Handler de archivo
    MOV CX, 120 ; Cantidad de bytes que se van a escribir
    LEA DX, cadena1 ; Direccion de la cadena a escribir
    INT 21h

    RCL BL, 1 ; Capturar el bit de CF en el registro BL
    AND BL, 1 ; Validar que en BL quede un 1 o 0
    CMP BL, 1 ; Verificar si no hay codigo de error
    JE ManejarError
    JMP FinEscribirArchivo

    ManejarError:
        Print salto
        Print errorEscribirArchivo
        getOpcionOpcion opcion
    
    FinEscribirArchivo:
ENDM

PosicionarApuntador MACRO handler
    MOV AH, 42h ; Codigo Interrupcion
    MOV AL, 02h ; Modo de posicionamiento
    MOV BX, handler ; handler archivo
    MOV CX, 00h ; offset mas significativo
    MOV DX, 00h ; offset menos significativo
    INT 21h

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
    mensajeMenu db "l -->(1) Nuevo Juego                    l", 10, 13, "l -->(2) Puntajes                       l", 10, 13, "l -->(3) Reportes                       l", 10, 13, "l -->(4) Salir                          l", 10, 13, " --->>>>> Seleccione del menu: ", "$"
    msg1 db 10, 13, 10, 13, "Ingrese la fila: ", "$"
    msg2 db 10, 13, "Ingrese la columna: ", "$"
    matriz db 64 dup(32)
    columnas db "  A B C D E F G H","$"
    filas db "12345678","$"
    msgSalida db "Saliendo Del Programa...", "$"
    msgEFila db 10, 13, "La Fila Ingresada Es Incorrecta", "$"
    msgEColumna db 10, 13, "La Columna Ingresada Es Incorrecta", "$"
    opcionContinuar db 1 dup("$")
    opcion db 1 dup("$")
    row db 1 dup("$")
    col db 1 dup("$")
    ;-----------------
    handlerArchivo dw ? ; Handler o manejador del archivo de 16 bits
    nombreArchivo db "puntaje.txt", 00h ; Nombre del archivo, DEBE TERMINAR EN CARACTER NULO
    errorCrearArchivo db "Ocurrio Un Error Al Crear El Archivo", "$"
    errorAbrirArchivo db "Ocurrio Un Error Al Abrir El Archivo", "$"
    errorCerrarArchivo db "Ocurrio Un Error Al Cerrar Archivo", "$"
    errorLeerArchivo db "Ocurrio Un Error Al Leer Archivo", "$"
    errorEscribirArchivo db "Ocurrio Un Error Al Escribir Archivo", "$"
    contentArchivo db "Este es un texto de prueba para escribir en los archivos"
    archivoCreado db 10, 13, "El Archivo Se Creo Correctamente", "$"
    buffer db 300 dup("$") ; Buffer para almacenar el contenido leido de un archivo

.CODE
    MOV AX, @data
    MOV DS, AX

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
            JE ImprimirPuntajes
            
            ;-------------------------------
            CMP opcion, 51 ; 3 - REPORTES
            JE ImprimirReportes
            
            ;-----------------------------
            CMP opcion, 52 ; 4 - SALIR
            JE Salir
            
        JUEGO:
            LimpiarConsola
            ImprimirBoard
            Print salto
            JMP PedirOpcionFila
            JMP Menu

        PedirOpcionFila:
            Print msg1
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


        AuxSalir: 
            JMP Salir

        ImprimirReportes:
            CrearArchivo nombreArchivo, handlerArchivo
            CMP opcion, 13  
            JE AuxSalir

            PosicionarApuntador handler
            EscribirArchivo contentArchivo, handlerArchivo
            CMP opcion, 13  ; Verificar que no hay ningun error
            JE AuxSalir4

            CerrarArchivo handlerArchivo
            CMP opcion, 13  ; Verificar que no hay ningun error
            JE AuxSalir4
            JMP ContinuarArchivos
        
        AuxSalir4:
            JMP Salir

        ContinuarArchivos:
            Print archivoCreado
            getOpcion opcion

            AbrirArchivo nombreArchivo, handlerArchivo
            CMP opcion, 13  ; Verificar que no hay ningun error
            JE AuxSalir4

            LeerArchivo buffer, handlerArchivo
            CMP opcion, 13  ; Verificar que no hay ningun error
            JE Salir

            CerrarArchivo handlerArchivo
            CMP opcion, 13 
            JE Salir

        Salir:
            Print buffer
            MOV AX, 4C00h 
            INT 21h
    Main ENDP
END