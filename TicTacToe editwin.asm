.model small        
.stack 100h        
print macro string
    mov ah, 9
    lea dx, string
    int 21h
endm

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
    mang_win dw 1,2, 1,4, 1,5, 2,3, 2,4, 2,5, 2,6, 3,5, 3,6, 4,5, 4,7, 4,8, 5,6, 5,7, 5,8, 5,9, 6,8, 6,9, 7,8, 8,9  ; mảng lưu các bộ 3 vị trí thắng
    score_x db 0            ; số ván thắng của X
    score_o db 0            ; số ván thắng của O
    msg_score db 13,10, ' Ti so X-O:  - ', '$' 

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
        call ve_bang        ; sau lệnh ah vẫn = 9
        mov al, res         ; lấy kết quả (X, O hoặc H)
        lea dx, msg_hoa     ; mặc định là msg_hoa
        cmp al, 'H'         
        je hien_kq
        mov msg_win[16], al ; cập nhật người thắng
        lea dx, msg_win     ; đổi sang thông báo thắng
    hien_kq:
        int 21h             ; in kết quả
        call hien_score     ; in tỉ số
        print msg_replay    
        mov ah, 1           ; nhập ký tự bằng hàm 1
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
    mov al, score_x         ; chuyển điểm X thành ký tự và cập nhật
    add al, '0'             
    mov msg_score[14], al   
    mov al, score_o         ; chuyển điểm O thành ký tự và cập nhật
    add al, '0'            
    mov msg_score[16], al   
    print msg_score         ; in tỉ số
    ret
hien_score endp

init proc           
    lea si, ki_tu           ; si trỏ đến ki_tu
    mov bl, '1'             ; bl bắt đầu từ ký tự '1'
    mov cx, 9               ; lặp 9 lần khởi tạo ki_tu từ '1' đến '9'
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
    mov ax, 0600h           ; ah=06h (lệnh cuộn màn hình), al=00h (cuộn toàn màn hình)
    mov bh, 70h             ; 7 (màu trắng) cho nền, 0 (màu đen) cho chữ
    mov cx, 0000h           ; tọa độ góc trên bên trái (0,0)
    mov dx, 184Fh           ; tọa độ góc dưới bên phải (24,79) 
    int 10h                 ; gọi ngắt 10h để xóa màn hình với màu đã cài đặt
    
    mov ah, 02h             ; chuyển sang lệnh đặt vị trí con trỏ
    mov bh, 0               ; chọn trang màn hình 0 (trang hiển thị)
    mov dx, 0000h           ; đặt con trỏ về vị trí (0,0)
    int 10h                 ; gọi ngắt 10h để di chuyển con trỏ
    
    mov cx, 9               ; lặp 9 lần để cập nhật 9 ô với giá trị từ ki_tu
    mov si, 0               ; đặt si=0 (bắt đầu từ ô đầu tiên)
    update_cell:            
        mov bx, si          ; bx=si*2 (vì pos lưu dạng dw cần 2B)
        add bx, bx          
        mov di, pos[bx]     ; lấy vị trí cần cập nhật trong chuỗi bang và lưu vào di
        mov al, ki_tu[si]   ; lấy ký tự từ mảng bảng
        mov bang[di], al    ; cập nhật ký tự vào chuỗi hiển thị
        inc si              ; tăng si (chuyển đến ô tiếp theo)
        loop update_cell    
    print bang
    ret                 
ve_bang endp

nhap_nuoc proc      
    mov al, turn            ; lấy lượt chơi hiện tại (X hoặc O)
    mov msg_turn[27], al    ; cập nhật kí tự trong thông báo
    hien_nhap:              
        print msg_turn
        mov ah, 1           ; hàm 1 để nhập ký tự
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
        print msg_invalid
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
    mov cx, 8                   ; lặp 8 lần để kiểm tra 8 bộ 3 vị trí thắng
    check_win:                  
        mov bx, mang_win[si]    ; lấy vị trí thứ 1 trong bộ 3 mang_win
        mov ah, ki_tu[bx-1]     ; lấy ki_tu tại vị trí đó (trừ 1 vì mảng từ 0)
        mov bx, mang_win[si+2]  ; lấy vị trí thứ 2 trong bộ 3 mang_win
        cmp ah, ki_tu[bx-1]     ; so sánh ki_tu tại vị trí 1 và 2
        jnz chua_win            ; nếu khác nhau thì chưa thắng 
       
        mov res, ah             ; nếu giống nhau thì lưu người thắng (X/O)
        sub ah, 'X'             ; nếu X thắng thì ah=0, O thắng thì ah!=0
        jz inc_score_x          ; nếu ah=0 (X thắng) thì tăng điểm X
        inc score_o             ; ngược lại tăng điểm O
        jmp end_check_win
    inc_score_x:
        inc score_x
    end_check_win:
        mov al, 1               ; al = 1 báo hiệu game kết thúc
        ret                              
    chua_win:                   ; xử lý khi chưa thắng ở bộ 3 hiện tại
        add si, 4               ; tăng si lên 6 (mỗi bộ 3 chiếm 6 byte trong mang_win)
        loop check_win          ; lặp check_win đến khi cx=0
    lea si, ki_tu               ; si trỏ đến mảng kí tự
    mov cx, 9                   ; cx=9 để lặp 9 lần
    check_hoa:                  
        mov al, [si]            ; lấy giá trị ô hiện tại
        cmp al, '9'             
        jbe chua_hoa            ; nếu <= '9' thì còn ô chưa đánh -> chưa hòa
        inc si                  ; tăng si (kiểm tra ô tiếp)
        loop check_hoa          ; lặp check_hoa đến khi cx=0
    mov res, 'H'                ; nếu tất cả ô đều đã đánh thì đánh dấu hòa
    mov al, 1                   ; al=1 báo hiệu game kết thúc
    ret                     
    chua_hoa:                   ; xử lý khi chưa hòa
        mov al, 0               ; al=0 (game chưa kết thúc)
        ret                     
check_end endp
end main 