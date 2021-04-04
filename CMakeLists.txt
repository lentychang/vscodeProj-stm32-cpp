cmake_minimum_required(VERSION 3.14)
project(stm32vsCodeProj C CXX ASM)

# This is for lazy configuration to use cmake from CLI
# ##############################################################################
# SET(TARGET_TRIPLET "arm-none-eabi") SET(CMAKE_TOOLCHAIN_FILE
# "<path_to_stm32-cmake>/cmake/gcc_stm32.cmake") SET(TOOLCHAIN_PREFIX
# "<path_to_gcc-arm-none-eabi-9-2020-q2-update>") SET(STM32_CHIP
# "<STM32_CHIP_MODEL>") SET(STM32Cube_DIR
# "<path_to_STM32Cube>/Repository/STM32Cube_FW_F4_V1.25.0")
# include(${CMAKE_TOOLCHAIN_FILE})
# ##############################################################################

# A double check and some basic hint when using cmake cli without any predifined
# setting, you can remove them if you want
# ##############################################################################
if(NOT CMAKE_TOOLCHAIN_FILE)
  message(
    FATAL_ERROR
      "Please specify -DCMAKE_TOOLCHAIN_FILE=<path-to-gcc_stm32.cmake  when configuring\n
                     i.e. /usr/local/src/stm32-cmake/cmake/gcc_stm32.cmake")
endif()

if(NOT STM32_CHIP)
  message(
    FATAL_ERROR "Please specify -DSTM32_CHIP=<chip-type> when configuring\n
                     i.e. STM32F446RE")
endif()

if(NOT STM32_LINKER_SCRIPT)
  message(STATUS "You can use STM32_LINKER_SCRIPT arg to assgin linker scripts")
endif()
# ##############################################################################

# Fetch cmsis and hal directly
# stm32_fetch_cmsis(F4) stm32_fetch_hal(F4)
# Add the components you need
find_package(
  CMSIS 5.4.0
  COMPONENTS STM32F446RE
  REQUIRED)
# Add the components you need
find_package(
  HAL
  COMPONENTS STM32F446RE RCC GPIO UART CORTEX
  REQUIRED)

add_executable(${CMAKE_PROJECT_NAME} ${PROJECT_SOURCES} ${CMSIS_SOURCES}
                                     ${STM32HAL_SOURCES})

# add all source files from src. Do not add system_stm32f4xx.c which will be
# included from ${CMSIS_SOURCES}
target_sources(
  ${CMAKE_PROJECT_NAME}
  PRIVATE src/main.cpp
)

target_include_directories(
  ${CMAKE_PROJECT_NAME}
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${CMSIS_INCLUDE_DIRS}
         ${STM32HAL_INCLUDE_DIR} include)

# For Semihosting comment below and also uncomment target_link_options
# TARGET_SOURCES(${CMAKE_PROJECT_NAME} PRIVATE src/syscalls.c )
target_link_libraries(
  ${CMAKE_PROJECT_NAME}
  PUBLIC STM32::NoSys HAL::STM32::F4::RCC HAL::STM32::F4::GPIO
         HAL::STM32::F4::UART HAL::STM32::F4::CORTEX CMSIS::STM32::F446RE)
