; TIC TAC TOE V2.0
.MODEL SMALL
.DATA
GMSG  DB  'Tro choi CA RO voi may tinh.',0DH,0AH
      DB  'Nguoi choi la X, may tinh la O',0DH,0AH,0DH,0AH,'$'
BOARD DB  '123456789'
BTXT  DB  0DH,0AH
      DB  '  |   |  ',0DH,0AH
      DB  '---------',0DH,0AH
      DB  '  |   |  ',0DH,0AH
      DB  '---------',0DH,0AH
      DB  '  |   |  ',0DH,0AH,0DH,0AH,'$'
BPOS  DB  2,6,10,24,28,32,46,50,54
PMSG  DB  'Nhap nuoc di cua ban (1 den 9): $'
PIM1  DB  0DH,0AH,'Nuoc di khong hop le, hay thu lai.',0DH,0AH,'$'
PIM2  DB  0DH,0AH,'O nay da duoc chon, hay thu o khac.',0DH,0AH,'$'
CMSG  DB  'Toi chon o so $'
CRLF  DB  0DH,0AH,'$'
WINS  DW  1,2,3, 4,5,6, 7,8,9                ;cac hang ngang
      DW  1,4,7, 2,5,8, 3,6,9                ;cac cot doc
      DW  1,5,9, 3,5,7                       ;cac duong cheo
XWIN  DB  'X da thang!',0DH,0AH,'$'
OWIN  DB  'O da thang!',0DH,0AH,'$'
MTIE  DB  'Tro choi hoa.',0DH,0AH,'$'
       
; ===== PHAN CODE =====
.CODE
.STARTUP
       LEA   DX, GMSG         ; hien thi loi chao
       MOV   AH, 9            ; chuc nang hien thi chuoi
       INT   21H
       CALL  SHOWBRD          ; hien thi bang
NEXT:  
       CALL  PMOVE            ; lay nuoc di cua nguoi choi
       CALL  SHOWBRD          ; hien thi bang
       CALL  CHECK            ; kiem tra nguoi choi thang hay hoa?
       JZ    EXIT
       CALL  CMOVE            ; may tinh thuc hien nuoc di
       CALL  SHOWBRD          ; hien thi bang
       CALL  CHECK            ; kiem tra may tinh thang hay hoa?
       JZ    EXIT
       JMP   NEXT             ; tiep tuc tro choi
EXIT:  
       .EXIT

; ===== HIEN THI BANG =====
SHOWBRD PROC NEAR
        MOV   CX, 9           ; thiet lap bo dem vong lap
        SUB   SI, SI          ; thiet lap con tro chi muc
LBC:    
        MOV   AL, BPOS[SI]    ; lay vi tri tren bang
        CBW                   ; chuyen doi thanh word
        MOV   DI, AX          ; thiet lap con tro den chuoi bang
        MOV   AL, BOARD[SI]   ; lay ky hieu nguoi choi
        MOV   BTXT[DI], AL    ; ghi vao chuoi bang
        INC   SI              ; tang con tro chi muc
        LOOP  LBC             ; lap lai cho tat ca 9 vi tri
        
        LEA   DX, BTXT        ; thiet lap con tro den chuoi bang
        MOV   AH, 9           ; chuc nang hien thi chuoi
        INT   21H             ; goi DOS
        RET
SHOWBRD ENDP

; ===== NGUOI CHOI NHAP NUOC DI =====
PMOVE  PROC NEAR
       LEA   DX, PMSG         ; thiet lap con tro den thong bao nguoi choi
       MOV   AH, 9            ; chuc nang hien thi chuoi
       INT   21H              ; goi DOS
       
       MOV   AH, 1            ; doc ban phim
       INT   21H              ; goi DOS
       
       CMP   AL, '1'          ; dam bao dau vao la chu so
       JC    BPM              ; nhay neu nho hon '1'
       CMP   AL, '9'+1        
       JNC   BPM              ; nhay neu lon hon hoac bang '9'+1
       
       SUB   AL, 31H          ; loai bo bias ASCII
       CBW                    ; chuyen doi thanh word
       MOV   SI, AX           ; thiet lap con tro chi muc
       
       MOV   AL, BOARD[SI]    ; lay ky hieu tren bang
       CMP   AL, 'X'          ; kiem tra vi tri co bi chiem?
       JZ    PSO
       CMP   AL, 'O'
       JZ    PSO
       
       MOV   BOARD[SI], 'X'   ; luu nuoc di cua nguoi choi
       LEA   DX, CRLF         ; thiet lap con tro den chuoi xuong dong
       MOV   AH, 9            ; chuc nang hien thi chuoi
       INT   21H              ; goi DOS
       RET
       
