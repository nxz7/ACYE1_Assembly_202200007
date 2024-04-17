Totito MACRO
    LOCAL Barra1, Barra2, Barra3, Barra4, SalirTablero
    XOR AX, AX
    XOR CX, CX
    XOR DX, DX

    MOV AL, 7
    MOV CX, 105
    MOV DX, 0
    MOV AH, 0Ch
    
    Barra1:
        INT 10h
        
        INC DX
        INC DX
        
        CMP DX, 200
        JB Barra1
        
        INC CX
        
        CMP CX, 110
        JA ContinuarBarra2
        MOV DX, 0
        JMP Barra1
        
    ContinuarBarra2:
        MOV CX, 210
        MOV DX, 0
        
    Barra2:
        INT 10h
        
        INC DX
        INC DX
        
        CMP DX, 200
        JB Barra2
        
        INC CX
        
        CMP CX, 215
        JA ContinuarBarra3
        MOV DX, 0
        JMP Barra2

    ContinuarBarra3:
        MOV CX, 0
        MOV DX, 60

    Barra3:
        INT 10h

        INC CX

        CMP CX, 320
        JB Barra3

        INC DX
        INC DX

        CMP DX, 65
        JA ContinuarBarra4
        MOV CX, 0
        JMP Barra3


    ContinuarBarra4:
        MOV CX, 0
        MOV DX, 125

    Barra4:
        INT 10h

        INC CX

        CMP CX, 320
        JB Barra4

        INC DX

        CMP DX, 130
        JA SalirTablero
        MOV CX, 0
        JMP Barra4

    SalirTablero:
ENDM

PPX MACRO
    LOCAL Ciclo1, Ciclo2
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX

    MOV BL, colMov
    MOV CL, lugarColumna[BX]

    MOV BL, filaMov
    MOV DL, posicionesFila[BX]

    MOV AL, 6
    MOV AH, 0Ch
    MOV BL, 0

    Ciclo1:
        INT 10h

        INC CX
        INC DX
        INC BL
        CMP BL, 30
        JNE Ciclo1

    MOV BL, colMov
    MOV CL, lugarColumna[BX]
    ADD CL, 30

    MOV BL, filaMov
    MOV DL, posicionesFila[BX]

    MOV BL, 0

    Ciclo2:
        INT 10h

        DEC CX
        INC DX
        INC BL
        CMP BL, 30
        JNE Ciclo2
ENDM

PPO MACRO
    LOCAL Part1, Part2, Part3, Part4
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX

    MOV AL, 5
    MOV AH, 0Ch

    MOV BL, colMov
    MOV CL, lugarColumna[BX]
    
    MOV BL, filaMov
    MOV DL, posicionesFila[BX]

    MOV BL, 0

    Part1:
        INT 10h

        INC CX
        INC BL
        CMP BL, 31
        JNE Part1

    MOV BL, colMov
    MOV CL, lugarColumna[BX]

    MOV BL, 0

    Part2:
        INT 10h

        INC DX
        INC BL
        CMP BL, 31
        JNE Part2

    MOV BL, colMov
    MOV CL, lugarColumna[BX]
    ADD CL, 30
    
    MOV BL, filaMov
    MOV DL, posicionesFila[BX]
    ADD DL, 30

    MOV BL, 0

    Part3:
        INT 10h

        DEC CX
        INC BL
        CMP BL, 31
        JNE Part3

    MOV BL, colMov
    MOV CL, lugarColumna[BX]
    ADD CL, 30

    MOV BL, 0

    Part4:
        INT 10h

        DEC DX
        INC BL
        CMP BL, 31
        JNE Part4
ENDM

