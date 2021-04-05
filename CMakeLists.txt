cmake_minimum_required(VERSION 3.14)
project(stm32vsCodeProj C CXX ASM)

# This is for lazy configuration to use cmake from CLI
# ##############################################################################
# SET(TARGET_TRIPLET "arm-none-eabi") SET(CMAKE_TOOLCHAIN_FILE
# "<path_to_stm32-cmake>/cmake/stm32_gcc.cmake") SET(TOOLCHAIN_PREFIX
# "<path_to_gcc-arm-none-eabi-9-2020-q2-update>") SET(STM32_CHIP
# "<STM32_CHIP_MODEL>") SET(STM32Cube_DIR
# "<path_to_STM32Cube>/Repository/STM32Cube_FW_F4_V1.26.1")
# include(${CMAKE_TOOLCHAIN_FILE}) SET(CMAKE_MODULE_PATH
# "/usr/local/src/stm32-cmake/cmake")

# Change to related familiy, here I use F4 SET(STM32_CUBE_F4_PATH)
# /opt/STM32Cube/Repository/STM32Cube_FW_F4_V1.26.1) SET(STM32_LINKER_SCRIPT
# <path_to_STM32F446RETX_FLASH.ld>)
# ##############################################################################

# A double check and some basic hint when using cmake cli without any predifined
# setting, you can remove them if you want
# ##############################################################################
if(NOT CMAKE_TOOLCHAIN_FILE)
  message(
    FATAL_ERROR
      "Please specify -DCMAKE_TOOLCHAIN_FILE=<path-to-stm32_gcc.cmake  when configuring\n
                     i.e. /usr/local/src/stm32-cmake/cmake/stm32_gcc.cmake")
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

# Fetch cmsis and hal directly stm32_fetch_cmsis(F4) stm32_fetch_hal(F4) Add the
# components you need
find_package(
  CMSIS 5.4.0
  COMPONENTS STM32F446RE
  REQUIRED)
# Add the components you need
find_package(
  HAL
  COMPONENTS STM32F446RE RCC GPIO UART CORTEX
  REQUIRED)

add_executable(${CMAKE_PROJECT_NAME} ${PROJECT_SOURCES})
target_sources(${CMAKE_PROJECT_NAME} PRIVATE src/main.cpp)

target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC include)

# For Semihosting comment below and also uncomment target_link_options. Be if no
# debugger is attached, CPU might crash.
# https://stackoverflow.com/questions/65453293/what-are-nosys-nano-rdimon-terms-when-using-arm-gcc
# target_link_options(${CMAKE_PROJECT_NAME} PRIVATE "-specs=rdimon.specs")
if(STM32_LINKER_SCRIPT)
  message(STATUS "Custom linker script:'${STM32_LINKER_SCRIPT}' is used.")
  stm32_add_linker_script(${CMAKE_PROJECT_NAME} PRIVATE ${STM32_LINKER_SCRIPT})
endif()

target_link_libraries(
  ${CMAKE_PROJECT_NAME}
  PUBLIC HAL::STM32::F4::RCC HAL::STM32::F4::GPIO HAL::STM32::F4::UART
         HAL::STM32::F4::CORTEX CMSIS::STM32::F446RE STM32::NoSys)
