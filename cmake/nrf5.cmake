# MIT License

# Copyright (c) 2019 Polidea

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

include("nrf5_utils")
include("nrf5_validate")

# Check nRF SDK
set(NRF5_SDK_PATH "" CACHE PATH "Path to the nRF5 SDK")
set(NRF5_SDK_VERSION "" CACHE STRING "nRF5 SDK version, e.g.: 15.3.0")

nrf5_validate_sdk(${NRF5_SDK_PATH} local_sdk_version)
if(NOT NRF5_SDK_VERSION)
  message(STATUS "nRF SDK version not explicitly provided, using deduced one: ${local_sdk_version}")
  set(NRF5_SDK_VERSION ${local_sdk_version})
else()
  message(STATUS "nRF SDK version ${local_sdk_version} overwritten by ${NRF5_SDK_VERSION}")
endif()
nrf5_validate_sdk_version(${NRF5_SDK_VERSION})

# Check supported board type (based on SDK version as well)
set(NRF5_BOARD "" CACHE STRING "nRF5 DK board e.g. pca10040, pca10056, pca10059")
set(NRF5_TARGET "" CACHE STRING "nRF5 target name e.g. nrf52810, nrf52832, nrf52840")

if(NRF5_BOARD)
  string(TOLOWER ${NRF5_BOARD} NRF5_BOARD)
  nrf5_validate_board(${NRF5_SDK_VERSION} ${NRF5_BOARD} local_board_target local_board_define)
  set(NRF5_BOARD_DEFINE ${local_board_define})
  if(NOT NRF5_TARGET)
    set(NRF5_TARGET ${local_board_target})
    message(STATUS "nRF5 target for board ${NRF5_BOARD} not specified, using: ${NRF5_TARGET}")
  else()
    string(TOLOWER ${NRF5_TARGET} NRF5_TARGET)
    string(COMPARE NOTEQUAL ${NRF5_TARGET} ${local_board_target} board_target_overwritten)
    if(board_target_overwritten)
      message(WARNING "Default nRF5 target for board ${NRF5_BOARD} (${local_board_target}) overwritten by ${NRF5_TARGET}")
    endif()
  endif()
  message(STATUS "Using nRF5 DK board: ${NRF5_BOARD}")
endif()

# Check supported target
if(NRF5_TARGET)
  nrf5_validate_target(${NRF5_TARGET})
else()
  message(FATAL_ERROR "NRF5_TARGET not specified")
endif()

message(STATUS "Using nRF5 target: ${NRF5_TARGET}")


set(NRF5_LINKER_SCRIPT "" CACHE FILEPATH "Linker script file. If not specified, a generic script for a selected target will be used.")
if(NRF5_LINKER_SCRIPT)
  if(NOT EXISTS ${NRF5_LINKER_SCRIPT})
    message(FATAL_ERROR "Linker script file (NRF5_LINKER_SCRIPT) doesn't exist: ${NRF5_LINKER_SCRIPT}")
  endif()
else()
  set(NRF5_LINKER_SCRIPT "${NRF5_SDK_PATH}/config/${NRF5_TARGET}/armgcc/generic_gcc_nrf52.ld" CACHE FILEPATH "" FORCE)
endif()

message(STATUS "Using linker script: ${NRF5_LINKER_SCRIPT}")

set(NRF5_SDKCONFIG_PATH "" CACHE PATH "Path to the sdk_config.h file. If not specified, a generic sdk_config.h for a selected target file will be used.")
if(NOT NRF5_SDKCONFIG_PATH)
  set(NRF5_SDKCONFIG_PATH "${NRF5_SDK_PATH}/config/${NRF5_TARGET}/config" CACHE PATH "" FORCE)
endif()

set(NRF5_APPCONFIG_PATH "" CACHE PATH "Path to the app_config.h file. If not specified, app_config.h will not be used.")

message(STATUS "Using sdk_config.h include path: ${NRF5_SDKCONFIG_PATH}")

if(NRF5_APPCONFIG_PATH)
  message(STATUS "Using app_config.h include path: ${NRF5_APPCONFIG_PATH}")
endif()

set(NRF5_NRFJPROG "" CACHE FILEPATH "nrfjprog utility executable file. If not specified, it is assumed that nrfjprog is available from PATH.")
if(NOT NRF5_NRFJPROG)
  set(NRF5_NRFJPROG "nrfjprog" CACHE FILEPATH "" FORCE)
  message(STATUS "Using nrfjprog utility available from PATH")
else()
  message(STATUS "Using nrfjprog utility: ${NRF5_NRFJPROG}")
endif()

set(NRF5_SOFTDEVICE_VARIANT "" CACHE STRING "SoftDevice variant. If not specified, a variant typical for the specified target will be used.")

