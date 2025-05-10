; TIC TAC TOE V1.4.2
.MODEL SMALL 
.STACK 100H
.DATA
    BANG       DB '123456789'   ; Lưu trạng thái 9 ô của bảng 3x3
    HIENTHI    DB 13,10
               DB '  |   |  ',13,10
               DB '---------',13,10
               DB '  |   |  ',13,10
               DB '---------',13,10
               DB '  |   |  ',13,10,13,10,'$' ; Mẫu hiển thị bảng trên màn hình
    VITRI      DB 2,6,10,24,28,32,46,50,54    ; Vị trí cần sửa trong HIENTHI
    LUOT_X     DB 'Nhap vi tri (1-9). Luot X: $'
    LUOT_O     DB 'Nhap vi tri (1-9). Luot O: $'
    NUOC_SAI   DB 'Khong hop le! Thu lai.$'
    X_THANG    DB 'NGUOI THANG: X$'
    O_THANG    DB 'NGUOI THANG: O$'
    HOA_VAN    DB 'HOA VAN$'
    CHOI_LAI   DB 'Choi lai? (Y/N): $'
    LUOT_CHOI  DB 'X'                   ; Người chơi hiện tại (X hoặc O)
    XUONG_DONG DB 13, 10, '$'           ; Ký tự xuống dòng và về đầu dòng
    KET_QUA    DB ' ', '$'              ; Lưu kết quả: X, O hoặc D (hòa) 
    BANG_WIN   DW 1,2,3, 4,5,6, 7,8,9   ; Các hàng ngang
               DW 1,4,7, 2,5,8, 3,6,9   ; Các cột dọc
               DW 1,5,9, 3,5,7          ; Các đường chéo

.CODE
MAIN PROC
    MOV AX, @DATA       ; Nạp địa chỉ phân đoạn dữ liệu
    MOV DS, AX          ; Khởi tạo DS
    CALL KHOI_TAO       ; Thiết lập trạng thái ban đầu
     
VONG_CHOI: 
    CALL IN_BANG        ; Hiển thị bảng hiện tại
    CALL NHAP_NUOC      ; Nhận lượt đánh từ người dùng
    CALL KT_KET_THUC    ; Kiểm tra đã kết thúc chưa
    CMP  AL, 1          ; AL=1 nếu game kết thúc
    JE   KET_THUC       ; Nếu kết thúc thì nhảy tới xử lý
    CALL DOI_LUOT       ; Đổi lượt người chơi
    JMP  VONG_CHOI      ; Quay lại vòng lặp chính
     
KET_THUC:             
    CALL IN_BANG        ; Hiển thị bảng cuối cùng
     
    MOV  AH, 9          ; Hàm hiển thị chuỗi
    MOV  AL, KET_QUA    ; Lấy kết quả (X, O hoặc D)
     
    LEA  DX, X_THANG    ; Chuẩn bị thông báo X thắng
    CMP  AL, 'X'        ; So sánh với X
    JE   HIEN_KQ        ; Nếu X thắng thì hiển thị
     
    LEA  DX, O_THANG    ; Chuẩn bị thông báo O thắng
    CMP  AL, 'O'        ; So sánh với O
    JE   HIEN_KQ        ; Nếu O thắng thì hiển thị
     
    LEA  DX, HOA_VAN    ; Mặc định là hòa
    
HIEN_KQ:
    INT  21H            ; Hiển thị thông báo kết quả
    
    LEA  DX, XUONG_DONG ; Xuống dòng
    INT  21H
    
    LEA  DX, CHOI_LAI   ; Hiển thị thông báo chơi lại
    INT  21H
    
    MOV  AH, 1          ; Nhận phím người dùng nhập
    INT  21H
    
    AND  AL, 0DFh       ; Chuyển thành chữ hoa nếu là chữ thường
    
    CMP  AL, 'Y'        ; Kiểm tra có phải 'Y'
    JNE  THOAT          ; Nếu không phải thì thoát game
    
    CALL KHOI_TAO       ; Khởi tạo lại trò chơi mới
    JMP  VONG_CHOI      ; Trở lại vòng lặp chính
    