PedirMovimiento MACRO
    MOV AX, 03h
    INT 10h

    MOV Ah, 09h
    LEA DX, pedirFila
    INT 21h

    MOV AH, 1
    INT 21h

    SUB AL, 49
    MOV filaMov, AL

    MOV Ah, 09h
    LEA DX, salto
    INT 21h

    MOV Ah, 09h
    LEA DX, pedirColumna
    INT 21h

    MOV AH, 1
    INT 21h

    SUB AL, 49
    MOV colMov, AL
ENDM

LimpiarConsola MACRO
    MOV AX, 03h 
    INT 10h        

    MOV AH, 05h             ; UNA DE OCHO PAGINAS
    MOV AL, paginaActual    
    INT 10h
ENDM

Retardo MACRO valor
    MOV AH, 86h
    MOV CX, valor
    INT 15h
ENDM


PrintCadena MACRO fila, columna, pagina, longitud, cadena, color
    MOV AL, 1           
    MOV BH, pagina      
    MOV BL, color       
    MOV CX, longitud    
    MOV DL, columna     
    MOV DH, fila        
    MOV BP, cadena      
    MOV AH, 13h
    INT 10h
ENDM

LeerKeyboardBuffer MACRO
    LOCAL AlmacenarTecla, Continuar, TeclaDer, TeclaIzq, TeclaSpace
    MOV AH, 01h     
    INT 16h
    JNZ AlmacenarTecla  ; 0=tecla disp
    JMP Continuar       

    AlmacenarTecla:
        MOV CX, 0       ; ciclo

        CMP AH, 4Dh  
        JE TeclaDer

        CMP AH, 4Bh    
        JE TeclaIzq

        CMP AH, 39h   ; bios space
        JE TeclaSpace
        JMP Continuar    

        TeclaDer:   
            ADD paginaActual, 1
            JMP Continuar

        TeclaIzq:   
            SUB paginaActual, 1
            JMP Continuar

        TeclaSpace: 
            MOV paginaActual, 8
            JMP Continuar

    Continuar:
        MOV AH, 0Ch 
        MOV AL, 00h 
        INT 21h
ENDM


Animacion1 MACRO
    LOCAL Ciclo, PrintArt, TerminarCiclo
    MOV CX, 21 

    Ciclo:
        PUSH CX 
        MOV saltoCadena, OFFSET cadena1 
                                        
        
        MOV CX, 7 
        PrintArt:
            PUSH CX 
            PrintCadena filaActual, 11, 0, 31, saltoCadena, 2 
            INC DH  
            MOV filaActual, DH


            
            MOV AX, saltoCadena
            ADD AX, 31
            MOV saltoCadena, AX


            POP CX      
            LOOP PrintArt ; loooooooooooop

        Retardo 2 ; delay

        POP CX  
        DEC CX  

        LeerKeyboardBuffer

        MOV AL, fila        
        INC AL
        MOV filaActual, AL
        MOV fila, AL

        ; ! SI SE PASA DE LOS SALTOS
        CMP CX, 0 
        JE TerminarCiclo 
        LimpiarConsola  
        JMP Ciclo 

    TerminarCiclo:  
ENDM

Animacion2 MACRO
    LOCAL Ciclo, PrintArt, TerminarCiclo
    MOV CX, 24

    Ciclo:
        MOV filaActual, 8
        PUSH CX
        MOV saltoCadena, OFFSET cadena1

        MOV CX, 7
        PrintArt:
            PUSH CX
            PrintCadena filaActual, columna, 1, 31, saltoCadena, 5
            INC DH
            MOV filaActual, DH
            MOV AX, saltoCadena
            ADD AX, 31
            MOV saltoCadena, AX
            POP CX
            LOOP PrintArt

        Retardo 2

        POP CX
        DEC CX

        LeerKeyboardBuffer

        MOV AL, columna
        INC AL
        MOV columna, AL
        
        CMP CX, 0
        JE TerminarCiclo
        LimpiarConsola
        JMP Ciclo

    TerminarCiclo:
ENDM

