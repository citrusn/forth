; 253 слова head
; 103 слова используют $col
; 9 слова использует $con 
; 29 слова использует $use
; 1 слово forth

masm
.8086
.MODEL SMALL
LOCALS
LINK=0
    .LALL
<<<<<<< HEAD
    ; Макроопределения
    ; Описание примитивов и слов высокого уровня
    HEAD  MACRO length,name,lchar,labl,code
    LINK$=$
        DB  length  ; NFA 7 бит равен 1.
                    ; 6 - признак immediate. 5- слово не описано smudge
=======
    ; ���ம�।������
    ; ���ᠭ�� �ਬ�⨢�� � ᫮� ��᮪��� �஢��

    HEAD  MACRO length, name, lchar, labl, code
    	LINK$=$
        DB  length  ; NFA 7 ��� ࠢ�� 1.
                    ; 6 - �ਧ��� immediate. 5- ᫮�� �� ���ᠭ� smudge
>>>>>>> 51f9fa2cf38b0a7ffc15f2cb0844f4e6edec42d6
        IFNB <name>
        DB  name
        ENDIF
<<<<<<< HEAD
        DB  lchar   ; последний символ слова + 128 (7 бит = 1).  
        DW  LINK    ; LFA предыдущее слово (адрес первого символа имени)
    LINK=LINK$
    labl LABEL FAR  ; CFA
=======
        DB  lchar   ; ��᫥���� ᨬ��� ᫮�� + 128 (7 ��� = 1).  

        DW  LINK    ; LFA �।��饥 ᫮�� (���� ��ࢮ�� ᨬ���� �����)
    	LINK=LINK$

    	labl LABEL FAR  ; CFA
>>>>>>> 51f9fa2cf38b0a7ffc15f2cb0844f4e6edec42d6
        IFNB <code> ; 
        DW code
        ELSE
        DW  $+2
        ENDIF
    ENDM
    HEAD2  MACRO length, name, lchar, labl, code
    	LINK$=$
        DB  length  ; NFA 7 ��� ࠢ�� 1.
                    ; 6 - �ਧ��� immediate. 5- ᫮�� �� ���ᠭ� smudge
        IFNB <name>
        DB  '&name','>'
        ENDIF
        DB  lchar   ; ��᫥���� ᨬ��� ᫮�� + 128 (7 ��� = 1).  

        DW  LINK    ; LFA �।��饥 ᫮�� (���� ��ࢮ�� ᨬ���� �����)
    	LINK=LINK$

    	labl LABEL FAR  ; CFA
        IFNB <code> ; 
        DW code
        ELSE
        DW  $+2
        ENDIF
    ENDM

    debug equ 1
    NEXT MACRO   ; переход к исполнению следующего слова
        local m1 
        LODSW           ; DS:[SI] -> AX ; SI = SI + 2
        MOV  BX, AX     ; BX равен CFA  следующего слова
    ; ------ call debugger --------     
    IF debug
        cmp byte ptr [di+102Q], 0   
        jz m1
        call printWORD
        call pause                 
      m1:
    ENDIF 
    ; -----------------------------
        JMP WORD PTR [BX] 
    ENDM

  TITLE   FORTH Interpreter

   ARRAY   SEGMENT   
   $TIME   DW  0,0                     ; TIMER COUNTER
   $DATE   DW  0                       ; DATE

   ;  Сегмент стека и словарь пользователя размещен в конце текста
   ;  интерпретатора. Для версии, записываемой в ПЗУ, их нужно
   ;  разместить здесь.

   DSKBUF  DW  3 DUP(0,512 DUP(0),0)   ; Экранные буферы на 1024 байта
   ENDBUF  DW  0        ; 6 1034 (40Ah) 2062(80Eh) адреса буферов

   XTIB    DW  92 DUP(0)               ; Входной буфер
   XR0     DW  0,0                     ; Стек возвратов  растет в область
                                       ; меньших адресов.  ADD BP - убрать данные
   XUP     DW  102 DUP(0)              ; USER-область на нее указывает DI

   $STI    DW  TASK-7  ;               ; Стартовая таблица PFA слова TASK
   $US     DW  XUP     ;               ; адрес user области
   ;    переменные
   $STK    DW  XS0     ;+6              ; SO   
   $RS     DW  XR0     ;+8              ; RO стек возвратов
           DW  XTIB    ;+10             ; входной буфер
           DW  1Fh     ;+12             ; WIDTH 31 буква
           DW  0       ;+14             ; WARNING
           DW  XDP     ;+16             ; словарь FENCE (забор)
           DW  XDP     ;+18             ; DP
           DW  XVOC    ;+20             ; словарь VOCL в слове Forth
   $BUF    DW  DSKBUF  ;+22             ; экранный буфер FIRST
           DW  ENDBUF  ;+24 или 30Q     ; LIMIT

   ASSUME  CS:ARRAY, DS:ARRAY, ES:ARRAY, SS:STCK


   $INI      PROC    FAR
             JMP  ENT
   ; ** PRIMITIVES **
  
             HEAD    83h,'IN',311Q,INIT                  ;INI
   ENT:      MOV   CX, ARRAY
             MOV   DS, CX          ; Установка DX
             MOV   ES, CX
             MOV   AX, $STI        ; Восстановление словаря (PFA слова TASK)
             LEA   SI, FORTH+6     ; Адрес места нахождения в PFA forth
             MOV   [SI], AX        ; 
             MOV   SI, $BUF
             MOV   CX, 1739        ; Установка счетчика 1730
   XXX:      MOV   WORD PTR [SI],0 ; Обнуление массивов
             ADD   SI, 2
             LOOP  XXX

   ; INIT 'OFFSET, USE, PREV
             MOV   BX, $US          ; xup
             MOV   CX, $BUF         ; TO 'USE'
             MOV   [BX]+72Q,CX      ; USE ? адрес блока
             MOV   [BX]+74Q,CX      ; PREV ? адрес блока
             MOV   word ptr [BX]+102Q,00h      ; отладка выключена
             MOV   CX, 10           ; Установка счетчика USER (14Q надо на 2 меньше уже)
             MOV   DI, $US          ; Запись адреса области USER
             ADD   DI, 6            ; почему 6.... ? User переменные начинаются с 6 адреса
             LEA   SI, $STK         ; Запись начального адреса
             ; заполняем начальные значения переменых
   REP       MOVS  WORD PTR ES:[DI], WORD PTR DS:[SI] 
             MOV   BP, $RS          ; Установка начального значения
                                    ; указателя стека возвратов
                                    ; пересекается с областью TIB
                                    ; RS растет в область с меньшими адресами
             MOV   DI, $US
             MOV   WORD PTR [DI+32Q],7  ; Установка цвета вывода текста
             MOV   WORD PTR [DI+42Q],0  ; Сброс флага печати
             LEA   SI, GO$
             NEXT
             ; здесь инструкции языка форт. указатель на них в SI
   GO$:      DW SPSTO,DECIMA,FORTH,DEFIN, ONE,LOA, quit; загрузка первого экрана
$INI      ENDP

