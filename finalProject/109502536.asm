INCLUDE Irvine32.inc


consoleChange PROTO                         ;螢幕清除並畫線
characterCheck PROTO                        ;判斷角色位置
groundCheck PROTO                           ;判斷地板位置
enemyCreate PROTO                           ;判斷敵人是否生成
enemyDraw PROTO                             ;判斷是否畫出敵人
enemyMove PROTO                             ;判斷前方是否有敵人並向前移動
gameOver PROTO                              ;判斷是否撞上敵人
scoreConsole PROTO                          ;顯示分數
endingScreen PROTO                          ;結束頁面
beginScreen PROTO                           ;開始頁面
pauseScreen PROTO                           ;暫停頁面

main	EQU start@0
CMDWIDTH = 120
CMDHEIGHT = 30

.data
block BYTE ?
enemyProbability DWORD 10000
delayTime DWORD 150
enemyRow BYTE 120 DUP(0)
enemyHeight BYTE 1 
enemy DWORD 0 
outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0
xyPosition COORD <0,0>
characterPosition COORD <10,10> 
jumping BYTE 0
gameovercheck BYTE 0
score DWORD 0
 
.code
main PROC

    INVOKE beginScreen
    call Clrscr
    INVOKE consoleChange
    mov ebx,0
  L1:                                       ;按鍵輸入
    mov ax,0
    call ReadKey
    .IF ax==1177h&&characterPosition.Y==10
      inc jumping                             ;開始跳躍過程
      dec characterPosition.Y
    .ENDIF 
    .IF ax==011Bh                           ;暫停遊戲
        INVOKE pauseScreen
    .ENDIF                                 
    .IF characterPosition.Y<10              ;若不在地上則下墜
      .IF jumping!=0                        ;判斷是否在跳躍過程
        .IF jumping<=5                      ;跳躍過程1到5每次向上1格
          inc jumping
          dec characterPosition.Y
        .ENDIF
        .IF jumping>5                       
          mov jumping,0                     ;跳躍過程結束歸零
        .ENDIF
      .ENDIF
      .IF jumping==0
        inc characterPosition.Y
      .ENDIF
    .ENDIF
    mov eax,1000000                            ;產生敵人變數
    call RandomRange
    mov enemy,eax
    INVOKE enemyMove                          ;判斷是否有舊的敵人並向前移動
    INVOKE gameOver                           ;判斷是否撞上敵人
    INVOKE enemyCreate                        ;判斷敵人生成
    mov eax,score
    shr eax,16
    add eax,10
    .IF eax>=delayTime
      mov delayTime,10
      jmp DelayEDIT
    .ENDIF
    .IF eax<delayTime
      sub delayTime,eax
    .ENDIF
  DelayEDIT:
    mov eax,delayTime                           ;延遲
    call Delay
    INVOKE consoleChange
    inc ebx
    .IF gameovercheck==1
      jmp L2
    .ENDIF
    inc score
    jmp L1
  L2:
    INVOKE endingScreen
    call WaitMsg
    call Clrscr
    exit
main ENDP

consoleChange PROC                          ;畫出遊戲畫面
  
  INVOKE GetStdHandle, STD_OUTPUT_HANDLE    ; Get the console ouput handle
    mov outputHandle, eax
    mov ecx,CMDHEIGHT          
    push xyPosition                         ;紀錄起點
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
    .IF eax==ebx                             ;利用eax ebx存取座標並比較,若相同則畫上0
      mov block,'0'
    .ENDIF
    ret
    characterCheck ENDP

groundCheck PROC USES eax ebx ecx           ;判斷地板位置
  
    mov ax,11
    mov bx,xyPosition.Y
    .IF ax==bx                               ;利用ax bx存取座標並比較,若相同則畫上-   
      mov block,'-'
    .ENDIF
    ret
    groundCheck ENDP

enemyCreate PROC USES eax ebx esi               ;判斷敵人是否生成
    mov ebx,enemyProbability                    ;增加機率
    inc ebx
    mov enemyProbability,ebx
    mov eax,enemyProbability                    ;機率生成敵人
    .IF eax>enemy
      mov esi,119                             ;用陣列存位置
      mov [enemyRow+esi],1
    .ENDIF
    ret
    enemyCreate ENDP

enemyDraw PROC USES eax ebx ecx esi         ;判斷是否畫出敵人
    movzx esi,xyPosition.X                  ;如果當前X座標對應到敵人陣列中不是1就不畫
    .IF [enemyRow+esi]==1
      mov ax,10                               ;如果當前Y座標不是地板上就不畫
      mov bx,xyPosition.Y
      .IF ax==bx
        mov block,'X'
      .ENDIF
    .ENDIF
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

gameOver PROC USES eax ebx ecx esi             ;判斷遊戲結束
    movzx esi,characterPosition.X              ;如果當前X座標對應到敵人陣列中不是1就沒事
    .IF [enemyRow+esi]==1
      mov ax,10                               ;如果當前Y座標不是地板上就沒事
      mov bx,characterPosition.Y
      .IF ax==bx
        mov gameovercheck,1
      .ENDIF
    .ENDIF
    ret
    gameOver ENDP

beginScreen PROC USES eax ebx ecx esi             ;開始畫面
    
    ret
    beginScreen ENDP

pauseScreen PROC USES eax ebx ecx esi             ;暫停畫面
    call Clrscr
    call WaitMsg
    call Clrscr
    INVOKE consoleChange
    ret
    pauseScreen ENDP

endingScreen PROC USES eax ebx ecx esi             ;結束畫面
    call Clrscr
    ret
    endingScreen ENDP
END main
