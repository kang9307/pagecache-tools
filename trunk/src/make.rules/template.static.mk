################################################################################
## @file: 	template.static.mk
## @author:	��·� <johnx@mail.ustc.edu.cn>
## @brief	��̬���makefileģ��.
## @version	1.1
###############################################################################

## NOTE: ������Ϊһ������Ŀ���Ӧһ������. '��ǰĿ¼'ָ$(MAKEFILE)����Ŀ¼.

## makefile �ļ�����Ĭ��Ϊ 'Makefile'. ����ļ�����Ϊ'Makefile', �����趨.
MAKEFILE	:=

## ����Ŀ������. ���ɵ�Ŀ���ļ���Ϊlib$(TARGET).a.$(VERSION), ��release��
## Ҫ���ϵ�ǰ'������'. �����趨.
TARGET		:=

## ����Ŀ������Ŀ¼, Ĭ��Ϊ��ǰĿ¼.
#OUTDIR		:=

## �汾�ţ�Ĭ��Ϊ��ǰ'������'��'make release'ʱΪ'r������'.
#VERSION	:=

## �Ƿ���Ҫ�汾�ţ�Ĭ������Ҫ��ֵ0/1: 0, ��Ҫ; 1, ����Ҫ.
#NVERSION	:= 1

## �������Ŀ¼, ��ʽΪ'-I_THE_DIR_', ÿ��'-I'һ��Ŀ¼, �ö��'-I'��ָ�����
## ����Ŀ¼.
#INCLUDES	:=

## ָ���������Ŀ�. ��������Ŀ������Ϊ'libLIBNAME.so', ����'-lLIBNAME'ָ��
## ����'_THE_DIR_WHERE_LIB_LIES_/libLIBNAME.so'. �ڵ�һ�з�ʽ��, ���������
## ��Ŀ¼����ϵͳĬ�ϵ�Ŀ¼, Ҳû����/etc/ld.so.conf�г���, ��'-L'ָ��, ��,
## '-L_THE_DIR_WHERE_LIB_LIES_'. ÿһ��'-l'��'-L'ָ��һ��, �ö��'-l'/'-L'ָ
## ������.
#LIBS		:=

## ����Ŀ�����ڹ��̵�ͷ�ļ��ĺ�׺��, Ĭ��Ϊ'.h'. ����趨��'FILES_H', ������
## �趨'FILE_H_SUFFIX', Ҳ��������.
#FILE_H_SUFFIX	:= .h

## ����Ŀ�����ڹ��̵�Դ�ļ��ĺ�׺��, Ĭ��Ϊ'.cpp'. ����趨��'FILES', ������
## �趨'FILES', Ҳ��������.
#FILE_SUFFIX	:= .cpp

## ͷ�ļ��б�. Ĭ��Ϊ'FILES_H=$(wildcard *$(FILE_H_SUFFIX))', ����ǰĿ¼�µ�
## ������'$(FILE_H_SUFFIX)'Ϊ��׺���ļ�.
#FILES_H	:=

## Դ�ļ��б�. Ĭ��Ϊ'FILES=$(wildcard *$(FILE_SUFFIX))', ����ǰĿ¼�µ�����
## ��'$(FILE_SUFFIX)'Ϊ��׺����. 
#FILES		:=

## DOXYGEN�����ļ���(�����·��), Ĭ��Ϊ'Doxyfile'.
#DOXYFILE	:= Doxyfile

## �Զ�����(doxygen)�ĵ����Ŀ¼. 'make distclean'��������Ŀ¼,�����ĵ���Ҫ
## ����ڴ�Ŀ¼.
#DOCSDIR	:=

## �Ƿ�ʹ��Ĭ�ϵı������. Ĭ�ϱ������, 
##	debug: 		CFLAGS=-Wall -g -fPIC -D_DEBUG 
##	release:	CFLAGS=-Wall -O3 -fPIC 
## ��ʹ��Ĭ�ϲ����������, ������ʹ�������CFLAGS, LDFLAGS, DCFLAGS, DLDFLAGS
## ���ӱ������, ��������. Ĭ��Ϊʹ�ñ������. ע��, ��������Ŀ���Ƿ��趨���
## ��������ʹ�ø���Ŀ�����������ֵ.
#DEFAULT_FLAGS	:= 0

## �Ƿ�ʹ�ø���Ŀ��FLAGS. Ĭ��ʹ��
#USE_PARENT_FLAGS := 0

## ��������Ӳ����趨. ����C����C++��ʹ��CFLAGS LDFLAGS, ��CPPFLAGS or CXXFLAGS
## û�б�ʹ��. ע��: �����ǲ�֧��C��C++���������Ի���, ��ȻC������Ե���C++��
## ����. ����Ǹ�����Ŀ, ʹ�ø���Ŀ�ı������, ע�͵���Ӧ����. CFLAGS��
## LDFLAGS����release�������; DCFLAGS��DLDFLAGS����debug�������.
CFLAGS		:= 
DCFLAGS		:=

## �������ָ��˳��DEFAULT FLAGS + PARENT FLAGS + THIS FLAGS 

## ����. See 'common.cmd.mk' for more.
#CC		:= cc
#CXX		:= c++
#CPP		:= cpp
#LD		:= $(CC) 

## �趨make��make all��Ĭ�ϱ������Ϊrelease����debug. Ĭ��Ϊdebug, ��release=0
## ע��, ��������Ŀ���Ƿ��趨�����������ʹ�ø���Ŀ�����������ֵ.
#release	:= 1

## ��Ҫ�趨��������'MAKE_RULES_DIR'.
include $(MAKE_RULES_DIR)/rules.static.mk
