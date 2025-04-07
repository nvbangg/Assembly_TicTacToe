Name "Tic Tac Toe" ; �?t t�n chuong tr�nh"Tic Tac Toe"
Org 100h           ; Thi?t l?p v? tr� b?t d?u trong b? nh?
.DATA              ; Kh?i d? li?u
	MANG DB '1','2','3'  	; Khai b�o m?ng 2D grid
             DB '4','5','6'
             DB '7','8','9'
	PLAYER DB ?  						; Khai b�o bi?n cho ngu?i choi
	WELCOME DB 'Welcome to Tic Tac Toe! $'			; Th�ng di?p ch�o m?ng
	INPUT DB 'Enter Position Number, PLAYER Turn is: $' 	; Th�ng di?p nh?p d? li?u
	DRAW DB 'DRAW! $' 					; Th�ng di?p h�a
	WIN DB 'PLAYER WIN: $' 					; Th�ng di?p chi?n th?ng

.CODE    ; Kh?i m� l?nh
main:
	mov cx,9    		; L?p 9 l?n v� s? lu?ng t?i da c�c lu?t choi l� 9
x:   
        call XOA_MAN_HINH  	; X�a m�n h�nh d? cho giao di?n d?p hon
	call PRINT_WELCOME 	; In th�ng di?p ch�o m?ng
	call PRINT_MANG    	; In b?ng lu?i
	mov bx, cx        	; Di chuy?n cx v�o bx
	and bx, 1         	; Ki?m tra s? ch?n ho?c l?
	cmp bx, 0        	; So s�nh k?t qu? AND
	je isEven         	; Nh?y d?n isEven n?u k?t qu? 0 (ch?n)
	mov PLAYER, 'x'    	; N?u l� s? l? th� l� lu?t c?a ngu?i choi x
	jmp endif		; Chuy?n d?n bu?c ti?p theo
isEven:
	mov PLAYER, 'o'    	; N?u l� s? ch?n th� l� lu?t c?a ngu?i choi o
endif:
  NOT_VALID:
	call IN_DONG_MOI 	; In d�ng m?i
	call IN_NHAP	 	; In th�ng di?p nh?p li?u
	call NHAP   		; �?c d? li?u d?u v�o, al ch?a v? tr� tr�n b?ng lu?i
           
	push cx           	; �?y cx v�o ngan x?p
	mov cx, 9         	; Thi?t l?p s? lu?ng v�ng l?p
	mov bx, 0         	; Ch? s? d? truy c?p b?ng lu?i
y:
	cmp MANG[bx], al  	; Ki?m tra v? tr� tr�n b?ng lu?i v?i d? li?u d?u v�o
	je UPDATE         	; N?u tr�ng kh?p c?p nh?t v? tr� c?a ngu?i choi(x ho?c o)
	jmp CONTINUE     	; Ti?p t?c n?u kh�ng tr�ng
UPDATE:
	mov dl, PLAYER     	; Di chuy?n ng choi v�o dl
	mov MANG[bx], dl  	; C?p nh?t b?ng lu?i v?i ngu?i choi
CONTINUE:
	inc bx            	; Tang ch? s?
	loop y            	; L?p d?n khi ho�n t?t
	pop cx            	; L?y gi� tr? cx ra kh?i ngan x?p
	call CHECKWIN     	; Ki?m tra k?t qu? choi        
	loop x                  ; L?p l?i chuong tr�nh
	call PRINT_DRAW      	; N?u kh�ng ai th?ng in h�a
programEnd:   
	mov     ah, 0        	; Thi?t l?p thanh ghi AH th�nh gi� tr? 0
        int     16h          	
ret                      		
	    
; C�c h�m 
PRINT_MANG:         			; Th? t?c in b?ng lu?i
	push cx           		; �?y cx v�o ngan x?p
	mov bx,0         		; Thi?t l?p ch? s? ban d?u
	mov cx,3          		; S? d�ng c?a b?ng lu?i
	x1:
                call IN_DONG_MOI 	; In d�ng m?i
                push cx          	; �?y cx v�o ngan x?p
                mov cx, 3       	; S? c?t c?a b?ng lu?i
	x2:
	mov dl, MANG[bx] 		; Di chuy?n gi� tr? grid v�o dl
	mov ah, 2h   			; C�u l?nh in k� t?
	int 21h       
	call PRINT_Space 		; G?i h�m in kho?ng tr?ng
	inc bx       			; Tang ch? s?
	loop x2          		; L?p l?i qua c�c c?t
	pop cx          		; L?y l?i gi� tr? cx
	loop x1              		; L?p lai qua cac d�ng
	pop cx               		; L?y l?i gi� tr? cx
	call IN_DONG_MOI    		; In d�ng m?i 
