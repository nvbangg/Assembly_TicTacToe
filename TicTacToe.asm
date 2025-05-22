.model small        
.stack 100h        
.data               
    ki_tu db '123456789'            ; mảng kí tự trong các ô (ban đầu là 1-9)
    bang db 13,10, '   |   |   ',13,10, '-----------',13,10, '   |   |   ',13,10, '-----------',13,10, '   |   |   ',13,10,'$' ; giao diện bảng trên màn hình  
    pos dw 3,7,11,29,33,37,55,59,63 ; vị trí các 'ki_tu' trong 'bang' để cập nhật
    msg_turn db 13,10, ' Nhap vi tri (1-9). Luot X: $'  
    msg_invalid db '    Khong hop le! Thu lai.$' 
    msg_win db 13,10, ' NGUOI THANG: X$'  
    msg_hoa db 13,10, ' HOA VAN$'          
    msg_replay db 13,10, ' Choi lai? (Y/N): $'  
    turn db 'X'             ; lưu lượt chơi hiện tại: X hoặc O
    turn_begin db 'O'       ; lưu lượt chơi đầu mỗi vòng 
    res db ' ', '$'         ; lưu kết quả: X, O hoặc H (hòa) 
    mang_win dw 1,2,3, 4,5,6, 7,8,9, 1,4,7, 2,5,8, 3,6,9, 1,5,9, 3,5,7  ; mảng lưu các bộ 3 vị trí thắng
    score_x db 0            ; Số ván thắng của X
    score_o db 0            ; Số ván thắng của O
    msg_score db 13,10, ' Ti so X/O:  - ', '$' ; Chuỗi hiển thị tỉ số 

.code               
main proc              
    mov ax, @data   
    mov ds, ax      
    call init       
    game_loop:          
        call ve_bang    
        call nhap_nuoc      
        call check_end      
        cmp al, 1           ; kiểm tra al=1 (có người thắng/hòa)
        je game_over        
        call doi_luot       
        jmp game_loop     
    game_over:          
        call ve_bang    
        mov ah, 9           ; dùng hàm 9 để in chuỗi
        mov al, res         ; lấy kết quả (X, O hoặc H)
        lea dx, msg_hoa     ; Mặc định là msg_hoa
        cmp al, 'H'         ; Nếu không phải hòa thì hiển thị người thắng
        je hien_kq
        mov msg_win[16], al ; Cập nhật kí tự trong thông báo thắng
        lea dx, msg_win     ; Đổi sang thông báo thắng
    hien_kq:
        int 21h             ; in kết quả
        call hien_score     ; in tỉ số
        lea dx, msg_replay  ; in thông báo hỏi chơi lại
        int 21h
        mov ah, 1           ; hàm 1 để nhập ký tự (lưu trong al)
        int 21h             
        and al, 0dfh        ; chuyển ký tự thành chữ hoa
        cmp al, 'Y'         
        jne exit            ; al=Y thì exit
        call init           ; al!=Y thì reset game
        jmp game_loop       
    exit:
        mov ah, 4ch         ; hàm 4Ch thoát chương trình
        int 21h
main endp
    
hien_score proc
    mov al, score_x         ; chuyển điểm X thành ký tự
    add al, '0'             
    mov msg_score[14], al   ; lưu điểm X vào msg_score
    mov al, score_o         ; chuyển điểm O thành ký tự
    add al, '0'            
    mov msg_score[16], al   ; lưu điểm O vào msg_score
    mov ah, 9               ; in chuỗi tỉ số
    lea dx, msg_score
    int 21h
    ret
hien_score endp

init proc           
    lea si, ki_tu           ; si trỏ đến mảng kí tự
    mov bl, '1'             ; bl bắt đầu từ ký tự '1'
    mov cx, 9               ; cx=9 để lặp 9 lần
    reset:                  
        mov [si], bl        ; gán giá trị bl vào ô hiện tại
        inc bl              ; tăng bl lên 1
        inc si              ; trỏ đến ô tiếp theo
        loop reset          ; lặp reset đến khi cx=0
    mov al, 'X'+'O'         ; đổi lượt chơi đầu bằng 'X'+'O' - turn_begin
    sub al, turn_begin  
    mov turn_begin, al      ; cập nhật turn_begin và turn hiện tại
    mov turn, al        
    ret                     ; trở về hàm gọi
init endp

ve_bang proc    
    mov ax, 3               ; hàm 3 của ngắt 10h để xóa màn hình
    int 10h
    mov cx, 9               ; cx=9 để lặp 9 lần
    mov si, 0               ; đặt si=0 (bắt đầu từ ô đầu tiên)
    update_cell:            ; vòng lặp cập nhật từng ô
        mov bx, si          ; bx=si*2 (vì pos lưu dạng dw cần 2B)
        add bx, bx          
        mov di, pos[bx]     ; lấy vị trí cần cập nhật trong chuỗi bang và lưu vào di
        mov al, ki_tu[si]   ; lấy ký tự từ mảng bảng
        mov bang[di], al    ; cập nhật ký tự vào chuỗi hiển thị
        inc si              ; tăng si (chuyển đến ô tiếp theo)
        loop update_cell    ; lặp update_cell đến khi cx=0
    mov ah, 9           
    lea dx, bang            ; in bảng
    int 21h             
    ret                 
