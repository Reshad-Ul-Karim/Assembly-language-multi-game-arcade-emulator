; AUTHOR: Reshad

;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
; STACK Segment
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================
STACKS    SEGMENT PARA STACK
	db      64 DUP('DADA007 ')              ; 8 * 64 = 512 bytes, used to track stack usage
STACKS    ENDS                                    ; If more than 512 bytes are used, the 'DADA007 ' text will be erased
						; Maximum for each Segment is 64kbytes

;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
; VARIABLES Segment
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================
DATAS    SEGMENT PARA
; Strings printed on screen during program execution
; Note: 13 = carriage return, 10 = line feed
		mex1    db      '                         ----> S P A C E - C A R <----',13,10,'$' ; 30 CHARACTERS -> 25 SPACES ON LEFT TO CENTER
		mex2    db      ' The game consists of avoiding asteroids and collecting as many coins',13,10,'$'
		mex2b   db      ' as possible to create a new RECORD!',13,10,'$'
		mex3    db      ' Use arrow keys (Right and Left) to move',13,10,'$'
		mex4    db      ' Hearts are lives, you can accumulate up to 5',13,10,'$'
		mex5    db      ' Once you run out of lives, the game ends',13,10,'$'
		mex6    db      ' Up/Down Arrow:  Increase/Decrease level (speed)',13,10,'$'
		mEsc    db      ' ESC:             Exit game immediately',13,10,'$'
		mPausa  db      ' P:               Pause the game',13,10,'$'
		mInitialiser db      ' Press ENTER to start the race',13,10,'$'

		cInitialiser db      '                                   ','$'        ; Used to clear mInitialiser without clearing the screen
		lescape   db      'Press ENTER to return to DOS  ','$'

		lPause  db      'PAUSE                              ','$'
		lLose   db      'GAME OVER                          ','$'
		lWin    db      'You reached the maximum score!','$'

		fScore  db      'Final score: ','$'
		fLife   db      'Remaining lives: ','$'

		lDead   db      'YOU CRASHED INTO AN ASTEROID!','$'
		llkey  db      'Press a key to continue    ','$'
		lEnter  db      'Press ENTER to continue       ','$'

		mLife   db      'LIFE: ','$'
		mLevel  db      'LEVEL: ','$'
		mScore  db      'SCORE: ','$'

		lLife   db      '+1 LIFE     ','$'
		lScore  db      '+1 SCORE    ','$'
		lLevelU db      '+1 LEVEL    ','$'
		lLevelD db      '-1 LEVEL    ','$'
		life    dw      3       ; Initial number of lives
		level   dw      1       ; Starting level
		score   dw      0H      ; Starting score
		tLevel  dw      10H     ; Cycles at first level (16 = 10H)

		maxScore dw     1000     ; Maximum score to end the game

		lempty  db      '                   ','$'

	; Variables for random number generation
		PrimoIN  DB     00H           ; First execution flag (= 0 yes; <> 0 no)
		Rnd_Lo   DW     ?             ; Current 32-bit random number value
		Rnd_Hi   DW     ?
		CONSTANT DW     8405H         ; Multiplier value

DATAS    ENDS






;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;PROGRAM Segment
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================
_prog    SEGMENT  PARA 'CODE'    ;Code Segment, Stack Segment and Data Segment allocation
	ASSUME  CS:_prog,        SS:STACKS,        DS:DATAS        ;ASSUME forces correct segment use for all segment symbols
	ORG 0100H       ;leave first 100H locations free
	initialiser: JMP     Main    ;start from Main label

	;=========================================================================================================
	;KEYS (CONSTANTS)
	;=========================================================================================================
	kESC    EQU     1bh             ;ESC key
	kEnter  EQU     0dh             ;ENTER key
	kUp     EQU     4800h           ;up arrow movement
	kDown    EQU     5000h           ;down arrow movement
	kRight     EQU     4d00h           ;right arrow movement
	kLeft     EQU     4b00h           ;left arrow movement
	limDX   EQU     27              ;right limit for spaceship (right frame column)
	limSX   EQU     2               ;left limit for spaceship (left frame column)

;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;MACROS
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================
setCur MACRO row,column       ;Macro that chooses where to position the Cursor
	PUSH DX
	MOV DH,row             ;row
	MOV DL,column          ;column
	CALL posCur             ;calls posCur procedure - INT10H 02H that positions cursor
	POP DX
ENDM
;=========================================================================================================
stpChrT MACRO char              ;prints in TTY mode (updates cursor)
	PUSH AX
	MOV AL,char             ;choose character passed as parameter
	CALL writeTTY           ;calls procedure
	POP AX
ENDM
;=========================================================================================================
stpChrC MACRO char,num,col      ;prints n colored characters
	PUSH AX
	PUSH CX
	MOV AL,char             ;choose character passed as parameter
	MOV CX,num
	MOV BL,col
	CALL writeCOL           ;calls procedure
	POP CX
	POP AX
