.MODEL SMALL
.STACK 100H
.DATA
    ; Bảng trò chơi (lưới 3x3)
    BOARD DB '1', '2', '3', '4', '5', '6', '7', '8', '9'
    
    ; Các thông báo hiển thị
    PLAYER_X_TURN DB 'Luot X. Nhap vi tri (1-9): $'
    PLAYER_O_TURN DB 'Luot O. Nhap vi tri (1-9): $'
    INVALID_MOVE DB 'Nuoc di khong hop le! Thu lai.$'
    X_WINS_MSG DB 'NGUOI CHOI X THANG CUOC!$'
    O_WINS_MSG DB 'NGUOI CHOI O THANG CUOC!$'
    DRAW_MSG DB 'HOA!$'
    PLAY_AGAIN_MSG DB 'Choi lai? (Y/N): $'
    
    CURRENT_PLAYER DB 'X'  ; Người chơi hiện tại
    NEWLINE DB 0DH, 0AH, '$'  ; Ký tự xuống dòng
    LINE_SEP DB '---+---+---$'  ; Đường phân cách
    WINNER_CHAR DB ' ', '$'  ; Lưu người thắng (X, O hoặc D cho hòa)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    CALL INIT_GAME
    
    GAME_LOOP:
        CALL DISPLAY_BOARD      ; Hiển thị bảng
        CALL GET_PLAYER_MOVE    ; Lấy nước đi
        
        CALL CHECK_GAME_OVER    ; Kiểm tra kết thúc
        CMP AL, 1
        JE END_GAME
        
        CALL SWITCH_PLAYER      ; Đổi lượt
        JMP GAME_LOOP
    
    END_GAME:
        CALL DISPLAY_BOARD      ; Hiển thị bảng cuối
        
        ; Hiển thị thông báo người thắng
        MOV AL, WINNER_CHAR
        CMP AL, 'X'
        JE SHOW_X_WINS
        CMP AL, 'O'
        JE SHOW_O_WINS
        
        ; Nếu hòa
        LEA DX, DRAW_MSG
        JMP DISPLAY_RESULT
        
        SHOW_X_WINS:
        LEA DX, X_WINS_MSG
        JMP DISPLAY_RESULT
        
        SHOW_O_WINS:
        LEA DX, O_WINS_MSG
        
        DISPLAY_RESULT:
        MOV AH, 9
        INT 21H
        
        LEA DX, NEWLINE
        MOV AH, 9
        INT 21H
        LEA DX, NEWLINE
        MOV AH, 9
        INT 21H
        
        LEA DX, PLAY_AGAIN_MSG  ; Hỏi chơi lại
        MOV AH, 9
        INT 21H
        
        MOV AH, 1
        INT 21H
        
        AND AL, 11011111b       ; Chuyển thường thành hoa
        CMP AL, 'Y'
        JE RESTART_GAME
        
        JMP EXIT
        
    RESTART_GAME:
        CALL INIT_GAME
        JMP GAME_LOOP
        
    EXIT:
        MOV AH, 4CH
        INT 21H
MAIN ENDP

; Khởi tạo trò chơi
INIT_GAME PROC
    MOV CX, 9                ; Đếm 9 ô
    LEA SI, BOARD
    MOV BL, '1'              ; Bắt đầu từ 1
    
    RESET_LOOP:
        MOV [SI], BL         ; Gán giá trị
        INC BL               ; Tăng số
        INC SI               ; Ô tiếp theo
        LOOP RESET_LOOP
    
    MOV CURRENT_PLAYER, 'X'  ; X đi trước
    RET
INIT_GAME ENDP

