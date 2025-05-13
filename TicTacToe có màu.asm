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
    MAU_X      DB 0Ch                   ; Màu đỏ sáng
    MAU_O      DB 0Ah                   ; Màu xanh lá sáng
    MAU_MAC_DINH DB 07h                 ; Màu mặc định (trắng trên đen)

.CODE
MAIN PROC
    MOV  AX, @DATA       ; Khởi tạo DS
    MOV  DS, AX
    CALL KHOI_TAO        ; Bắt đầu game mới
     
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
    JMP  VONG_CHOI
    
THOAT:
    MOV  AH, 4Ch         ; Thoát chương trình
    INT  21H
MAIN ENDP

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
    MOV  AX, 3            ; Xóa màn hình
    INT  10H
    MOV  DI, 0            ; Vị trí bắt đầu của HIENTHI
    
HIEN_THI_BANG:
    MOV  AL, HIENTHI[DI]  ; Lấy ký tự từ chuỗi HIENTHI
    CMP  AL, '$'          ; Nếu gặp ký tự kết thúc
    JE   KET_THUC_HIEN_THI
    MOV  CX, 9            ; 9 vị trí cần kiểm tra
    XOR  SI, SI           ; SI = 0
    
KIEM_TRA_VI_TRI:
    MOV  BL, VITRI[SI]    ; Lấy giá trị byte từ VITRI
    XOR  BH, BH           ; Chuyển đổi thành word
    CMP  DI, BX           ; So sánh DI với BX
    JE   HIEN_THI_O       ; Nếu là vị trí ô, hiển thị ký tự từ BANG
    INC  SI
    LOOP KIEM_TRA_VI_TRI
    
    MOV  BH, 0            ; Trang hiển thị 0
    MOV  BL, MAU_MAC_DINH ; Màu mặc định
    MOV  AH, 0Eh          ; Chức năng hiển thị ký tự
    INT  10h              ; Hiển thị ký tự trong AL
    INC  DI
    JMP  HIEN_THI_BANG
    
HIEN_THI_O:
    MOV  BX, SI           ; BX = chỉ số ô (0-8)
    MOV  AL, BANG[BX]     ; Lấy ký tự từ BANG
    PUSH DI               ; Lưu vị trí hiện tại
    MOV  BH, 0            ; Trang 0
    MOV  BL, MAU_MAC_DINH ; Mặc định
    CMP  AL, 'X'
    JNE  CHECK_O
    MOV  BL, MAU_X        ; Màu đỏ cho X
    JMP  HIEN_KY_TU
    
CHECK_O:
    CMP  AL, 'O'
    JNE  HIEN_KY_TU
    MOV  BL, MAU_O        ; Màu xanh lá cho O
    
HIEN_KY_TU:
    MOV  AH, 09h          ; Hàm hiển thị ký tự và thuộc tính
    MOV  CX, 1            ; Hiển thị 1 ký tự
    INT  10h              ; Hiển thị ký tự với màu
    MOV  AH, 03h          ; Lấy vị trí con trỏ
    INT  10h              ; DH = dòng, DL = cột
    INC  DL               ; Tăng cột
    MOV  AH, 02h          ; Đặt vị trí con trỏ
    INT  10h
    POP  DI               ; Khôi phục vị trí trong chuỗi
    INC  DI
    JMP  HIEN_THI_BANG
    
KET_THUC_HIEN_THI:
    RET
IN_BANG ENDP

NHAP_NUOC PROC
    MOV  AH, 9
    LEA  DX, LUOT_X       ; Thông báo lượt X
    CMP  LUOT_CHOI, 'X'
    JE   HIEN_NHAP
    LEA  DX, LUOT_O       ; Hoặc lượt O
     
HIEN_NHAP:            
    INT  21H
    MOV  AH, 1            ; Nhận input
    INT  21H
    CMP  AL, '1'          ; Kiểm tra hợp lệ
    JL   NHAP_SAI
    CMP  AL, '9'
    JG   NHAP_SAI
    SUB  AL, '1'          ; Chuyển '1'-'9' thành 0-8
    MOV  BL, AL
    XOR  BH, BH           ; BX = 0-8
    LEA  SI, BANG
    ADD  SI, BX           ; SI = địa chỉ ô được chọn
    MOV  AL, [SI]
    CMP  AL, 'X'          ; Kiểm tra ô đã đánh chưa
    JE   NHAP_SAI
    CMP  AL, 'O'
    JE   NHAP_SAI
    MOV  AL, LUOT_CHOI    ; Đánh dấu X hoặc O
    MOV  [SI], AL
    MOV  AH, 9
    LEA  DX, XUONG_DONG   ; Xuống dòng
    INT  21H
    RET
    
NHAP_SAI:            
    MOV  AH, 9
    LEA  DX, NUOC_SAI     ; Thông báo nước đi không hợp lệ
    INT  21H
    JMP  NHAP_NUOC        ; Nhập lại
NHAP_NUOC ENDP

DOI_LUOT PROC
    MOV  AL, 'X' + 'O'    ; Tổng = 167 
    SUB  AL, LUOT_CHOI    ; Hoán đổi X<->O
    MOV  LUOT_CHOI, AL
    RET
DOI_LUOT ENDP

KT_KET_THUC PROC
    XOR  SI, SI           ; SI = 0
    MOV  CX, 8            ; 8 cách thắng cần kiểm tra
    
KT_THANG:
    MOV  BX, BANG_WIN[SI] ; Lấy vị trí thứ 1
    MOV  AH, BANG[BX-1]
    MOV  BX, BANG_WIN[SI+2] ; Lấy vị trí thứ 2
    CMP  AH, BANG[BX-1]   ; So sánh 1 và 2
    JNZ  KHONG_THANG
    MOV  BX, BANG_WIN[SI+4] ; Lấy vị trí thứ 3
    CMP  AH, BANG[BX-1]   ; So sánh 1 và 3
    JNZ  KHONG_THANG
    MOV  KET_QUA, AH      ; Lưu người thắng
    MOV  AL, 1            ; Báo game kết thúc
    RET
     
KHONG_THANG: 
    ADD  SI, 6            ; Chuyển đến bộ 3 ô tiếp theo
    LOOP KT_THANG

    LEA  SI, BANG         ; Kiểm tra hòa
    MOV  CX, 9
KT_HOA: 
    MOV  AL, [SI]         ; Lấy ký tự ô hiện tại
    CMP  AL, '9'          ; Nếu còn số (chưa đánh)
    JBE  CHUA_HOA         ; Thì chưa hòa
    INC  SI
    LOOP KT_HOA
    MOV  KET_QUA, 'D'     ; Đánh dấu hòa (Draw)
    MOV  AL, 1            ; Báo game kết thúc
    RET
     
CHUA_HOA:
    XOR  AL, AL           ; AL = 0 (Game chưa kết thúc)
    RET
KT_KET_THUC ENDP

END MAIN