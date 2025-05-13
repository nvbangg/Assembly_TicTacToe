;https://github.com/trandinhhao/PTIT-KTMT-Assembly/blob/main/Tic_Tac_Toe.asm
Name "Tic Tac Toe" ; Đặt tên chương trình"Tic Tac Toe"
Org 100h           ; Thiết lập vị trí bắt đầu trong bộ nhớ
.DATA              ; Khối dữ liệu
	MANG DB '1','2','3'  	; Khai báo mảng 2D grid
             DB '4','5','6'
             DB '7','8','9'
	PLAYER DB ?  						; Khai báo biến cho người chơi
	WELCOME DB 'Welcome to Tic Tac Toe! $'			; Thông điệp chào mừng
	INPUT DB 'Enter Position Number, PLAYER Turn is: $' 	; Thông điệp nhập dữ liệu
	DRAW DB 'DRAW! $' 					; Thông điệp hòa
	WIN DB 'PLAYER WIN: $' 					; Thông điệp chiến thắng

.CODE    ; Khối mã lệnh
main:
	mov cx,9    		; Lặp 9 lần vì số lượng tối đa các lượt chơi là 9
x:   
        call XOA_MAN_HINH  	; Xóa màn hình để cho giao diện đẹp hơn
	call PRINT_WELCOME 	; In thông điệp chào mừng
	call PRINT_MANG    	; In bảng lưới
	mov bx, cx        	; Di chuyển cx vào bx
	and bx, 1         	; Kiểm tra số chẵn hoặc lẻ
	cmp bx, 0        	; So sánh kết quả AND
	je isEven         	; Nhảy đến isEven nếu kết quả 0 (chẵn)
	mov PLAYER, 'x'    	; Nếu là số lẻ thì là lượt của người chơi x
	jmp endif		; Chuyển đến bước tiếp theo
isEven:
	mov PLAYER, 'o'    	; Nếu là số chẵn thì là lượt của người chơi o
endif:
  NOT_VALID:
	call IN_DONG_MOI 	; In dòng mới
	call IN_NHAP	 	; In thông điệp nhập liệu
	call NHAP   		; Đọc dữ liệu đầu vào, al chứa vị trí trên bảng lưới
           
	push cx           	; Đẩy cx vào ngăn xếp
	mov cx, 9         	; Thiết lập số lượng vòng lặp
	mov bx, 0         	; Chỉ số để truy cập bảng lưới
y:
	cmp MANG[bx], al  	; Kiểm tra vị trí trên bảng lưới với dữ liệu đầu vào
	je UPDATE         	; Nếu trùng khớp cập nhật vị trí của người chơi(x hoặc o)
	jmp CONTINUE     	; Tiếp tục nếu không trùng
UPDATE:
	mov dl, PLAYER     	; Di chuyển ng chơi vào dl
	mov MANG[bx], dl  	; Cập nhật bảng lưới với người chơi
CONTINUE:
	inc bx            	; Tăng chỉ số
	loop y            	; Lặp đến khi hoàn tất
	pop cx            	; Lấy giá trị cx ra khỏi ngăn xếp
	call CHECKWIN     	; Kiểm tra kết quả chơi        
	loop x                  ; Lặp lại chương trình
	call PRINT_DRAW      	; Nếu không ai thắng in hòa
programEnd:   
	mov     ah, 0        	; Thiết lập thanh ghi AH thành giá trị 0
        int     16h          	
ret                      		
	    
; Các hàm 
PRINT_MANG:         			; Thủ tục in bảng lưới
	push cx           		; Đẩy cx vào ngăn xếp
	mov bx,0         		; Thiết lập chỉ số ban đầu
	mov cx,3          		; Số dòng của bảng lưới
	x1:
                call IN_DONG_MOI 	; In dòng mới
                push cx          	; Đẩy cx vào ngăn xếp
                mov cx, 3       	; Số cột của bảng lưới
	x2:
	mov dl, MANG[bx] 		; Di chuyển giá trị grid vào dl
	mov ah, 2h   			; Câu lệnh in ký tự
	int 21h       
	call PRINT_Space 		; Gọi hàm in khoảng trắng
	inc bx       			; Tăng chỉ số
	loop x2          		; Lặp lại qua các cột
	pop cx          		; Lấy lại giá trị cx
	loop x1              		; Lặp lai qua cac dòng
	pop cx               		; Lấy lại giá trị cx
	call IN_DONG_MOI    		; In dòng mới 
