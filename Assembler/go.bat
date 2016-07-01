\mingw\bin\asw -L game.asm
if errorlevel 1 goto norun
\mingw\bin\p2bin -r 0-4095 -l 0 game.p
del game.p
..\emulator\vip.exe game.bin
:norun
