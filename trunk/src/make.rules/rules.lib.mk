################################################################################
## @file: 	rules.lib.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	生成共享库的rules.
## @version	1.1
###############################################################################

ifeq ($(release),1)
        debug   = 0
endif

ifeq ($(SOEXT),)
	SOEXT		:= .so
endif

SOEXT		:= $(strip $(SOEXT))

DEPS_DIR	:= .shdeps

ifeq ($(OBJECTS_DIR),)
	OBJECTS_DIR     := .shobjs
endif

include $(MAKE_RULES_DIR)/common.flags.mk
include $(MAKE_RULES_DIR)/common.files.mk
include $(MAKE_RULES_DIR)/common.cmd.mk
include $(MAKE_RULES_DIR)/common.others.mk

TARGET_FILE_SYMBOL		:= lib$(TARGET)$(SOEXT)

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
LOCAL_LDFLAGS += -Wl,-Bsymbolic -Wl,-E -Wl,-h 

include $(MAKE_RULES_DIR)/rules.common.mk

$(TARGET_FILE_FULL): $(OBJECTS)
	@${ECHO} -e "\033[1;35m""\t\tLD      ""\033[0m""\033[4m"${TARGET_FILE_SYMBOL}"\033[0m"
	@$(LD) -shared $(LOCAL_LDFLAGS) -Wl,$(TARGET_FILE_SYMBOL).$(VERSION) $(addprefix $(OBJECTS_DIR)/, $(OBJECTS)) $(LIBS) -o $@
ifneq ($(NVERSION),1)
ifneq ($(OUTDIR),)
	@$(CD)	$(OUTDIR) && $(LN)  $(TARGET_FILE_SYMBOL).$(VERSION) $(TARGET_FILE_SYMBOL)
else
	@$(LN)  $(TARGET_FILE_SYMBOL).$(VERSION) $(TARGET_FILE_SYMBOL)
endif
endif
ifeq ($(debug),0)
	@$(STRIP) $(TARGET_FILE_FULL)
endif
	@$(ECHO)
