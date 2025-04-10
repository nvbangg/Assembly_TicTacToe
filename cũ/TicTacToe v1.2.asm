; TIC TAC TOE V1.2
.MODEL SMALL
.STACK 100H
.DATA
    ; Bảng trò chơi 3x3 và thông báo
    BANG       DB '123456789'
    LUOT_X     DB 'Luot X. Nhap vi tri (1-9): $'
    LUOT_O     DB 'Luot O. Nhap vi tri (1-9): $'
    NUOC_LOI   DB 'Nuoc di khong hop le! Thu lai.$'
    X_THANG    DB 'NGUOI CHOI X THANG CUOC!$'
    O_THANG    DB 'NGUOI CHOI O THANG CUOC!$'
    VAN_HOA    DB 'VAN HOA$'
    CHOI_LAI   DB 'Choi lai? (Y/N): $'
    NGUOI_CHOI DB 'X'           ; Lượt hiện tại
    XUONG_DONG DB 13, 10, '$'   ; CR+LF
    DUONG_KE   DB '---+---+---$'
    NGUOI_THANG DB ' ','$'      ; X, O hoặc D

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    CALL KHOI_TAO
    
VONG_CHOI:
    CALL HIEN_THI_BANG
    CALL NHAP_NUOC_DI
    CALL KIEM_TRA_KET_THUC
    CMP  AL, 1
    JE   KET_THUC
    CALL DOI_NGUOI_CHOI
    JMP  VONG_CHOI
    
KET_THUC:            
    CALL HIEN_THI_BANG
    
    MOV  AH, 9
    MOV  AL, NGUOI_THANG
    LEA  DX, X_THANG
    CMP  AL, 'X'
    JE   HIEN_KQ
    LEA  DX, O_THANG
    CMP  AL, 'O'
    JE   HIEN_KQ
    LEA  DX, VAN_HOA
HIEN_KQ:
    INT  21H
    LEA  DX, XUONG_DONG
    INT  21H
    INT  21H
    LEA  DX, CHOI_LAI
    INT  21H
    MOV  AH, 1
    INT  21H
    AND  AL, 0DFh
    CMP  AL, 'Y'
    JNE  THOAT
    CALL KHOI_TAO
    JMP  VONG_CHOI
THOAT:
    MOV  AH, 4Ch
    INT  21H
MAIN ENDP

; Khởi tạo trò chơi
KHOI_TAO PROC
    LEA  SI, BANG
    MOV  BL, '1'
    MOV  CX, 9
LAP_RESET:          
    MOV  [SI], BL
    INC  BL
    INC  SI
    LOOP LAP_RESET
    
    MOV  NGUOI_CHOI, 'X'
    RET
KHOI_TAO ENDP

; Hiển thị bảng
HIEN_THI_BANG PROC
    MOV  AH, 0
    MOV  AL, 3
    INT  10H
    
    LEA  SI, BANG
    XOR  BX, BX
    MOV  CX, 3
    
VONG_HANG:           
    PUSH CX
    
    ; Hiển thị hàng với 3 ô
    MOV  AH, 2
    MOV  DL, ' '
    INT  21H
    
    CALL HIEN_THI_O              ; Hiển thị ô 1
    CALL HIEN_PHAN_CACH          ; Phân cách
    
    INC  BX                      ; Chuyển sang ô 2
    CALL HIEN_THI_O
    CALL HIEN_PHAN_CACH          ; Phân cách
    
    INC  BX                      ; Chuyển sang ô 3
    CALL HIEN_THI_O
    
    MOV  AH, 9                   ; Xuống dòng
    LEA  DX, XUONG_DONG
    INT  21H
    
    POP  CX
    CMP  CX, 1                   ; Nếu không phải dòng cuối
    JE   TIEP_HANG
    
    LEA  DX, DUONG_KE            ; Hiển thị đường kẻ
    INT  21H
    LEA  DX, XUONG_DONG
    INT  21H
    
TIEP_HANG:           
    INC  BX                      ; Bước tới hàng tiếp theo
    LOOP VONG_HANG
    
    LEA  DX, XUONG_DONG          ; Thêm dòng trống
    INT  21H
    
    RET

; Hiển thị một ô
HIEN_THI_O:
    MOV  DL, [SI + BX]
    INT  21H
    RET

; Hiển thị dấu phân cách
HIEN_PHAN_CACH:
    MOV  DL, ' '
    INT  21H
    MOV  DL, '|'
    INT  21H
    MOV  DL, ' '
    INT  21H
    RET
HIEN_THI_BANG ENDP

; Lấy nước đi của người chơi
NHAP_NUOC_DI PROC
    MOV  AH, 9
    LEA  DX, LUOT_X              ; Mặc định là lượt X
    CMP  NGUOI_CHOI, 'X'
    JE   HIEN_NHAC
    LEA  DX, LUOT_O              ; Nếu không phải X thì là O
    