ENDM
;=========================================================================================================
stpChrBN MACRO char             ;prints a character in Black and White
	PUSH AX
	MOV AL,char             ;choose character passed as parameter
	CALL writeBN            ;calls procedure
	POP AX
ENDM
;=========================================================================================================
Random  MACRO num       ;remember to do a PUSH AX if necessary
			;EX: num=10 random number goes from 0 to 9
	MOV AX,num      ;puts in Random procedure input the AX value
	CALL rand
ENDM
;=========================================================================================================
stpMex  MACRO mex       ;prints a message saved in memory (Data Segment)
	PUSH AX
	PUSH BX
	PUSH DX
	MOV AX,SEG DATAS
	MOV DS,AX
	MOV DX,OFFSET mex
	MOV AH,09H
	INT 21H
	POP DX
	POP BX
	POP AX
ENDM
;=========================================================================================================
delayer MACRO tick      ;creates a delay (1 tick = 0.55 ms -> 18H ticks = 1 second)
	PUSH CX
	MOV CX,tick
	CALL delay      ;calls delay procedure based on clock
	POP CX
ENDM
;=========================================================================================================

;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;START OF THE PROGRAM
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================

;NB:    in DX will save the position of the spaceship
;       in BX will save the obstacle/coin/life (BL=Type)  x=asteroid, v=life, m=coin
;       CX is the cycle counter

Main:           CALL cls        ;clear screen
		setCur 0,0
		stpMex mex1     ;print the instructions on the screen
		setCur 2,0
		stpMex mex2
		stpMex mex2b
		stpMex mex3
		stpMex mex4
		stpMex mex5
		stpMex mex6
		stpMex mEsc
		stpMex mPausa
		setCur 11,1
		stpMex llkey
		CALL outCur
		CALL waitKey    ;wait for a key to continue

Start:          ;every time you hit an asteroid, you start over from here
		CALL cls        ;clear screen
		CALL WBORDER     ;draw border

	;PRINT THE LIVES
		setCur 4,40
		stpMex mLife
		setCur 4,50
		stpChrC 03H,life,04H    ;print the hearts

	;PRINT THE LEVEL
		setCur 6,40
		stpMex mLevel
		setCur 6,50
		stpChrC 09H,level,09H   ;print the dots (which represent the level number)

	;PRINT THE SCORE
		setCur 8,40
		stpMex mScore
		setCur 8,50
		MOV AX,score
		CALL word2dec           ;print the score


	;POSITION THE SPACESHIP AT THE BOTTOM CENTER
		MOV DH,20       ;row
		MOV DL,14       ;column
		CALL setCar     ;position the spaceship


		setCur 15,40    ;AREA WHERE MESSAGES ARE PRINTED
		stpMex mInitialiser  ;start of the level, waits for an enter
		CALL outCur
reqEnter:       CALL waitKey    ;wait for the ENTER key
		CMP AL,kEnter
		JNE reqEnter
		setCur 15,40
		stpMex cInitialiser


		;CALL outCur    ;hide the cursor
		MOV BX,0000H    ;initialize each cycle the obstacle/life/coin controller
cycle:          MOV CH,BYTE PTR tLevel   ;set the initial level (speed)
		MOV CL,0        ;initialize the cycle counter to increment


		CMP CH,CL       ;if I have changed level and
		JBE Continue3   ;CH is less than or equal to CL -> I start the cycle again
				;if I don't put this control the program can get stuck
				;for example if CL is 0AH and CH has reached 0BH while I have changed the level
				;JBE = jump below or equal

		PUSH DX
		setCur 15,40    ;delete the interactive message
		stpMex lempty   ;of the previous cycle
		POP DX
		CMP BL,'m'      ;if I took a coin, increase the score
		 JE addMon
		CMP BL,'v'
		 JE ADDLIFE     ;if I took a heart, increase the lives (unless they are already 5)

Continue3:      JMP AspKey

addMon:         PUSH AX         ;I took a coin
		 MOV AX,score   ;I could also directly "INC score"
		 ;INC AX         ;increase the score
		 ADD AX,level    ;instead of increasing by 1 unit, I add the level value
		 MOV score,AX
		 setCur 8,50    ;position the cursor in the SCORE area:
		 CALL word2dec  ;print the ascii/decimal value of the score variable
		 setCur 15,40   ;position the cursor in the MESSAGES area
		 stpMex lScore  ;write +1 SCORE
		POP AX
		MOV BX,0000H    ;initialize obstacle/life/coin controller
		JMP AspKey

