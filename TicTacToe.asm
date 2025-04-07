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
    VT_CHIA    DB ' | | $'      ; Mẫu chia cột

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    CALL KHOI_TAO
    
VONG_CHOI:
    CALL HIEN_THI_BANG
    CALL NHAP_NUOC_DI
    
    CALL KIEM_TRA_KET_THUC       ; Kiểm tra kết thúc
    CMP  AL, 1
    JE   KET_THUC
    
    CALL DOI_NGUOI_CHOI          ; Đổi lượt
    JMP  VONG_CHOI
    
KET_THUC:            
    CALL HIEN_THI_BANG           ; Hiển thị bảng cuối
    
    ; Hiển thị thông báo người thắng
    MOV  AL, NGUOI_THANG
    CMP  AL, 'X'
    JE   HIEN_X_THANG
    CMP  AL, 'O'
    JE   HIEN_O_THANG
    
    ; Nếu hòa
    LEA  DX, VAN_HOA
    JMP  HIEN_KET_QUA
    
HIEN_X_THANG:        
    LEA  DX, X_THANG
    JMP  HIEN_KET_QUA
    
HIEN_O_THANG:        
    LEA  DX, O_THANG
    
HIEN_KET_QUA:        
    MOV  AH, 9
    INT  21H
    
    LEA  DX, XUONG_DONG          ; Xuống dòng 2 lần
    INT  21H
    INT  21H                     ; Không cần lặp lại LEA DX
    
    LEA  DX, CHOI_LAI            ; Hỏi chơi lại
    INT  21H
    
    MOV  AH, 1                   ; Nhận đầu vào
    INT  21H
    
    AND  AL, 11011111b           ; Chuyển thường thành hoa
    CMP  AL, 'Y'
    JE   CHOI_LAI_GAME
    
    MOV  AH, 4CH                 ; Kết thúc chương trình
    INT  21H
    
CHOI_LAI_GAME:       
    CALL KHOi_TAO
    JMP  VONG_CHOI
MAIN ENDP

; Khởi tạo trò chơi
KHOI_TAO PROC
    MOV  CX, 9                   ; Đếm 9 ô
    LEA  SI, BANG
    MOV  BL, '1'                 ; Bắt đầu từ 1
    
VONG_RESET:          
    MOV  [SI], BL                ; Gán giá trị
    INC  BL                      ; Tăng số
    INC  SI                      ; Ô tiếp theo
    LOOP VONG_RESET
    
    MOV  NGUOI_CHOI, 'X'         ; X đi trước
    RET
KHOI_TAO ENDP

; Hiển thị bảng
HIEN_THI_BANG PROC
    MOV  AH, 0                   ; Xóa màn hình
    MOV  AL, 3
    INT  10H
    
    LEA  SI, BANG
    XOR  BX, BX                  ; BX = 0, dùng làm bộ đếm
    
    MOV  CX, 3                   ; Hiển thị 3 hàng
    
VONG_HANG:           
    PUSH CX                      ; Lưu bộ đếm hàng
    
    MOV  AH, 2                   ; Hiển thị 1 hàng (3 ô)
    MOV  DL, ' '                 ; Khoảng trắng đầu
    INT  21H
    
    MOV  DL, [SI + BX]           ; Ô 1
    INT  21H
    
    MOV  DL, ' '                 ; Phân cách
    INT  21H
    MOV  DL, '|'
    INT  21H
    MOV  DL, ' '
    INT  21H
    
    MOV  DL, [SI + BX + 1]       ; Ô 2
    INT  21H
    
    MOV  DL, ' '                 ; Phân cách
    INT  21H
    MOV  DL, '|'
    INT  21H
    MOV  DL, ' '
    INT  21H
    
    MOV  DL, [SI + BX + 2]       ; Ô 3
    INT  21H
    
    MOV  AH, 9                   ; Chuyển sang INT 9 để hiển thị chuỗi
    LEA  DX, XUONG_DONG
    INT  21H
    
    POP  CX
    CMP  CX, 1                   ; Nếu không phải dòng cuối, hiển thị đường kẻ
    JE   BO_QUA_KE
    
    LEA  DX, DUONG_KE
    INT  21H
    LEA  DX, XUONG_DONG
    INT  21H
    
BO_QUA_KE:           
    ADD  BX, 3                   ; Bước tới hàng tiếp theo
    LOOP VONG_HANG
    
    LEA  DX, XUONG_DONG          ; Thêm dòng trống
    INT  21H
    
    RET
HIEN_THI_BANG ENDP

; Lấy nước đi của người chơi
NHAP_NUOC_DI PROC
    CMP  NGUOI_CHOI, 'X'         ; Hiển thị lời nhắc
    JNE  NHAC_O
    
    LEA  DX, LUOT_X
    JMP  HIEN_NHAC
    
NHAC_O:              
    LEA  DX, LUOT_O
    
