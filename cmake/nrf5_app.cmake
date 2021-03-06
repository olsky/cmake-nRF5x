# MIT License

# Copyright (c) 2020 Polidea

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
#
# WARNING: FILE GENERATED FROM ./ci/scripts/generate_cmake.sh SCRIPT.

# Application Scheduler
add_library(nrf5_app_scheduler OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/scheduler/app_scheduler.c"
)
target_include_directories(nrf5_app_scheduler PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/scheduler"
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_scheduler PUBLIC
  nrf5_config
  nrf5_mdk
  nrf5_soc
)
list(APPEND NRF5_LIBRARY_NRF5_APP_SCHEDULER_DEPENDENCIES
  nrf5_app_scheduler
  nrf5_config
  nrf5_mdk
  nrf5_soc
)

# Application Error
add_library(nrf5_app_error OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/util/app_error.c"
  "${NRF5_SDK_PATH}/components/libraries/util/app_error_handler_gcc.c"
  "${NRF5_SDK_PATH}/components/libraries/util/app_error_weak.c"
)
target_include_directories(nrf5_app_error PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_error PUBLIC
  nrf5_log
)
list(APPEND NRF5_LIBRARY_NRF5_APP_ERROR_DEPENDENCIES
  nrf5_app_error
  nrf5_app_scheduler
  nrf5_app_util_platform
  nrf5_atfifo
  nrf5_atomic
  nrf5_balloc
  nrf5_balloc_fwd
  nrf5_cli
  nrf5_cli_fwd
  nrf5_config
  nrf5_delay
  nrf5_ext_fprintf
  nrf5_fds
  nrf5_fstorage
  nrf5_log
  nrf5_log_fwd
  nrf5_mdk
  nrf5_memobj
  nrf5_memobj_fwd
  nrf5_mtx
  nrf5_nrfx_common
  nrf5_nrfx_hal
  nrf5_pwr_mgmt
  nrf5_queue
  nrf5_ringbuf
  nrf5_sdh
  nrf5_section
  nrf5_soc
  nrf5_strerror
)

# Application Platform Utilities
add_library(nrf5_app_util_platform OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/util/app_util_platform.c"
)
target_include_directories(nrf5_app_util_platform PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_util_platform PUBLIC
  nrf5_mdk
  nrf5_soc
)
list(APPEND NRF5_LIBRARY_NRF5_APP_UTIL_PLATFORM_DEPENDENCIES
  nrf5_app_util_platform
  nrf5_mdk
  nrf5_soc
)

# Application Timer
add_library(nrf5_app_timer OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/timer/app_timer.c"
)
target_include_directories(nrf5_app_timer PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/timer"
)
target_link_libraries(nrf5_app_timer PUBLIC
  nrf5_app_scheduler
  nrf5_app_util_platform
  nrf5_delay
  nrf5_nrfx_hal
)
list(APPEND NRF5_LIBRARY_NRF5_APP_TIMER_DEPENDENCIES
  nrf5_app_scheduler
  nrf5_app_timer
  nrf5_app_util_platform
  nrf5_config
  nrf5_delay
  nrf5_mdk
  nrf5_nrfx_common
  nrf5_nrfx_hal
  nrf5_soc
)

# Application Button
add_library(nrf5_app_button OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/button/app_button.c"
)
target_include_directories(nrf5_app_button PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/button"
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_button PUBLIC
  nrf5_app_timer
  nrf5_nrfx_gpiote
)
list(APPEND NRF5_LIBRARY_NRF5_APP_BUTTON_DEPENDENCIES
  nrf5_app_button
  nrf5_app_scheduler
  nrf5_app_timer
  nrf5_app_util_platform
  nrf5_atfifo
  nrf5_atomic
  nrf5_balloc
  nrf5_balloc_fwd
  nrf5_cli
  nrf5_cli_fwd
  nrf5_config
  nrf5_delay
  nrf5_ext_fprintf
  nrf5_fds
  nrf5_fstorage
  nrf5_log
  nrf5_log_fwd
  nrf5_mdk
  nrf5_memobj
  nrf5_memobj_fwd
  nrf5_mtx
  nrf5_nrfx_common
  nrf5_nrfx_gpiote
  nrf5_nrfx_hal
  nrf5_pwr_mgmt
  nrf5_queue
  nrf5_ringbuf
  nrf5_sdh
  nrf5_section
  nrf5_soc
  nrf5_strerror
)