ADDLIFE:        CMP life,5      ;I took a heart
		JAE life5       ;if lives are greater than or equal to 5 then do not add more lives
		PUSH AX
		 MOV AX,life
		 INC AX         ;increase the life variable
		 MOV life,AX
		 setCur 4,50    ;position the cursor in the LIFE area:
		 stpChrC 03H,life,04H   ;print as many red hearts as lives
		 setCur 15,40   ;position the cursor in the MESSAGES area
		 setCur 4,50    ;position the cursor in the LIFE area:
		 stpChrC 03H,life,04H   ;print as many red hearts as lives
		 setCur 15,40   ;position the cursor in the MESSAGES area
		 stpMex lLife   ;write +1 LIFE
		POP AX
life5:          MOV BX,0000H    ;initialize the obstacle/life/coin controller
		JMP AspKey


AspKey:
		CMP BL,'x'      ;check if I hit an asteroid
		JE Dead2        ;if hit -> go to Dead2
		CALL setCar     ;check if I hit an obstacle or collected a coin/life and position the spaceship
		delayer 01H     ;18 "waits" per second
		INC CL          ;increment the 18 waits counter
		CMP CL,CH       ;If CL=CH then we are at the end of the cycle (18 waits have passed if the cycle is one second)
		JE Continue2    ;move down a line
		CALL pressKey   ;otherwise check if a key is pressed
		JZ AspKey        ;if no key is pressed, wait again
		 CALL waitKey    ;otherwise check which key was pressed
		 CMP AL,kESC     ;press ESC
		 JE  exitGame2       ;exit to DOS
		 CMP AL,'P'      ;press P
		 JE I_Pause      ;put the game in Pause
		 CMP AL,'p'      ;press p (lowercase)
		 JE I_Pause      ;put the game in Pause
		 CMP AX,kRight      ;press Right arrow - kRight EQU 4D00H
		 JE moveRight2
		 CMP AX,kLeft      ;press Left arrow - kLeft EQU 4B00H
		 JE moveLeft2
		 CMP AX,kUp      ;press Up arrow
		 JE moveUp2
		 CMP AX,kDown     ;press Down arrow
		 JE moveDown2
		 ;CMP AL,'h'      ;INCREASE SCORE BY 100
		 ;JE HintA2
		 ;CMP AL,'H'      ;DECREASE SCORE BY 100
		 ;JE HintB2
		 JMP keyTest2      ;go to print the pressed key


;----------labels for too long JUMPs-------------
;Win2:           JMP Win
Dead2:          JMP Dead
moveRight2:        JMP moveRight
moveLeft2:      JMP moveLeft
exitGame2:          JMP exitGame
Continue2:      JMP Continue
keyTest2:         JMP keyTest
moveUp2:            JMP moveUp
moveDown2:           JMP moveDown
;HintA2:         JMP HintA
;HintB2:         JMP HintB
;AspKey2:        JMP AspKey
;------------labels for too long JUMPs-----------


;-----PAUSE Management------------------------------
I_Pause:        PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		setCur 15,40    ;WRITE "PAUSE" in the MESSAGES area
		stpMex lPause
Pause:          CALL waitKey    ;wait for a key
		CMP AL,kESC     ;ESC key
		JE exitGame2         ;go to exitGame
		CMP AL,'P'      ;P key
		JE F_Pause       ;End the Pause
		CMP AL,'p'      ;p key
		JE F_Pause       ;End the Pause
		JMP Pause       ;otherwise continue the pause -> loop Pause
F_Pause:        setCur 15,40    ;ERASE the "PAUSE" text
		stpMex lempty
		POP DX
		POP CX
		POP BX
		POP AX
		JMP AspKey      ;go to AspKey
;-----PAUSE Management-------------------------------

AspKey2:        JMP AspKey

moveRight:         ;move the spaceship to the right
		CMP DL,limDX    ;check if the spaceship has reached the right edge
		JE AspKey2      ;if it has reached the right limit and I want to move it further right, the program blocks it there
		 INC DX         ;otherwise I can move it one character to the right
		 PUSH DX
		 SUB DX,2       ;move the cursor to the area where the spaceship was before moving right
		 CALL posCur
		 stpChrBN ' '   ;put a ' ' character to the left where the spaceship was before
		 POP DX
	;print control characters
		;PUSH DX
		;setCur 21,35
		;stpChrBN 'R'
		;setCur 21,36
		;stpChrBN CL
		;POP DX
	;end print control characters
		JMP AspKey      ;wait for the next key

moveLeft:       ;move the spaceship to the left
		CMP DL,limSX    ;check if the spaceship has reached the left edge
		JE AspKey2      ;if it has reached the left limit and I want to move it further left, the program blocks it there
		 DEC DX         ;otherwise I can move it one character to the left
		 PUSH DX
		 ADD DX,2       ;move the cursor to where the spaceship was before being moved left
		 CALL posCur
		 stpChrBN ' '   ;put a ' ' character where the spaceship was before
		 POP DX
	;print control characters
		;PUSH DX
		;setCur 21,35
		;stpChrBN 'L'
		;setCur 21,36
		;stpChrBN CL
		;POP DX
	;end print control characters
		JMP AspKey      ;wait for the next key

