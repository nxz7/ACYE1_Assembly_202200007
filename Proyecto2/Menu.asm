LimpiarConsola MACRO
    MOV AX, 03h
    INT 10h
ENDM

PrintCadena MACRO cadena
    MOV AH, 09h
    LEA DX, cadena
    INT 21h
ENDM

CrearCadena MACRO valor, cadena
    LOCAL CICLO, DIVBASE, SALIRCC, ADDZERO, ADDZERO2

    CICLO:
        MOV DX, 0
        MOV CX, valor
        CMP CX, base
        JB DIVBASE

        MOV BX, base
        MOV AX, valor
        DIV BX
        MOV cadena[SI], AL
        ADD cadena[SI], 48
        INC SI

        MUL BX
        SUB valor, AX

        CMP base, 1
        JE SALIRCC
        
        DIVBASE:
            CMP valor, 0
            JE ADDZERO

            MOV AX, base
            MOV BX, 10
            DIV BX
            MOV base, AX
            JMP CICLO
            
            ADDZERO:
                MOV cadena[SI], 48
                INC SI
    SALIRCC:
ENDM

OpenFile MACRO
    LOCAL ErrorToOpen, ExitOpenFile
    MOV AL, 2
    MOV DX, OFFSET filename + 2
    MOV AH, 3Dh
    INT 21h

    JC ErrorToOpen

    MOV handlerFile, AX
    PrintCadena salto
    PrintCadena exitOpenFileMsg
    JMP ExitOpenFile

    ErrorToOpen:
        MOV errorCode, AL
        ADD errorCode, 48

        PrintCadena salto
        PrintCadena errorOpenFile

        MOV AH, 02h
        MOV DL, errorCode
        INT 21h

    ExitOpenFile:
ENDM

CloseFile MACRO handler
    LOCAL ErrorToClose, ExitCloseFile
    MOV AH, 3Eh
    MOV BX, handler
    INT 21h

    JC ErrorToClose

    PrintCadena salto
    PrintCadena exitCloseFileMsg
    JMP ExitCloseFile

    ErrorToClose:
        MOV errorCode, AL
        ADD errorCode, 48

        PrintCadena salto
        PrintCadena errorCloseFile

        MOV AH, 02h
        MOV DL, errorCode
        INT 21h
    
    ExitCloseFile:
ENDM

ReadCSV MACRO handler, buffer
    LOCAL LeerByte, ErrorReadCSV, ExitReadCSV

    MOV BX, handler
    MOV CX, 1
    MOV DX, OFFSET buffer

    LeerByte:
        MOV AX, 3F00h
        INT 21h

        JC ErrorReadCSV

        INC DX
        MOV SI, DX
        SUB SI, 1

        SUB SI, OFFSET buffer

        CMP buffer[SI], 2Ch
        JNE LeerByte
        
        PUSH BX
        ConvertirNumero
        MOV DX, OFFSET buffer

        PUSH CX
        PUSH DX

        obtenerPosApuntador handler, 1, posApuntador

        POP DX
        POP CX
        POP BX
        MOV AX, posApuntador

        CMP extensionArchivo, AX
        JBE ExitReadCSV
        JMP LeerByte

    ErrorReadCSV:
        MOV errorCode, AL
        ADD errorCode, 48

        PrintCadena salto
        PrintCadena errorReadFile

        MOV AH, 02h
        MOV DL, errorCode
        INT 21h

    ExitReadCSV:
ENDM

ConvertirNumero MACRO
    LOCAL DosDigitosNum, FinConvertirNumero
    XOR AX, AX
    XOR BX, BX

    MOV DI, 0
    CMP SI, 2
    JNE UnDigitoNum

    DosDigitosNum:
        MOV AL, numCSV[DI]
        SUB AL, 48
        MOV BL, 10
        MUL BL
        INC DI

    UnDigitoNum:
        MOV BL, numCSV[DI]
        SUB BL, 48
        ADD AL, BL

    FinConvertirNumero:
        XOR BX, BX
        MOV BX, indexDatos
        MOV bufferDatos[BX], AL
        INC BX
        MOV indexDatos, BX

        MOV BX, numDatos
        INC BX
        MOV numDatos, BX
ENDM

GetSizeFile MACRO handler
    LOCAL ErrorGetSize, ExitGetSize
    obtenerPosApuntador handler, 2, extensionArchivo
    JC ErrorGetSize

    MOV extensionArchivo, AX
    obtenerPosApuntador handler, 0, posApuntador
    JC ErrorGetSize

    PrintCadena salto
    PrintCadena exitSizeFileMsg
    JMP ExitGetSize

    ErrorGetSize:
        MOV errorCode, AL
        ADD errorCode, 48

        PrintCadena salto
        PrintCadena errorSizeFile

        MOV AH, 02h
        MOV DL, errorCode
        INT 21h

    ExitGetSize:
ENDM

obtenerPosApuntador MACRO handler, posActual, bufferPos
    MOV AH, 42h
    MOV AL, posActual
    MOV BX, handler
    MOV CX, 0
    MOV DX, 0
    INT 21h

    MOV bufferPos, AX
ENDM

PedirCadena MACRO buffer
    LEA DX, buffer
    MOV AH, 0Ah
    INT 21h

    XOR BX, BX
    MOV SI, 2
    MOV BL, filename[1]
    ADD SI, BX
    MOV filename[SI], 0
ENDM

OrderData MACRO
    LOCAL for1, for2, Intercambio, terminarFor2
    XOR AX, AX
    XOR CX, CX
    XOR DX, DX

    MOV CX, numDatos
    DEC CX
    MOV DL, 0
    for1:
        PUSH CX

        MOV CX, numDatos
        DEC CX
        SUB CX, DX
        MOV BX, 0
        for2:
            MOV AL, bufferDatos[BX]
            MOV AH, bufferDatos[BX + 1]
            CMP AL, AH
            JA Intercambio
            INC BX
            LOOP for2
            JMP terminarFor2

            Intercambio:
                XCHG AL, AH
                MOV bufferDatos[BX], AL
                MOV bufferDatos[BX + 1], AH
                INC BX

            LOOP for2

        terminarFor2:
            POP CX
            INC DL
            LOOP for1
ENDM

Promedio MACRO
    LOCAL Sumatoria, CicloDecimal, ContinuarProm
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX

    MOV CX, numDatos
    Sumatoria:
        MOV DL, bufferDatos[BX]
        ADD AX, DX
        INC BX
        MOV DX, 0
        LOOP Sumatoria
    
    MOV DX, 0
    MOV BX, numDatos
    DIV BX
    MOV entero, AX
    MOV decimal, DX
    MOV SI, 0

    CrearCadena entero, cadenaResult

    MOV cadenaResult[SI], 46
    INC SI

    CMP decimal, 0
    JNE CicloDecimal

    MOV cadenaResult[SI], 48
    INC SI
    MOV cadenaResult[SI], 48
    JMP ContinuarProm

    CicloDecimal:
        MOV AX, decimal
        MOV BX, 10
        MOV DX, 0
        MUL BX

        MOV BX, numDatos
        MOV DX, 0
        DIV BX

        MOV decimal, DX
        MOV entero, AX
        CrearCadena entero, cadenaResult
        MOV AL, cantDecimal
        INC AL
        MOV cantDecimal, AL
        CMP AL, 2
        JNE CicloDecimal

    ContinuarProm:
        MOV cantDecimal, 0
        PrintCadena salto
        PrintCadena msgPromedio
        PrintCadena cadenaResult
ENDM


Maximo MACRO
    XOR AX, AX
    MOV BX, numDatos
    DEC BX
    MOV AL, bufferDatos[BX]
    MOV entero, AX
    MOV SI, 0

    CrearCadena entero, cadenaResult
    MOV cadenaResult[SI], 46
    INC SI
    MOV cadenaResult[SI], 48
    INC SI
    MOV cadenaResult[SI], 48
    INC SI
    MOV cadenaResult[SI], 36

    PrintCadena salto
    PrintCadena msgMaximo
    PrintCadena cadenaResult
ENDM

Minimo MACRO
    XOR AX, AX
    MOV AL, bufferDatos[0]
    MOV entero, AX
    MOV SI, 0

    CrearCadena entero, cadenaResult
    MOV cadenaResult[SI], 46
    INC SI
    MOV cadenaResult[SI], 48
    INC SI
    MOV cadenaResult[SI], 48
    INC SI
    MOV cadenaResult[SI], 36

    PrintCadena salto
    PrintCadena msgMinimo
    PrintCadena cadenaResult
ENDM