THOAT:
    MOV  AH, 4Ch        ; Chức năng thoát chương trình
    INT  21H            ; Gọi ngắt DOS
MAIN ENDP

KHOI_TAO PROC
    LEA  SI, BANG       ; Trỏ SI đến mảng BANG
    MOV  BL, '1'        ; Bắt đầu từ ký tự '1'
    MOV  CX, 9          ; 9 ô cần khởi tạo
LAP_RESET:          
    MOV  [SI], BL       ; Gán giá trị ký tự vào mảng
    INC  BL             ; Tăng giá trị ký tự
    INC  SI             ; Chuyển sang ô tiếp theo
    LOOP LAP_RESET      ; Lặp cho đến khi hoàn thành
    
    MOV  LUOT_CHOI, 'X' ; X đi trước
    RET                 ; Trở về hàm gọi
KHOI_TAO ENDP

XOA_MH PROC
    MOV AX, 3           ; Chế độ văn bản 80x25
    INT 10H             ; Gọi ngắt BIOS để xóa màn hình
    RET                 ; Trở về hàm gọi
XOA_MH ENDP

IN_BANG PROC
    CALL XOA_MH         ; Làm sạch màn hình trước khi vẽ
    
    MOV CX, 9           ; Số ô cần cập nhật
    SUB SI, SI          ; SI = 0 (chỉ số của mảng)
LAP_IN:
    MOV AL, VITRI[SI]   ; Lấy vị trí trong chuỗi hiển thị
    CBW                 ; Chuyển AL thành AX
    MOV DI, AX          ; DI là vị trí cần sửa trong HIENTHI
    MOV AL, BANG[SI]    ; Lấy giá trị từ mảng BANG
    MOV HIENTHI[DI], AL ; Cập nhật chuỗi hiển thị
    INC SI              ; Tăng chỉ số
    LOOP LAP_IN         ; Lặp cho tất cả các ô
     
    LEA DX, HIENTHI     ; Nạp địa chỉ chuỗi hiển thị
    MOV AH, 9           ; Hàm hiển thị chuỗi
    INT 21H             ; Gọi ngắt DOS
    RET                 ; Trở về hàm gọi
IN_BANG ENDP

NHAP_NUOC PROC
    MOV  AH, 9          ; Hàm hiển thị chuỗi
    LEA  DX, LUOT_X     ; Mặc định thông báo lượt X
    CMP  LUOT_CHOI, 'X' ; Kiểm tra lượt hiện tại
    JE   HIEN_NHAP      ; Nếu là X thì hiển thị
    LEA  DX, LUOT_O     ; Nếu là O thì đổi thông báo
     
HIEN_NHAP:            
    INT  21H            ; Hiển thị thông báo lượt đi
     
    MOV  AH, 1          ; Hàm nhận một ký tự
    INT  21H            ; Nhận vị trí từ người dùng
     
    CMP  AL, '1'        ; Kiểm tra nhỏ hơn 1
    JL   NHAP_SAI       ; Không hợp lệ
    CMP  AL, '9'        ; Kiểm tra lớn hơn 9
    JG   NHAP_SAI       ; Không hợp lệ
     
    SUB  AL, '1'        ; Chuyển thành số 0-8
    MOV  BL, AL         ; Lưu vào BL
    XOR  BH, BH         ; BH = 0, BX = 0-8
     
    LEA  SI, BANG       ; Trỏ đến mảng BANG
    ADD  SI, BX         ; Vị trí tương ứng trong mảng
     
    MOV  AL, [SI]       ; Lấy giá trị tại vị trí đó
    CMP  AL, 'X'        ; Kiểm tra đã có X
    JE   NHAP_SAI       ; Nếu có rồi thì không hợp lệ
    CMP  AL, 'O'        ; Kiểm tra đã có O
    JE   NHAP_SAI       ; Nếu có rồi thì không hợp lệ
    
    MOV  AL, LUOT_CHOI  ; Lấy người chơi hiện tại
    MOV  [SI], AL       ; Đánh dấu ô đã chọn
    
    MOV  AH, 9          ; Hàm hiển thị chuỗi
    LEA  DX, XUONG_DONG ; Xuống dòng
    INT  21H            ; Gọi ngắt DOS
    
    RET                 ; Trở về hàm gọi
    