moveUp:             ;up one level
		CMP level,8     ;check if we are at level 8
		JAE level8      ;if the level is greater than or equal to 8 then do not add more levels
		 PUSH AX
		 MOV AX,level   ;otherwise add a level
		 INC AX
		 MOV level,AX
		  MOV AX,tLevel ;decrease the cycle duration by 2 ticks
		  SUB AX,2
		  MOV tLevel,AX
		 setCur 6,50    ;position the cursor in the LEVEL area:
		 stpChrC 09H,level,09H  ;print the number of levels (blue dots)
		 setCur 15,40   ;position the cursor in the MESSAGES area
		 stpMex lLevelU ;print +1 LEVEL
		POP AX
level8:          MOV BX,0000H    ;initialize the obstacle/life/coin controller
		JMP aspKey

moveDown:            ;down one level
		CMP level,1
		JBE level1  ;if the level is less than or equal to 1 then do not lower the level
		PUSH AX
		 MOV AX,level
		 DEC AX     ;otherwise decrement the level
		 MOV level,AX
		  MOV AX,tLevel ;increase the cycle duration by 2 ticks
		  ADD AX,2
		  MOV tLevel,AX
		 setCur 6,50
		 stpMex lempty  ;erase the previous levels to print fewer dots than before (otherwise the level decrement is not noticeable)
		 setCur 6,50    ;position the cursor in the LEVEL area:
		 stpChrC 09H,level,09H  ;print the level number (blue dots)
		 setCur 15,40   ;position the cursor in the MESSAGES area
		 stpMex lLevelD ;write -1 LEVEL
		POP AX
level1:          MOV BX,0000H    ;initialize the obstacle/life/coin controller
		JMP aspKey


keyTest:          ;if I press any key, it does nothing
		;I leave the label in case I want to use other keys in the future
		;or I want the program to do something with generic keys
		;print control characters
		;PUSH DX
		;setCur 20,35
		;stpChrBN AL
		;POP DX
		JMP AspKey

Continue:       CALL GODOWN      ;make the obstacles "descend" one line
		;now draw the new obstacles/life/coin (with different probabilities)
		Random 99      ;random number between 0 and 99 (100 total numbers)
		CMP AX,95
		 JAE LIFE        ;greater than or equal to 95 -> life (5% probability)
		CMP AX,25
		 JB COIN      ;less than 25 -> coin (25% probability)
		CALL wOst       ;otherwise -> print an obstacle (the remaining 73% probability)
		JMP Next

LIFE:           CALL wLife      ;print a life
		JMP Next
COIN:         CALL wMon       ;print a coin
		JMP Next

Dead:           ;PUSH AX
		;MOV AX,life
		;DEC AX
		;MOV life,AX
		;POP AX
		DEC life        ;decrement a life
		CMP life,0      ;if life is zero -> Game Over
		JE Lose
		 CALL setCar    ;otherwise restart the game with one less life
		 PUSH DX
		 setCur 4,50            ;position the cursor in the LIFE area:
		 stpChrC 03H,life,04H   ;update the number of hearts
		 setCur 15,40           ;position the cursor in the MESSAGES area
		 stpMex lDead           ;print the message "You hit an asteroid"
		 setCur 16,40
		 stpMex lEnter          ;print "Press enter to continue"
		 POP DX

aspEnter:        CALL waitKey           ;wait for the ENTER key
		CMP AL,kEnter           ;to restart the game with one less life
		JNE aspEnter
		JMP Start


Next:           CALL outCur     ;hide the cursor

		PUSH AX         ;check if I reached the maximum score
		MOV AX,maxScore ;I cannot compare two variables
		CMP score,AX    ;so I put one of them in AX
		POP AX
		JAE Win

		JMP cycle       ;continue with the Loop and go to the cycle label

Lose:           ;CALL cls
		PUSH DX
		setCur 15,40    ;position the cursor in the MESSAGES area
		stpMex lLose    ;write GAME OVER
		POP DX
		CALL setCar
		JMP Exit

Win:            PUSH DX
		setCur 15,40
		stpMex lWin
		POP DX
		CALL setCar

Exit:           setCur 17,40
		stpMex fScore   ;print the final score
		setCur 17,59    ;score value area
		PUSH AX
		MOV AX,score
		CALL word2dec   ;decimal value of the score
		POP AX
		;POP DX
		CALL waitKey    ;wait for a key


exitGame:           setCur 19,40
		stpMex lescape    ;print the exit message
WAITENTER:        CALL waitKey    ;wait for enter to exit
		CMP AL,kEnter
		JNE WAITENTER
		CALL cls
		CALL tornaDOS   ;call the procedure to return to DOS


;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;PROCEDURES
;---------------------------------------------------------------------------------------------------------
;============================================================================
WBORDER PROC NEAR        ;draws the game border
		;PRINT TOP ROW
		setCur 0,0      ;position cursor at top left
		stpChrT 0DAH    ;print top left corner
		MOV CX,28       ;set loop to 28 times (columns)
