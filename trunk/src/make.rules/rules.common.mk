################################################################################
## @file: 	rules.common.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	公用的rules.
## @version	1.1
###############################################################################

.PHONY: all 
all: makefile_name_all depend.local $(TARGET_FILE_FULL)
	@${ECHO} -e "         ""\033[1;32m""generating  "\""\033[4m"$(TARGET_FILE_SYMBOL)\
	"\033[0m""\033[1;32m"\""  successfuly.""\033[0m"
	@${ECHO} 

.PHONY: release
release:  
ifneq ($(release),1)
	@$(RM) $(addprefix $(OBJECTS_DIR)/, $(OBJECTS))
endif
	@$(MAKE) --no-print-directory -S -f $(MAKEFILE) release=1 all

.PHONY: debug
debug:
ifeq ($(release),1)
	@$(RM) $(addprefix $(OBJECTS_DIR)/, $(OBJECTS))
endif
	@$(MAKE) --no-print-directory -S -f $(MAKEFILE) release=0 all

.PHONY: compile
compile: makefile_name_all depend.local $(OBJECTS)
	@$(ECHO)
	@${ECHO} -e "\t\t""\033[1;32m""done successfuly.""\033[0m"
	@${ECHO} 

.PHONY: clean 
clean: makefile_name
#  @$(ECHO) -e "\033[1;31m"\t\tCLEAN"   ""$(TARGET_FILE) $(OBJECTS)""\033[0m"
	@$(ECHO) -e "\033[1;31m""\t\tCLEAN   ""\033[0m""\033[4m"$(TARGET_FILE_SYMBOL)"\033[0m"
	@$(RM) $(TARGET_FILE) $(TARGET_FILE_FULL) $(addprefix $(OBJECTS_DIR)/, $(OBJECTS))
	@$(ECHO)

.PHONY: moreclean 
moreclean: makefile_name 
#  @$(ECHO) -e "\033[1;31m"\t\tCLEAN"   ""$(filter-out $(FILES) $(FILES_H),$(wildcard $(TARGET_FILE)*)) $(OBJECTS)""\033[0m"
	@$(ECHO) -e "\033[1;31m""\t\tCLEAN   ""\033[0m""\033[4m"$(TARGET_FILE_SYMBOL)"\033[0m"
	@$(RM) $(filter-out $(FILES) $(FILES_H),$(wildcard $(TARGET_FILE)*)) $(addprefix $(OBJECTS_DIR)/, $(OBJECTS))
	@$(ECHO)

.PHONY: distclean
.PHONY: depend
distclean: makefile_name
#  @$(ECHO) -e "\033[1;35m"clean"\033[1;31m" \
"$(filter-out $(FILES) $(FILES_H),$(wildcard $(TARGET_FILE)*)) $(OBJECTS)" \
"tags cscope.out $(DEPS_DIR) $(OBJECTS_DIR) $(DOCS_DIR)""\033[0m"
	@$(ECHO) -e "\033[1;31m""\t\tCLEAN   ""\033[0m""\033[4m"$(TARGET_FILE_SYMBOL)"\033[0m"
	@$(RM) $(filter-out $(FILES) $(FILES_H),$(wildcard $(TARGET_FILE)*))
	@$(RM) tags cscope.out
	@$(RM) $(DEPS_DIR) $(OBJECTS_DIR)
	@$(RM) $(DOCS_DIR)
	@$(ECHO)

$(OBJECTS): %.o: %$(FILE_SUFFIX)
	@${ECHO} -e "\033[1;35m""\t\tCC      ""\033[0m"$@ 
	@$(CC) -c $(LOCAL_CFLAGS) $(INCLUDES) -o $(OBJECTS_DIR)/$@ $< 

$(FILES_DEPS): %.dep: %$(FILE_SUFFIX) 
	@${ECHO} -e "\033[1;35m""\t\tDEP     ""\033[0m"$< 
	@$(CC) -MM -MP $(INCLUDES) -MF $(DEPS_DIR)/$@ $< 
	@cat $(DEPS_DIR)/$@ | sed -e "s/\(^\S\+\)\.o/\1.o \1.dep/g" > $(DEPS_DIR)/$@.d

.PHONY: depend.local
depend.local: mkdirs.local $(FILES_DEPS)

.PHONY: depend
depend: makefile_name_all depend.clean depend.local 
	@$(ECHO)
	@${ECHO} -e "\t\t""\033[1;32m""done successfuly.""\033[0m"
	@${ECHO} 
	

.PHONY: depend.clean
depend.clean:
	@$(RM) $(DEPS_DIR) $(OBJECTS_DIR)

.PHONY: mkdirs.local
mkdirs.local: $(DEPS_DIR) $(OBJECTS_DIR)

$(DEPS_DIR) $(OBJECTS_DIR):
#  @${ECHO} -e "\033[0;33m" MKDIR   $@ "\033[0m"
	@$(MKDIR) $@ 

ifeq ($(findstring $(MAKECMDGOALS), depend depend.local depend.clean mkdirs.local clean moreclean distclean tags cscope docs makefile_name),)
-include $(addsuffix .d,$(addprefix $(DEPS_DIR)/, $(FILES_DEPS)))
endif

include $(MAKE_RULES_DIR)/rules.one.mk
include $(MAKE_RULES_DIR)/rules.mkname.mk
