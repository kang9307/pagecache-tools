###############################################################################
## @file: 	rules.mkname.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	输出使用的makefile名称的rules.
## @version	1.1
###############################################################################

LOCAL_TOP	:= 0
ifeq ($(LOCAL_TOP_DIR),)
	LOCAL_TOP	:= 1
	LOCAL_TOP_DIR	:= $(shell pwd)/
endif

ifeq ($(LOCAL_TOP),1)
CURRENT_DIR	:=.
else
CURRENT_DIR	:=$(subst $(LOCAL_TOP_DIR),,$(shell pwd))
endif

.PHONY: makefile_name
makefile_name:
ifeq ($(LOCAL_TOP),1)
	@${ECHO} 
	@${ECHO} -e "\033[37m""     Top Level:""\033[0m""\033[1;30m" ${LOCAL_TOP_DIR}"\033[0m" 
	@${ECHO}
	@${ECHO} -e "\t\t\033[7m""        Author:" "C.F. Xu <johnx@ustc.edu>        ""\033[0m"
	@${ECHO} -e "\t\t\033[7m""       Version:" "1.1 (Clean Style)               ""\033[0m"
	@${ECHO} -e "\t\t\033[7m""       Licence:" "GPL v2                          ""\033[0m"
	@${ECHO} -e "\t\t\033[7m""    Last Modif:" "Mon Jun  5 15:54:30 CST 2006    ""\033[0m"
	@${ECHO}
endif
	@${ECHO} -e "\033[1;33m" Current Level:"\033[0m" ${CURRENT_DIR} 
	@${ECHO} -e "\033[1;33m""      Makefile:""\033[0m" "$(MAKEFILE)"
	@${ECHO}

.PHONY: makefile_name_all
makefile_name_all:  makefile_name
ifeq ($(debug),0)
	@${ECHO} -e "\033[1;36m        Target:""\033[0m" "\033[4m"${TARGET_FILE_SYMBOL}\
	"\033[0m" "(release ${VERSION})"
else
	@${ECHO} -e "\033[1;36m        Target:""\033[0m" "\033[4m"${TARGET_FILE_SYMBOL}\
	"\033[0m" "(debug ${VERSION})"
endif
	@${ECHO} -e "\033[1;36m        Output:""\033[0m" "${OUTDIR}"
	@${ECHO} -e "\033[1;36m       Compile:""\033[0m" "${CC}"
	@${ECHO} -e "\033[1;36m Compile Flags:""\033[0m" "${LOCAL_CFLAGS}" 
	@${ECHO} -e "\033[1;36m          LINK:""\033[0m" "${LD}"
	@${ECHO} -e "\033[1;36m    LINK Flags:""\033[0m" "${LOCAL_LDFLAGS}"
	@${ECHO} 