CYCLER1:        stpChrT 0C4H    ;print top line
		LOOP CYCLER1    ;until reaching column 29
		stpChrT 0BFH    ;where it prints top right corner

		;PRINT LEFT COLUMN
		MOV DH,01H      ;set row to 2
		MOV DL,00H      ;set column to 0 (fixed) - first column
		MOV CX,20       ;set loop to 20 times (rows)
CYCLEC1:        CALL posCur     ;position cursor at DH,DL (row,column)
		stpChrT 0B3H    ;print | character for left column
		inc DH          ;increase counter (move to next row)
		LOOP CYCLEC1    ;for 20 times

		;PRINT RIGHT COLUMN
		MOV DH,01H      ;set row to 2
		MOV DL,29       ;set column to 29 (fixed) - 30th column
		MOV CX,0020     ;set loop to 20 times (rows)
CYCLEC2:        CALL posCur     ;position cursor at DH,DL (row,column)
		stpChrT 0B3H     ;print | character for right column
		inc DH          ;increase counter (move to next row)
		LOOP CYCLEC2    ;for 20 times

		;PRINT BOTTOM ROW
		setCur 21,0     ;position cursor at row 22, column 0
		stpChrT 0C0H     ;print bottom left corner
		MOV CX,28     ;set loop to 28 times (columns)
CYCLER2:        stpChrT 0C4H     ;print line to create row
		LOOP CYCLER2    ;for 28 times
		stpChrT 0D9H     ;print bottom right corner

		;CREATED A 22 ROWS X 30 COLUMNS RECTANGLE

WBORDER  ENDP
;============================================================================
rand    PROC    NEAR        ;function that creates a random number between 0<n<AX
	OR      AX,AX           ;if the range value passed as parameter
	JNZ     Rand_1          ;is null, procedure ends immediately
	RET                     ;(incorrect value!)

Rand_1: PUSH    BX          ;Save registers used by procedure
	PUSH    CX
	PUSH    DX
	PUSH    DI
	PUSH    DS
	PUSH    AX              ;Save range value, passed as input
							;parameter (will be used at the end)
	LEA     DI,PrimoIN      ;Check if this is the first call
      CMP Byte Ptr DS:[DI],00H  ;of the procedure that generates the delay
	JNE     Rand_2          ;if NOT, calculate new value

	MOV     AH,2CH          ;If this is the first call, the procedure
	INT     21H             ;gets a random value from CMOS memory containing current time
	MOV     DS:[Rnd_Lo],CX  ;Uses DOS Function 2CH which
							;leaves in CH = Hours     (0-23)
							;               in CL = Minutes  (0-59)
							;       in DH = Seconds (0-59)
							;       in DL = Hundredths of seconds (0-99)
	MOV Byte Ptr DS:[DI],01H  ;Modifies first entry byte to avoid
							;reloading initial random variables

							;Instructions for first round
Rand_2: MOV     AX,DS:[Rnd_Lo]  ;AH=Hours     (0-23), AL=Minutes    (0-59)
	MOV     BX,DS:[Rnd_Hi]  ;BH=Seconds (0-59), BL=Hundredths (0-99)
	MOV     CX,AX           ;CH=Hours     (0-23), CL=Minutes    (0-59)

	MUL     DS:[CONSTANT]   ;AX*CONSTANT=AX*8405H=DX,AX (32-bit number)

	SHL     CX,1            ;Random number calculation algorithm
	SHL     CX,1
	SHL     CX,1
	ADD     CH,CL
	ADD     DX,CX
	ADD     DX,BX
	SHL     BX,1
	SHL     BX,1
	ADD     DX,BX
	ADD     DH,BL
	MOV     CL,5
	SHL     BX,CL
	ADD     AX,1
	ADC     DX,0

	MOV     DS:[Rnd_Lo],AX  ;Save 32-bit result of manipulation
	MOV     DS:[Rnd_Hi],DX  ;in variables intended for this purpose

	POP     BX              ;Recover in BX the range value, passed in
							;input, in AX
	XOR     AX,AX           ;Prepare 32-bit dividend by forcing to zero
	XCHG    AX,DX           ;the most significant 16 bits and copying into the 16
							;low bits the current value of DX
	DIV     BX              ;AX = quotient (DX,AX / BX)
							;DX = remainder
	XCHG    AX,DX           ;current random number is the remainder value
							;and is left, in output, in AX
	POP     DS
	POP     DI              ;Recover registers used by procedure
	POP     DX
	POP     CX
	POP     BX
	RET
