; TIC TAC TOE V1.4
.MODEL SMALL 
.STACK 100H
.DATA
    BANG       DB '123456789'   ; Mảng 3x3 lưu vị trí
    BTXT       DB 0DH,0AH
               DB '  |   |  ',0DH,0AH
               DB '---------',0DH,0AH
               DB '  |   |  ',0DH,0AH
               DB '---------',0DH,0AH
               DB '  |   |  ',0DH,0AH,0DH,0AH,'$'
    BPOS       DB 2,6,10,24,28,32,46,50,54  ; Vị trí hiển thị trong BTXT
    LUOT_X     DB 'Luot X. Nhap vi tri (1-9): $'
    LUOT_O     DB 'Luot O. Nhap vi tri (1-9): $'
    NUOC_LOI   DB 'Nuoc di khong hop le! Thu lai.$'
    X_THANG    DB 'NGUOI CHOI X THANG CUOC!$'
    O_THANG    DB 'NGUOI CHOI O THANG CUOC!$'
    VAN_HOA    DB 'VAN HOA$'
    CHOI_LAI   DB 'Choi lai? (Y/N): $'
    NGUOI_CHOI DB 'X'           ; Lượt hiện tại
    XUONG_DONG DB 13, 10, '$'   ; CR+LF
    NGUOI_THANG DB ' ','$'      ; Giá trị kết thúc: X, O hoặc D
    WINS       DW 1,2,3, 4,5,6, 7,8,9        ; Các hàng ngang
               DW 1,4,7, 2,5,8, 3,6,9        ; Các cột dọc
               DW 1,5,9, 3,5,7              ; Các đường chéo

.CODE
MAIN PROC
    ; Khởi tạo dữ liệu và gọi vòng lặp trò chơi
    MOV AX, @DATA
    MOV DS, AX
    CALL KHOI_TAO
    
VONG_CHOI:
    ; Hiển thị bảng, nhập nước đi, kiểm tra kết thúc
    CALL IN_BANG
    CALL NHAP_NUOC_DI
    CALL KIEM_TRA_KET_THUC
    CMP  AL, 1
    JE   KET_THUC
    CALL DOI_NGUOI_CHOI
    JMP  VONG_CHOI
    
KET_THUC:            
    ; Hiển thị bảng cuối, thông báo kết quả, hỏi chơi tiếp
    CALL IN_BANG
    
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
    LEA  DX, CHOI_LAI           ; Hỏi chơi lại
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

; Gán lại giá trị ban đầu cho mảng và chọn X đi trước
KHOI_TAO PROC
    LEA  SI, BANG
    MOV  BL, '1'
    MOV  CX, 9
LAP_RESET:          
    MOV  [SI], BL
    INC  BL
    INC  SI
    LOOP LAP_RESET
    
    MOV  NGUOI_CHOI, 'X'        ; Mặc định X đi trước
    RET
KHOI_TAO ENDP

; Xoá toàn bộ màn hình, thiết lập chế độ
XOA_MAN_HINH PROC
    mov ax, 3
    int 10h
    ret
XOA_MAN_HINH ENDP

; In bảng theo mẫu định sẵn
IN_BANG PROC
    call XOA_MAN_HINH
    
    ; Cập nhật bảng hiển thị từ mảng BANG
    MOV CX, 9           ; thiết lập bộ đếm vòng lặp
    SUB SI, SI          ; thiết lập con trỏ chỉ mục
LAP_BANG:
    MOV AL, BPOS[SI]    ; lấy vị trí trên bảng hiển thị
    CBW                 ; chuyển đổi thành word
    MOV DI, AX          ; thiết lập con trỏ đến chuỗi bảng
    MOV AL, BANG[SI]    ; lấy ký hiệu người chơi
    MOV BTXT[DI], AL    ; ghi vào chuỗi bảng
    INC SI              ; tăng con trỏ chỉ mục
    LOOP LAP_BANG       ; lặp lại cho tất cả 9 vị trí
    
    LEA DX, BTXT        ; thiết lập con trỏ đến chuỗi bảng
    MOV AH, 9           ; chức năng hiển thị chuỗi
    INT 21H             ; gọi DOS
    RET
IN_BANG ENDP

; Lấy nước đi của người chơi
NHAP_NUOC_DI PROC
    MOV  AH, 9
    LEA  DX, LUOT_X              ; Mặc định là lượt X
    CMP  NGUOI_CHOI, 'X'        ; Kiểm tra lượt
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
    MOV  AL, NGUOI_CHOI         ; Lấy giá trị hiện tại
    XOR  AL, 17h                ; Đổi X <-> O (17h = 'X' XOR 'O' = 88 XOR 79)
    MOV  NGUOI_CHOI, AL
    RET
DOI_NGUOI_CHOI ENDP

; Kiểm tra kết thúc sử dụng mảng WINS
KIEM_TRA_KET_THUC PROC
    SUB SI, SI           ; Xoá con trỏ chỉ mục
    MOV CX, 8            ; Thiết lập bộ đếm vòng lặp - 8 trường hợp thắng
    
KIEM_TRA_THANG:
    MOV DI, WINS[SI]     ; Lấy vị trí đầu tiên
    MOV AH, BANG[DI-1]   ; Lấy ký hiệu trên bảng
    
    MOV DI, WINS[SI+2]   ; Lấy vị trí thứ hai
    MOV BL, BANG[DI-1]   ; Lấy ký hiệu trên bảng
    
    MOV DI, WINS[SI+4]   ; Lấy vị trí thứ ba
    MOV BH, BANG[DI-1]   ; Lấy ký hiệu trên bảng
    
    ADD SI, 6            ; Chuyển đến bộ vị trí tiếp theo
    
    CMP AH, BL           ; Kiểm tra cả ba ký hiệu có giống nhau?
    JNZ KHONG_THANG
    CMP AH, BH
    JNZ KHONG_THANG
    
    MOV NGUOI_THANG, AH  ; Lưu người thắng
    MOV AL, 1
    RET
    
KHONG_THANG:
    LOOP KIEM_TRA_THANG  ; Không trùng khớp, thử nhóm khác
    
    ; Kiểm tra hoà
    LEA SI, BANG
    MOV CX, 9
KIEM_TRA_HOA:
    MOV AL, [SI]
    CMP AL, 'X'          ; Kiểm tra là X?
    JZ KIEM_TIEP
    CMP AL, 'O'          ; Kiểm tra là O?
    JZ KIEM_TIEP
    XOR AL, AL           ; Vẫn còn ô trống
    RET                  ; Chưa hoà - vẫn còn ô trống
    
KIEM_TIEP:
    INC SI               ; Chuyển đến vị trí tiếp theo
    LOOP KIEM_TRA_HOA    ; Kiểm tra ký hiệu bảng khác
    
    MOV NGUOI_THANG, 'D' ; Game hoà
    MOV AL, 1
    RET
KIEM_TRA_KET_THUC ENDP

END MAIN