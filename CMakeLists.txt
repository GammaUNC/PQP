cmake_minimum_required(VERSION 2.8.11)

project(pqp)

include(CMakePackageConfigHelpers)
include(GenerateExportHeader)
include(GNUInstallDirs)

set(VERSION_MAJOR 1)
set(VERSION_MINOR 3)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR})

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

set(
	HDRS
	src/BV.h
	src/PQP.h
	src/PQP_Compile.h
	src/PQP_Internal.h
	src/Tri.h
)

set(
	SRCS
	src/Build.cpp
	src/BV.cpp
	src/PQP.cpp
	src/TriDist.cpp
)

add_library(PQP ${HDRS} ${SRCS})

target_include_directories(
	PQP
	PUBLIC
	$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
	$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(
	PQP
	PROPERTIES
	POSITION_INDEPENDENT_CODE ON
	VERSION ${VERSION}
)

if(MSVC)
	if(BUILD_SHARED_LIBS)
		set_target_properties(
			PQP
			PROPERTIES
			DEBUG_POSTFIX d
		)
	else()
		set_target_properties(
			PQP
			PROPERTIES
			DEBUG_POSTFIX sd
			MINSIZEREL_POSTFIX s
			RELEASE_POSTFIX s
			RELWITHDEBINFO_POSTFIX s
		)
	endif()
endif()

install(FILES ${HDRS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT development)

if(NOT CMAKE_VERSION VERSION_LESS 3.12)
	install(
		TARGETS	PQP
		EXPORT PQP
		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT development
		LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT runtime NAMELINK_COMPONENT development
		RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT runtime
	)
else()
	install(
		TARGETS	PQP
		EXPORT PQP
		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT development
		LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT runtime NAMELINK_SKIP
		RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT runtime
	)
	if(BUILD_SHARED_LIBS)
		install(
			TARGETS	PQP
			EXPORT PQP
			LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT development NAMELINK_ONLY
		)
	endif()
endif()

if(MSVC AND BUILD_SHARED_LIBS AND ${CMAKE_MAJOR_VERSION} GREATER 2 AND ${CMAKE_MINOR_VERSION} GREATER 0)
	install(FILES $<TARGET_PDB_FILE:PQP> DESTINATION ${CMAKE_INSTALL_BINDIR} CONFIGURATIONS Debug RelWithDebInfo COMPONENT debug)
endif()

generate_export_header(PQP EXPORT_FILE_NAME PQP_Export.h)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/PQP_Export.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT development)

option(BUILD_SAMPLES "Build samples" OFF)

if(BUILD_SAMPLES)
	add_executable(sample demos/sample/main.cpp)
	target_link_libraries(sample PQP)
	
	find_package(GLUT)
	find_package(OpenGL)
	find_package(X11)
	
	if(GLUT_FOUND AND OPENGL_FOUND AND X11_FOUND)
		configure_file(demos/spinning/bunny.tris bunny.tris COPYONLY)
		configure_file(demos/spinning/torus.tris torus.tris COPYONLY)
		add_executable(spinning demos/spinning/main.cpp demos/spinning/model.cpp)
		target_include_directories(spinning PRIVATE ${GLUT_INCLUDE_DIR} ${X11_INCLUDE_DIR})
		target_link_libraries(spinning PQP ${GLUT_LIBRARIES} ${OPENGL_LIBRARIES} ${X11_LIBRARIES})
		
		configure_file(demos/falling/torus1.path torus1.path COPYONLY)
		configure_file(demos/falling/torus1.tris torus1.tris COPYONLY)
		configure_file(demos/falling/torus2.path torus2.path COPYONLY)
		configure_file(demos/falling/torus2.tris torus2.tris COPYONLY)
		add_executable(falling demos/falling/main.cpp demos/falling/model.cpp)
		target_include_directories(falling PRIVATE ${GLUT_INCLUDE_DIR} ${X11_INCLUDE_DIR})
		target_link_libraries(falling PQP ${GLUT_LIBRARIES} ${OPENGL_LIBRARIES} ${X11_LIBRARIES})
	endif()
endif()

configure_package_config_file(
	pqp-config.cmake.in pqp-config.cmake
	INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PQP-${VERSION}
)

install(
	FILES ${CMAKE_CURRENT_BINARY_DIR}/pqp-config.cmake
	DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PQP-${VERSION}
	COMPONENT development
)

write_basic_package_version_file(
	${CMAKE_CURRENT_BINARY_DIR}/pqp-config-version.cmake
	VERSION ${VERSION}
	COMPATIBILITY ExactVersion
)

install(
	FILES ${CMAKE_CURRENT_BINARY_DIR}/pqp-config-version.cmake
	DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PQP-${VERSION}
	COMPONENT development
)

install(
	EXPORT PQP
	DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PQP-${VERSION}
	NAMESPACE PQP::
	FILE pqp-export.cmake
	COMPONENT development
)

set(CPACK_COMPONENT_DEVELOPMENT_DEPENDS runtime)
set(CPACK_DEB_COMPONENT_INSTALL ON)
set(CPACK_DEBIAN_DEVELOPMENT_PACKAGE_DEPENDS "libpqp")
set(CPACK_DEBIAN_DEVELOPMENT_PACKAGE_NAME "libpqp-dev")
set(CPACK_DEBIAN_DEVELOPMENT_PACKAGE_SECTION "libdevel")
set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "http://gamma.cs.unc.edu/SSV/")
set(CPACK_DEBIAN_PACKAGE_NAME "libpqp")
set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
set(CPACK_DEBIAN_RUNTIME_PACKAGE_NAME "libpqp")
set(CPACK_DEBIAN_RUNTIME_PACKAGE_SECTION "libs")
set(CPACK_NSIS_PACKAGE_NAME "PQP ${VERSION}")
set(CPACK_NSIS_URL_INFO_ABOUT ${CPACK_DEBIAN_PACKAGE_HOMEPAGE})
set(CPACK_PACKAGE_CONTACT "geom@cs.unc.edu")
set(CPACK_PACKAGE_DISPLAY_NAME "PQP ${VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "PQP-${VERSION}")
set(CPACK_PACKAGE_NAME "pqp")
set(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR})
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE)
set(CPACK_RPM_COMPONENT_INSTALL ON)
set(CPACK_RPM_development_PACKAGE_NAME "pqp-devel")
set(CPACK_RPM_development_PACKAGE_REQUIRES "pqp")
set(CPACK_RPM_PACKAGE_GROUP "Development/Libraries")
set(CPACK_RPM_PACKAGE_NAME "pqp")
set(CPACK_RPM_PACKAGE_URL ${CPACK_DEBIAN_PACKAGE_HOMEPAGE})
set(CPACK_RPM_runtime_PACKAGE_NAME "pqp")

if(WIN32 AND CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
endif()

include(CPack)