; Hiển thị bảng
DISPLAY_BOARD PROC
    MOV AH, 0                ; Xóa màn hình
    MOV AL, 3
    INT 10H
    
    LEA SI, BOARD
    XOR BX, BX               ; BX = 0, dùng làm bộ đếm
    
    MOV CX, 3                ; Hiển thị 3 hàng
    
    ROW_LOOP:
        PUSH CX              ; Lưu bộ đếm hàng
        
        MOV AH, 2            ; Hiển thị 1 hàng (3 ô)
        MOV DL, ' '          ; Khoảng trắng đầu
        INT 21H
        
        MOV DL, [SI + BX]    ; Ô 1
        INT 21H
        
        MOV DL, ' '
        INT 21H
        MOV DL, '|'
        INT 21H
        MOV DL, ' '
        INT 21H
        
        MOV DL, [SI + BX + 1] ; Ô 2
        INT 21H
        
        MOV DL, ' '
        INT 21H
        MOV DL, '|'
        INT 21H
        MOV DL, ' '
        INT 21H
        
        MOV DL, [SI + BX + 2] ; Ô 3
        INT 21H
        
        LEA DX, NEWLINE      ; Xuống dòng
        MOV AH, 9
        INT 21H
        
        POP CX               ; Hiển thị đường phân cách (trừ dòng cuối)
        CMP CX, 1            ; CX = 1 là dòng cuối
        JE SKIP_SEP
        
        LEA DX, LINE_SEP
        MOV AH, 9
        INT 21H
        
        LEA DX, NEWLINE
        MOV AH, 9
        INT 21H
        
        SKIP_SEP:
        ADD BX, 3            ; Bước tới hàng tiếp theo
        LOOP ROW_LOOP
    
    LEA DX, NEWLINE          ; Thêm dòng trống
    MOV AH, 9
    INT 21H
    
    RET
DISPLAY_BOARD ENDP

; Lấy nước đi của người chơi
GET_PLAYER_MOVE PROC
    CMP CURRENT_PLAYER, 'X'  ; Hiển thị lời nhắc
    JNE PROMPT_O
    
    LEA DX, PLAYER_X_TURN
    JMP SHOW_PROMPT
    
    PROMPT_O:
    LEA DX, PLAYER_O_TURN
    
    SHOW_PROMPT:
    MOV AH, 9
    INT 21H
    
    MOV AH, 1                ; Nhận đầu vào
    INT 21H
    
    CMP AL, '1'              ; Kiểm tra hợp lệ (1-9)
    JL INVALID_INPUT
    CMP AL, '9'
    JG INVALID_INPUT
    
    SUB AL, '1'              ; Chuyển thành chỉ số 0-8
    MOV BL, AL
    
    LEA SI, BOARD            ; Kiểm tra ô đã bị chiếm chưa
    XOR BH, BH
    ADD SI, BX
    
    MOV AL, [SI]
    CMP AL, 'X'
    JE INVALID_INPUT
    CMP AL, 'O'
    JE INVALID_INPUT
    
    MOV AL, CURRENT_PLAYER   ; Đánh dấu ô
    MOV [SI], AL
    
    LEA DX, NEWLINE          ; Xuống dòng
    MOV AH, 9
    INT 21H
    
    RET
    
    INVALID_INPUT:
    LEA DX, NEWLINE
    MOV AH, 9
    INT 21H
    
    LEA DX, INVALID_MOVE
    MOV AH, 9
    INT 21H
    
    LEA DX, NEWLINE
    MOV AH, 9
    INT 21H
    
    JMP GET_PLAYER_MOVE      ; Thử lại
GET_PLAYER_MOVE ENDP

; Đổi người chơi
SWITCH_PLAYER PROC
    MOV AL, 'X'              ; Đảo X <-> O
    CMP CURRENT_PLAYER, AL
    JE SET_O
    MOV CURRENT_PLAYER, AL   ; Đổi thành X
    JMP DONE_SWITCH
    
    SET_O:
    MOV CURRENT_PLAYER, 'O'  ; Đổi thành O
    
    DONE_SWITCH:
    RET
SWITCH_PLAYER ENDP

