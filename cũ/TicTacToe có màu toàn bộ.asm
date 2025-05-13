; TIC TAC TOE V1.6
.MODEL SMALL 
.STACK 100H
.DATA
    BANG       DB '123456789'   ; Ma trận 3x3 dạng 1 chiều
    HIENTHI    DB 13,10,'  |   |  ',13,10,'---------',13,10,'  |   |  ',13,10
               DB '---------',13,10,'  |   |  ',13,10,13,10,'$'
    VITRI      DB 2,6,10,24,28,32,46,50,54    ; Vị trí ký tự trong HIENTHI
    LUOT_X     DB 'Nhap vi tri (1-9). Luot X: $'
    LUOT_O     DB 'Nhap vi tri (1-9). Luot O: $'
    NUOC_SAI   DB ' Khong hop le! Thu lai.',13,10,'$'
    X_THANG    DB 'NGUOI THANG: X$'
    O_THANG    DB 'NGUOI THANG: O$'
    HOA_VAN    DB 'HOA VAN$'
    CHOI_LAI   DB 'Choi lai? (Y/N): $'
    LUOT_CHOI  DB 'X'                   ; Lưu X hoặc O
    LUOT_DAU   DB 'O'                   ; Lưu người chơi đi trước
    XUONG_DONG DB 13, 10, '$'           ; CR+LF
    KET_QUA    DB ' ', '$'              ; X, O hoặc D (draw) 
    BANG_WIN   DW 1,2,3, 4,5,6, 7,8,9, 1,4,7, 2,5,8, 3,6,9, 1,5,9, 3,5,7
    MAU_CHU    DB 09h                   ; Màu xanh dương sáng (09h)

.CODE
MAIN PROC
    MOV  AX, @DATA       ; Khởi tạo DS
    MOV  DS, AX
    CALL KHOI_TAO        ; Bắt đầu game mới
    CALL XOA_MAN_HINH    ; Xóa màn hình với màu xanh dương sáng
     
VONG_CHOI: 
    CALL IN_BANG         ; Vẽ bảng
    CALL NHAP_NUOC       ; Nhận input
    CALL KT_KET_THUC     ; Kiểm tra kết thúc
    CMP  AL, 1           ; AL=1 nếu có người thắng/hòa
    JE   KET_THUC      
    CALL DOI_LUOT        ; Đổi người chơi
    JMP  VONG_CHOI       ; Lặp lại vòng chơi
     
KET_THUC:             
    CALL IN_BANG         ; Vẽ bảng cuối
    MOV  AH, 9           ; Int 21h/9
    MOV  AL, KET_QUA     ; X, O hoặc D
    LEA  DX, X_THANG     ; Mặc định X thắng
    CMP  AL, 'X'
    JE   HIEN_KQ
    LEA  DX, O_THANG     ; Nếu O thắng
    CMP  AL, 'O'
    JE   HIEN_KQ
    LEA  DX, HOA_VAN     ; Nếu hòa
    
HIEN_KQ:
    INT  21H
    MOV  AH, 9
    LEA  DX, XUONG_DONG
    INT  21H
    LEA  DX, CHOI_LAI
    INT  21H
    MOV  AH, 1           ; Đợi nhập phím
    INT  21H
    AND  AL, 0DFh        ; Chuyển sang chữ hoa
    CMP  AL, 'Y'
    JNE  THOAT
    CALL KHOI_TAO        ; Reset game
    CALL XOA_MAN_HINH    ; Xóa màn hình với màu xanh dương sáng
    JMP  VONG_CHOI
    
THOAT:
    MOV  AH, 4Ch         ; Thoát chương trình
    INT  21H
MAIN ENDP

; Hàm xóa màn hình với màu nền đen và chữ xanh dương sáng
XOA_MAN_HINH PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV  AH, 06h         ; Yêu cầu cuộn cửa sổ lên
    MOV  AL, 0           ; Xóa toàn bộ màn hình
    MOV  BH, MAU_CHU     ; Màu chữ (bit 0-3) và nền (bit 4-7)
    MOV  CX, 0           ; Góc trên trái (0,0)
    MOV  DH, 24          ; Dòng cuối cùng
    MOV  DL, 79          ; Cột cuối cùng
    INT  10h             ; Gọi ngắt BIOS
    
    ; Đặt vị trí con trỏ về đầu màn hình
    MOV  AH, 02h
    MOV  BH, 0
    MOV  DX, 0
    INT  10h
    
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET
XOA_MAN_HINH ENDP

; Hàm đặt thuộc tính màu văn bản
DAT_MAU PROC
    PUSH AX
    PUSH BX
    
    MOV  AH, 0Eh         ; Hiển thị ký tự Teletype với màu
    MOV  BL, MAU_CHU     ; Màu xanh dương sáng
    
    POP  BX
    POP  AX
    RET
DAT_MAU ENDP