Animacion3 MACRO
    LOCAL Ciclo, PrintArt, TerminarCiclo
    MOV CX, 21

    MOV fila, 0
    MOV filaActual, 0
    MOV columna, 0

    Ciclo:
        PUSH CX
        MOV saltoCadena, OFFSET cadena1

        MOV CX, 7
        PrintArt:
            PUSH CX
            PrintCadena filaActual, columna, 2, 31, saltoCadena, 14
            INC DH
            MOV filaActual, DH
            MOV AX, saltoCadena
            ADD AX, 31
            MOV saltoCadena, AX
            POP CX
            LOOP PrintArt

        Retardo 2

        POP CX
        DEC CX

        LeerKeyboardBuffer

        MOV AL, columna
        INC AL
        MOV columna, AL
        
        MOV AL, fila
        INC AL
        MOV fila, AL
        MOV filaActual, AL

        CMP CX, 0
        JE TerminarCiclo
        LimpiarConsola
        JMP Ciclo

    TerminarCiclo:
ENDM

Animacion4 MACRO
    LOCAL Ciclo, PrintArt, TerminarCiclo
    MOV CX, 21

    MOV fila, 24
    MOV filaActual, 24
    MOV columna, 0

    Ciclo:
        PUSH CX
        MOV saltoCadena, OFFSET cadena7

        MOV CX, 7
        PrintArt:
            PUSH CX
            PrintCadena filaActual, columna, 3, 31, saltoCadena, 6
            DEC DH
            MOV filaActual, DH
            MOV AX, saltoCadena
            SUB AX, 31
            MOV saltoCadena, AX
            POP CX
            LOOP PrintArt

        Retardo 2

        POP CX
        DEC CX

        LeerKeyboardBuffer

        MOV AL, columna
        INC AL
        MOV columna, AL
        
        MOV AL, fila
        DEC AL
        MOV fila, AL
        MOV filaActual, AL

        CMP CX, 0
        JE TerminarCiclo
        LimpiarConsola
        JMP Ciclo

    TerminarCiclo:
ENDM




Animacion5 MACRO
    LOCAL Ciclo, PrintArt, TerminarCiclo
    MOV CX, 21

    MOV fila, 24
    MOV filaActual, 24
    MOV columna, 11

    Ciclo:
        PUSH CX
        MOV saltoCadena, OFFSET cadena7

        MOV CX, 7
        PrintArt:
            PUSH CX
            PrintCadena filaActual, 11, 4, 31, saltoCadena, 3
            DEC DH
            MOV filaActual, DH
            MOV AX, saltoCadena
            SUB AX, 31
            MOV saltoCadena, AX
            POP CX
            LOOP PrintArt

        Retardo 2

        POP CX
        DEC CX

LeerKeyboardBuffer

        MOV AL, fila
        DEC AL
        MOV filaActual, AL
        MOV fila, AL

        CMP CX, 0
        JE TerminarCiclo
        LimpiarConsola
        JMP Ciclo

    TerminarCiclo:
ENDM

Animacion6 MACRO
    LOCAL Ciclo, PrintArt, TerminarCiclo
    MOV CX, 24


    MOV columna, 24

    Ciclo:
        MOV filaActual, 8
        PUSH CX
        MOV saltoCadena, OFFSET cadena1

        MOV CX, 7
        PrintArt:
            PUSH CX
            PrintCadena filaActual, columna, 5, 31, saltoCadena, 11
            INC DH
            MOV filaActual, DH
            MOV AX, saltoCadena
            ADD AX, 31
            MOV saltoCadena, AX
            POP CX
            LOOP PrintArt

        Retardo 2

        POP CX
        DEC CX

        LeerKeyboardBuffer

        MOV AL, columna
        DEC AL
        MOV columna, AL
        
        CMP CX, 0
        JE TerminarCiclo
        LimpiarConsola
        JMP Ciclo

    TerminarCiclo:
ENDM

