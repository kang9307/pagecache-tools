################################################################################
## @file: 	common.flags.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	设定编译参数.
## @version	1.1
###############################################################################

ifneq ($(debug),0)
        debug           = 1
endif

ARFLAGS		        := rcs

ifeq ($(DEFAULT_FLAGS),)
	DEFAULT_FLAGS	:= 1
endif

ifeq ($(USE_PARENT_FLAGS),)
	USE_PARENT_FLAGS := 1
endif

LOCAL_CFLAGS	:=
LOCAL_CXXFLAGS	:=
LOCAL_LDFLAGS	:=


ifeq ($(debug),1)
ifeq ($(USE_PARENT_FLAGS),1)
	LOCAL_CFLAGS	+= $(DCFLAGS_PASS)
	LOCAL_CXXFLAGS	+= $(DCFLAGS_PASS)
	LOCAL_LDFLAGS	+= $(DLDFLAGS_PASS)
endif
	LOCAL_CFLAGS	+= $(DCFLAGS)
	LOCAL_CXXFLAGS	+= $(DCFLAGS)
	LOCAL_LDFLAGS	+= $(DLDFLAGS)
else
ifeq ($(USE_PARENT_FLAGS),1)
	LOCAL_CFLAGS	+= $(CFLAGS_PASS)
	LOCAL_CXXFLAGS	+= $(CFLAGS_PASS)
	LOCAL_LDFLAGS	+= $(LDFLAGS_PASS)
endif
	LOCAL_CFLAGS	+= $(CFLAGS)
	LOCAL_CXXFLAGS	+= $(CFLAGS)
	LOCAL_LDFLAGS	+= $(LDFLAGS)
endif

ifeq ($(DEFAULT_FLAGS),1)
ifeq ($(debug),1)
        LOCAL_CFLAGS	+= -Wall -g -D_DEBUG -pipe
        LOCAL_CXXFLAGS	+= $(LOCAL_CFLAGS)
        LOCAL_LDFLAGS	+= -D_DEBUG -DDEBUG -pipe
else
        LOCAL_CFLAGS	+= -Wall -O3 -pipe
        LOCAL_CXXFLAGS	+= $(LOCAL_CFLAGS)
        LOCAL_LDFLAGS	+= -Wl,-O3 -pipe
endif
else
	LOCAL_CFLAGS	+=
	LOCAL_CXXFLAGS	+=
	LOCAL_LDFLAGS	+=
endif

LOCAL_CFLAGS	:=$(strip $(LOCAL_CFLAGS))
LOCAL_CXXFLAGS	:=$(strip $(LOCAL_CXXFLAGS))
LOCAL_LDFLAGS	:=$(strip $(LOCAL_LDFLAGS))