HIEN_NHAC:           
    INT  21H
    
    MOV  AH, 1                   ; Nhận đầu vào
    INT  21H
    
    CMP  AL, '1'                 ; Kiểm tra hợp lệ (1-9)
    JL   NHAP_SAI
    CMP  AL, '9'
    JG   NHAP_SAI
    
    SUB  AL, '1'                 ; Chuyển thành chỉ số 0-8
    MOV  BL, AL
    XOR  BH, BH
    
    LEA  SI, BANG
    ADD  SI, BX
    
    MOV  AL, [SI]                ; Kiểm tra ô đã đánh chưa
    CMP  AL, 'X'
    JE   NHAP_SAI
    CMP  AL, 'O'
    JE   NHAP_SAI
    
    MOV  AL, NGUOI_CHOI          ; Đánh dấu ô
    MOV  [SI], AL
    
    MOV  AH, 9                   ; Xuống dòng
    LEA  DX, XUONG_DONG
    INT  21H
    
    RET
    
NHAP_SAI:            
    MOV  AH, 9
    LEA  DX, XUONG_DONG
    INT  21H
    LEA  DX, NUOC_LOI
    INT  21H
    LEA  DX, XUONG_DONG
    INT  21H
    JMP  NHAP_NUOC_DI
NHAP_NUOC_DI ENDP

; Đổi người chơi
DOI_NGUOI_CHOI PROC
    MOV  AL, NGUOI_CHOI
    XOR  AL, ('X' XOR 'O')       ; Đổi X thành O và ngược lại
    MOV  NGUOI_CHOI, AL
    RET
DOI_NGUOI_CHOI ENDP

; Kiểm tra kết thúc
KIEM_TRA_KET_THUC PROC
    LEA  SI, BANG
    XOR  BX, BX                  ; Kiểm tra các hàng
KIEM_TRA_HANG_ALL:
    CALL KIEM_TRA_HANG
    JE   TIM_THAY_NGUOI_THANG
    ADD  BX, 3
    CMP  BX, 9
    JL   KIEM_TRA_HANG_ALL
    
    MOV  CX, 3                   ; Bước nhảy cho cột
    XOR  BX, BX                  ; Kiểm tra các cột
KIEM_TRA_COT_ALL:
    CALL KIEM_TRA_DUONG
    JE   TIM_THAY_NGUOI_THANG
    INC  BX
    CMP  BX, 3
    JL   KIEM_TRA_COT_ALL
    
    MOV  BX, 0                   ; Kiểm tra đường chéo chính
    MOV  CX, 4
    CALL KIEM_TRA_DUONG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  BX, 2                   ; Kiểm tra đường chéo phụ
    MOV  CX, 2
    CALL KIEM_TRA_DUONG
    JE   TIM_THAY_NGUOI_THANG
    
    ; Kiểm tra hòa
    LEA  SI, BANG
    MOV  CX, 9
KIEM_TRA_HOA:
    MOV  AL, [SI]
    CMP  AL, '9'
    JLE  KIEM_SO
    INC  SI
    LOOP KIEM_TRA_HOA
    JMP  HOA_GAME
    
KIEM_SO:
    CMP  AL, '1'
    JGE  CON_O_TRONG
    INC  SI
    LOOP KIEM_TRA_HOA
    
HOA_GAME:
    MOV  NGUOI_THANG, 'D'
    MOV  AL, 1
    RET
    
CON_O_TRONG:
    XOR  AL, AL
    RET
    
TIM_THAY_NGUOI_THANG:
    MOV  NGUOI_THANG, AL
    MOV  AL, 1
    RET
KIEM_TRA_KET_THUC ENDP

; Kiểm tra hàng ngang
KIEM_TRA_HANG PROC
    MOV  AL, [SI + BX]
    CMP  AL, [SI + BX + 1]
    JNE  KHONG_BANG
    CMP  AL, [SI + BX + 2]
    JNE  KHONG_BANG
    RET
    
KHONG_BANG:
    OR   AL, 1
    RET
KIEM_TRA_HANG ENDP

; Kiểm tra đường (cột, chéo)
KIEM_TRA_DUONG PROC
    PUSH BX
    
    MOV  AL, [SI + BX]
    ADD  BX, CX
    CMP  AL, [SI + BX]
    JNE  KHONG_KHOP
    ADD  BX, CX
    CMP  AL, [SI + BX]
    JNE  KHONG_KHOP
    
    POP  BX
    RET
    
KHONG_KHOP:
    POP  BX
    OR   AL, 1
    RET
KIEM_TRA_DUONG ENDP

END MAIN