Animacion7 MACRO
    LOCAL Ciclo, PrintArt, TerminarCiclo
    MOV CX, 21

    MOV fila, 24
    MOV filaActual, 24
    MOV columna, 24

    Ciclo:
        PUSH CX
        MOV saltoCadena, OFFSET cadena7

        MOV CX, 7
        PrintArt:
            PUSH CX
            PrintCadena filaActual, columna, 6, 31, saltoCadena, 14
            DEC DH
            MOV filaActual, DH
            MOV AX, saltoCadena
            SUB AX, 31
            MOV saltoCadena, AX
            POP CX
            LOOP PrintArt

        Retardo 2

        POP CX
        DEC CX

        LeerKeyboardBuffer

        MOV AL, columna
        DEC AL
        MOV columna, AL
        
        MOV AL, fila
        DEC AL
        MOV fila, AL
        MOV filaActual, AL

        CMP CX, 0
        JE TerminarCiclo
        LimpiarConsola
        JMP Ciclo

    TerminarCiclo:
ENDM

Animacion8 MACRO
    LOCAL Ciclo, PrintArt, TerminarCiclo
    MOV CX, 21

    MOV fila, 0
    MOV filaActual, 0
    MOV columna, 24

    Ciclo:
        PUSH CX
        MOV saltoCadena, OFFSET cadena1

        MOV CX, 7
        PrintArt:
            PUSH CX
            PrintCadena filaActual, columna, 7, 31, saltoCadena, 14
            INC DH
            MOV filaActual, DH
            MOV AX, saltoCadena
            ADD AX, 31
            MOV saltoCadena, AX
            POP CX
            LOOP PrintArt

        Retardo 2

        POP CX
        DEC CX

        LeerKeyboardBuffer

        MOV AL, columna
        DEC AL
        MOV columna, AL
        
        MOV AL, fila
        INC AL
        MOV fila, AL
        MOV filaActual, AL

        CMP CX, 0
        JE TerminarCiclo
        LimpiarConsola
        JMP Ciclo

    TerminarCiclo:
ENDM


.MODEL small

.STACK 100h

.DATA
cadena1 db "             _   _             "
cadena2 db"           (.)_(.)             "
cadena3 db"        _ (   _   ) _          "
cadena4 db"       / \/`-----'\/ \         "
cadena5 db"     __\ ( (     ) ) /__        "
cadena6 db"     )   /\ \._./ /\   (        "
cadena7 db"      )_/ /|\   /|\ \_(         "
Menu1 db" .___  ___.  _______ .__   __.  __    __ "
Menu2 db"|   \/   | |   ____||  \ |  | |  |  |  |"
Menu3 db"|  \  /  | |  |__   |   \|  | |  |  |  |"
Menu4 db"|  |\/|  | |   __|  |  . `  | |  |  |  |"
Menu5 db"|  |  |  | |  |____ |  |\   | |  `--'  |"
Menu6 db"|__|  |__| |_______||__| \__|  \______/ "

op1 db"------> Nuevo Juego <------"
op2 db"------> Animacion   <------"
op3 db"------> Informacion <------"
op4 db"------> Salir       <------"

txt1 db"------> op 1 <------"
txt2 db"------> op 2 <------"
txt3 db"------> op 3 <------"
txt4 db"------> op 4 <------"


inf1 db "                   _   _           _ _  "
inf2 db "  _ __ _ _ __ _ __| |_(_)__ __ _  | | | "
inf3 db " | '_ \ '_/ _` / _|  _| / _/ _` | |_  _|"
inf4 db " | .__/_| \__,_\__|\__|_\__\__,_|   |_| "
inf5 db " |_|                                    "


