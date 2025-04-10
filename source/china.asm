; https://www.ee.nthu.edu.tw/jcliao/mic97/chap08/TICTAC.ASM
;Program TICTAC.ASM: Play Tic Tac Toe with the computer.
;
      .MODEL SMALL
      .DATA
GMSG  DB  'Computer TIC TAC TOE.',0DH,0AH
      DB  'User is X, computer is O',0DH,0AH,0DH,0AH,'$'
BOARD DB  '123456789'
BTXT  DB  0DH,0AH
      DB  '  |   |  ',0DH,0AH
      DB  '---------',0DH,0AH
      DB  '  |   |  ',0DH,0AH
      DB  '---------',0DH,0AH
      DB  '  |   |  ',0DH,0AH,0DH,0AH,'$'
BPOS  DB  2,6,10,24,28,32,46,50,54
PMSG  DB  'Enter your move (0 to 9): $'
PIM1  DB  0DH,0AH,'That move does not make sense, try again.',0DH,0AH,'$'
PIM2  DB  0DH,0AH,'That square is occupied, try again.',0DH,0AH,'$'
CMSG  DB  'I choose square $'
CRLF  DB  0DH,0AH,'$'
WINS  DW  1,2,3, 4,5,6, 7,8,9                ;any row
      DW  1,4,7, 2,5,8, 3,6,9                ;any column
      DW  1,5,9, 3,5,7                       ;either diagonal
XWIN  DB  'X wins the game!',0DH,0AH,'$'
OWIN  DB  'O wins the game!',0DH,0AH,'$'
MTIE  DB  'The game is a tie.',0DH,0AH,'$'
       
       .CODE
       .STARTUP
       LEA   DX,GMSG  ;set up pointer to greeting
       MOV   AH,9     ;display string function
       INT   21H
       CALL  SHOWBRD  ;display board
NEXT:  CALL  PMOVE    ;get player move
       CALL  SHOWBRD  ;display board
       CALL  CHECK    ;did player win or tie?
       JZ    EXIT
       CALL  CMOVE    ;let computer move
       CALL  SHOWBRD  ;display board
       CALL  CHECK    ;did computer win or tie?
       JZ    EXIT
       JMP   NEXT     ;continue with game
EXIT:  .EXIT

SHOWBRD PROC  NEAR
        MOV   CX,9             ;set up loop counter
        SUB   SI,SI            ;set up index pointer
LBC:    MOV   AL,BPOS[SI]      ;get a board position
        CBW                    ;convert to word
        MOV   DI,AX            ;set up pointer to board string
        MOV   AL,BOARD[SI]     ;get player symbol
        MOV   BTXT[DI],AL      ;write into board string
        INC   SI               ;advance index pointer
        LOOP  LBC              ;repeat for all nine positions
        LEA   DX,BTXT          ;set up pointer to board string
        MOV   AH,9             ;display string function
        INT   21H              ;DOS call
        RET
SHOWBRD ENDP

PMOVE  PROC NEAR
       LEA  DX,PMSG         ;set up pointer to player string
       MOV  AH,9            ;display string function
       INT  21H             ;DOS call
       MOV  AH,1            ;read keyboard function
       INT  21H             ;DOS call
       CMP  AL,'1'          ;insure user input is a digit
       JC   BPM
       CMP  AL,'9'+1
       JNC  BPM
       SUB  AL,31H          ;remove ASCII bias
       CBW                  ;convert to word
       MOV  SI,AX           ;set up index pointer
       MOV  AL,BOARD[SI]    ;get board symbol
       CMP  AL,'X'          ;is position occupied?
       JZ   PSO
       CMP  AL,'O'
       JZ   PSO
       MOV  BOARD[SI],'X'   ;save player move
       LEA  DX,CRLF         ;set up pointer to newline string
       MOV  AH,9            ;display string function
       INT  21H             ;DOS call
       RET
BPM:   LEA  DX,PIM1         ;set up pointer to illegal string
STP:   MOV  AH,9            ;display string function
       INT  21H             ;DOS call
       JMP  PMOVE           ;go give user a second chance
PSO:   LEA  DX,PIM2         ;set up pointer to occupied string
       JMP  STP             ;go process error message
       RET
PMOVE  ENDP

CMOVE  PROC NEAR
       SUB  SI,SI           ;clear index pointer
NCM:   MOV  AL,BOARD[SI]    ;get board symbol
       CMP  AL,'X'          ;is position occupied?
       JZ   STN
       CMP  AL,'O'
       JZ   STN
       MOV  BOARD[SI],'O'   ;save computer move (not very tough, is it?)
       MOV  AX,SI           ;save move value
       PUSH AX
       LEA  DX,CMSG         ;set up pointer to choice string
       MOV  AH,9            ;display string function
       INT  21H             ;DOS call
       POP  DX              ;get move value back
       ADD  DL,31H          ;add ASCII bias
       MOV  AH,2            ;display character function
       INT  21H             ;DOS call
       LEA  DX,CRLF         ;set up pointer to newline string
       MOV  AH,9            ;display string function
       INT  21H             ;DOS call
       RET
STN:   INC  SI              ;advance to next position
       JMP  NCM             ;go check next position
CMOVE  ENDP

CHECK  PROC NEAR
       SUB  SI,SI             ;clear index pointer
       MOV  CX,8              ;set up loop counter
CAT:   MOV  DI,WINS[SI]       ;get first board position
       MOV  AH,BOARD[DI-1]    ;get board symbol
       MOV  DI,WINS[SI+2]     ;get second board pisition
       MOV  BL,BOARD[DI-1]    ;get board symbol
       MOV  DI,WINS[SI+4]     ;get third board position
       MOV  BH,BOARD[DI-1]    ;get board symbol
       ADD  SI,6              ;advance to next set of psitions
       CMP  AH,BL             ;do all three symbols match?
       JNZ  NMA
       CMP  AH,BH
       JNZ  NMA
       CMP  AH,'X'            ;does match contain X?
       JNZ  WIO
       LEA  DX,XWIN           ;set up pointer to x-wins string
       JMP  EXC               ;go process string
WIO:   LEA  DX,OWIN           ;set up pointer to o-wins string
       JMP  EXC               ;go process string
NMA:   LOOP CAT               ;no match, try another group
       SUB  SI,SI             ;clear index pointer
CFB:   MOV  AL,BOARD[SI]      ;get board symbol
       CMP  AL,'X'            ;is symbol X?
       JZ   IAH
       CMP  AL,'O'            ;is symbol O?
       JZ   IAH
       RET                    ;no tie yet
IAH:   INC  SI                ;advance to next position
       LOOP CFB               ;go check another board symbol
       LEA  DX,MTIE           ;set up pointer to tie message
EXC:   MOV  AH,9              ;display string function
       INT  21H               ;DOS call
       SUB  AL,AL             ;set zero flag
       RET
CHECK  ENDP

       END
