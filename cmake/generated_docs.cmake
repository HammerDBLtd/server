# Copyright (c) 2026, MariaDB Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1335  USA

# Utilities to produce generated docs. The docs are generated as part of
# the build, but only if WITH_GENERATED_DOCS is set to ON. The docs are generated
# using doxygen and moxygen, and are output to the docs directory
# in the build directory.
# First doxygen is called to produce XML output into docs/${PROJECT}/xml,
# and then moxygen is called to produce markdown output into
# docs/${PROJECT}/$PROJECT.md out of the XML output.
# Normal usage sequence:
# * include this file in the top-level CMakeLists.txt
# * call GENERATED_DOCS_PROJECT for each project to generate docs for.


# An option to control building the generated docs.
# Possible values are:
#  - ON: always build the docs or fail trying
#  - OFF: do not build the docs
SET(WITH_GENERATED_DOCS OFF CACHE BOOL "Produce the generated docs")


# Find the programs needed for generating the docs.
# This is to be called from the top-level CMakeLists.txt, and the results
# are used in GENERATED_DOCS_PROJECT
IF (WITH_GENERATED_DOCS)
  FIND_PACKAGE(Doxygen REQUIRED)
  FIND_PROGRAM(MOXYGEN_BIN moxygen OPTIONAL)
  IF (NOT MOXYGEN_BIN)
    MESSAGE(FATAL_ERROR "Moxygen is required to build the generated docs. See https://github.com/sourcey/moxygen/")
  ENDIF()
ENDIF()

# Generate documentation for a project.
# There can be multiple projects, e.g. one for the plugin API, one for the server, etc.
# Creates a target named DOCS_${NAME} that generates the docs for the specified sources.
# Call with a project name name, a mask (default *), and list of sources, e.g.
# GENERATED_DOCS_PROJECT(NAME plugin_api MASK "*.h" foo.h bar.h)

FUNCTION (GENERATED_DOCS_PROJECT)

  CMAKE_PARSE_ARGUMENTS(ARG 1
    ""
    "MASK"
    ""
    ${ARGN}
  )
  set(ARG_NAME "${ARGV0}")
  IF (NOT ARG_NAME)
    MESSAGE(FATAL_ERROR "NAME is required as a first argument to GENERATED_DOCS_PROJECT")
  ENDIF()

  IF (NOT ARG_MASK)
    SET(ARG_MASK "*")
  ENDIF()

  STRING(TOLOWER "${ARG_NAME}" DOCS_PROJECT_NAME)
  STRING(PREPEND DOCS_PROJECT_NAME "generated_docs_")
  ADD_FEATURE_INFO(${DOCS_PROJECT_NAME} WITH_GENERATED_DOCS "Generated documentation for the ${ARG_NAME}")
  IF (NOT WITH_GENERATED_DOCS)
    RETURN()
  ENDIF()

  SET(SOURCES ${ARG_UNPARSED_ARGUMENTS})
  LIST(REMOVE_AT SOURCES 0)   # Remove the NAME that ended up in unparsed args

  FILE(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/docs)
  FILE(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/docs/${ARG_NAME})
  FILE(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/docs/${ARG_NAME}/md)

  SET(DOXYGEN_FILE_PATTERNS ${ARG_MASK})
  SET(DOXYGEN_GENERATE_HTML NO)
  SET(DOXYGEN_WARN_IF_UNDOCUMENTED NO)
  SET(DOXYGEN_GENERATE_XML YES)
  SET(DOXYGEN_INCLUDE_PATH ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
  SET(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/docs/${ARG_NAME}")
  SET(DOXYGEN_WARN_AS_ERROR YES)
  SET(DOXYGEN_EXTRACT_ALL YES)
  SET(DOXYGEN_QUIET YES)
  SET(DOXYGEN_XML_PROGRAMLISTING YES)
  doxygen_add_docs(${DOCS_PROJECT_NAME} ${SOURCES} ALL USE_STAMP_FILE COMMENT "Generating ${ARG_NAME} XML docs with doxygen")
  ADD_CUSTOM_COMMAND(TARGET ${DOCS_PROJECT_NAME} POST_BUILD
    COMMAND ${MOXYGEN_BIN} --quiet
      --source-root ${CMAKE_SOURCE_DIR}
      --output ${CMAKE_BINARY_DIR}/docs/${ARG_NAME}/md/${ARG_NAME}.md
      ${CMAKE_BINARY_DIR}/docs/${ARG_NAME}/xml
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/docs/${ARG_NAME}/md
    BYPRODUCTS ${CMAKE_BINARY_DIR}/docs/${ARG_NAME}/md/${ARG_NAME}.md
    COMMENT "Generating ${ARG_NAME} markdown docs with moxygen"
  )
ENDFUNCTION()