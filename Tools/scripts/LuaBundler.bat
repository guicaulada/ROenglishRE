@echo off
echo =================================================================
echo Welcome to the Lua Bundler!
echo This will help you bundle a Lua file and all its dependencies into a single file.
echo.
echo 1. Move the file in the same folder or a sub-directory as this script.
echo 2. Use this script and follow the steps.
echo 3. The bundled file will be created with '.bundle.lua' extension.
echo =================================================================
pause

set /p "sub=Please write the name of the sub-directory (leave it empty for none): "
echo =================================================================
set /p "file=Please write the file name (eg.: itemInfo): "

if "%file%"=="" (
    echo No file name provided, exiting...
    pause
    exit /b 1
)

echo =================================================================
set /p "ext=Please write the file's extension (eg.: .lua): "

if "%ext%"=="" (
    echo No extension provided, exiting...
    pause
    exit /b 1
)

:: Determine the input file path
if "%sub%"=="" (
    set "INPUT_PATH=%file%%ext%"
) else (
    set "INPUT_PATH=%sub%\%file%%ext%"
)

:: Run the bundler
./bin/lua.exe bundler.lua "%INPUT_PATH%"

echo =================================================================
pause 