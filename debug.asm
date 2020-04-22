; обработка нажатия клавиш
pause proc
    @start:
        xor ax, ax
        int 16h ; AL = ASCII символ (если AL=0, AH содержит расширенный код ASCII )
                ; AH = сканкод  или расширенный код ASCII
        cmp ah, 10h ; клавиша Q (quit)
        je @e
        cmp ah, 20h ; клавиша D (debug off)
        je @d
        cmp ah, 1Fh ; клавиша S (show parameters stack)
        je @s
        cmp ah, 13h ; клавиша R (show return stack)
        je @rs
        cmp ah, 31h ; клавиша N (next step)
        je @r
        cmp ah, 39h ; клавиша SPACE (next step)
        je @r
        cmp ah, 11h ; клавиша W(next word from dict)
        je @v
        jmp @start
    @e: mov ah, 4Ch ; выход из программы
        int 21h
    @v: call showWD
        jmp @start
    @rs: call showRS
        jmp @start
    @s: call showStack
        jmp @start
    @d: mov word ptr [DI]+102Q,00h  ; отладка выключена
        ;jmp @start
    @r: ret
pause endp

proc showWD
    push di
    push bx
    mov dx, offset @@caption
    call outText
    mov di,OFFSET @@ASCII ;
    mov ax, [si]
    call toHex
    mov dx, offset @@ASCII 
    call outText
    call outCR
    pop bx
    pop di
    ret
    @@caption DB "NEXT WORD:  $" 
    @@ASCII DB "0000    $" 
showWD endp

; печать дампа памяти в порядке стека
; cх - число байт 
; bx - адрес памяти
; dx - адрес строки
showStDump proc
    shr cx, 1   ; байты в слова
    or cx , cx
    jz @@r
    mov ax, ss
    mov es, ax         
  @@l:
    dec bx
    dec bx
    mov ax, es:[bx]    
    push bx
    mov di, dx
    call toHex        
    ;mov dx, offset @@ASCII
    call outText
    pop bx
    loop @@l
  @@r: 
    ret        
showStDump endP

; стек возвратов
showRS proc
    push di
    push si
    push es
    push bx
    mov dx, offset @@caption
    call outText    
    mov cx, offset XR0
    mov bx, BP
    sub cx, bx
    mov dx, offset @@ASCII
    mov bx, offset XR0
    call showStDump    
  @@r:    
    call outCR
    pop bx
    pop es 
    pop si
    pop di
    ret    
    @@caption DB "RS:  $" 
    @@ASCII DB "0000 $" 
showRS endP

; стек параметров
showStack proc    
    push di
    push si
    push es
    push bx
    mov dx, offset @@caption
    call outText    
    mov cx, 80h
    mov bx, SP
    add bx, 2*6   ; столько лишних элементов стеке
    sub cx, bx
    mov bx, 80h
    mov dx, offset @@ASCII
    call showStDump    
  @@r:    
    call outCR
    pop bx
    pop es 
    pop si
    pop di
    ret    
    @@caption DB "STACK:  $" 
    @@ASCII DB "0000 $" 
showStack endP

; AX- значение для печати в 16 виде
; di - адрес строки для вывода
toHex PROC        
    push cx
    mov cl,4            ; number of ASCII
@@1: rol ax,4           ; 1 Nibble (start with highest byte)
    mov bl,al
    and bl,0Fh          ; only low-Nibble
    add bl,30h          ; convert to ASCII
    cmp bl,39h          ; above 9?
    jna short @@2
    add bl,7            ; "A" to "F"
@@2: mov [di],bl         ; store ASCII in buffer
    inc di              ; increase target address
    dec cl              ; decrease loop counter
    jnz @@1              ; jump if cl is not equal 0 (zeroflag is not set)
    pop cx
    ret
toHex endP

; di- адрес буфера
; cx - число символов
; заполнение пробелом
blankBuffer proc
    push di
    cld
    mov al, 32
    rep stosb 
    pop di    
    ret
blankBuffer endp 

; вывод адреса и имени слова
; AX- значение адреса
printWORD proc
    push di
    push si
    push bx
    push ax
    mov di,OFFSET ASCII ; get the offset address
    mov cx, 25
    call blankBuffer
    ; печать адреса слова
    mov ax, si
    sub ax, 2 
    call toHex
    inc di
    inc di
    ; печать CFA слова
    pop ax
    push ax
    call toHex
    inc di  ; вывод имени слова после его адреса
    pop bx ; адрес слова CFA?
    ;mov al, byte ptr [bx-3] ; последний символ слова
    SUB bx, 3   ; 
    mm:          ; ищем поле длины        
    dec bx
    CMP  BYTE PTR [bx],  0 
    JNS  mm     ; JUMP IF POSITIVE
    mov cx, [bx] ; длина слова + всякие  служ. поля
    and cx, 003Fh
    mmm1:
    inc bx
    mov al, byte ptr [bx]
    and al, 7Fh ;   последний символ увеличен на 80h    
    mov [di],al
    inc di    
    loop mmm1    
    ; Print string
    mov dx,OFFSET ASCII ; DOS 1+ WRITE STRING TO STANDARD OUTPUT
    call outText       
    pop bx
    pop si
    pop di
    ret
    ASCII DB "0000: 0000                ",0Dh,0Ah,"$" ; buffer for ASCII string              
printWORD endP

outCR proc
    mov ah,9            ; DS:DX->'$'-terminated string
    lea dx, @@cr
    int 21h             ; (using pipe character">") or output to printer
    ret
    @@cr DB 0Dh, 0Ah, "$"
outCR endp

; вывод текста
outText proc    
    mov ah,9            ; DS:DX->'$'-terminated string
    int 21h             ; (using pipe character">") or output to printer
    ret
outText endp