Mediana MACRO
    LOCAL CalcPromedio, ExitCalcMediana, CicloDecimal
    XOR AX, AX
    XOR BX, BX
    XOR DX, DX

    MOV AX, numDatos
    MOV BX, 2
    DIV BX

    MOV BX, AX

    CMP DX, 0
    JZ CalcPromedio
    
    XOR DX, DX
    MOV DL, bufferDatos[BX]
    MOV entero, DX
    MOV SI, 0

    CrearCadena entero, cadenaResult

    MOV cadenaResult[SI], 46
    INC SI
    MOV cadenaResult[SI], 48
    INC SI
    MOV cadenaResult[SI], 48
    INC SI
    MOV cadenaResult[SI], 36
    JMP ExitCalcMediana

    CalcPromedio:
        XOR AX, AX
        DEC BX
        ADD AL, bufferDatos[BX]
        ADD AL, bufferDatos[BX + 1]
        MOV DX, 0
        MOV BX, 2
        DIV BX
        MOV entero, AX
        MOV decimal, DX
        MOV SI, 0

        CrearCadena entero, cadenaResult

        MOV cadenaResult[SI], 46
        INC SI

        CMP decimal, 0
        JNE CicloDecimal

        MOV cadenaResult[SI], 48
        INC SI
        MOV cadenaResult[SI], 48
        INC SI
        MOV cadenaResult[SI], 36
        JMP ExitCalcMediana

        CicloDecimal:
            MOV AX, decimal
            MOV BX, 10
            MOV DX, 0
            MUL BX

            MOV BX, 2
            MOV DX, 0
            DIV BX

            MOV decimal, DX
            MOV entero, AX
            CrearCadena entero, cadenaResult
            MOV AL, cantDecimal
            INC AL
            MOV cantDecimal, AL
            CMP AL, 2
            JNE CicloDecimal

    ExitCalcMediana:
        MOV cantDecimal, 0
        PrintCadena salto
        PrintCadena msgMediana
        PrintCadena cadenaResult

ENDM

ContadorDatos MACRO
    XOR AX, AX
    MOV AX, numDatos
    MOV entero, AX
    MOV SI, 0

    CrearCadena entero, cadenaResult

    MOV cadenaResult[SI], 36

    PrintCadena salto
    PrintCadena msgContadorDatos
    PrintCadena cadenaResult
ENDM

BuildTablaFrecuencias MACRO
    LOCAL forDatos, saveFrecuencia, ExitModa
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR SI, SI

    MOV CX, numDatos
    MOV AH, bufferDatos[BX]
    forDatos:
        CMP AH, bufferDatos[BX]
        JNE saveFrecuencia

        INC AL
        INC BX
        LOOP forDatos

        MOV tablaFrecuencias[SI], AH
        INC SI
        MOV tablaFrecuencias[SI], AL
        INC SI 

        JMP ExitModa

        saveFrecuencia:
            MOV tablaFrecuencias[SI], AH
            INC SI
            MOV tablaFrecuencias[SI], AL
            INC SI

            MOV AH, numEntradas
            INC AH
            MOV numEntradas, AH

            MOV AH, bufferDatos[BX]
            MOV AL, 0
        
        JMP forDatos

    ExitModa:
ENDM

OrderFrecuencies MACRO
    LOCAL for1, for2, Intercambio, terminarFor2
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX

    MOV CL, numEntradas
    DEC CX
    MOV DL, 0
    for1:
        PUSH CX

        MOV CL, numEntradas
        DEC CX
        SUB CX, DX
        MOV SI, 0
        for2:
            MOV AH, tablaFrecuencias[SI]
            MOV AL, tablaFrecuencias[SI + 1]
            MOV BH, tablaFrecuencias[SI + 2]
            MOV BL, tablaFrecuencias[SI + 3]

            CMP AL, BL
            JA Intercambio
            ADD SI, 2
            LOOP for2
            JMP terminarFor2

            Intercambio:
                XCHG AX, BX
                MOV tablaFrecuencias[SI], AH
                MOV tablaFrecuencias[SI + 1], AL
                MOV tablaFrecuencias[SI + 2], BH
                MOV tablaFrecuencias[SI + 3], BL
                ADD SI, 2

            LOOP for2
        
        terminarFor2:
            POP CX
            INC DL
            LOOP for1

ENDM

Moda MACRO
    LOCAL CicloModa, ExitCalcModa
    XOR AX, AX
    XOR BX, BX
    MOV AL, numEntradas
    MOV BL, 2
    MUL BL
    MOV DI, AX
    DEC DI

    CicloModa:
        XOR AX, AX
        XOR BX, BX

        MOV AL, tablaFrecuencias[DI] ; ? Frecuencia
        DEC DI
        MOV BL, tablaFrecuencias[DI] ; ? Valor
        DEC DI
        
        PUSH AX
        MOV entero, BX
        MOV SI, 0
        MOV base, 10000
        CrearCadena entero, cadenaResult
        MOV cadenaResult[SI], 36

        PrintCadena salto
        PrintCadena msgModa1
        PrintCadena cadenaResult
        POP AX
        MOV entero, AX
        
        PUSH AX
        MOV SI, 0
        MOV base, 10000

        CrearCadena entero, cadenaResult
        MOV cadenaResult[SI], 36

        PrintCadena salto
        PrintCadena msgModa2
        PrintCadena cadenaResult

        POP AX
        
        CMP AL, tablaFrecuencias[DI]
        JA ExitCalcModa
        JMP CicloModa

    ExitCalcModa:
ENDM

PrintTablaFrecuencias MACRO
    LOCAL tabla, ExitPrintTabla
    PrintCadena salto
    PrintCadena msgEncabezadoTabla
    PrintCadena salto

    XOR AX, AX
    XOR BX, BX
    MOV AL, numEntradas
    MOV CX, AX
    MOV BL, 2
    MUL BL
    MOV DI, AX
    DEC DI

    tabla:
        PUSH CX
        XOR AX, AX
        XOR BX, BX

        MOV AL, tablaFrecuencias[DI]
        DEC DI
        MOV BL, tablaFrecuencias[DI]  
        DEC DI

        PUSH AX
        MOV entero, BX
        MOV SI, 0
        MOV base, 10000
        CrearCadena entero, cadenaResult
        MOV cadenaResult[SI], 36
        PrintCadena espacios
        PrintCadena cadenaResult

        POP AX
        MOV entero, AX
        
        MOV SI, 0
        MOV base, 10000
        CrearCadena entero, cadenaResult
        MOV cadenaResult[SI], 36
        PrintCadena espacios

        MOV AH, 2
        MOV DL, 124
        INT 21h

        PrintCadena espacios
        PrintCadena cadenaResult
        PrintCadena salto

        POP CX
        DEC CX
        CMP CX, 0
        JE ExitPrintTabla
        JMP tabla

    ExitPrintTabla:
ENDM

getOpcion MACRO regOpcion
    MOV AH, 01h
    INT 21h

    MOV regOpcion, AL
ENDM

.MODEL small
.STACK 64h
.DATA

    mensajeInicio db "PROYECTO 2 ::::::::: 1S 2024 ", 10, 13, "$"
    mensajeDatos db " Abrir Archivo (a)", 10, 13, "promedio(p)", 10, 13, "mediana(m)", 10, 13, "contador(c)", 10, 13, "$"

    mensajeDatosDos db  "moda(o)", 10, 13, "max(x)",10,13,"min(n)",10,13,"TablaFrec (f)", 10, 13, "Limpiar(l)", 10, 13, "$"

    mensajeDatosTres db  "Reporte(r)", 10, 13, "info(i)",10,13,"salir(s)",10,13, "$"



    mensajeSeparacion db "========================================", 10, 13, "$"
;INFO
    infoUno db " Arquitectura de computadores y ensambladores 1", 10, 13," SECCION A", 10, 13, "$"
    infoDos db " PRIMER SEMESTRE 2024", 10, 13, " Natalia Mariel Calderon Echeverria", 10, 13, " ----> 202200007 - PROYECTO 2", 10, 13, "$"
;----

    opcion db 1 dup("$")

    handlerArchivohtml dw ?
  
    buffer db 300 dup("$")

;----------
    handlerFile         dw ?
    filename            db 30 dup(32)
    bufferDatos         db 300 dup (?)
    errorCode           db ?
    errorOpenFile       db "Ocurrio Un Error Al Abrir El Archivo - ERRCODE: ", "$"
    errorCloseFile      db "Ocurrio Un Error Al Cerrar El Archivo - ERRCODE: ", "$"
    errorReadFile       db "Ocurrio Un Error Al Leer El CSV - ERRCODE: ", "$"
    errorSizeFile       db "Ocurrio Un Error Obteniendo El Size Del Archivo - ERRCODE: ", "$"
    exitOpenFileMsg     db "El Archivo Se Abrio Correctamente", "$"
    exitCloseFileMsg    db "El Archivo Se Cerro Correctamente", "$"
    exitSizeFileMsg     db "Se Obtuvo La Longitud Correctamente", "$"
    msgToRequestFile    db "Ingrese El Nombre Del Archivo CSV: ", "$"
    msgPromedio         db "El Promedio De Los Datos Es: ", "$"
    msgMaximo           db "El Valor Maximo De Los Datos Es: ", "$"
    msgMinimo           db "El Valor Minimo De Los Datos Es: ", "$"
    msgMediana          db "El Valor De la Mediana De Los Datos Es: ", "$"
    msgContadorDatos    db "El Total De Datos Utilizados Ha Sido De: ", "$"
    msgModa1            db "La Moda De Los Datos Es: ", "$"
    msgModa2            db "Con Una Frecuencia De: ", "$"
    msgEncabezadoTabla  db "-> Valor    -> Frecuencia", "$"
    salto               db 10, 13, "$"
    espacios            db 32, 32, 32, 32, 32, "$"
    numCSV              db 3 dup(?)
    cadenaResult        db 6 dup("$")
    tablaFrecuencias    db 100 dup(?)
    numEntradas         db 1
    indexDatos          dw 0
    extensionArchivo    dw 0
    posApuntador        dw 0
    numDatos            dw 0
    base                dw 10000
    entero              dw ?
    decimal             dw ?
    cantDecimal         db 0

