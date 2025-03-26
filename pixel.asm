.model large                ;  Inputs : 32 , 64 
.stack 100h
.data
    res dw 32
    x dw ?
    y dw ?
    lcount dw 0
    line dw 0 
    mouseX dw ?
    mouseY dw ?
    Color db 0Fh              ; Mouse / Fill color
    buttonPressed db ?
    ;Grid_arr [1024]  

    old_mouseDI dw -1       ; old Mouse Position
    old_bk_color db 0Fh      ; old Mouse BG colors
    prompt db 'Enter the resolution: $'                
.code

MAIN PROC  
    
CALL FAR PTR PRINT_MATRIX

CALL FAR PTR DRAW_MENUE

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

    jmp MAIN_LOOP
con_mouse:
    CALL FAR PTR DRAW_MOUSE

    CALL FAR PTR GET_KEY_PRESS

    JMP MAIN_LOOP

    ;mov ax, 4C00h  
    ;int 21h  
        
MAIN ENDP

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

DRAW_MENUE PROC
    ; Draw horizontal lines as before
    mov cx, 7
m_loop:
    mov bx, 200
    sub bx, cx  
    call FAR PTR HORZ_LINE
    loop m_loop

    ; =========== 
    ; ==== W ====
    ; ===========

    ; W: 194...198,17  => 62097, 62417, 62737, 63057, 63377
    mov al, 00h
    mov di, 62097                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62417                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62737                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63057                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63377                   
    mov byte ptr es:[di], al 

    ; W: 194...198,21  => 62101, 62421, 62741, 63061, 63381
    mov al, 00h
    mov di, 62101                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62421                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62741                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63061                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63381                   
    mov byte ptr es:[di], al 

    ; W: 197,18 => 63058
    mov al, 00h
    mov di, 63058                   
    mov byte ptr es:[di], al 

    ; W: 196,19 => 62739
    mov al, 00h
    mov di, 62739                   
    mov byte ptr es:[di], al 

    ; W: 197,20 => 63060
    mov al, 00h
    mov di, 63060                   
    mov byte ptr es:[di], al 

    ; =========== 
    ; ==== R ====
    ; ===========

    ; R: 194...198,29  => 62109, 62429, 62749, 63069, 63389
    mov al, 00h
    mov di, 62109                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62429                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62749                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63069                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63389                   
    mov byte ptr es:[di], al 

    ; R: 194,30...31  => 62110, 62111
    mov al, 00h
    mov di, 62110                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62111                   
    mov byte ptr es:[di], al 

    ; R: 195,32 => 62432
    mov al, 00h
    mov di, 62432                   
    mov byte ptr es:[di], al 

    ; R: 196,30...31  => 62750, 62751
    mov al, 00h
    mov di, 62750                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62751                   
    mov byte ptr es:[di], al 

    ; R: 197,31 => 63071
    mov al, 00h
    mov di, 63071                   
    mov byte ptr es:[di], al 

    ; R: 198,32 => 63392
    mov al, 00h
    mov di, 63392                   
    mov byte ptr es:[di], al 

    ; =========== 
    ; ==== G ====
    ; ===========

    ; G: 194,41...42  => 62121, 62122
    mov al, 00h
    mov di, 62121                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62122                   
    mov byte ptr es:[di], al 

    ; G: 195...197,40  => 62440, 62760, 63080
    mov al, 00h
    mov di, 62440                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62760                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63080                   
    mov byte ptr es:[di], al 

    ; G: 196,42...43  => 62762, 62763
    mov al, 00h
    mov di, 62762                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62763                   
    mov byte ptr es:[di], al 

    ; G: 197,43 => 63083
    mov al, 00h
    mov di, 63083                   
    mov byte ptr es:[di], al 

    ; G: 198,41..42  => 63401, 63402
    mov al, 00h
    mov di, 63401                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63402                   
    mov byte ptr es:[di], al 

    ; =========== 
    ; ==== B ====
    ; ===========

    ; B: 194...198,51  => 62131, 62451, 62771, 63091, 63411
    mov al, 00h
    mov di, 62131                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62451                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62771                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63091                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63411                   
    mov byte ptr es:[di], al 

    ; B: 194,52...53  => 62132, 62133
    mov al, 00h
    mov di, 62132                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62133                   
    mov byte ptr es:[di], al 

    ; B: 196,52...53  => 62772, 62773
    mov al, 00h
    mov di, 62772                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62773                   
    mov byte ptr es:[di], al 

    ; B: 198,52...53  => 63412, 63413
    mov al, 00h
    mov di, 63412                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 63413                   
    mov byte ptr es:[di], al 

    ; B: 197,54 => 63094
    mov al, 00h
    mov di, 63094                   
    mov byte ptr es:[di], al 

    ; B: 195,54 => 62454
    mov al, 00h
    mov di, 62454                   
    mov byte ptr es:[di], al 

    ; =========== 
    ; ==== Y ====
    ; ===========

    ; Y: 194,[62,66]  => 62142, 62146
    mov al, 00h
    mov di, 62142                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62146                   
    mov byte ptr es:[di], al 

    ; Y: 195,[62,66]  => 62462, 62466
    mov al, 00h
    mov di, 62462                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62466                   
    mov byte ptr es:[di], al 

    ; Y: 196,63...65  => 62783, 62784, 62785
    mov al, 00h
    mov di, 62783                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62784                   
    mov byte ptr es:[di], al 

    mov al, 00h
    mov di, 62785                   
    mov byte ptr es:[di], al 

    ; Y: 197,64 => 63104
    mov al, 00h
    mov di, 63104                   
    mov byte ptr es:[di], al 

    ; Y: 198,64 => 63424
    mov al, 00h
    mov di, 63424                   
    mov byte ptr es:[di], al 

    ret
