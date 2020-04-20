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

push di
MOV AL,COLOR; цвет линии
; рисуем горизонтальную линию
MOV CX,N; длина линии
REP STOSB
pop di

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

end start