ret                      					
        
IN_DONG_MOI:            		; Th? t?c in d�ng m?i
	mov dl, 0ah     		; K� t? xu?ng d�ng
	mov ah, 2       		; C�u l?nh in k� t?
	int 21h         		; G?i ng?t d? in k� t?
	mov dl, 13          		 		
	mov ah, 2       		; C�u l?nh in k� t?
	int 21h         		; G?i ng?t d? in k� t?
ret                     			 		
        
PRINT_Space:            		; Th? t?c in kho?ng tr?ng
	mov dl, 32          		; M� ascii c?a kho?ng tr?ng
	mov ah, 2            		; C�u l?nh in k� t?
	int 21h              		; G?i ng?t d? in k� t?
ret       
              		 			
NHAP:  				        ; Th? t?c d?c d? li?u d?u v�o

	mov ah, 1        		; Cho ph�p nh?p k� t?
	int 21h               	 	; G?i ng?t d? nh?p d? li?u
	cmp al, '1'                     ; Ki?m tra gi� tr? nh?p v�o
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
	jmp NOT_VALID                   ; Quay l?i v? tr� kh�ng h?p l?
	VALID:                          ; �i?m h?p l?
ret                       					
        
PRINT_WELCOME:          	 	; Th? t?c in th�ng di?p ch�o m?ng
	lea dx, WELCOME   		; T?i d?a ch? c?a th�ng di?p v�o dx
	mov ah, 9            		; C�u l?nh in chu?i
	int 21h             		; G?i ng?t d? in chu?i
ret                       					
        
PRINT_DRAW:                  		; Th? t?c in th�ng di?p hoa
	call IN_DONG_MOI       		; In d�ng m?i
	lea dx, DRAW            	; T?i d?a ch? th�ng di?p
	mov ah, 9                	; C�u l?nh in chu?i
	int 21h                   	; G?i ng?t d? in chu?i
ret                         		 			
        
PRINT_WIN:                     		; Th? t?c in th�ng di?p chi?n th?ng
	call IN_DONG_MOI       	 	; In d�ng m?i
	call PRINT_MANG           	; In b?ng lu?i l?n cu?i
	lea dx, WIN               	; T?i d?a ch? th�ng di?p
	mov ah, 9                 	; C�u l?nh in chu?i
	int 21h                    	; G?i ng?t d? in chu?i
	mov dl, PLAYER            	; Di chuy?n gi� tr? ngu?i choi v�o dl
	mov ah, 2h                 	; C�u l?nh in k� t?
	int 21h                    	; G?i ng?t d? in k� t?
	jmp programEnd            	; Quay l?i k?t th�c chuong tr�nh
ret                            				
        
IN_NHAP:                 		; Th? t?c in th�ng di?p nh?p li?u
	lea dx, INPUT            	; T?i d?a ch? th�ng di?p
	mov ah, 9                   	; C�u l?nh in chu?i
	int 21h                       	; G?i ng?t d? in chu?i
	mov dl, PLAYER               	; Di chuy?n gi� tr? ngu?i choi v�o dl
	mov ah, 2h                     	; C�u l?nh in k� t?
	int 21h                       	; G?i ng?t d? in k� t?
	call PRINT_Space                ; G?i th? t?c in kho?ng tr?ng
ret                                				
        
CHECKWIN:                      		; Th? t?c ki?m tra k?t qu?
	mov bl, MANG[0]                 ; Ki?m tra h�ng 0
	cmp bl, MANG[1]          	; So s�nh gi� tr? d?u ti�n v� th? 2
	jne skip1                	; N?u kh�ng gi?ng nhau b? qua
	cmp bl, MANG[2]          	; So s�nh gi� tr? d?u ti�n v� th? 3
	jne skip1                	; N?u kh�ng gi?ng nhau b? qua
	call PRINT_WIN           	; N?u gi?ng nhau in th�ng di?p chi?n th?ng

skip1:                           	; V? tr� b? qua
	mov bl, MANG[3]          	; Ki?m tra h�ng 1
	cmp bl, MANG[4]          	; So s�nh gi� tr? d?u ti�n v� th? 2 c?a h�ng 1
	jne skip2                	; N?u kh�ng gi?ng nhau b? qua
	cmp bl, MANG[5]          	; So s�nh gi� tr? d?u ti�n v� th? 3 c?a h�ng 1
	jne skip2                	; N?u kh�ng gi?ng nhau b? qua
	call PRINT_WIN           	; N?u gi?ng nhau in th�ng di?p chi?n th?ng

