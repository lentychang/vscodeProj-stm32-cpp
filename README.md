This repo is a basic example configuring CMake and intellisense on vscode. The code itself is blinking LED and tested with STM32F446RE-nucleo

# Required VS Code extensions
- CMake-Tools
- Cortex-Debug

# Setup project folder  
0. Clone [ObKo/stm32-cmake](https://github.com/ObKo/stm32-cmake.git) somewhere
1. Configure and generated code from STM32CubeMX.
2. Copy all files in `STM32CubeMX_generated_project/Src` to `./src` except `system_stm32f4xx.c`
3. Copy all header in `STM32CubeMX_generated_project/Inc` to `./include`
4. Copy linker script to `./src`. (XXX_FLASH.ld)
5. Finish the configuration below.
6. Relauch vscode, open Command Pallette, choose `CMake: Select a kit`, then it should automatically configure.
7. After flashing the code and restart your target, LED should blink after press user_button.

## Configuration
1. `settings.json`    
    Please update `cmake.configureSettings`. Those arguments will be added when configuring with cmake. See example below
    ```json
    {
        "configurations": [
            {
                "name": "Linux-arm-cross-platform",
                "includePath": [
                    "${workspaceFolder}/**",
                    "/opt/STM32Cube/Repository/STM32Cube_FW_F4_V1.25.0/**"
                ],
                "defines": ["STM32F446xx","USE_HAL_DRIVER"],
                "compilerPath": "/usr/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-g++",
                "cStandard": "gnu11",
                "cppStandard": "gnu++14",
                "compileCommands": "${workspaceFolder}/build/compile_commands.json",
                "intelliSenseMode": "gcc-arm",
                "configurationProvider": "ms-vscode.cmake-tools"
            }
        ],
        "version": 4
    }
    ```
2. `cmake-kits.json`  
    Configuration of vscode extension cmake-tools where is toolchain file from stm32-cmake. Since we use toolchain file here, please do not specified `compliers` here, which leads to confliction.  
    ```json  
    [{
    "name": "C/C++ CMake-Kit for arm-none-eabi 9.3.1",
    "toolchainFile":"/usr/local/src/stm32-cmake/cmake/gcc_stm32.cmake"}]  
    ```   
    
3. `tasks.json` (optional)  
    Configuration for st-flash.  
    ```json  
    {
        "version": "2.0.0",
        "tasks": [
            {
                "type": "shell",
                "label": "build",
                "command": "cmake --build ${workspaceFolder}/build --config Debug",
                "args": [
                
                ],
                "options": {
                    "cwd": "${workspaceFolder}/build"
                },
                "problemMatcher": [
                    "$gcc"
                ],
                "group": {
                    "kind": "build",
                    "isDefault": true
                }
            },
            {
                "type": "shell",
                "label": "Flash program",
                "command": "st-flash",
                "args": [
                    "write",
                    "${workspaceFolderBasename}.bin",
                    "0x8000000"
                ],
                "options": {
                    "cwd": "${workspaceFolder}/build"
                },
                "problemMatcher": []
        }
        ]
    }
    ```  

4. `c_cpp_properties.json` (optional)  
    Configuration for intellisense. Please update `includePath`, `defines`, `c/cppStandards`  
    ```json  
    {
    "configurations": [
        {
            "name": "Linux-arm-cross-platform",
            "includePath": [
                "${workspaceFolder}/**",
                "/opt/STM32Cube/Repository/STM32Cube_FW_F4_V1.25.0/**"
            ],
            "defines": ["STM32F446xx","USE_HAL_DRIVER"],
            "compilerPath": "/usr/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-g++",
            "cStandard": "gnu11",
            "cppStandard": "gnu++14",
            "compileCommands": "${workspaceFolder}/build/compile_commands.json",
            "intelliSenseMode": "gcc-arm",
            "configurationProvider": "ms-vscode.cmake-tools"
        }
    ],
    "version": 4
    }
    ```

5. `launch.json` for debugger  
    ```json  
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "cortex-debug",
                "type": "cortex-debug",
                "request": "launch",
                "cwd": "${workspaceRoot}/build",
                "executable": "${workspaceRoot}/build/${workspaceFolderBasename}",
                "servertype": "openocd",
                "interface": "swd",
                "device": "STM32F446RE",
                "runToMain": true,
                "preRestartCommands": [
                    "target remote localhost:3333",
                    "add-symbol-file ${workspaceFolderBasename}",
                    "enable breakpoint",
                    "monitor reset"
                ],
                "armToolchainPath": "/usr/local/gcc-arm-none-eabi-9-2020-q2-update/bin",
                "configFiles": ["/usr/local/share/openocd/scripts/board/st_nucleo_f4.cfg"],
                "searchDir":["/usr/local/share/openocd/scripts/board/"],
                "svdFile": "${workspaceFolder}/etc/STM32F446.svd",
                "preLaunchTask": "build"
            }
        ]
    }
    ```

# Semihosting  
If you want to use printf to print message on host's terminal, or scanf from host's keyboard.  
## Steps  
0. enabling semihosting in openocd has been done in the launch.json (line25: `monitor arm semihosting enable`).  You can remove it if you don't need semihosting.
1. uncomment `target_link_options` in CMakeLists.txt  
2. Include header `stdio.h` in the source file  
3. Exclude syscall.c from compilation, which means, temove it from PROJECT_SOURCES in CMakeList.txt  

For CMake version before 3.14 use the following setting in CMakeLists.txt  
```CMake   
set_property(TARGET ${CMAKE_PROJECT_NAME} APPEND_STRING PROPERTY LINK_FLAGS " -specs=rdimon.specs -lc -lrdimon")  
```  

## TODO
- Using STM32Programmer to flash
