; 253 ᫮�� head
; 103 ᫮�� �ᯮ����� $col
; 9 ᫮�� �ᯮ���� $con 
; 29 ᫮�� �ᯮ���� $use
; 1 ᫮�� forth

masm
.8086
.MODEL SMALL
LINK=0
    .LALL
    ; ���ம�।������
    ; ���ᠭ�� �ਬ�⨢�� � ᫮� ��᮪��� �஢��
    HEAD  MACRO length,name,lchar,labl,code
    LINK$=$
        DB  length  ; NFA 7 ��� ࠢ�� 1.
                    ; 6 - �ਧ��� immediate. 5- ᫮�� �� ���ᠭ�
        IFNB <name>
        DB  NAME
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

debug equ 0

    NEXT MACRO   ; ���室 � �ᯮ������ ᫥���饣� ᫮��

        LODSW           ; DS:[SI] -> AX ; SI = SI + 2
        MOV  BX, AX     ; BX ࠢ�� CFA  ᫥���饣� ᫮��
        if debug
            ;mov ax, si
            call printWORD
            call pause                 
        endif
        JMP WORD PTR [BX] ; 
        ENDM

  TITLE   FORTH Interpreter

   ARRAY   SEGMENT   
   $TIME   DW  0,0                     ; TIMER COUNTER
   $DATE   DW  0                       ; DATE

   ;  ������� �⥪� � ᫮���� ���짮��⥫� ࠧ��饭 � ���� ⥪��
   ;  ��������. ��� ���ᨨ, �����뢠���� � ���, �� �㦭�
   ;  ࠧ������ �����.

   DSKBUF  DW  3 DUP(0,512 DUP(0),0)   ; ��࠭�� ����� �� 1024 ����
   ENDBUF  DW  0        ; 6 1034 (40Ah) 2062(80Eh) ���� ���஢

   XTIB    DW  92 DUP(0)               ; �室��� ����
   XR0     DW  0,0                     ; �⥪ �����⮢  ���� � �������
                                       ; ������ ���ᮢ.  ADD BP - ���� �����
   XUP     DW  102 DUP(0)              ; USER-������� �� ��� 㪠�뢠�� DI

   $STI    DW  TASK-7  ;               ; ���⮢�� ⠡��� PFA ᫮�� TASK
   $US     DW  XUP     ;               ; ���� user ������
   ;    ��६����
   $STK    DW  XS0     ;+6              ; SO   
   $RS     DW  XR0     ;+8              ; RO �⥪ �����⮢
           DW  XTIB    ;+10             ; �室��� ����
           DW  1Fh     ;+12             ; WIDTH 31 �㪢�
           DW  0       ;+14             ; WARNING
           DW  XDP     ;+16             ; ᫮���� FENCE (�����)
           DW  XDP     ;+18             ; DP
           DW  XVOC    ;+20             ; ᫮���� VOCL � ᫮�� Forth
   $BUF    DW  DSKBUF  ;+22             ; �࠭�� ���� FIRST
           DW  ENDBUF  ;+24 ��� 30Q     ; LIMIT

   ASSUME  CS:ARRAY, DS:ARRAY, ES:ARRAY, SS:STCK

   $INI      PROC    FAR
             JMP  ENT
   ; ** PRIMITIVES **

             HEAD    83h,'IN',311Q,INIT                  ;INI
   ENT:      MOV   CX, ARRAY
             MOV   DS, CX          ; ��⠭���� DX
             MOV   ES, CX
             MOV   AX, $STI        ; ����⠭������� ᫮���� (PFA ᫮�� TASK)
             LEA   SI, FORTH+6     ; ���� ���� ��宦����� � PFA forth
             MOV   [SI], AX        ; 
             MOV   SI, $BUF
             MOV   CX, 1739        ; ��⠭���� ���稪� 1730
   XXX:      MOV   WORD PTR [SI],0 ; ���㫥��� ���ᨢ��
             ADD   SI, 2
             LOOP  XXX

   ; INIT 'OFFSET, USE, PREV
             MOV   BX, $US          ; xup
             MOV   CX, $BUF         ; TO 'USE'
             MOV   [BX]+72Q,CX      ; USE ? ���� �����
             MOV   [BX]+74Q,CX      ; PREV ? ���� �����
             MOV   CX, 10           ; ��⠭���� ���稪� USER (14Q ���� �� 2 ����� 㦥)
             MOV   DI, $US          ; ������ ���� ������ USER
             ADD   DI, 6            ; ��祬� 6.... ? User ��६���� ��稭����� � 6 ����
             LEA   SI, $STK         ; ������ ��砫쭮�� ����
             ; ������塞 ��砫�� ���祭�� ��६����
   REP       MOVS  WORD PTR ES:[DI], WORD PTR DS:[SI] 
             MOV   BP, $RS          ; ��⠭���� ��砫쭮�� ���祭��
                                    ; 㪠��⥫� �⥪� �����⮢
                                    ; ���ᥪ����� � �������� TIB
             MOV   DI, $US
             MOV   WORD PTR [DI+32Q],7  ; ��⠭���� 梥� �뢮�� ⥪��
             MOV   WORD PTR [DI+42Q],0  ; ���� 䫠�� ����
             LEA   SI, GO$
             NEXT
             ; ����� ������樨 �몠 ���. 㪠��⥫� �� ��� � SI
   GO$:      DW SPSTO,DECIMA,FORTH,DEFIN, ONE,LOA, quit; ����㧪� ��ࢮ�� �࠭�
$INI      ENDP

; ���� ������ ������, �� Q ��室 �� �ணࠬ��
pause proc
        xor ax, ax
        int 16h ; AL = ASCII ᨬ��� (�᫨ AL=0, AH ᮤ�ন� ���७�� ��� ASCII )
                ; AH = ᪠����  ��� ���७�� ��� ASCII
        cmp ah, 10H ; ������ Q (quit)
        jnz @1
        mov ah,4Ch
        int 21h
    @1: ret
pause endp

; AX- ���祭�� ��� ���� � 16 ����
; di - ���� ��ப� ��� �뢮��
toHex PROC        
    mov cl,4            ; number of ASCII
P1: rol ax,4           ; 1 Nibble (start with highest byte)
    mov bl,al
    and bl,0Fh          ; only low-Nibble
    add bl,30h          ; convert to ASCII
    cmp bl,39h          ; above 9?
    jna short P2
    add bl,7            ; "A" to "F"
P2: mov [di],bl         ; store ASCII in buffer
    inc di              ; increase target address
    dec cl              ; decrease loop counter
    jnz P1              ; jump if cl is not equal 0 (zeroflag is not set)
    ret
toHex endP

; di- ���� ����
; cx - �᫮ ᨬ�����
; ���������� �஡����
blankBuffer proc
    push di
    @@:
    mov byte ptr [di], 32
    inc di
    loop @@
    pop di
    ret
blankBuffer endp 

; �뢮� ���� � ����� ᫮��
; AX- ���祭�� ����
printWORD proc
    ;local label m, m1
    push di
    push si
    push bx
    push ax
    mov di,OFFSET ASCII ; get the offset address
    mov cx, 20
    call blankBuffer
    call toHex
    inc di  ; �뢮� ⥪�� ��᫥ ����
    pop bx ; ���� ᫮�� CFA?
    ;mov al, byte ptr [bx-3] ; ��᫥���� ᨬ��� ᫮��
    SUB bx, 3   ; 
    mm:          ; �饬 ���� �����        
    dec bx
    CMP  BYTE PTR [bx],  0 
    JNS  mm     ; JUMP IF POSITIVE
    mov cx, [bx] ; ����� ᫮�� + ��直�  ��. ����
    and cx, 003Fh
    mmm1:
    inc bx
    mov al, byte ptr [bx]
    and al, 7Fh ;   ��᫥���� ᨬ��� 㢥��祭 �� 80h    
    mov [di],al
    inc di    
    loop mmm1
    ;-----------------------
    ; Print string
    ;-----------------------
    mov dx,OFFSET ASCII ; DOS 1+ WRITE STRING TO STANDARD OUTPUT
    mov ah,9            ; DS:DX->'$'-terminated string
    int 21h             ; maybe redirected under DOS 2+ for output to file
                        ; (using pipe character">") or output to printer
    pop bx
    pop si
    pop di
    ret
    ASCII DB "0000                ",0Dh,0Ah,"$" ; buffer for ASCII string              
