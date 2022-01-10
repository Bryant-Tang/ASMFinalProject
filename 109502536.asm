INCLUDE Irvine32.inc


consoleChange PROTO                                                   ;螢幕清除並畫線
characterCheck PROTO                                                  ;判斷角色位置
groundCheck PROTO                                                     ;判斷地板位置
enemyCreate PROTO                                                     ;判斷敵人是否生成
enemyDraw PROTO                                                       ;判斷是否畫出敵人
enemyMove PROTO                                                       ;判斷前方是否有敵人並向前移動
gameOver PROTO                                                        ;判斷是否撞上敵人
springCreate PROTO                                                    ;判斷彈簧是否生成
springDraw PROTO                                                      ;判斷是否畫出彈簧
springMove PROTO                                                      ;判斷前方是否有彈簧並向前移動
springDetect PROTO                                                    ;判斷是否撞上彈簧
accelerateCreate PROTO                                                ;判斷加速板是否生成
accelerateDraw PROTO                                                  ;判斷是否畫出加速板
accelerateMove PROTO                                                  ;判斷前方是否有加速板並向前移動
accelerateDetect PROTO                                                ;判斷是否撞上加速板
coinCreate PROTO                                                      ;判斷金幣是否生成
coinDraw PROTO                                                        ;判斷是否畫出金幣
coinMove PROTO                                                        ;判斷前方是否有金幣並向前移動
coinDetect PROTO                                                      ;判斷是否撞上金幣
scoreConsole PROTO                                                    ;顯示分數
endingScreen PROTO                                                    ;結束頁面
beginScreen PROTO                                                     ;開始頁面
pauseScreen PROTO                                                     ;暫停頁面
initialization PROTO                                                  ;初始化
rankScreen PROTO                                                      ;排行頁面
rank PROTO                                                            ;判斷排名

main	EQU start@0
CMDWIDTH = 120
CMDHEIGHT = 30

.data
block BYTE ?
restart BYTE ?
enemyProbability DWORD 10000
springProbability DWORD 10000
accelerateProbability DWORD 20000
coinProbability DWORD 50000
delayTime DWORD 50
begintext BYTE 10000 DUP(?)
pausetext BYTE 10000 DUP(?)
endingtext BYTE 10000 DUP(?)
enemyRow BYTE 120 DUP(0)
springRow BYTE 120 DUP(0)
enemyHeight WORD 120 DUP(0)
accelerateRow BYTE 120 DUP(0)
accelerateHeight WORD 120 DUP(0)
coinRow BYTE 120 DUP(0)
coinHeight WORD 120 DUP(0)
height DWORD 0 
onGround WORD 20
ground WORD 21
enemy DWORD 0 
spring DWORD 0
accelerate DWORD 0
aheight DWORD 0
kingKrim DWORD 0
coin DWORD 0
cheight DWORD 0 
outputHandle DWORD 0
inputHandle DWORD 0
count DWORD 0
xyPosition COORD <0,12>
characterPosition COORD <10,20> 
scoreTitleStringPosition COORD <102,0>
scorePosition COORD <113,0>
smallRect SMALL_RECT <0,0,120,30> 
consoleScreen COORD <120,30>
jumping BYTE 0
gameoverCheck BYTE 0
score DWORD 0
scoreTitleString BYTE "your score:" , 0
beginFile BYTE "START.txt",0
pauseFile BYTE "PAUSE.txt",0
endingFile BYTE "OVER.txt",0
rankAsking BYTE "What's your name(10 character at most):",0
WrongName BYTE "contain invalid character",0
NameTooLong BYTE "too long",0
rankScoreFile BYTE "rankScore.txt",0
rankNameFile BYTE "rankName.txt",0
backToStart BYTE "PRESS SPACE TO BACK TO MENU",0
endTheGame BYTE "PRESS OTHER KEY TO END THE GAME",0
fromEndScreen BYTE 0