ret                      					
        
IN_DONG_MOI:            		; Thủ tục in dòng mới
	mov dl, 0ah     		; Kí tự xuống dòng
	mov ah, 2       		; Câu lệnh in kí tự
	int 21h         		; Gọi ngắt để in kí tự
	mov dl, 13          		 		
	mov ah, 2       		; Câu lệnh in kí tự
	int 21h         		; Gọi ngắt để in kí tự
ret                     			 		
        
PRINT_Space:            		; Thủ tục in khoảng trắng
	mov dl, 32          		; Mã ascii của khoảng trắng
	mov ah, 2            		; Câu lệnh in kí tự
	int 21h              		; Gọi ngắt để in kí tự
ret       
              		 			
NHAP:  				        ; Thủ tục đọc dữ liệu đầu vào

	mov ah, 1        		; Cho phép nhập kí tự
	int 21h               	 	; Gọi ngắt để nhập dữ liệu
	cmp al, '1'                     ; Kiểm tra giá trị nhập vào
	je VALID
	cmp al, '2'
	je VALID
	cmp al, '3'
	je VALID
	cmp al, '4'
	je VALID
	cmp al, '5'
	je VALID
	cmp al, '6'
	je VALID
	cmp al, '7'
	je VALID
	cmp al, '8'
	je VALID
	cmp al, '9'
	je VALID
	jmp NOT_VALID                   ; Quay lại vị trí không hợp lệ
	VALID:                          ; Điểm hợp lệ
ret                       					
        
PRINT_WELCOME:          	 	; Thủ tục in thông điệp chào mừng
	lea dx, WELCOME   		; Tải địa chỉ của thông điệp vào dx
	mov ah, 9            		; Câu lệnh in chuỗi
	int 21h             		; Gọi ngắt để in chuỗi
ret                       					
        
PRINT_DRAW:                  		; Thủ tục in thông điệp hoa
	call IN_DONG_MOI       		; In dòng mới
	lea dx, DRAW            	; Tải địa chỉ thông điệp
	mov ah, 9                	; Câu lệnh in chuỗi
	int 21h                   	; Gọi ngắt để in chuỗi
ret                         		 			
        
PRINT_WIN:                     		; Thủ tục in thông điệp chiến thắng
	call IN_DONG_MOI       	 	; In dòng mới
	call PRINT_MANG           	; In bảng lưới lần cuối
	lea dx, WIN               	; Tải địa chỉ thông điệp
	mov ah, 9                 	; Câu lệnh in chuỗi
	int 21h                    	; Gọi ngắt để in chuỗi
	mov dl, PLAYER            	; Di chuyển giá trị người chơi vào dl
	mov ah, 2h                 	; Câu lệnh in kí tự
	int 21h                    	; Gọi ngắt để in kí tự
	jmp programEnd            	; Quay lại kết thúc chương trình
ret                            				
        
IN_NHAP:                 		; Thủ tục in thông điệp nhập liệu
	lea dx, INPUT            	; Tải địa chỉ thông điệp
	mov ah, 9                   	; Câu lệnh in chuỗi
	int 21h                       	; Gọi ngắt để in chuỗi
	mov dl, PLAYER               	; Di chuyển giá trị người chơi vào dl
	mov ah, 2h                     	; Câu lệnh in kí tự
	int 21h                       	; Gọi ngắt để in kí tự
	call PRINT_Space                ; Gọi thủ tục in khoảng trắng
ret                                				
        
CHECKWIN:                      		; Thủ tục kiểm tra kết quả
	mov bl, MANG[0]                 ; Kiểm tra hàng 0
	cmp bl, MANG[1]          	; So sánh giá trị đầu tiên và thứ 2
	jne skip1                	; Nếu không giống nhau bỏ qua
	cmp bl, MANG[2]          	; So sánh giá trị đầu tiên và thứ 3
	jne skip1                	; Nếu không giống nhau bỏ qua
	call PRINT_WIN           	; Nếu giống nhau in thông điệp chiến thắng

