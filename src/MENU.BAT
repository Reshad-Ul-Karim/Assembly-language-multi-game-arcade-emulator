@echo off
:menu
cls
echo === GAME COLLECTION ===
echo 1. Rapid Roll Game
echo 2. Space Car
echo 3. Snake
echo 4. Exit
choice /c:1234 /n /m "Enter your choice (1-4): "
if errorlevel 4 goto end
if errorlevel 3 goto snake
if errorlevel 2 goto spacecar
if errorlevel 1 goto rapidroll
goto menu

:rapidroll
RR.EXE
goto menu

:spacecar
SPACECAR.EXE
goto menu

:snake
SNAKE.COM
goto menu

:end 