include debug.asm

   ; BX - WP находится адрес исполняемого слова 
   ; SI - IP-регистр    должен сохраняться
   ; DI - указатель области USER
   ; BP - указатель стека возвратов
   ; SP - указатель стека параметров

             HEAD    87h,'EXECUT',305Q,EXEC              ; 
    ; в стеке адрес поля CFA (НЕ PFA)
             POP   BX
             JMP  WORD PTR [ BX ]

             HEAD    83h,'LI',324Q,LIT                   ; LIT
             LODSW
             PUSH  AX
             NEXT

             HEAD    86h,'TERMO',316Q,TERMON             ; TERMON
    ; NumLock, ScrollLock, CapsLock, Ins. Состояние этих клавиш записывается
    ; в область данных BIOS в два байта с адресами 0000h:0417h и 0000h:0418h
             POP   AX
             PUSH  ES
             MOV   CX, 0
             MOV   ES, CX
             MOV   ES:417H,AX
             POP   ES
             NEXT

             HEAD    87h,'?BRANC',310Q,ZBRAN             ; ?BRANCH
    ; переход, если 0 в стеке (FALSE)
             POP   AX
             CMP   AX, 0
             JE    CNT
             ADD   SI, 2 ; без перехода пропускаем следующее слово (адрес перехода)
             NEXT

             HEAD    86h,'BRANC',310Q,BRAN               ; BRANCH
    ; безусловный переход. SI указывает на число инструкций,
    ; которые нужно пропустить
   CNT:      ADD   SI,  [SI]  ; si содержит число инструкций,
                            ; которые необходимо пропустить
             NEXT

             HEAD    84h,'(DO',251Q,XDO                  ; (DO)
             POP   AX  ; в стек данных начальное значение цикла
             SUB   BP, 2
             POP   [BP] ; конечное значение цикла
             SUB   BP, 2
             MOV   WORD PTR  [BP],AX ; в стек возвратов начальное значение цикла
            ; RS растет в сторону с меньшими адресами 
            ; BP  до входа в слово. 
            ; BP-2 - конечное значение цикла
            ; BP-4 - начальное значение 
             NEXT

             HEAD    86h,'(LOOP',251Q,XLOOP              ; (LOOP)
   ; Приращение индекса цикла LOOP и может быть  ветвление
             INC   WORD PTR  [BP] ; начальное значение увеличиваем
   LOP:      MOV   AX,  [BP]    ; индекс
             CMP   AX,  [BP+2]  ; предел цикла
             JL    CNT
   LV:       ADD   BP,  4 ; удаляем параметры цикла
             ADD   SI,  2 ; переход к следующеу слову
             NEXT

             HEAD    87h,'(+LOOP',251Q,XPLOO             ; (+LOOP)
    ; n  ---   
             POP   AX
             ADD   [BP],   AX
             CMP   AX, 0
             JL    $LESS
             JMP   LOP
     $LESS:  MOV   CX, [BP]   ; Работа с отрицательными приращениями
             CMP   [BP]+2, CX
             JLE   LV
             JMP   CNT

             HEAD    86h,'(FIND',251Q,PFIND              ; PFIND
        ;  addr1 addr2 --- pfa b tf (ok) оператор поиска 
   ; Адрес строки  NFA => PFA длина TRUE/FALSE (!реально СFA !)
             POP   AX       ; NFA последнего слова в context словаре
             POP   CX       ; addr1 строка для поиска. первый байт длина образца
             PUSH  BP       ; сохранение содержимого регистров
             PUSH  SI       ; --
             PUSH  DI       ; --
             MOV   SI, CX   ; адрес образца
             SUB   BP, BP   ; 
             MOV   DI, AX   ; NFA  последнего слова в словаре
             MOV   DX,WORD PTR [SI] ; длина строки поиска и первый символ
             AND   DX, 77577Q ; 7F7f - сброс старших битов. кажется лишним
             CLD                    ; DF=0 (вперед)
   FAST:     MOV   CX,WORD PTR [DI] ; 
             AND   CX, 77477Q ; сброс 7-ых и 6 бита в первом байте
             CMP   DX, CX   ; сравним длину и первый символ
             JE    SLOW     ; если равны, может то, что ищем
   MATCH:    CMP   WORD PTR [DI], 0 ; ищем конец nfa 
             JS    $SIG         ; BPL 
             INC   DI           ; следующий символ в слове
             JMP   MATCH
   $SIG:     ADD   DI, 2        ; переход к полю LFA
             CMP   WORD PTR [DI],0  ; список слов закончился
             JE    FAIL             ; LFA =0, поиск не удачен
             MOV   DI,WORD PTR [DI] ; переход к другому слову в словаре
             JMP   FAST
   SLOW:     MOV   BP,WORD PTR [DI] ; длина и первый символ найденого слова
             MOV   BX, SI           ; адрес образца
             JMP   SLOW1            
   $LOOP:    INC   BX               ; перебор символов
             MOV   AX,WORD PTR [BX]
             MOV   CX,WORD PTR [DI]
             AND   CX, 77777Q   ; 7FFFh
             CMP   AX, CX
             JNE   MATCH        ; не совпало, переход на начало
   SLOW1:    INC   DI           
             TEST  WORD PTR -1[DI],100000Q ; 8000h
             JZ    $LOOP        ; переход, если 7 бит РАВЕН 0
             MOV   DX, BP       ; длина слова
             ADD   DI, 5        ; PFA найденого слова
             MOV   AX, DI       
             POP   DI           ; восстановление содержимого регистров
             POP   SI
             POP   BP   
             SUB   AX, 2        ; CFA 
             PUSH  AX
             AND   DX, 377Q        ; FFh выделяем байт длины и ФЛАГОВ
             PUSH  DX              ; в стек
             JMP   TRUE            ; Установка флага "Найдено"   
   FAIL:     POP   DI
             POP   SI
             POP   BP
             JMP   FALSE

             HEAD    85h,'DIGI',324Q,DIGIT               ; DIGIT
   ; ASCII-DIGIT BASE=>DIGIT-VALUE TRUE (FALSE)
             POP   AX      ; AX=BASE
             POP   CX
             SUB   CX, 60Q ; VALID DIGIT = ASCII-60
             JL    FALSE
             CMP   CX, 9   ; Если >9
             JLE   M09
             SUB   CX, 7
             CMP   CX, 10
             JL    FALSE
   M09:      CMP   CX, AX  ; Если не меньше BASE, то ошибка
             JGE   FALSE
             PUSH  CX      ; Запись цифры в стек
             JMP   TRUE    ; "Успешный" выход

   ;         **  Стандартные слова  **
   ;         **  Условные операторы  **

             HEAD    82h,'0',275Q,ZEQU                   ; 0=
             POP   AX
             CMP   AX,  0
             JE    TRUE
   FALSE:    SUB   AX,  AX
   PUT:      PUSH  AX
             NEXT
   TRUE:     MOV   AX,  1
             JMP   PUT

             HEAD    83h,'0<','>'+80h,NZEQ               ; 0<>
             POP   AX
             CMP   AX,  0
             JNE    TRUE
             JMP FALSE

             HEAD    82h,'0',276Q,ZGRET                  ; 0>
             POP   AX
             CMP   AX, 0
             JG    TRUE
             JMP   FALSE

             HEAD    83h,'0=',276Q,ZEQGR                  ; 0=>
             POP   AX
             CMP   AX, 0
             JGE    TRUE
             JMP   FALSE

             HEAD    82h,'0',274Q,ZLESS                  ; 0<
             POP   AX
             CMP   AX, 0
             JS    TRUE         ; Если минус
             JMP   FALSE

             HEAD    83h,'0=',274Q,ZEQLES                ; 0=<
             POP   AX
             CMP   AX, 0
             JS   TRUE         ; Если минус
             JE   TRUE          ; или ноль
             JMP   FALSE

             HEAD    81h,,275Q,EQUAL                     ; =
             POP   AX
             POP   CX
             CMP   CX, AX
             JE    TRUE
             JMP   FALSE

             HEAD    82h,'<','>'+80h,NEQ                  ; <>
             POP   AX
             POP   CX
             CMP   CX, AX
             JE    FALSE1
             JMP   TRUE1

             HEAD    82h,'U',274Q,ULESS                  ; U<
             POP   AX
             POP   CX
             CMP   CX, AX
             JB    TRUE1           ; для чисел без знака
             JMP   FALSE1

             HEAD    81h,,274Q,LESS                      ; <
             POP   AX
             POP   CX
             CMP   AX, CX
             JG    TRUE1
             JMP   FALSE1

             HEAD    82h,'=',274Q,EQLES                  ; =<
             POP   AX
             POP   CX
             CMP   AX, CX
             JGE    TRUE1
             JMP   FALSE1

             HEAD    81h,,276Q,GREAT                     ; >
             POP   AX
             POP   CX
             CMP   AX, CX
	         JL    TRUE1
             JMP   FALSE1

             HEAD    82h,'=',276Q,EQGR                     ; =>
             POP   AX
             POP   CX
             CMP   AX, CX
	         JLE    TRUE1
             JMP   FALSE1

            HEAD     84h,'EVE', 'N'+80h, $EVEN           ; EVEN
    ; проверка на четность
            pop ax 
            test ax, 1 ; проверяем младший бит
            jz true1 ; если бит=0, то число четное            
    FALSE1: SUB   AX,  AX
    PUT1:   PUSH  AX
            NEXT
    TRUE1:  MOV   AX,  1
            JMP   PUT1

   ;         ******************

             HEAD    84h,'ENC',314Q,ENCL                 ; ENCLOSE
    ; addr1 c -- addr1 n1 n2 n3
             POP   AX         ; разделитель
             POP   CX         ; начальный адрес
             MOV   BX, CX
   A:        CMP   BYTE PTR  [BX], AL ; обход разделителей в начале
             JNE   NOTEQ
   AAA1:     INC   BX
             JMP   A
   NOTEQ:    CMP   BYTE PTR  [BX], 15Q ; обход перевода строки
             JE    AAA1
             CMP   BYTE PTR  [BX], 12Q
             JE    AAA1                 ; обход перевода строки
             MOV   DX, BX               ; начало лексемы
             PUSH  DX
   AA:       CMP   BYTE PTR  [BX],  0
             JE    ZZZ                  ; если нуль
             CMP   BYTE PTR  [BX], AL   ; не нуль, ищем конец лексемы
             JE    EQW
             INC   BX
             JMP   AA
   EQW:      MOV   AX, BX
             SUB   BX, DX
             PUSH  BX
             SUB   AX, CX
             INC   AX
             PUSH  AX
             NEXT               ; выход из слова

   ZZZ:      CMP   BX, DX
             JNE   EQW
             INC   BX
             JMP   EQW

    ;         ** Дисплей **

             HEAD    84h,'PAG',305Q,$PAGE                ; PAGE
    ; Установка активной страницы ( PAGE --)
             POP   AX
    ; вход:  AL = номер страницы (большинство программ использует страницу 0)             
             MOV   AH, 5
             INT   10h
             NEXT

            HEAD    85h,'PIX1','3'+80h,PIX13             ; pixel 13h mode
        ; color y x ->     
            pop bx
            pop ax
            mov dx, 320
            mul dx
            add ax, bx
            mov bx, 0a000h
            pop cx
            push es
            mov es, bx
            mov bx, ax
            mov es:[bx], cl
            pop es
            NEXT 

            HEAD    85h,'PIX1','2'+80h,PIX12             ; pixel 12h mode
        ; color y x ->     
        ; ax - row
        ; bx - column
        ; ch - color
            pop bx
            pop ax
            pop cx
            mov ch, cl
            push es
            call pixptr12 
            mov dx, 3ceh

            shl ah, cl
            mov al, 8
            out dx, ax
            
            mov ax, 205h
            out dx, ax

            mov ax, 3
            out dx, ax    

            mov al, es:[bx]
            mov es:[bx], ch

            mov ax, 0ff08h
            out dx, ax
            mov ax, 5
            out dx,ax
            mov ah, 3
            out dx, ax
            pop es
            NEXT

            pixptr12 proc
    ; ax-row 
    ; bx-column
    ; returns
    ; es:bx -> pixel
    ; cl - bit position
    ; ah - bitmask 
            push dx
            mov cl, bl
            mov dx, 80
            mul dx
            shr bx, 3
            add bx, ax
            mov ax, 0a000h
            mov es, ax
            and cl, 7
            xor cl, 7
            mov ah, 1
            pop dx
            ret
            pixptr12 endp

             HEAD    83h,'PI',330Q,PIX                   ; PIX
    ; COLCOD ROW COLUMN -->  -    запись графической точки             
             POP   CX                  ; колонка x?
             POP   DX                  ; строка y?
             POP   AX                  ; код цветности
             ;PUSH  DX                  ; сохранение DX             
             ;MOV   DX, BX              ; BH = номер видео страницы ??? где
             ;SUB   DH, DH              ; ошибка в коде
             push   ax             
             MOV   AH, 0Fh             ; Чтение текущей страницы
             INT   10h                 ; в BH
             pop    ax                 ; код цветности
             MOV   AH, 0Ch             ; 
             INT   10h                 ; запись графической точки
             ;POP   DX                  ; восстановление DX
             NEXT

             HEAD    84h,'MOD','A'+80h,MODA                 ; MODA
    ; установка режима. ( М --> - )
             POP   AX
             SUB   AH, AH       ; 00H уст. видео режим. Очистить экран
                                ;  установить поля BIOS, установить режим.
             INT    10h
             NEXT

             HEAD    83h,'EM',311Q,EMI$                  ; EMI
             POP   CX              ; Число символов
             POP   AX              ; Символ
             PUSH  CX              ; Сохранение содержимого CX
             PUSH  AX              ; Сохранение содержимого AХ
             MOV   BX, [DI+32Q]    ; Установка атрибута
             MOV   AH, 0Fh         ; Чтение текущей страницы
             INT   10h             ; в BH
             POP   AX              ; Восстановление содержимого AX
             MOV   AH, 9           ; Запись строки символов
             INT   10h
             MOV   AH, 3           ; Чтение положения курсора
             INT   10h
             POP   CX
             ADD   DL, CL          ; DH,DL = строка, колонка (считая от 0)
             MOV   AH, 2           ; Установка положения курсора
   $EM:      INT   10h
             CMP   WORD PTR [DI+42Q], 0  ; сброс флага печати
             JNE   PRINT
   OK:       NEXT

             HEAD    84h,'EMI',324Q,EMIT,$EMIT           ; EMIT
    ; вывод текста без атрибутов (по умолчанию)             
   $EMIT     LABEL   FAR
             POP   AX
   ENT$:     PUSH  AX
             MOV   AH, 15       ; Чтение текущей страницы
             INT   10h
             POP   AX
             MOV   AH, 14       ;
             JMP   $EM

   PRINT:    MOV   DX, 0   ; Установка номера принтера
             SUB   AH, AH
             INT   17h
             TEST   AH, 29h
             JE    OK
   ERR4:     MOV   AL, AH
             ADD   AL, 60Q
             MOV   AH, 14
             INT   10h
             MOV   DX, OFFSET ERMES4
             MOV   AH, 9H
             INT   21H
             JMP   TYPE$
   ERMES4    DB   " PRINTER ERROR $" ; 

             HEAD    82h,'R',303Q,RC               ; RC
             MOV   AX, 13
             JMP   ENT$

             HEAD    82h,'I',314Q,IL               ; BELL
             MOV   AX, 7
             JMP   ENT$

             HEAD    84h,'PRI',316Q,PRIN           ; PRINT-FLAG
             INC   WORD PTR  [DI+42Q]
             MOV   DX,  0       ; Установка номера принтера
             MOV   AH,  1       ; Инициализация принтера
             INT   17H
             TEST  AH,  29h
             JNE   ERR4
             NEXT

             HEAD    83h,'TT',331Q,TTY              ; TERMI-FLAG
   TYPE$:    MOV   WORD PTR [DI+42Q],0
             NEXT

             HEAD    83h,'SC',314Q,SCL                   ; SCL
   ; SCREEN CLEAR
             ;MOV   CX, 2048     ; Загрузка счетчика
             ;MOV   AH, 15
             ;INT   10h           ; Установка текущей страницы
             mov   dx, 1855h      ;  DH,DL = строка, колонка (считая от 0)
             sub   cx, cx
             ;MOV   AH, 2        ; Курсор в исходное положение
             ;INT   10h
             mov   bh, 0       ; атрибут
    ; 09H писать символ/атрибут в текущей позиции курсора
   CLEAR:    MOV   AX, 0600H    ; число пустых строк, вдвигаемых снизу (0=очистить все окно)
             INT   10h
             NEXT

             HEAD    83h,'FI',330Q,FIX                   ; FIX
   ; Позиционирование курсора: COL ROW FIX
             MOV   AH, 0Fh
             INT   10h      ; Запись текущего номера страницы в BX
             POP   DX
             MOV   DH, DL   ; строка
             POP   AX

             MOV   DL, AL   ; столбец
             MOV   AH, 2    ; уст. позицию курсора. установка
                            ; на строку 25 делает курсор невидимым.
             INT   10h      ; Фиксация положения курсора
             NEXT

             HEAD    84h,'DSP',314Q,DSPL                 ; DSPL
   ; LOAD GRAFBUFFER (b adr DSPL)
    ; записывает байт в графическую память
             POP   BX  ; адрес
             POP   AX  ; байт
             PUSH  ES  ; сохранение регистра сегмента
             MOV   CX, 0B000H ; GRAFBUF
             MOV   ES, CX
             MOV   BYTE PTR ES:[BX], AL
             POP   ES
             NEXT

   ;         ** Терминал **

             HEAD    83h,'KE',331Q,KEY                   ; KEY
        ; читать (ожидать) следующую нажатую клавишу
        ; выход: AL = ASCII символ (если AL=0, AH содержит расширенный код ASCII )
        ; AH = сканкод  или расширенный код ASCII
             SUB   AH, AH
             INT   16h
             SUB   AH, AH
             PUSH  AX
             NEXT

             HEAD    86h,'EXPEC',324Q,EXPE               ; EXPECT
        ; adr count -> 
             MOV   AH, 0AH              ;  ввод строки в буфер
             POP   CX                   ; Число символов
             POP   BX                   ; Адрес буфера SS
             MOV   BYTE PTR [BX],  CL   ; Засылка ожидаемого числа
             MOV   DX, BX
             INT   21h

             MOV   AL, BYTE PTR [BX+1]  ; фактически введено символов
             SUB   AH, AH               ; 
             ADD   BX, AX               ; адрес конца строки
             MOV   WORD PTR [BX+2],0    ; +2, т.к. в начале строки мах длина 
                                        ; и число введенных символов
             NEXT

             HEAD    85h,'?TER',244Q,?TER$               ; ?TER$
             PUSH  ES
             SUB   CX, CX
             MOV   ES, CX
             OR    BYTE PTR ES:[417H],  40Q
   TER:      MOV   AH, 1    ; проверить готовность символа (и показать его, если так)
                            ; выход: ZF = 1 если символ не готов.
                            ; ZF = 0 если символ готов.
                            ; AX = как для подфункции 00H (но символ здесь не
                            ; удаляется из очереди).
             INT   16h
             JZ    TER
             SUB   AH, AH   ; читать (ожидать) следующую нажатую клавишу
             INT   16h
             AND   BYTE PTR ES:[417H],337Q  ; Сброс 'NUM LOCK'
             POP   ES              ; Восстановление ES
             PUSH  AX              ; Запись символа
             NEXT

   ; ** Ввод/Вывод **

             HEAD    84h,'POR',324Q,PORT                 ; PORT
             POP   DX
             POP   AX
             OUT   DX, AL
             NEXT

             HEAD    84h,'REA',304Q,READ                 ; READ
             POP   DX
             IN    AL, DX
             SUB   AH, AH
             PUSH  AX
             NEXT

   ;         ** Арифметика **

             HEAD    82h,'1',253Q,ONEP                   ; 1+
             POP   AX
             INC   AX
             PUSH  AX
             NEXT

             HEAD    82h,'2',253Q,TWOP                   ; 2+
             POP   AX
             ADD   AX, 2
             PUSH  AX
             NEXT

             HEAD    82h,'1',255Q,ONEM                   ; 1-
             POP   AX
             DEC   AX
             PUSH  AX
             NEXT

             HEAD    82h,'2',252Q,MUL2                   ; 2*
             POP   AX
             SAL   AX,  1
             PUSH  AX
             NEXT

             HEAD    82h,'2',257Q,DIV2                   ; 2/
             POP   AX
             SAR   AX, 1
             PUSH  AX
             NEXT

             HEAD    82h, 'U', 252Q,USTAR                ; U*
    ; u1  u2  ---  ud 
             POP   AX
             POP   CX
             MUL   CX
             PUSH  AX
             PUSH  DX
             NEXT

             HEAD    82h,'U',257Q,USLAS                  ; U/
    ; ud u1 --- u2 u3 
             POP   CX          ; Делитель
             POP   DX
             POP   AX
             DIV   CX
             PUSH  DX          ; Остаток
             PUSH  AX          ; Засылка  результата
             NEXT

             HEAD    82h,'M',252Q,MSTAR                  ; M*
             POP   AX
             POP   CX
             IMUL  CX
             PUSH  AX
             PUSH  DX
             NEXT

             HEAD     86h,'DMINU',323Q,DMINU             ; DMINUS
   ; Изменение знака числа двойной длины
             POP  AX
   DMIN:     NEG  AX
             POP  CX
             NEG  CX
             SBB  AX, 0       ; sub with borrow
             PUSH CX
             PUSH AX
   G$:       NEXT

            HEAD     84h,'DAB',323Q,DABS                 ; DABS
            POP   AX
            CMP   AX, 0
            JS    DMIN
            PUSH  AX
            NEXT

            HEAD     82h,'M',257Q,MSLAS                  ; M/
            POP   CX          ; Делимое
            POP   DX
            POP   AX
            IDIV  CX
            PUSH  DX
            PUSH  AX
            NEXT

            HEAD     81h,,253Q,PLUS                      ; +
            POP  AX
            POP  CX
            ADD  AX, CX
            PUSH AX
            NEXT

            HEAD     81h,,255Q,SUBB                       ; -
    ; n1 n2 -> n1-n2
            POP  CX
            POP  AX
            SUB  AX, CX
            PUSH AX
            NEXT

            HEAD     82h,'D',253Q,DPLUS                  ; D+
            POP  AX
            POP  CX
            MOV  BX, SP
            ADD  SS:[BX+2],  CX
            ADC  SS:[BX],    AX
            NEXT

            HEAD     82h,'M',253Q,MPLUS                  ; M+
            POP  CX
            MOV  BX, SP
            ADD  SS:[BX+2],  CX
            ADC  word ptr SS:[BX],    0
            NEXT

            HEAD     85h,'MINU',323Q,MINUS               ; MINUS
            POP  AX
            NEG  AX
            PUSH AX
            NEXT

            HEAD     84h,'SWA',302Q,SWAB                 ; SWAB
        ; обмен байтами слова в стеке
            POP  AX
            XCHG AL, AH
            PUSH AX
            NEXT

            HEAD     83h,'AB',323Q,$ABS                   ; ABS
            POP  AX
            CMP  AX, 0
            JNS  AB
            NEG  AX
   AB:      PUSH AX
            NEXT

            HEAD     83h,'AN',304Q,$AND                  ; AND
            POP  AX
            POP  CX
            AND  AX,  CX
   ENDA:    PUSH AX
            NEXT

            HEAD     82h,'O',322Q,$OR                    ; OR
            POP  AX
            POP  CX
            OR   AX, CX
            JMP  ENDA

            HEAD     83h,'XO',322Q,$XOR                  ; XOR
            POP  AX
            POP  CX
            XOR  AX, CX
            JMP  ENDA

            HEAD2     84h,<S->,304Q,STOD                 ; S->D ; sds S->
            POP  AX
            PUSH AX
            MOV  CX, DX           ; Сохранение содержимого DX
            CWD                   ; sign bit AX to DX
            PUSH  DX
            MOV  DX, CX           ; Восстановление DX
            NEXT

            HEAD     83h,'MI',316Q,MIN                   ; MIN
            POP  AX
            POP  CX
            CMP  CX,  AX
            JL  DEEP            ;
   TOP:     PUSH AX
            NEXT
   DEEP:    PUSH CX
            NEXT

            HEAD     83h,'MA',330Q,MAX                   ; MAX
            POP  AX
            POP  CX
            CMP  CX, AX
            JGE  DEEP
            JMP  TOP

            HEAD     83h,'SP',300Q,SPAT                  ; SP@
        ; значение текущего указателя регистра SP в стек
            MOV  AX, SP
            JMP  ENDA

            HEAD     83h,'SP',241Q,SPSTO                 ; SP!
            MOV  SP, [DI+6]                             ; 80h
            NEXT

            HEAD     83h,'RP',241Q,RPSTO                 ; RP!
            MOV  BP, $RS                                ; ccch
            NEXT

            HEAD     82h,';',323Q,SEMI                   ; ;S
        ; переход на слово по адресу в стеке возврата СЛОЖНО
        ; слово,которым заканчивается слова на форте
            MOV  SI, [BP] ; в RS хранится адрес следующего слова, 
                        ; до перехода на исполнение слова, которое завершается
            ADD  BP, 2 ; удаляем из RS
            NEXT ;  возврат на предыдущее слово

   ;        ** Стек возвратов **

            HEAD     85h, 'LEAV',305Q,LEAV                ; LEAVE
        ; надо смотреть дальше с хранением адресов 
        ; приравнивает значения индекса и предела     
	        MOV  AX, [BP]
            MOV  [BP+2], AX 
            NEXT

            HEAD     82h, 62,322Q,TOR                    ; >R sds
