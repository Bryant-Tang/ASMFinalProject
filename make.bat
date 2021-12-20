@echo off
REM make
REM Assembles and links the 32-bit ASM program into .exe which can be used by WinDBG
REM Uses MicroSoft Macro Assembler version 6.11 and 32-bit Incremental Linker version 5.10.7303
REM Created by Huang 

REM delete related files
del 109502536.lst	REM 109502536可以替換成.asm檔的檔名
del 109502536.obj
del 109502536.ilk
del 109502536.pdb
del 109502536.exe

setlocal 
set INCLUDE=windbg;	REM 這裡要設成WINdbgFolder的路徑
set LIB=windbg;
set PATH=windbg;

REM /c          assemble without linking
REM /coff       generate object code to be linked into flat memory model 
REM /Zi         generate symbolic debugging information for WinDBG
REM /Fl		Generate a listing file
 

ML /c /coff /Zi   109502536.asm
if errorlevel 1 goto terminate

REM /debug              generate symbolic debugging information
REM /subsystem:console  generate console application code
REM /entry:start        entry point from WinDBG to the program 
REM                           the entry point of the program must be _start

REM /out:109502536.exe         output 109502536.exe code
REM 109502536.obj              input 109502536.obj
REM Kernel32.lib        library procedures to be invoked from the program
REM irvine32.lib
REM user32.lib

LINK /INCREMENTAL:no /debug /subsystem:console /entry:start /out:109502536.exe 109502536.obj Kernel32.lib irvine32.lib user32.lib
if errorlevel 1 goto terminate

REM Display all files related to this program:
DIR 109502536.*

:terminate

endlocal