# VecMem project, part of the ACTS project (R&D line)
#
# (c) 2021-2024 CERN for the benefit of the ACTS project
#
# Mozilla Public License Version 2.0

# Set up the helper functions/macros.

####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was vecmem-config.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

####################################################################################

# Set up some simple variables for using the package.
set( vecmem_VERSION "1.13.0" )
set_and_check( vecmem_INCLUDE_DIR "${PACKAGE_PREFIX_DIR}/include" )
set_and_check( vecmem_LIBRARY_DIR "${PACKAGE_PREFIX_DIR}/lib" )
set_and_check( vecmem_CMAKE_DIR "${PACKAGE_PREFIX_DIR}/lib/cmake/vecmem-1.13.0" )
set_and_check( vecmem_LANGUAGE_FILE
   "${vecmem_CMAKE_DIR}/vecmem-check-language.cmake" )

# Include the file listing all the imported targets and options.
include( "${vecmem_CMAKE_DIR}/vecmem-config-targets.cmake" )

# Add the current directory to CMAKE_MODULE_PATH.
list( APPEND CMAKE_MODULE_PATH "${vecmem_CMAKE_DIR}" )

# Set up additional variables, based on the imported targets. These are mostly
# just here for handling COMPONENT arguments for find_package(...).
set( vecmem_CORE_LIBRARY vecmem::core )
if( TARGET vecmem::cuda )
   set( vecmem_CUDA_LIBRARY vecmem::cuda )
else()
   set( vecmem_CUDA_LIBRARY vecmem::cuda-NOTFOUND )
endif()
if( TARGET vecmem::hip )
   set( vecmem_HIP_LIBRARY vecmem::hip )
else()
   set( vecmem_HIP_LIBRARY vecmem::hip-NOTFOUND )
endif()
if( TARGET vecmem::sycl )
   set( vecmem_SYCL_LIBRARY vecmem::sycl )
else()
   set( vecmem_SYCL_LIBRARY vecmem::sycl-NOTFOUND )
endif()

# If the user asked for the CUDA/HIP/SYCL components explicitly, make
# sure that they would exist in the installation.
set( vecmem_REQUIRED_LIBS vecmem_CORE_LIBRARY )
foreach( comp "CUDA" "HIP" "SYCL" )
   if( "${vecmem_FIND_COMPONENTS}" MATCHES "${comp}" )
      list( APPEND vecmem_REQUIRED_LIBS vecmem_${comp}_LIBRARY )
   endif()
endforeach()

# Print a standard information message about the package being found.
include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( vecmem REQUIRED_VARS
   CMAKE_CURRENT_LIST_FILE ${vecmem_REQUIRED_LIBS}
   VERSION_VAR vecmem_VERSION )

# Clean up.
unset( vecmem_REQUIRED_LIBS )

# (Post-)Configure the targets.
include( vecmem-setup-core )
vecmem_setup_core( vecmem::core )
if( TARGET vecmem::sycl )
   include( vecmem-setup-sycl )
   vecmem_setup_sycl( vecmem::sycl )
endif()