HIEN_NHAC:           
    MOV  AH, 9
    INT  21H
    
    MOV  AH, 1                   ; Nhận đầu vào
    INT  21H
    
    CMP  AL, '1'                 ; Kiểm tra hợp lệ (1-9)
    JL   NHAP_SAI
    CMP  AL, '9'
    JG   NHAP_SAI
    
    SUB  AL, '1'                 ; Chuyển thành chỉ số 0-8
    MOV  BL, AL
    
    LEA  SI, BANG                ; Kiểm tra ô đã bị chiếm chưa
    XOR  BH, BH
    ADD  SI, BX
    
    MOV  AL, [SI]
    CMP  AL, 'X'
    JE   NHAP_SAI
    CMP  AL, 'O'
    JE   NHAP_SAI
    
    MOV  AL, NGUOI_CHOI          ; Đánh dấu ô
    MOV  [SI], AL
    
    LEA  DX, XUONG_DONG          ; Xuống dòng
    MOV  AH, 9
    INT  21H
    
    RET
    
NHAP_SAI:            
    MOV  AH, 9
    LEA  DX, XUONG_DONG          ; Hiển thị thông báo lỗi và xuống dòng
    INT  21H
    
    LEA  DX, NUOC_LOI
    INT  21H
    
    LEA  DX, XUONG_DONG
    INT  21H
    
    JMP  NHAP_NUOC_DI            ; Thử lại
NHAP_NUOC_DI ENDP

; Đổi người chơi
DOI_NGUOI_CHOI PROC
    MOV  AL, 'X'                 ; Đảo X <-> O
    CMP  NGUOI_CHOI, AL
    JE   DAT_O
    MOV  NGUOI_CHOI, AL          ; Đổi thành X
    JMP  XONG_DOI
    
DAT_O:               
    MOV  NGUOI_CHOI, 'O'         ; Đổi thành O
    
XONG_DOI:            
    RET
DOI_NGUOI_CHOI ENDP

; Kiểm tra kết thúc
KIEM_TRA_KET_THUC PROC
    LEA  SI, BANG
    
    ; Thay thế vòng lặp bằng cách kiểm tra trực tiếp
    MOV  BX, 0                   ; Kiểm tra hàng 1
    CALL KIEM_TRA_HANG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  BX, 3                   ; Kiểm tra hàng 2
    CALL KIEM_TRA_HANG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  BX, 6                   ; Kiểm tra hàng 3
    CALL KIEM_TRA_HANG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  BX, 0                   ; Kiểm tra cột 1
    MOV  CX, 3                   ; Bước nhảy = 3
    CALL KIEM_TRA_DUONG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  BX, 1                   ; Kiểm tra cột 2
    CALL KIEM_TRA_DUONG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  BX, 2                   ; Kiểm tra cột 3
    CALL KIEM_TRA_DUONG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  BX, 0                   ; Kiểm tra đường chéo chính
    MOV  CX, 4                   ; Bước nhảy = 4
    CALL KIEM_TRA_DUONG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  BX, 2                   ; Kiểm tra đường chéo phụ
    MOV  CX, 2                   ; Bước nhảy = 2
    CALL KIEM_TRA_DUONG
    JE   TIM_THAY_NGUOI_THANG
    
    MOV  CX, 9                   ; Kiểm tra hòa (9 ô)
    LEA  SI, BANG
    
KIEM_TRA_HOA:        
    MOV  AL, [SI]
    CMP  AL, '1'
    JL   VI_TRI_KE
    CMP  AL, '9'
    JG   VI_TRI_KE
    
    XOR  AL, AL                  ; Còn ô trống -> tiếp tục
    RET
    
VI_TRI_KE:           
    INC  SI
    LOOP KIEM_TRA_HOA
    
    MOV  NGUOI_THANG, 'D'        ; Đánh dấu hòa
    MOV  AL, 1
    RET
    
TIM_THAY_NGUOI_THANG:
    MOV  NGUOI_THANG, AL
    MOV  AL, 1
    RET
KIEM_TRA_KET_THUC ENDP

; Các thủ tục kiểm tra phụ
KIEM_TRA_HANG PROC
    MOV  AL, [SI + BX]           ; Ô đầu tiên
    CMP  AL, [SI + BX + 1]       ; So với ô thứ hai
    JNE  KHONG_BANG
    CMP  AL, [SI + BX + 2]       ; So với ô thứ ba
    JNE  KHONG_BANG
    
    RET                          ; Cờ Zero=1 nếu bằng nhau
    
KHONG_BANG:          
    OR   AL, 1                   ; Cờ Zero=0 nếu không bằng
    RET
KIEM_TRA_HANG ENDP

KIEM_TRA_DUONG PROC
    PUSH BX                      ; Lưu BX
    
    MOV  AL, [SI + BX]           ; Ô đầu tiên
    
    ADD  BX, CX                  ; BX = BX + step
    CMP  AL, [SI + BX]           ; So với ô thứ hai
    JNE  KHONG_KHOP
    
    ADD  BX, CX                  ; BX = BX + step thêm lần nữa
    CMP  AL, [SI + BX]           ; So với ô thứ ba
    JNE  KHONG_KHOP
    
    POP  BX                      ; Khôi phục BX
    RET                          ; Cờ Zero=1 nếu bằng nhau
    
KHONG_KHOP:          
    POP  BX                      ; Khôi phục BX
    OR   AL, 1                   ; Cờ Zero=0 nếu không bằng
    RET
KIEM_TRA_DUONG ENDP

END MAIN