KHOI_TAO PROC
    LEA  SI, BANG        ; Trỏ đến bảng
    MOV  BL, '1'         ; Bắt đầu từ ký tự '1'
    MOV  CX, 9           ; 9 ô cần khởi tạo
LAP_RESET:          
    MOV  [SI], BL        ; Đánh số ô
    INC  BL
    INC  SI
    LOOP LAP_RESET
    MOV  AL, 'X' + 'O'   ; Tổng = 167 
    SUB  AL, LUOT_DAU    ; Hoán đổi X<->O
    MOV  LUOT_DAU, AL    ; Cập nhật người đi trước
    MOV  LUOT_CHOI, AL   ; Đặt lượt chơi hiện tại
    RET
KHOI_TAO ENDP

IN_BANG PROC
    CALL XOA_MAN_HINH    ; Xóa màn hình với màu xanh dương sáng
    MOV  CX, 9           ; 9 ô cần cập nhật
    XOR  SI, SI          ; SI = 0
LAP_IN:
    MOV  AL, VITRI[SI]   ; Vị trí cần cập nhật
    CBW                  ; Chuyển AL thành AX
    MOV  DI, AX
    MOV  AL, BANG[SI]    ; Lấy ký tự từ bảng
    MOV  HIENTHI[DI], AL ; Cập nhật vào chuỗi hiển thị
    INC  SI
    LOOP LAP_IN
    LEA  DX, HIENTHI
    MOV  AH, 9           ; In bảng
    INT  21H
    RET
IN_BANG ENDP

NHAP_NUOC PROC
    MOV  AH, 9
    LEA  DX, LUOT_X      ; Thông báo lượt X
    CMP  LUOT_CHOI, 'X'
    JE   HIEN_NHAP
    LEA  DX, LUOT_O      ; Hoặc lượt O
     
HIEN_NHAP:            
    INT  21H
    MOV  AH, 1           ; Nhận input
    INT  21H
    CMP  AL, '1'         ; Kiểm tra hợp lệ
    JL   NHAP_SAI
    CMP  AL, '9'
    JG   NHAP_SAI
    SUB  AL, '1'         ; Chuyển '1'-'9' thành 0-8
    MOV  BL, AL
    XOR  BH, BH          ; BX = 0-8
    LEA  SI, BANG
    ADD  SI, BX          ; SI = địa chỉ ô được chọn
    MOV  AL, [SI]
    CMP  AL, 'X'         ; Kiểm tra ô đã đánh chưa
    JE   NHAP_SAI
    CMP  AL, 'O'
    JE   NHAP_SAI
    MOV  AL, LUOT_CHOI   ; Đánh dấu X hoặc O
    MOV  [SI], AL
    MOV  AH, 9
    LEA  DX, XUONG_DONG  ; Xuống dòng
    INT  21H
    RET
    
NHAP_SAI:            
    MOV  AH, 9
    LEA  DX, NUOC_SAI    ; Thông báo nước đi không hợp lệ
    INT  21H
    JMP  NHAP_NUOC       ; Nhập lại
NHAP_NUOC ENDP

DOI_LUOT PROC
    MOV  AL, 'X' + 'O'   ; Tổng = 167 
    SUB  AL, LUOT_CHOI   ; Hoán đổi X<->O
    MOV  LUOT_CHOI, AL
    RET
DOI_LUOT ENDP

KT_KET_THUC PROC
    XOR  SI, SI          ; SI = 0
    MOV  CX, 8           ; 8 cách thắng cần kiểm tra
    
KT_THANG:
    MOV  BX, BANG_WIN[SI]; Lấy vị trí thứ 1
    MOV  AH, BANG[BX-1]
    MOV  BX, BANG_WIN[SI+2]; Lấy vị trí thứ 2
    CMP  AH, BANG[BX-1]  ; So sánh 1 và 2
    JNZ  KHONG_THANG
    MOV  BX, BANG_WIN[SI+4]; Lấy vị trí thứ 3
    CMP  AH, BANG[BX-1]  ; So sánh 1 và 3
    JNZ  KHONG_THANG
    MOV  KET_QUA, AH     ; Lưu người thắng
    MOV  AL, 1           ; Báo game kết thúc
    RET
     
KHONG_THANG: 
    ADD  SI, 6           ; Chuyển đến bộ 3 ô tiếp theo
    LOOP KT_THANG

    LEA  SI, BANG        ; Kiểm tra hòa
    MOV  CX, 9
KT_HOA: 
    MOV  AL, [SI]        ; Lấy ký tự ô hiện tại
    CMP  AL, '9'         ; Nếu còn số (chưa đánh)
    JBE  CHUA_HOA        ; Thì chưa hòa
    INC  SI
    LOOP KT_HOA
    MOV  KET_QUA, 'D'    ; Đánh dấu hòa (Draw)
    MOV  AL, 1           ; Báo game kết thúc
    RET
     
CHUA_HOA:
    XOR  AL, AL          ; AL = 0 (Game chưa kết thúc)
    RET
KT_KET_THUC ENDP

END MAIN