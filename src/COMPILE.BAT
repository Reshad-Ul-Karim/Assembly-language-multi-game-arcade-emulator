@echo off

echo Compiling Rapid Roll Game...
tasm GAME.asm
tlink GAME.obj
ren GAME.exe RAPIDROLL.exe

echo Compiling Space Car...
tasm SPACECAR.asm
tlink SPACECAR.obj
ren SPACECAR.exe SPACECAR.exe

echo Compiling Menu...
tasm MERGED~1.asm
tlink MERGED~1.obj
ren MERGED~1.exe GAMES.exe

echo Done! 