rand  ENDP
;============================================================================
delay PROC NEAR         ;CX=18 for a 0.55ms*18 = 1second delay
	PUSH AX         ;save registers
	PUSH BX
	PUSH DX

	PUSH CX         ;the value of CX is put in BX
	POP BX          ;in BX is the value chosen as delay
	CALL clock      ;returns in CX,DX the system time (32bit)
	ADD DX,BX       ;add a total of TICK (CX) to DX (low part of time)
	JNC Delay_0     ;if no carry go to Delay_0
	INC CX          ;otherwise add carry to CX
Delay_0: PUSH CX        ;copy in AX,BX the tick count relative to the first read
	PUSH DX         ;AGGIORNED with the tick count corresponding to the desired DELAY
	POP BX          ;in practice in AX,BX is the future time to reach
	POP AX
Delay_1: PUSH AX        ;save in the stack the data of AX,BX (time to reach)
	PUSH BX
	CALL clock      ;save the data of the NEW read in CX,DX
	POP BX          ;and in AX,BX is always the data of the time to reach
	POP AX

	CMP AX,CX       ;compare the high part of the two times
	JZ Delay_2      ;if they are the same check the low part (Dela_2)
			;otherwise means (almost always) that they differ by the carry
	PUSH AX         ;save the high part
	SUB AX,CX       ;check if they differ, maybe by a different number from 1
	CMP AX,18H      ;because if the difference is 18H it's almost midnight
	POP AX
	JNZ Delay_1     ;if not midnight (difference < 18H) go back to Delay_1 to continue waiting

	PUSH BX         ;if midnight (difference 18H)
	SUB BX,00B0H    ;so CX,DX is passed from 0018-00AFH to 0000-0000H
	CMP BX,DX       ;so also the low part must be adjusted to the new situation
	POP BX
	JG Delay_1      ;if still greater BX,DX continue waiting
	JMP Delay_3     ;otherwise no more waiting - delay consumed!

Delay_2: CMP BX,DX      ;if the high part is the same and the low part of
	JG Delay_1      ;current time is less, BX>DX -> continue waiting

Delay_3: POP DX         ;the delay is consumed!
	POP BX
	POP AX

	RET             ;return

delay ENDP
;=========================================================================================================
wLife PROC NEAR         ;prints a random heart
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	Random 27       ;random column between 0 and 27 (puts the value in AX)
	INC AX          ;random column between 1 and 28 (within the border)
	setCur 1,AL     ;choose the low part of the random number (high part is always zero)
	MOV BH,0        ;video page 0
	MOV CX,1        ;print one character
	MOV AL,03H      ;choose the heart character
	MOV BL,04H      ;choose red on black color
	CALL PRINTER     ;print the character
	POP AX
	POP BX
	POP CX
	POP DX
	RET
wLife ENDP
;=========================================================================================================
wMon PROC NEAR       ;prints a random coin
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	Random 27       ;random column between 0 and 27 (puts the value in AX)
	INC AX          ;random column between 1 and 28 (within the border)
	setCur 1,AL     ;choose the low part of the random number (high part is always zero)
	MOV BH,0        ;video page 0
	MOV CX,1        ;print one character
	MOV AL,0FH      ;choose the coin (sun) character
	MOV BL,0EH      ;choose yellow on black color
	CALL PRINTER     ;print the character
	POP AX
	POP BX
	POP CX
	POP DX
	RET
wMon ENDP
;=========================================================================================================
wOst PROC NEAR       ;prints a random obstacle
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	Random 27       ;random column between 0 and 27 (puts the value in AX)
	INC AX          ;random column between 1 and 28 (within the border)
	setCur 1,AL     ;choose the low part of the random number (high part is always zero)
	MOV BH,0        ;video page 0
	MOV CX,1        ;print one character
	MOV AL,0B1H     ;choose the boulder character
	MOV BL,08H      ;choose gray on black color
	CALL PRINTER     ;print the character
	POP AX
	POP BX
	POP CX
	POP DX
	RET
wOst ENDP
;============================================================================
GODOWN PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	MOV AH,07H      ;function moves a part of the screen down
	MOV AL,01H      ;num rows
	MOV CH,1        ;row top left angle
	MOV CL,1        ;col top left angle
	MOV DH,20       ;row bottom right angle
	MOV DL,28       ;col bottom right angle
			;from 1,1 to 28,20 (in row 0 and 22 there is the frame)
	MOV BH,07H      ;color of empty rows black (DEFAULT 07H)
	INT 10H
	POP DX
	POP CX
	POP BX
	POP AX
	RET             ;returns
GODOWN ENDP
;=========================================================================================================
writeTTY PROC Near      ;AL=char,CX=num of times
	PUSH BX
	MOV BH,00H      ;Page 0
	MOV BL,70H      ;White on black
	MOV AH,0EH      ;Function 0EH of INT 10H (Prints one or more colored characters on the screen)
	INT 10H
	POP BX
	RET             ;returns
writeTTY ENDP
;=========================================================================================================
writeCOL PROC Near      ;AL=char,CX=num of times,BL=color
	MOV BH,00H      ;Page 0
	MOV AH,09H      ;Function 09H of INT 10H (Prints one or more colored characters on the screen)
	INT 10H
	RET             ;returns