# Application FIFO
add_library(nrf5_app_fifo OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/fifo/app_fifo.c"
)
target_include_directories(nrf5_app_fifo PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/fifo"
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_fifo PUBLIC
  nrf5_config
  nrf5_mdk
  nrf5_soc
)
list(APPEND NRF5_LIBRARY_NRF5_APP_FIFO_DEPENDENCIES
  nrf5_app_fifo
  nrf5_config
  nrf5_mdk
  nrf5_soc
)

# Application UART
add_library(nrf5_app_uart OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/uart/app_uart.c"
)
target_include_directories(nrf5_app_uart PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/uart"
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_uart PUBLIC
  nrf5_drv_uart
)
list(APPEND NRF5_LIBRARY_NRF5_APP_UART_DEPENDENCIES
  nrf5_app_scheduler
  nrf5_app_uart
  nrf5_app_util_platform
  nrf5_atfifo
  nrf5_atomic
  nrf5_balloc
  nrf5_balloc_fwd
  nrf5_cli
  nrf5_cli_fwd
  nrf5_config
  nrf5_delay
  nrf5_drv_uart
  nrf5_ext_fprintf
  nrf5_fds
  nrf5_fstorage
  nrf5_log
  nrf5_log_fwd
  nrf5_mdk
  nrf5_memobj
  nrf5_memobj_fwd
  nrf5_mtx
  nrf5_nrfx_common
  nrf5_nrfx_hal
  nrf5_nrfx_uart
  nrf5_nrfx_uarte
  nrf5_pwr_mgmt
  nrf5_queue
  nrf5_ringbuf
  nrf5_sdh
  nrf5_section
  nrf5_soc
  nrf5_strerror
)

# Application UART (with FIFO)
add_library(nrf5_app_uart_fifo OBJECT EXCLUDE_FROM_ALL
  "${NRF5_SDK_PATH}/components/libraries/uart/app_uart_fifo.c"
)
target_include_directories(nrf5_app_uart_fifo PUBLIC
  "${NRF5_SDK_PATH}/components/libraries/uart"
  "${NRF5_SDK_PATH}/components/libraries/util"
)
target_link_libraries(nrf5_app_uart_fifo PUBLIC
  nrf5_app_fifo
  nrf5_drv_uart
)
list(APPEND NRF5_LIBRARY_NRF5_APP_UART_FIFO_DEPENDENCIES
  nrf5_app_fifo
  nrf5_app_scheduler
  nrf5_app_uart_fifo
  nrf5_app_util_platform
  nrf5_atfifo
  nrf5_atomic
  nrf5_balloc
  nrf5_balloc_fwd
  nrf5_cli
  nrf5_cli_fwd
  nrf5_config
  nrf5_delay
  nrf5_drv_uart
  nrf5_ext_fprintf
  nrf5_fds
  nrf5_fstorage
  nrf5_log
  nrf5_log_fwd
  nrf5_mdk
  nrf5_memobj
  nrf5_memobj_fwd
  nrf5_mtx
  nrf5_nrfx_common
  nrf5_nrfx_hal
  nrf5_nrfx_uart
  nrf5_nrfx_uarte
  nrf5_pwr_mgmt
  nrf5_queue
  nrf5_ringbuf
  nrf5_sdh
  nrf5_section
  nrf5_soc
  nrf5_strerror
)
