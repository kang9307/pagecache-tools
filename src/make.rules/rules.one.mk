
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

ifeq ($(DOCS_DIR),)
	DOCS_DIR 	:= docs 
endif

tags: makefile_name_all $(FILES) $(FILES_H) 
	@${ECHO} -e "\033[1;35m""\t\tCTAGS   ""\033[0m"tags 
	@$(CTARGS) $(FILES) $(FILES_H)
	@$(ECHO)
	@${ECHO} -e "\t\t""\033[1;32m""done successfuly.""\033[0m"
	@${ECHO} 

cscope: makefile_name_all $(FILES) $(FILES_H)
	@${ECHO} -e "\033[1;35m""\t\tCTAGS   ""\033[0m"cscope
	@$(CSCOPE_CMD) $(FILES) $(FILES_H)
	@$(ECHO)
	@${ECHO} -e "\t\t""\033[1;32m""done successfuly.""\033[0m"
	@$(ECHO)

docs: makefile_name_all $(DOXYFILE) $(FILES_H) $(FILES)
	@$(MKDIR) $(DOCS_DIR)
	@doxygen $(DOXYFILE) 
	@$(ECHO)
	@${ECHO} -e "\t\t""\033[1;32m""done successfuly.""\033[0m"
	@$(ECHO)