dato1 db "UNIVERSIDAD DE SAN CARLOS DE GUATEMALA"
dato2 db "FACULTAD DE INGENIERIA                "
dato3 db "ESCUELA CIENCIAS Y SISTEMAS           "
dato4 db "ARQUITECTURA DE COMP Y ENSAMBLADORES 1"
dato5 db "PRIMER SEMESTRE 2024                  "
dato6 db "NATALIA MARIEL CALDERON ECHEVERRIA    "
dato7 db "202200007                             "

    fila db 0
    filaActual db 0
    columna db 0
    saltoCadena dw ?
    paginaActual db 0


    lugarColumna db 35, 145, 250
    posicionesFila db 15, 80, 150

    filaMov db 0
    colMov db 0

    salto db 10, 13, "$"
    pedirFila db ">>> fila (1-3): ", "$"
    pedirColumna db ">>> columna(1-3): ", "$"
    turno db 0

.CODE

    MOV AX, @data
    MOV DS, AX
    MOV ES, AX

    LimpiarConsola
    MostrarMenu:

    Main PROC
        MOV saltoCadena, OFFSET Menu1
        PrintCadena 1, 11, 0, 41, saltoCadena, 2 
        MOV saltoCadena, OFFSET Menu2
        PrintCadena 2, 11, 0, 41, saltoCadena, 2 
        MOV saltoCadena, OFFSET Menu3
        PrintCadena 3, 11, 0, 41, saltoCadena, 2 
        MOV saltoCadena, OFFSET Menu4
        PrintCadena 4, 11, 0, 41, saltoCadena, 2 
        MOV saltoCadena, OFFSET Menu5
        PrintCadena 5, 11, 0, 41, saltoCadena, 2 
        MOV saltoCadena, OFFSET Menu6
        PrintCadena 6, 11, 0, 41, saltoCadena, 2 

        ;---------------------------------------------
        MOV saltoCadena, OFFSET op1
        PrintCadena 7, 11, 0, 27, saltoCadena, 6 
        MOV saltoCadena, OFFSET op2
        PrintCadena 8, 11, 0, 27, saltoCadena, 6 
        MOV saltoCadena, OFFSET op3
        PrintCadena 9, 11, 0, 27, saltoCadena, 6 
        MOV saltoCadena, OFFSET op4
        PrintCadena 10, 11, 0, 27, saltoCadena, 6 
        
        ; INPUT
        Mov ah, 01h
        Int 21h

        ; LA TECLA
        CMP AL, '1'
        JE Option1Aux
        CMP AL, '2'
        JE Option2Aux
        CMP AL, '3'
        JE Option3Aux
        CMP AL, '4'
        JE Option4Aux

        ; MENU
        JMP MostrarMenu

    Option1Aux:
    Retardo 8
LimpiarConsola
    JMP Option1

    Option2Aux:
    Retardo 8
LimpiarConsola
    JMP Option2

    Option3Aux:
    Retardo 8
LimpiarConsola
    JMP Option3

    Option4Aux:
    Retardo 8
LimpiarConsola
    JMP Option4

    Option1:
        LimpiarConsola
        MOV saltoCadena, OFFSET txt1
        PrintCadena 11, 5, 0, 13, saltoCadena, 2
        JMP Tablero

        JMP MostrarMenu
        
        Tablero:
            PedirMovimiento

            MOV AL, 13h
            MOV AH, 00h
            INT 10h

            Totito

            CMP turno, 0
            JE Pintar_X

            CMP turno, 1
            JE Pintar_O

            Pintar_X:
                PPX
                MOV AL, turno
                INC AL
                MOV turno, AL
                JMP SeguirTablero

            Pintar_O:
                PPO
                MOV AL, turno
                DEC AL
                MOV turno, AL

            SeguirTablero: 
                MOV AH, 10h
                INT 16h

                MOV AL, 03h
                MOV AH, 00h
                INT 10h

            JMP MostrarMenu

    Option2:
        LimpiarConsola

        MOV saltoCadena, OFFSET txt2
        PrintCadena 11, 5, 0, 13, saltoCadena, 2
        LimpiarConsola