<<<<<<< HEAD
        ; пишем в стек возвратов
        ; слово из стека данных
            SUB  BP, 2 ; заняли ячейку 
            POP  [BP]   ; записали значение 
=======
        ; ��襬 � �⥪ �����⮢ ᫮�� �� �⥪� ������
            SUB  BP, 2 ; ���﫨 �祩�� 
            POP  [BP]   ; ����ᠫ� ���祭�� 
>>>>>>> 51f9fa2cf38b0a7ffc15f2cb0844f4e6edec42d6
            NEXT

	        HEAD     82h, 'R',276Q,FROMR                  ; R>
        ; в стек данных слово по адресу из стека возвратов
	        PUSH [BP] ; в стек записали
            ADD  BP, 2 ; убрали 
            NEXT

            HEAD     81h,,311Q,I                         ; I R R@
        ; Копирует верхнее число из стека возвратов
        ; и записывая в стек параметров
  RR$:      PUSH [BP]
  Z$:       NEXT

            HEAD     81h,,322Q,R                         ; R
            JMP  RR$

            HEAD     82h,'I',247Q,SRP                    ; I'
        ; Копирует второе сверху число из стека возвратов 
        ; и записывает его в стек параметров
            PUSH [BP+2]
            JMP  Z$

        HEAD     81h,,'J'+80h,J                    ; J
        ; Копирует третье сверху число из стека возвратов 
        ; и записывает его в стек параметров
            PUSH [BP+4]
            JMP  Z$
        
        HEAD     82h,'J',247Q,JT                    ; J'
        ; Копирует четвертое сверху число из стека возвратов 
        ; и записывает его в стек параметров
            PUSH [BP+6]
            JMP  Z$

        HEAD     81h,,'K'+80h,K                    ; K
        ; Копирует пятое сверху число из стека возвратов 
        ; и записывает его в стек параметров
            PUSH [BP+8]
            JMP  Z$        

        HEAD     82h,'K',247Q,KT                    ; K'
        ; Копирует шестое сверху число из стека возвратов 
        ; и записывает его в стек параметров
            PUSH [BP+10]
            JMP  Z$

            HEAD     83h,'LE',326Q,LEV                   ; LEV
        ; эквивалент R> DROP :) только быстрее
        ; для выхода из interpret
            ADD  BP, 2
            NEXT

            ;** Операции со стеком параметров **

            HEAD     84h,'PIC',313Q,PICK                 ; PICK
            POP  BX
            CMP  BX,  0
            JLE  $GO
            DEC  BX
            SAL  BX, 1
            ADD  BX, SP
            PUSH SS:[BX]
   $GO:     NEXT

            HEAD     84h,'OVE',322Q,OVER                 ; OVER
            MOV  BX, SP
	        PUSH SS:[BX+2]
            NEXT
            
            HEAD     84h,'SWA',320Q,SWAP                 ; SWAP
            POP  CX
            POP  AX
            PUSH CX
            PUSH AX
            NEXT

            HEAD     85h,'2SWA',320Q,DSWAP               ; 2SWAP
            POP  AX
            POP  CX
            MOV  BX,  SP
            MOV  DX,WORD PTR SS:[BX+2]
            PUSH DX
            MOV  DX,WORD PTR SS:[BX]
            PUSH DX
            MOV  WORD  PTR SS:[BX],AX
            MOV  WORD  PTR SS:[BX+2],CX
            NEXT

            HEAD     83h,'DU',320Q,DUBL                  ; DUP
            POP  AX
   DU:      PUSH AX
   C$:      PUSH AX
            NEXT

            HEAD     84h,'-DU',320Q,DDUP                 ; -DUP
        ; DUP если в стеке не 0
            POP  AX
            CMP  AX,  0
            JNE  DU
            JMP  C$

            HEAD     84h,'2DU',320Q,DUP2                 ; 2DUP
            POP  AX
            POP  CX
            PUSH CX
            PUSH AX
            PUSH CX
            PUSH AX
            NEXT

            HEAD     83h,'RO',324Q,ROT                   ; ROT
            POP  AX
            POP  CX
            POP  BX
            PUSH CX
            PUSH AX
            PUSH BX
            NEXT

            HEAD     84h,'-RO',324Q,MROT                   ; -ROT
            POP  AX
            POP  CX
            POP  BX
            PUSH AX
            PUSH BX
            PUSH CX
            NEXT

            HEAD     85h,'4DRO',320Q,QDROP               ; 4DROP
            ADD  SP, 6
            NEXT

            HEAD     85h,'2DRO',320Q,DDROP               ; 2DROP
   DRO:     ADD  SP, 4
            NEXT

            HEAD     84h,'DRO',320Q,DROP                 ; DROP
   DRP:     ADD  SP, 2
            NEXT

            HEAD     83h,'NI','P'+80h,NIP                ; NIP
            POP  BX
            POP  AX
            PUSH BX
            NEXT

   ;        ** Работа с памятью **

            HEAD     85h,'CMOV',305Q,CMOV               ; CMOVE
        ; src dst cnt -> перенос области памяти
            POP  CX         ; Счетчик
            CMP  CX,  0
            JLE  DRO        ; выход, c сбросом двух параметров в стеке
            MOV  AX,  DI     ; Сохранение содержимого DI,SI
            MOV  BX,  SI
            POP  DI          ; Куда
            POP  SI          ; Откуда
   REP      MOVS  BYTE PTR ES:[DI], BYTE PTR DS:[SI]
            MOV  DI, AX      ; Восстановление DI,SI
            MOV  SI, BX
            NEXT

            HEAD     84h,'FIL',314Q,FILL                 ; FILL
    ; addr cnt chr -> заполнение области памяти
            POP  AX      ; Символ
   FLL:     POP  CX      ; Счетчик символов
            CMP  CX, 0
            JLE  DRP     ;
            POP  BX   
   $REPE:   MOV  BYTE PTR [BX],  AL
            INC  BX
            LOOP $REPE
            NEXT

            HEAD     85h,'ERAS',305Q,ERASE               ; ERASE
        ; заполнение нулем
            SUB  AX, AX
            JMP  FLL

            HEAD     86h,'BLANK',323Q,BLANK              ; BLANKS
        ; заполнение  пробелом
            MOV  AX, 32
            JMP  FLL

            HEAD     84h,'HOL',304Q,HOLD                 ; HOLD
        ; Вводит в текущую ячейку выходного буфера символ,
        ; код которого в стеке. Должен использоваться между <# и #>
        ; уменьшает на 1 значение указателя HLD.
            DEC  WORD PTR  [DI+70Q]
            POP  AX
            MOV  BX,  [DI+70Q]
            MOV  BYTE PTR [BX], AL
            NEXT

            HEAD     82h,'+',241Q,PSTOR                  ; +!
            POP  BX
            POP  CX
            ADD  [BX], CX
            NEXT

            HEAD     82h,'-',241Q,MSTOR                  ; +!
            POP  BX
            POP  CX
            SUB  [BX], CX
            NEXT

            HEAD     84h,'TOG',314Q,TOGL                 ; TOGGLE
   ; адр-байта маска -> XOR в байт памяти
            POP  CX         ; Маска
            POP  BX
            XOR  BYTE PTR [BX],CL
            NEXT

            HEAD     81h,,300Q,AT                        ; @
        ; addr -> n    
            POP  BX
            PUSH [BX]
            NEXT

            HEAD     82h,'A',300Q,AAT                    ; a@
        ; ( Offset Segment --> Value )
            pop  ax
            pop  bx
            push es
            mov  es, ax
            mov  ax, es:[bx]
            pop  es
            push ax            
            NEXT

            HEAD     82h,'C',300Q,CAT                    ; c@
        ; Извлекает байт информации из ячейки, 
        ; адрес которой находится в стеке
            POP  BX
            MOV  AL, BYTE PTR [BX]
            SUB  AH, AH
            PUSH AX
            NEXT

            HEAD     81h,,241Q,STORE                     ; !
        ; n addr ->
            POP  BX  
            POP  AX
            MOV  [BX],   AX
            NEXT

            HEAD     82h,'C',241Q,CSTOR                 ; C!
            POP  BX
            POP  AX
            MOV  BYTE PTR [BX],  AL
            NEXT

            HEAD     83h,'NF','A'+80h,NFA               ; NFA
    ; pfa -> nfa
            POP  BX
            SUB  BX, 5
            MOV  CX, -1

            JMP  TRV

            HEAD     83h,'LF','A'+80h,LFA               ; LFA
            POP  AX
            SUB  AX, 4
            PUSH AX
            NEXT

            HEAD     83h,'CF','A'+80h,CFA               ; CFA
    ; PFA -> CFA
            POP  AX
            SUB  AX, 2
            PUSH AX
            NEXT

            HEAD     84h,'!CS',320Q,SCSP                 ; !CSP
    ; контролируют сохранение указателя стека параметров 
    ; в процессе интерпретации слова
            MOV  WORD PTR [DI]+64Q,SP
            NEXT

            HEAD     84h,'HER',305Q,HERE                 ; HERE
            PUSH [DI+22Q]
            NEXT

            HEAD     85h,'ALLO',324Q,ALLOT               ; ALLOT
            POP  BX
            ADD  [DI+22Q],BX        ; 
            NEXT

            HEAD     84h,'TRA',326Q,TRAV                 ; TRAVERSE
            ; Движение вперед/назад вдоль имени переменной длины
            POP  CX     ; DELTA
            POP  BX     ; адрес строки
    TRV:    ADD  BX, CX
            CMP  BYTE PTR [BX],  0
            JNS  TRV    ; JUMP IF POSITIVE
            PUSH BX
            NEXT

            HEAD     301Q,,333Q,LBRAC                     ; [
            ; Прекращение компил., начало исполн. (обнуление STATE)
            MOV  WORD PTR [DI+54Q],0
            NEXT

            HEAD     301Q,,335Q,RBRAC                     ; ]
            MOV  WORD PTR [DI+54Q],300Q   ; Начало компиляции
            NEXT

            HEAD     83h,'HE',330Q,$HEX                  ; HEX
            MOV  WORD PTR [DI+56Q],16
            NEXT

            HEAD     87h,'DECIMA',314Q,DECIMA             ; DECIMAL
            MOV  WORD PTR [DI+56Q],10
            NEXT

            HEAD     85h,'OCTA',314Q,OCTAL               ; OCTAL
            MOV  WORD PTR [DI+56Q],  8
   Y$:      NEXT

            HEAD     86h,'LATES',324Q,LATES              ; LATEST
        ; в стек данных NFA  последнего определенного слова 
        ; в current словаре
            MOV  BX, [DI+52Q] 
            PUSH [BX]
            NEXT

            HEAD     86h,'-TRAI',314Q,DTRAI              ; -TRAIL
    ; адр n1 --> адр n2 Убирает пробелы в конце строки
            POP  CX
            POP  BX
            PUSH BX
            ADD  BX, CX
   COMPA:   DEC  BX
            CMP  BYTE PTR [BX],  32  ; BLANK ?
            JNE  NO
            LOOP COMPA
   NO:      PUSH CX
            NEXT

            HEAD     85h,'UPPE',322Q,UPPER               ; UPPER
            POP  CX                 ; число символов
            POP  BX                 ; строка
   $COMP:   CMP  BYTE PTR [BX],  61h ; a
            JL   OFLIM
            CMP  BYTE PTR [BX],  7Ah ; z
            JG   OFLIM
            AND  WORD PTR [BX], 177737Q ; FFDF
   OFLIM:   INC  BX
            LOOP $COMP
            NEXT

            HEAD     213Q,'DEFINITION',323Q,DEFIN      ; DEFINITIONS
    ; Контекстный словарь становится текущим, все последующие 
    ; описания связаны с этим словарем            
            MOV  AX, [DI+50Q]       ; context
            MOV  [DI+52Q],AX        ; current
            NEXT

            HEAD     84h,'+BU',306Q,PBUF                 ; +BUF
    ; 
            MOV  BX, SP         ; 
            ADD  SS:[BX],1028   ; адрес следующего буфера
            MOV  AX, SS:[BX]
            CMP  [DI+30Q],AX    ; LIMIT
            JNE  PB             ; уперлись в адрес лимита, значит буфер - последний
            MOV  CX, [DI+26Q]   ; FIRST
            MOV  SS:[BX],CX     ; переходим на первый буфер  
   PB:      PUSH SS:[BX]        ; полученный адрес буфера в стек
            MOV  CX, [DI+74Q]   ; prev
            SUB  SS:[BX-2],CX   ; стек растет вниз. BX-2 сейчас  вершина стека
                                ; если 0, значит адрес совпадает с адресом prev 
            NEXT

            HEAD     86h,'UPDAT',305Q,UPDAT              ; UPDATE
            MOV  BX, [DI+74Q]   ; prev buffer
            OR BX, BX           ; если 0, буфер пустой
            jz $upd
            OR  WORD PTR [BX],   100000Q  ; ставим бит
    $upd:   NEXT

            HEAD     81h,,330Q,X                         ; X
    ; сброс бита сохранения буфера
            POP  BX
            AND WORD PTR [BX],   77777Q   ;
            PUSH [BX]
            NEXT

   ;        ** Управляющие слова **

            HEAD     301Q,,272Q,COLON,$COL                ; :
        ; слово для создания новых слов из Форта
            DW QEXEC,SCSP,CURR,AT,CONT,STORE,CREAT
            DW RBRAC,PSCOD ; после этого слова SI указывает на следующий код,
                           ; адрес, которого попадет в CFA создаваемого слова
   $COL     LABEL   FAR ; код для исполнения слов на форте из этого исходника
                        ; функция интерпретатора
            ADD  BP, -2 ; резервируем место в стеке возвратов
            ADD  BX, 2  ; BX указывает на CFA здесь это $COL
                        ; BX+2 будет указывать на адрес QEXEC
            MOV  [BP], SI ; сохраняем текущий указатель IP
            MOV  SI, BX ; исполняем слово QEXEC
            NEXT

            HEAD     301Q,,273Q,SMI,$COL                  ; ;
        ; слово для завершения новых слов из Форта
            DW QCSP,COMP,SEMI,SMUG,LBRAC,SEMI

            HEAD     88h,'CONSTAN',324Q,CON,$COL         ; CONSTANT
            DW CREAT,SMUG,COMMA,PSCOD                    ;
   $CON     LABEL   FAR
            ADD  BX, 2 ; аналогично переменной
            PUSH [BX]  ; вместо адреса пишем значение по этому адресу PFA
            NEXT

            HEAD     88h, 'VARIABL',305Q,VAR,$COL        ; VARIABLE
            DW CON,PSCOD  ; ������ ���� ��砫쭮� ���祭�� ��६�����
   $VAR     LABEL   FAR
            ADD  BX, 2  ; BX указывает на CFA ($COL)
                        ; BX+2 пропускает поле CFA
            PUSH BX     ; в BX находится адрес переменной PFA ($VAR)
            NEXT

            HEAD     84h,'USE',322Q,USER, $COL           ; USER
            DW CON,PSCOD
   $USE     LABEL   FAR
            ADD  BX, 2
            MOV  AX, [BX] ; берем смещение из PFA
            ADD  AX, DI  ; вычисляем смещение
            PUSH AX ; полученный адрес в стек
            NEXT

            HEAD     85h,'DOES',276Q,DOES,$COL           ; DOES>
    ; запись в PFA адреса кода, который следует за DOES>.
    ; В CFA пишется адрес кода, следующего за PSCOD, т.е. $DOE
    ; при исполнении в стек помещается адрес PFA+2
    ;  управление передается по адресу PFA
            DW  FROMR,LATES,PFA,STORE,PSCOD
   $DOE     LABEL   FAR   ; здесь используется только в FORTH
            SUB  BP,  2   ; резервируем место в RS
            MOV  [BP], SI ; сохраняем SI адрес следующего слова
            ADD  BX, 2    ; BX+2 это PFA исполняемого слова (FORTH)
            MOV  SI, [BX] ; там лежит адрес слова DOVOC
            ADD  BX, 2    ; адрес параметра PFA+2 для DOVOC (120201Q)
            PUSH BX       ; в стек
            NEXT          ; исполняется слово DOVOC (по адресу PFA)   

            HEAD     83h,'BY','E'+80h,BYE                  ; BYE
            mov ah, 4ch
            int 21h

   ;        ** Константы **

            HEAD     81h,,260Q,ZERO,$CON                 ; 0
            DW 0

            HEAD     81h,,261Q,ONE,$CON                  ; 1
            DW 1

            HEAD     81h,,262Q,TWO,$CON                  ; 2
            DW 2

            HEAD     81h,,263Q,THREE,$CON                ; 3
            DW 3

            HEAD     81h,,270Q,EIGHT, $CON               ; 8
            DW 8

            HEAD     82h,'B',314Q,BLAN,$CON              ; BL
            DW 32

            HEAD     82h,'C',314Q,$CL,$CON               ; C/L
            DW 64   ;CHAR# PER LINE

            HEAD     82h,'1',313Q,BBUF,$CON              ; BBUF
            DW 1024 ; длина буфера 

            ;** USER-переменные **

            HEAD     82h,'S',260Q,SZERO,$USE             ; SO
            DW 6 ; Указатель начала стека параметров
 
            HEAD     82h,'R',260Q,RZERO,$USE             ; RO
            DW 8  ; Указатель начала стека возврата

            HEAD     83h, 'TI',302Q,TIB,$USE             ; TIB
            DW 12Q  ;Входной буфер терминала 10

            HEAD     85h,'WIDT',310Q,$WIDTH,$USE         ; WIDTH
            DW 14Q ; Определяет максимальную длину имени в словаре

            HEAD     87h,'WARNIN',307Q,$WARN,$USE        ; WARNING            
            DW 16Q  ;  при 0 только код ошибки выводится

            HEAD     85h,'FENC',305Q,FENCE,$USE          ; FENCE
            DW 20Q ; FENCE указывает верхний край базового словаря
            ; FENCE  (ограда) служит  для  защиты  базового словаря
            ; от стирания с помощью оператора FORGET,  указывает адрес,
            ; предшествующий первой  свободной  ячейке  в словаре сразу
            ; после загрузки системы Форт, т.е. при этом FENCE @ равно HERE-2

            HEAD     82h,'D',320Q,$DP,$USE               ; DP
            DW 22Q ; указывает на первую свободную ячейку словаря (DP @ = HERE)

            HEAD     84h,'VOC',314Q,VOCL,$USE            ; VOCL
            ; хранится адрес XVOC 
            DW 24Q ; переменная  связи контекстных словарей.

            HEAD     85h,'FIRS',324Q,FIRST,$USE          ; FIRST
            DW 26Q ; адрес первого байта экранных буферов

            HEAD     85h,'LIMI',324Q,LIMIT,$USE          ; LIMIT
            DW 30Q ; указатель конца экранных буферов и некоторые другие

            HEAD     83h,'AT',322Q,ATR,$USE              ; ATR
            DW 32Q          ;Атрибут

            HEAD     82h,'P',307Q,PG,$USE                ; PG
            DW 34Q          ; Текущая страница

            HEAD     83h,'BL',313Q,BLK,$USE              ; BLK
            DW 36Q ; 0  для  входного  буфера  и  номеру экрана
                   ; в противном  случае

            HEAD     82h,'I',316Q,$IN,$USE               ; IN
            DW 40Q ; внутренний   указатель   входного   буфера

            HEAD     83h,'PN',324Q,PNT,$USE              ; PNT
            DW 42Q          ;Флаг-печати

            HEAD     83h,'SC',322Q,SCR,$USE              ; SCR
            DW 44Q ; для хранения текущего значения номера экрана
                    ; только в list

            HEAD     86h,'OFFSE',324Q,OFSET,$USE        ; OFFSET
            DW 46Q ; Диагностические сообщения обычно размещаются
                ; на экранах 4 и 5. Если это не так, задачу можно решить,
                ; поменяв значение OFFSET или исправив число, стоящее
                ; перед OFFSET в описании MESSAGE

            HEAD     87h,'CONTEX',324Q,CONT,$USE         ; CONTEXT
    ; Пребывание в том  или ином  словаре  контролируется системной переменной
    ; CONTEXT,  в которой хранится  ссылка  на  адрес  последнего  слова,
    ; описанного  в  данном (контекстном) словаре.
            DW 50Q ; Указатель, с какого словаря следует начинать просмотр
                   ; при интерпретации

            HEAD    87h, 'CURREN',324Q,CURR,$USE        ; CURRENT
            DW 52Q  ; хранящая ссылку в слове Словаря на последнее слово,
                    ; описанное в текущем Словаре. очевидно, что
                    ; текущий Словарь может не совпадать с контекстным
                    ; это же адрес latest 

            HEAD     85h,'STAT',305Q,STATE,$USE          ; STATE
            DW 54Q  ; 0=> Исполнение

            HEAD     84h,'BAS',305Q,BASE,$USE            ; BASE
            DW 56Q  ; система исчисления

            HEAD     83h,'DP',314Q,DPL,$USE              ; DPL
            DW 60Q ; DPL определяет положение десятичной запятой (во входном
                   ; представлении это точка), для чисел одинарной длины DPL=-1.

            HEAD     83h,'CS',320Q,CSP,$USE              ; CSP
            DW 64Q

            HEAD     82h,'R',243Q,RNUM,$USE              ; R#
            DW 66Q ; указатель  положения  курсора  на  экране

            HEAD     83h,'HL',304Q,HLD,$USE              ; HLD
            DW 70Q ; которая является указателем позиции 
                   ; в выходном буфере (обычно PAD)

            HEAD     83h,'US',305Q,USE,$USE              ; USE
            DW 72Q ;
            ; A variable containing the address of the block buffer to use next,
            ; as the least recently written.

            HEAD     84h,'PRE',326Q,PREV,$USE            ; PREV
            DW 74Q ; адрес экранного блока 
            ; A variable containing the address of the disc buffer most recently
            ; referenced. The UPDATE command marks this buffer to be later written
            ; to disc.

            HEAD     83h,'$E',330Q,$EX,$USE              ; EXP
            DW 76Q  ; целочисленное значение  порядка  числа,  
                    ; который  следует  за признаком Е                    

            HEAD     83h,'ER',302Q,ERB,$USE              ; ERB
            DW 100Q ; 64d 40h
            ; Если ERB=0,  ERROR  работает  обычным  образом,  в противном случае
            ; переменная ERB обнуляется,  а уход из  программы  в  Форт  через  QUIT
            ; блокируется.

            HEAD     83h,'DE','B'+80h,DEB,$USE              ; DEB
            DW 102Q  ; признак отладки  66d

            HEAD     89h,'LASTRAND','X'+80h,LASTRANDX,$USE  ; LASTRANDX
            DW 104Q  ; 

            HEAD     82h,'X','A'+80h,XA,$USE              ; XA
            DW 106Q  ; 

            HEAD     82h,'X','C'+80h,XC,$USE              ; XC
            DW 110Q  ; 
                    
            HEAD     82h,'X','M'+80h,XM,$USE              ; XM
            DW 112Q  ;  

        ;** Слова высокого уровня **

            HEAD     85h,'?TER',315Q,?TERM,$COL          ; ?TERM
    ; вывод в стек кода символа из буфера клавиатуры без ожидания нажатия
            DW ?TER$,LIT,377Q,$AND,SEMI

            HEAD     82h,'C',322Q,CR,$COL                ; CR
    ; вывод символов 0D 0A
            DW LIT,15Q,EMIT,LIT,12Q,EMIT,SEMI

            HEAD     81h,,254Q,COMMA,$COL                ; ,
    ; в  свободную ячейку словаря помещяем число из стека и
    ;  занимаем эту ячейку (смещаем указатель here)
            DW HERE,STORE,TWO,ALLOT,SEMI

            HEAD     82h,'C',254Q,CCOM,$COL              ; C,
            DW HERE,CSTOR,ONE,ALLOT,SEMI

            HEAD      85h,'SPAC',305Q,SPACE,$COL         ; SPACE
            DW BLAN,EMIT,SEMI

             HEAD    83h,'PF','A'+80h,PFA,$COL           ; PFA
    ; NFA -> PFA
             DW  ONE,TRAV,LIT,5,PLUS,SEMI

             HEAD    83h,'?E',322Q,QERR,$COL             ; ?ER
    ; f errorcode -> если f=0, то без ошибок
             DW  SWAP,ZBRAN,TTT-$,ERROR,SEMI
   TTT:      DW  DROP,SEMI

             HEAD    85h,'?COM',320Q,QCOMP,$COL          ; ?COMP
        ; проверка режима работы. система в режиме компиляции?
             DW  STATE,AT,ZEQU,LIT,21Q,QERR,SEMI        ; 17 

             HEAD    85h,'?EXE',303Q,QEXEC,$COL          ; ?EXEC
        ; проверка режима исполнения    0=> Исполнение 
             DW  STATE,AT,LIT,22Q,QERR,SEMI             ; 18

             HEAD    85h,'?PAI',322Q,QPAIR,$COL          ; ?PAIR
             DW  SUBB,LIT,23Q,QERR,SEMI

             HEAD    84h,'?CS',320Q,QCSP,$COL            ; ?CSP
        ; контролируют сохранение указателя 
        ; стека параметров в процессе интерпретации слова
        ; текущее и сохраненное значение стека должны быть равны
             DW  SPAT,CSP,AT,SUBB,LIT,24Q,QERR,SEMI

             HEAD    85h,'?LOA',304Q,QLOAD,$COL          ; ?LOAD
        ; ошибка, если не вовремя загрузки
             DW  BLK,AT,ZEQU,LIT,26Q,QERR,SEMI      ; 22

             HEAD    87h,'COMPIL',305Q,COMP,$COL         ; COMPILE
    ; Компиляция исполнительного адреса, следующего за оператором
             DW  QCOMP,I,FROMR,TWOP,TOR,AT,COMMA,SEMI

             HEAD    84h,'SMU',307Q,SMUG,$COL            ; SMUDGE
        ; сбрасывает 5-й бит первого байта  описания  и  тем  самым
        ; делает   данное   слово  полноправным  членом  текущего  словаря
             DW  LATES,BLAN,TOGL,SEMI

             HEAD    87h,'(;CODE',251Q,PSCOD,$COL        ; (;CODE)
    ; адрес из стека возвратов (там находится адрес начала кода на ассемблере)
    ; пишем в CFA последнего определяемого слова  
    ; таким образом в CFA будет свой код интерпретатора на ассемблере
             DW  FROMR,LATES,PFA,CFA,STORE,SEMI