.CODE
    MOV AX, @data
    MOV DS, AX
    call Main
; aumentar

    ; se imprime todo
    Main PROC
        LimpiarConsola
        PrintCadena mensajeSeparacion
            PrintCadena mensajeInicio
            PrintCadena mensajeSeparacion
            PrintCadena mensajeDatos
            PrintCadena mensajeDatosDos
            PrintCadena mensajeDatosTres
            PrintCadena mensajeSeparacion

        Menu:

; Abrir Archivo (a)", 10, 13, "promedio(p)", 10, 13, "media(m)
;mediana(M)", 10, 13, "moda(o)", 10, 13, "TablaFrec (f)

            getOpcion opcion ; OPCION
            CMP opcion, 97 ; Abrir el archivo(a)
            JE AbrirAux
            ;--------------------------------
            CMP opcion, 112 ; promedio(p)
            JE Promedioaux
            ;-------------------------------
            CMP opcion, 109 ; mediana (m)
            JE MedianaAux
            ;----------------------------
            CMP opcion, 99 ; contador(c)
            JE ContadorAux
            ;--------------------------------
            CMP opcion, 111 ; moda(o)
            JE ModaAux
            ;--------------------------------
            CMP opcion, 120 ; max(x)
            JE MaxAux
            ;--------------------------------
            CMP opcion, 110 ; min(n)
            JE MinAux
;-----------------------------------------
            CMP opcion, 108 ; limpiar(l)
            JE LimpiarAux
            ;--------------------------------
            CMP opcion, 102 ; tabla frec(f)
            JE TablaAux
            ;--------------------------------
            CMP opcion, 114 ; reporte(r)
            JE ReporteAux
            ;--------------------------------
            CMP opcion, 105 ; info(i)
            JE InfoAux
            ;-----------------------------
            CMP opcion, 115 ;  SALIR (s)
            JE SalirAux

        AbrirAux:
        JMP AbrirL

        Promedioaux:
        JMP PromedioL

        MedianaAux:
        JMP MedianaL

        ContadorAux:
        JMP ContadorL

        ModaAux:
        JMP ModaL

        MaxAux:
        JMP MaxL

        MinAux:
        JMP MinL

        LimpiarAux:
        LimpiarConsola
        JMP Menu

        TablaAux:
        JMP TablaL

        ReporteAux:
        JMP ReporteL

        InfoAux:
        JMP InfoL

        SalirAux:
        JMP Salir

;-----------------abrir-------
        AbrirL:
        PrintCadena msgToRequestFile
        PedirCadena filename

        ; * Extraer Informacion Del CSV
        OpenFile
        GetSizeFile handlerFile
        ReadCSV handlerFile, numCSV
        CloseFile handlerFile

        ; * Ordenar Datos - Ordenamiento Burbuja
        OrderData

        JMP Menu
;-------------------prom---------
    PromedioL:
        Promedio
        MOV base, 10000

    JMP Menu
;-------------------mediana------
        MedianaL:
        Mediana
        MOV base, 10000
        JMP Menu
 ;-------------------contador---------       
        ContadorL:
        ContadorDatos
        MOV base, 10000

        JMP Menu
;-------------------moda
        ModaL:
        BuildTablaFrecuencias
        OrderFrecuencies
        MOV base, 10000
        Moda
        MOV base, 10000
        JMP Menu
;------------------Maximo
        MaxL:
        Maximo
        MOV base, 10000
        JMP Menu
;------------------Min
        MinL:
        Minimo
        MOV base, 10000
        JMP Menu
;-------------------limpiar

;-------------------tabla
        TablaL:
        PrintTablaFrecuencias
        JMP Menu

;--------------------reporte

        ReporteL:
PrintCadena mensajeSeparacion
        JMP Menu

;--------------------infor
        InfoL:
            PrintCadena mensajeSeparacion
            PrintCadena infoUno
            PrintCadena infoDos
            PrintCadena mensajeSeparacion
        JMP Menu

;-----------------------
        Salir:
            MOV AX, 4C00h 
            INT 21h
    Main ENDP
END