INCLUDE Irvine32.inc


consoleChange PROTO                         ;螢幕清除並畫線
characterCheck PROTO                        ;判斷角色位置
groundCheck PROTO                           ;判斷地板位置
enemyCreate PROTO                           ;判斷敵人是否生成
enemyDraw PROTO                             ;判斷是否畫出敵人
enemyMove PROTO                             ;判斷前方是否有敵人並向前移動
gameOver PROTO                              ;判斷是否撞上敵人

main	EQU start@0
CMDWIDTH = 120
CMDHEIGHT = 30

.data
block BYTE ?

enemyRow BYTE 120 DUP(0)
enemy DWORD 0 
outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0
xyPosition COORD <0,0>
characterPosition COORD <10,10> 
jumping BYTE 0
 
.code
main PROC

    INVOKE consoleChange
  L1:                                       ;按鍵輸入
    mov al,0
    call ReadKey
    cmp al,'w'
    je JUMP
    cmp al,'a'
    je LEFT
    cmp al,'d'
    je RIGHT
    jmp CHANGE
  JUMP:                                     ;跳躍指令
    inc jumping                             ;開始跳躍過程
    dec characterPosition.Y
    jmp CHANGE
  LEFT:                                     ;向左指令
    dec characterPosition.X
    jmp CHANGE
  RIGHT:                                    ;向右指令
    inc characterPosition.X
    jmp CHANGE
  CHANGE:                                   ;若不在地上則下墜
    mov ax,characterPosition.Y
    cmp ax,10
    je ONGROUND
    inc characterPosition.Y
    cmp jumping,0                           ;判斷是否在跳躍過程
    je ONGROUND
    cmp jumping,5                           ;跳躍過程1到5每次向上1格
    ja JUMPINGDOWN
    dec characterPosition.Y
    dec characterPosition.Y
    inc jumping
    jmp ONGROUND
  JUMPINGDOWN:                              ;跳躍過程結束歸零
    mov jumping,0
  ONGROUND:
    mov eax,1000                            ;產生敵人變數
    call RandomRange
    mov enemy,eax
    INVOKE consoleChange
    mov eax,100                             ;10ms延遲
    call Delay
    jmp L1

    call WaitMsg
    call Clrscr
    exit
main ENDP

consoleChange PROC                          ;螢幕清除並畫線
  
  INVOKE GetStdHandle, STD_OUTPUT_HANDLE    ; Get the console ouput handle
    mov outputHandle, eax
    mov ecx,CMDHEIGHT          
    push xyPosition                         ;紀錄起點
  INVOKE enemyMove                          ;判斷是否有舊的敵人並向前移動
  INVOKE enemyCreate                        ;判斷敵人生成
  DRAWLINE:                                 ;行數
    push ecx
    push xyPosition.X                       ;紀錄x位置
    mov ecx,CMDWIDTH
  DRAWROW:                                  ;列數
    push ecx
    mov block,' '
    INVOKE characterCheck                   ;判斷角色位置
    INVOKE groundCheck                      ;判斷地板位置
    INVOKE enemyDraw                        ;判斷畫出敵人
    INVOKE WriteConsoleOutputCharacter,     ;輸出一格
       outputHandle,   
       ADDR block,   
       1,   
       xyPosition,   
       ADDR count    
    pop ecx
    inc xyPosition.X                        
    LOOP DRAWROW                            ;增加x座標
    pop xyPosition.X
    pop ecx
    inc xyPosition.Y                        ;座標換到下一行位置
    LOOP DRAWLINE
    pop xyPosition
    ret
    consoleChange ENDP

characterCheck PROC USES eax ebx ecx        ;判斷角色位置
  
    mov ax,characterPosition.X                      
    shl eax,16
    mov ax,characterPosition.Y
    mov bx,xyPosition.X
    shl ebx,16
    mov bx,xyPosition.Y
    cmp eax,ebx                             ;利用eax ebx存取座標並比較,若相同則畫上0
    jne NOCHARACTER
    mov block,'0'
  NOCHARACTER:
    ret
    characterCheck ENDP

groundCheck PROC USES eax ebx ecx           ;判斷地板位置
  
    mov ax,11
    mov bx,xyPosition.Y
    cmp ax,bx                               ;利用ax bx存取座標並比較,若相同則畫上-   
    jne NOGROUND
    mov block,'-'
  NOGROUND:
    ret
    groundCheck ENDP

enemyCreate PROC USES eax esi               ;判斷敵人是否生成
    mov eax,50                              ;50/1000的機率生成敵人
    cmp eax,enemy
    jb NONEWENEMY
    mov esi,119                             ;用陣列存位置
    mov [enemyRow+esi],1
  NONEWENEMY:
    ret
    enemyCreate ENDP

enemyDraw PROC USES eax ebx ecx esi         ;判斷是否畫出敵人
    movzx esi,xyPosition.X                  ;如果當前X座標對應到敵人陣列中不是1就不畫
    cmp [enemyRow+esi],1
    jne NOENEMY
    mov ax,10                               ;如果當前Y座標不是地板上就不畫
    mov bx,xyPosition.Y
    cmp ax,bx
    jne NOENEMY
    mov block,'X'
  NOENEMY:
    ret
    enemyDraw ENDP

enemyMove PROC USES eax ecx esi             ;每一次清除版面重畫就判斷敵人移動
    mov esi,0
    mov ecx,119
  ENEMYLEFT:                                ;敵人陣列全部往前複製
    mov al,[enemyRow+esi+1]
    mov [enemyRow+esi],al
    inc esi
    LOOP ENEMYLEFT
    mov esi,119                             ;敵人陣列最後一個補0
    mov [enemyRow+esi],0
    ret
    enemyMove ENDP
END main
