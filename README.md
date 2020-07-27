This repo is a basic example configuring CMake and intellisense on vscode. The code itself is blinking LED and tested with STM32F446RE-nucleo

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
                "intelliSenseMode": "clang-x64",
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
    "name": "C/C++ cmake-kits: arm-none-eabi 9.3.1",
    "toolchainFile":"/usr/local/src/stm32-cmake/cmake/gcc_stm32.cmake"
  }]
    ```   
    
3. `tasks.json` (optional)  
    Configuration for st-flash.  
    ```json  
    {
    "tasks":  [       
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
    ],
    "version": "2.0.0"
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
            "intelliSenseMode": "clang-x64",
            "configurationProvider": "ms-vscode.cmake-tools"
        }
    ],
    "version": 4
    }
    ```

## TODO
- Using STM32Programmer to 
- Debugger configuring
