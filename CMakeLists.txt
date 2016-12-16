cmake_minimum_required(VERSION 3.0.0)

project(Meshb VERSION 7.22 LANGUAGES C)

add_library(meshb sources/libmeshb7.c)
target_include_directories(meshb PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/sources>
    $<INSTALL_INTERFACE:include>)
install(TARGETS meshb EXPORT meshb-target DESTINATION lib)
install(EXPORT meshb-target NAMESPACE ${PROJECT_NAME}::
    DESTINATION lib/cmake/${PROJECT_NAME})
install(FILES sources/libmeshb7.h DESTINATION include)

include(CMakePackageConfigHelpers)
file(WRITE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    "include(\${CMAKE_CURRENT_LIST_DIR}/meshb-target.cmake)")
write_basic_package_version_file(
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion)
install(FILES
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION lib/cmake/${PROJECT_NAME})
