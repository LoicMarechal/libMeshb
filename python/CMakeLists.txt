# Package Python pymeshb (Cython) -- active par -DENABLE_PYTHON=ON
#   cmake .. -DENABLE_PYTHON=ON -DPYTHON_EXECUTABLE=$PYTHON3
# Le module est construit dans <build>/python/lib et installe dans
# <prefix>/lib/pythonX.Y/site-packages (ajouter ce dossier a PYTHONPATH).

if(NOT PYTHON_EXECUTABLE)
   find_package(Python3 REQUIRED COMPONENTS Interpreter)
   set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
endif()

# Verification des prerequis Python
execute_process(
   COMMAND ${PYTHON_EXECUTABLE} -c "import Cython, numpy, setuptools; print(Cython.__version__)"
   RESULT_VARIABLE PYMESHB_DEPS_RESULT
   OUTPUT_VARIABLE PYMESHB_CYTHON_VERSION
   ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT PYMESHB_DEPS_RESULT EQUAL 0)
   message(FATAL_ERROR "pymeshb : ${PYTHON_EXECUTABLE} doit fournir Cython, numpy et setuptools "
                       "(pip install cython numpy setuptools)")
endif()

# Dossier site-packages relatif au prefixe d'installation
execute_process(
   COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print(sysconfig.get_path('purelib', vars={'base': '', 'platbase': ''}).lstrip('/\\\\'))"
   OUTPUT_VARIABLE PYMESHB_SITE_REL OUTPUT_STRIP_TRAILING_WHITESPACE)

set(PYMESHB_BIN ${CMAKE_CURRENT_BINARY_DIR})
file(GLOB PYMESHB_FILES ${CMAKE_CURRENT_SOURCE_DIR}/pymeshb/*.py ${CMAKE_CURRENT_SOURCE_DIR}/pymeshb/*.pyx
                        ${LIBMESHB_SRC}/libmeshb8.c ${LIBMESHB_SRC}/libmeshb8.h)

add_custom_command(
   OUTPUT ${PYMESHB_BIN}/pymeshb.stamp
   COMMAND ${CMAKE_COMMAND} -E env PYMESHB_BUILD_DIR=${PYMESHB_BIN}/work
           ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/setup.py -q
           build --build-lib ${PYMESHB_BIN}/lib --build-temp ${PYMESHB_BIN}/tmp
   COMMAND ${CMAKE_COMMAND} -E touch ${PYMESHB_BIN}/pymeshb.stamp
   DEPENDS ${PYMESHB_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/setup.py
   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
   COMMENT "Building the pymeshb Python package"
   VERBATIM)
add_custom_target(pymeshb ALL DEPENDS ${PYMESHB_BIN}/pymeshb.stamp)

install(DIRECTORY ${PYMESHB_BIN}/lib/pymeshb DESTINATION ${PYMESHB_SITE_REL}
        PATTERN "__pycache__" EXCLUDE)
install(DIRECTORY examples/ DESTINATION share/libMeshb/python/examples
        FILES_MATCHING PATTERN "*.py")

if(WITH_GMF_CTEST)
   add_test(NAME pymeshb
            COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${PYMESHB_BIN}/lib
                    ${PYTHON_EXECUTABLE} -m unittest discover ${CMAKE_CURRENT_SOURCE_DIR}/tests)
endif()

message("-- pymeshb               : Cython ${PYMESHB_CYTHON_VERSION}, ${PYTHON_EXECUTABLE}")