<<<<<<< HEAD
             HEAD    87h,'#BUILD',323Q,BUILD,$COL        ; <BUILDS ; 
    ; формирует в словаре описание константы равной 0 с именем XXX
    ; в поле PFA находится 0, который потом заменится адресом кода,
    ; следующего за словом DOES 
    ; в CFA будет помещен адрес кода $DOE
=======
             HEAD    87h, '<BUILD',323Q,BUILD,$COL        ; <BUILDS ; 
    ; �ନ��� � ᫮��� ���ᠭ�� ����⠭�� ࠢ��� 0 � ������ XXX
    ; � ���� PFA ��室���� 0, ����� ��⮬ ��������� ���ᮬ ����,
    ; ᫥���饣� �� ᫮��� DOES 
    ; � CFA �㤥� ����饭 ���� ���� $DOE
>>>>>>> 51f9fa2cf38b0a7ffc15f2cb0844f4e6edec42d6
             DW  ZERO,CON,SEMI

             HEAD    85h,'COUN',324Q,COUNT,$COL          ; COUNT
    ; addr1 --- addr2 n
    ; адрес HERE+1 (это адрес первого байта слова)
    ; и число символов в  слове  (HERE  C@)
             DW  DUBL           ; addr1 addr1
             DW  ONEP,SWAP      ; addr1+1 addr1
             DW  CAT,SEMI       ; addr1+1 u8[addr1]

             HEAD    84h,'TYP',305Q,$TYPE,$COL           ; TYPE
    ; адр count -> вывод строки на экран
             DW  DDUP,ZBRAN,TC1-$,ZERO,XDO
    TC0:     DW  DUBL,I,PLUS,CAT,LIT,177Q,$AND
             DW  ONE,EMI$,XLOOP,TC0-$
    TC1:     DW  DROP,SEMI

             HEAD    84h,'(."',251Q,PDOTQ,$COL           ; (.")
             DW  I      ; при исполнении следующее число - 
                        ; число символов сохраняется в RS 
             DW COUNT,DUBL,ONEP
             DW  FROMR,PLUS,TOR,$TYPE,SEMI

             HEAD    302Q,'.',242Q,DOTQ,$COL              ; ."
             DW  LIT,34,STATE,AT,ZBRAN,XT-$
             DW  COMP,PDOTQ,$WORD,HERE,CAT,ONEP
             DW  ALLOT, SEMI
   XT:       DW  $WORD,HERE,COUNT,$TYPE,SEMI

             HEAD    85h,'QUER',331Q,QUERY,$COL          ; QUERY
    ; входной буфер,  адрес которого хранится в системной переменной
    ; по имени TIB (Terminal Input Buffer).  Ввод  в  этот  буфер
    ; осуществляется оператором QUERY
             DW  TIB,AT,CFA,LIT,120Q,EXPE
             DW  ZERO,$IN,STORE,CR,SEMI
             
             HEAD    301Q,,200Q,NULL,$COL                 ; NULL
    ; немедленного исполнения. исполняется, если встретился 0 в коде 
    ; прерывает бесконечное испольнение INTERPRET 
             DW  BLK,AT,ZBRAN,NUL-$         ; если пультовый режим
             DW  ONE,BLK,PSTOR,ZERO,$IN,STORE,QEXEC
    NUL:     DW  LEV,SEMI

             HEAD    83h,'PA',304Q,PAD,$COL              ; PAD
        ; Многие операции   выдачи   результатов   и   сообщений   на   экран
        ; производятся   через   специальный   буфер,   адрес   которого  смещен
        ; относительно HERE.  В базовом словаре имеется  оператор  PAD,  который
        ; выдает в стек адрес КОНЦА этого буфера:
             DW  HERE,LIT,104Q,PLUS,SEMI

             HEAD    84h,'WOR',304Q,$WORD,$COL           ; WORD
        ; разделитель -> число_символов строка по адресу here
             DW  BLK,AT,DDUP,ZBRAN,WD1-$; ввод с клавиатуры
             DW  BLOCK,BRAN,WD2-$       ; адрес буфера из переменной BLK
   WD1:      DW  TIB,AT                 ; адрес входного терминала
   WD2:      DW  $IN,AT,PLUS,SWAP,ENCL,HERE,BLAN,BLANK,$IN
             DW  PSTOR,TOR,I,HERE,CSTOR
             DW  HERE,ONEP,FROMR,CMOV,SEMI

             HEAD    88h,'(NUMBER',251Q,PNUMB,$COL       ; (NUMBER)
   BN:       DW  ONEP,TOR,I,CAT,BASE,AT,DIGIT,ZBRAN,MMO-$
             DW  SWAP,BASE,AT,USTAR,DROP,ROT,BASE,AT,USTAR
             DW  DPLUS,DPL,AT,ONEP,ZBRAN,BN1-$,ONE,DPL,PSTOR
   BN1:      DW  FROMR,BRAN,BN-$
   MMO:      DW  FROMR,SEMI

             HEAD    85h,'-FIN',304Q,DFIND,$COL          ; -FIND
        ; Поиск слова в словаре, которое следует следующим в тексте программы
             DW  BLAN,$WORD,HERE,COUNT,UPPER,HERE
             DW  CONT,AT,AT ; поиска в контекстном словаре
             DW  PFIND,DDUP,ZEQU,ZBRAN,FIN-$,HERE,LATES,PFIND
   FIN:      DW  SEMI

             HEAD    86h,'NUMBE',322Q,NUMB,$COL          ; NUMBER
             DW  ZERO,$EX,STORE,BASE,AT,ZERO,ROT
             DW  ONEP,DUBL,CAT,DUBL,LIT,53Q,EQUAL
             DW  ZBRAN,NH1-$,DECIMA,DROP,BRAN,NH4-$
   NH1:      DW  DUBL,LIT,55Q,EQUAL,ZBRAN,NH2-$,DROP,DECIMA
             DW  SWAP,DROP,ONE,SWAP,BRAN,NH4-$
   NH2:      DW  LIT,47Q,EQUAL,ZBRAN,NH3-$,OCTAL,ONEP
   NH3:      DW  ONEM
   NH4:      DW  LIT,-1,DPL,STORE,ZERO,ZERO,ROT,PNUMB,DUBL
             DW  CAT,BLAN,SUBB,ZBRAN,NH6-$
             DW  DUBL,CAT,LIT,56Q,EQUAL,ZBRAN,EXP-$
             DW  ZERO,DPL,STORE,PNUMB,DUBL,CAT,BLAN,SUBB,ZBRAN,NH6-$
   EXP:      DW  DPL,AT,SWAP,DUBL,CAT,LIT
             DW  105Q,EQUAL,ZBRAN,ER1-$,ONEP,DUBL,CAT
             DW  LIT,55Q,EQUAL,ZBRAN,NEMI-$,ONE,BRAN,NH0-$
   NEMI:     DW  DUBL,CAT,LIT,53Q,SUBB,ZBRAN,PLU-$,ONEM
   PLU:      DW  ZERO
   NH0:      DW  SWAP,ZERO,ZERO,ROT,PNUMB,CAT,BLAN,EQUAL,ZBRAN,ER-$
             DW  DROP,SWAP,ZBRAN,NH5-$,MINUS
   NH5:      DW  $EX,STORE,DPL,STORE,ZERO
   NH6:      DW  DROP,ROT,ZBRAN,NH7-$,DMINU
   NH7:      DW  ROT,BASE,STORE,SEMI
   ER:       DW  DDROP,DROP
   ER1:      DW  DDROP,DDROP,DROP,ZERO,ERROR,SEMI

             HEAD    85h,'ERRO',322Q,ERROR,$COL          ; ERROR
             DW  HERE,COUNT,$TYPE,PDOTQ
             DB  3 , ' ? '
             DW  ERB,AT,ZBRAN,XER-$
             DW  ZERO,ERB,STORE,DROP,SEMI
   XER:      DW  MESS,SPSTO,QUIT

             HEAD    83h,'ID',256Q,IDDOT,$COL            ; ID.
        ; печатает   имя   слова
             DW  COUNT,LIT,37Q,$AND,$TYPE,SPACE,SEMI

             HEAD    86h,'CREAT',305Q,CREAT,$COL         ; CREATE  
        ; - --> адр XXX (I, C)
        ; формирование новых слов - описателей.
        ; (CREATE XXX DOES>) XXX исполняется на этапе компиляции,
        ; текст программы, следующий за DOES>, адрес которого 
        ; помещается в PFA - на этапе исполнения.        
             DW  DFIND,ZBRAN,CRE-$,DROP,TWOP,NFA,IDDOT
             DW  LIT,4,MESS             ; сообщение о повторном определении слова
   CRE:      DW  HERE,DUBL,CAT,$WIDTH,AT,MIN,ONEP,ALLOT ; here указывает на число символов слова
                                                ; сдвигаем here на длину слова + сам байт длины
             DW  DUBL,LIT,240Q,TOGL,HERE,ONEM   ; выключаем из поиска
                                            ; 240Q = 10100000
             DW  LIT,200Q,TOGL,LATES,COMMA,CURR,AT,STORE ; в последней букве слова включаем 7 бит
                                            ; ссылка на пред слово и сохраняем ссылку на вновь
                                            ; созданное слово    
             DW  HERE,TWOP,COMMA,SEMI       ; в CFA пишем адрес PFA
             HEAD    311Q,'[COMPILE',335Q,BCOM,$COL       ; [COMPILE]
        ; Используется в описании типа двоеточия и служит для
		; компиляции слова немедленного действия XXX, как если бы оно
        ; не было таким. Слово XXX будет исполнено тогда, когда будет
        ; исполнено слово, в котором использована комбинация [COMPILE] XXX
        ; кладет в словарь CFA компилируемого слова
             DW  DFIND,ZEQU,ZERO,QERR,DROP,COMMA,SEMI

            HEAD    307Q,'LITERA',314Q,LITER,$COL        ; LITERAL
    ; компилирует число в словарь
            DW  STATE,AT,ZBRAN,LIL-$       ; в режиме исполнения ничего не делает
            DW  COMP,LIT,COMMA
    LIL:    DW  SEMI

             HEAD    310Q,'DLITERA',314Q,DLITE,$COL       ; DLITERAL
    ; компилирует в словарь двойное число
             DW  STATE,AT,ZBRAN,DLI-$
            DW  SWAP,LITER,LITER
   DLI:      DW  SEMI

             HEAD    86h,'?STAC',313Q,QSTAC,$COL         ; ?STACK
    ; -> f , true если значение указателя стека в пределах допусков
             DW  SZERO,AT,CFA,SPAT,ULESS,ONE,QERR
             DW  LIT,-200Q,SPAT,ULESS,TWO
             DW  QERR, SEMI

             HEAD    211Q,'INTERPRE',324Q,INTER,$COL      ; INTERPRET
   IT1:      DW  DFIND,ZBRAN,IT3-$ ; переход если не найдено
             DW  STATE,AT,LESS, ZBRAN,IT2-$ ; выполнить  
             DW  COMMA,BRAN,IT5-$
   IT2:      DW  EXEC,BRAN,IT5-$
   IT3:      DW  HERE,NUMB,DPL,AT,ONEP,ZBRAN,IT4-$
             DW  DLITE,BRAN,IT5-$
   IT4:      DW  DROP,LITER
   IT5:      DW  QSTAC,BRAN,IT1-$

             HEAD    211Q,'IMMEDIAT',305Q,IMMED,$COL      ; IMMEDIATE
    ; отмечает последнее слово признаком 
             DW  LATES,$CL,TOGL,SEMI        ; cl - 6 бит

            HEAD    212Q,'VOCABULAR',331Q,VOCAB,$COL     ; VOCABULARY
    ; создание нового словаря 
            DW  BUILD,LIT,120201Q,COMMA ; 
            DW  CURR,AT,CFA,COMMA
            DW  HERE,VOCL,AT,COMMA,VOCL,STORE,DOES
    DOVOC   LABEL    FAR  
            DW  TWOP,CONT,STORE,SEMI ; этот код будет в PFA нового словаря
                                     ; в CFA словаря попадет код $DOE, который 
                                     ; передает управлению коду по адресу PFA
                                     ; в стек кладет адрес PFA+2


             HEAD    301Q,,250Q,PAREN,$COL                ; (
        ; пропуск до следующей )
             DW  LIT,29h,$WORD,SEMI

             HEAD    84h,'QUI',324Q,QUIT,$COL            ; QUIT
    ; Очищает оба стека и возвращает управление терминалу. 
    ; Не выдается никаких сообщений
             DW  ZERO,BLK,STORE,LBRAC
   QUI:      DW  RPSTO,CR,QUERY,INTER,STATE,AT
             DW  ZEQU,ZBRAN,QUI-$,PDOTQ
             DB  3,' OK'
             DW  BRAN,QUI-$

             HEAD    85h,'ABOR',324Q,ABORT,$COL          ; ABORT
    ; Прерывает исполнение, делает словарь Форт контекстным,
    ; выполняет QUIT. Распечатывает версию интерпретатора
             DW  SPSTO,DECIMA,CR,PDOTQ
             DB  17,'FORTH-PC IS HERE '
             DW  FORTH,DEFIN,QUIT

             HEAD    82h,'S',256Q,SPOT,$COL              ; S.
    ; печать верхнего значения со стека без его изменения
             DW  DUBL,UDOT,SEMI

             HEAD    81h,,252Q,STAR,$COL                 ; *
             DW  MSTAR,DROP,SEMI

             HEAD    84h,'/MO',304Q,SLMOD,$COL           ; /MOD
    ; n1 n2 --- rem quot 
             DW  TOR,STOD,FROMR,MSLAS,SEMI

             HEAD    81h,,257Q,SLASH,$COL                ; /
             DW  SLMOD,SWAP,DROP,SEMI

             HEAD    83h,'MO',304Q,$MOD,$COL             ; MOD
             DW  SLMOD,DROP,SEMI

             HEAD    85h,'*/MO',304Q,SSMOD,$COL          ;. */MOD
    ; u1 u2 u3 --> u-rem u-result
    ; u1*u2/u3 - остаток и частное, u1 u2 - 32-разрядное число

             DW  TOR,MSTAR,FROMR,MSLAS,SEMI

             HEAD    82h,'*',257Q,SSLA,$COL              ; */
             DW  SSMOD,SWAP,DROP,SEMI

             HEAD    85h,'M/MO',304Q,MSMOD,$COL          ; M/MOD
             DW  TOR,ZERO,I,USLAS,FROMR,SWAP,TOR,USLAS
   $MO:      DW  FROMR,SEMI

             HEAD    215Q,'EMPTY-BUFFER',323Q,MTBUF,$COL  ;EMPTY-BUFFERS
             DW  FIRST,AT,LIT,0C12h,ERASE,SEMI   ; 3084 было

             HEAD    85h,'FLUS',310Q,FLUSH,$COL          ; FLUSH
    ; запись буферов на диск
             DW  LIMIT,AT,FIRST,AT,XDO
   FLU:      DW  I,AT,ZLESS,ZBRAN,FL1-$
             DW  I,TWOP,I,X,ZERO, RW
   FL1:      DW  LIT,1028,XPLOO,FLU-$,MTBUF,SEMI

             HEAD    86h,'BUFFE',322Q,BUFFE,$COL         ; BUFFER
    ; u --> адр  Резервирует блок в памяти, приписывает ему
    ; номер u, но никакого чтения с носителя не производится
             DW  USE,AT,TOR,I       ; адрес буфера в стеках
   BR1:      DW  PBUF,ZBRAN,BR1-$   ; ищем свободный буфер
            DW USE,STORE            ; полученный адрес сохранить в USE
             DW  I,AT,ZLESS,ZBRAN,BR2-$ ; если buffer изменен,
             DW  I,TWOP,I,X,ZERO, RW    ; то запись его на диск
   BR2:      DW  I,STORE,I,PREV,STORE   ; номер буфера записать и адрес сохранить в PREV
            DW FROMR,TWOP,SEMI          ; возвращаемое значение

             HEAD    85h,'BLOC',313Q,BLOCK,$COL          ; BLOCK
    ;   u --> адр  Записывает в стек адрес первого байта в блоке с
    ;   номером u. Если блок не находится в памяти, он переносится с носителя 
             DW  OFSET,AT,PLUS,TOR
             DW  PREV,AT,DUBL,X,I,SUBB,ZBRAN,BLC-$
   BLO:      DW  PBUF,ZEQU,ZBRAN,BCK-$
             DW  DROP,I,BUFFE,DUBL,I,ONE,RW,CFA
   BCK:      DW  DUBL,X,I,SUBB,ZEQU
             DW  ZBRAN,BLO-$,DUBL,PREV,STORE
   BLC:      DW  FROMR,DROP,TWOP,SEMI

             HEAD    85h,'.LIN',305Q,DLINE,$COL          ; .LINE
    ; строка номер_экрана -- печать строки из экрана
             DW  TOR,$CL,BBUF,SSMOD ; строка*64/1024 
             DW  FROMR,PLUS,BLOCK   ; номер_экрана + частное 
             DW  PLUS           ; остаток+ адрес_блока (нужная строка) 
             DW  $CL,DTRAI,$TYPE,SEMI ; 64 - число пробелов (число символов в строке)

             HEAD    87h,'MESSAG',305Q,MESS,$COL         ; MESSAGE
             DW  $IN,AT,RNUM,STORE ; сохранить значение $in
             DW  $WARN,AT,ZBRAN,MS1-$ ; нужен ли текст сообщения
             DW  DDUP,ZBRAN,MES-$
             DW  LIT,4,OFSET,AT,SUBB,DLINE ; текстовые сообщения на 4 экране
   MES:      DW  SEMI
   MS1:      DW  PDOTQ
             DB  6,'MSG # '
             DW $DOT,SEMI

             HEAD    84h,'LOA',304Q,LOA,$COL            ; LOAD
    ; n -> номер экрана
             DW  BLK,AT,$IN,AT,ZERO,$IN,STORE,ROT,BLK
             DW  STORE,INTER,$IN,STORE,BLK,STORE,SEMI

             HEAD    303Q,'--',276Q,ARROW,$COL            ; -->
    ; згрузка следующего экрана 
             DW  QLOAD,ZERO,$IN,STORE,ONE
             DW  BLK,PSTOR,SEMI

             HEAD    301Q,,247Q,TICK,$COL                 ; '
    ; Ищет слово XXX в словаре и записывает в стек его PFA
             DW  DFIND,ZEQU,ZERO,QERR,DROP,TWOP,LITER,SEMI

             HEAD    86h,'FORGE',324Q,FORGE,$COL         ; FORGET
             DW  CURR,AT,CONT,AT,SUBB,LIT,30Q,QERR     ; 24 ошибка не описана
                                                        ; ошибка если CURRENT = CONTEXT
             DW  TICK,DUBL,FENCE,AT,ULESS,LIT,25Q,QERR  ; 21 слово защищено
             DW  DUBL,NFA,$DP,STORE                    ; словарь свободен до указаного слова
             DW  LFA,AT,CONT,AT,STORE,SEMI             ; в переменную context пишем адрес  
                                                ; значение LFA забываемого слова

             HEAD    84h,'BAC',313Q,BACK,$COL            ; BACK
    ; HERE - , ; (компилирует в описание слова адрес возврата)
             DW  HERE,SUBB,COMMA,SEMI

             HEAD    305Q,'BEGI',316Q,BEGIN,$COL          ; BEGIN
    ; BEGIN ... UNTIL
    ; BEGIN ... AGAIN
    ; BEGIN ... WHILE ... REPEAT
             DW  QCOMP,HERE,ONE,SEMI             

             HEAD    302Q,'D',317Q,$DO,$COL               ; DO
             DW  COMP,XDO,HERE,THREE,SEMI

             HEAD    304Q,'LOO',320Q,LOO,$COL            ; LOOP
             DW  THREE,QPAIR,COMP,XLOOP,BACK,SEMI

             HEAD    305Q,'+LOO',320Q,PLOOP,$COL          ; +LOOP
             DW  THREE,QPAIR,COMP,XPLOO,BACK,SEMI

             HEAD    305Q,'UNTI',314Q,UNTIL,$COL          ; UNTIL
             DW  ONE,QPAIR,COMP,ZBRAN,BACK,SEMI

            HEAD    305Q,'AGAI','N'+80h,AGAIN,$COL        ; AGAIN sds
            DW  ONE,QPAIR,COMP,BRAN,BACK,SEMI

             HEAD    305Q,'WHIL',305Q,$WHILE,$COL         ; WHILE
             DW  $IF,SEMI

             HEAD    306Q,'REPEA',324Q,REPEA,$COL        ; REPEAT
             DW  ROT,ONE,QPAIR,ROT,COMP,BRAN,BACK
             DW  THEN,SEMI

             HEAD    302Q,'I',306Q,$IF,$COL               ; IF
             DW  COMP,ZBRAN,HERE,ZERO,COMMA,TWO,SEMI

             HEAD    304Q,'ELS',305Q,$ELSE,$COL           ; ELSE
             DW  TWO,QPAIR,COMP
             DW  BRAN,HERE,ZERO,COMMA   ; если исполнение пришло к этому BRAN
                                        ; значит была выполнена ветка TRUE и
                                        ; надо перепрыгнуть ветку FALSE (безусловно)
             DW  SWAP,TWO,THEN,TWO,SEMI ; адреса переходов меняем местами, т.к.
                                        ; по условию FALSE должен выполниться  
                                        ; код после слова ELSE, воспользуемся 
                                        ; для этого словом THEN

             HEAD    304Q,'THE',316Q,THEN,$COL            ; THEN
             DW  QCOMP,TWO,QPAIR,HERE,OVER,SUBB,SWAP,STORE,SEMI           
    ; if - step      cond if true else false then 
        ; DICT:  ?BRANCH 0 
        ; STACK:  adr_if 
    ; else - step получается слишком много кода... Вроде разобрался! :)
        ; ?BRANCH 0     BRANCH 0 
        ;  adr_else adr_if 
    ; then - step
        ;1 DICT:  ?BRANCH 0 
        ;1 STACK:  adr_if         
        ;2 STACK:  adr_if adr_then  
        ;3 STACK:  adr_if adr_then  adr_if 
        ;4 STACK:  adr_if (adr_if-adr_then)
        ;4 STACK:  (adr_if-adr_then) adr_if 
        ;5 DICT:  ?BRANCH [adr_if]=(adr_if-adr_then) 
        ;5 STACK:  

             HEAD    86h,'SPACE',323Q,SPACS,$COL         ; SPACES
             DW  ZERO,MAX,DDUP,ZBRAN,SP1-$,ZERO,XDO
   SPA:      DW  SPACE,XLOOP,SPA-$
   SP1:      DW  SEMI