.code
main PROC
    RESET:
        INVOKE initialization
        INVOKE GetStdHandle, STD_OUTPUT_HANDLE                        ; Get the console ouput handle
        mov outputHandle, eax
        INVOKE GetStdHandle, STD_INPUT_HANDLE                         ; Get the console input handle
        mov inputHandle, eax
        INVOKE SetConsoleWindowInfo,outputHandle,TRUE,ADDR smallRect  ;設定console範圍
        INVOKE SetConsoleScreenBufferSize,outputHandle,consoleScreen  ;設定緩衝區大小
        .IF fromEndScreen==0
            INVOKE beginScreen
        .ENDIF
        mov fromEndScreen,0
        call Clrscr
        INVOKE consoleChange
        mov ebx,0
        L1:                                                           ;按鍵輸入
            mov ax,0
            call ReadKey
            mov bx,onGround
            .IF ax==3920h && characterPosition.Y==bx
                inc jumping                                           ;開始跳躍過程
                dec characterPosition.Y
            .ENDIF 
            .IF ax==011Bh                                             ;暫停遊戲
                INVOKE pauseScreen
            .ENDIF
            mov bx,onGround                                                                 
            .IF characterPosition.Y<bx                                ;若不在地上則下墜
                .IF jumping!=0                                        ;判斷是否在跳躍過程
                    .IF jumping<=7                                    ;跳躍過程1到7每次向上1格
                        inc jumping
                        dec characterPosition.Y
                    .ENDIF
                    .IF jumping>7
                        mov jumping,0                                 ;跳躍過程結束歸零
                    .ENDIF
                .ENDIF
                .IF jumping==0
                    inc characterPosition.Y
                .ENDIF
            .ENDIF
            mov eax,1000000                                           ;產生敵人變數
            call RandomRange
            mov enemy,eax
            mov eax,3                                                 ;產生敵人高度變數
            call RandomRange
            inc eax
            mov height,eax
            mov eax,1000000                                           ;產生彈簧變數
            call RandomRange
            mov spring,eax
            mov eax,1000000                                           ;產生加速板變數
            call RandomRange
            mov accelerate,eax
            mov eax,3                                                 ;產生加速板高度變數
            call RandomRange
            inc eax
            mov aheight,eax
            mov eax,1000000                                           ;產生金幣變數
            call RandomRange
            mov coin,eax
            mov eax,3                                                 ;產生金幣高度變數
            call RandomRange
            inc eax
            mov cheight,eax
            INVOKE enemyMove                                          ;判斷是否有舊的敵人並向前移動
            INVOKE springMove                                         ;判斷是否有舊的彈簧並向前移動
            INVOKE accelerateMove                                     ;判斷是否有舊的加速板並向前移動
            INVOKE coinMove                                           ;判斷是否有舊的金幣並向前移動
            INVOKE gameOver                                           ;判斷是否撞上敵人
            INVOKE springDetect                                       ;判斷是否撞上彈簧
            INVOKE accelerateDetect                                   ;判斷是否撞上加速板
            INVOKE coinDetect                                         ;判斷是否撞上金幣
            INVOKE enemyCreate                                        ;判斷敵人生成
            INVOKE springCreate                                       ;判斷彈簧生成
            INVOKE accelerateCreate                                   ;判斷加速板生成
            INVOKE coinCreate                                         ;判斷金幣生成
            INVOKE consoleChange                                      ;畫出畫面
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
                mov eax,ebx                                           ;延遲
                call Delay
            .IF gameovercheck==1
                jmp L2
            .ENDIF
            inc score
            INVOKE SetConsoleCursorPosition,outputHandle,scorePosition;讓游標位置固定，顯示分數
            mov eax,score
            call WriteDec
            jmp L1
        L2:
            INVOKE endingScreen
            .IF restart==1
                jmp RESET
            .ENDIF
    exit
main ENDP

initialization PROC USES eax ebx ecx esi                              ;初始化
    call Randomize
    mov enemyProbability,10000
    mov delayTime,50
    mov ecx,120
    mov esi,0
    INITIAL:
        mov [enemyRow+esi],0
        mov [springRow+esi],0
        mov [accelerateRow+esi],0
        mov [coinRow+esi],0
        mov [enemyHeight+esi],0
        mov [accelerateHeight+esi],0
        mov [coinHeight+esi],0
        inc esi
        LOOP INITIAL
    mov xyPosition.x,0
    mov xyPosition.y,12
    mov characterPosition.x,10
    mov characterPosition.y,20
    mov jumping,0
    mov gameoverCheck,0
    mov score,0
    mov kingKrim,0
    ret
    initialization ENDP

