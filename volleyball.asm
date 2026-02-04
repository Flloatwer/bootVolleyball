BITS 16
ORG 0x7C00

mov si, msg ;print credits (DONT REMOVE pls)
mov ah, 0x00
mov al, 0x03
int 0x10
printloop:
    lodsb           
    cmp al, 0
    je doneprint
    mov ah, 0x0E    
    int 0x10
    jmp printloop
doneprint:
    mov bx, 0
dloop:
    inc bx
    cmp bx, 300
    je start
    call delay
    jmp dloop 

start:
mov bx, 0
; start video mode
mov ah, 0x00
mov al, 0x13
int 0x10
; clear register and init es
mov ax, 0xA000
mov es, ax
mov ax, 0x0000
mov byte [current_color], 15
; draw the paddle (dosent appear automatically)
call drawpaddle


;main game loop
loop:
    call delay
    call clearball
    call setballx
    call setbally
    call setballcoordinatesx
    call setballcoordinatesy
    call drawball
    call check ;bassicly also moves the paddles
    jmp loop

clearpaddle:    ;clear the last paddle instead of clearing the whole screen
    mov byte [current_color], 0
    call drawpaddle
    mov byte [current_color], 15
    ret

clearball:  ;remove the ball
    mov byte [current_color], 0
    call drawball
    mov byte [current_color], 15
    call drawpaddle
    ret

;move the ball in the right directions
setballcoordinatesx:
    cmp byte [balldx], 0
    je a1
    cmp byte [balldx], 1
    je a2
a1:
    inc word [ballx]
    ret
a2:
    dec word [ballx]
    ret
setballcoordinatesy:
    cmp byte [balldy], 0
    je b1
    cmp byte [balldy], 1
    je b2
b1:
    inc word [bally]
    ret
b2:
    dec word [bally]
    ret

;draw the ball
drawball:
    push ax ;pop all registers to save
    push bx
    push cx
    push dx
    mov ax, word [bally]    ;move the correct values to all registers
    mov bx, word [ballx]
    mov cx, ax
    mov dx, bx
drawballloop:
    call drawpixel  ;loop around drawing the lines, if at line 10 jump to a new line
    sub bx, dx
    inc bx
    cmp bx, 10
    je nextline3
    add bx, dx
    jmp drawballloop
nextline3:
    sub ax, cx  ;set to next line, return if done
    inc ax
    cmp ax, 10
    je returnfromball
    add ax, cx
    mov bx, dx
    jmp drawballloop
returnfromball:
    pop dx
    pop cx
    pop bx
    pop ax
    ret


;set the direction of the ball (x axis)
setballx:
    cmp word [ballx], 0 
    je setx0
    cmp word [ballx], 310
    je setx1
    ret
;set the x direction of the ball to 0
setx0:
    mov byte [balldx], 0
    ret
;opposite
setx1:
    mov byte [balldx], 1
    ret
setbally:
    cmp word [bally], -5
    je sety0
    cmp word [bally], 190
    je sety1
    ret
;set the y direction of the ball to 0
sety0:
    mov byte [balldy], 0
    ret
;opposite
sety1:
    mov byte [balldy], 1
    ret

;draw the paddle
drawpaddle:
    push ax
    push bx
    mov bx, 0
    mov al, [paddley]
    xor ah, ah
    mov cx, ax
drawpaddleloop:
    call drawpixel
    inc bx
    cmp bx, 5
    je nextline2
    jmp drawpaddleloop
nextline2:
    sub ax, cx
    inc ax
    cmp ax, 51
    je return
    add ax, cx
    mov bx, 0
    jmp drawpaddleloop

movepaddle:
    cmp al, 'w'
    je movepaddleup
    cmp byte [paddley], 147
    je return
    call clearpaddle
    add byte [paddley], 21
    call drawpaddle
    jmp return
movepaddleup:
    cmp byte [paddley], 0
    je return
    call clearpaddle
    sub byte [paddley], 21
    call drawpaddle
    jmp return

;clear the screen
clear:
    push ax ; get ready to clear
    push bx
    mov byte [current_color], 6
    mov ax, 0
    mov ax, bx
clearloop:
    call drawpixel
    inc bx
    cmp bx, 320 ;check if at the end of line
    je nextline
    jmp clearloop
nextline:
    inc ax  ;draw the next line
    cmp ax, 200
    je returnfromclear
    jmp clearloop

returnfromclear:
    mov dl, 15  ;change color back to white for drawing
return: ;return for pretty much anything, it resets rhe registers too. mostly for e.g. cmp then je return
    pop bx
    pop ax
    ret

;x is stored in bx, y in ax, color is in cl
drawpixel:
	push ax
	push bx
    push cx
	imul ax, 320
	add ax, bx
	mov bx, ax
    mov cl, byte [current_color]
	mov byte [es:bx], cl
	pop cx
    pop bx
	pop ax
	ret

check:
    push ax
    push bx
    mov ah, 0x01
    int 0x16
    jz return
    mov ah, 0x00
    int 0x16
    jmp movepaddle
delay:
    mov ah, 86h       ; BIOS wait function
    mov cx, 0         
    mov dx, 5000   
    int 15h
    ret

;define memory addresses
paddley db 42
ballx dw 30
bally dw 70
balldx db 0
balldy db 1
ball_iteration_x1 db 0
ball_iteration_x2 db 0
ball_iteration_y1 db 0
ball_iteration_y2 db 0
current_color db 15
msg db "bootVolleyball v1 by Flloatwer", 0    ;pls dont change

times 510 - ($ - $$) db 0
dw 0xAA55
