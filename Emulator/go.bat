\mingw\bin\asw -L test.asm
if errorlevel 1 goto norun
\mingw\bin\p2bin -r 0-511 -l 0 test.p
del test.p
elf test.bin
:norun