writeCOL ENDP
;=========================================================================================================
writeBN PROC Near      ;AL=char,CX=num of times
	PUSH BX
	PUSH CX
	MOV BH,00H      ;Page 0
	MOV BL,70H      ;White on Black
	MOV CX,1        ;print ONE character
	MOV AH,0AH      ;Function 0AH of INT 10H (Prints one or more characters)
	INT 10H
	POP CX
	POP BX
	RET             ;returns
writeBN ENDP
;=========================================================================================================
PRINTER PROC    Near     ;AL=char,CX=num of times,BL=color
	MOV AH,09H      ;Function 09H of INT 10H (Prints CX colored characters on the screen)
	INT 10H
	RET                     ;returns
PRINTER ENDP
;=========================================================================================================
clock PROC NEAR         ;puts the current time in the registers:
	MOV AH,00H      ;CX=high part of the clock
	INT 1AH         ;DX=low part of the clock
	RET
clock ENDP
;=========================================================================================================
waitKey PROC NEAR       ;waits for a key
	MOV AH,00H      ;function 00H of INT 16H that waits for a key
	INT 16H
			;AL=ascii code, AH=scan code
	RET             ;returns
waitKey ENDP
;============================================================================
pressKey PROC NEAR
	MOV AH,01H      ;if key pressed, modifies ZERO FLAG
	INT 16H
	RET
pressKey ENDP
;============================================================================
posCur PROC    Near     ;Procedure that positions the cursor
	PUSH AX
	PUSH BX
	PUSH DX
	MOV BH,00H      ;video page 0 (the visible one)
	MOV AH,02H      ;function 02H of INT 10H that positions the cursor in DH,DL (row,column)
	INT 10H
	POP DX
	POP BX
	POP AX
	RET             ;returns
posCur ENDP
;============================================================================
setCar PROC NEAR        ;DH=row,DL=column
	PUSH AX
	PUSH CX
	PUSH DX
	MOV CX,0000H

	CALL posCur     ;position the cursor
	 CMP BX,0000H   ;if BX is zero then it has not yet touched anything
	 JNE asd1       ;skip the check
	 CALL checkCar   ;check if it has touched something
asd1:    CALL posCur
	stpChrBN 1EH    ;I can print the central character

	INC DX          ;I move to the right
	CALL posCur
	 CMP BX,0000H   ;if BX is zero then it has not yet touched anything
	 JNE asd2       ;skip the check
	 CALL checkCar
asd2:   CALL posCur
	stpChrBN '>'    ;print the character on the right

	SUB DX,2        ;I move 2 to the left
	CALL posCur
	 CMP BX,0000H   ;if BX is zero then it has not yet touched anything
	 JNE asd3       ;skip the check
	 CALL checkCar
asd3:   CALL posCur
	stpChrBN '<'    ;I can print the character on the left

	;PRINT CHARACTER TO CHECK
	;PUSH DX
	;setCur 18,60    ;print the obstacle that I touched
	;stpChrBN CH
	;POP DX

	CMP CH,'M'      ;I took a coin
	 JE COIN_2
	CMP CH,'X'      ;I took a boulder
	 JE ROCK_2
	CMP CH,'V'      ;I took a life
	 JE LIFE_2
	JMP CONT_2

COIN_2: JMP CONT_2    ;I leave the code as it is in case I want to make subsequent changes

ROCK_2:  JMP CONT_2

LIFE_2:   JMP CONT_2


CONT_2: INC DX
	CALL posCur

	POP DX
	POP CX
	POP AX
	RET                     ;returns
setCar ENDP
;============================================================================
checkCar PROC NEAR ;DH=row,DL=column
	CMP CL,01H      ;CL checks if something has already been taken
	JE CONT_1       ;CL=1 skip the check because it is not needed and go to the end

	CALL readCur    ;check the ASCII character pointed by the cursor AL=character, AH=color
	CMP AH,08H      ;if it's gray -> boulder
	 JE ROCK_1
	CMP AH,0EH      ;if it's yellow -> coin
	 JE COIN_1
	CMP AH,04H
	 JE LIFE_1      ;if it's red -> life
	CMP AH,07H
	 JE NOTHING_1    ;takes nothing
	JMP CONT_1

ROCK_1: MOV CL,01H     ;set CL to 1 to say that I touched something
	 MOV CH,'X'     ;in CH I save the value of the type of obstacle (in CH it lasts a tick)
	 MOV BL,'x'     ;in BL I save the value of the type of obstacle (in BL it lasts a cycle)
	 JMP CONT_1

COIN_1: MOV CL,01H    ;set CL to 1 to say that I touched something
	  MOV CH,'M'    ;in CH I save the value of the type of obstacle (in CH it lasts a tick)
	  MOV BL,'m'    ;in BL I save the value of the type of obstacle (in BL it lasts a cycle)
	  JMP CONT_1