consoleChange PROC USES ecx edx                                       ;畫出遊戲畫面
    mov ecx,10
    push xyPosition                                                   ;紀錄起點
    DRAWLINE:                                                         ;行數
        push ecx
        push xyPosition.X                                             ;紀錄x位置
        mov ecx,CMDWIDTH
        DRAWROW:                                                      ;列數
            push ecx
            mov block,' '
            INVOKE characterCheck                                     ;判斷角色位置
            INVOKE groundCheck                                        ;判斷地板位置
            INVOKE enemyDraw                                          ;判斷畫出敵人
            INVOKE springDraw                                         ;判斷畫出彈簧
            INVOKE accelerateDraw                                     ;判斷畫出加速板
            INVOKE coinDraw                                           ;判斷畫出金幣
            INVOKE WriteConsoleOutputCharacter,outputHandle,
                ADDR block,1,xyPosition,ADDR count                    ;輸出一格
            pop ecx
            inc xyPosition.X
            LOOP DRAWROW                                              ;增加x座標
        pop xyPosition.X
        pop ecx
        inc xyPosition.Y                                              ;座標換到下一行位置
        LOOP DRAWLINE
    pop xyPosition
    INVOKE SetConsoleCursorPosition,outputHandle,
        scoreTitleStringPosition                                      ;讓游標位置固定，顯示分數字串
    mov edx,OFFSET scoreTitleString
    call WriteString
    ret
    consoleChange ENDP

characterCheck PROC USES eax ebx ecx                                  ;判斷角色位置
    mov ax,characterPosition.X
    shl eax,16
    mov ax,characterPosition.Y
    mov bx,xyPosition.X
    shl ebx,16
    mov bx,xyPosition.Y
    .IF eax==ebx                                                      ;利用eax ebx存取座標並比較,若相同則畫上0
        mov block,'H'
    .ENDIF
    ret
    characterCheck ENDP

groundCheck PROC USES eax ebx ecx                                     ;判斷地板位置
    mov ax,ground
    mov bx,xyPosition.Y
    .IF ax==bx                                                        ;利用ax bx存取座標並比較,若相同則畫上-     
        mov block,'-'
    .ENDIF
    ret
    groundCheck ENDP

enemyCreate PROC USES eax ebx ecx esi                                 ;判斷敵人是否生成
    mov ebx,enemyProbability                                          ;增加機率
    inc ebx
    mov enemyProbability,ebx
    mov eax,enemyProbability                                          ;機率生成敵人
    .IF eax>enemy
        mov esi,119                                                   ;用陣列存位置
        mov [enemyRow+esi],1
    .ENDIF
    .IF eax>enemy
        mov esi,119                                                   ;用陣列存高度
        mov eax,height
        mov [enemyHeight+esi],ax
    .ENDIF
    ret
    enemyCreate ENDP

enemyDraw PROC USES eax ebx ecx esi                                   ;判斷是否畫出敵人
    movzx esi,xyPosition.X                                            ;如果當前X座標對應到敵人陣列中不是1就不畫
    .IF [enemyRow+esi]==1
        mov ax,ground                                                 ;如果當前Y座標不是地板上就不畫
        sub ax,[enemyHeight+esi]
        mov bx,xyPosition.Y
        .IF ax<=bx && bx<=onGround
            mov block,'X'
        .ENDIF
    .ENDIF
    ret
    enemyDraw ENDP

enemyMove PROC USES eax ecx esi                                       ;每一次重畫就判斷敵人移動
    mov esi,0
    mov ecx,119
    ENEMYLEFT:                                                        ;敵人陣列全部往前複製
        mov al,[enemyRow+esi+1]
        mov [enemyRow+esi],al
        mov ax,[enemyHeight+esi+1]
        mov [enemyHeight+esi],ax
        inc esi
        LOOP ENEMYLEFT
    mov esi,119                                                       ;敵人陣列最後一個補0
    mov [enemyRow+esi],0
    mov [enemyHeight+esi],0
    ret
    enemyMove ENDP

gameOver PROC USES eax ebx ecx esi                                    ;判斷遊戲結束
    movzx esi,characterPosition.X                                     ;如果當前X座標對應到敵人陣列中不是1就沒事
    .IF [enemyRow+esi]==1
        mov ax,ground                                                 ;如果當前Y座標不是地板上就沒事
        sub ax,[enemyHeight+esi]
        mov bx,characterPosition.Y
        .IF ax<=bx && bx<=onGround
            mov gameovercheck,1
        .ENDIF
    .ENDIF
    ret
    gameOver ENDP