DRAW_MENUE ENDP
       
GET_KEY_PRESS PROC
    MOV AH, 01h      ;check key press
    INT 16h
    JZ NO_KEY        ; no key, return

    MOV AH, 00h      ; Get  key
    INT 16h

    CMP AL, 'r'      ; r -> red
    JNE CHECK_G
    MOV [Color], 04h
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
    JNE CHECK_BACKSPACE
    MOV [Color], 0Eh

CHECK_BACKSPACE:
    CMP AL,08h
    JNE NO_KEY
    MOV [Color],00h

NO_KEY:
    RET

GET_KEY_PRESS ENDP

PRINT_MATRIX PROC                                       ; Works Some how don't change any thing 
    lea dx, PROMPT
    mov ah,9
    int 21h

    mov BH,0
    mov BL,32
    mov [res], bx

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

    ; Calculate X Quads (Width)
    mov ax, 320
    mov bx, [res]
    div bx
    mov ah, 0
    mov [x], ax       ; Store X spacing

    mov cx, [res]     ; Loop counter
    mov bx, 0       ; Start X at 0
    vert_loop:
        mov dx, [x]
        add bx, dx  ; Move to next X position
        CALL FAR PTR VERT_LINE
        cmp bx,320
        jle vert_loop

    ; Calculate Y Quads (Height)
    mov ax, 200
    mov bx, [res]
    div bx
    mov ah, 0
    mov [y], ax       ; Store Y spacing

    mov cx, [res]
    mov bx, 0       ; Start Y at 0
    horz_loop:
        mov dx, [y]
        add bx, dx  ; Move to next Y position
        CALL FAR PTR HORZ_LINE
        cmp bx,200
        jle horz_loop
        
    ret    
PRINT_MATRIX ENDP

CLS PROC
    MOV AX, 0600H  ; Scroll entire screen up (clear screen)
    MOV BH, 07H    ; White text on black background
    MOV CX, 0000H  ; Upper-left corner (row=0, col=0)
    MOV DX, 184FH  ; Lower-right corner (row=24, col=79)
    INT 10H        ; Call BIOS video interrupt

    MOV DH, 0      ; Cursor row = 0
    MOV DL, 0      ; Cursor column = 0
    MOV AH, [color]    ; Set cursor position function
    MOV BH, 0      ; Page number
    INT 10H        ; Call BIOS interrupt

    RET
CLS ENDP

VERT_LINE PROC                      ; x quads -> BX to draw line
    mov [line],0
    v_loop:

        mov ax,320  
        mov Dx, [line]
        mul Dx
        add ax,BX
        mov di,ax

        mov al, 07h       
        mov byte ptr es:[di], al  

        inc [line]
        cmp [line],200
        JNE v_loop
    RET
VERT_LINE ENDP

HORZ_LINE PROC                      ; y quads -> BX to draw line
    mov [line],0
    mov ax,320  
    mul Bx
    mov di,ax
    h_loop:
            
        mov al, 07h        
        mov byte ptr es:[di], al  

        inc di
        inc [line]
        cmp [line],320
        JL h_loop
    RET
HORZ_LINE ENDP

TWO_INPUT PROC              ;input from user is at bl
    XOR BX, BX              
    MOV AH, 1
    INT 21H    
    SUB AL, '0'             
    MOV BL, AL              

    MOV AH, 1
    INT 21H    
    SUB AL, '0'             
    MOV BH, AL   

    MOV AL, 10
    MUL BL                  
    ADD AL, BH              
    MOV BL, AL              
    XOR BH, BH              

    RET
TWO_INPUT ENDP

PRINT_NUMBER PROC           ; mov number to print on to al
    CMP AL, 10
    JL PRINT_SINGLE_DIGIT  ; If < 10, print directly

    mov ah,0
    aam
    mov bx,ax

    ADD bh, '0'     ; Convert tens to ASCII
    MOV DL, bh      ; Store in DL for printing
    MOV AH, 2
    INT 21H         ; Print tens digit

    ADD bL, '0'     ; Convert to ASCII
    MOV DL, bL
    MOV AH, 2
    INT 21H         ; Print ones digit

    RET

PRINT_SINGLE_DIGIT:
    ADD AL, '0'     ; Convert single digit to ASCII
    MOV DL, AL
    MOV AH, 2
    INT 21H
    RET

PRINT_NUMBER ENDP

COLOR_FILL PROC FAR
    mov ax, 0A000h   ; Set ES to VGA graphics memory
    mov es, ax

    mov ax, [mouseX]
    mov cl, 10
    div cl
    mov ah,0
    ; mov dx, ax
    ; mov ax, dx
    mov cl, 10
    mul cl
    mov dx, ax      ; X coordinate adjustment

    push dx

    mov ax, [mouseY]
    mov cl, 6
    div cl
    mov ah, 0       ; Clear AH before division
    ; mov bx, ax
    ; mov ax, bx
    mul cl
    mov bx, ax       ; Y coordinate adjustment

    mov si, bx       ; Store row index separately
    add bx,5h
    inc si

v_fill:
    mov ax, 320
    mul si
    
    mov di, ax  ; Store pixel address in DI
    pop dx
    push dx
    add di,1
    add di, dx
    mov cx, 9  ; Width of fill (horizontal pixels)

h_fill:
    mov al, [Color]        
    mov byte ptr es:[di], al
    inc di
    loop h_fill  ; Repeat for 10 pixels horizontally

    inc si       ; Move to next row
    cmp si, bx   ; Limit vertical fill
    jng v_fill

    pop [lcount]
    RET
COLOR_FILL ENDP

end