printWORD endP

   ; BX - WP ��室���� ���� �ᯮ��塞��� ᫮�� 
   ; SI - IP-ॣ����    ������ ��࠭�����
   ; DI - 㪠��⥫� ������ USER
   ; BP - 㪠��⥫� �⥪� �����⮢
   ; SP - 㪠��⥫� �⥪� ��ࠬ��஢

             HEAD    87h,'EXECUT',305Q,EXEC              ; 
    ; � �⥪� ���� ���� CFA (�� PFA)
             POP   BX
             JMP  WORD PTR [ BX ]

             HEAD    83h,'LI',324Q,LIT                   ; LIT
             LODSW
             PUSH  AX
             NEXT

             HEAD    86h,'TERMO',316Q,TERMON             ; TERMON
    ; NumLock, ScrollLock, CapsLock, Ins. ����ﭨ� ��� ������ �����뢠����
    ; � ������� ������ BIOS � ��� ���� � ���ᠬ� 0000h:0417h � 0000h:0418h
             POP   AX
             PUSH  ES
             MOV   CX, 0
             MOV   ES, CX
             MOV   ES:417H,AX
             POP   ES
             NEXT

             HEAD    87h,'?BRANC',310Q,ZBRAN             ; ?BRANCH
    ; ���室, �᫨ 0 � �⥪� (FALSE)
             POP   AX
             CMP   AX, 0
             JE    CNT
             ADD   SI, 2 ; ��� ���室� �ய�᪠�� ᫥���饥 ᫮�� (���� ���室�)
             NEXT

             HEAD    86h,'BRANC',310Q,BRAN               ; BRANCH
    ; ����᫮��� ���室. SI 㪠�뢠�� �� �᫮ ������権,
    ; ����� �㦭� �ய�����
   CNT:      ADD   SI,  [SI]  ; si ᮤ�ন� �᫮ ������権,
                            ; ����� ����室��� �ய�����
             NEXT

             HEAD    84h,'(DO',251Q,XDO                  ; (DO)
             POP   AX  ; � �⥪ ������ ��砫쭮� ���祭�� 横��
             SUB   BP, 2
             POP   [BP] ; ����筮� ���祭�� 横��
             SUB   BP, 2
             MOV   WORD PTR  [BP],AX ; � �⥪ �����⮢ ��砫쭮� ���祭�� 横��
            ; BP-4 - ��砫쭮� ���祭�� 
            ; BP-2 - ����筮� ���祭�� 横��
            ; BP  �� �室� � ᫮��. RS ���� � ��஭� � ����訬� ���ᠬ� 
             NEXT

             HEAD    86h,'(LOOP',251Q,XLOOP              ; (LOOP)
   ; ���饭�� ������ 横�� LOOP � ����� ����  ��⢫����
             INC   WORD PTR  [BP] ; ��砫쭮� ���祭�� 㢥��稢���
   LOP:      MOV   AX,  [BP]    ; ������
             CMP   AX,  [BP+2]  ; �।�� 横��
             JL    CNT
   LV:       ADD   BP,  4 ; 㤠�塞 ��ࠬ���� 横��
             ADD   SI,  2 ; ���室 � ᫥����� ᫮��
             NEXT

             HEAD    87h,'(+LOOP',251Q,XPLOO             ; (+LOOP)
    ; n  ---   
             POP   AX
             ADD   [BP],   AX
             CMP   AX, 0
             JL    $LESS
             JMP   LOP
     $LESS:  MOV   CX, [BP]   ; ����� � ����⥫�묨 ���饭�ﬨ
             CMP   [BP]+2, CX
             JLE   LV
             JMP   CNT

             HEAD    86h,'(FIND',251Q,PFIND              ; PFIND
        ;  addr1 addr2 --- pfa b tf (ok) ������ ���᪠ 
   ; ���� ��ப�  NFA => PFA ����� TRUE/FALSE (!ॠ�쭮 �FA !)
             POP   AX       ; NFA ��᫥����� ᫮�� � context ᫮���
             POP   CX       ; addr1 ��ப� ��� ���᪠. ���� ���� ����� ��ࠧ�
             PUSH  BP       ; ��࠭���� ᮤ�ন���� ॣ���஢
             PUSH  SI       ; --
             PUSH  DI       ; --
             MOV   SI, CX   ; ���� ��ࠧ�
             SUB   BP, BP   ; 
             MOV   DI, AX   ; NFA  ��᫥����� ᫮�� � ᫮���
             MOV   DX,WORD PTR [SI] ; ����� ��ப� ���᪠ � ���� ᨬ���
             AND   DX, 77577Q ; 7F7f - ��� ����� ��⮢. ������� ��譨�
             CLD                    ; DF=0 (���।)
   FAST:     MOV   CX,WORD PTR [DI] ; 
             AND   CX, 77477Q ; ��� 7-�� � 6 ��� � ��ࢮ� ����
             CMP   DX, CX   ; �ࠢ��� ����� � ���� ᨬ���
             JE    SLOW     ; �᫨ ࠢ��, ����� �, �� �饬
   MATCH:    CMP   WORD PTR [DI], 0 ; �饬 ����� nfa 
             JS    $SIG         ; BPL 
             INC   DI           ; ᫥���騩 ᨬ��� � ᫮��
             JMP   MATCH
   $SIG:     ADD   DI, 2        ; ���室 � ���� LFA
             CMP   WORD PTR [DI],0  ; ᯨ᮪ ᫮� �����稫��
             JE    FAIL             ; LFA =0, ���� �� 㤠祭
             MOV   DI,WORD PTR [DI] ; ���室 � ��㣮�� ᫮�� � ᫮���
             JMP   FAST
   SLOW:     MOV   BP,WORD PTR [DI] ; ����� � ���� ᨬ��� ��������� ᫮��
             MOV   BX, SI           ; ���� ��ࠧ�
             JMP   SLOW1            
   $LOOP:    INC   BX               ; ��ॡ�� ᨬ�����
             MOV   AX,WORD PTR [BX]
             MOV   CX,WORD PTR [DI]
             AND   CX, 77777Q   ; 7FFFh
             CMP   AX, CX
             JNE   MATCH        ; �� ᮢ����, ���室 �� ��砫�
   SLOW1:    INC   DI           
             TEST  WORD PTR -1[DI],100000Q ; 8000h
             JZ    $LOOP        ; ���室, �᫨ 7 ��� ����� 0
             MOV   DX, BP       ; ����� ᫮��
             ADD   DI, 5        ; PFA ��������� ᫮��
             MOV   AX, DI       
             POP   DI           ; ����⠭������� ᮤ�ন���� ॣ���஢
             POP   SI
             POP   BP   
             SUB   AX, 2        ; CFA 
             PUSH  AX
             AND   DX, 377Q        ; FFh �뤥�塞 ���� ����� � ������
             PUSH  DX              ; � �⥪
             JMP   TRUE            ; ��⠭���� 䫠�� "�������"   
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
             CMP   CX, 9   ; �᫨ >9
             JLE   M09
             SUB   CX, 7
             CMP   CX, 10
             JL    FALSE
   M09:      CMP   CX, AX  ; �᫨ �� ����� BASE, � �訡��
             JGE   FALSE
             PUSH  CX      ; ������ ���� � �⥪
             JMP   TRUE    ; "�ᯥ��" ��室

   ;         **  �⠭����� ᫮��  **
   ;         **  �᫮��� �������  **

             HEAD    82h,'0',275Q,ZEQU                   ; 0=
             POP   AX
             CMP   AX,  0
             JE    TRUE
   FALSE:    SUB   AX,  AX
   PUT:      PUSH  AX
             NEXT
   TRUE:     MOV   AX,  1
             JMP   PUT

             HEAD    82h,'0',276Q,ZGRET                  ; 0>
             POP   AX
             CMP   AX, 0
             JG    TRUE
             JMP   FALSE

             HEAD    82h,'0',274Q,ZLESS                  ; 0<
             POP   AX
             CMP   AX, 0
             JS    TRUE         ; �᫨ �����
             JMP   FALSE

             HEAD    81h,,275Q,EQUAL                     ; =
             POP   AX
             POP   CX
             CMP   CX, AX
             JE    TRUE
             JMP   FALSE

             HEAD    82h,'U',274Q,ULESS                  ; U<
             POP   AX
             POP   CX
             CMP   CX, AX
             JB    TRUE           ; ��� �ᥫ ��� �����
             JMP   FALSE

             HEAD    81h,,274Q,LESS                      ; <
             POP   AX
             POP   CX
             CMP   AX, CX
             JG    TRUE
             JMP   FALSE

             HEAD    81h,,276Q,GREAT                     ; >
             POP   AX
             POP   CX
             CMP   AX, CX
	         JL    TRUE
             JMP   FALSE

            HEAD     84h,'EVE', 'N'+80h, $EVEN           ; EVEN
    ; �஢�ઠ �� �⭮���
            pop ax 
            test ax, 1 ; �஢��塞 ����訩 ���
            jz true ; �᫨ ���=0, � �᫮ �⭮�
            jmp false

   ;         ******************

             HEAD    84h,'ENC',314Q,ENCL                 ; ENCLOSE
    ; addr1 c -- addr1 n1 n2 n3
             POP   AX         ; ࠧ����⥫�
             POP   CX         ; ��砫�� ����
             MOV   BX, CX
   A:        CMP   BYTE PTR  [BX], AL ; ��室 ࠧ����⥫�� � ��砫�
             JNE   NOTEQ
   AAA1:     INC   BX
             JMP   A
   NOTEQ:    CMP   BYTE PTR  [BX], 15Q ; ��室 ��ॢ��� ��ப�
             JE    AAA1
             CMP   BYTE PTR  [BX], 12Q
             JE    AAA1                 ; ��室 ��ॢ��� ��ப�
             MOV   DX, BX               ; ��砫� ���ᥬ�
             PUSH  DX
   AA:       CMP   BYTE PTR  [BX],  0
             JE    ZZZ                  ; �᫨ ���
             CMP   BYTE PTR  [BX], AL   ; �� ���, �饬 ����� ���ᥬ�
             JE    EQW
             INC   BX
             JMP   AA
   EQW:      MOV   AX, BX
             SUB   BX, DX
             PUSH  BX
             SUB   AX, CX
             INC   AX
             PUSH  AX
             NEXT               ; ��室 �� ᫮��

   ZZZ:      CMP   BX, DX
             JNE   EQW
             INC   BX
             JMP   EQW

    ;         ** ��ᯫ�� **

             HEAD    84h,'PAG',305Q,$PAGE                ; PAGE
    ; ��⠭���� ��⨢��� ��࠭��� ( PAGE --)
             POP   AX
    ; �室:  AL = ����� ��࠭��� (����設�⢮ �ணࠬ� �ᯮ���� ��࠭��� 0)             
             MOV   AH, 5
             INT   10h
             NEXT

             HEAD    83h,'PI',330Q,PIX                   ; PIX
    ; COLCOD ROW COLUMN -->  -    ������ ����᪮� �窨             
             POP   CX                  ; �������
             POP   BX                  ; ��ப�
             POP   AX                  ; ��� 梥⭮��
             PUSH  DX                  ; ��࠭���� DX             
             MOV   DX, BX              ; BH = ����� ����� ��࠭��� ??? ���
             SUB   DH, DH
             push   ax             
             MOV   AH, 0Fh             ; �⥭�� ⥪�饩 ��࠭���
             INT   10h                 ; � BH
             pop    ax                 ; ��� 梥⭮��
             MOV   AH, 0Ch             ; 
             INT   10h                 ; ������ ����᪮� �窨
             POP   DX                  ; ����⠭������� DX
             NEXT

             HEAD    84h,'MOD','A'+80h,MODA                 ; MODA
    ; ��⠭���� ०���. ( � --> - )
             POP   AX
             SUB   AH, AH       ; 00H ���. ����� ०��. ������ �࠭
                                ;  ��⠭����� ���� BIOS, ��⠭����� ०��.
             INT    10h
             NEXT

             HEAD    83h,'EM',311Q,EMI$                  ; EMI
             POP   CX              ; ��᫮ ᨬ�����
             POP   AX              ; ������
             PUSH  CX              ; ���࠭���� ᮤ�ন���� CX
             PUSH  AX              ; ���࠭���� ᮤ�ন���� A�
             MOV   BX, [DI+32Q]    ; ��⠭���� ��ਡ��
             MOV   AH, 0Fh         ; �⥭�� ⥪�饩 ��࠭���
             INT   10h             ; � BH
             POP   AX              ; ����⠭������� ᮤ�ন���� AX
             MOV   AH, 9           ; ������ ��ப� ᨬ�����
             INT   10h
             MOV   AH, 3           ; �⥭�� ��������� �����
             INT   10h
             POP   CX
             ADD   DL, CL          ; DH,DL = ��ப�, ������� (���� �� 0)
             MOV   AH, 2           ; ��⠭���� ��������� �����
   $EM:      INT   10h
             CMP   WORD PTR [DI+42Q], 0  ; ��� 䫠�� ����
             JNE   PRINT
   OK:       NEXT

             HEAD    84h,'EMI',324Q,EMIT,$EMIT           ; EMIT
    ; �뢮� ⥪�� ��� ��ਡ�⮢ (�� 㬮�砭��)             
   $EMIT     LABEL   FAR
             POP   AX
   ENT$:     PUSH  AX
             MOV   AH, 15       ; �⥭�� ⥪�饩 ��࠭���
             INT   10h
             POP   AX
             MOV   AH, 14       ;
             JMP   $EM

   PRINT:    MOV   DX, 0   ; ��⠭���� ����� �ਭ��
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

             HEAD    82h,'R',303Q,RC                     ; RC
             MOV   AX, 13
             JMP   ENT$

             HEAD    82h,'I',314Q,IL                     ; BELL
             MOV   AX, 7
             JMP   ENT$

             HEAD    84h,'PRI',316Q,PRIN             ; PRINT-FLAG
             INC   WORD PTR  [DI+42Q]
             MOV   DX,  0       ; ��⠭���� ����� �ਭ��
             MOV   AH,  1       ; ���樠������ �ਭ��
             INT   17H
             TEST  AH,  29h
             JNE   ERR4
             NEXT

             HEAD    83h,'TT',331Q,TTY              ; TERMI-FLAG
   TYPE$:    MOV   WORD PTR [DI+42Q],0
             NEXT

             HEAD    83h,'SC',314Q,SCL                   ; SCL
   ; SCREEN CLEAR
             MOV   CX, 2048     ; ����㧪� ���稪�
             MOV   AH, 15
             INT   10h           ; ��⠭���� ⥪�饩 ��࠭���
             SUB   DX, DX       ;  DH,DL = ��ப�, ������� (���� �� 0)
             MOV   AH, 2        ; ����� � ��室��� ���������
             INT   10h
             MOV   BL, 7        ; ��ਡ��
    ; 09H ����� ᨬ���/��ਡ�� � ⥪�饩 ����樨 �����
   CLEAR:    MOV   AX, 0920H    ; ���⪠ �࠭� AL = �����뢠��� ᨬ���
             INT   10h
             NEXT

             HEAD    83h,'FI',330Q,FIX                   ; FIX
   ; ����樮��஢���� �����: COL ROW FIX
             MOV   AH, 0Fh
             INT   10h      ; ������ ⥪�饣� ����� ��࠭��� � BX
             POP   DX
             MOV   DH, DL   ; ��ப�
             POP   AX

             MOV   DL, AL   ; �⮫���
             MOV   AH, 2    ; ���. ������ �����. ��⠭����
                            ; �� ��ப� 25 ������ ����� ��������.
             INT   10h      ; ������ ��������� �����
             NEXT

             HEAD    84h,'DSP',314Q,DSPL                 ; DSPL
   ; LOAD GRAFBUFFER (b adr DSPL)
    ; �����뢠�� ���� � ������� ������
             POP   BX  ; ����
             POP   AX  ; ����
             PUSH  ES  ; ��࠭���� ॣ���� ᥣ����
             MOV   CX, 0B000H ; GRAFBUF
             MOV   ES, CX
             MOV   BYTE PTR ES:[BX], AL
             POP   ES
             NEXT

   ;         ** ��ନ��� **

             HEAD    83h,'KE',331Q,KEY                   ; KEY
        ; ���� (�������) ᫥������ ������� �������
        ; ��室: AL = ASCII ᨬ��� (�᫨ AL=0, AH ᮤ�ন� ���७�� ��� ASCII )
        ; AH = ᪠����  ��� ���७�� ��� ASCII
             SUB   AH, AH
             INT   16h
             SUB   AH, AH
             PUSH  AX
             NEXT

             HEAD    86h,'EXPEC',324Q,EXPE               ; EXPECT
        ; adr count -> 
             MOV   AH, 0AH              ;  ���� ��ப� � ����
             POP   CX                   ; ��᫮ ᨬ�����
             POP   BX                   ; ���� ���� SS
             MOV   BYTE PTR [BX],  CL   ; ���뫪� ���������� �᫠
             MOV   DX, BX
             INT   21h

             MOV   AL, BYTE PTR [BX+1]  ; 䠪��᪨ ������� ᨬ�����
             SUB   AH, AH               ; 
             ADD   BX, AX               ; ���� ���� ��ப�
             MOV   WORD PTR [BX+2],0    ; +2, �.�. � ��砫� ��ப� ��� ����� 
                                        ; � �᫮ ��������� ᨬ�����
             NEXT

             HEAD    85h,'?TER',244Q,?TER$               ; ?TER$
             PUSH  ES
             SUB   CX, CX
             MOV   ES, CX
             OR    BYTE PTR ES:[417H],  40Q
   TER:      MOV   AH, 1    ; �஢���� ��⮢����� ᨬ���� (� �������� ���, �᫨ ⠪)
                            ; ��室: ZF = 1 �᫨ ᨬ��� �� ��⮢.
                            ; ZF = 0 �᫨ ᨬ��� ��⮢.
                            ; AX = ��� ��� ����㭪樨 00H (�� ᨬ��� ����� ��
                            ; 㤠����� �� ��।�).
             INT   16h
             JZ    TER
             SUB   AH, AH   ; ���� (�������) ᫥������ ������� �������
             INT   16h
             AND   BYTE PTR ES:[417H],337Q  ; ���� 'NUM LOCK'
             POP   ES              ; ����⠭������� ES
             PUSH  AX              ; ������ ᨬ����
             NEXT

   ; ** ����/�뢮� **

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

   ;         ** ��䬥⨪� **

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
             POP   CX          ; ����⥫�
             POP   DX
             POP   AX
             DIV   CX
             PUSH  DX          ; ���⮪
             PUSH  AX          ; ���뫪�  १����
             NEXT

             HEAD    82h,'M',252Q,MSTAR                  ; M*
             POP   AX
             POP   CX
             IMUL  CX
             PUSH  AX
             PUSH  DX
             NEXT

             HEAD     86h,'DMINU',323Q,DMINU             ; DMINUS
   ; ��������� ����� �᫠ ������� �����
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
            POP   CX          ; �������
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

            HEAD     85h,'MINU',323Q,MINUS               ; MINUS
            POP  AX
            NEG  AX
            PUSH AX
            NEXT

            HEAD     84h,'SWA',302Q,SWAB                 ; SWAB
        ; ����� ���⠬� ᫮�� � �⥪�
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

            HEAD     84h,'S-#',304Q,STOD                 ; S->D ; sds S->
            POP  AX
            PUSH AX
            MOV  CX, DX           ; ���࠭���� ᮤ�ন���� DX
            CWD                   ; sign bit AX to DX
            PUSH  DX
            MOV  DX, CX           ; ����⠭������� DX
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
        ; ���祭�� ⥪�饣� 㪠��⥫� ॣ���� SP � �⥪
            MOV  AX, SP
            JMP  ENDA

            HEAD     83h,'SP',241Q,SPSTO                 ; SP!
            MOV  SP, [DI+6]                             ; 80h
            NEXT

            HEAD     83h,'RP',241Q,RPSTO                 ; RP!
            MOV  BP, $RS                                ; ccch
            NEXT

            HEAD     82h,';',323Q,SEMI                   ; ;S
        ; ���室 �� ᫮�� �� ����� � �⥪� ������ ������
        ; ᫮��,����� �����稢����� ᫮�� �� ���
            MOV  SI, [BP] ; � RS �࠭���� ���� ᫥���饣� ᫮��, 
                        ; �� ���室� �� �ᯮ������ ᫮��, ���஥ �����蠥���
            ADD  BP, 2 ; 㤠�塞 �� RS
            NEXT ;  ������ �� �।��饥 ᫮��

   ;        ** �⥪ �����⮢ **

            HEAD     85h, 'LEAV',305Q,LEAV                ; LEAVE
        ; ���� ᬮ���� ����� � �࠭����� ���ᮢ 
        ; ��ࠢ������ ���祭�� ������ � �।���     
	        MOV  AX, [BP]
            MOV  [BP+2], AX 
            NEXT

            HEAD     82h, 62,322Q,TOR                    ; >R sds
        ; ��襬 � �⥪ �����⮢
        ; ᫮�� �� �⥪� ������
            SUB  BP, 2 ; ���﫨 �祩�� 
            POP  [BP]   ; ����ᠫ� ���祭�� 
            NEXT

	        HEAD     82h, 'R',276Q,FROMR                  ; R>
        ; � �⥪ ������ ᫮�� �� ����� �� �⥪� �����⮢
	        PUSH [BP] ; � �⥪ ����ᠫ�
            ADD  BP, 2 ; �ࠫ� 
            NEXT

            HEAD     81h,,311Q,I                         ; I R R@
        ; ������� ���孥� �᫮ �� �⥪� �����⮢
        ; � �����뢠� � �⥪ ��ࠬ��஢
  RR$:      PUSH [BP]
  Z$:       NEXT

            HEAD     81h,,322Q,R                         ; R
            JMP  RR$

            HEAD     82h,'I',247Q,SRP                    ; I'
        ; ������� ��஥ ᢥ��� �᫮ �� �⥪� �����⮢ 
        ; � �����뢠�� ��� � �⥪ ��ࠬ��஢
            PUSH [BP+2]
            JMP  Z$

            HEAD     83h,'LE',326Q,LEV                   ; LEV
        ; �������� R> DROP :) ⮫쪮 ����॥
        ; ��� ��室� �� interpret
            ADD  BP, 2
            NEXT

            ;** ����樨 � �⥪�� ��ࠬ��஢ **

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
        ; DUP �᫨ � �⥪� �� 0
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

            HEAD     85h,'2DRO',320Q,DDROP               ; 2DROP
   DRO:     ADD  SP, 4
            NEXT

            HEAD     84h,'DRO',320Q,DROP                 ; DROP
   DRP:     ADD  SP, 2
            NEXT

   ;        ** ����� � ������� **

            HEAD     85h,'CMOV',305Q,CMOV               ; CMOVE
        ; src dst cnt -> ��७�� ������ �����
            POP  CX         ; ���稪
            CMP  CX,  0
            JLE  DRO        ; ��室, c ��ᮬ ���� ��ࠬ��஢ � �⥪�
            MOV  AX,  DI     ; ���࠭���� ᮤ�ন���� DI,SI
            MOV  BX,  SI
            POP  DI          ; �㤠
            POP  SI          ; ��㤠
   REP      MOVS  BYTE PTR ES:[DI], BYTE PTR DS:[SI]
            MOV  DI, AX      ; ����⠭������� DI,SI
            MOV  SI, BX
            NEXT

            HEAD     84h,'FIL',314Q,FILL                 ; FILL
    ; addr cnt chr -> ���������� ������ �����
            POP  AX      ; ������
   FLL:     POP  CX      ; ���稪 ᨬ�����
            CMP  CX, 0
            JLE  DRP     ;
            POP  BX   
   $REPE:   MOV  BYTE PTR [BX],  AL
            INC  BX
            LOOP $REPE
            NEXT

            HEAD     85h,'ERAS',305Q,ERASE               ; ERASE
        ; ���������� �㫥�
            SUB  AX, AX
            JMP  FLL

            HEAD     86h,'BLANK',323Q,BLANK              ; BLANKS
        ; ����������  �஡����
            MOV  AX, 32
            JMP  FLL

            HEAD     84h,'HOL',304Q,HOLD                 ; HOLD
        ; ������ � ⥪���� �祩�� ��室���� ���� ᨬ���,
        ; ��� ���ண� � �⥪�. ������ �ᯮ�짮������ ����� <# � #>
        ; 㬥��蠥� �� 1 ���祭�� 㪠��⥫� HLD.
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

            HEAD     84h,'TOG',314Q,TOGL                 ; TOGGLE
   ; ���-���� ��᪠ -> XOR � ���� �����
            POP  CX         ; ��᪠
            POP  BX
            XOR  BYTE PTR [BX],CL
            NEXT

            HEAD     81h,,300Q,AT                        ; @
        ; addr -> n    
            POP  BX
            PUSH [BX]
            NEXT

            HEAD     82h,'C',300Q,CAT                    ; C@
        ; ��������� ���� ���ଠ樨 �� �祩��, 
        ; ���� ���ன ��室���� � �⥪�
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
    ; ����஫����� ��࠭���� 㪠��⥫� �⥪� ��ࠬ��஢ 
    ; � ����� ������樨 ᫮��
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
            ; �������� ���।/����� ����� ����� ��६����� �����
            POP  CX     ; DELTA
            POP  BX     ; ���� ��ப�
    TRV:    ADD  BX, CX
            CMP  BYTE PTR [BX],  0
            JNS  TRV    ; JUMP IF POSITIVE
            PUSH BX
            NEXT

            HEAD     301Q,,333Q,LBRAC                     ; [
            ; �४�饭�� ������., ��砫� �ᯮ��. (���㫥��� STATE)
            MOV  WORD PTR [DI+54Q],0
            NEXT

            HEAD     301Q,,335Q,RBRAC                     ; ]
            MOV  WORD PTR [DI+54Q],300Q   ; ��砫� �������樨
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
        ; � �⥪ ������ NFA  ��᫥����� ��।�������� ᫮�� 
        ; � current ᫮���
            MOV  BX, [DI+52Q] 
            PUSH [BX]
            NEXT

            HEAD     86h,'-TRAI',314Q,DTRAI              ; -TRAIL
    ; ��� n1 --> ��� n2 ���ࠥ� �஡��� � ���� ��ப�
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
            POP  CX                 ; �᫮ ᨬ�����
            POP  BX                 ; ��ப�
   $COMP:   CMP  BYTE PTR [BX],  61h ; a
            JL   OFLIM
            CMP  BYTE PTR [BX],  7Ah ; z
            JG   OFLIM
            AND  WORD PTR [BX], 177737Q ; FFDF
   OFLIM:   INC  BX
            LOOP $COMP
            NEXT

            HEAD     213Q,'DEFINITION',323Q,DEFIN      ; DEFINITIONS
    ; ���⥪��� ᫮���� �⠭������ ⥪�騬, �� ��᫥���騥 
    ; ���ᠭ�� �易�� � �⨬ ᫮��६            
            MOV  AX, [DI+50Q]       ; context
            MOV  [DI+52Q],AX        ; current
            NEXT

            HEAD     84h,'+BU',306Q,PBUF                 ; +BUF
    ; 
            MOV  BX, SP         ; 
            ADD  SS:[BX],1028   ; ���� ᫥���饣� ����
            MOV  AX, SS:[BX]
            CMP  [DI+30Q],AX    ; LIMIT
            JNE  PB             ; 㯥૨�� � ���� �����, ����� ���� - ��᫥����
            MOV  CX, [DI+26Q]   ; FIRST
            MOV  SS:[BX],CX     ; ���室�� �� ���� ����  
   PB:      PUSH SS:[BX]        ; ����祭�� ���� ���� � �⥪
            MOV  CX, [DI+74Q]   ; prev
            SUB  SS:[BX-2],CX   ; �⥪ ���� ����. BX-2 ᥩ��  ���設� �⥪�
                                ; �᫨ 0, ����� ���� ᮢ������ � ���ᮬ prev 
            NEXT

            HEAD     86h,'UPDAT',305Q,UPDAT              ; UPDATE
            MOV  BX, [DI+74Q]   ; prev buffer
            OR BX, BX           ; �᫨ 0, ���� ���⮩
            jz $upd
            OR  WORD PTR [BX],   100000Q  ; �⠢�� ���
    $upd:   NEXT

            HEAD     81h,,330Q,X                         ; X
    ; ��� ��� ��࠭���� ����
            POP  BX
            AND WORD PTR [BX],   77777Q   ;
            PUSH [BX]
            NEXT

   ;        ** ��ࠢ���騥 ᫮�� **

            HEAD     301Q,,272Q,COLON,$COL                ; :
        ; ᫮�� ��� ᮧ����� ����� ᫮� �� ����
            DW QEXEC,SCSP,CURR,AT,CONT,STORE,CREAT
            DW RBRAC,PSCOD ; ��᫥ �⮣� ᫮�� SI 㪠�뢠�� �� ᫥���騩 ���,
                           ; ����, ���ண� ������� � CFA ᮧ��������� ᫮��
   $COL     LABEL   FAR ; ��� ��� �ᯮ������ ᫮� �� ��� �� �⮣� ��室����
                        ; �㭪�� ��������
            ADD  BP, -2 ; १�ࢨ�㥬 ���� � �⥪� �����⮢
            ADD  BX, 2  ; BX 㪠�뢠�� �� CFA ����� �� $COL
                        ; BX+2 �㤥� 㪠�뢠�� �� ���� QEXEC
            MOV  [BP], SI ; ��࠭塞 ⥪�騩 㪠��⥫� IP
            MOV  SI, BX ; �ᯮ��塞 ᫮�� QEXEC
            NEXT

            HEAD     301Q,,273Q,SMI,$COL                  ; ;
        ; ᫮�� ��� �����襭�� ����� ᫮� �� ����
            DW QCSP,COMP,SEMI,SMUG,LBRAC,SEMI

            HEAD     88h,'CONSTAN',324Q,CON,$COL         ; CONSTANT
            DW CREAT,SMUG,COMMA,PSCOD                    ;
   $CON     LABEL   FAR
            ADD  BX, 2 ; �������筮 ��६�����
            PUSH [BX]  ; ����� ���� ��襬 ���祭�� �� �⮬� ����� PFA
            NEXT

            HEAD     88h, 'VARIABL',305Q,VAR,$COL        ; VARIABLE
            DW CON,PSCOD
   $VAR     LABEL   FAR
            ADD  BX, 2  ; BX 㪠�뢠�� �� CFA ($COL)
                        ; BX+2 �ய�᪠�� ���� CFA
            PUSH BX     ; � BX ��室���� ���� ��६����� PFA (CON)
            NEXT

            HEAD     84h,'USE',322Q,USER, $COL           ; USER
            DW CON,PSCOD
   $USE     LABEL   FAR
            ADD  BX, 2
            MOV  AX, [BX] ; ��६ ᬥ饭�� �� PFA
            ADD  AX, DI  ; ����塞 ᬥ饭��
            PUSH AX ; ����祭�� ���� � �⥪
            NEXT

            HEAD     85h,'DOES',276Q,DOES,$COL           ; DOES>
    ; ������ � ���� PFA ᫮�� � ᫮��� ���� ����,
    ; ����� ᫥��� �� DOES>. � CFA ������ ���� ����,
    ; ᫥���饣� �� PSCOD, �.�. $DOE
            DW  FROMR,LATES,PFA,STORE,PSCOD
   $DOE     LABEL   FAR ; ����� �ᯮ������ ⮫쪮 � FORTH
            SUB  BP,  2   ; १�ࢨ�㥬 ���� � RS
            MOV  [BP], SI ; ��࠭塞 SI ���� ᫥���饣� ᫮��
            ADD  BX, 2    ; BX+2 �� PFA �ᯮ��塞��� ᫮�� (FORTH)
            MOV  SI, [BX] ; ⠬ ����� ���� ᫮�� DOVOC
            ADD  BX, 2    ; ���� ��ࠬ��� PFA+2 ��� DOVOC (120201Q)
            PUSH BX       ; � �⥪
            NEXT          ; �ᯮ������ ᫮�� DOVOC (�� ����� PFA)   

            HEAD     83h,'BY','E'+80h,BYE                  ; BYE
            mov ah, 4ch
            int 21h

   ;        ** ����⠭�� **

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
            DW 1024 ; ����� ���� 

            ;** USER-��६���� **

            HEAD     82h,'S',260Q,SZERO,$USE             ; SO
            DW 6 ; �����⥫� ��砫� �⥪� ��ࠬ��஢
 
            HEAD     82h,'R',260Q,RZERO,$USE             ; RO
            DW 8  ; �����⥫� ��砫� �⥪� ������

            HEAD     83h, 'TI',302Q,TIB,$USE             ; TIB
            DW 12Q  ;�室��� ���� �ନ���� 10

            HEAD     85h,'WIDT',310Q,$WIDTH,$USE         ; WIDTH
            DW 14Q ; ��।���� ���ᨬ����� ����� ����� � ᫮���

            HEAD     87h,'WARNIN',307Q,$WARN,$USE        ; WARNING            
            DW 16Q  ;  �� 0 ⮫쪮 ��� �訡�� �뢮�����

            HEAD     85h,'FENC',305Q,FENCE,$USE          ; FENCE
            DW 20Q ; FENCE 㪠�뢠�� ���孨� �ࠩ �������� ᫮����
            ; FENCE  (��ࠤ�) �㦨�  ���  �����  �������� ᫮����
            ; �� ��࠭�� � ������� ������ FORGET,  㪠�뢠�� ����,
            ; �।�����騩 ��ࢮ�  ᢮������  �祩��  � ᫮��� �ࠧ�
            ; ��᫥ ����㧪� ��⥬� ����, �.�. �� �⮬ FENCE @ ࠢ�� HERE-2

            HEAD     82h,'D',320Q,$DP,$USE               ; DP
            DW 22Q ; 㪠�뢠�� �� ����� ᢮������ �祩�� ᫮���� (DP @ = HERE)

            HEAD     84h,'VOC',314Q,VOCL,$USE            ; VOCL
            ; �࠭���� ���� XVOC 
            DW 24Q ; ��६�����  �裡 ���⥪���� ᫮��३.

            HEAD     85h,'FIRS',324Q,FIRST,$USE          ; FIRST
            DW 26Q ; ���� ��ࢮ�� ���� �࠭��� ���஢

            HEAD     85h,'LIMI',324Q,LIMIT,$USE          ; LIMIT
            DW 30Q ; 㪠��⥫� ���� �࠭��� ���஢ � ������� ��㣨�

            HEAD     83h,'AT',322Q,ATR,$USE              ; ATR
            DW 32Q          ;��ਡ��

            HEAD     82h,'P',307Q,PG,$USE                ; PG
            DW 34Q          ; ������ ��࠭��

            HEAD     83h,'BL',313Q,BLK,$USE              ; BLK
            DW 36Q ; 0  ���  �室����  ����  �  ������ �࠭�
                   ; � ��⨢���  ��砥

            HEAD     82h,'I',316Q,$IN,$USE               ; IN
            DW 40Q ; ����७���   㪠��⥫�   �室����   ����

            HEAD     83h,'PN',324Q,PNT,$USE              ; PNT
            DW 42Q          ;����-����

            HEAD     83h,'SC',322Q,SCR,$USE              ; SCR
            DW 44Q ; ��� �࠭���� ⥪�饣� ���祭�� ����� �࠭�
                    ; ⮫쪮 � list

            HEAD     86h,'OFFSE',324Q,OFSET,$USE        ; OFFSET
            DW 46Q ; ���������᪨� ᮮ�饭�� ���筮 ࠧ�������
                ; �� �࠭�� 4 � 5. �᫨ �� �� ⠪, ������ ����� ����,
                ; ������ ���祭�� OFFSET ��� ��ࠢ�� �᫮, ���饥
                ; ��। OFFSET � ���ᠭ�� MESSAGE

            HEAD     87h,'CONTEX',324Q,CONT,$USE         ; CONTEXT
    ; �ॡ뢠��� � ⮬  ��� ����  ᫮���  ����஫������ ��⥬��� ��६�����
    ; CONTEXT,  � ���ன �࠭����  ��뫪�  ��  ����  ��᫥�����  ᫮��,
    ; ���ᠭ����  �  ������ (���⥪�⭮�) ᫮���.
            DW 50Q ; �����⥫�, � ������ ᫮���� ᫥��� ��稭��� ��ᬮ��
                   ; �� ������樨

            HEAD    87h, 'CURREN',324Q,CURR,$USE        ; CURRENT
            DW 52Q  ; �࠭��� ��뫪� � ᫮�� ������� �� ��᫥���� ᫮��,
                    ; ���ᠭ��� � ⥪�饬 ������. �祢����, ��
                    ; ⥪�騩 ������� ����� �� ᮢ������ � ���⥪���
                    ; �� �� ���� latest 

            HEAD     85h,'STAT',305Q,STATE,$USE          ; STATE
            DW 54Q  ; 0=> �ᯮ������

            HEAD     84h,'BAS',305Q,BASE,$USE            ; BASE
            DW 56Q  ; ��⥬� ���᫥���

            HEAD     83h,'DP',314Q,DPL,$USE              ; DPL
            DW 60Q ; DPL ��।���� ��������� �����筮� ����⮩ (�� �室���
                   ; �।�⠢����� �� �窠), ��� �ᥫ �����୮� ����� DPL=-1.

            HEAD     83h,'CS',320Q,CSP,$USE              ; CSP
            DW 64Q

            HEAD     82h,'R',243Q,RNUM,$USE              ; R#
            DW 66Q ; 㪠��⥫�  ���������  �����  ��  �࠭�

            HEAD     83h,'HL',304Q,HLD,$USE              ; HLD
            DW 70Q ; ����� ���� 㪠��⥫�� ����樨 
                   ; � ��室��� ���� (���筮 PAD)

            HEAD     83h,'US',305Q,USE,$USE              ; USE
            DW 72Q ;

            HEAD     84h,'PRE',326Q,PREV,$USE            ; PREV
            DW 74Q ; ���� �࠭���� �����

            HEAD     83h,'$E',330Q,$EX,$USE              ; EXP
            DW 76Q  ; 楫��᫥���� ���祭��  ���浪�  �᫠,  
                    ; �����  ᫥���  �� �ਧ����� �

            HEAD     83h,'ER',302Q,ERB,$USE              ; ERB
            DW 100Q ; 64d 40h
            ; �᫨ ERB=0,  ERROR  ࠡ�⠥�  �����  ��ࠧ��,  � ��⨢��� ��砥
            ; ��६����� ERB ��������,  � �室 ��  �ணࠬ��  �  ����  �१  QUIT
            ; ����������.

        ;** ����� ��᮪��� �஢�� **

            HEAD     85h,'?TER',315Q,?TERM,$COL          ; ?TERM
    ; �뢮� � �⥪ ���� ᨬ���� �� ���� ���������� ��� �������� ������
            DW ?TER$,LIT,377Q,$AND,SEMI

            HEAD     82h,'C',322Q,CR,$COL                ; CR
    ; �뢮� ᨬ����� 0D 0A
            DW LIT,15Q,EMIT,LIT,12Q,EMIT,SEMI

            HEAD     81h,,254Q,COMMA,$COL                ; ,
    ; �  ᢮������ �祩�� ᫮���� �����塞 �᫮ �� �⥪� �
    ;  �������� ��� �祩�� (ᬥ頥� 㪠��⥫� here)
            DW HERE,STORE,TWO,ALLOT,SEMI

            HEAD     82h,'C',254Q,CCOM,$COL              ; C,
            DW HERE,CSTOR,ONE,ALLOT,SEMI

            HEAD      85h,'SPAC',305Q,SPACE,$COL         ; SPACE
            DW BLAN,EMIT,SEMI

             HEAD    83h,'PF','A'+80h,PFA,$COL           ; PFA
    ; NFA -> PFA
             DW  ONE,TRAV,LIT,5,PLUS,SEMI

             HEAD    83h,'?E',322Q,QERR,$COL             ; ?ER
    ; f errorcode -> �᫨ f=0, � ��� �訡��
             DW  SWAP,ZBRAN,TTT-$,ERROR,SEMI
   TTT:      DW  DROP,SEMI

             HEAD    85h,'?COM',320Q,QCOMP,$COL          ; ?COMP
        ; �஢�ઠ ०��� ࠡ���. ��⥬� � ०��� �������樨?
             DW  STATE,AT,ZEQU,LIT,21Q,QERR,SEMI        ; 17 

             HEAD    85h,'?EXE',303Q,QEXEC,$COL          ; ?EXEC
        ; �஢�ઠ ०��� �ᯮ������    0=> �ᯮ������ 
             DW  STATE,AT,LIT,22Q,QERR,SEMI             ; 18

             HEAD    85h,'?PAI',322Q,QPAIR,$COL          ; ?PAIR
             DW  SUBB,LIT,23Q,QERR,SEMI

             HEAD    84h,'?CS',320Q,QCSP,$COL            ; ?CSP
        ; ����஫����� ��࠭���� 㪠��⥫� 
        ; �⥪� ��ࠬ��஢ � ����� ������樨 ᫮��
        ; ⥪�饥 � ��࠭����� ���祭�� �⥪� ������ ���� ࠢ��
             DW  SPAT,CSP,AT,SUBB,LIT,24Q,QERR,SEMI

             HEAD    85h,'?LOA',304Q,QLOAD,$COL          ; ?LOAD
        ; �訡��, �᫨ �� ���६� ����㧪�
             DW  BLK,AT,ZEQU,LIT,26Q,QERR,SEMI      ; 22

             HEAD    87h,'COMPIL',305Q,COMP,$COL         ; COMPILE
    ; ��������� �ᯮ���⥫쭮�� ����, ᫥���饣� �� �����஬
             DW  QCOMP,I,FROMR,TWOP,TOR,AT,COMMA,SEMI

             HEAD    84h,'SMU',307Q,SMUG,$COL            ; SMUDGE
        ; ���뢠�� 5-� ��� ��ࢮ�� ����  ���ᠭ��  �  ⥬  ᠬ�
        ; ������   ������   ᫮��  ������ࠢ��  童���  ⥪�饣�  ᫮����
             DW  LATES,BLAN,TOGL,SEMI

             HEAD    87h,'(;CODE',251Q,PSCOD,$COL        ; (;CODE)
        ; ���� �� �⥪� �����⮢ (⠬ ��室���� ���� ��砫� ���� �� ��ᥬ����)
        ; ��襬 � CFA ��᫥����� ��।�������� ᫮��  
        ; ⠪�� ��ࠧ�� � CFA �㤥� ᢮� ��� �������� �� ��ᥬ����
             DW  FROMR,LATES,PFA,CFA,STORE,SEMI

             HEAD    87h,'#BUILD',323Q,BUILD,$COL        ; <BUILDS ; 
        ; �ନ��� � ᫮��� ���ᠭ�� ����⠭�� ࠢ��� 0 � ������ XXX
             DW  ZERO,CON,SEMI

             HEAD    85h,'COUN',324Q,COUNT,$COL          ; COUNT
        ; addr1 --- addr2 n
        ; ���� HERE+1 (�� ���� ��ࢮ�� ���� ᫮��)
        ; � �᫮ ᨬ����� �  ᫮��  (HERE  C@)
             DW  DUBL           ; addr1 addr1
             DW  ONEP,SWAP      ; addr1+1 addr1
             DW  CAT,SEMI       ; addr1+1 u8(addr1)   

             HEAD    84h,'TYP',305Q,$TYPE,$COL           ; TYPE
    ; ��� count -> �뢮� ��ப� �� �࠭
             DW  DDUP,ZBRAN,TC1-$,ZERO,XDO
   TC0:      DW  DUBL,I,PLUS,CAT,LIT,177Q,$AND
             DW  ONE,EMI$,XLOOP,TC0-$
   TC1:      DW  DROP,SEMI

             HEAD    84h,'(."',251Q,PDOTQ,$COL           ; (.")
             DW  I      ; �� �ᯮ������ ᫥���饥 �᫮ - 
                        ; �᫮ ᨬ����� ��࠭���� � RS 
             DW COUNT,DUBL,ONEP
             DW  FROMR,PLUS,TOR,$TYPE,SEMI

             HEAD    302Q,'.',242Q,D0TQ,$COL              ; ."
             DW  LIT,34,STATE,AT,ZBRAN,XT-$
             DW  COMP,PDOTQ,$WORD,HERE,CAT,ONEP
             DW  ALLOT, SEMI
   XT:       DW  $WORD,HERE,COUNT,$TYPE,SEMI

             HEAD    85h,'QUER',331Q,QUERY,$COL          ; QUERY
    ; �室��� ����,  ���� ���ண� �࠭���� � ��⥬��� ��६�����
    ; �� ����� TIB (Terminal Input Buffer).  ����  �  ���  ����
    ; �����⢫���� �����஬ QUERY
             DW  TIB,AT,CFA,LIT,120Q,EXPE
             DW  ZERO,$IN,STORE,CR,SEMI
             
             HEAD    301Q,,200Q,NULL,$COL                 ; NULL
    ; ������������ �ᯮ������. �ᯮ������, �᫨ ����⨫�� 0 � ���� 
    ; ���뢠�� ��᪮��筮� �ᯮ�쭥��� INTERPRET 
             DW  BLK,AT,ZBRAN,NUL-$         ; �᫨ ���⮢� ०��
             DW  ONE,BLK,PSTOR,ZERO,$IN,STORE,QEXEC
   NUL:      DW  LEV,SEMI

             HEAD    83h,'PA',304Q,PAD,$COL              ; PAD
        ; ������ ����樨   �뤠�   १���⮢   �   ᮮ�饭��   ��   �࠭
        ; �ந��������   �१   ᯥ樠���   ����,   ����   ���ண�  ᬥ饭
        ; �⭮�⥫쭮 HERE.  � ������� ᫮��� �������  ������  PAD,  �����
        ; �뤠�� � �⥪ ���� ����� �⮣� ����:
             DW  HERE,LIT,104Q,PLUS,SEMI

             HEAD    84h,'WOR',304Q,$WORD,$COL           ; WORD
        ; ࠧ����⥫� -> �᫮_ᨬ����� ��ப� �� ����� here
             DW  BLK,AT,DDUP,ZBRAN,WD1-$; ���� � ����������
             DW  BLOCK,BRAN,WD2-$       ; ���� ���� �� ��६����� BLK
   WD1:      DW  TIB,AT                 ; ���� �室���� �ନ����
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
        ; ���� ᫮�� � ᫮���, ���஥ ᫥��� ᫥���騬 � ⥪�� �ணࠬ��
             DW  BLAN,$WORD,HERE,COUNT,UPPER,HERE
             DW  CONT,AT,AT ; ���᪠ � ���⥪�⭮� ᫮���
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
        ; ���⠥�   ���   ᫮��
             DW  COUNT,LIT,37Q,$AND,$TYPE,SPACE,SEMI

             HEAD    86h,'CREAT',305Q,CREAT,$COL         ; CREATE  - --> ��� XXX (I, C)
        ; �ନ஢���� ����� ᫮� - ����⥫��.
        ; (CREATE XXX DOES>) XXX �ᯮ������ �� �⠯� �������樨,
        ; ⥪�� �ணࠬ��, ᫥���騩 �� DOES>, ���� ���ண� 
        ; ����頥��� � PFA - �� �⠯� �ᯮ������.        
             DW  DFIND,ZBRAN,CRE-$,DROP,TWOP,NFA,IDDOT
             DW  LIT,4,MESS             ; ᮮ�饭�� � ����୮� ��।������ ᫮��
   CRE:      DW  HERE,DUBL,CAT,$WIDTH,AT,MIN,ONEP,ALLOT ; here 㪠�뢠�� �� �᫮ ᨬ����� ᫮��
                                                ; ᤢ����� here �� ����� ᫮�� + ᠬ ���� �����
             DW  DUBL,LIT,240Q,TOGL,HERE,ONEM   ; �몫�砥� �� ���᪠
                                                ; 240Q = 10100000
             DW  LIT,200Q,TOGL,LATES,COMMA,CURR,AT,STORE ; � ��᫥���� �㪢� ᫮�� ����砥� 7 ���
                                            ; ��뫪� �� �। ᫮�� � ��࠭塞 ��뫪� �� �����
                                            ; ᮧ������ ᫮��    
             DW  HERE,TWOP,COMMA,SEMI       ; � ᫮���� ���� here

             HEAD    311Q,'[COMPILE',335Q,BCOM,$COL       ; [COMPILE]
        ; �ᯮ������ � ���ᠭ�� ⨯� ������� � �㦨� ���
		; �������樨 ᫮�� ������������ ����⢨� XXX, ��� �᫨ �� ���
        ; �� �뫮 ⠪��. ����� XXX �㤥� �ᯮ����� ⮣��, ����� �㤥�
        ; �ᯮ����� ᫮��, � ���஬ �ᯮ�짮���� ��������� [COMPILE] XXX
        ; ������ � ᫮���� CFA ��������㥬��� ᫮��
             DW  DFIND,ZEQU,ZERO,QERR,DROP,COMMA,SEMI

            HEAD    307Q,'LITERA',314Q,LITER,$COL        ; LITERAL
    ; ���������� �᫮ � ᫮����
            DW  STATE,AT,ZBRAN,LIL-$       ; � ०��� �ᯮ������ ��祣� �� ������
            DW  COMP,LIT,COMMA
    LIL:    DW  SEMI

             HEAD    310Q,'DLITERA',314Q,DLITE,$COL       ; DLITERAL
    ; ���������� � ᫮���� ������� �᫮
             DW  STATE,AT,ZBRAN,DLI-$
            DW  SWAP,LITER,LITER
   DLI:      DW  SEMI

             HEAD    86h,'?STAC',313Q,QSTAC,$COL         ; ?STACK
    ; -> f , true �᫨ ���祭�� 㪠��⥫� �⥪� � �।���� ����᪮�
             DW  SZERO,AT,CFA,SPAT,ULESS,ONE,QERR
             DW  LIT,-200Q,SPAT,ULESS,TWO
             DW  QERR, SEMI

             HEAD    211Q,'INTERPRE',324Q,INTER,$COL      ; INTERPRET
   IT1:      DW  DFIND,ZBRAN,IT3-$ ; ���室 �᫨ �� �������
             DW  STATE,AT,LESS, ZBRAN,IT2-$ ; �믮�����  
             DW  COMMA,BRAN,IT5-$
   IT2:      DW  EXEC,BRAN,IT5-$
   IT3:      DW  HERE,NUMB,DPL,AT,ONEP,ZBRAN,IT4-$
             DW  DLITE,BRAN,IT5-$
   IT4:      DW  DROP,LITER
   IT5:      DW  QSTAC,BRAN,IT1-$

             HEAD    211Q,'IMMEDIAT',305Q,IMMED,$COL      ; IMMEDIATE
    ; �⬥砥� ��᫥���� ᫮�� �ਧ����� 
             DW  LATES,$CL,TOGL,SEMI        ; cl - 6 ���

            HEAD    212Q,'VOCABULAR',331Q,VOCAB,$COL     ; VOCABULARY
    ; ᮧ����� ������ ᫮���� 
            DW  BUILD,LIT,120201Q,COMMA ; 
            DW  CURR,AT,CFA,COMMA
            DW  HERE,VOCL,AT,COMMA,VOCL,STORE,DOES
    DOVOC   LABEL    FAR  
            DW  TWOP,CONT,STORE,SEMI ; ��� ��� �㤥� � PFA ������ ᫮����
                                     ; � CFA ᫮���� ������� ��� $DOE, ����� 
                                     ; ��।��� �ࠢ����� ���� �� ����� PFA
                                     ; � �⥪ ������ ���� PFA+2


             HEAD    301Q,,250Q,PAREN,$COL                ; (
        ; �ய�� �� ᫥���饩 )
             DW  LIT,29h,$WORD,SEMI

             HEAD    84h,'QUI',324Q,QUIT,$COL            ; QUIT
    ; ��頥� ��� �⥪� � �����頥� �ࠢ����� �ନ����. 
    ; �� �뤠���� ������� ᮮ�饭��
             DW  ZERO,BLK,STORE,LBRAC
   QUI:      DW  RPSTO,CR,QUERY,INTER,STATE,AT
             DW  ZEQU,ZBRAN,QUI-$,PDOTQ
             DB  3,' OK'
             DW  BRAN,QUI-$

             HEAD    85h,'ABOR',324Q,ABORT,$COL          ; ABORT
    ; ���뢠�� �ᯮ������, ������ ᫮���� ���� ���⥪���,
    ; �믮���� QUIT. ��ᯥ��뢠�� ����� ��������
             DW  SPSTO,DECIMA,CR,PDOTQ
             DB  17,'FORTH-PC IS HERE '
             DW  FORTH,DEFIN,QUIT

             HEAD    82h,'S',256Q,SPOT,$COL              ; S.
    ; ����� ���孥�� ���祭�� � �⥪� ��� ��� ���������
             DW  DUBL,UDOT,SEMI

             HEAD    81h,,252Q,STAR,$COL                 ; *
             DW  MSTAR,DROP,SEMI

             HEAD    84h,'/MO',304Q,SLMOD,$COL           ; /MOD
             DW  TOR,STOD,FROMR,MSLAS,SEMI

             HEAD    81h,,257Q,SLASH,$COL                ; /
             DW  SLMOD,SWAP,DROP,SEMI

             HEAD    83h,'MO',304Q,$MOD,$COL             ; MOD
             DW  SLMOD,DROP,SEMI

             HEAD    85h,'*/MO',304Q,SSMOD,$COL          ;. */MOD
             DW  TOR,MSTAR,FROMR,MSLAS,SEMI

             HEAD    82h,'*',257Q,SSLA,$COL              ; */
             DW  SSMOD,SWAP,DROP,SEMI

             HEAD    85h,'M/MO',304Q,MSMOD,$COL          ; M/MOD
             DW  TOR,ZERO,I,USLAS,FROMR,SWAP,TOR,USLAS
   $MO:      DW  FROMR,SEMI

             HEAD    215Q,'EMPTY-BUFFER',323Q,MTBUF,$COL  ;EMPTY-BUFFERS
             DW  FIRST,AT,LIT,0C12h,ERASE,SEMI   ; 3084 �뫮

             HEAD    85h,'FLUS',310Q,FLUSH,$COL          ; FLUSH
    ; ������ ���஢ �� ���
             DW  LIMIT,AT,FIRST,AT,XDO
   FLU:      DW  I,AT,ZLESS,ZBRAN,FL1-$
             DW  I,TWOP,I,X,ZERO, RW
   FL1:      DW  LIT,1028,XPLOO,FLU-$,MTBUF,SEMI

             HEAD    86h,'BUFFE',322Q,BUFFE,$COL         ; BUFFER
    ; u --> ���  ����ࢨ��� ���� � �����, �ਯ��뢠�� ���
    ; ����� u, �� �������� �⥭�� � ���⥫� �� �ந��������
             DW  USE,AT,TOR,I       ; ���� ���� � �⥪��
   BR1:      DW  PBUF,ZBRAN,BR1-$   ; �饬 ᢮����� ����
            DW USE,STORE            ; ����祭�� ���� ��࠭��� � USE
             DW  I,AT,ZLESS,ZBRAN,BR2-$ ; �᫨ buffer �������,
             DW  I,TWOP,I,X,ZERO, RW    ; � ������ ��� �� ���
   BR2:      DW  I,STORE,I,PREV,STORE   ; ����� ���� ������� � ���� ��࠭��� � PREV
            DW FROMR,TWOP,SEMI          ; �����頥��� ���祭��

             HEAD    85h,'BLOC',313Q,BLOCK,$COL          ; BLOCK
    ;   u --> ���  �����뢠�� � �⥪ ���� ��ࢮ�� ���� � ����� �
    ;   ����஬ u. �᫨ ���� �� ��室���� � �����, �� ��७����� � ���⥫� 
             DW  OFSET,AT,PLUS,TOR
             DW  PREV,AT,DUBL,X,I,SUBB,ZBRAN,BLC-$
   BLO:      DW  PBUF,ZEQU,ZBRAN,BCK-$
             DW  DROP,I,BUFFE,DUBL,I,ONE,RW,CFA
   BCK:      DW  DUBL,X,I,SUBB,ZEQU
             DW  ZBRAN,BLO-$,DUBL,PREV,STORE
   BLC:      DW  FROMR,DROP,TWOP,SEMI

             HEAD    85h,'.LIN',305Q,DLINE,$COL          ; .LINE
    ; ����� ��ப� �� ������ �࠭�
             DW  TOR,$CL,BBUF,SSMOD,FROMR,PLUS,BLOCK
             DW  PLUS,$CL,DTRAI,$TYPE,SEMI

             HEAD    87h,'MESSAG',305Q,MESS,$COL         ; MESSAGE
             DW  $IN,AT,RNUM,STORE ; ��࠭��� ���祭�� $in
             DW  $WARN,AT,ZBRAN,MS1-$ ; �㦥� �� ⥪�� ᮮ�饭��
             DW  DDUP,ZBRAN,MES-$
             DW  LIT,4,OFSET,AT,SUBB,DLINE ; ⥪�⮢� ᮮ�饭�� �� 4 �࠭�
   MES:      DW  SEMI
   MS1:      DW  PDOTQ
             DB  6,'MSG # '
             DW $DOT,SEMI

             HEAD    84h,'LOA',304Q,LOA,$COL            ; LOAD
    ; n -> ����� �࠭�
             DW  BLK,AT,$IN,AT,ZERO,$IN,STORE,ROT,BLK
             DW  STORE,INTER,$IN,STORE,BLK,STORE,SEMI

             HEAD    303Q,'--',276Q,ARROW,$COL            ; -->
    ; ���㧪� ᫥���饣� �࠭� 
             DW  QLOAD,ZERO,$IN,STORE,ONE
             DW  BLK,PSTOR,SEMI

             HEAD    301Q,,247Q,TICK,$COL                 ; '
    ; ��� ᫮�� XXX � ᫮��� � �����뢠�� � �⥪ ��� PFA
             DW  DFIND,ZEQU,ZERO,QERR,DROP,TWOP,LITER,SEMI

             HEAD    86h,'FORGE',324Q,FORGE,$COL         ; FORGET
             DW  CURR,AT,CONT,AT,SUBB,LIT,30Q,QERR     ; 24 �訡�� �� ���ᠭ�
                                                        ; �訡�� �᫨ CURRENT = CONTEXT
             DW  TICK,DUBL,FENCE,AT,ULESS,LIT,25Q,QERR  ; 21 ᫮�� ���饭�
             DW  DUBL,NFA,$DP,STORE                    ; ᫮���� ᢮����� �� 㪠������ ᫮��
             DW  LFA,AT,CONT,AT,STORE,SEMI             ; � ��६����� context ��襬 ����  
                                                ; ���祭�� LFA ���뢠����� ᫮��

             HEAD    84h,'BAC',313Q,BACK,$COL            ; BACK
    ; HERE - , ; (���������� � ���ᠭ�� ᫮�� ���� ������)
             DW  HERE,SUBB,COMMA,SEMI

             HEAD    305Q,'BEGI',316Q,BEGIN,$COL          ; BEGIN
             DW  QCOMP,HERE,ONE,SEMI

             HEAD    304Q,'THE',316Q,THEN,$COL            ; THEN
             DW  QCOMP,TWO,QPAIR,HERE,OVER,SUBB,SWAP,STORE,SEMI

             HEAD    302Q,'D',317Q,$DO,$COL               ; DO
             DW  COMP,XDO,HERE,THREE,SEMI

             HEAD    304Q,'LOO',320Q,LOO,$COL            ; LOOP
             DW  THREE,QPAIR,COMP,XLOOP,BACK,SEMI

             HEAD    305Q,'+LOO',320Q,PLOOP,$COL          ; +LOOP
             DW  THREE,QPAIR,COMP,XPLOO,BACK,SEMI

             HEAD    305Q,'UNTI',314Q,UNTIL,$COL          ; UNTIL
             DW  ONE,QPAIR,COMP,ZBRAN,BACK,SEMI

             HEAD    306Q,'REPEA',324Q,REPEA,$COL        ; REPEAT
             DW  ROT,ONE,QPAIR,ROT,COMP,BRAN,BACK
             DW  THEN,SEMI

             HEAD    302Q,'I',306Q,$IF,$COL               ; IF
             DW  COMP,ZBRAN,HERE,ZERO,COMMA,TWO,SEMI

             HEAD    304Q,'ELS',305Q,$ELSE,$COL           ; ELSE
             DW  TWO,QPAIR,COMP,BRAN,HERE,ZERO,COMMA
             DW  SWAP,TWO,THEN,TWO,SEMI

             HEAD    305Q,'WHIL',305Q,$WHILE,$COL         ; WHILE
             DW  $IF,SEMI

             HEAD    86h,'SPACE',323Q,SPACS,$COL         ; SPACES
             DW  ZERO,MAX,DDUP,ZBRAN,SP1-$,ZERO,XDO
   SPA:      DW  SPACE,XLOOP,SPA-$
   SP1:      DW  SEMI

             HEAD    82h,'#',243Q,BDIGS,$COL             ; <# ; sds replace 
    ; ��稭��� ����� �८�ࠧ������ �᫠ � ��᫥����⥫쭮��� ����� ASCII.
    ; ��室��� �᫮ � �⥪� ������ ���� ������� ����� ��� �����
             DW  PAD,HLD,STORE,SEMI

             HEAD    82h,'#',276Q,EDIGS,$COL             ; #>
    ; �����蠥� �८�ࠧ������ �᫠. � �⥪� ��⠥��� �᫮
    ; ����祭��� ᨬ����� � ����, ��� �� �ॡ���� ���
    ; ������ TYPE         
             DW  DDROP,HLD,AT,PAD,OVER,SUBB,SEMI

             HEAD    84h,'SIG',316Q,SIGN,$COL            ; SIGN
    ; ������ ���� "�����" � ��室��� ����
             DW  ROT,ZLESS,ZBRAN,SIG-$,LIT,55Q,HOLD
   SIG:      DW  SEMI

             HEAD    81h,,243Q,DIG,$COL                  ; #
    ; �८�ࠧ�� ���� ���� � �����뢠�� �� � ��室��� ���� (PAD),
    ; �뤠�� ���� �ᥣ��, �᫨ �८�ࠧ��뢠�� ��祣�, �����뢠���� 0
             DW  BASE,AT,MSMOD,ROT,LIT,11Q,OVER,LESS
             DW  ZBRAN,DIGI-$,LIT,7,PLUS
   DIGI:     DW  LIT,60Q,PLUS,HOLD,SEMI

             HEAD    82h,'#',323Q,DIGS,$COL              ; #S
    ; �८�ࠧ�� �᫮ �� �� ���, ���� �� �㤥� ����祭 0.
    ; ���� ��� �뤠���� � �� ��砥 (0)
   DIS:      DW  DIG,DUP2,$OR,ZEQU,ZBRAN,DIS-$,SEMI

             HEAD    83h,'D.',322Q,DDOTR,$COL            ; D.R
    ; s width -> ����� �������� �᫠ � ������ � ��ࠢ������ ��ࠢ�
             DW  TOR,SWAP,OVER,DABS,BDIGS,DIGS,SIGN,EDIGS
             DW  FROMR,OVER,SUBB,SPACS,$TYPE,SEMI

             HEAD    82h,'.',322Q,DOTR,$COL              ; .R
    ; s width -> ����� �᫠ � ������ � ��ࠢ������ ��ࠢ�
             DW  TOR,STOD,FROMR,DDOTR,SEMI

             HEAD    83h,'U.',322Q,UDOTR,$COL            ; U.R
    ; u width -> ����� �᫠ ��� ����� � ��ࠢ������ ��ࠢ�
             DW  ZERO,SWAP,DDOTR,SEMI

             HEAD    82h,'D',256Q,DDOT,$COL              ; D.
    ; ����� ������� �ᥫ
             DW  ZERO,DDOTR,SPACE,SEMI

             HEAD    81h,,256Q,$DOT,$COL                 ; .
             DW  STOD,DDOT,SEMI

             HEAD    81h,,277Q,QUEST,$COL                ; ?
    ; ����� ᮤ�ন���� �� ����� � �⥪�
             DW  AT,$DOT,SEMI

             HEAD    82h,'U',256Q,UDOT,$COL              ; U.
    ; ����� �᫠ ��� �����          
             DW  ZERO,DDOT,SEMI

    ;         ** �ᯮ����⥫�� ��楤��� **

             HEAD    84h,'LIS',324Q,$LIST,$COL           ; LIST
    ; n -> �뢮� ᮤ�ন���� �࠭�
             DW  DECIMA,CR,DUBL,SCR,STORE,PDOTQ
             DB  3,'S# '
             DW  $DOT
             DW  LIT,20Q,ZERO,XDO
   LSTI:     DW  CR,I,THREE,DOTR,SPACE
             DW  I,SCR,AT,DLINE
             DW XLOOP,LSTI-$,CR,SEMI

             HEAD    85h,'INDE',330Q,INDEX,$COL          ; INDEX
    ; n1 n2 -> �뢮��� ����� ��ப� �࠭�� � n1 �� n2
             DW  ONEP,SWAP,XDO
   INDX:     DW  CR,I,THREE,DOTR,SPACE,ZERO,I,DLINE
             DW  XLOOP,INDX-$,SEMI

             HEAD    84h,'TRI',317Q,TRIO,$COL            ; TRIO
    ; �� ���㬥��஢���� ⥪�⮢ �ணࠬ� ����뢠���� 㤮��� ࠧ�����
    ; ⥪��� �࠭�� �� �� �� ��࠭��
             DW  LIT,14Q,EMIT
             DW  THREE,OVER,PLUS,SWAP,XDO
   TRI:      DW  I,$LIST,XLOOP,TRI-$,SEMI

             HEAD    85h,'VLIS',324Q,VLIST,$COL          ; VLIST
    ; ᯨ᮪ ᫮� � ᫮���
             DW  CONT,AT,AT
   VL0:      DW  CR,THREE,ZERO,XDO
   VL1:      DW  DUBL,IDDOT,LIT,15Q,OVER,CAT,LIT,37Q,$AND,SUBB
             DW  SPACS,PFA,DUBL,LIT,6,UDOTR,SPACE,LIT,41Q
             DW  EMIT,SPACE,KEY, DROP, LFA,AT,DUBL,ZEQU,ZBRAN,VL2-$
             DW  LEAV ; ������� ����
   VL2:      DW  XLOOP,VL1-$,DDUP,ZEQU,ZBRAN,VL0-$,SEMI

             HEAD    83h,'LC',314Q,LCL,$COL              ; LCL
    ; ���⪠ ��������� ��ப�
             DW  ZERO,ZERO,FIX,$CL,SPACS,RC,SEMI

             HEAD    82h,'H',324Q,HT,$COL                ; HT HOME?
    ; ����� � ��砫� �࠭�
             DW  ZERO,ZERO,FIX,SEMI

             HEAD    84h,'COP',331Q,COPY,$COL            ; COPY
    ; ����� �࠭�          
             DW  SWAP,BLOCK,CFA,STORE,UPDAT,FLUSH,SEMI
             
             HEAD    82h,'T',331Q,TY$$,$COL              ; TY
    ; adr n ->  ���� �����
             DW  ZERO,XDO
   TY4:      DW  I,EIGHT,$MOD,ZEQU,ZBRAN,TY5-$
             DW  CR,DUBL,LIT,7,UDOTR
   TY5:      DW  DUBL,AT,LIT,7,UDOTR,TWOP,XLOOP,TY4-$,SEMI

             HEAD    85h,'DEPT',310Q,DEPTH,$COL          ; DEPTH
    ; �᫮ ����⮢ � �⥪�      
             DW  SZERO,AT,SPAT,TWOP,SUBB,DIV2,SEMI

             HEAD    84h,'DUM',320Q,DUMP,$COL            ; DUMP
    ; ��� u --> - �⮡ࠦ��� u ���� ����� ��稭�� � ���
             DW  ZERO,XDO
   DMP:      DW  DUBL,LIT,7,UDOTR,SPACE,EIGHT,ZERO,XDO
   DP1:      DW  DUBL,I,PLUS,CAT,LIT,5,DOTR,XLOOP,DP1-$
             DW  LIT,4,SPACS,EIGHT,ZERO,XDO
   DP2:      DW  DUBL,I,PLUS,CAT,LIT,177Q,$AND,DUBL,BLAN
             DW  LESS,ZBRAN,DP3-$,DROP,LIT,56Q
   DP3:      DW  EMIT,XLOOP,DP2-$,CR,EIGHT,PLUS,EIGHT
             DW  XPLOO,DMP-$,DROP,SEMI

             HEAD    84h,'SWA',323Q,SWAS,$COL            ; SWAS
        ; ��६���  ���� �࠭�� � � N     
             DW  TOR,BLOCK,CFA,DUBL,AT,I,BLOCK,CFA,STORE,UPDAT
             DW  FROMR,LIT,100000Q,$OR,SWAP,STORE,FLUSH,SEMI

             HEAD    83h,'ST',331Q,STY,$COL              ; STY
        ; ����� �⥪�
             DW  DEPTH,DDUP,ZBRAN,STY3-$,ZERO,XDO
   STY1:     DW  I,EIGHT,$MOD,ZEQU,ZBRAN,STY2-$,CR
   STY2:     DW  I,ONEP,PICK,LIT,7,UDOTR,XLOOP,STY1-$
   STY3:     DW  SEMI

             HEAD    82h,'O',256Q,ODOT,$COL              ; O.
        ; ⮦� �� � S. � octal ��⥬�
             DW  BASE,AT,OVER,OCTAL,UDOT,BASE,STORE,SEMI

             HEAD    83h,'R/',327Q,RW                    ; R/W
   ; ����⨥ 䠩��
             MOV   DX, OFFSET file
             ;MOV   AH, 0FH      ; open file
             MOV   AH, 3dh
             mov   al, 2
             INT   21H
             ;CMP   AL, 0FFH
             ;JE    ERR0
             jc ERR0
             mov    handle, ax
             POP   BX  ; R/W - 䫠�
             POP   AX  ; ����� �����             
             POP   DX  ; ���� ����
             DEC   AX
             MOV   CL, 10 ; 3 �뫮
             SAL   AX, CL  ; (BLOCK#-1)*8 ; ⥯��� �� 1024 ����
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
             CMP   BX, 0 ; ०��
             JNE   RED
   ; WRITE
             ;MOV   BX, DX
             ;MOV   CX, 8      ; ����� �����
   WR:       ;MOV   DX, BX
             ;MOV   AH,1AH     ; ������ ���� ���� (Set disk transfer address)
             ;INT   21H
             ;MOV   DX,OFFSET FCB
             ;MOV   AH, 22H    ; ������ RECORD (Random write)
             ;INT   21H
             MOV   AH, 40H
             MOV   CX, 1024
             mov    bx, handle
             INT   21H
             ;CMP   AL, 0
             ;JNE   ERR1
             jc err1
             ;INC   RANDREC    ; ���४�� ���� ����
             ;ADD   BX, 80H
             ;LOOP  WR
             JMP  OUT1

    RED:     ;MOV   CX, 8
             ;MOV   BX, DX
    ;RD:     ;MOV   DX, BX       ; ���� ����
             ;MOV   AH, 1AH     ; ������ ���� ����
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
             ;INC   RANDREC     ; ���४�� ����
             ;ADD   BX, 80H
            ; LOOP   RD

   OUT1:     ;MOV   DX, OFFSET  FCB  ; �����⨥ 䠩��
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
   DONE:     MOV   AH, 9H ; �뢮� ᮮ�饭��
             INT   21H 
             JMP   EXIT

             HEAD    305Q,';COD','E'+80h,SEMIC,$COL          ; ;CODE
    ; ��� ��।������ � ��� �ணࠬ�� ᫮� �� ��ᥬ����
             DW  QCSP,COMP,PSCOD,LBRAC,SMUG,SEMI

             HEAD    305Q,'FORT','H'+80h,FORTH,$DOE          ; FORTH
    ; ������ ᫮���� ���� ���⥪���.
    ; �. FORTH DIMENSION 
            DW  DOVOC   ; PFA     
            DW 120201Q  ; = A0 81 ����� ��������� ᫮�� ��� �裡 ᫮��३
            DW TASK-7   ; PFA+4 NFA(TASK) ��᫥���� ᫮�� � �⮬ ᫮���                                    
    XVOC    LABEL   FAR         ;  VOC-LINK
            DW  0               ;  ��뫪� �� �।��騩 ᫮����

             HEAD    84h,'TAS','K'+80h,TASK,$COL            ; TASK
        ; ���⮥ ��।������. ��᫥���� ᫮�� � ᫮��� FORTH
             DW  SEMI

   handle   dw 0
   file     db "forth.dat", 0
   ; FCB not used now
   FCB       LABEL WORD
   DRIVE     DB    0
   FN        DB    'FORTH   '
   EXT       DB    'DAT'
   CURBLK    DW    0          ; �⭮�⥫쭮� ��砫� 䠩��
   RECSIZE   DW    80H        ; ࠧ��� ������ �����  
   FILESIZE  DW    5000,0     ; ࠧ��� 䠩��  
   DATE      DW    0,0
             DB    0,0,0,0,0, 0,0,0,0,0 ; REZERV
   CURREC    DB    0           ; ������ � ⥪�饣� ����� 
   RANDREC   DW    0,0         ; ����� �����

   ERMES0    DB    'ERR OPENING FILE$'
   ERMES1    DB    'ERR WRITING FILE$'
   ERMES2    DB    'ERR CLOSING FILE$'
   ERMES3    DB    'ERR READING FILE$'


   XDP     DW  16000 DUP(0)           ; DICTIONARY

   STCK   SEGMENT STACK              ; �⥪ ��ࠬ��஢
           DW  64 DUP (?)
   XS0     LABEL   WORD
           DW  0,0   ; STACK
   STCK   ENDS

   ARRAY      ENDS
   END        $INI


   ������ 26. ���������᪨� ᮮ�饭��
----------------------------------------------------------------------
����饭�� ��                                       ����饭�� ��
  WARNING=0            ���祭��                     WARNING=1
----------------------------------------------------------------------
MSC# 0      ����� �� 㧭���.
            ��᫮ �� 㧭���.
            ��� ᮮ⢥��⢨� ��⥬� ��᫥���

MSC# 1      ����⪠ ������� ���� �� ���⮣� �⥪�  EMPTY STACK

MSC# 2      ��९������� �⥪� ��� ᫮����          STACK OR DIRECTORY
						                            OVERFLOW

MSC# 4      ����୮� ���ᠭ�� ᫮�� (�� ����   IT ISN'T UNIQUE
	        �⠫쭮� �訡���)

MSC# 17     �ᯮ������ ⮫쪮 �� �������樨      COMPILATION ONLY

MSC# 18     �ᯮ������ ⮫쪮 �� �ᯮ������      EXECUTION ONLY

MSC# 19     IF � THEN ��� ��㣨� �������          CONDITIONALS
	        �� ����� ����                           AREN'T PAIRED

MSC# 20     ��।������ �� �����襭�                DEFINITION ISN'T
						                            FINISHED

MSC# 21     ��������� ��㬥�� ᫮�� FORGET       PROTECTED
	        ����� � ���饭��� ��� ᫮����        DIRECTORY

MSC# 22     ������ �ᯮ�짮������ ⮫쪮            USED AT LOADING
            �� ����㧪�                            ONLY

MSC# 26     ������� �� 0                            0 DIVISION
----------------------------------------------------------------------

   N = 1 ������� ��᪠ ��� � ��⥬�
   N = 2 ��������� �ࠢ����� �ணࠬ�� ���譥�� ���ன�⢠
   N = 3 ��������� 䠩� DK:FORTH.DAT (��� ��� �������騩)
   N = 5 ��-� � �⥪��
   N = 6 ��㤠� �� �⥭��
   N = 7 �訡�� �� �����

��᫥ ����㧪�:
    context=current=27f5 ᫮���� forth 
    㪠�뢠�� �� ��᫥���� ᫮�� asctab (2977)

VOCABULARY editor
    vocl -> 2a16
    nfa (editor) = 2a05
    context=current=27f5 ᫮���� forth 
    㪠�뢠�� �� ��᫥���� ᫮�� editor (2a05)

editor
    context = 2a14 -> 27f3 = ����� ��������� (120201Q)
    current = 27f5

������� ᫮�� ᫮���� 
2a05    86, 'EDITOR' 
2a0c    2977 link - asctab �।�����饥 ᫮��
2a0e    18DB cfa - $DOE
2a10    201E pfa - dovoc
2a12    a081 pfa+2  - ����� ��������� 
2a14    27f3  - context ����� ��������� (120201Q) ᫮���� ���
2a16    27f7  - ����� ᫮���� FORTH. VOCL=2a16