springCreate PROC USES eax ebx ecx esi                                ;判斷彈簧是否生成
    mov eax,springProbability
    mov esi,119
    .IF eax>spring && [enemyRow+esi]==0                               ;機率生成彈簧
        mov [springRow+esi],1
    .ENDIF
    ret
    springCreate ENDP

springDraw PROC USES eax ebx ecx esi                                  ;判斷是否畫出彈簧
    movzx esi,xyPosition.X                                            ;如果當前X座標對應到彈簧陣列中不是1就不畫
    .IF [springRow+esi]==1
        mov ax,onGround                                               ;如果當前Y座標不是地板上就不畫
        mov bx,xyPosition.Y
        .IF ax==bx
            mov block,'Z'
        .ENDIF
    .ENDIF
    ret
    springDraw ENDP

springMove PROC USES eax ecx esi                                      ;每一次重畫就判斷彈簧移動
    mov esi,0
    mov ecx,119
    SPRINGLEFT:                                                       ;彈簧陣列全部往前複製
        mov al,[springRow+esi+1]
        mov [springRow+esi],al
        inc esi
        LOOP SPRINGLEFT
    mov esi,119                                                       ;彈簧陣列最後一個補0
    mov [springRow+esi],0
    ret
    springMove ENDP

springDetect PROC USES eax ebx ecx esi                                ;判斷彈簧
    movzx esi,characterPosition.X                                     ;如果當前X座標對應到彈簧陣列中不是1就沒事
    .IF [springRow+esi]==1
        mov ax,onGround
        mov bx,characterPosition.Y
        .IF ax==bx
            mov ecx,7
            SPRINGOVER:
                mov eax,5                                             ;延遲
                call Delay
                dec characterPosition.y
                LOOP SPRINGOVER
        .ENDIF
    .ENDIF
    ret
    springDetect ENDP

accelerateCreate PROC USES eax ebx ecx esi                            ;判斷加速板是否生成
    mov eax,accelerateProbability
    mov esi,119
    .IF eax>accelerate && [enemyRow+esi]==0 && [springRow+esi]==0     ;機率生成加速板
        mov [accelerateRow+esi],1
    .ENDIF
    .IF eax>accelerate && [enemyRow+esi]==0 && [springRow+esi]==0
        mov esi,119                                                   ;用陣列存高度
        mov eax,aheight
        mov [accelerateHeight+esi],ax
    .ENDIF
    ret
    accelerateCreate ENDP

accelerateDraw PROC USES eax ebx ecx esi                              ;判斷是否畫出加速板
    movzx esi,xyPosition.X                                            ;如果當前X座標對應到加速板陣列中不是1就不畫
    .IF [accelerateRow+esi]==1
        mov ax,ground                                                 ;如果當前Y座標不是地板-高度就不畫
        sub ax,[accelerateHeight+esi]
        mov bx,xyPosition.Y
        .IF ax==bx
            mov block,'C'
        .ENDIF
    .ENDIF
    ret
    accelerateDraw ENDP

accelerateMove PROC USES eax ecx esi                                  ;每一次清除版面重畫就判斷加速板移動
    mov esi,0
    mov ecx,119
    ACCELERATELEFT:                                                   ;加速板陣列全部往前複製
        mov al,[accelerateRow+esi+1]
        mov [accelerateRow+esi],al
        mov ax,[accelerateHeight+esi+1]
        mov [accelerateHeight+esi],ax
        inc esi
        LOOP ACCELERATELEFT
    mov esi,119                                                       ;加速板陣列最後一個補0
    mov [accelerateRow+esi],0
    mov [accelerateHeight+esi],0
    ret
    accelerateMove ENDP