LIFE_1:   MOV CL,01H    ;set CL to 1 to say that I touched something
	  MOV CH,'V'    ;in CH I save the value of the type of obstacle (in CH it lasts a tick)
	  MOV BL,'v'    ;in BL I save the value of the type of obstacle (in BL it lasts a cycle)
	  JMP CONT_1

NOTHING_1: MOV CH,'_'    ;control character
	  JMP CONT_1

CONT_1:   RET

checkCar ENDP
;=========================================================================================================
Word2Dec PROC NEAR      ;transforms the hexadecimal word provided in AX into the corresponding ASCII characters
	PUSH    AX
	PUSH    BX
	PUSH    DX
	CMP     AX,10000        ;If the hexadecimal number in input is less
	JC      Wor2_0          ;than 10000 the next division is avoided
	MOV     DX,0000H        ;(DX,AX=0000XXXX):(BX=10000)=AX, remainder DX
	MOV     BX,10000        ;Prepare the divisor to 10000
	DIV     BX              ;Performs the division
	CALL    STAasci         ;Prints the value of the Tens of Thousands
	MOV     AX,DX           ;Moves in AX the  Rest  RRRR  of the  division
	JMP     SHORT Wor2_1    ;previous to divide  in the  next phase
Wor2_0: CMP     AX,1000     ;If the hexadecimal number in input is less
	JC      Byt2_0          ;than 1000  the next division is avoided
Wor2_1: MOV     DX,0000H    ;(DX,AX=0000XXXX):(BX=1000)=AX, remainder DX
	MOV     BX,1000         ;Prepare the divisor to 1000
	DIV     BX              ;Performs the division
	CALL    STAasci         ;Prints the value of the Thousands
	MOV     AX,DX           ;Moves in AX the  Rest  RRRR  of the  division
	JMP     SHORT Byt2_1    ;previous to divide in the  next phase

;Byte2Dec
	PUSH    AX              ;Saves the Registers used by the Procedure, including-
	PUSH    BX              ;the value to convert, passed in input in AL
	PUSH    DX              ;formats the dividend to the value AX=00XX
Byt2_0: CMP     AX,100      ;If the hexadecimal number in input is less
	JC      Byt2_2          ;than 100 the  next division is avoided
Byt2_1: MOV     BL,100      ;Prepare the divisor to 100
	DIV     BL              ;Divide AX=00XX for BL=100 (AX:BL=AL, remainder AH)
	CALL    STAasci         ;Prints the value of the Hundreds
	MOV     AL,AH           ;Moves in AL the Rest RR of the previous division
	MOV     AH,00H          ;to divide  in the  next phase,
	JMP     SHORT Byt2_3    ;formatting the dividend to the value AX=00RR
Byt2_2: CMP     AX,10       ;If the hexadecimal number in input  is less
	JC      Byt2_4          ;than 10 the next  division  is  avoided
Byt2_3: MOV     BL,10       ;Prepare the divisor to 10
	DIV     BL              ;Divide AX=00XX for BL=10  (AX:BL=AL, remainder AH)
	CALL    STAasci         ;Prints the value of the Tens
	MOV     AL,AH           ;Prepare in AL the digit of the Units
Byt2_4: CALL    STAasci     ;Prints the value of the Units
	POP     DX
	POP     BX
	POP     AX
	RET
Word2Dec ENDP
;========================================================================================================
STAasci PROC NEAR             ;prints the ascii value of the number in AL
	PUSH    AX
	ADD     AL,30H        ;add 30 to the number to have the ASCII character of the number
	stpChrT AL
	POP     AX
	RET
STAasci ENDP
;=========================================================================================================
readCur PROC NEAR             ;reads the value of the ASCII character pointed by the cursor
	MOV AH,08H
	MOV BH,00H
	INT 10H               ;returns in AH=Color, AL=Character
	RET
readCur ENDP
;=========================================================================================================
outCur PROC    Near             ;Procedure that hides the cursor from the video
	PUSH CX                 ;based on the procedure resize cursor (in height)
	PUSH AX                 ;(if the bit 5 of CH is 1 then the cursor disappears)
	MOV CH,20H              ;start line of pixel
	MOV CL,00H              ;end line of pixel
	MOV AH,01H
	INT 10H
	POP AX
	POP CX
	RET                     ;returns
outCur ENDP
;============================================================================
cls PROC Near
	MOV AL,03H              ;video mode 80columns x 24rows
	MOV AH,00H              ;also creates a clear screen
	INT 10H
	RET
cls ENDP
;============================================================================
tornaDOS PROC NEAR
	MOV AH,4CH
	INT 21H
tornaDOS ENDP
;============================================================================

_prog    ENDS                   ;END PROGRAM SEGMENT
	END     initialiser          ;end Program, everything written after is ignored!
