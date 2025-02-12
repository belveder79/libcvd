find_package(X11)
find_package(Threads REQUIRED)

# largely taken from here:
# https://github.com/FreeRDP/FreeRDP/pull/8190/commits/73b74e8ccb08e8c00a133cf22b5e48ce2bd7e946
find_file(CVD_AVCODEC_VERSION_FILE "libavcodec/version.h")
find_file(CVD_AVCODEC_MVERSION_FILE "libavcodec/version_major.h")
file(STRINGS ${CVD_AVCODEC_VERSION_FILE} AV_VERSION_FILE REGEX "LIBAVCODEC_VERSION_M[A-Z]+[\t ]*[0-9]+")
if (EXISTS "${CVD_AVCODEC_MVERSION_FILE}")
	file(STRINGS "${CVD_AVCODEC_MVERSION_FILE}" AV_VERSION_FILE2 REGEX "LIBAVCODEC_VERSION_M[A-Z]+[\t ]*[0-9]+")
	list(APPEND AV_VERSION_FILE ${AV_VERSION_FILE2})
endif()

FOREACH(item ${AV_VERSION_FILE})
  STRING(REGEX MATCH "LIBAVCODEC_VERSION_M[A-Z]+[\t ]*[0-9]+" litem ${item})
	IF(litem)
			string(REGEX REPLACE "[ \t]+" ";" VSPLIT_LINE ${litem})
			list(LENGTH VSPLIT_LINE VSPLIT_LINE_LEN)
			if (NOT "${VSPLIT_LINE_LEN}" EQUAL "2")
				message(ERROR "invalid entry in libavcodec version header ${item}")
			endif(NOT "${VSPLIT_LINE_LEN}" EQUAL "2")
			list(GET VSPLIT_LINE 0 VNAME)
			list(GET VSPLIT_LINE 1 VVALUE)
			set(${VNAME} ${VVALUE})
	ENDIF(litem)
	IF(litem)
			string(REGEX REPLACE "[ \t]+" ";" VSPLIT_LINE ${litem})
			list(LENGTH VSPLIT_LINE VSPLIT_LINE_LEN)
			if (NOT "${VSPLIT_LINE_LEN}" EQUAL "2")
				message(ERROR "invalid entry in libavcodec version header ${item}")
			endif(NOT "${VSPLIT_LINE_LEN}" EQUAL "2")
			list(GET VSPLIT_LINE 0 VNAME)
			list(GET VSPLIT_LINE 1 VVALUE)
			set(${VNAME} ${VVALUE})
	ENDIF(litem)
ENDFOREACH(item ${AV_VERSION_FILE})

set(AVCODEC_VERSION "${LIBAVCODEC_VERSION_MAJOR}.${LIBAVCODEC_VERSION_MINOR}.${LIBAVCODEC_VERSION_MICRO}")
message(STATUS "Version: ${AVCODEC_VERSION}")

IF(${AVCODEC_VERSION} VERSION_GREATER "57.48.101")
	SET(CVD_FFMPEG_FOUND FALSE)
	MESSAGE(WARNING "FFMPEG found, but version is too new!")
ELSE()
	find_path(CVD_AVCODEC_INCLUDE_DIR libavcodec/avcodec.h)
	find_library(CVD_AVCODEC_LIBRARY NAMES avcodec)
	find_path(CVD_AVDEVICE_INCLUDE_DIR libavdevice/avdevice.h)
	find_library(CVD_AVDEVICE_LIBRARY NAMES avdevice)
	find_path(CVD_AVFORMAT_INCLUDE_DIR libavformat/avformat.h)
	find_library(CVD_AVFORMAT_LIBRARY NAMES avformat)
	find_library(CVD_AVUTIL_LIBRARY NAMES avutil)
	find_path(CVD_SWSCALE_INCLUDE_DIR libswscale/swscale.h)
	find_library(CVD_SWSCALE_LIBRARY NAMES swscale)
	find_library(CVD_SWRESAMPLE_LIBRARY NAMES swresample)
	find_library(CVD_AVFILTER_LIBRARY NAMES avfilter)


	FIND_PACKAGE_HANDLE_STANDARD_ARGS(CVD_FFMPEG REQUIRED_VARS
		CVD_AVCODEC_INCLUDE_DIR CVD_AVCODEC_LIBRARY CVD_AVDEVICE_INCLUDE_DIR
		CVD_AVDEVICE_LIBRARY CVD_AVFORMAT_INCLUDE_DIR CVD_AVFORMAT_LIBRARY
		CVD_AVUTIL_LIBRARY CVD_SWSCALE_INCLUDE_DIR CVD_SWSCALE_LIBRARY
		CVD_SWRESAMPLE_LIBRARY CVD_AVFILTER_LIBRARY)

	if(CVD_FFMPEG_FOUND)
		message(STATUS "FFMPEG - found")

		set(CVD_FFMPEG_INCLUDE_DIRS ${CVD_AVCODEC_INCLUDE_DIR}
			${CVD_AVDEVICE_INCLUDE_DIR} ${CVD_AVFORMAT_INCLUDE_DIR}
			${CVD_SWSCALE_INCLUDE_DIR})

		set(CVD_FFMPEG_LIBRARIES
			${CVD_AVDEVICE_LIBRARY}
			${CVD_AVFILTER_LIBRARY}
			${CVD_AVFORMAT_LIBRARY}
			${CVD_AVCODEC_LIBRARY}
			${CVD_AVUTIL_LIBRARY}
			${CVD_SWSCALE_LIBRARY}
			${CVD_SWRESAMPLE_LIBRARY}
			)


		set(CVD_FFMPEG_LIKELY_X_LIBS xcb-xfixes xcb-shape xcb-shm xcb)
		foreach(l IN LISTS CVD_FFMPEG_LIKELY_X_LIBS)
			find_library(CVD_TMP_${l} NAMES ${l})
			if(NOT (CVD_TMP_${l} STREQUAL "CVD_TMP_${l}-NOTFOUND"))
				message(STATUS "Found ${l}: ${CVD_TMP_${l}}")
				list(APPEND CVD_FFMPEG_LIBRARIES ${CVD_TMP_${l}})
			endif()
		endforeach()

		list(APPEND CVD_FFMPEG_LIBRARIES ${CMAKE_DL_LIBS} Threads::Threads)

		if(X11_FOUND)
			list(APPEND CVD_FFMPEG_LIBRARIES ${X11_LIBRARIES})
		endif()
		if(X11_Xv_FOUND)
			list(APPEND CVD_FFMPEG_LIBRARIES ${X11_Xv_LIB})
		endif()
		if(X11_Xext_FOUND)
			list(APPEND CVD_FFMPEG_LIBRARIES ${X11_Xext_LIB})
		endif()
		if(X11_Xau_FOUND)
			list(APPEND CVD_FFMPEG_LIBRARIES ${X11_Xau_LIB})
		endif()
		if(X11_Xdmcp_FOUND)
			list(APPEND CVD_FFMPEG_LIBRARIES ${X11_Xdmcp_LIB})
		endif()
	else()
		message(STATUS "FFMPEG - not found")
	endif()
endif()
