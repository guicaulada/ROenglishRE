#!/bin/bash

echo "================================================================="
echo "Welcome to the Lua Bundler!"
echo "This will help you bundle a Lua file and all its dependencies into a single file."
echo
echo "1. Move the file in the same folder or a sub-directory as this script."
echo "2. Use this script and follow the steps."
echo "3. The bundled file will be created with '.bundle.lua' extension."
echo "================================================================="
read -p "Press enter to continue..."

read -p "Please write the name of the sub-directory (leave it empty for none): " sub
echo "================================================================="
read -p "Please write the file name (eg.: itemInfo): " file

if [ -z "$file" ]; then
    echo "No file name provided, exiting..."
    exit 1
fi

echo "================================================================="
read -p "Please write the file's extension (eg.: .lua): " ext

if [ -z "$ext" ]; then
    echo "No extension provided, exiting..."
    exit 1
fi

# Determine the input file path
if [ -z "$sub" ]; then
    INPUT_PATH="$file$ext"
else
    INPUT_PATH="$sub/$file$ext"
fi

# Run the bundler
./bin/lua lua/bundler.lua "$INPUT_PATH"

echo "================================================================="
read -p "Press enter to exit..." 