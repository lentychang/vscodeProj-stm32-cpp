This repo is a basic example configuring CMake and intellisense on vscode. The code itself is blinking LED and tested with STM32F446RE-nucleo

# Required VS Code extensions
- CMake-Tools
- Cortex-Debug

# Required Tools and their default location in this repository  
Please modify according to the path you installed these tools
-  [ObKo/stm32-cmake](https://github.com/ObKo/stm32-cmake.git)(git repo): `/usr/local/src/stm32-cmake`
- openocd(apt): `/usr/local/share/openocd`
- gcc-arm-none-eabi toolchain(download): `/usr/local/gcc-arm-none-eabi-9-2020-q2-update`
- stlink-tools
- STM32CubeMX package: `/opt/STM32Cube/Repository/STM32Cube_FW_F4_V1.25.0`


# 0. Installation
1. Install openocd, stm32-cmake, this repo
```bash
    sudo apt install openocd

    git clone https://github.com/stlink-org/stlink.git
    cd stlink && mkdir build && cd build
    cmake -DCMAKE_BUILD_TYPE=release
    sudo make install && cd ../../

    git clone https://github.com/ObKo/stm32-cmake.git
    sudo mv stm32-cmake /usr/local/src/

    git clone https://github.com/lentychang/vscodeProj-stm32-cpp.git
    sudo mv vscodeProj-stm32-cpp /usr/local/src/
    cp /usr/local/src/vscodeProj-stm32-cpp/gen_stm32_cppproj.sh ~/.local/bin/gen_stm32_cppproj  
```
2. Install gcc-arm-none-eabi  
    - [Download](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) desired version  
    - Extract to `/usr/local/`  

3. Modify the configuration files for VS Code  
    All json files are in `/usr/local/src/vscodeProj-stm32-cpp/.vscode`


# 1. Configuration
1. `settings.json`    
    Please update the shown values below. Example below is only partly shown.    
    Here we configure CMakeTools and cortex-debug extension.     
    ```json
    {
    "cmake.generator": "Unix Makefiles",
    "cmake.configureSettings": {
        "TOOLCHAIN_PREFIX": "/usr/local/gcc-arm-none-eabi-9-2020-q2-update",
        "STM32_CHIP": "STM32F446RE",
        "STM32Cube_DIR": "/opt/STM32Cube/Repository/STM32Cube_FW_F4_V1.25.0",
    },
    "cortex-debug.armToolchainPath": "/usr/local/gcc-arm-none-eabi-9-2020-q2-update/bin",
    "cortex-debug.openocdPath": "/usr/local/bin/openocd"
    }
    ```  
2. `cmake-kits.json`  
    Configuration of vscode extension cmake-tools where is toolchain file from stm32-cmake. Since we use toolchain file here, please do not specified `compliers` here, which leads to confliction.  
    ```json  
    [{
    "name": "C/C++ CMake-Kit for arm-none-eabi 9.3.1",
    "toolchainFile":"/usr/local/src/stm32-cmake/cmake/gcc_stm32.cmake"}]  
    ```   
    
3. `c_cpp_properties.json`   
    Configuration for intellisense. Please update `includePath`, `defines`, `c/cppStandards`, `compilerPath`  
    ps. for cStandard, you should always use gnu standard instead of  c standard, since STM32Cube HAL is written with gnu11, not c11 standard.
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
            "compilerPath": "/usr/local/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-g++",
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

4. `launch.json` for debugger   
    Please update `armToolchainPath`, `configFiles`, `searchDir`, `svdFile`  
    Example below is only partly shown  
    ```json  
    {
        "armToolchainPath": "/usr/local/gcc-arm-none-eabi-9-2020-q2-update/bin",
        "configFiles": ["/usr/local/share/openocd/scripts/board/st_nucleo_f4.cfg"],
        "searchDir":["/usr/local/share/openocd/scripts/board/"],
        "svdFile": "${workspaceFolder}/etc/STM32F446.svd"
    }
    ```

# 2. Convert STM32CubeIDE project to VS Code CMake project
1. Use STM32CubeMX to generate STM32CubeIDE proejct  
    If you select other type of projects, you have to modify gen_stm32_cppproj.sh to remove corresponding project files.
2. Now you can execute `gen_stm32_cppproj` from CLI at the root directory of your STM32CubeMX_generated_project. It renames directories and removes unnecessary files.
    ```
    $ gen_stm32_cppproj
    ```
    ps. If your `gen_stm32_cppproj` is not found, please check `/home/<username>/.local/bin` is in environment variable `PATH`

3. Relauch vscode, open Command Pallette, choose `CMake: Select a kit`, then it should automatically configure.
4. After flashing the code and restart your target, LED should blink after press user_button.

# Manually Setup from stm32-cmake   
If you don't want to use this repository, here are some steps to use stm32-cmake directly   

0. Install required tools and VS Code extensions  
1. Configure and generated code from STM32CubeMX.  
2. Copy all files in `<STM32CubeMX_generated_project>/Src` to `./src` except `system_stm32f4xx.c`  
3. Copy all header in `<STM32CubeMX_generated_project>/Inc` to `./include`  
4. Copy linker script to `./`. (XXX_FLASH.ld)
5. Finish the configuration below.
6. Relauch vscode, open Command Pallette, choose `CMake: Select a kit`, then it should automatically configure.
7. After flashing the code and restart your target, LED should blink after press user_button.


# Semihosting  
If you want to use printf to print message on host's terminal, or scanf from host's keyboard.  
   
0. enabling semihosting in openocd has been done in the launch.json (line25: `monitor arm semihosting enable`).  You can remove it if you don't need semihosting.  
1. uncomment `target_link_options` in CMakeLists.txt 
2. comment  `target_sources` with `syscall.c` in CMakeLists.txt 
3. Include header `stdio.h` in the source file and add `initialize_monitor_handle();` before while loop
4. Now printf should work. The printed out message is shown in **OUTPUT** panel  
  
ps. If you enable semihosting here, be aware that, the device will hang due to monitor_handle and will not start at all, unless you use debugger to run. So, if you want to test you program without debugger, remember to remove `initialize_monitor_handle();` and `printf` as well as revert the CMakeLists.txt

For CMake version before 3.14 use the following setting in CMakeLists.txt  
```CMake   
set_property(TARGET ${CMAKE_PROJECT_NAME} APPEND_STRING PROPERTY LINK_FLAGS " -specs=rdimon.specs -lc -lrdimon")  
```  

# Note  
- C/C++ intellisense (ms-vscode.cpptools) v0.30.0-insider Bug [#5906](https://github.com/microsoft/vscode-cpptools/issues/5906)
    It will fail autocomplete, you can use disable extension autoupdate and use version 0.29.0. It might be bug from CMakeTool.

## TODO
- Using STM32Programmer to flash
