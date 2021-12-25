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
initialization PROTO                        ;初始化

main	EQU start@0
CMDWIDTH = 120
CMDHEIGHT = 30

.data
block BYTE ?
restart BYTE ?
enemyProbability DWORD 10000
delayTime DWORD 50
begintext BYTE 10000 DUP(?)
pausetext BYTE 10000 DUP(?)
endingtext BYTE 10000 DUP(?)
enemyRow BYTE 120 DUP(0)
enemyHeight WORD 120 DUP(0)
height DWORD 0 
onGround WORD 20
ground WORD 21
enemy DWORD 0 
outputHandle DWORD 0
inputHandle DWORD 0
count DWORD 0
xyPosition COORD <0,12>
characterPosition COORD <10,20> 
scoreStringPosition COORD <102,0>
scorePosition COORD <113,0>
smallRect SMALL_RECT <0,0,120,30> 
consoleScreen COORD <120,30>
jumping BYTE 0
gameovercheck BYTE 0
score DWORD 0
scoreString BYTE "your score:" , 0
beginFile BYTE "START.txt",0
pauseFile BYTE "PAUSE.txt",0
endingFile BYTE "OVER.txt",0
 
.code
main PROC
RESET:
  INVOKE initialization
  INVOKE GetStdHandle, STD_OUTPUT_HANDLE    ; Get the console ouput handle
    mov outputHandle, eax
  INVOKE GetStdHandle, STD_INPUT_HANDLE    ; Get the console ouput handle
    mov inputHandle, eax
    INVOKE SetConsoleWindowInfo,          ;設定console範圍
      outputHandle,
      TRUE,
      ADDR smallRect
    INVOKE SetConsoleScreenBufferSize,      ;設定緩衝區大小
      outputHandle,
      consoleScreen
    INVOKE beginScreen
    call Clrscr
    INVOKE consoleChange
    mov ebx,0
  L1:                                       ;按鍵輸入
    mov ax,0
    call ReadKey
    mov bx,onGround
    .IF al==20h && characterPosition.Y==bx
      inc jumping                           ;開始跳躍過程
      dec characterPosition.Y
    .ENDIF 
    .IF al==1Bh                             ;暫停遊戲
        INVOKE pauseScreen
    .ENDIF
    mov bx,onGround                                 
    .IF characterPosition.Y<bx              ;若不在地上則下墜
      .IF jumping!=0                        ;判斷是否在跳躍過程
        .IF jumping<=7                      ;跳躍過程1到7每次向上1格
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
    mov eax,3                                 ;產生敵人高度變數
    call RandomRange
    inc eax
    mov height,eax
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
      mov ebx,delayTime
      sub ebx,eax
    .ENDIF
  DelayEDIT:
    mov eax,ebx                           ;延遲
    call Delay
    INVOKE consoleChange
    inc ebx
    .IF gameovercheck==1
      jmp L2
    .ENDIF
    inc score
    INVOKE SetConsoleCursorPosition,            ;讓游標位置固定，顯示分數
        outputHandle,
        scorePosition
    mov eax,score
    call WriteInt
    jmp L1
  L2:
    INVOKE endingScreen
    .IF restart==1
      jmp RESET
    .ENDIF
    exit
main ENDP

initialization PROC USES eax ebx ecx esi        ;初始化
    mov enemyProbability,10000
    mov delayTime,50
    mov ecx,120
    mov esi,0
  INITIAL:
    mov [enemyRow+esi],0
    mov [enemyHeight+esi],0
    inc esi
    LOOP INITIAL
    mov xyPosition.x,0
    mov xyPosition.y,12
    mov characterPosition.x,10
    mov characterPosition.y,20
    mov jumping,0
    mov gameovercheck,0
    mov score,0
    ret
    initialization ENDP

consoleChange PROC                          ;畫出遊戲畫面
  
    mov ecx,10          
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
    INVOKE SetConsoleCursorPosition,            ;讓游標位置固定，顯示分數字串
        outputHandle,
        scoreStringPosition
    mov edx,OFFSET scoreString
    call WriteString
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
  
    mov ax,ground
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
    .IF eax>enemy
      mov esi,119                             ;用陣列存高度
      mov eax,height
      mov [enemyHeight+esi],ax
    .ENDIF
    ret
    enemyCreate ENDP

enemyDraw PROC USES eax ebx ecx esi         ;判斷是否畫出敵人
    movzx esi,xyPosition.X                  ;如果當前X座標對應到敵人陣列中不是1就不畫
    .IF [enemyRow+esi]==1
      mov ax,ground                               ;如果當前Y座標不是地板上就不畫
      sub ax,[enemyHeight+esi]
      mov bx,xyPosition.Y
      .IF ax<=bx && bx<=onGround
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
    mov ax,[enemyHeight+esi+1]
    mov [enemyHeight+esi],ax
    inc esi
    LOOP ENEMYLEFT
    mov esi,119                             ;敵人陣列最後一個補0
    mov [enemyRow+esi],0
    mov [enemyHeight+esi],0
    ret
    enemyMove ENDP

gameOver PROC USES eax ebx ecx esi             ;判斷遊戲結束
    movzx esi,characterPosition.X              ;如果當前X座標對應到敵人陣列中不是1就沒事
    .IF [enemyRow+esi]==1
      mov ax,ground                               ;如果當前Y座標不是地板上就沒事
      sub ax,[enemyHeight+esi]
      mov bx,characterPosition.Y
      .IF ax<=bx && bx<=onGround
        mov gameovercheck,1
      .ENDIF
    .ENDIF
    ret
    gameOver ENDP

beginScreen PROC USES eax ecx edx              ;開始畫面
    LOCAL fileHandle:HANDLE,buffer[5000]:BYTE
    mov	edx,OFFSET beginFile                   ;開啟檔案
	  call OpenInputFile
	  mov	fileHandle,eax                         ;讀檔案到buffer裡
    lea	edx,[buffer]
	  mov	ecx,3659
	  call ReadFromFile
    call Clrscr                                ;清空螢幕
    lea	edx,[buffer]                           ;印出buffer
	  call WriteString
    call ReadChar
    ret
    beginScreen ENDP

pauseScreen PROC USES eax ecx edx              ;暫停畫面
    LOCAL fileHandle:HANDLE,buffer[5000]:BYTE 
    mov	edx,OFFSET pauseFile
	  call OpenInputFile
	  mov	fileHandle,eax
    lea	edx,[buffer]
	  mov	ecx,3659
	  call ReadFromFile
    call Clrscr
    lea	edx,[buffer]
	  call WriteString
    call ReadChar
    mov edx,OFFSET scoreString
    call WriteString
    INVOKE consoleChange
    ret
    pauseScreen ENDP

endingScreen PROC USES eax ecx edx              ;結束畫面
    LOCAL fileHandle:HANDLE,buffer[5000]:BYTE
    mov	edx,OFFSET endingFile
	  call OpenInputFile
	  mov	fileHandle,eax
    lea	edx,[buffer]
	  mov	ecx,3659
	  call ReadFromFile
    call Clrscr
    lea	edx,[buffer]
	  call WriteString
    call ReadChar
    .IF al==20h
      mov restart,1
    .ENDIF
    .IF al!=20h
      mov restart,0
    .ENDIF
    ret
    endingScreen ENDP

END main
