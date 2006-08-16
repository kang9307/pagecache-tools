################################################################################
## @file: 	rules.muti.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	生成多个目标的rules.
## @version	1.1
###############################################################################

ifeq ($(MAKEFILE),)
        MAKEFILE        := Makefile
endif

ifeq ($(release),1)
        debug   = 0
endif

PROJS := $(strip $(PROJS))

include $(MAKE_RULES_DIR)/common.flags.mk
include $(MAKE_RULES_DIR)/common.cmd.mk

ifneq ($(PROJS),)

LOCAL_TARGETS	:= all release debug depend clean moreclean distclean compile

.PHONY: $(LOCAL_TARGETS)
#  @${ECHO} -e "\033[1;34m""      Subgoals:""\033[0m""\033[1;37m" ${PROJS}"\033[0m"
#  @${ECHO}
ifeq ($(LOCAL_TOP),)
$(LOCAL_TARGETS): makefile_name
else
$(LOCAL_TARGETS): 
endif
ifeq ($(USE_PARENT_FLAGS),1)
	@$(MAKE) --no-print-directory -S -f $(MAKEFILE) CC="$(CC)" \
	CFLAGS_PASS="$(CFLAGS_PASS) $(CFLAGS)" \
	DCFLAGS_PASS="$(DCFLAGS_PASS) $(DCFLAGS)" \
	LDFLAGS_PASS="$(LDFLAGS_PASS) $(LDFLAGS)" \
	DLDFLAGS_PASS="$(DLDFLAGS_PASS) $(DLDFLAGS)" \
	DEFAULT_FLAGS=$(DEFAULT_FLAGS) release=$(release) \
	LOCAL_TARGET=$@ LOCAL_TOP=0 $(PROJS)
else
	@$(MAKE) --no-print-directory -S -f $(MAKEFILE) CC="$(CC)" \
	CFLAGS_PASS="$(CFLAGS)" \
	DCFLAGS_PASS="$(DCFLAGS)" \
	LDFLAGS_PASS="$(LDFLAGS)" \
	DLDFLAGS_PASS="$(DLDFLAGS)" \
	DEFAULT_FLAGS=$(DEFAULT_FLAGS) release=$(release) \
	LOCAL_TARGET=$@ LOCAL_TOP=0 $(PROJS)
endif

.PHONY: $(PROJS)
$(PROJS):
	@$(MAKE) --no-print-directory -f $(addprefix $(MAKEFILE)., $@) CC="$(CC)" \
	CFLAGS_PASS="$(CFLAGS_PASS)" \
	DCFLAGS_PASS="$(DCFLAGS_PASS)" \
	LDFLAGS_PASS="$(LDFLAGS_PASS)" \
	DLDFLAGS_PASS="$(DLDFLAGS_PASS)" \
	DEFAULT_FLAGS=$(DEFAULT_FLAGS) release=$(release) \
	$(LOCAL_TARGET)

include $(MAKE_RULES_DIR)/rules.one.mk

else
all: makefile_name

endif
include $(MAKE_RULES_DIR)/rules.mkname.mk