<<<<<<< HEAD
             HEAD    82h,'#',243Q,BDIGS,$COL             ; <# ; sds replace 
    ; Начинает процесс преобразования числа в последовательность кодов ASCII.
    ; Исходное число в стеке должно быть двойной длины без знака
=======
             HEAD    82h,'<',243Q,BDIGS,$COL             ; <# ; sds replace 
    ; ��稭��� ����� �८�ࠧ������ �᫠ � ��᫥����⥫쭮��� ����� ASCII.
    ; ��室��� �᫮ � �⥪� ������ ���� ������� ����� ��� �����
>>>>>>> 51f9fa2cf38b0a7ffc15f2cb0844f4e6edec42d6
             DW  PAD,HLD,STORE,SEMI

             HEAD    82h,'#',276Q,EDIGS,$COL             ; #>
    ; Завершает преобразование числа. В стеке остается число
    ; полученных символов и адрес, как это требуется для
    ; оператора TYPE         
             DW  DDROP,HLD,AT,PAD,OVER,SUBB,SEMI

             HEAD    84h,'SIG',316Q,SIGN,$COL            ; SIGN
    ; Вводит знак "минус" в выходной буфер
             DW  ROT,ZLESS,ZBRAN,SIG-$,LIT,55Q,HOLD
   SIG:      DW  SEMI

             HEAD    81h,,243Q,DIG,$COL                  ; #
    ; Преобразует одну цифру и записывает ее в выходной буфер (PAD),
    ; выдает цифру всегда, если преобразовывать нечего, записывается 0
             DW  BASE,AT,MSMOD,ROT,LIT,11Q,OVER,LESS
             DW  ZBRAN,DIGI-$,LIT,7,PLUS
   DIGI:     DW  LIT,60Q,PLUS,HOLD,SEMI

             HEAD    82h,'#',323Q,DIGS,$COL              ; #S
    ; Преобразует число до тех пор, пока не будет получен 0.
    ; Одна цифра выдается в любом случае (0)
   DIS:      DW  DIG,DUP2,$OR,ZEQU,ZBRAN,DIS-$,SEMI

             HEAD    83h,'D.',322Q,DDOTR,$COL            ; D.R
    ; s width -> печать двойного числа со знаком с выравниваем вправо
             DW  TOR,SWAP,OVER,DABS,BDIGS,DIGS,SIGN,EDIGS
             DW  FROMR,OVER,SUBB,SPACS,$TYPE,SEMI

             HEAD    82h,'.',322Q,DOTR,$COL              ; .R
    ; s width -> печать числа со знаком с выравниваем вправо
             DW  TOR,STOD,FROMR,DDOTR,SEMI

             HEAD    83h,'U.',322Q,UDOTR,$COL            ; U.R
    ; u width -> печать числа без знака с выравниваем вправо
             DW  ZERO,SWAP,DDOTR,SEMI

             HEAD    82h,'D',256Q,DDOT,$COL              ; D.
    ; печать двойных чисел
             DW  ZERO,DDOTR,SPACE,SEMI

             HEAD    81h,,256Q,$DOT,$COL                 ; .
             DW  STOD,DDOT,SEMI

             HEAD    81h,,277Q,QUEST,$COL                ; ?
    ; печать содержимого по адресу в стеке
             DW  AT,$DOT,SEMI

             HEAD    82h,'U',256Q,UDOT,$COL              ; U.
    ; печать числа без знака          
             DW  ZERO,DDOT,SEMI

    ;         ** Вспомогательные процедуры **

             HEAD    84h,'LIS',324Q,$LIST,$COL           ; LIST
    ; n -> вывод содержимого экрана
             DW  DECIMA,CR,DUBL,SCR,STORE,PDOTQ
             DB  3,'S# '
             DW  $DOT
             DW  LIT,20Q,ZERO,XDO
   LSTI:     DW  CR,I,THREE,DOTR,SPACE
             DW  I,SCR,AT,DLINE
             DW XLOOP,LSTI-$,CR,SEMI

             HEAD    85h,'INDE',330Q,INDEX,$COL          ; INDEX
    ; n1 n2 -> выводит первую строку экранов с n1 по n2
             DW  ONEP,SWAP,XDO
   INDX:     DW  CR,I,THREE,DOTR,SPACE,ZERO,I,DLINE
             DW  XLOOP,INDX-$,SEMI

             HEAD    84h,'TRI',317Q,TRIO,$COL            ; TRIO
    ; При документировании текстов программ оказывается удобным размещать
    ; тексты экранов по три на странице
             DW  LIT,14Q,EMIT
             DW  THREE,OVER,PLUS,SWAP,XDO
   TRI:      DW  I,$LIST,XLOOP,TRI-$,SEMI

             HEAD    85h,'VLIS',324Q,VLIST,$COL          ; VLIST
    ; список слов в контекстном словаре 
             DW  CONT,AT,AT
   VL0:      DW  CR,THREE,ZERO,XDO
   VL1:      DW  DUBL,IDDOT,LIT,15Q,OVER,CAT,LIT,37Q,$AND,SUBB
             DW  SPACS,PFA,DUBL,LIT,6,UDOTR,SPACE,LIT,41Q
             DW  EMIT,SPACE,   LFA,AT,DUBL,ZEQU,ZBRAN,VL2-$
             DW  LEAV ; добавил паузу
   VL2:      DW  XLOOP,VL1-$, KEY, DROP
             DW  DDUP,ZEQU,ZBRAN,VL0-$,SEMI

             HEAD    83h,'LC',314Q,LCL,$COL              ; LCL
    ; очистка командной строки
             DW  ZERO,ZERO,FIX,$CL,SPACS,RC,SEMI

             HEAD    82h,'H',324Q,HT,$COL                ; HT HOME?
    ; курсор в начало экрана
             DW  ZERO,ZERO,FIX,SEMI

             HEAD    84h,'COP',331Q,COPY,$COL            ; COPY
    ; копия экрана          
             DW  SWAP,BLOCK,CFA,STORE,UPDAT,FLUSH,SEMI
             
             HEAD    82h,'T',331Q,TY$$,$COL              ; TY
    ; adr n ->  дамп памяти
             DW  ZERO,XDO
   TY4:      DW  I,EIGHT,$MOD,ZEQU,ZBRAN,TY5-$
             DW  CR,DUBL,LIT,7,UDOTR
   TY5:      DW  DUBL,AT,LIT,7,UDOTR,TWOP,XLOOP,TY4-$,SEMI

             HEAD    85h,'DEPT',310Q,DEPTH,$COL          ; DEPTH
    ; число элементов в стеке      
             DW  SZERO,AT,SPAT,TWOP,SUBB,DIV2,SEMI

             HEAD    84h,'DUM',320Q,DUMP,$COL            ; DUMP
    ; адр u --> - Отображает u байт памяти начиная с адр
             DW  ZERO,XDO
   DMP:      DW  DUBL,LIT,7,UDOTR,SPACE,EIGHT,ZERO,XDO
   DP1:      DW  DUBL,I,PLUS,CAT,LIT,5,DOTR,XLOOP,DP1-$
             DW  LIT,4,SPACS,EIGHT,ZERO,XDO
   DP2:      DW  DUBL,I,PLUS,CAT,LIT,177Q,$AND,DUBL,BLAN
             DW  LESS,ZBRAN,DP3-$,DROP,LIT,56Q
   DP3:      DW  EMIT,XLOOP,DP2-$,CR,EIGHT,PLUS,EIGHT
             DW  XPLOO,DMP-$,DROP,SEMI

             HEAD    84h,'SWA',323Q,SWAS,$COL            ; SWAS
        ; перемены  мест экранов М и N     
             DW  TOR,BLOCK,CFA,DUBL,AT,I,BLOCK,CFA,STORE,UPDAT
             DW  FROMR,LIT,100000Q,$OR,SWAP,STORE,FLUSH,SEMI

             HEAD    83h,'ST',331Q,STY,$COL              ; STY
        ; печать стека
             DW  DEPTH,DDUP,ZBRAN,STY3-$,ZERO,XDO
   STY1:     DW  I,EIGHT,$MOD,ZEQU,ZBRAN,STY2-$,CR
   STY2:     DW  I,ONEP,PICK,LIT,7,UDOTR,XLOOP,STY1-$
   STY3:     DW  SEMI

             HEAD    82h,'O',256Q,ODOT,$COL              ; O.
        ; тоже что и S. в octal системе
             DW  BASE,AT,OVER,OCTAL,UDOT,BASE,STORE,SEMI

             HEAD    83h,'R/',327Q,RW                    ; R/W
   ; Открытие файла
             MOV   DX, OFFSET file
             ;MOV   AH, 0FH      ; open file
             MOV   AH, 3dh
             mov   al, 2
             INT   21H
             ;CMP   AL, 0FFH
             ;JE    ERR0
             jc ERR0
             mov    handle, ax
             POP   BX  ; R/W - флаг
             POP   AX  ; Номер блока             
             POP   DX  ; Адрес буфера
             DEC   AX
             MOV   CL, 10 ; 3 было
             SAL   AX, CL  ; (BLOCK#-1)*8 ; теперь на 1024 байт
             ;MOV   RANDREC,AX
             ;MOV   RANDREC+2,0
             push   bx
             push   dx
             mov    dx, ax
             mov    cx, 0
             mov    ax, 4200h
             mov bx, handle
             int 21h
             jc ERR0
             pop    dx
             pop    bx                          
             CMP   BX, 0 ; режим
             JNE   RED
   ; WRITE
             ;MOV   BX, DX
             ;MOV   CX, 8      ; Номер записи
   WR:       ;MOV   DX, BX
             ;MOV   AH,1AH     ; Запись адреса буфера (Set disk transfer address)
             ;INT   21H
             ;MOV   DX,OFFSET FCB
             ;MOV   AH, 22H    ; Запись RECORD (Random write)
             ;INT   21H
             MOV   AH, 40H
             MOV   CX, 1024
             mov    bx, handle
             INT   21H
             ;CMP   AL, 0
             ;JNE   ERR1
             jc err1
             ;INC   RANDREC    ; Коррекция адреса буфера
             ;ADD   BX, 80H
             ;LOOP  WR
             JMP  OUT1

    RED:     ;MOV   CX, 8
             ;MOV   BX, DX
    ;RD:     ;MOV   DX, BX       ; адрес буфера
             ;MOV   AH, 1AH     ; Запись адреса буфера
             MOV   AH, 3fH
             MOV   CX, 1024
             mov    bx, handle
             INT   21H
             jc ERR3
             cmp ax,cx
             jne err3
             ;MOV   DX, OFFSET  FCB
             ;MOV   AH, 21H      ; Random read
             ;INT   21H
             ;CMP   AL, 0
             ;JNE   ERR3
             ;INC   RANDREC     ; Коррекция адреса
             ;ADD   BX, 80H
            ; LOOP   RD

   OUT1:     ;MOV   DX, OFFSET  FCB  ; Закрытие файла
             mov bx, handle   
             ;MOV   AH, 10H
             mov ah, 3eh 
             INT   21H
             ;CMP   AL, 0
             ;JNE   ERR2
             jc ERR2
   EXIT:     NEXT
   ERR0:     MOV   DX, OFFSET  ERMES0
             JMP   DONE
   ERR1:     MOV   DX, OFFSET  ERMES1
             JMP   DONE
   ERR2:     MOV   DX, OFFSET  ERMES2
             JMP   DONE
   ERR3:     MOV   DX, OFFSET  ERMES3
   DONE:     MOV   AH, 9H ; вывод сообщения
             INT   21H 
             JMP   EXIT

             HEAD    305Q,';COD','E'+80h,SEMIC,$COL          ; ;CODE
    ; для определения в форт программе слов на ассемблере
             DW  QCSP,COMP,PSCOD,LBRAC,SMUG,SEMI

             HEAD    305Q,'FORT','H'+80h,FORTH,$DOE          ; FORTH
    ; Делает словарь Форт контекстным.
    ; см. FORTH DIMENSION 
            DW  DOVOC   ; PFA     
            DW 120201Q  ; = A0 81 мнимый заголовок слова для связи словарей
            DW TASK-7   ; PFA+4 NFA(TASK) последнее слово в этом словаре                                    
    XVOC    LABEL   FAR ; VOC-LINK
            DW  0       ; ссылка на предыдущий словарь
                        ; для чего так и не нашел. похоже, здесь не используется
    ; VOC-LINK --- addr U
    ;    A user variable containing the address of a field in the definition
    ;    of the most recently created vocabulary. All vocabulary names are
    ;    linked by these fields to allow control for FORGETting thru multiple
    ;    vocabularies.

             HEAD    84h,'TAS','K'+80h,TASK,$COL            ; TASK
        ; пустое определение. последнее слово в словаре FORTH
             DW  SEMI

   handle   dw 0
   file     db "forth.dat", 0
   ; FCB not used now
   FCB       LABEL WORD
   DRIVE     DB    0
   FN        DB    'FORTH   '
   EXT       DB    'DAT'
   CURBLK    DW    0          ; Относительное начало файла
   RECSIZE   DW    80H        ; размер логичю записи  
   FILESIZE  DW    5000,0     ; размер файла  
   DATE      DW    0,0
             DB    0,0,0,0,0, 0,0,0,0,0 ; REZERV
   CURREC    DB    0           ; запись с текущего блока 
   RANDREC   DW    0,0         ; номер записи

   ERMES0    DB    'ERR OPENING FILE$'
   ERMES1    DB    'ERR WRITING FILE$'
   ERMES2    DB    'ERR CLOSING FILE$'
   ERMES3    DB    'ERR READING FILE$'


   XDP     DW  16000 DUP(0)           ; DICTIONARY

   STCK   SEGMENT STACK              ; Стек параметров
           DW  64 DUP (?)
   XS0     LABEL   WORD
           DW  0,0   ; STACK
   STCK   ENDS

   ARRAY      ENDS
   END        $INI


   Таблица 26. Диагностические сообщения
----------------------------------------------------------------------
Сообщение при                                       Сообщения при
  WARNING=0            Значения                     WARNING=1
----------------------------------------------------------------------
MSC# 0      Слово не узнано.
            Число не узнано.
            Нет соответствия системе счисления

MSC# 1      Попытка извлечь нечто из пустого стека  EMPTY STACK

MSC# 2      Переполнение стека или словаря          STACK OR DIRECTORY
						                            OVERFLOW

MSC# 4      Повторное описание слова (не является   IT ISN'T UNIQUE
	        фатальной ошибкой)