skip1:                           	; Vị trí bỏ qua
	mov bl, MANG[3]          	; Kiểm tra hàng 1
	cmp bl, MANG[4]          	; So sánh giá trị đầu tiên và thứ 2 của hàng 1
	jne skip2                	; Nếu không giống nhau bỏ qua
	cmp bl, MANG[5]          	; So sánh giá trị đầu tiên và thứ 3 của hàng 1
	jne skip2                	; Nếu không giống nhau bỏ qua
	call PRINT_WIN           	; Nếu giống nhau in thông điệp chiến thắng

skip2:                           	; Vị trí bỏ qua
	mov bl, MANG[6]          	; Kiểm tra hàng 2
	cmp bl, MANG[7]          	; So sánh giá trị đầu tiên và thứ 2 của hàng 2
	jne skip3                	; Nếu không giống nhau bỏ qua
	cmp bl, MANG[8]          	; So sánh giá trị đầu tiên và thứ 3 của hàng 2
	jne skip3                	; Nếu không giống nhau bỏ qua
	call PRINT_WIN           	; Nếu giống nhau in thông điệp chiến thắng

skip3:                           	; Vị trí bỏ qua
	mov bl, MANG[0]          	; Kiểm tra cột 0
	cmp bl, MANG[3]          	; So sánh vị trí đầu tiên và thứ 2 của cột 0
	jne skip4                	; Nếu không giống nhau bỏ qua
	cmp bl, MANG[6]          	; So sánh vị trí đầu tiên và thứ 3 của cột 0
	jne skip4               	; Nếu không giống nhau bỏ qua
	call PRINT_WIN           	; Nếu giống nhau in thông điệp chiến thắng

skip4:                           	; Vị trí bỏ qua
	mov bl, MANG[1]          	; Kiểm tra cột 1
	cmp bl, MANG[4]          	; So sánh vị trí đầu tiên và thứ 2 của cột 1
	jne skip5                	; Nếu không giống nhau bỏ qua
	cmp bl, MANG[7]          	; So sánh vị trí đầu tiên và thứ 3 của cột 1
	jne skip5                	; Nếu không giống nhau bỏ qua
	call PRINT_WIN           	; Nếu giống nhau in thông điệp chiến thắng

skip5:                           	; Vị trí bỏ qua    
	mov bl, MANG[2]          	; Kiểm tra cột 2
	cmp bl, MANG[5]          	; So sánh vị trí đầu tiên và thứ 2 của cột 2
	jne skip6                	; Nếu không giống nhau bỏ qua
	cmp bl, MANG[8]          	; So sánh vị trí đầu tiên và thứ 3 của cột 2
	jne skip6                	; Nếu không giống nhau bỏ qua
	call PRINT_WIN           	; Nếu giống nhau in thông điệp chiến thắng


skip6:                           	; Vị trí bỏ qua
            
            mov bl, MANG[0]      	; Kiểm tra đường chéo chính
            cmp bl, MANG[4]      	; So sánh giá trị đầu tiên và thứ 2 của đường chéo chính
            jne skip7            	; Nếu không giống nhau bỏ qua
            cmp bl, MANG[8]      	; So sánh giá trị đầu tiên và thứ 3 của đường chéo chính
            jne skip7            	; Nếu không giống nhau bỏ qua
            call PRINT_WIN       	; Nếu giống nhau in thông điệp chiến thắng

skip7:               		 	; Vị trí bỏ qua
	mov bl, MANG[2]          	; Kiểm tra đường chéo phụ
	cmp bl, MANG[4]          	; So sánh giá trị đầu tiên và thứ 2 của đường chéo phụ
	jne skip8                	; Nếu không giống nhau bỏ qua 
	cmp bl, MANG[6]          	; So sánh giá trị đầu tiên và thứ 3 của đường chéo phụ
	jne skip8                	; Nếu không giống nhau bỏ qua
	call PRINT_WIN          	; Nếu giống nhau in thông điệp chiến thắng

skip8:                           	; Vị trí bỏ qua
ret                                                                 	 
        
XOA_MAN_HINH:                    	; Thủ tục xóa màn hình
	mov ax, 3                	; Xóa màn hình
	int 10h                  	; Gọi ngắt
ret                                                            	
end main                         	; Kết thúc chương trình