accelerateDetect PROC USES eax ebx ecx esi                            ;判斷加速板
    movzx esi,characterPosition.X                                     ;如果當前X座標對應到加速板陣列中不是1就沒事
    .IF [accelerateRow+esi]==1
        mov ax,ground                                                 ;如果當前Y座標不是地板-高度就沒事
        sub ax,[accelerateHeight+esi]
        mov bx,characterPosition.Y
        .IF ax==bx
            mov kingKrim,10
            ACCERLERATEOVER:
                mov eax,1000000                                       ;產生敵人變數
                call RandomRange
                mov enemy,eax
                mov eax,3                                             ;產生敵人高度變數
                call RandomRange
                inc eax
                mov height,eax
                mov eax,1000000                                       ;產生彈簧變數
                call RandomRange
                mov spring,eax
                mov eax,1000000                                       ;產生彈簧變數
                call RandomRange
                mov accelerate,eax
                mov eax,3                                             ;產生加速板高度變數
                call RandomRange
                inc eax
                mov aheight,eax
                mov eax,1000000                                       ;產生硬幣變數
                call RandomRange
                mov coin,eax
                mov eax,3                                             ;產生硬幣高度變數
                call RandomRange
                inc eax
                mov cheight,eax
                INVOKE enemyMove                                      ;判斷是否有舊的敵人並向前移動
                INVOKE springMove                                     ;判斷是否有舊的彈簧並向前移動
                INVOKE accelerateMove                                 ;判斷是否有舊的加速板並向前移動
                INVOKE coinMove                                       ;判斷是否有舊的金幣並向前移動
                INVOKE coinDetect                                     ;判斷是否撞上金幣
                INVOKE enemyCreate                                    ;判斷敵人生成
                INVOKE springCreate                                   ;判斷彈簧生成
                INVOKE accelerateCreate                               ;判斷加速板生成
                INVOKE coinCreate                                     ;判斷金幣生成
                INVOKE consoleChange                                  ;畫出畫面
                inc score
                mov eax,1                                             ;延遲
                call Delay
                dec kingKrim
                cmp kingKrim,0
                jne ACCERLERATEOVER
        .ENDIF
    .ENDIF
    ret
    accelerateDetect ENDP

coinCreate PROC USES eax ebx ecx esi                                  ;判斷金幣是否生成
    mov eax,coinProbability
    mov esi,119
    .IF eax>coin && [enemyRow+esi]==0 && [springRow+esi]==0 && [accelerateRow+esi]==0;機率生成金幣
        mov [coinRow+esi],1
    .ENDIF
    .IF eax>coin && [enemyRow+esi]==0 && [springRow+esi]==0 && [accelerateRow+esi]==0
        mov esi,119                                                   ;用陣列存高度
        mov eax,cheight
        mov [coinHeight+esi],ax
    .ENDIF
    ret
    coinCreate ENDP

coinDraw PROC USES eax ebx ecx esi                                    ;判斷是否畫出金幣
    movzx esi,xyPosition.X                                            ;如果當前X座標對應到金幣陣列中不是1就不畫
    .IF [coinRow+esi]==1
        mov ax,ground                                                 ;如果當前Y座標不是地板-高度就不畫
        sub ax,[coinHeight+esi]
        mov bx,xyPosition.Y
        .IF ax==bx
            mov block,'O'
        .ENDIF
    .ENDIF
    ret
    coinDraw ENDP

coinMove PROC USES eax ecx esi                                        ;每一次清除版面重畫就判斷金幣移動
    mov esi,0
    mov ecx,119
    COINLEFT:                                                         ;金幣陣列全部往前複製
        mov al,[coinRow+esi+1]
        mov [coinRow+esi],al
        mov ax,[coinHeight+esi+1]
        mov [coinHeight+esi],ax
        inc esi
        LOOP COINLEFT
    mov esi,119                                                       ;金幣陣列最後一個補0
    mov [coinRow+esi],0
    mov [coinHeight+esi],0
    ret
    coinMove ENDP

coinDetect PROC USES eax ebx ecx esi                                  ;判斷金幣
    movzx esi,characterPosition.X                                     ;如果當前X座標對應到金幣陣列中不是1就沒事
    .IF [coinRow+esi]==1
        mov ax,ground                                                 ;如果當前Y座標不是地板-高度就沒事
        sub ax,[coinHeight+esi]
        mov bx,characterPosition.Y
        .IF ax==bx
            add score,10
            mov [coinRow+esi],0
        .ENDIF
    .ENDIF
    ret
    coinDetect ENDP

beginScreen PROC USES eax ecx edx                                     ;開始畫面
    LOCAL fileHandle:HANDLE,buffer[4000]:BYTE

    ;創建handle
    INVOKE CreateFile,OFFSET beginFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov	fileHandle,eax

    ;讀檔然後關閉handle
    INVOKE ReadFile,fileHandle,ADDR buffer,3628,0,0
    INVOKE CloseHandle,fileHandle

    ;輸出畫面
    call Clrscr
    INVOKE WriteConsole,outputHandle,ADDR buffer,3628,0,0

    ;讀取字元判斷要開始遊戲還是查看排行榜
    call ReadChar
    call Clrscr
    .IF al=='r'
        call rankScreen
    .ENDIF
    .IF al=='R'
        call rankScreen
    .ENDIF
    ret
    beginScreen ENDP