skip2:                           	; V? tr� b? qua
	mov bl, MANG[6]          	; Ki?m tra h�ng 2
	cmp bl, MANG[7]          	; So s�nh gi� tr? d?u ti�n v� th? 2 c?a h�ng 2
	jne skip3                	; N?u kh�ng gi?ng nhau b? qua
	cmp bl, MANG[8]          	; So s�nh gi� tr? d?u ti�n v� th? 3 c?a h�ng 2
	jne skip3                	; N?u kh�ng gi?ng nhau b? qua
	call PRINT_WIN           	; N?u gi?ng nhau in th�ng di?p chi?n th?ng

skip3:                           	; V? tr� b? qua
	mov bl, MANG[0]          	; Ki?m tra c?t 0
	cmp bl, MANG[3]          	; So s�nh v? tr� d?u ti�n v� th? 2 c?a c?t 0
	jne skip4                	; N?u kh�ng gi?ng nhau b? qua
	cmp bl, MANG[6]          	; So s�nh v? tr� d?u ti�n v� th? 3 c?a c?t 0
	jne skip4               	; N?u kh�ng gi?ng nhau b? qua
	call PRINT_WIN           	; N?u gi?ng nhau in th�ng di?p chi?n th?ng

skip4:                           	; V? tr� b? qua
	mov bl, MANG[1]          	; Ki?m tra c?t 1
	cmp bl, MANG[4]          	; So s�nh v? tr� d?u ti�n v� th? 2 c?a c?t 1
	jne skip5                	; N?u kh�ng gi?ng nhau b? qua
	cmp bl, MANG[7]          	; So s�nh v? tr� d?u ti�n v� th? 3 c?a c?t 1
	jne skip5                	; N?u kh�ng gi?ng nhau b? qua
	call PRINT_WIN           	; N?u gi?ng nhau in th�ng di?p chi?n th?ng

skip5:                           	; V? tr� b? qua    
	mov bl, MANG[2]          	; Ki?m tra c?t 2
	cmp bl, MANG[5]          	; So s�nh v? tr� d?u ti�n v� th? 2 c?a c?t 2
	jne skip6                	; N?u kh�ng gi?ng nhau b? qua
	cmp bl, MANG[8]          	; So s�nh v? tr� d?u ti�n v� th? 3 c?a c?t 2
	jne skip6                	; N?u kh�ng gi?ng nhau b? qua
	call PRINT_WIN           	; N?u gi?ng nhau in th�ng di?p chi?n th?ng


skip6:                           	; V? tr� b? qua
            
            mov bl, MANG[0]      	; Ki?m tra du?ng ch�o ch�nh
            cmp bl, MANG[4]      	; So s�nh gi� tr? d?u ti�n v� th? 2 c?a du?ng ch�o ch�nh
            jne skip7            	; N?u kh�ng gi?ng nhau b? qua
            cmp bl, MANG[8]      	; So s�nh gi� tr? d?u ti�n v� th? 3 c?a du?ng ch�o ch�nh
            jne skip7            	; N?u kh�ng gi?ng nhau b? qua
            call PRINT_WIN       	; N?u gi?ng nhau in th�ng di?p chi?n th?ng

skip7:               		 	; V? tr� b? qua
	mov bl, MANG[2]          	; Ki?m tra du?ng ch�o ph?
	cmp bl, MANG[4]          	; So s�nh gi� tr? d?u ti�n v� th? 2 c?a du?ng ch�o ph?
	jne skip8                	; N?u kh�ng gi?ng nhau b? qua 
	cmp bl, MANG[6]          	; So s�nh gi� tr? d?u ti�n v� th? 3 c?a du?ng ch�o ph?
	jne skip8                	; N?u kh�ng gi?ng nhau b? qua
	call PRINT_WIN          	; N?u gi?ng nhau in th�ng di?p chi?n th?ng

skip8:                           	; V? tr� b? qua
ret                                                                 	 
        
XOA_MAN_HINH:                    	; Th? t?c x�a m�n h�nh
	mov ax, 3                	; X�a m�n h�nh
	int 10h                  	; G?i ng?t
ret                                                            	
end main                         	; K?t th�c chuong tr�nh