BPM:   
       LEA   DX, PIM1         ; thiet lap con tro den thong bao khong hop le
STP:   
       MOV   AH, 9            ; chuc nang hien thi chuoi
       INT   21H              ; goi DOS
       JMP   PMOVE            ; cho phep nguoi dung thu lai
       
PSO:   
       LEA   DX, PIM2         ; thiet lap con tro den thong bao o da chiem
       JMP   STP              ; xu ly thong bao loi
       RET
PMOVE  ENDP

; ===== MAY TINH THUC HIEN NUOC DI =====
CMOVE  PROC NEAR
       SUB   SI, SI           ; xoa con tro chi muc
NCM:   
       MOV   AL, BOARD[SI]    ; lay ky hieu tren bang
       CMP   AL, 'X'          ; kiem tra vi tri co bi chiem?
       JZ    STN
       CMP   AL, 'O'
       JZ    STN
       
       MOV   BOARD[SI], 'O'   ; luu nuoc di cua may tinh
       MOV   AX, SI           ; luu gia tri nuoc di
       PUSH  AX
       
       LEA   DX, CMSG         ; thiet lap con tro den chuoi lua chon
       MOV   AH, 9            ; chuc nang hien thi chuoi
       INT   21H              ; goi DOS
       
       POP   DX               ; lay lai gia tri nuoc di
       ADD   DL, 31H          ; them bias ASCII
       MOV   AH, 2            ; chuc nang hien thi ky tu
       INT   21H              ; goi DOS
       
       LEA   DX, CRLF         ; thiet lap con tro den chuoi xuong dong
       MOV   AH, 9            ; chuc nang hien thi chuoi
       INT   21H              ; goi DOS
       RET
       
STN:   
       INC   SI               ; chuyen den vi tri tiep theo
       JMP   NCM              ; kiem tra vi tri tiep theo
CMOVE  ENDP

; ===== KIEM TRA THANG THUA =====
CHECK  PROC NEAR
       SUB   SI, SI           ; xoa con tro chi muc
       MOV   CX, 8            ; thiet lap bo dem vong lap - 8 truong hop thang
       
CAT:   
       MOV   DI, WINS[SI]     ; lay vi tri dau tien
       MOV   AH, BOARD[DI-1]  ; lay ky hieu tren bang
       
       MOV   DI, WINS[SI+2]   ; lay vi tri thu hai
       MOV   BL, BOARD[DI-1]  ; lay ky hieu tren bang
       
       MOV   DI, WINS[SI+4]   ; lay vi tri thu ba
       MOV   BH, BOARD[DI-1]  ; lay ky hieu tren bang
       
       ADD   SI, 6            ; chuyen den bo vi tri tiep theo
       
       CMP   AH, BL           ; kiem tra ca ba ky hieu co giong nhau?
       JNZ   NMA
       CMP   AH, BH
       JNZ   NMA
       
       CMP   AH, 'X'          ; kiem tra co phai X?
       JNZ   WIO
       
       LEA   DX, XWIN         ; thiet lap con tro den thong bao X thang
       JMP   EXC              ; xu ly chuoi
       
WIO:   
       LEA   DX, OWIN         ; thiet lap con tro den thong bao O thang
       JMP   EXC              ; xu ly chuoi
       
NMA:   
       LOOP  CAT              ; khong trung khop, thu nhom khac
       
       ; Kiem tra truong hop hoa
       SUB   SI, SI           ; xoa con tro chi muc
       MOV   CX, 9            ; set bo dem cho kiem tra bang day
       
CFB:   
       MOV   AL, BOARD[SI]    ; lay ky hieu tren bang
       CMP   AL, 'X'          ; kiem tra la X?
       JZ    IAH
       CMP   AL, 'O'          ; kiem tra la O?
       JZ    IAH
       RET                    ; chua hoa - van con o trong
       
IAH:   
       INC   SI               ; chuyen den vi tri tiep theo
       LOOP  CFB              ; kiem tra ky hieu bang khac
       
       LEA   DX, MTIE         ; thiet lap con tro den thong bao hoa
       
EXC:   
       MOV   AH, 9            ; chuc nang hien thi chuoi
       INT   21H              ; goi DOS
       SUB   AL, AL           ; thiet lap co zero
       RET
CHECK  ENDP

END