set(NRF5_SOFTDEVICE_HEX "" CACHE FILEPATH "SoftDevice HEX file. If not specified, a SoftDevice file typical for specified the target found in the SDK will be used.")
if(NOT NRF5_SOFTDEVICE_HEX)
  nrf5_get_softdevice_variant(softdevice_variant ${NRF5_TARGET})
  nrf5_find_softdevice_file(softdevice_hex "${NRF5_SDK_PATH}/components/softdevice" ${softdevice_variant})
  if(NOT softdevice_hex)
    message(FATAL_ERROR "Unable to find SoftDevice HEX file for the ${softdevice_variant} variant")
  endif()
  set(NRF5_SOFTDEVICE_VARIANT ${softdevice_variant} CACHE STRING "" FORCE)
  set(NRF5_SOFTDEVICE_HEX ${softdevice_hex} CACHE FILEPATH "" FORCE)
else()
  if(NOT NRF5_SOFTDEVICE_VARIANT)
    message(FATAL_ERROR "When using custom SoftDevice HEX file, you must specify the SoftDevice variant (NRF5_SOFTDEVICE_VARIANT) e.g. S112, S132, S140")
  endif()
  nrf5_validate_softdevice_variant(${NRF5_SOFTDEVICE_VARIANT})
endif()

message(STATUS "Using SoftDevice HEX file: ${NRF5_SOFTDEVICE_HEX}")
message(STATUS "Using SoftDevice variant: ${NRF5_SOFTDEVICE_VARIANT}")

string(TOLOWER ${NRF5_SOFTDEVICE_VARIANT} NRF5_SOFTDEVICE_VARIANT_LOWER)
string(TOUPPER ${NRF5_SOFTDEVICE_VARIANT} NRF5_SOFTDEVICE_VARIANT_UPPER)

nrf5_get_device_name(NRF5_DEVICE_NAME ${NRF5_TARGET})
nrf5_get_mdk_postfix(NRF5_MDK_POSTFIX ${NRF5_TARGET})

add_library(nrf5_config INTERFACE)
target_include_directories(nrf5_config INTERFACE "${NRF5_SDKCONFIG_PATH}")
if(NRF5_APPCONFIG_PATH)
  target_include_directories(nrf5_config INTERFACE "${NRF5_APPCONFIG_PATH}")
  target_compile_definitions(nrf5_config INTERFACE USE_APP_CONFIG)
endif()

# Microcontroller Development Kit (MDK)
add_library(nrf5_mdk OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/modules/nrfx/mdk/gcc_startup_${NRF5_MDK_POSTFIX}.S"
  "${NRF5_SDK_PATH}/modules/nrfx/mdk/system_${NRF5_MDK_POSTFIX}.c"
)
target_include_directories(nrf5_mdk PUBLIC
  "${NRF5_SDK_PATH}/components/toolchain/cmsis/include"
  "${NRF5_SDK_PATH}/modules/nrfx/mdk"
)
target_compile_definitions(nrf5_mdk PUBLIC
  ${NRF5_DEVICE_NAME}
)

# SoC header files (SoftDevice variant)
# NOTE: there is another variant of this dependency for non-SoftDevice projects but it is not supported by this solution
add_library(nrf5_soc INTERFACE)
target_include_directories(nrf5_soc INTERFACE
  "${NRF5_SDK_PATH}/components/softdevice/${NRF5_SOFTDEVICE_VARIANT_LOWER}/headers"
  "${NRF5_SDK_PATH}/components/softdevice/${NRF5_SOFTDEVICE_VARIANT_LOWER}/headers/nrf52"
)
target_compile_definitions(nrf5_soc INTERFACE
  SOFTDEVICE_PRESENT  
  ${NRF5_SOFTDEVICE_VARIANT_UPPER}
)