NHAP_SAI:            
    MOV  AH, 9          ; Hàm hiển thị chuỗi
    LEA  DX, XUONG_DONG ; Xuống dòng
    INT  21H            ; Gọi ngắt DOS
    LEA  DX, NUOC_SAI   ; Thông báo lỗi
    INT  21H            ; Gọi ngắt DOS
    LEA  DX, XUONG_DONG ; Xuống dòng nữa
    INT  21H            ; Gọi ngắt DOS
    JMP  NHAP_NUOC      ; Nhập lại
NHAP_NUOC ENDP

DOI_LUOT PROC
    MOV  AL, LUOT_CHOI  ; Lấy người chơi hiện tại
    XOR  AL, 17h        ; Đảo X<->O (17h = 88 XOR 79)
    MOV  LUOT_CHOI, AL  ; Cập nhật lại người chơi
    RET                 ; Trở về hàm gọi
DOI_LUOT ENDP

KT_KET_THUC PROC
    SUB SI, SI              ; SI = 0, chỉ số mảng BANG_WIN
    MOV CX, 8               ; 8 trường hợp thắng cần kiểm tra
    
KT_THANG:
    MOV DI, BANG_WIN[SI]    ; Lấy vị trí đầu tiên
    MOV AH, BANG[DI-1]      ; Lấy ký tự tại vị trí đó
    
    MOV DI, BANG_WIN[SI+2]  ; Lấy vị trí thứ hai
    MOV BL, BANG[DI-1]      ; Lấy ký tự tại vị trí đó
    
    MOV DI, BANG_WIN[SI+4]  ; Lấy vị trí thứ ba
    MOV BH, BANG[DI-1]      ; Lấy ký tự tại vị trí đó
     
    ADD SI, 6               ; Chuyển đến bộ 3 ô tiếp theo
     
    CMP AH, BL              ; So sánh ký tự 1 và 2
    JNZ KHONG_THANG         ; Nếu khác nhau thì không thắng
    CMP AH, BH              ; So sánh ký tự 1 và 3
    JNZ KHONG_THANG         ; Nếu khác nhau thì không thắng
     
    MOV KET_QUA, AH         ; Lưu người thắng
    MOV AL, 1               ; Trả về 1 (đã kết thúc)
    RET                     ; Trở về hàm gọi
     
KHONG_THANG: 
    LOOP KT_THANG           ; Kiểm tra trường hợp tiếp theo
     
    LEA SI, BANG            ; Trỏ đến mảng BANG
    MOV CX, 9               ; 9 ô cần kiểm tra
KT_HOA: 
    MOV AL, [SI]            ; Lấy giá trị ô hiện tại
    CMP AL, 'X'             ; Kiểm tra có phải X
    JZ KT_TIEP              ; Nếu đúng thì kiểm tra ô tiếp
    CMP AL, 'O'             ; Kiểm tra có phải O
    JZ KT_TIEP              ; Nếu đúng thì kiểm tra ô tiếp
    XOR AL, AL              ; AL = 0, game chưa kết thúc
    RET                     ; Trở về hàm gọi
     
KT_TIEP: 
    INC SI                  ; Chuyển đến ô tiếp theo
    LOOP KT_HOA             ; Kiểm tra tiếp
    
    MOV KET_QUA, 'D'        ; Hòa, tất cả ô đều đã đánh
    MOV AL, 1               ; Trả về 1 (đã kết thúc)
    RET                     ; Trở về hàm gọi
KT_KET_THUC ENDP

END MAIN