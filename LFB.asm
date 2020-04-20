; LFB.asm
; Простенькая программа, демонстрирующая работу с LFB
; Компиляция:
;   tasm.exe /m  LFB.asm
; Линк:
;   tlink.exe /x /3 LFB.obj
 
.386p      ; 32-битные регистры появились на 386
LFB_seg segment para public "code" use16        ; Наш сегмент
    assume  CS:LFB_seg,DS:LFB_seg,SS:LFB_seg    ; Код, данные, стек
                                ; находятся в одном сегменте
start:
 
; Этот блок кода отвечает за переход в BIG REAL MODE
; мы не будем на нём подробно останавливаться…
 
    push    cs
    pop ds
    mov eax,cr0
    test    al,1
    jz  no_V86
    mov dx,offset v86_msg
err_exit:
    mov ah,9
    int 21h
    mov ah,4Ch
    int 21h
v86_msg db  "Error!Bad mode in v86!$"
win_msg db  "Error!Windows is runing!$"
no_V86:
    mov ax,1600h
    int 2Fh
    test    al,al
    jz  no_windows
    mov dx,offset win_msg
    jmp err_exit
no_windows:
    xor eax,eax
    mov ax,cs
    shl eax,4
    add ax,offset GDT
    mov gdt_base,eax
    lgdt    fword ptr gdtr
    cli
    mov eax,cr0
    or  al,1
    mov cr0,eax
    jmp start_PM
   
start_PM:
    mov ax,8
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
   
    mov eax,cr0
    and al,0FEh
    mov cr0,eax
    jmp exit_PM
 
exit_PM:
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    sti
    mov ax,cs
    mov ds,ax
; Всё, теперь мы в BIG REAL MODE
; Нам нужны некоторые сегментные регистры
    push    ds
    pop es
; Получаем общую SVGA информацию
    mov ax,4F00h
; Сохраняем её в буфере
    mov di,offset Video_Buffer
    int 10h
; Считываем номер версии VBE в BX
    mov bx,word ptr [Video_Buffer+04h]
; Если он ниже чем 2.0
    cmp bx,0200h
; Выдать сообщение об ошибке
    jl  Not_support_LFB
; Иначе переходим далее
    jmp Next_step
Not_support_LFB:
    mov ah,9
    mov dx,offset Error
    int 21h
    ret
Next_step:
 
; Получаем информацию о режиме
    mov ax,4F01h
    mov cx,4112h
    mov edi, offset Info_Buffer
    int 10h
; Записываем физический адрес начала LFB в ESI
    mov esi,dword ptr [Info_Buffer+028h]
    push    esi
; Устанавливаем режим
    mov ax,4F02h
    mov bx,4112h
    int 10h
    pop esi
; Теперь выводим точку
 
    mov X_scr,640
    mov Pos_X,100
    mov Pos_Y,100
    mov Cr_Red,255
    mov Cr_Blue,0
    mov Cr_Green,255
    mov Cr_Alpha,0
    call    pset32bit
; Ожидание нажатия клавиши
    mov ah,1
    int 21h
; Выход
    mov ah,4Ch
    int 21h
 
; Процедура вывода точки на экран
 
pset32bit   proc
    pusha
; В общем случае формула выглядит так:
;  X_scr * Pos_Y * Количество компонент цвета + Pos_X * Количество компонент цвета
 
    mov eax,Pos_Y
    mov ebx,X_scr
    imul    eax,ebx
    imul    eax,4
    mov ebx,Pos_X
    imul    ebx,4
    add eax,ebx
    xor ecx,ecx
    xor ebx,ebx
    mov cl,Cr_Blue
    mov ch,Cr_Green
    mov bl,Cr_Red
    mov bh,Cr_Alpha
    mov byte ptr fs:[esi+eax],cl
    inc eax
    mov byte ptr fs:[esi+eax],ch
    inc eax
    mov byte ptr fs:[esi+eax],bl
    inc eax
    mov byte ptr fs:[esi+eax],bh
    popa
    ret
pset32bit   endp
; Начало области данных
 
GDT label   byte
; Нулевой дескриптор
    db  8 dup(0)
; 16-битный 4 Гб сегмент:
    db  0FFh,0FFh,0,0,0,10010010b,11001111b,0
; Размер GDT
gdtr    dw  16
; Линейный адрес GDT
gdt_base        dd  ?
Pos_X           dd  0   ; Координата X точки
Pos_Y           dd  0   ; Координата Y точки
X_scr           dd  0   ; Разрешение по X
Cr_Red          db  0   ; Красная компонента
Cr_Green        db  0   ; Зелёная компонента
Cr_Blue         db  0   ; Синяя компонента
Cr_Alpha        db  0   ; Альфа
Info_Buffer     db  256 dup(0)  ; Буфер для информации о режиме
Video_Buffer    db  512 dup (0) ; Буфер для общей SVGA информации
Error           db  "Not support VESA VBE 2.0 or higher!$"
LFB_seg ends
    end start