# strerror (error to string converion)
add_library(nrf5_strerror OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/strerror/nrf_strerror.c"
)
target_include_directories(nrf5_strerror PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/strerror"
)
target_link_libraries(nrf5_strerror PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Section variables (experimental)
add_library(nrf5_section OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/experimental_section_vars/nrf_section_iter.c"
)
target_include_directories(nrf5_section PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/experimental_section_vars"
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_section nrf5_config nrf5_mdk nrf5_soc)

# fprintf
add_library(nrf5_fprintf OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/external/fprintf/nrf_fprintf.c"
  "${NRF5_SDK_PATH}/external/fprintf/nrf_fprintf_format.c"
)
target_include_directories(nrf5_fprintf PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/external/fprintf"
)
target_link_libraries(nrf5_fprintf PUBLIC nrf5_mdk nrf5_soc nrf5_config)

# Atomic
add_library(nrf5_atomic OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/atomic/nrf_atomic.c"
)
target_include_directories(nrf5_atomic PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/atomic"
)
target_link_libraries(nrf5_atomic PUBLIC nrf5_mdk nrf5_soc nrf5_config)

# Mutex
add_library(nrf5_mtx INTERFACE)
target_include_directories(nrf5_mtx INTERFACE
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/mutex"
)
target_link_libraries(nrf5_mtx INTERFACE nrf5_atomic)

# Logger forwarding interface (include directories only)
add_library(nrf5_log_fwd INTERFACE)
target_include_directories(nrf5_log_fwd INTERFACE
  "${NRF5_SDK_PATH}/components/libraries/log"
  "${NRF5_SDK_PATH}/components/libraries/log/src"
)

# SoftDevice handler
add_library(nrf5_sdh OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/softdevice/common/nrf_sdh.c"
)
target_include_directories(nrf5_sdh PUBLIC
"${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/softdevice/common"
)
target_link_libraries(nrf5_sdh PUBLIC nrf5_section nrf5_log_fwd nrf5_strerror)

# Power management
add_library(nrf5_pwr_mgmt OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/pwr_mgmt/nrf_pwr_mgmt.c"
)
target_include_directories(nrf5_pwr_mgmt PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/pwr_mgmt"
)
target_link_libraries(nrf5_pwr_mgmt PUBLIC nrf5_mtx nrf5_section nrf5_nrfx_hal nrf5_log_fwd nrf5_memobj nrf5_sdh)

# Queue
add_library(nrf5_queue OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/queue/nrf_queue.c"
)
target_include_directories(nrf5_queue PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/queue"
)
target_link_libraries(nrf5_queue PUBLIC nrf5_section nrf5_log_fwd nrf5_strerror)

# Command Line Interface (CLI)
add_library(nrf5_cli OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/cli/nrf_cli.c"
)
target_include_directories(nrf5_cli PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/cli"
)
target_link_libraries(nrf5_cli PUBLIC nrf5_atomic nrf5_section nrf5_log_fwd nrf5_memobj nrf5_queue nrf5_fprintf nrf5_delay nrf5_nrfx_common nrf5_pwr_mgmt)

# Block allocator
add_library(nrf5_balloc OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/balloc/nrf_balloc.c"
)
target_include_directories(nrf5_balloc PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/balloc"
)
target_link_libraries(nrf5_balloc PUBLIC nrf5_section nrf5_log_fwd nrf5_soc nrf5_strerror)

# Memory object
add_library(nrf5_memobj OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/memobj/nrf_memobj.c"
)
target_include_directories(nrf5_memobj PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/memobj"
)
target_link_libraries(nrf5_memobj PUBLIC nrf5_balloc nrf5_atomic)

# Memory Manager
add_library(nrf5_mem_manager OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/mem_manager/mem_manager.c"
)
target_include_directories(nrf5_mem_manager PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/mem_manager"
)
target_link_libraries(nrf5_mem_manager PUBLIC nrf5_log)

# Ring buffer
add_library(nrf5_ringbuf OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/ringbuf/nrf_ringbuf.c"
)
target_include_directories(nrf5_ringbuf PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/ringbuf"
)
target_link_libraries(nrf5_ringbuf PUBLIC nrf5_atomic)

# Atomic FIFO
add_library(nrf5_atfifo OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/atomic_fifo/nrf_atfifo.c"
)
target_include_directories(nrf5_atfifo PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/atomic_fifo"
)
target_link_libraries(nrf5_atfifo PUBLIC nrf5_section nrf5_log_fwd nrf5_strerror)

# Atomic flags
add_library(nrf5_atflags OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/atomic_flags/nrf_atflags.c"
)
target_include_directories(nrf5_atflags PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/atomic_flags"
)
target_link_libraries(nrf5_atflags PUBLIC nrf5_atomic)

# File storage
add_library(nrf5_fstorage OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/fstorage/nrf_fstorage.c"
  "${NRF5_SDK_PATH}/components/libraries/fstorage/nrf_fstorage_sd.c"
)
target_include_directories(nrf5_fstorage PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/fstorage"
)
target_link_libraries(nrf5_fstorage PUBLIC nrf5_section nrf5_log_fwd nrf5_strerror nrf5_sdh nrf5_atomic nrf5_atfifo)

# File data storage
add_library(nrf5_fds OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/fds/fds.c"
)
target_include_directories(nrf5_fds PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/fds"
)
target_link_libraries(nrf5_fds PUBLIC nrf5_fstorage)

# Logger (frontend & formatter)
add_library(nrf5_log OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/log/src/nrf_log_frontend.c"
  "${NRF5_SDK_PATH}/components/libraries/log/src/nrf_log_str_formatter.c"
)
target_include_directories(nrf5_log PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/log"
  "${NRF5_SDK_PATH}/components/libraries/log/src"
)
target_link_libraries(nrf5_log PUBLIC nrf5_config nrf5_mdk nrf5_soc nrf5_section nrf5_strerror nrf5_memobj nrf5_fprintf nrf5_ringbuf nrf5_cli nrf5_fds)

# Logger Serial backend
add_library(nrf5_log_backend_serial OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/log/src/nrf_log_backend_serial.c"
)
target_link_libraries(nrf5_log_backend_serial PUBLIC nrf5_log)

# Logger UART backend
add_library(nrf5_log_backend_uart OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/log/src/nrf_log_backend_uart.c"
)
target_link_libraries(nrf5_log_backend_uart PUBLIC nrf5_log nrf5_drv_uart)

# Segger RTT
add_library(nrf5_ext_segger_rtt OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/external/segger_rtt/SEGGER_RTT.c"
)
target_include_directories(nrf5_ext_segger_rtt PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/external/segger_rtt"
)
target_link_libraries(nrf5_ext_segger_rtt PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Logger RTT backend
add_library(nrf5_log_backend_rtt OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/log/src/nrf_log_backend_rtt.c"
)
target_link_libraries(nrf5_log_backend_rtt PUBLIC nrf5_log nrf5_ext_segger_rtt)

# Logger (default backends)
add_library(nrf5_log_default_backends OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/log/src/nrf_log_default_backends.c"
)
target_link_libraries(nrf5_log_default_backends PUBLIC nrf5_log)

# Application error
add_library(nrf5_app_error OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/util/app_error.c"  
  "${NRF5_SDK_PATH}/components/libraries/util/app_error_weak.c"
  "${NRF5_SDK_PATH}/components/libraries/util/app_error_handler_gcc.c"
)
target_include_directories(nrf5_app_error PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_error PUBLIC nrf5_mdk nrf5_soc nrf5_log nrf5_section nrf5_strerror nrf5_memobj)

# Application platform utilities
add_library(nrf5_app_util_platform OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/util/app_util_platform.c"
)
target_include_directories(nrf5_app_util_platform PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_util_platform PUBLIC nrf5_mdk nrf5_soc)

# Scheduler
add_library(nrf5_app_scheduler OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/scheduler/app_scheduler.c"
)
target_include_directories(nrf5_app_scheduler PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/scheduler"
)
target_link_libraries(nrf5_app_scheduler PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Application timer
add_library(nrf5_app_timer OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/timer/app_timer.c"
)
target_include_directories(nrf5_app_timer PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/timer"
)
target_link_libraries(nrf5_app_timer PUBLIC nrf5_app_scheduler nrf5_delay nrf5_nrfx_hal)

# nrfx Peripheral Resource Sharing (PRS)
add_library(nrf5_nrfx_prs OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/modules/nrfx/drivers/src/prs/nrfx_prs.c"
)
target_include_directories(nrf5_nrfx_prs PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/modules/nrfx/drivers/src/prs"
)
target_link_libraries(nrf5_nrfx_prs PUBLIC nrf5_log)

# GPIOTE nrfx driver
add_library(nrf5_nrfx_gpiote OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/modules/nrfx/drivers/src/nrfx_gpiote.c"
)
target_include_directories(nrf5_nrfx_gpiote PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/modules/nrfx/drivers/include"
  "${NRF5_SDK_PATH}/integration/nrfx/legacy"
)
target_link_libraries(nrf5_nrfx_gpiote PUBLIC nrf5_log nrf5_nrfx_common)

# UART (EasyDMA) nrfx driver
add_library(nrf5_nrfx_uarte OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/modules/nrfx/drivers/src/nrfx_uarte.c"
)
target_include_directories(nrf5_nrfx_uarte PUBLIC
  "${NRF5_SDK_PATH}/modules/nrfx/drivers/include"
)
target_link_libraries(nrf5_nrfx_uarte PUBLIC nrf5_log nrf5_nrfx_common)

# UART (no EasyDMA) nrfx driver
add_library(nrf5_nrfx_uart OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/modules/nrfx/drivers/src/nrfx_uart.c"
)
target_include_directories(nrf5_nrfx_uart PUBLIC
  "${NRF5_SDK_PATH}/modules/nrfx/drivers/include"
)
target_link_libraries(nrf5_nrfx_uart PUBLIC nrf5_log nrf5_nrfx_common)

# UART legacy driver
add_library(nrf5_drv_uart OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/integration/nrfx/legacy/nrf_drv_uart.c"
)
target_include_directories(nrf5_drv_uart PUBLIC
  "${NRF5_SDK_PATH}/integration/nrfx/legacy"
)
target_link_libraries(nrf5_drv_uart PUBLIC nrf5_nrfx_uarte nrf5_nrfx_uart)

# Application button
add_library(nrf5_app_button OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/button/app_button.c"
)
target_include_directories(nrf5_app_button PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/button"
)
target_link_libraries(nrf5_app_button PUBLIC nrf5_app_timer nrf5_nrfx_gpiote)

# Application FIFO
add_library(nrf5_app_fifo OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/fifo/app_fifo.c"
)
target_include_directories(nrf5_app_fifo PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/fifo"
)
target_link_libraries(nrf5_app_fifo PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Application UART
add_library(nrf5_app_uart OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/uart/app_uart.c"
)
target_include_directories(nrf5_app_uart PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/uart"
)
target_link_libraries(nrf5_app_uart PUBLIC nrf5_config nrf5_mdk nrf5_soc nrf5_drv_uart)

# Application UART (with FIFO)
add_library(nrf5_app_uart_fifo OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/uart/app_uart_fifo.c"
)
target_include_directories(nrf5_app_uart_fifo PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/uart"
)
target_link_libraries(nrf5_app_uart_fifo PUBLIC nrf5_config nrf5_mdk nrf5_soc nrf5_drv_uart nrf5_app_fifo)

# Stack Info
add_library(nrf5_stack_info INTERFACE)
target_include_directories(nrf5_stack_info INTERFACE
  "${NRF5_SDK_PATH}/components/libraries/stack_info"
)

# SVC
add_library(nrf5_svc OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/svc/nrf_svc_handler.c"
)
target_include_directories(nrf5_svc PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/svc"
)
target_link_libraries(nrf5_svc PUBLIC nrf5_section)

# Sensor Data Simulator
add_library(nrf5_sensorsim OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/sensorsim/sensorsim.c"
)
target_include_directories(nrf5_sensorsim PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/sensorsim"
)

# CC310 library forwarding interface (external, include directories only)
add_library(nrf5_ext_cc310_fwd INTERFACE)
target_include_directories(nrf5_ext_cc310_fwd INTERFACE
  "${NRF5_SDK_PATH}/external/nrf_cc310/include"
)

# mbedTLS library forwarding interface (external, include directories only)
add_library(nrf5_ext_mbedtls_fwd INTERFACE)
target_include_directories(nrf5_ext_mbedtls_fwd INTERFACE
  "${NRF5_SDK_PATH}/external/mbedtls/include"
)

# nRF Crypto forwarding interface (include directories only)
add_library(nrf5_crypto_fwd INTERFACE)
target_include_directories(nrf5_crypto_fwd INTERFACE
  "${NRF5_SDK_PATH}/components/libraries/crypto"
)

# Crypto CC310 backend
add_library(nrf5_crypto_cc310_backend OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_aes.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_aes_aead.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_chacha_poly_aead.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_ecc.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_ecdh.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_ecdsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_eddsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_hash.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_hmac.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_init.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_mutex.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_rng.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310/cc310_backend_shared.c"
)
target_include_directories(nrf5_crypto_cc310_backend PUBLIC
"${NRF5_SDK_PATH}/components/libraries/util"
"${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310"
)
target_link_libraries(nrf5_crypto_cc310_backend PUBLIC nrf5_mtx nrf5_nrfx_common nrf5_ext_cc310_fwd)

# Crypto CC310 BL backend
add_library(nrf5_crypto_cc310_bl_backend OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310_bl/cc310_bl_backend_ecc.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310_bl/cc310_bl_backend_ecdsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310_bl/cc310_bl_backend_hash.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310_bl/cc310_bl_backend_init.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310_bl/cc310_bl_backend_shared.c"
)
target_include_directories(nrf5_crypto_cc310_bl_backend PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cc310_bl"
)
target_link_libraries(nrf5_crypto_cc310_bl_backend PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Crypto Cifra backend
add_library(nrf5_crypto_cifra_backend OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cifra/cifra_backend_aes_aead.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cifra/cifra_backend_aes_aead.c"
)
target_include_directories(nrf5_crypto_cifra_backend PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/cifra"
)
target_link_libraries(nrf5_crypto_cifra_backend PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Crypto mbedTLS backend
add_library(nrf5_crypto_mbedtls_backend OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls/mbedtls_backend_aes.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls/mbedtls_backend_aes_aead.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls/mbedtls_backend_ecc.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls/mbedtls_backend_ecdh.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls/mbedtls_backend_ecdsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls/mbedtls_backend_hash.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls/mbedtls_backend_hmac.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls/mbedtls_backend_init.c"
)
target_include_directories(nrf5_crypto_mbedtls_backend PUBLIC
"${NRF5_SDK_PATH}/components/libraries/util"
"${NRF5_SDK_PATH}/components/libraries/crypto/backend/mbedtls"
)
target_link_libraries(nrf5_crypto_mbedtls_backend PUBLIC nrf5_mdk nrf5_soc nrf5_nrfx_common nrf5_crypto_fwd nrf5_ext_mbedtls_fwd)

# Crypto micro-ecc backend
add_library(nrf5_crypto_micro_ecc_backend OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/micro_ecc/micro_ecc_backend_ecc.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/micro_ecc/micro_ecc_backend_ecdh.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/micro_ecc/micro_ecc_backend_ecdsa.c"
)
target_include_directories(nrf5_crypto_micro_ecc_backend PUBLIC
"${NRF5_SDK_PATH}/components/libraries/util"
"${NRF5_SDK_PATH}/components/libraries/crypto/backend/micro_ecc"
)
target_link_libraries(nrf5_crypto_micro_ecc_backend PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Crypto Oberon backend
add_library(nrf5_crypto_oberon_backend OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/oberon/oberon_backend_chacha_poly_aead.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/oberon/oberon_backend_ecc.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/oberon/oberon_backend_ecdh.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/oberon/oberon_backend_ecdsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/oberon/oberon_backend_eddsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/oberon/oberon_backend_hash.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/oberon/oberon_backend_hmac.c"
)
target_include_directories(nrf5_crypto_oberon_backend PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/oberon"
)
target_link_libraries(nrf5_crypto_oberon_backend PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Crypto nRF HW backend
add_library(nrf5_crypto_nrf_hw_backend OBJECT EXCLUDE_FROM_ALL
"${NRF5_SDK_PATH}/components/libraries/crypto/backend/nrf_hw/nrf_hw_backend_init.c"
"${NRF5_SDK_PATH}/components/libraries/crypto/backend/nrf_hw/nrf_hw_backend_rng.c"
"${NRF5_SDK_PATH}/components/libraries/crypto/backend/nrf_hw/nrf_hw_backend_rng_mbedtls.c"
)
target_include_directories(nrf5_crypto_nrf_hw_backend PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/nrf_hw"
)
target_link_libraries(nrf5_crypto_nrf_hw_backend PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Crypto nRF SW backend
add_library(nrf5_crypto_nrf_sw_backend OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/nrf_sw/nrf_sw_backend_hash.c"
)
target_include_directories(nrf5_crypto_nrf_sw_backend PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/nrf_sw"
)
target_link_libraries(nrf5_crypto_nrf_sw_backend PUBLIC nrf5_config nrf5_mdk nrf5_soc)

# Crypto Optiga backend
add_library(nrf5_crypto_optiga_backend OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/optiga/optiga_backend_ecc.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/optiga/optiga_backend_ecdh.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/optiga/optiga_backend_ecdsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/optiga/optiga_backend_init.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/optiga/optiga_backend_rng.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/optiga/optiga_backend_utils.c"
)
target_include_directories(nrf5_crypto_optiga_backend PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/libraries/crypto/backend/optiga"
)
target_link_libraries(nrf5_crypto_optiga_backend PUBLIC nrf5_config nrf5_mdk nrf5_soc nrf5_crypto_fwd)

# Crypto
add_library(nrf5_crypto OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_aead.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_aes.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_aes_shared.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_ecc.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_ecdh.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_ecdsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_eddsa.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_error.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_hash.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_hkdf.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_hmac.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_init.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_rng.c"
  "${NRF5_SDK_PATH}/components/libraries/crypto/nrf_crypto_shared.c"
)
target_include_directories(nrf5_crypto PUBLIC
"${NRF5_SDK_PATH}/components/libraries/util"
"${NRF5_SDK_PATH}/components/libraries/svc"
"${NRF5_SDK_PATH}/components/libraries/crypto"
)
target_link_libraries(nrf5_crypto PUBLIC
  nrf5_section
  nrf5_log
  nrf5_stack_info
  nrf5_svc
  nrf5_crypto_cc310_backend
  nrf5_crypto_cc310_bl_backend
  nrf5_crypto_cifra_backend
  nrf5_crypto_mbedtls_backend
  nrf5_crypto_micro_ecc_backend
  nrf5_crypto_oberon_backend
  nrf5_crypto_nrf_hw_backend
  nrf5_crypto_nrf_sw_backend
  nrf5_crypto_optiga_backend
)

# Boards
add_library(nrf5_boards OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/boards/boards.c"
)
target_include_directories(nrf5_boards PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/boards"
)
if(NRF5_BOARD)
  target_compile_definitions(nrf5_boards PUBLIC ${NRF5_BOARD_DEFINE})
endif()
target_link_libraries(nrf5_boards PUBLIC nrf5_mdk nrf5_soc nrf5_nrfx_hal)

# Board Support Package
add_library(nrf5_bsp OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/bsp/bsp.c"
)
target_include_directories(nrf5_bsp PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/bsp"
)
target_link_libraries(nrf5_bsp PUBLIC nrf5_boards nrf5_app_button)

# BSP Button BLE
add_library(nrf5_bsp_btn_ble OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/bsp/bsp_btn_ble.c"
)
target_include_directories(nrf5_bsp_btn_ble PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/bsp"
)
target_link_libraries(nrf5_bsp_btn_ble PUBLIC nrf5_boards nrf5_app_button)

# nrfx common
add_library(nrf5_nrfx_common INTERFACE)
target_include_directories(nrf5_nrfx_common INTERFACE
  "${NRF5_SDK_PATH}/modules/nrfx"
  "${NRF5_SDK_PATH}/integration/nrfx"
)
target_compile_definitions(nrf5_nrfx_common INTERFACE
  SOFTDEVICE_PRESENT
)
target_link_libraries(nrf5_nrfx_common INTERFACE nrf5_config)

# nrfx Hardware Abstraction Layer (HAL)
add_library(nrf5_nrfx_hal INTERFACE)
target_include_directories(nrf5_nrfx_hal INTERFACE
  "${NRF5_SDK_PATH}/modules/nrfx/hal"
)
target_link_libraries(nrf5_nrfx_hal INTERFACE nrf5_nrfx_common)

add_library(nrf5_delay INTERFACE)
target_include_directories(nrf5_delay INTERFACE
  "${NRF5_SDK_PATH}/components/libraries/delay")

# SoftDevice Handler
add_library(nrf5_softdevice_handler OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/softdevice/common/nrf_sdh.c"
  "${NRF5_SDK_PATH}/components/softdevice/common/nrf_sdh_ble.c"
  "${NRF5_SDK_PATH}/components/softdevice/common/nrf_sdh_soc.c"
)
target_include_directories(nrf5_softdevice_handler PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/softdevice/common"
)
target_link_libraries(nrf5_softdevice_handler PUBLIC nrf5_log)

# BLE common
add_library(nrf5_ble_common OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/common/ble_advdata.c"
  "${NRF5_SDK_PATH}/components/ble/common/ble_conn_params.c"
  "${NRF5_SDK_PATH}/components/ble/common/ble_conn_state.c"
  "${NRF5_SDK_PATH}/components/ble/common/ble_srv_common.c"
)
target_include_directories(nrf5_ble_common PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/common"
)
target_link_libraries(nrf5_ble_common PUBLIC nrf5_config nrf5_mdk nrf5_soc nrf5_atomic nrf5_softdevice_handler nrf5_app_timer nrf5_atflags)

# BLE advertising
add_library(nrf5_ble_advertising OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_advertising/ble_advertising.c"
)
target_include_directories(nrf5_ble_advertising PUBLIC
  "${NRF5_SDK_PATH}/components/ble/ble_advertising"
)
target_link_libraries(nrf5_ble_advertising PUBLIC nrf5_log nrf5_ble_common)

# BLE scanning
add_library(nrf5_ble_scan OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/nrf_ble_scan/nrf_ble_scan.c"
)
target_include_directories(nrf5_ble_scan PUBLIC
  "${NRF5_SDK_PATH}/components/ble/nrf_ble_scan"
)
target_link_libraries(nrf5_ble_scan PUBLIC nrf5_log nrf5_ble_common)

# BLE data base discovery
add_library(nrf5_ble_db_discovery OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_db_discovery/ble_db_discovery.c"
)
target_include_directories(nrf5_ble_db_discovery PUBLIC
  "${NRF5_SDK_PATH}/components/ble/ble_db_discovery"
)
target_link_libraries(nrf5_ble_db_discovery PUBLIC nrf5_log nrf5_ble_common)

# BLE GATT
add_library(nrf5_ble_gatt OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/nrf_ble_gatt/nrf_ble_gatt.c"
)
target_include_directories(nrf5_ble_gatt PUBLIC
  "${NRF5_SDK_PATH}/components/ble/nrf_ble_gatt"
)
target_link_libraries(nrf5_ble_gatt PUBLIC nrf5_log nrf5_strerror)

# BLE Queued Writes
add_library(nrf5_ble_qwr OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/nrf_ble_qwr/nrf_ble_qwr.c"
)
target_include_directories(nrf5_ble_qwr PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/nrf_ble_qwr"
)
target_link_libraries(nrf5_ble_qwr PUBLIC nrf5_config nrf5_mdk nrf5_soc nrf5_ble_common)

# BLE Link Context Manager
add_library(nrf5_ble_link_ctx_manager OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_link_ctx_manager/ble_link_ctx_manager.c"
)
target_include_directories(nrf5_ble_link_ctx_manager PUBLIC
  "${NRF5_SDK_PATH}/components/ble/ble_link_ctx_manager"
)
target_link_libraries(nrf5_ble_link_ctx_manager PUBLIC nrf5_ble_common)

# BLE LESC
add_library(nrf5_ble_lesc OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/nrf_ble_lesc.c"
)
target_include_directories(nrf5_ble_lesc PUBLIC
"${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_lesc PUBLIC nrf5_config nrf5_mdk nrf5_soc nrf5_crypto_fwd)

# Peer Database
add_library(nrf5_ble_peer_database OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_database.c"
)
target_include_directories(nrf5_ble_peer_database PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_peer_database PUBLIC nrf5_ble_common)

# Peer Data Storage
add_library(nrf5_ble_peer_data_storage OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_data_storage.c"
)
target_include_directories(nrf5_ble_peer_data_storage PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_peer_data_storage PUBLIC nrf5_ble_common)

# ID Manager
add_library(nrf5_ble_id_manager OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/id_manager.c"
)
target_include_directories(nrf5_ble_id_manager PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_id_manager PUBLIC nrf5_ble_common)

# Peer ID
add_library(nrf5_ble_peer_id OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_id.c"
)
target_include_directories(nrf5_ble_peer_id PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_peer_id PUBLIC nrf5_ble_common)

# Peer Manager Buffer
add_library(nrf5_ble_pm_buffer OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/pm_buffer.c"
)
target_include_directories(nrf5_ble_pm_buffer PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_pm_buffer PUBLIC nrf5_ble_common)

# Authorization Status Tracker
add_library(nrf5_ble_auth_status_tracker OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/auth_status_tracker.c"
)
target_include_directories(nrf5_ble_auth_status_tracker PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_auth_status_tracker PUBLIC nrf5_ble_common)

# Security Dispatcher
add_library(nrf5_ble_security_dispatcher OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/security_dispatcher.c"
)
target_include_directories(nrf5_ble_security_dispatcher PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_security_dispatcher PUBLIC nrf5_ble_common)

# Security Manager
add_library(nrf5_ble_security_manager OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/security_manager.c"
)
target_include_directories(nrf5_ble_security_manager PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_security_manager PUBLIC nrf5_ble_common)

# GATT Cache Manager
add_library(nrf5_ble_gatt_cache_manager OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/gatt_cache_manager.c"
  "${NRF5_SDK_PATH}/components/ble/peer_manager/gatts_cache_manager.c"
)
target_include_directories(nrf5_ble_gatt_cache_manager PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_gatt_cache_manager PUBLIC nrf5_ble_common)

# Peer Manager Handler
add_library(nrf5_ble_peer_manager_handler OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_manager_handler.c"
)
target_include_directories(nrf5_ble_peer_manager_handler PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_peer_manager_handler PUBLIC nrf5_ble_common)

# Peer Manager
add_library(nrf5_ble_peer_manager OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_manager.c"
)
target_include_directories(nrf5_ble_peer_manager PUBLIC
  "${NRF5_SDK_PATH}/components/ble/peer_manager"
)
target_link_libraries(nrf5_ble_peer_manager PUBLIC nrf5_ble_common)

# IoT Common
add_library(nrf5_iot_common INTERFACE)
target_include_directories(nrf5_iot_common INTERFACE
  "${NRF5_SDK_PATH}/components/iot/common"
)

# BLE LED Button Service (Peripheral)
add_library(nrf5_ble_srv_lbs OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_lbs/ble_lbs.c"
)
target_include_directories(nrf5_ble_srv_lbs PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_lbs"
)
target_link_libraries(nrf5_ble_srv_lbs PUBLIC nrf5_config nrf5_ble_common nrf5_softdevice_handler)

# BLE LED Button Service (Central)
add_library(nrf5_ble_srv_lbs_c OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_lbs_c/ble_lbs_c.c"
)
target_include_directories(nrf5_ble_srv_lbs_c PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_lbs_c"
)
target_link_libraries(nrf5_ble_srv_lbs_c PUBLIC nrf5_ble_db_discovery)

# BLE Nordic UART Service (Peripheral)
add_library(nrf5_ble_srv_nus OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_nus/ble_nus.c"
)
target_include_directories(nrf5_ble_srv_nus PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_nus/"
)
target_link_libraries(nrf5_ble_srv_nus PUBLIC nrf5_ble_link_ctx_manager)

# BLE Device Information Service (Peripheral)
add_library(nrf5_ble_srv_dis OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_dis/ble_dis.c"
)
target_include_directories(nrf5_ble_srv_dis PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_dis/"
)
target_link_libraries(nrf5_ble_srv_dis PUBLIC nrf5_ble_common)

# BLE Bond Management Service
add_library(nrf5_ble_srv_bms OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_services/nrf_ble_bms/nrf_ble_bms.c"
)
target_include_directories(nrf5_ble_srv_bms PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/ble_services/nrf_ble_bms/"
)
target_link_libraries(nrf5_ble_srv_bms PUBLIC nrf5_ble_common nrf5_ble_qwr)

# BLE Internet Protocol Support Profile Service
add_library(nrf5_ble_srv_ipsp OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_ipsp/ble_ipsp.c"
)
target_include_directories(nrf5_ble_srv_ipsp PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
  "${NRF5_SDK_PATH}/components/ble/ble_services/ble_ipsp/"
)
target_link_libraries(nrf5_ble_srv_ipsp PUBLIC nrf5_ble_common)

function(nrf5_target exec_target)
  # nrf5_mdk must be linked as startup_*.S contains definition of the Reset_Handler entry symbol 
  target_link_libraries(${exec_target} PRIVATE nrf5_mdk)
  target_link_options(${exec_target} PRIVATE
    "-L${NRF5_SDK_PATH}/modules/nrfx/mdk"
    "-T${NRF5_LINKER_SCRIPT}"
  )
  # print size information after build
  add_custom_command(TARGET ${exec_target} POST_BUILD
    COMMAND ${CMAKE_SIZE_BIN} "${exec_target}"
  )
  # targets for creating Intel HEX and binary executable forms
  add_custom_target(hex DEPENDS ${exec_target} COMMAND ${CMAKE_OBJCOPY_BIN} -O ihex "${exec_target}" "${exec_target}.hex")
  add_custom_target(bin DEPENDS ${exec_target} COMMAND ${CMAKE_OBJCOPY_BIN} -O binary "${exec_target}" "${exec_target}.bin")
  # target for flashing SoftDevice
  add_custom_target(flash_softdevice
    COMMAND ${NRF5_NRFJPROG} --program ${NRF5_SOFTDEVICE_HEX} -f nrf52 --sectorerase
    COMMAND ${NRF5_NRFJPROG} --reset -f nrf52
  )
  # target for flashing the output executable
  add_custom_target(flash DEPENDS hex 
    COMMAND ${NRF5_NRFJPROG} --program "${exec_target}.hex" -f nrf52 --sectorerase
    COMMAND ${NRF5_NRFJPROG} --reset -f nrf52
  )
  # target for erasing Flash memory and the UICR page
  add_custom_target(erase_all
    COMMAND ${NRF5_NRFJPROG} --eraseall -f nrf52
  )
endfunction()
