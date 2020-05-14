.286
.model tiny
.code
org 100h
start:
jmp _s 
x dw 150
y dw 70
n dw 60
color db 50
_s:
mov ah,0Fh ;запомнить видеорежим
int 10h
mov videor,al

mov ax,13h
int 10h;установили видеорежим 256x320x200

call LineDraw ;рисуем линию

mov ah,0 ;ждем нажатия на клавишу
int 16h

mov ax, word ptr videor ;восстановить видеорежим
int 10h

int 20h ;выход из программы
videor db 0,0

LineDraw proc
;предварительные установки
PUSH 0A000h
POP ES; позиционируем ES на область видеопамяти

MOV DI,X ; в DI координаты начальной точки по X
MOV AX,320; длина строки экрана
MUL Y; умножаем на Y
ADD DI,AX; и складываем с X

;push di
;MOV AL, 1; цвет линии
;mov di, 0
; рисуем горизонтальную линию
;MOV CX, 320*200 ; N; длина линии
;REP STOSB
;pop di

; рисуем линию по точкам 
	mov y, 0
cy:
	mov x, 0
cyx:
;	push x ; color
;	push y  
;	push x
;	jmp p13 ;call pix13 ; color y x ->     
	;mov bx, 320
	;mov ax, y
	;mul bx
	; mov bx, y
	;add ax, x
	;mov bx, ax
	mov ax, x
	mov es:[bx], al
t1:
	mov bx, ax ; x !!!!
	inc bx
	inc bx
	cmp bx, 320*200
	je stepy 
	mov x, bx
	jmp cyx
stepy:
	mov bx, y
	inc bx
	mov y, bx
	cmp bx, 1
	je e
	jmp cy
e:
	ret 

push di
MOV AL, 60; цвет линии
;Вертикальную линию обычно рисуют циклом
MOV CX,N; длина линии
A1: MOV ES:[DI],AL; рисуем точку на строке
ADD DI,320; переход на следующую строку
LOOP A1
pop di

push di
MOV AL, 70; цвет линии
;диагональную линию с наклоном влево можно нарисовать циклом
MOV CX,N; длина линии
A2: MOV ES:[DI],AL; рисуем точку на строке
ADD DI,319; переход на следующую строку
LOOP A2
pop di

MOV AL, 80; цвет линии
;диагональную линию с наклоном вправо — циклом
MOV CX,N; длина линии
A3: MOV ES:[DI],AL; рисуем точку на строке
ADD DI,321; переход на следующую строку
LOOP A3
ret
LineDraw endp

; color y x ->     
pix13 proc 
p13:	pop bx
	pop ax
	mov dx, 320
	mul dx
	add ax, bx
	;mov bx, 0a000h
	pop cx
	;push es
	;mov es, bx
	mov bx, ax
	mov es:[bx], cl
	;pop es
	jmp t1
pix13 endp

end start