pauseScreen PROC USES eax ecx edx                                     ;暫停畫面
    LOCAL fileHandle:HANDLE,buffer[4000]:BYTE

    ;創建handle
    INVOKE CreateFile,OFFSET pauseFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov	fileHandle,eax

    ;讀檔然後關閉handle
    INVOKE ReadFile,fileHandle,ADDR buffer,3628,0,0
    INVOKE CloseHandle,fileHandle

    ;輸出畫面
    call Clrscr
    INVOKE WriteConsole,outputHandle,ADDR buffer,3628,0,0

    ;讀取任意字元然後重新輸出遊戲畫面
    call ReadChar
    call Clrscr
    INVOKE consoleChange
    ret
    pauseScreen ENDP

endingScreen PROC USES eax ecx edx                                    ;結束畫面
    LOCAL middlePosition:COORD,fileHandle:HANDLE,buffer[4000]:BYTE

    ;讓游標位置固定，顯示分數
    mov middlePosition.X,50
    mov middlePosition.Y,15
    call Clrscr
    INVOKE SetConsoleCursorPosition,outputHandle,middlePosition
    mov edx,OFFSET scoreTitleString
    call WriteString
    mov eax,score
    call WriteDec
    INVOKE Sleep,2000

    ;呼叫rank函式判斷排行
    INVOKE rank

    ;創建handle
    INVOKE CreateFile,OFFSET endingFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov	fileHandle,eax

    ;讀檔然後關閉handle
    INVOKE ReadFile,fileHandle,ADDR buffer,3628,0,0
    INVOKE CloseHandle,fileHandle

    ;輸出畫面
    call Clrscr
    INVOKE WriteConsole,outputHandle,ADDR buffer,3628,0,0

    ;讀取字元判斷要重新開始遊戲還是查看排行榜還是結束遊戲
    call ReadChar
    call Clrscr
    .IF ax==3920h
        mov restart,1
    .ENDIF
    .IF al=='R'
        mov restart,1
        mov fromEndScreen,1
        call rankScreen
    .ENDIF
    .IF al=='r'
        mov restart,1
        mov fromEndScreen,1
        call rankScreen
    .ENDIF
    .IF ax!=3920h
        .IF al!='R'
            .IF al!='r'
                exit
            .ENDIF
        .ENDIF
    .ENDIF
    ret
    endingScreen ENDP


rankScreen PROC USES eax ebx ecx edx esi
    LOCAL rankScorePosition:COORD,nameString[11]:BYTE,scoreString[11]:BYTE,
        fileScoreHandle:HANDLE,fileNameHandle:HANDLE,scoreBuffer[60]:BYTE,nameBuffer[60]:BYTE
        
    ;創建handle讀分數檔然後關閉handle
    call Clrscr
    INVOKE CreateFile,OFFSET rankScoreFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov	fileScoreHandle,eax
    INVOKE ReadFile,fileScoreHandle,ADDR scoreBuffer,50,0,0
    INVOKE CloseHandle,fileScoreHandle

    ;創建handle讀名字檔然後關閉handle
    INVOKE CreateFile,OFFSET rankNameFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
    mov fileNameHandle,eax
    INVOKE ReadFile,fileNameHandle,ADDR nameBuffer,50,0,0
    INVOKE CloseHandle,fileNameHandle

    ;設定游標位置
    mov rankScorePosition.X,45
    mov rankScorePosition.Y,11
    INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition

    ;讀取buffer內容並照順序輸出
    mov ecx,5
    mov esi,0
    mov ebx,0
    ;每次迴圈讀取一個名字一個分數
    READRANK:
        push ecx

        ;設定游標位置
        mov rankScorePosition.X,45
        inc rankScorePosition.Y
        INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition

        ;讀取一個名字
        mov ecx,0
        READRANKNAME:
            mov eax,0
            mov al,[nameBuffer+esi]
            .IF al!='|'
                mov [nameString+ecx],al
                inc esi
                inc ecx
                jmp READRANKNAME
            .ENDIF
        inc esi
        mov [nameString+ecx],0

        ;輸出一個名字
        lea edx,[nameString]
        call WriteString

        ;設定游標位置
        mov rankScorePosition.X,60
        INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition

        ;讀取一個分數
        mov ecx,10
        READRANKSCORE:
            mov al,[scoreBuffer+ebx]
            mov edx,10
            sub edx,ecx
            mov [scoreString+edx],al
            inc ebx
            LOOP READRANKSCORE
        mov edx,10
        sub edx,ecx
        mov [scoreString+edx],0

        ;輸出一個分數
        lea edx,[scoreString]
        call WriteString

        ;回到迴圈開始
        pop ecx
        .IF ecx>1
            dec ecx
            jmp READRANK
        .ENDIF
        
    ;設定游標位置並輸出提示文字
    mov rankScorePosition.X,45
    inc rankScorePosition.Y
    INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition
    INVOKE WriteConsole,outputHandle,ADDR backToStart,27,0,0
    inc rankScorePosition.Y
    INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition
    INVOKE WriteConsole,outputHandle,ADDR endTheGame,31,0,0

    ;讀取字元判斷要回到開始畫面還是結束遊戲
    mov eax,0
    IFBACK:
    call ReadChar
    .IF ax==3920h
        call beginScreen
        jmp RANKSCREENEND
    .ENDIF
    .IF ax!=3920h
        exit
    .ENDIF
    RANKSCREENEND:
    ret
    rankScreen ENDP