MSC# 17     Используется только при компиляции      COMPILATION ONLY

MSC# 18     Используется только при исполнении      EXECUTION ONLY

MSC# 19     IF и THEN или другие операторы          CONDITIONALS
	        не имеют пары                           AREN'T PAIRED

MSC# 20     Определение не завершено                DEFINITION ISN'T
						                            FINISHED

MSC# 21     Нелегальный аргумент слова FORGET       PROTECTED
	        Слово в защищенной части словаря        DIRECTORY

MSC# 22     Должно использоваться только            USED AT LOADING
            при загрузке                            ONLY

MSC# 26     Деление на 0                            0 DIVISION
----------------------------------------------------------------------
после загрузки:
    context=current=27f5 словарь forth 
    указывает на последнее слово asctab (2977)

VOCABULARY editor
    vocl -> 2a16
    nfa (editor) = 2a05
    context=current=27f5 словарь forth 
    указывает на последнее слово editor (2a05)

editor
    context = 2a14 -> 27f3 = мнимый заголовок (120201Q)
    current = 27f5

структура слова словаря 
2a05    86, 'EDITOR' 
2a0c    2977 link - asctab предшествующее слово
2a0e    18DB cfa - $DOE
2a10    201E pfa - dovoc
2a12    a081 pfa+2  - мнимый заголовок 
2a14    27f3  - context мнимый заголовок (120201Q) словаря форт
2a16    27f7  - конец словаря FORTH. VOCL=2a16