ve_bang endp

nhap_nuoc proc      
    mov ah, 9               ; hàm 9 để in chuỗi
    mov al, turn            ; Lấy lượt chơi hiện tại (X hoặc O)
    mov msg_turn[27], al    ; Cập nhật kí tự trong thông báo
    lea dx, msg_turn        ; Chuẩn bị in thông báo lượt chơi
    hien_nhap:              
        int 21h             ; in thông báo lượt chơi
        mov ah, 1           ; hàm 1 để nhập ký tự (lưu trong al)
        int 21h             
        cmp al, '1'         
        jl nhap_sai         ; nếu nhỏ hơn '1' thì nhập sai
        cmp al, '9'         
        jg nhap_sai         ; nếu lớn hơn '9' thì nhập sai
        sub al, '1'         ; chuyển '1'-'9' thành 0-8 (chỉ số mảng)
        mov bl, al          ; lưu vào bl
        mov bh, 0           ; bh=0 để bx=bl
        lea si, ki_tu       ; si trỏ đến mảng kí tự
        add si, bx          ; si= địa chỉ ô được chọn
        mov al, [si]        ; lấy giá trị ô và kiểm tra ô đánh chưa (có x hoặc o) 
        cmp al, 'X'         
        je nhap_sai         
        cmp al, 'O'         
        je nhap_sai         
        mov al, turn        ; lấy lượt chơi hiện tại (X/O)
        mov [si], al        ; đánh dấu X hoặc O vào ô
        ret                 
    nhap_sai:               
        mov ah, 9           ; hàm 9 để in chuỗi
        lea dx, msg_invalid ; in thông báo nước đi không hợp lệ
        int 21h 
        jmp nhap_nuoc       ; quay lại nhập lại
nhap_nuoc endp

doi_luot proc       
    mov al, 'X'+'O'         ; đổi lượt chơi bằng 'X'+'O' - turn
    sub al, turn        
    mov turn, al        
    ret                 
doi_luot endp

check_end proc      
    mov si, 0                   ; si=0 để bắt đầu từ ô đầu tiên
    mov cx, 8                   ; cx=8 để lặp 8 lần
    check_win:                  
        mov bx, mang_win[si]    ; lấy vị trí thứ 1 trong bộ 3 mang_win
        mov ah, ki_tu[bx-1]     ; lấy ki_tu tại vị trí đó (trừ 1 vì mảng từ 0)
        mov bx, mang_win[si+2]  ; lấy vị trí thứ 2 trong bộ 3 mang_win
        cmp ah, ki_tu[bx-1]     ; so sánh ki_tu tại vị trí 1 và 2
        jnz chua_win            ; nếu khác nhau thì chưa thắng
        mov bx, mang_win[si+4]  ; lấy vị trí thứ 3 trong bộ 3 mang_win
        cmp ah, ki_tu[bx-1]     ; so sánh ki_tu tại vị trí 1 và 3
        jnz chua_win            ; nếu khác nhau thì chưa thắng
        mov res, ah             ; nếu giống nhau thì lưu người thắng (X/O)
        cmp ah, 'X'             ; nếu X thắng
        je inc_score_x
        cmp ah, 'O'             ; nếu O thắng
        je inc_score_o
    inc_score_x:
        inc score_x
        jmp end_check_win
    inc_score_o:
        inc score_o
        jmp end_check_win
    end_check_win:
        mov al, 1               ; al = 1 báo hiệu game kết thúc
        ret                              
    chua_win:                   ; xử lý khi chưa thắng ở bộ 3 hiện tại
        add si, 6               ; tăng si lên 6 (mỗi bộ 3 chiếm 6 byte trong mang_win)
        loop check_win          ; lặp check_win đến khi cx=0
        lea si, ki_tu               ; si trỏ đến mảng kí tự
        mov cx, 9                   ; cx=9 để lặp 9 lần
    check_hoa:                  
        mov al, [si]            ; lấy giá trị ô hiện tại
        cmp al, '9'             
        jbe chua_hoa            ; nếu <= '9' thì còn ô chưa đánh -> chưa hòa
        inc si                  ; tăng si (kiểm tra ô tiếp)
        loop check_hoa          ; lặp check_hoa đến khi cx=0
        mov res, 'H'            ; nếu tất cả ô đều đã đánh thì đánh dấu hòa
        mov al, 1               ; al=1 báo hiệu game kết thúc
        ret                     
    chua_hoa:                   ; xử lý khi chưa hòa
        mov al, 0               ; al=0 (game chưa kết thúc)
        ret                     
check_end endp
end main 