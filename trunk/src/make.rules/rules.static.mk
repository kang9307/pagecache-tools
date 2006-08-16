################################################################################
## @file: 	rules.static.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	生成静态库的rules.
## @version	1.1
###############################################################################

ifeq ($(release),1)
        debug   = 0
endif

DEPS_DIR	:= .stdeps

ifeq ($(OBJECTS_DIR),)
	OBJECTS_DIR     := .stobjs
endif

include $(MAKE_RULES_DIR)/common.files.mk
include $(MAKE_RULES_DIR)/common.flags.mk
include $(MAKE_RULES_DIR)/common.cmd.mk
include $(MAKE_RULES_DIR)/common.others.mk

TARGET_FILE_SYMBOL		:= lib$(TARGET).a

ifeq ($(OUTDIR),)
	TARGET_FILE		:= $(TARGET_FILE_SYMBOL)
else
	TARGET_FILE		:= $(OUTDIR)/$(TARGET_FILE_SYMBOL)
endif

ifneq ($(NVERSION),1)
	TARGET_FILE_FULL	:= $(TARGET_FILE).$(VERSION)
else
	TARGET_FILE_FULL	:= $(TARGET_FILE)
endif

LOCAL_CFLAGS  += -fPIC

include $(MAKE_RULES_DIR)/rules.common.mk

$(TARGET_FILE_FULL): $(OBJECTS)
	@${ECHO} -e "\033[1;35m""\t\tAR      ""\033[0m""\033[4m"${TARGET_FILE_SYMBOL}"\033[0m"
	@$(AR) $(ARFLAGS) $@  $(addprefix $(OBJECTS_DIR)/, $(OBJECTS)) 
ifneq ($(NVERSION),1)
ifneq ($(OUTDIR),)
		-@$(CD)	$(OUTDIR) && $(LN)  $(TARGET_FILE_SYMBOL).$(VERSION) $(TARGET_FILE_SYMBOL)
else
		-@$(LN)  $(TARGET_FILE_SYMBOL).$(VERSION) $(TARGET_FILE_SYMBOL)
endif
endif
	@$(ECHO)
