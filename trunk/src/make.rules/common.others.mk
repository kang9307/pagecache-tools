################################################################################
## @file: 	common.others.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	设定其他使用到的变量.
## @version	1.1
###############################################################################

TARGET		:= $(strip $(TARGET))
OUTDIR		:= $(strip $(OUTDIR))
VERSION		:= $(strip $(VERSION))
DATE		:= $(shell date +%Y%m%d)
VPATH   	:= $(OBJECTS_DIR):$(DEPS_DIR):.

ifeq ($(DOCS_DIR),)
	DOCS_DIR 	:= docs 
endif

ifeq ($(VERSION),)
ifeq ($(debug),1)
	VERSION		:= $(DATE)
else
	VERSION		:= r$(DATE)
endif
else
ifeq ($(debug),1)
	VERSION		:= $(VERSION).$(DATE)
endif
endif

ifeq ($(NVERSION),)
	NVERSION	:= 0
endif