; Kiểm tra kết thúc
CHECK_GAME_OVER PROC
    LEA SI, BOARD
    
    MOV BX, 0                ; Kiểm tra hàng 1
    CALL CHECK_LINE
    JE WINNER_FOUND
    
    MOV BX, 3                ; Kiểm tra hàng 2
    CALL CHECK_LINE
    JE WINNER_FOUND
    
    MOV BX, 6                ; Kiểm tra hàng 3
    CALL CHECK_LINE
    JE WINNER_FOUND
    
    MOV BX, 0                ; Kiểm tra cột 1
    MOV CX, 3                ; Bước nhảy = 3
    CALL CHECK_LINE_WITH_STEP
    JE WINNER_FOUND
    
    MOV BX, 1                ; Kiểm tra cột 2
    CALL CHECK_LINE_WITH_STEP
    JE WINNER_FOUND
    
    MOV BX, 2                ; Kiểm tra cột 3
    CALL CHECK_LINE_WITH_STEP
    JE WINNER_FOUND
    
    MOV BX, 0                ; Kiểm tra đường chéo chính
    MOV CX, 4                ; Bước nhảy = 4
    CALL CHECK_LINE_WITH_STEP
    JE WINNER_FOUND
    
    MOV BX, 2                ; Kiểm tra đường chéo phụ
    MOV CX, 2                ; Bước nhảy = 2
    CALL CHECK_LINE_WITH_STEP
    JE WINNER_FOUND
    
    MOV CX, 9                ; Kiểm tra hòa (9 ô)
    LEA SI, BOARD
    
    CHECK_DRAW:
        MOV AL, [SI]
        CMP AL, '1'          ; Nếu < '1' là X hoặc O
        JL NEXT_POS
        CMP AL, '9'          ; Nếu > '9' là X hoặc O
        JG NEXT_POS
        
        MOV AL, 0            ; Còn ô trống -> tiếp tục
        RET
        
        NEXT_POS:
        INC SI
        LOOP CHECK_DRAW
    
    ; Hòa - không hiển thị thông báo ở đây nữa
    MOV WINNER_CHAR, 'D'     ; Đánh dấu là hòa
    MOV AL, 1                ; Trò chơi kết thúc
    RET
    
    WINNER_FOUND:            
    ; Lưu người thắng vào biến
    MOV WINNER_CHAR, AL      ; Lưu X hoặc O
    
    MOV AL, 1                ; Trò chơi kết thúc
    RET
CHECK_GAME_OVER ENDP

; Kiểm tra 3 ô liên tiếp (hàng ngang)
CHECK_LINE PROC
    MOV AL, [SI + BX]        ; Ô đầu tiên
    CMP AL, [SI + BX + 1]    ; So với ô thứ hai
    JNE NOT_EQUAL
    CMP AL, [SI + BX + 2]    ; So với ô thứ ba
    JNE NOT_EQUAL
    
    RET                      ; Cờ Zero=1 nếu bằng nhau
    
    NOT_EQUAL:
    OR AL, 1                 ; Cờ Zero=0 nếu không bằng
    RET
CHECK_LINE ENDP

; Kiểm tra 3 ô với bước nhảy tùy chỉnh (cột, đường chéo)
CHECK_LINE_WITH_STEP PROC
    PUSH BX                  ; Lưu BX
    
    MOV AL, [SI + BX]        ; Ô đầu tiên
    
    ADD BX, CX               ; BX = BX + step
    CMP AL, [SI + BX]        ; So với ô thứ hai
    JNE NOT_MATCH
    
    ADD BX, CX               ; BX = BX + step thêm lần nữa
    CMP AL, [SI + BX]        ; So với ô thứ ba
    JNE NOT_MATCH
    
    POP BX                   ; Khôi phục BX
    RET                      ; Cờ Zero=1 nếu bằng nhau
    
    NOT_MATCH:
    POP BX                   ; Khôi phục BX
    OR AL, 1                 ; Cờ Zero=0 nếu không bằng
    RET
CHECK_LINE_WITH_STEP ENDP

END MAIN