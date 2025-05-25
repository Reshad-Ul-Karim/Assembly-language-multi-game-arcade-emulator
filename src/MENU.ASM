.MODEL SMALL
.STACK 100h

.DATA
    MENU_TITLE    DB 13,10, '=== My Menu ===', 13,10, '$'
    MENU_ITEM_1   DB '1. Rapid Roll Game', 13,10, '$'
    MENU_ITEM_2   DB '2. Space Car', 13,10, '$'
    MENU_ITEM_3   DB '3. Option 3', 13,10, '$'
    MENU_ITEM_4   DB '4. Exit', 13,10, '$'
    MENU_PROMPT   DB 'Select an option (1-4): $'
    ERROR_MESSAGE DB 13,10, 'Invalid input. Please try again.', 13,10, '$'
    RR_PATH       DB 'RR.EXE', 0
    SPACECAR_PATH DB 'SPACECAR.EXE', 0

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

MENU_LOOP:
    ; Clear screen
    MOV AH, 0
    MOV AL, 3
    INT 10H

    ; Display menu
    LEA DX, MENU_TITLE
    MOV AH, 9
    INT 21H

    LEA DX, MENU_ITEM_1
    MOV AH, 9
    INT 21H

    LEA DX, MENU_ITEM_2
    MOV AH, 9
    INT 21H

    LEA DX, MENU_ITEM_3
    MOV AH, 9
    INT 21H

    LEA DX, MENU_ITEM_4
    MOV AH, 9
    INT 21H

    LEA DX, MENU_PROMPT
    MOV AH, 9
    INT 21H

    ; Get user input (with echo)
    MOV AH, 1
    INT 21H

    ; AL now has the ASCII code of the key pressed
    CMP AL, '1'
    JE RUN_RR
    CMP AL, '2'
    JE RUN_SPACECAR
    CMP AL, '3'
    JE OPTION3
    CMP AL, '4'
    JE EXIT_MENU

    ; Invalid input
    LEA DX, ERROR_MESSAGE
    MOV AH, 9
    INT 21H
    JMP MENU_LOOP

RUN_RR:
    MOV AH, 4Bh
    MOV AL, 0
    LEA DX, RR_PATH
    MOV AX, @DATA
    MOV ES, AX
    XOR BX, BX
    INT 21H
    JMP MENU_LOOP

RUN_SPACECAR:
    MOV AH, 4Bh
    MOV AL, 0
    LEA DX, SPACECAR_PATH
    MOV AX, @DATA
    MOV ES, AX
    XOR BX, BX
    INT 21H
    JMP MENU_LOOP

OPTION3:
    ; Placeholder for Option 3
    JMP MENU_LOOP

EXIT_MENU:
    MOV AH, 4Ch
    INT 21H

END START
