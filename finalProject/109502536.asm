INCLUDE Irvine32.inc


characterMove PROTO


main	EQU start@0
CMDWIDTH = 120
CMDHEIGHT = 30

.data
sky BYTE CMDWIDTH DUP(?)
 
outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0
xyPosition COORD <0,0>
characterPosition COORD <10,10> 
          
 
.code
main PROC

    INVOKE characterMove
  L1:
    mov al,0
    call ReadKey
    jz NOTMOVE
    cmp al,'w'
    je JUMP
    cmp al,'a'
    je LEFT
    cmp al,'d'
    je RIGHT
    jmp CHANGE
  JUMP:
    dec xyPosition.Y
    jmp CHANGE
  LEFT:
    dec xyPosition.X
    jmp CHANGE
  RIGHT:
    inc xyPosition.X
    jmp CHANGE
  INSKY:
    inc xyPosition.Y
    jmp CHANGE
  CHANGE:
    push xyPosition
    INVOKE characterMove
    pop xyPosition
  NOTMOVE:
    mov ax,500
    call DELAY
    jmp L1

    call WaitMsg
    call Clrscr
    exit
main ENDP

characterMove PROC
  
  INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
    mov outputHandle, eax ; save console handle
    call Clrscr
    ; 畫出box的第一行
    mov ecx,CMDHEIGHT
    push xyPosition
  DRAW:
    INVOKE WriteConsoleOutputCharacter,
       outputHandle,   ; console output handle
       ADDR sky,   ; pointer to the top box line
       CMDWIDTH,   ; size of box line
       xyPosition,   ; coordinates of first char
       ADDR count    ; output count
 
    inc xyPosition.y   ; 座標換到下一行位置
    LOOP DRAW
    pop xyPosition
    ret
    characterMove ENDP

END main
