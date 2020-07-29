CMAKE_MINIMUM_REQUIRED(VERSION 3.14)
PROJECT(vscodeProj-stm32-cpp C CXX ASM)


# This is for lazy configuration to use cmake from CLI
#######################################
# SET(TARGET_TRIPLET "arm-none-eabi")
# SET(CMAKE_TOOLCHAIN_FILE "<path_to_stm32-cmake>/cmake/gcc_stm32.cmake")
# SET(TOOLCHAIN_PREFIX "<path_to_gcc-arm-none-eabi-9-2020-q2-update>")
# SET(STM32_CHIP "<STM32_CHIP_MODEL>")
# SET(STM32Cube_DIR "<path_to_STM32Cube>/Repository/STM32Cube_FW_F4_V1.25.0")
# include(${CMAKE_TOOLCHAIN_FILE})
#######################################


# A double check and some basic hint when using cmake cli without any predifined setting, you can remove them if you want
#######################################
IF(NOT TOOLCHAIN_PREFIX)
message(FATAL_ERROR "Please specify -TOOLCHAIN_PREFIX=<path-to-toolchain-dir  when configuring\n
                     i.e. /usr/gcc-arm-none-eabi-9-2020-q2-update")
ENDIF()

IF(NOT CMAKE_TOOLCHAIN_FILE)
message(FATAL_ERROR "Please specify -DCMAKE_TOOLCHAIN_FILE=<path-to-gcc_stm32.cmake  when configuring\n
                     i.e. /usr/local/src/stm32-cmake/cmake/gcc_stm32.cmake")
ENDIF()

IF(NOT STM32_CHIP)
message(FATAL_ERROR "Please specify -DSTM32_CHIP=<chip-type> when configuring\n
                     i.e. STM32F446RE")
ENDIF()

IF(NOT STM32Cube_DIR)
message(FATAL_ERROR "please specify -DSTM32Cube_DIR=<path-to-STM32Cube_DIR> when configuring\n
                     i.e. /opt/STM32Cube/Repository/STM32Cube_FW_F4_V1.25.0")
ENDIF()

IF(NOT STM32_LINKER_SCRIPT)
message(STATUS "You can use STM32_LINKER_SCRIPT arg to assgin linker scripts")
ENDIF()
#######################################


FIND_PACKAGE(CMSIS REQUIRED)
# Add the components you need
FIND_PACKAGE(STM32HAL COMPONENTS gpio tim uart REQUIRED)

# add all source files from src. 
# Do not add system_stm32f4xx.c which will be included from ${CMSIS_SOURCES}
SET(PROJECT_SOURCES
    src/main.cpp
    src/stm32f4xx_hal_msp.c    
    src/stm32f4xx_it.c
    src/syscalls.c
    src/sysmem.c
)

ADD_EXECUTABLE(${CMAKE_PROJECT_NAME} ${PROJECT_SOURCES} ${CMSIS_SOURCES} ${STM32HAL_SOURCES})

TARGET_INCLUDE_DIRECTORIES(
    ${CMAKE_PROJECT_NAME}
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMSIS_INCLUDE_DIRS}
    ${STM32HAL_INCLUDE_DIR}
    include
)

# For Semihosting uncomment below and also exclude src/syscall.c from PROJECT_SOURCES 
# target_link_options(${CMAKE_PROJECT_NAME} PUBLIC "-specs=rdimon.specs" 
#                                                  "-lc" 
#                                                  "-lrdimon")

STM32_SET_TARGET_PROPERTIES(${CMAKE_PROJECT_NAME})
STM32_ADD_HEX_BIN_TARGETS(${CMAKE_PROJECT_NAME})
