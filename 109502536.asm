INCLUDE Irvine32.inc


consoleChange PROTO                         ;�ù�M���õe�u
characterCheck PROTO                        ;�P�_�����m
groundCheck PROTO                           ;�P�_�a�O��m
enemyCreate PROTO                           ;�P�_�ĤH�O�_�ͦ�
enemyDraw PROTO                             ;�P�_�O�_�e�X�ĤH
enemyMove PROTO                             ;�P�_�e��O�_���ĤH�æV�e����
gameOver PROTO                              ;�P�_�O�_���W�ĤH
springCreate PROTO                          ;�P�_�u®�O�_�ͦ�
springDraw PROTO                            ;�P�_�O�_�e�X�u®
springMove PROTO                            ;�P�_�e��O�_���u®�æV�e����
springDetect PROTO                          ;�P�_�O�_���W�u®
accelerateCreate PROTO                      ;�P�_�[�t�O�O�_�ͦ�
accelerateDraw PROTO                        ;�P�_�O�_�e�X�[�t�O
accelerateMove PROTO                        ;�P�_�e��O�_���[�t�O�æV�e����
accelerateDetect PROTO                      ;�P�_�O�_���W�[�t�O
coinCreate PROTO                            ;�P�_���O�_�ͦ�
coinDraw PROTO                              ;�P�_�O�_�e�X���
coinMove PROTO                              ;�P�_�e��O�_�����æV�e����
coinDetect PROTO                            ;�P�_�O�_���W���
scoreConsole PROTO                          ;��ܤ��
endingScreen PROTO                          ;�����
beginScreen PROTO                           ;�}�l����
pauseScreen PROTO                           ;�Ȱ�����
initialization PROTO                        ;��l��
rankScreen PROTO
rank PROTO                                  ;�P�_�ƦW

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
middlePosition  COORD <50,15>
smallRect SMALL_RECT <0,0,120,30> 
consoleScreen COORD <120,30>
jumping BYTE 0
gameovercheck BYTE 0
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
backToStart BYTE "��U�ť���^��MENU",0
endTheGame BYTE "���L�䵲��C�",0
fromEndScreen BYTE 0


.code
main PROC
RESET:
  INVOKE initialization
  INVOKE GetStdHandle, STD_OUTPUT_HANDLE    ; Get the console ouput handle
    mov outputHandle, eax
  INVOKE GetStdHandle, STD_INPUT_HANDLE    ; Get the console input handle
    mov inputHandle, eax
    INVOKE SetConsoleWindowInfo,          ;�]�wconsole�d��
      outputHandle,
      TRUE,
      ADDR smallRect
    INVOKE SetConsoleScreenBufferSize,      ;�]�w�w�İϤj�p
      outputHandle,
      consoleScreen
    .IF fromEndScreen==0
      INVOKE beginScreen
    .ENDIF
    mov fromEndScreen,0
    call Clrscr
    INVOKE consoleChange
    mov ebx,0
  L1:                                       ;�����J
    mov ax,0
    call ReadKey
    mov bx,onGround
    .IF ax==3920h && characterPosition.Y==bx
      inc jumping                           ;�}�l���D�L�{
      dec characterPosition.Y
    .ENDIF 
    .IF ax==011Bh                             ;�Ȱ��C�
        INVOKE pauseScreen
    .ENDIF
    mov bx,onGround                                 
    .IF characterPosition.Y<bx              ;�Y���b�a�W�h�U�Y
      .IF jumping!=0                        ;�P�_�O�_�b���D�L�{
        .IF jumping<=7                      ;���D�L�{1��7�C���V�W1��
          inc jumping
          dec characterPosition.Y
        .ENDIF
        .IF jumping>5                       
          mov jumping,0                     ;���D�L�{�����k�s
        .ENDIF
      .ENDIF
      .IF jumping==0
        inc characterPosition.Y
      .ENDIF
    .ENDIF
    mov eax,1000000                            ;���ͼĤH�ܼ�
    call RandomRange
    mov enemy,eax
    mov eax,3                                 ;���ͼĤH�����ܼ�
    call RandomRange
    inc eax
    mov height,eax
    mov eax,1000000                            ;���ͼu®�ܼ�
    call RandomRange
    mov spring,eax
    mov eax,1000000                            ;���ͥ[�t�O�ܼ�
    call RandomRange
    mov accelerate,eax
    mov eax,3                                 ;���ͥ[�t�O�����ܼ�
    call RandomRange
    inc eax
    mov aheight,eax
    mov eax,1000000                            ;���ͪ���ܼ�
    call RandomRange
    mov coin,eax
    mov eax,3                                 ;���ͪ����ܼ�
    call RandomRange
    inc eax
    mov cheight,eax
    INVOKE enemyMove                           ;�P�_�O�_���ª��ĤH�æV�e����
    INVOKE springMove                          ;�P�_�O�_���ª��u®�æV�e����
    INVOKE accelerateMove                      ;�P�_�O�_���ª��[�t�O�æV�e����
    INVOKE coinMove                            ;�P�_�O�_���ª����æV�e����
    INVOKE gameOver                            ;�P�_�O�_���W�ĤH
    INVOKE springDetect                        ;�P�_�O�_���W�u®
    INVOKE accelerateDetect                    ;�P�_�O�_���W�[�t�O
    INVOKE coinDetect                          ;�P�_�O�_���W���
    INVOKE enemyCreate                         ;�P�_�ĤH�ͦ�
    INVOKE springCreate                        ;�P�_�u®�ͦ�
    INVOKE accelerateCreate                    ;�P�_�[�t�O�ͦ�
    INVOKE coinCreate                          ;�P�_���ͦ�
    INVOKE consoleChange                       ;�e�X�e��
    mov eax,score
    shr eax,6
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
    mov eax,ebx                           ;����
    call Delay
    inc ebx
    .IF gameovercheck==1
      jmp L2
    .ENDIF
    inc score
    INVOKE SetConsoleCursorPosition,            ;���Ц�m�T�w�A��ܤ��
        outputHandle,
        scorePosition
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

initialization PROC USES eax ebx ecx esi        ;��l��
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
    mov gameovercheck,0
    mov score,0
    mov kingKrim,0
    ret
    initialization ENDP

consoleChange PROC                          ;�e�X�C��e��
  
    mov ecx,10          
    push xyPosition                         ;���_�I
  DRAWLINE:                                 ;���
    push ecx
    push xyPosition.X                       ;���x��m
    mov ecx,CMDWIDTH
  DRAWROW:                                  ;�C��
    push ecx
    mov block,' '
    INVOKE characterCheck                   ;�P�_�����m
    INVOKE groundCheck                      ;�P�_�a�O��m
    INVOKE enemyDraw                        ;�P�_�e�X�ĤH
    INVOKE springDraw                       ;�P�_�e�X�u®
    INVOKE accelerateDraw                   ;�P�_�e�X�[�t�O
    INVOKE coinDraw                         ;�P�_�e�X���
    INVOKE WriteConsoleOutputCharacter,     ;��X�@��
       outputHandle,   
       ADDR block,   
       1,   
       xyPosition,   
       ADDR count    
    pop ecx
    inc xyPosition.X                        
    LOOP DRAWROW                            ;�W�[x�y��
    pop xyPosition.X
    pop ecx
    inc xyPosition.Y                        ;�y�д���U�@���m
    LOOP DRAWLINE
    pop xyPosition
    INVOKE SetConsoleCursorPosition,            ;���Ц�m�T�w�A��ܤ�Ʀr��
        outputHandle,
        scoreTitleStringPosition
    mov edx,OFFSET scoreTitleString
    call WriteString
    ret
    consoleChange ENDP

characterCheck PROC USES eax ebx ecx        ;�P�_�����m
  
    mov ax,characterPosition.X                      
    shl eax,16
    mov ax,characterPosition.Y
    mov bx,xyPosition.X
    shl ebx,16
    mov bx,xyPosition.Y
    .IF eax==ebx                             ;�Q��eax ebx�s��y�Шä��,�Y�ۦP�h�e�W0
      mov block,'H'
    .ENDIF
    ret
    characterCheck ENDP

groundCheck PROC USES eax ebx ecx           ;�P�_�a�O��m
  
    mov ax,ground
    mov bx,xyPosition.Y
    .IF ax==bx                               ;�Q��ax bx�s��y�Шä��,�Y�ۦP�h�e�W-   
      mov block,'-'
    .ENDIF
    ret
    groundCheck ENDP

enemyCreate PROC USES eax ebx ecx esi               ;�P�_�ĤH�O�_�ͦ�
    mov ebx,enemyProbability                    ;�W�[��v
    inc ebx
    mov enemyProbability,ebx
    mov eax,enemyProbability                    ;��v�ͦ��ĤH
    .IF eax>enemy
      mov esi,119                             ;�ΰ}�C�s��m
      mov [enemyRow+esi],1
    .ENDIF
    .IF eax>enemy
      mov esi,119                             ;�ΰ}�C�s����
      mov eax,height
      mov [enemyHeight+esi],ax
    .ENDIF
    ret
    enemyCreate ENDP

enemyDraw PROC USES eax ebx ecx esi         ;�P�_�O�_�e�X�ĤH
    movzx esi,xyPosition.X                  ;�p�G��eX�y�й����ĤH�}�C�����O1�N���e
    .IF [enemyRow+esi]==1
      mov ax,ground                               ;�p�G��eY�y�Ф��O�a�O�W�N���e
      sub ax,[enemyHeight+esi]
      mov bx,xyPosition.Y
      .IF ax<=bx && bx<=onGround
        mov block,'X'
      .ENDIF
    .ENDIF
    ret
    enemyDraw ENDP

enemyMove PROC USES eax ecx esi             ;�C�@�����e�N�P�_�ĤH����
    mov esi,0
    mov ecx,119
  ENEMYLEFT:                                ;�ĤH�}�C�������e�ƻs
    mov al,[enemyRow+esi+1]
    mov [enemyRow+esi],al
    mov ax,[enemyHeight+esi+1]
    mov [enemyHeight+esi],ax
    inc esi
    LOOP ENEMYLEFT
    mov esi,119                             ;�ĤH�}�C�̫�@�Ӹ�0
    mov [enemyRow+esi],0
    mov [enemyHeight+esi],0
    ret
    enemyMove ENDP

gameOver PROC USES eax ebx ecx esi             ;�P�_�C�����
    movzx esi,characterPosition.X              ;�p�G��eX�y�й����ĤH�}�C�����O1�N�S��
    .IF [enemyRow+esi]==1
      mov ax,ground                               ;�p�G��eY�y�Ф��O�a�O�W�N�S��
      sub ax,[enemyHeight+esi]
      mov bx,characterPosition.Y
      .IF ax<=bx && bx<=onGround
        mov gameovercheck,1
      .ENDIF
    .ENDIF
    ret
    gameOver ENDP

springCreate PROC USES eax ebx ecx esi               ;�P�_�u®�O�_�ͦ�
    mov eax,springProbability                   
    mov esi,119
    .IF eax>spring && [enemyRow+esi]==0             ;��v�ͦ��u®
      mov [springRow+esi],1
    .ENDIF
    ret
    springCreate ENDP

springDraw PROC USES eax ebx ecx esi         ;�P�_�O�_�e�X�u®
    movzx esi,xyPosition.X                  ;�p�G��eX�y�й����u®�}�C�����O1�N���e
    .IF [springRow+esi]==1
      mov ax,onGround                               ;�p�G��eY�y�Ф��O�a�O�W�N���e
      mov bx,xyPosition.Y
      .IF ax==bx
        mov block,'Z'
      .ENDIF
    .ENDIF
    ret
    springDraw ENDP

springMove PROC USES eax ecx esi             ;�C�@�����e�N�P�_�u®����
    mov esi,0
    mov ecx,119
  SPRINGLEFT:                                ;�u®�}�C�������e�ƻs
    mov al,[springRow+esi+1]
    mov [springRow+esi],al
    inc esi
    LOOP SPRINGLEFT
    mov esi,119                             ;�u®�}�C�̫�@�Ӹ�0
    mov [springRow+esi],0
    ret
    springMove ENDP

springDetect PROC USES eax ebx ecx esi             ;�P�_�u®
    movzx esi,characterPosition.X              ;�p�G��eX�y�й����u®�}�C�����O1�N�S��
    .IF [springRow+esi]==1
      mov ax,onGround                              
      mov bx,characterPosition.Y
      .IF ax==bx
      mov ecx,7
  SPRINGOVER:
        mov eax,5                           ;����
        call Delay
        dec characterPosition.y
        LOOP SPRINGOVER
      .ENDIF
    .ENDIF
    ret
    springDetect ENDP

accelerateCreate PROC USES eax ebx ecx esi               ;�P�_�[�t�O�O�_�ͦ�
    mov eax,accelerateProbability                   
    mov esi,119
    .IF eax>accelerate && [enemyRow+esi]==0 && [springRow+esi]==0           ;��v�ͦ��[�t�O
      mov [accelerateRow+esi],1
    .ENDIF
    .IF eax>accelerate && [enemyRow+esi]==0 && [springRow+esi]==0
      mov esi,119                             ;�ΰ}�C�s����
      mov eax,aheight
      mov [accelerateHeight+esi],ax
    .ENDIF
    ret
    accelerateCreate ENDP

accelerateDraw PROC USES eax ebx ecx esi         ;�P�_�O�_�e�X�[�t�O
    movzx esi,xyPosition.X                  ;�p�G��eX�y�й����[�t�O�}�C�����O1�N���e
    .IF [accelerateRow+esi]==1
      mov ax,ground                               ;�p�G��eY�y�Ф��O�a�O-���״N���e
      sub ax,[accelerateHeight+esi]
      mov bx,xyPosition.Y
      .IF ax==bx
        mov block,'C'
      .ENDIF
    .ENDIF
    ret
    accelerateDraw ENDP

accelerateMove PROC USES eax ecx esi             ;�C�@���M���������e�N�P�_�[�t�O����
    mov esi,0
    mov ecx,119
  ACCELERATELEFT:                                ;�[�t�O�}�C�������e�ƻs
    mov al,[accelerateRow+esi+1]
    mov [accelerateRow+esi],al
    mov ax,[accelerateHeight+esi+1]
    mov [accelerateHeight+esi],ax
    inc esi
    LOOP ACCELERATELEFT
    mov esi,119                             ;�[�t�O�}�C�̫�@�Ӹ�0
    mov [accelerateRow+esi],0
    mov [accelerateHeight+esi],0
    ret
    accelerateMove ENDP

accelerateDetect PROC USES eax ebx ecx esi             ;�P�_�[�t�O
    movzx esi,characterPosition.X              ;�p�G��eX�y�й����[�t�O�}�C�����O1�N�S��
    .IF [accelerateRow+esi]==1
      mov ax,ground                               ;�p�G��eY�y�Ф��O�a�O-���״N�S��
      sub ax,[accelerateHeight+esi]
      mov bx,characterPosition.Y
      .IF ax==bx
      mov kingKrim,10
  ACCERLERATEOVER:
      mov eax,1000000                            ;���ͼĤH�ܼ�
      call RandomRange
      mov enemy,eax
      mov eax,3                                 ;���ͼĤH�����ܼ�
      call RandomRange
      inc eax
      mov height,eax
      mov eax,1000000                            ;���ͼu®�ܼ�
      call RandomRange
      mov spring,eax
      mov eax,1000000                            ;���ͼu®�ܼ�
      call RandomRange
      mov accelerate,eax
      mov eax,3                                 ;���ͥ[�t�O�����ܼ�
      call RandomRange
      inc eax
      mov aheight,eax
      mov eax,1000000                            ;���͵w���ܼ�
      call RandomRange
      mov coin,eax
      mov eax,3                                 ;���͵w����ܼ�
      call RandomRange
      inc eax
      mov cheight,eax
      INVOKE enemyMove                           ;�P�_�O�_���ª��ĤH�æV�e����
      INVOKE springMove                          ;�P�_�O�_���ª��u®�æV�e����
      INVOKE accelerateMove                      ;�P�_�O�_���ª��[�t�O�æV�e����
      INVOKE coinMove                            ;�P�_�O�_���ª����æV�e����
      INVOKE coinDetect                          ;�P�_�O�_���W���
      INVOKE enemyCreate                         ;�P�_�ĤH�ͦ�
      INVOKE springCreate                        ;�P�_�u®�ͦ�
      INVOKE accelerateCreate                    ;�P�_�[�t�O�ͦ�
      INVOKE coinCreate                          ;�P�_���ͦ�
      INVOKE consoleChange                       ;�e�X�e��
      inc score
      mov eax,1                           ;����
      call Delay
      dec kingKrim
      cmp kingKrim,0
      jne ACCERLERATEOVER
      .ENDIF
    .ENDIF
    ret
    accelerateDetect ENDP

coinCreate PROC USES eax ebx ecx esi               ;�P�_���O�_�ͦ�
    mov eax,coinProbability                   
    mov esi,119
    .IF eax>coin && [enemyRow+esi]==0 && [springRow+esi]==0 && [accelerateRow+esi]==0        ;��v�ͦ����
      mov [coinRow+esi],1
    .ENDIF
    .IF eax>coin && [enemyRow+esi]==0 && [springRow+esi]==0 && [accelerateRow+esi]==0
      mov esi,119                             ;�ΰ}�C�s����
      mov eax,cheight
      mov [coinHeight+esi],ax
    .ENDIF
    ret
    coinCreate ENDP

coinDraw PROC USES eax ebx ecx esi         ;�P�_�O�_�e�X���
    movzx esi,xyPosition.X                  ;�p�G��eX�y�й������}�C�����O1�N���e
    .IF [coinRow+esi]==1
      mov ax,ground                               ;�p�G��eY�y�Ф��O�a�O-���״N���e
      sub ax,[coinHeight+esi]
      mov bx,xyPosition.Y
      .IF ax==bx
        mov block,'O'
      .ENDIF
    .ENDIF
    ret
    coinDraw ENDP

coinMove PROC USES eax ecx esi             ;�C�@���M���������e�N�P�_����
    mov esi,0
    mov ecx,119
  COINLEFT:                                ;���}�C�������e�ƻs
    mov al,[coinRow+esi+1]
    mov [coinRow+esi],al
    mov ax,[coinHeight+esi+1]
    mov [coinHeight+esi],ax
    inc esi
    LOOP COINLEFT
    mov esi,119                             ;���}�C�̫�@�Ӹ�0
    mov [coinRow+esi],0
    mov [coinHeight+esi],0
    ret
    coinMove ENDP

coinDetect PROC USES eax ebx ecx esi             ;�P�_���
    movzx esi,characterPosition.X              ;�p�G��eX�y�й������}�C�����O1�N�S��
    .IF [coinRow+esi]==1
      mov ax,ground                               ;�p�G��eY�y�Ф��O�a�O-���״N�S��
      sub ax,[coinHeight+esi]
      mov bx,characterPosition.Y
      .IF ax==bx
        add score,10
        mov [coinRow+esi],0
      .ENDIF
    .ENDIF
    ret
    coinDetect ENDP

beginScreen PROC USES eax ecx edx              ;�}�l�e��
    LOCAL fileHandle:HANDLE,buffer[5000]:BYTE
    mov	edx,OFFSET beginFile                   ;�}���ɮ�
	  call OpenInputFile
	  mov	fileHandle,eax                         ;Ū�ɮר�buffer��
    lea	edx,[buffer]
	  mov	ecx,3627
	  call ReadFromFile
    INVOKE CloseHandle,fileHandle
    mov [buffer+3627],0
    call Clrscr
    lea	edx,[buffer]                           ;�L�Xbuffer
	  call WriteString
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

pauseScreen PROC USES eax ecx edx              ;�Ȱ��e��
    LOCAL fileHandle:HANDLE,buffer[5000]:BYTE 
    mov	edx,OFFSET pauseFile
	  call OpenInputFile
	  mov	fileHandle,eax
    lea	edx,[buffer]
	  mov	ecx,3627
	  call ReadFromFile
    INVOKE CloseHandle,fileHandle
    mov [buffer+3627],0
    call Clrscr
    lea	edx,[buffer]
	  call WriteString
    call ReadChar
    call Clrscr
    INVOKE consoleChange
    ret
    pauseScreen ENDP

endingScreen PROC USES eax ecx edx              ;����e��
    LOCAL fileHandle:HANDLE,buffer[5000]:BYTE
    call Clrscr
    INVOKE SetConsoleCursorPosition,            ;���Ц�m�T�w�A��ܤ��
      outputHandle,
      middlePosition
    mov edx,OFFSET scoreTitleString
    call WriteString
    mov eax,score
    call WriteDec
    INVOKE Sleep,2000
    INVOKE rank
    mov	edx,OFFSET endingFile
	  call OpenInputFile
	  mov	fileHandle,eax
    lea	edx,[buffer]
	  mov	ecx,3627
	  call ReadFromFile
    INVOKE CloseHandle,fileHandle
    mov [buffer+3627],0
    call Clrscr
    lea	edx,[buffer]
	  call WriteString
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
    
; rank PROC USES eax ebx ecx edx esi
    ; LOCAL UserName[10]:BYTE,fileScoreHandle:HANDLE,fileNameHandle:HANDLE,scoreBuffer[500]:BYTE,newScoreBuffer[500]:BYTE,nameBuffer[500]:BYTE
  ; READNAME:
    ; call Clrscr
  ;   mov edx,OFFSET rankAsking
  ;   call WriteString
  ;   lea edx,[UserName]
  ;   mov [UserName+10],0
  ;   mov ecx,11
  ;   call ReadString
  ;   .IF [UserName+10]!=0
  ;   mov edx,OFFSET NameTooLong
  ;   call WriteString
  ;   INVOKE Sleep,2000
  ;   jmp READNAME
  ;   .ENDIF
  ;   mov ecx,10
  ;   mov esi,0
  ; CHECKNAME:
  ;   mov al,[UserName+esi]
  ;   .IF al=='|'
  ;   mov edx,OFFSET WrongName
  ;   call WriteString
  ;   INVOKE Sleep,2000
  ;   jmp READNAME
  ;   .ENDIF
  ;   inc esi
  ;   LOOP CHECKNAME
    ; mov	edx,OFFSET rankScoreFile
	  ; call OpenInputFile
	  ; mov	fileScoreHandle,eax
    ; lea	edx,[scoreBuffer]
	  ; mov	ecx,160
	  ; call ReadFromFile
    ; call CloseFile
  ;   mov eax,score
  ;   mov ecx,32
  ;   mov esi,0
  ; WRITESCORE:
  ;   shl eax,1
  ;   jc SETONE
  ;   mov al,0
  ;   jmp SETDONE
  ;   SETONE:
  ;   mov al,1
  ;   SETDONE:
  ;   add al,'0'
  ;   mov [newScoreBuffer+esi],al
  ;   inc esi
  ;   LOOP WRITESCORE
  ;   mov [newScoreBuffer+32],0
  ;   lea edx,[newScoreBuffer]
  ;   call WriteString
  ;   call Crlf
  ;   mov eax,score
  ;   call WriteInt
  ;   call WaitMsg
  ;   mov ecx,128
  ;   mov esi,0
  ; CHANGERANK:
  ;   mov al,[ScoreBuffer+esi]
  ;   mov [newScoreBuffer+esi+32],al
  ;   LOOP CHANGERANK
    ; INVOKE CreateFile,OFFSET rankScoreFile,GENERIC_WRITE,DO_NOT_SHARE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
    ; mov	fileScoreHandle,eax
    ; lea	edx,[newScoreBuffer]
    ; mov ecx,32
    ; mov eax,fileScoreHandle
    ; call WriteToFile
    ; ret
    ; rank ENDP


rankScreen PROC USES eax ebx ecx edx esi
    LOCAL rankScorePosition:COORD,nameString[11]:BYTE,scoreString[11]:BYTE,fileScoreHandle:HANDLE,fileNameHandle:HANDLE,scoreBuffer[60]:BYTE,nameBuffer[60]:BYTE
    call Clrscr
    INVOKE CreateFile,OFFSET rankScoreFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	  mov	fileScoreHandle,eax
    INVOKE ReadFile,fileScoreHandle,ADDR scoreBuffer,50,0,0
    INVOKE CloseHandle,fileScoreHandle

    INVOKE CreateFile,OFFSET rankNameFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
    mov fileNameHandle,eax
    INVOKE ReadFile,fileNameHandle,ADDR nameBuffer,50,0,0
    INVOKE CloseHandle,fileNameHandle
    mov rankScorePosition.X,45
    mov rankScorePosition.Y,11
    INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition
    mov ecx,5
    mov esi,0
    mov ebx,0
    READRANK:
      push ecx
      mov rankScorePosition.X,45
      inc rankScorePosition.Y
      INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition
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
      lea edx,[nameString]
      call WriteString
      mov rankScorePosition.X,60
      INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition
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
      lea edx,[scoreString]
      call WriteString
      pop ecx
      .IF ecx>1
        dec ecx
        jmp READRANK
      .ENDIF
    mov rankScorePosition.X,45
    inc rankScorePosition.Y
    INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition
    INVOKE WriteConsole,outputHandle,ADDR backToStart,18,0,0
    inc rankScorePosition.Y
    INVOKE SetConsoleCursorPosition,outputHandle,rankScorePosition
    INVOKE WriteConsole,outputHandle,ADDR endTheGame,16,0,0
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
    LOCAL UserInsert:DWORD,NewScoreIn:BYTE,UserName[11]:BYTE,scoreString[11]:BYTE,fileScoreHandle:HANDLE,fileNameHandle:HANDLE,scoreBuffer[60]:BYTE,newScoreBuffer[60]:BYTE,nameBuffer[60]:BYTE,newNameBuffer[60]:BYTE

    mov ecx,10
    mov esi,0
  CLEARNAME:
    mov [UserName+esi],0
    inc esi
    LOOP CLEARNAME
  READNAME:
    call Clrscr
    mov edx,OFFSET rankAsking
    call WriteString
    lea edx,[UserName]
    mov [UserName+10],0
    mov ecx,11
    call ReadString
    .IF [UserName+10]!=0
    mov edx,OFFSET NameTooLong
    call WriteString
    INVOKE Sleep,2000
    jmp READNAME
    .ENDIF
    mov ecx,10
    mov esi,0
  CHECKNAME:
    mov al,[UserName+esi]
    .IF al=='|'
    mov edx,OFFSET WrongName
    call WriteString
    INVOKE Sleep,2000
    jmp READNAME
    .ENDIF
    inc esi
    LOOP CHECKNAME

    INVOKE CreateFile,OFFSET rankScoreFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	  mov	fileScoreHandle,eax
    INVOKE ReadFile,fileScoreHandle,ADDR scoreBuffer,50,0,0
    INVOKE CloseHandle,fileScoreHandle

    INVOKE CreateFile,OFFSET rankNameFile,GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
    mov fileNameHandle,eax
    INVOKE ReadFile,fileNameHandle,ADDR nameBuffer,50,0,0
    INVOKE CloseHandle,fileNameHandle

    mov UserInsert,-1
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

    mov NewScoreIn,0
    mov ecx,5
    mov esi,0
    mov ebx,0
  CHECKRANKSCORE:
    push ecx
    mov ecx,10
    .IF NewScoreIn==1
      jmp MOVINOLDSCORE
    .ENDIF
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
    
    .IF eax<=score
      pop ecx
      mov edx,5
      sub edx,ecx
      mov UserInsert,edx
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
    SCORENEXT:
    add ebx,10
    pop ecx
    .IF ecx>1
      dec ecx
      jmp CHECKRANKSCORE
    .ENDIF

    INVOKE Str_length,ADDR UserName
    mov [UserName+eax],'|'
    mov ecx,5
    mov esi,0
    mov ebx,0
  CHECKRANKNAME:
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
    WRITEOLDNAME:
    mov eax,0
    mov al,[nameBuffer+ebx]
    inc ebx
    .IF al!='|'
      mov [newNameBuffer+esi],al
      inc esi
      jmp WRITEOLDNAME
    .ENDIF
    NAMENEXT:
    mov [newNameBuffer+esi],'|'
    inc esi
    LOOP CHECKRANKNAME

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
