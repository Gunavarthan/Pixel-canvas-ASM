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
    
    cmp [mouseY],190
    JG con_mouse

    TEST BL, 1                ; right click pressed
    JZ con_mouse

    CALL FAR PTR COLOR_FILL
    CALL FAR PTR DRAW_MOUSE
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
            
            cmp [X_10], 5              ; change the grid size 
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
    ; Calculate DI from mouse position
    MOV AX, [mouseY]
    MOV BX, 320
    MUL BX
    ADD AX, [mouseX]
    MOV DI, AX

    CMP old_mouseDI, -1
    JNE not_first

    ; First time: store background
    MOV SI, DI
    MOV AL, BYTE PTR ES:[SI]         ; Center
    MOV [old_bk_color], AL

    MOV AL, BYTE PTR ES:[SI+320]
    MOV [old_bk_color + 1], AL

    MOV AL, BYTE PTR ES:[SI+319]
    MOV [old_bk_color + 2], AL

    MOV AL, BYTE PTR ES:[SI+318]
    MOV [old_bk_color + 3], AL

    MOV AL, BYTE PTR ES:[SI+321]
    MOV [old_bk_color + 4], AL

    MOV AL, BYTE PTR ES:[SI+322]
    MOV [old_bk_color + 5], AL

    MOV AL, BYTE PTR ES:[SI-320]
    MOV [old_bk_color + 6], AL

    ; Draw the cursor
    MOV AL, [Color]
    MOV BYTE PTR ES:[DI], AL
    MOV BYTE PTR ES:[DI+320], AL
    MOV BYTE PTR ES:[DI+319], AL
    MOV BYTE PTR ES:[DI+318], AL
    MOV BYTE PTR ES:[DI+321], AL
    MOV BYTE PTR ES:[DI+322], AL
    MOV BYTE PTR ES:[DI-320], AL

    MOV [old_mouseDI], DI
    RET

not_first:
    ; CMP [buttonPressed], 1
    ; JE continue2

    ; Restore old pixels only if not filled
    MOV SI, old_mouseDI

    ; Center
    MOV AX, SI
    MOV pixel_offset, AX
    CALL FAR PTR check_pixel_filled
    CMP AL, 1
    JE skip_restore_0
    MOV BL, [old_bk_color]
    MOV BYTE PTR ES:[SI], BL
skip_restore_0:

    ; +320
    MOV AX, SI
    ADD AX, 320
    MOV pixel_offset, AX
    CALL FAR PTR check_pixel_filled
    CMP AL, 1
    JE skip_restore_1
    MOV BL, [old_bk_color + 1]
    MOV BYTE PTR ES:[SI+320], BL
skip_restore_1:

    ; +319
    MOV AX, SI
    ADD AX, 319
    MOV pixel_offset, AX
    CALL FAR PTR check_pixel_filled
    CMP AL, 1
    JE skip_restore_2
    MOV BL, [old_bk_color + 2]
    MOV BYTE PTR ES:[SI+319], BL
skip_restore_2:

    ; +318
    MOV AX, SI
    ADD AX, 318
    MOV pixel_offset, AX
    CALL FAR PTR check_pixel_filled
    CMP AL, 1
    JE skip_restore_3
    MOV BL, [old_bk_color + 3]
    MOV BYTE PTR ES:[SI+318], BL
skip_restore_3:

    ; +321
    MOV AX, SI
    ADD AX, 321
    MOV pixel_offset, AX
    CALL FAR PTR check_pixel_filled
    CMP AL, 1
    JE skip_restore_4
    MOV BL, [old_bk_color + 4]
    MOV BYTE PTR ES:[SI+321], BL
skip_restore_4:

    ; +322
    MOV AX, SI
    ADD AX, 322
    MOV pixel_offset, AX
    CALL FAR PTR check_pixel_filled
    CMP AL, 1
    JE skip_restore_5
    MOV BL, [old_bk_color + 5]
    MOV BYTE PTR ES:[SI+322], BL
skip_restore_5:

    ; -320
    MOV AX, SI
    SUB AX, 320
    MOV pixel_offset, AX
    CALL FAR PTR check_pixel_filled
    CMP AL, 1
    JE skip_restore_6
    MOV BL, [old_bk_color + 6]
    MOV BYTE PTR ES:[SI-320], BL
skip_restore_6:

continue2:
    ; Update to new position
    MOV AX, [mouseY]
    MOV BX, 320
    MUL BX
    ADD AX, [mouseX]
    MOV DI, AX

    ; Save background
    MOV SI, DI
    MOV AL, BYTE PTR ES:[SI]
    MOV [old_bk_color], AL

    MOV AL, BYTE PTR ES:[SI+320]
    MOV [old_bk_color + 1], AL

    MOV AL, BYTE PTR ES:[SI+319]
    MOV [old_bk_color + 2], AL

    MOV AL, BYTE PTR ES:[SI+318]
    MOV [old_bk_color + 3], AL

    MOV AL, BYTE PTR ES:[SI+321]
    MOV [old_bk_color + 4], AL

    MOV AL, BYTE PTR ES:[SI+322]
    MOV [old_bk_color + 5], AL

    MOV AL, BYTE PTR ES:[SI-320]
    MOV [old_bk_color + 6], AL

    ; Draw cursor again
    MOV AL, [Color]
    MOV BYTE PTR ES:[DI], AL
    MOV BYTE PTR ES:[DI+320], AL
    MOV BYTE PTR ES:[DI+319], AL
    MOV BYTE PTR ES:[DI+318], AL
    MOV BYTE PTR ES:[DI+321], AL
    MOV BYTE PTR ES:[DI+322], AL
    MOV BYTE PTR ES:[DI-320], AL

    MOV [old_mouseDI], DI
    RET
DRAW_MOUSE ENDP

GET_KEY_PRESS PROC
    MOV AH, 01h      ;check key press
    INT 16h
    JZ NO_KEY        ; no key, return

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
    JNE NO_KEY
    call PRINT_MATRIX

NO_KEY:
    RET

GET_KEY_PRESS ENDP

COLOR_FILL PROC FAR
    ; Set starting pointer for filled_pixel array
    mov bp, 0           ; Offset index into filled_pixel array

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
    dec ax
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

    ; Store current DI into filled_pixel array
    mov [filled_pixel + bp], di
    add bp, 2           ; Move to next slot

    inc di
    loop h_fill

    inc si
    cmp si, bx
    jl v_fill

    ret
COLOR_FILL ENDP

; === Check if [SI+offset] is in filled_pixel array ===
; Result: ZF = 1 → not found → restore it
;         ZF = 0 → found → skip restoration

check_pixel_filled PROC FAR
    push ax
    push bx
    push cx
    mov ax, pixel_offset     ; DI+offset
    mov cx, 25
    mov bx, 0
search_loop:
    cmp ax, [filled_pixel + bx]
    je pixel_found
    add bx, 2
    loop search_loop
    ; Not found
    pop cx
    pop bx
    pop ax
    mov al, 0                ; Not found → AL = 0
    ret

pixel_found:
    pop cx
    pop bx
    pop ax
    mov al, 1                ; Found → AL = 1
    ret
check_pixel_filled ENDP

end
