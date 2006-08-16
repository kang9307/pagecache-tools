################################################################################
## @file: 	common.files.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	设定各种文件变量和文件列表变量.
## @version	1.1
###############################################################################

ifeq ($(FILE_H_SUFFIX),)
	FILE_H_SUFFIX 	= .h
endif

ifeq ($(FILE_SUFFIX),)
	FILE_SUFFIX	= .cpp
endif

ifeq ($(FILES_H),)
	FILES_H		:= $(wildcard *$(FILE_H_SUFFIX))
endif

ifeq ($(FILES),)
	FILES		:= $(wildcard *$(FILE_SUFFIX))
endif

FILES_DEPS		:= $(patsubst %$(FILE_SUFFIX),%.dep,$(FILES))
OBJECTS			:= $(patsubst %$(FILE_SUFFIX),%.o,$(FILES))

ifeq ($(DOXYFILE),)
	DOXYFILE	:= Doxyfile
endif

ifeq ($(MAKEFILE),)
        MAKEFILE        := Makefile
endif
