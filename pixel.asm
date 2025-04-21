.model large                ;  Inputs : 32 , 64 
.stack 100h
.data
    res dw 32
    init_flag db 0
    cb db 07H
    x dw ?
    y dw ?
    Xprint dw 0
    line dw 0 
    lcount dw 0
    mouseX dw ?
    mouseY dw ?
    X_10 db 0
    Y_10 db 0
    Color db 07h              ; Mouse / Fill color
    buttonPressed db ?
    filled_pixel dw 25 dup(?)
    pixel_offset dw ?
    old_bk_color db 9 dup(?)
    grid_res db 10

    i db 0
    ;Grid_arr [1024]  

    old_mouseDI dw -1       ; old Mouse Position
    prompt db 'Enter the resolution: $'                
.code

MAIN PROC  

mov ax, 13h     ; Set graphics mode 320x200
int 10h
mov ax, 0A000h  ; Set video memory segment
mov es, ax

MOV AX, 1  ; Show mouse pointer
INT 33h
MOV AX, 1               ; Initialize mouse
INT 33h
MOV AX, 2               ; set mouse visible
INT 33h

CALL FAR PTR PRINT_MATRIX

MAIN_LOOP:

    MOV AX, 3                 ; get mouse coords and buttons state
    INT 33h
    MOV [mouseX], CX          ; X coords
    MOV [mouseY], DX          ; y coords
    MOV [buttonPressed], BL   ; 1 -> left 2|3 -> right 4 -> middle 
    
    TEST BL, 1                ; right click pressed
    JZ con_mouse

    CALL FAR PTR COLOR_FILL
    ;CALL FAR PTR DRAW_MOUSE
    jmp MAIN_LOOP
con_mouse:
    CALL FAR PTR DRAW_MOUSE

    CALL FAR PTR GET_KEY_PRESS

    JMP MAIN_LOOP
MAIN ENDP

PRINT_MATRIX PROC
    mov [line],0
    mov [X_10],1
    mov [Y_10],0
    mov Xprint, 0
    grid_ver_loop:
        cmp [Y_10],5                   ; change the grid size 
        JNE continue1
        mov [Y_10],0
        CALL FAR PTR swapColor
        continue1: 
        mov [Xprint], 0
        grid_loop:
            ; Calculate X Quads (Width)
            mov ax, 320
            mov dx, [line]
            mul dx
            add ax, [Xprint]
            mov di, ax

            ; Store pixel in video memory
            mov al, [cb]
            mov es:[di], al
            
            cmp [X_10],5              ; change the grid size 
            JNE continue
            mov [X_10], 0
            CALL FAR PTR swapColor
            continue:
                inc [X_10]
                inc [Xprint]
            cmp [Xprint], 320
            JNE grid_loop
        inc [line]
        inc [Y_10]
        cmp [line], 200   ; Stop after 200 lines
        JLE grid_ver_loop
    ret    
PRINT_MATRIX ENDP

swapColor PROC FAR
    cmp [cb], 07h
    JNE color_switch_2
    mov [cb], 0Fh
    jmp r
    color_switch_2:
    mov [cb], 07h
    r:
        ret
swapColor ENDP

DRAW_MOUSE PROC
    ; Calculate DI based on mouse position
    MOV AX, [mouseY]
    MOV BX, 320
    MUL BX            
    ADD AX, [mouseX]  
    MOV DI, AX        

    CMP old_mouseDI, -1
    JNE not_first

    ; Store background colors for all cursor pixels
    MOV SI, DI
    MOV AL, BYTE PTR ES:[SI]  
    MOV [old_bk_color], AL  

    MOV AL, BYTE PTR ES:[SI+1]  
    MOV [old_bk_color + 1], AL  

    MOV AL, BYTE PTR ES:[SI-1]  
    MOV [old_bk_color + 2], AL  

    MOV AL, BYTE PTR ES:[SI+320]  
    MOV [old_bk_color + 3], AL

    MOV AL, BYTE PTR ES:[SI+319]  
    MOV [old_bk_color + 4], AL

    MOV AL, BYTE PTR ES:[SI+318]  
    MOV [old_bk_color + 5], AL  

    MOV AL, BYTE PTR ES:[SI+321]  
    MOV [old_bk_color + 6], AL

    MOV AL, BYTE PTR ES:[SI+322]  
    MOV [old_bk_color + 7], AL

    MOV AL, BYTE PTR ES:[SI-320]  
    MOV [old_bk_color + 8], AL  

    ; Draw cross cursor
    mov AL,[Color]
    MOV BYTE PTR ES:[DI], AL   ; Center
    MOV BYTE PTR ES:[DI+1], AL ; Right
    MOV BYTE PTR ES:[DI-1], AL ; Left
    MOV BYTE PTR ES:[DI+320], AL ; Below
    MOV BYTE PTR ES:[DI+319], AL
    MOV BYTE PTR ES:[DI+318], AL
    MOV BYTE PTR ES:[DI+321], AL
    MOV BYTE PTR ES:[DI+322], AL
    MOV BYTE PTR ES:[DI-320], AL ; Above

    MOV [old_mouseDI], DI
    RET 

