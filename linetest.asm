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
mov ah,0Fh ;��������� ����������
int 10h
mov videor,al

mov ax,13h
int 10h;���������� ���������� 256x320x200

call LineDraw ;������ �����

mov ah,0 ;���� ������� �� �������
int 16h

mov ax, word ptr videor ;������������ ����������
int 10h

int 20h ;����� �� ���������
videor db 0,0

LineDraw proc
;��������������� ���������
PUSH 0A000h
POP ES; ������������� ES �� ������� �����������

MOV DI,X ; � DI ���������� ��������� ����� �� X
MOV AX,320; ����� ������ ������
MUL Y; �������� �� Y
ADD DI,AX; � ���������� � X

;push di
;MOV AL, 1; ���� �����
;mov di, 0
; ������ �������������� �����
;MOV CX, 320*200 ; N; ����� �����
;REP STOSB
;pop di

; ������ ����� �� ������ 
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
MOV AL, 60; ���� �����
;������������ ����� ������ ������ ������
MOV CX,N; ����� �����
A1: MOV ES:[DI],AL; ������ ����� �� ������
ADD DI,320; ������� �� ��������� ������
LOOP A1
pop di

push di
MOV AL, 70; ���� �����
;������������ ����� � �������� ����� ����� ���������� ������
MOV CX,N; ����� �����
A2: MOV ES:[DI],AL; ������ ����� �� ������
ADD DI,319; ������� �� ��������� ������
LOOP A2
pop di

MOV AL, 80; ���� �����
;������������ ����� � �������� ������ � ������
MOV CX,N; ����� �����
A3: MOV ES:[DI],AL; ������ ����� �� ������
ADD DI,321; ������� �� ��������� ������
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
