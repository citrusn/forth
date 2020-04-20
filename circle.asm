.286
.model tiny
.code
RADIUS EQU 99 ;рисуем окружность с радиусом 99
RADIUS2 EQU RADIUS*RADIUS ;квадрат радиуса
DIAMETR EQU RADIUS*2 ;диаметр окружности
N EQU 11*RADIUS/14;количество точек на 1/8
COLOR EQU 10 ;цвет окружности
ORG 100h
start: MOV AH,0Fh ;узнать номер текущего видеорежима
INT 10h
MOV VIDEOR,AL ;запомним текущий видеорежим
MOV AX,13h;установить видеорежим 320х200х256
INT 10h
PUSH 0A000h;установить регистр ES на сегмент
POP ES ; видеопамяти
XOR BP,BP ;будем увеличивать X и Y
MOV Y,RADIUS-1 ;координаты X=0 и Y=R
CALL DRAW_OCT1 ;рисуем восьмушку окружности
MOV BP,RADIUS-1 ;координата X=2*R
MOV Y,0 ;координата Y=0
CALL DRAW_OCT2 ;рисуем восьмушку окружности
NEG DELTA_X ;увеличиваем Y и уменьшаем X
MOV Y,RADIUS
MOV BP,DIAMETR ;координаты Y=R и X=2*R
CALL DRAW_OCT1 ;рисуем восьмушку окружности
MOV BP,RADIUS ;координата X=R
MOV Y,0 ;координата Y=0
CALL DRAW_OCT2 ;рисуем восьмушку окружности
NEG DELTA_Y ;уменьшаем координаты Y и X
MOV Y,RADIUS ;координата Y=R
MOV BP,DIAMETR ;координата X=2*R
CALL DRAW_OCT1 ;рисуем восьмушку окружности
MOV BP,RADIUS ;координата X=R
MOV Y,DIAMETR ;координата Y=2*R
CALL DRAW_OCT2 ;рисуем восьмушку окружности
NEG DELTA_X ; уменьшаем Y и увеличиваем X
XOR BP,BP ;координата X=0
MOV Y,RADIUS ;координата Y=R
CALL DRAW_OCT1 ;рисуем восьмушку окружности
MOV BP,RADIUS ;координата X=R
MOV Y,DIAMETR ;координата Y=2*R
CALL DRAW_OCT2 ;рисуем восьмушку окружности

XOR AX,AX ;ожидание нажатия любой клавиши
INT 16h

MOV AX,WORD PTR VIDEOR;восстановление видеорежима
INT 10h
RET ;выход из программы

PROC DELTA_CALC ;рассчитаем ошибку накопления
MOV BX,AX ;в AX значение координаты X или Y
DEC AX ;вычислим (Y+0,5)2 » Y2+Y
MUL AX ;или (X+0,5)2 » X2+X
ADD AX,BX
MOV DELTA,AX ;и поместим это значение в DELTA
RET
ENDP

;процедура прорисовки 1/8 окружности с вычислением
PROC DRAW_OCT1 ; координаты X
MOV AX,Y
SHL AX,6 ;должно быть DI=Y*320, но для умножения
MOV DI,AX ;на 320 используем сдвиги, AX= Y*64,
SHL AX,2 ;сохраним AX в DI и умножим Y*64 на 4
ADD DI,AX ;DI=Y*(256+64)=Y*320.
MOV AX,BP
SUB AX,RADIUS ;BP=X AX=R-X
CALL DELTA_CALC ;расчет ошибки накопления по X
MOV CX,N
CIRC1: MOV AX,Y
SUB AX,RADIUS ;AX=Y-R
MUL AX
NEG AX
ADD AX,RADIUS2 ;AX=R2-Y2
CMP DELTA,AX ;сравнить текущий X2=R2-Y2 с ошибкой
JBE A3 ;накопления, если меньше, увеличиваем или
ADD BP,DELTA_X;уменьшаем только Y, иначе
MOV AX,BP;увеличиваем или уменьшаем еще и X и
SUB AX,RADIUS; вычисляем новую ошибку накопления
CALL DELTA_CALC
A3: CMP DELTA_Y,1
JNE A1
ADD DI,320
JMP SHORT A2
A1: SUB DI,320
A2: MOV BYTE PTR ES:[DI][BP],COLOR;выводим точку на
MOV AX,DELTA_Y; экран
ADD Y,AX
LOOP CIRC1 ;повторяем цикл
RET
ENDP

;процедура прорисовки 1/8 окружности с вычислением
PROC DRAW_OCT2 ; координаты X
MOV AX,Y
SHL AX,6 ;должно быть DI=Y*320, но для умножения
MOV DI,AX ;на 320 используем сдвиги, AX= Y*64,
SHL AX,2 ;сохраним AX в DI и умножим Y*64 на 4
ADD DI,AX ;DI=Y*(256+64)=Y*320.
MOV AX, Y
SUB AX,RADIUS
CALL DELTA_CALC
MOV CX,N
CIRC2: MOV AX,BP
SUB AX,RADIUS
MUL AX
NEG AX
ADD AX,RADIUS2 ;AX=R^2-(X-R)^2
CMP DELTA,AX
JBE A5
MOV AX,DELTA_Y
ADD Y,AX
MOV AX,Y
SUB AX,RADIUS
CALL DELTA_CALC
CMP DELTA_Y,1
JNE A4
ADD DI,320
JMP SHORT A5
A4: SUB DI,320
A5: ADD BP,DELTA_X
MOV BYTE PTR ES:[DI][BP],COLOR
LOOP CIRC2
RET
ENDP

VIDEOR DB 0,0 ;значение текущего видеорежима
DELTA DW 0 ;ошибка накопления
DELTA_X DW 1 ;смещение по оси X
DELTA_Y DW 1 ;смещение по оси Y
Y DW 0 ;координата Y
END start