not_first:
    ; Restore old pixels first
    MOV SI, old_mouseDI
    MOV BL, [old_bk_color]
    MOV BYTE PTR ES:[SI], BL  

    MOV BL, [old_bk_color + 1]
    MOV BYTE PTR ES:[SI+1], BL  

    MOV BL, [old_bk_color + 2]
    MOV BYTE PTR ES:[SI-1], BL  

    MOV BL, [old_bk_color + 3]
    MOV BYTE PTR ES:[SI+320], BL  

    MOV BL, [old_bk_color + 4]
    MOV BYTE PTR ES:[SI+319], BL

    MOV BL, [old_bk_color + 5]
    MOV BYTE PTR ES:[SI+318], BL

    MOV BL, [old_bk_color + 6]
    MOV BYTE PTR ES:[SI+321], BL

    MOV BL, [old_bk_color + 7]
    MOV BYTE PTR ES:[SI+322], BL

    MOV BL, [old_bk_color + 8]
    MOV BYTE PTR ES:[SI-320], BL  

    ; Update new position
    MOV AX, [mouseY]
    MOV BX, 320
    MUL BX            
    ADD AX, [mouseX]  
    MOV DI, AX        

    ; Store new background colors before drawing new cursor
    MOV SI, DI
    MOV AL, BYTE PTR ES:[SI]  
    MOV [old_bk_color], AL  

    MOV AL, BYTE PTR ES:[SI+1]  
    MOV [old_bk_color + 1], AL  

    MOV AL, BYTE PTR ES:[SI-1]  
    MOV [old_bk_color + 2], AL  

    MOV AL, BYTE PTR ES:[SI+320]  
    MOV [old_bk_color + 3], AL

    MOV AL, BYTE PTR ES:[SI+319]  
    MOV [old_bk_color + 4], AL

    MOV AL, BYTE PTR ES:[SI+318]  
    MOV [old_bk_color + 5], AL  

    MOV AL, BYTE PTR ES:[SI+321]  
    MOV [old_bk_color + 6], AL

    MOV AL, BYTE PTR ES:[SI+322]  
    MOV [old_bk_color + 7], AL

    MOV AL, BYTE PTR ES:[SI-320]  
    MOV [old_bk_color + 8], AL  

    ; Draw new cursor
    mov AL,[Color]
    MOV BYTE PTR ES:[DI], AL   ; Center
    MOV BYTE PTR ES:[DI+1], AL ; Right
    MOV BYTE PTR ES:[DI-1], AL ; Left
    MOV BYTE PTR ES:[DI+320], AL ; Below
    MOV BYTE PTR ES:[DI+319], AL
    MOV BYTE PTR ES:[DI+318], AL
    MOV BYTE PTR ES:[DI+321], AL
    MOV BYTE PTR ES:[DI+322], AL
    MOV BYTE PTR ES:[DI-320], AL ; Above 

    MOV [old_mouseDI], DI
    RET
DRAW_MOUSE ENDP

GET_KEY_PRESS PROC
    MOV AH, 01h      ;check key press
    INT 16h
    JNZ CONTINUE2      ; if not zero, continue (no match)
    JMP NO_KEY        ; if zero (Z flag set), go to NO_KEY
