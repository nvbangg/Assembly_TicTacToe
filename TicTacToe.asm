; Tic Tac Toe v1.7
.model small
.stack 100h
.data
    ki_tu db '123456789'   ; kí tự các ô trong bảng
    screen db 13,10,'  |   |  ',13,10,'---------',13,10,'  |   |  ',13,10
           db '---------',13,10,'  |   |  ',13,10,13,10,'$'
    pos db 2,6,10,24,28,32,46,50,54  ; vị trí ký tự trong screen
    msg_turnX db 'Nhap vi tri (1-9). Luot X: $'
    msg_turnO db 'Nhap vi tri (1-9). Luot O: $'
    msg_invalid db ' Khong hop le! Thu lai.', 13, 10, '$'
    msg_xWin db 'NGUOI THANG: X$'
    msg_oWin db 'NGUOI THANG: O$'
    msg_hoa db 'HOA VAN$'
    msg_replay db 'Choi lai? (Y/N): $'
    turn db 'X'        ; lưu lượt chơi hiện tại: X hoặc O
    turn_begin db 'O'         ; lưu người chơi đầu mỗi vòng chơi
    crlf db 13, 10, '$'      ; xuống dòng
    res db ' ', '$'      ; đánh dấu kết quả: X, O hoặc H (hòa) 
    mang_win dw 1,2,3, 4,5,6, 7,8,9, 1,4,7, 2,5,8, 3,6,9, 1,5,9, 3,5,7

.code
main proc
    mov ax, @data       ; khởi tạo
    mov ds, ax
    call init        
     
game_loop: 
    call draw_screen    ; vẽ bảng
    call nhap_nuoc      ; nhập nước đi       
    call check_end      ; kiểm tra kết thúc
    cmp al, 1           ; al=1 nếu có người thắng/hòa
    je game_over        ; kết thúc nếu al = 1
    call doi_luot       ; đổi người chơi nếu al = 0
    jmp game_loop       ; lặp lại vòng chơi
     
game_over:             
    call draw_screen         
    mov ah, 9           ; ngắt 9 để in chuỗi
    mov al, res         ; X, O hoặc H
    lea dx, msg_xWin    ; mặc định X thắng
    cmp al, 'X'
    je hien_kq
    lea dx, msg_oWin    ; nếu O thắng
    cmp al, 'O'
    je hien_kq
    lea dx, msg_hoa     ; nếu hòa
    
hien_kq:
    int 21h             ; in kết quả
    mov ah, 9           ; in xuống dòng
    lea dx, crlf
    int 21h
    lea dx, msg_replay  ; in hỏi chơi lại?
    int 21h
    mov ah, 1           ; ngắt 1 để nhập kí tự
    int 21h
    and al, 0dfh        ; chuyển sang chữ hoa
    cmp al, 'Y'
    jne exit
    call init           ; reset game
    jmp game_loop
    
exit:
    mov ah, 4ch         ; thoát chương trình
    int 21h
main endp

init proc
    lea si, ki_tu       ; trỏ đến bảng
    mov bl, '1'         ; bắt đầu từ ký tự '1'
    mov cx, 9           ; 9 ô cần khởi tạo
reset:          
    mov [si], bl        ; đánh số ô
    inc bl
    inc si
    loop reset
    mov al, 'X'+'O'     ; tổng = 167 
    sub al, turn_begin  ; hoán đổi X<->O
    mov turn_begin, al  ; cập nhật người đi trước
    mov turn, al        ; đặt lượt chơi hiện tại
    ret
init endp

draw_screen proc
    mov ax, 3           ; xóa màn hình
    int 10h
    mov cx, 9           ; 9 ô cần cập nhật
    xor si, si          ; si = 0
update_cell:
    mov al, pos[si]     ; vị trí cần cập nhật
    cbw                 ; chuyển al thành ax
    mov di, ax
    mov al, ki_tu[si]   ; lấy ký tự từ bảng
    mov screen[di], al  ; cập nhật vào chuỗi hiển thị
    inc si
    loop update_cell
    lea dx, screen
    mov ah, 9           ; in bảng
    int 21h
    ret
draw_screen endp

nhap_nuoc proc
    mov ah, 9
    lea dx, msg_turnX   ; thông báo lượt X
    cmp turn, 'X'
    je hien_nhap
    lea dx, msg_turnO   ; hoặc lượt O
     
hien_nhap:            
    int 21h             ; in msg lượt chơi
    mov ah, 1           ; nhận input
    int 21h
    cmp al, '1'         ; kiểm tra hợp lệ
    jl nhap_sai
    cmp al, '9'
    jg nhap_sai
    sub al, '1'         ; chuyển '1'-'9' thành 0-8
    mov bl, al
    xor bh, bh          ; bx = 0-8
    lea si, ki_tu
    add si, bx          ; si = địa chỉ ô được chọn
    mov al, [si]
    cmp al, 'X'         ; kiểm tra ô đã đánh chưa
    je nhap_sai
    cmp al, 'O'
    je nhap_sai
    mov al, turn        ; đánh dấu X hoặc O
    mov [si], al
    mov ah, 9
    lea dx, crlf        ; xuống dòng
    int 21h
    ret
    
nhap_sai:            
    mov ah, 9
    lea dx, msg_invalid ; thông báo nước đi không hợp lệ
    int 21h 
    jmp nhap_nuoc       ; nhập lại
nhap_nuoc endp

doi_luot proc
    mov al, 'X'+'O'     ; tổng = 167 
    sub al, turn        ; hoán đổi X<->O
    mov turn, al
    ret
doi_luot endp

check_end proc
    xor si, si          ; si = 0
    mov cx, 8           ; 8 cách thắng cần kiểm tra
    
check_win:
    mov bx, mang_win[si]    ; lấy vị trí thứ 1
    mov ah, ki_tu[bx-1]
    mov bx, mang_win[si+2]  ; lấy vị trí thứ 2
    cmp ah, ki_tu[bx-1]     ; so sánh 1 và 2
    jnz khong_win
    mov bx, mang_win[si+4]  ; lấy vị trí thứ 3
    cmp ah, ki_tu[bx-1]     ; so sánh 1 và 3
    jnz khong_win
    mov res, ah             ; lưu người thắng
    mov al, 1               ; báo game kết thúc
    ret
     
khong_win: 
    add si, 6           ; chuyển đến bộ 3 ô tiếp theo
    loop check_win

    lea si, ki_tu       ; kiểm tra hòa
    mov cx, 9
check_hoa: 
    mov al, [si]        ; lấy ký tự ô hiện tại
    cmp al, '9'         ; nếu còn số (chưa đánh)
    jbe chua_hoa        ; thì chưa hòa
    inc si
    loop check_hoa
    mov res, 'H'        ; đánh dấu hòa
    mov al, 1           ; báo game kết thúc
    ret
     
chua_hoa:
    xor al, al          ; al = 0 (game chưa kết thúc)
    ret
check_end endp

end main