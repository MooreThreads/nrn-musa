# =============================================================================
# Copyright (C) 2016-2021 Blue Brain Project
#
# See top-level LICENSE file for details.
# =============================================================================

# Helper to parse X.Y[.{anything] into X.Y
function(cnrn_parse_version FULL_VERSION)
  cmake_parse_arguments(PARSE_ARGV 1 CNRN_PARSE_VERSION "" "OUTPUT_MAJOR_MINOR" "")
  if(NOT "${CNRN_PARSE_VERSION_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(
      FATAL_ERROR
        "cnrn_parse_version got unexpected arguments: ${CNRN_PARSE_VERSION_UNPARSED_ARGUMENTS}")
  endif()
  string(FIND ${FULL_VERSION} . first_dot)
  math(EXPR first_dot_plus_one "${first_dot}+1")
  string(SUBSTRING ${FULL_VERSION} ${first_dot_plus_one} -1 minor_and_later)
  string(FIND ${minor_and_later} . second_dot_relative)
  if(${first_dot} EQUAL -1 OR ${second_dot_relative} EQUAL -1)
    message(FATAL_ERROR "Failed to parse major.minor from ${FULL_VERSION}")
  endif()
  math(EXPR second_dot_plus_one "${first_dot}+${second_dot_relative}+1")
  string(SUBSTRING ${FULL_VERSION} 0 ${second_dot_plus_one} major_minor)
  set(${CNRN_PARSE_VERSION_OUTPUT_MAJOR_MINOR}
      ${major_minor}
      PARENT_SCOPE)
endfunction()

# =============================================================================
# Prepare compiler flags for GPU target (MUSA)
# =============================================================================
if(CORENRN_ENABLE_GPU)
  # Enable musaProfiler{Start,Stop}() behind the Instrumentor::phase... APIs
  list(APPEND CORENRN_COMPILE_DEFS CORENEURON_MUSA_PROFILING CORENEURON_ENABLE_GPU)
  # Add MUSA toolkit include directories
  list(APPEND CMAKE_MODULE_PATH "/usr/local/musa/cmake")
  find_package(MUSAToolkit REQUIRED)
  include_directories(${MUSAToolkit_INCLUDE_DIRS})
  # MUSA unified memory support
  if(CORENRN_ENABLE_CUDA_UNIFIED_MEMORY)
    list(APPEND CORENRN_COMPILE_DEFS CORENEURON_UNIFIED_MEMORY)
  endif()
  set(CORENRN_MUSA_VERSION_SHORT "${MUSAToolkit_VERSION_MAJOR}.${MUSAToolkit_VERSION_MINOR}")
  # For MUSA, we use direct MUSA runtime API without OpenACC/OpenMP offload
  # The GPU kernels are compiled separately with mcc
  set(CORENRN_ACCELERATOR_OFFLOAD "OpenMP")
  list(APPEND CORENRN_COMPILE_DEFS CORENEURON_PREFER_OPENMP_OFFLOAD)
  set(MUSA_ACC_COMP_FLAGS "")
  set(NVHPC_CXX_INLINE_FLAGS "")
endif()

# =============================================================================
# Initialise global properties that will be used by NEURON to link with CoreNEURON
# =============================================================================
if(CORENRN_ENABLE_GPU)
  set_property(GLOBAL PROPERTY CORENRN_LIB_LINK_FLAGS "${MUSA_ACC_COMP_FLAGS}")
  if(CORENRN_ENABLE_SHARED)
    set_property(GLOBAL PROPERTY CORENRN_NEURON_LINK_FLAGS "${MUSA_ACC_COMP_FLAGS}")
  endif()
endif()

set_property(GLOBAL PROPERTY CORENRN_ENABLE_SHARED ${CORENRN_ENABLE_SHARED})