CONTINUE2:

    MOV AH, 00h      ; Get  key
    INT 16h

    CMP AL, 'r'      ; r -> red
    JNE CHECK_PLUS
    MOV [Color], 04h
    JMP NO_KEY

CHECK_PLUS:
    CMP AL, '+'
    JNE CHECK_MINUS
    inc [Color]
    JMP NO_KEY 

CHECK_MINUS:
    CMP AL, '-'
    JNE CHECK_G
    dec [Color]
    JMP NO_KEY 

CHECK_G:
    CMP AL, 'g'      ; g -> green
    JNE CHECK_B
    MOV [Color], 02h
    JMP NO_KEY

CHECK_B:
    CMP AL, 'b'      ; b -> blue
    JNE CHECK_W
    MOV [Color], 01h
    JMP NO_KEY

CHECK_W:
    CMP AL, 'w'      ; w -> white
    JNE CHECK_Y
    MOV [Color], 0Fh

CHECK_Y:
    CMP AL, 'y'      ; w -> white
    JNE CHECK_SPACE
    MOV [Color], 0Eh

CHECK_SPACE:
    CMP AL,' '
    JNE CHECK_BACKSPACE
    MOV [Color],00h

CHECK_BACKSPACE:
    CMP AL,08h
    JNE CHECK_P
    call PRINT_MATRIX

CHECK_P:
    CMP AL,'p'
    JNE CHECK_EXIT
    call FAR PTR GET_DI        ; Compute DI from mouseX, mouseY
    mov bl, BYTE PTR ES:[di]   ; Read color byte at calculated offset
    mov [Color], bl

CHECK_EXIT:
    CMP AL, 1Bh       ; Check for ESC key
    JNE NO_KEY

    ; --- Clear screen with black background ---
    mov ax, 0600h     ; Scroll up entire window
    mov bh, 00h       ; Black background, black text
    mov cx, 0000h     ; Upper-left corner (row 0, col 0)
    mov dx, 184Fh     ; Lower-right corner (row 24, col 79)
    int 10h

    ; --- Set cursor position to top-left ---
    mov ah, 02h
    mov bh, 0
    mov dx, 0000h
    int 10h

    ; --- Exit to DOS ---
    mov ax, 4C00h
    int 21h


NO_KEY:
    RET

GET_KEY_PRESS ENDP

COLOR_FILL PROC FAR
    ; Set starting pointer for filled_pixel array
    mov bp, 0           ; Offset index into filled_pixel array

    MOV [old_mouseDI], -1

    ; === Calculate aligned X ===
    mov ax, [mouseX]
    xor dx, dx
    mov cl, 5
    div cl
    mov ah, 0
    mov cl, 5
    mul cl
    mov dx, ax          ; dx = adjusted x

    mov [lcount], dx

    ; === Calculate aligned Y ===
    mov ax, [mouseY]
    xor dx, dx
    mov cl, 5
    div cl
    mov ah, 0
    mov cl, 5
    mul cl
    ;dec ax
    mov si, ax
    mov bx, ax
    add bx, 5

v_fill:
    mov ax, si
    mov cx, 320
    mul cx
    mov dx, [lcount]
    add ax, dx
    mov di, ax          ; di = offset

    mov cx, 5
h_fill:
    mov al, [Color]
    mov byte ptr es:[di], al

    inc di
    loop h_fill

    inc si
    cmp si, bx
    jl v_fill

    ret
COLOR_FILL ENDP

;RETURN DI FROM X,Y
GET_DI PROC FAR
    push ax
    push bx
    push cx
    push dx

    ; Align mouseX to grid
    mov ax, [mouseX]
    xor dx, dx
    mov cl, 5
    div cl
    xor ah, ah
    mul cl
    mov bx, ax         ; BX = aligned mouseX

    ; Align mouseY to grid
    mov ax, [mouseY]
    xor dx, dx
    mov cl, 5
    div cl
    xor ah, ah
    mul cl             ; AX = aligned mouseY

    ; Calculate offset: (Y * 320) + X
    mov cx, 320
    mul cx
    add ax, bx         ; AX = (aligned Y * 320) + aligned X
    mov di, ax         ; Store result in DI

    pop dx
    pop cx
    pop bx
    pop ax
    ret
GET_DI ENDP


end