rank PROC USES eax ebx ecx edx esi
    LOCAL nameAskPosition:COORD,UserInsert:DWORD,NewScoreIn:BYTE,UserName[11]:BYTE,scoreString[11]:BYTE,fileScoreHandle:HANDLE,
        fileNameHandle:HANDLE,scoreBuffer[60]:BYTE,newScoreBuffer[60]:BYTE,nameBuffer[60]:BYTE,newNameBuffer[60]:BYTE
    mov UserInsert,-1
    mov NewScoreIn,0

    ;設定游標位置並重制UserName字串
    mov nameAskPosition.X,22
    mov nameAskPosition.Y,15
    mov ecx,10
    mov esi,0
    CLEARNAME:
        mov [UserName+esi],0
        inc esi
        LOOP CLEARNAME

    ;輸入名字並判斷是否過長
    READNAME:
        call Clrscr
        INVOKE SetConsoleCursorPosition,outputHandle,nameAskPosition
        mov edx,OFFSET rankAsking
        call WriteString
        lea edx,[UserName]
        mov [UserName+10],0
        mov ecx,12
        call ReadString
        .IF [UserName+10]!=0
        call Clrscr
        INVOKE SetConsoleCursorPosition,outputHandle,nameAskPosition
        mov edx,OFFSET NameTooLong
        call WriteString
        INVOKE Sleep,2000
        jmp READNAME
        .ENDIF

    ;判斷是否有|
    mov ecx,10
    mov esi,0
    CHECKNAME:
        mov al,[UserName+esi]
        .IF al=='|'
        call Clrscr
        INVOKE SetConsoleCursorPosition,outputHandle,nameAskPosition
        mov edx,OFFSET WrongName
        call WriteString
        INVOKE Sleep,2000
        jmp READNAME
        .ENDIF
        inc esi
        LOOP CHECKNAME

    ;創建ScoreHandle並讀取然後關閉
    INVOKE CreateFile,OFFSET rankScoreFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov	fileScoreHandle,eax
    INVOKE ReadFile,fileScoreHandle,ADDR scoreBuffer,50,0,0
    INVOKE CloseHandle,fileScoreHandle

    ;創建NameHandle並讀取然後關閉
    INVOKE CreateFile,OFFSET rankNameFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
    mov fileNameHandle,eax
    INVOKE ReadFile,fileNameHandle,ADDR nameBuffer,50,0,0
    INVOKE CloseHandle,fileNameHandle

    ;轉換新分數成字串型態
    mov eax,score
    mov ecx,10
    SCORETOSTRING:
        mov edx,0
        mov ebx,10
        div ebx
        add dl,'0'
        mov [scoreString+ecx-1],dl
        LOOP SCORETOSTRING
    mov [scoreString+10],0

    ;一個個讀取舊分數轉成整數型態然後跟新分數比較，然後寫入新Buffer
    mov ecx,5
    mov esi,0;新Buffer的index
    mov ebx,0;舊Buffer的index
    ;每次讀一個舊分數，並寫入一個(舊分數或新分數)進Buffer
    CHECKRANKSCORE:
        push ecx
        mov ecx,10
        ;如果新分數已經被寫進Buffer那就不用比直接把舊分數寫進Buffer
        .IF NewScoreIn==1
            jmp MOVINOLDSCORE
        .ENDIF

        ;讀舊分數並轉成整數型態
        mov eax,0
        READONESCORE:
            mov edx,10
            mul edx
            mov edx,0
            push ebx
            add ebx,10
            sub ebx,ecx
            mov dl,[scoreBuffer+ebx]
            pop ebx
            sub dl,'0'
            add eax,edx
            LOOP READONESCORE
        
        ;如果新分數較大就把字串型態的新分數寫入Buffer，然後先不寫入目前這個舊分數
        .IF eax<=score
            pop ecx
            mov edx,5
            sub edx,ecx
            mov UserInsert,edx;紀錄新分數是第幾個插入進去的
            push ecx
            mov ecx,10
            MOVINNEWSCORE:
                mov edx,0
                push ebx
                mov ebx,10
                sub ebx,ecx
                mov dl,[scoreString+ebx]
                pop ebx
                mov [newScoreBuffer+esi],dl
                inc esi
                LOOP MOVINNEWSCORE
            mov NewScoreIn,1
            jmp SCORENEXT
        .ENDIF

        ;如果沒寫新分數(沒有jmp SCORENEXT)那就把舊分數寫進Buffer
        mov ecx,10
        MOVINOLDSCORE:
            mov edx,0
            push ebx
            add ebx,10
            sub ebx,ecx
            mov dl,[scoreBuffer+ebx]
            pop ebx
            mov [newScoreBuffer+esi],dl
            inc esi
            LOOP MOVINOLDSCORE
        add ebx,10

        ;回到迴圈一開始
        SCORENEXT:
        pop ecx
        .IF ecx>1
            dec ecx
            jmp CHECKRANKSCORE
        .ENDIF

    ;先在新名字最後面加上|
    INVOKE Str_length,ADDR UserName
    mov [UserName+eax],'|'
    ;一個個讀取舊名字然後在對的地方(UserInsert)插入新名字，然後寫入新Buffer
    mov ecx,5
    mov esi,0;新Buffer的index
    mov ebx,0;舊Buffer的index
    ;每次讀一個舊名字，並寫入一個(舊名字或新名字)進Buffer
    CHECKRANKNAME:

        ;如果目前是第UserInsert次迴圈(UserInsert+ecx=5)就寫入新名字然後跳到下一次迴圈
        mov eax,ecx
        add eax,UserInsert
        .IF eax==5
            push ecx
            mov ecx,0
            WRITENEWNAME:
            mov eax,0
            mov al,[UserName+ecx]
            .IF al!='|'
                mov [newNameBuffer+esi],al
                inc esi
                inc ecx
                jmp WRITENEWNAME
            .ENDIF
            pop ecx
            jmp NAMENEXT
        .ENDIF

        ;如果沒有寫入新名字(沒有jmp NAMENEXT)那就寫入舊名字
        WRITEOLDNAME:
        mov eax,0
        mov al,[nameBuffer+ebx]
        inc ebx
        .IF al!='|'
            mov [newNameBuffer+esi],al
            inc esi
            jmp WRITEOLDNAME
        .ENDIF

        ;進入下一次迴圈並在Buffer中寫入分隔|
        NAMENEXT:
        mov [newNameBuffer+esi],'|'
        inc esi
        LOOP CHECKRANKNAME

    ;創建Handle並寫檔然後關閉Handle
    INVOKE CreateFile,OFFSET rankScoreFile,GENERIC_WRITE,DO_NOT_SHARE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
    mov	fileScoreHandle,eax
    INVOKE WriteFile,fileScoreHandle,ADDR newScoreBuffer,50,0,0
    INVOKE CloseHandle,fileScoreHandle
    INVOKE CreateFile,OFFSET rankNameFile,GENERIC_WRITE,DO_NOT_SHARE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
    mov	fileNameHandle,eax
    INVOKE WriteFile,fileNameHandle,ADDR newNameBuffer,esi,0,0
    INVOKE CloseHandle,fileNameHandle
    ret
    rank ENDP

END main
