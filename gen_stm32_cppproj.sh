#!/bin/bash

read -p "Do you want to configure stm32 cpp project for VS Code? [y/n]" yn
echo    # (optional) move to a new line
if [[ ! $yn =~ ^[Yy]$ ]]
then
    exit 1
fi


proj_name=${PWD##*/}
mkdir $proj_name

mv Core/Inc include
mv Core/Src src
mv Core/Src/main.c src/main.cpp
mv Core/Startup $proj_name/
mv Drivers $proj_name/
mv ./.* $proj_name/
mv *.ioc $proj_name/
mv *RAM.ld $proj_name/
trash $proj_name 
echo "Unneccessary files are collected in new directory $proj_name, which is thrown to trash!"
mkdir build

cp -r /usr/local/src/vscodeProj-stm32-cpp/.vscode .vscode
cp /usr/local/src/vscodeProj-stm32-cpp/CMakeLists.txt CMakeLists.txt

