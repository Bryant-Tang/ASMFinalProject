INCLUDE Irvine32.inc


consoleChange PROTO                         ;螢幕清除並畫線
characterCheck PROTO                        ;判斷角色位置
groundCheck PROTO                           ;判斷地板位置
enemyCreate PROTO                           ;判斷敵人是否生成
enemyMove PROTO                             ;判斷前方是否有敵人並向前移動
gameOver PROTO                              ;判斷是否撞上敵人

main	EQU start@0
CMDWIDTH = 120
CMDHEIGHT = 30

.data
block BYTE ?

enemyRow DWORD 120 DUP(?)
enemy DWORD 0 
outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0
xyPosition COORD <0,0>
characterPosition COORD <10,10> 
          
 
.code
main PROC

    INVOKE consoleChange
  L1:
    mov al,0
    call ReadKey
    cmp al,'w'
    je JUMP
    cmp al,'a'
    je LEFT
    cmp al,'d'
    je RIGHT
    jmp CHANGE
  JUMP:
    dec characterPosition.Y
    dec characterPosition.Y
    dec characterPosition.Y
    jmp CHANGE
  LEFT:
    dec characterPosition.X
    jmp CHANGE
  RIGHT:
    inc characterPosition.X
    jmp CHANGE
  CHANGE:
    mov ax,characterPosition.Y
    cmp ax,10
    je ONGROUND
    inc characterPosition.Y
  ONGROUND:
    mov eax,10 
    call RandomRange
    mov enemy,eax
    INVOKE consoleChange
    mov ax,0
    call DELAY
    jmp L1

    call WaitMsg
    call Clrscr
    exit
main ENDP

consoleChange PROC
  
  INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
    mov outputHandle, eax 
    call Clrscr
    mov ecx,CMDHEIGHT
    push xyPosition
  DRAWLINE:
    push ecx
    push xyPosition.X
    mov ecx,CMDWIDTH
  DRAWROW:
    push ecx
    mov block,' '
    INVOKE characterCheck
    INVOKE groundCheck
    INVOKE enemyCreate
    INVOKE enemyMove
    INVOKE WriteConsoleOutputCharacter,
       outputHandle,   ; console output handle
       ADDR block,   ; pointer to the top box line
       1,   ; size of box line
       xyPosition,   ; coordinates of first char
       ADDR count    ; output count
    pop ecx
    inc xyPosition.X
    LOOP DRAWROW
    pop xyPosition.X
    pop ecx
    inc xyPosition.Y   ; 座標換到下一行位置
    LOOP DRAWLINE
    pop xyPosition
    ret
    consoleChange ENDP

characterCheck PROC USES eax ebx
  
    mov ax,characterPosition.X
    shl eax,16
    mov ax,characterPosition.Y
    mov bx,xyPosition.X
    shl ebx,16
    mov bx,xyPosition.Y
    cmp eax,ebx
    jne NOCHARACTER
    mov block,'0'
  NOCHARACTER:
    ret
    characterCheck ENDP

groundCheck PROC USES eax ebx
  
    mov ax,11
    mov bx,xyPosition.Y
    cmp ax,bx
    jne NOGROUND
    mov block,'-'
  NOGROUND:
    ret
    groundCheck ENDP

enemyCreate PROC USES eax ebx
  
    mov eax,4
    cmp eax,enemy
    jb NOENEMY
    mov ax,119
    shl eax,16
    mov ax,10
    mov bx,xyPosition.X
    shl ebx,16
    mov bx,xyPosition.Y
    cmp eax,ebx
    jne NOENEMY
    mov block,'X'
  NOENEMY:
    ret
    enemyCreate ENDP

enemyMove PROC USES eax ebx
  
    
    ret
    enemyMove ENDP

END main