;-----------------------ANIMACION
        Ciclo: 
            MOV fila, 0
            MOV filaActual, 0
            MOV columna, 0
            
            CMP paginaActual, 0 ; * Salto A Pagina 1
            JZ EtAnimacion1Aux

            CMP paginaActual, 1 ; * Salto A Pagina 2
            JZ EtAnimacion2Aux

            CMP paginaActual, 2 ; * Salto A Pagina 3
            JZ EtAnimacion3Aux

            CMP paginaActual, 3 ; * Salto A Pagina 4
            JZ EtAnimacion4Aux

            CMP paginaActual, 4 ; * Salto A Pagina 1
            JZ EtAnimacion5Aux

            CMP paginaActual, 5 ; * Salto A Pagina 2
            JZ EtAnimacion6Aux

            CMP paginaActual, 6 ; * Salto A Pagina 3
            JZ EtAnimacion7Aux

            CMP paginaActual, 7 
            JZ EtAnimacion8Aux

            ;JMP MostrarMenu   

            EtAnimacion1Aux:    
                JMP EtAnimacion1
            EtAnimacion2Aux:
                JMP EtAnimacion2
            EtAnimacion3Aux:
                JMP EtAnimacion3
            EtAnimacion4Aux:
                JMP EtAnimacion4
           EtAnimacion5Aux:    
                JMP EtAnimacion5
            EtAnimacion6Aux:
                JMP EtAnimacion6
            EtAnimacion7Aux:
                JMP EtAnimacion7
            EtAnimacion8Aux:
                JMP EtAnimacion8

            
            EtAnimacion1:
                Animacion1
                JMP Ciclo

            EtAnimacion2:
                Animacion2
                JMP Ciclo

            EtAnimacion3:
                Animacion3
                JMP Ciclo

            EtAnimacion4:
                Animacion4
                JMP Ciclo

            EtAnimacion5:
                Animacion5
                JMP Ciclo

            EtAnimacion6:
                Animacion6
                JMP Ciclo

            EtAnimacion7:
                Animacion7
                JMP Ciclo

            EtAnimacion8:
                Animacion8
                JMP Ciclo    


    Option3:
        ; LIMPIARRRRR
        LimpiarConsola

        MOV saltoCadena, OFFSET txt3
        PrintCadena 11, 5, 0, 13, saltoCadena, 6

        MOV saltoCadena, OFFSET inf1
        PrintCadena 12, 11, 0, 40, saltoCadena, 6 
        MOV saltoCadena, OFFSET inf2
        PrintCadena 13, 11, 0, 40, saltoCadena, 6 
        MOV saltoCadena, OFFSET inf3
        PrintCadena 14, 11, 0, 40, saltoCadena, 6 
        MOV saltoCadena, OFFSET inf4
        PrintCadena 15, 11, 0, 40, saltoCadena, 6 
        MOV saltoCadena, OFFSET inf5
        PrintCadena 16, 11, 0, 40, saltoCadena, 6 
;------------------info mia
        MOV saltoCadena, OFFSET dato1
        PrintCadena 17, 11, 0, 38, saltoCadena, 14 
        MOV saltoCadena, OFFSET dato2
        PrintCadena 18, 11, 0, 38, saltoCadena, 14 
        MOV saltoCadena, OFFSET dato3
        PrintCadena 19, 11, 0, 38, saltoCadena, 14 
        MOV saltoCadena, OFFSET dato4
        PrintCadena 20, 11, 0, 38, saltoCadena, 14 
        MOV saltoCadena, OFFSET dato6
        PrintCadena 21, 11, 0, 38, saltoCadena, 14 
        MOV saltoCadena, OFFSET dato7
        PrintCadena 22, 11, 0, 38, saltoCadena, 14

        
        JMP MostrarMenu

    Option4:
        
        LimpiarConsola
        MOV AX, 4C00h
        INT 21h

    Main ENDP

END