@echo off
echo =======================================================
echo Compiling Scissor Mechanism Research Paper with Tectonic
echo =======================================================
"E:\Work\bin\tectonic.exe" main.tex
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Paper compiled successfully to main.pdf!
) else (
    echo.
    echo [ERROR] Compilation failed. Check the output above.
)
pause
