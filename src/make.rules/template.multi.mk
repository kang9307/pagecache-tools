################################################################################
## @file: 	template.multi.mk
## @author:	��·� <johnx@mail.ustc.edu.cn>
## @brief	ͬһĿ¼�¶������Ŀ���makefileģ��.
## @version	1.1
###############################################################################

## NOTE: ������Ϊһ������Ŀ���Ӧһ������. '��ǰĿ¼'ָ$(MAKEFILE)����Ŀ¼.

## makefile �ļ�����Ĭ��Ϊ 'Makefile'. ����ļ�����Ϊ'Makefile', �����趨.
MAKEFILE	:=

## �ӹ����б�. ע��: 
##	1. ���������Ŀ¼��������һ��makefile, ���Ӧ��Makefile.dirs;
##	2. ÿ���ӹ��̵�makefile��Ϊ: $(MAKEFILE).'�ӹ�����';
## ����:
## ��ǰĿ¼��������Ŀ¼: dir1 dir2
## ������makefile: Makefile Makefile.proj1 Makefile.proj2 Makefile.dirs
## Makefileʹ�ô�ģ��, ����'MAKEFILE:=Makefile', 'PROJS:= proj1 proj2 dirs';
## Makefile.dirsʹ��template.dir.mkģ��, ����'MAKEFILE:=Makefile.dirs', 
## 'DIRS:=dir1 dir2'.
PROJS		:=

## DOXYGEN�����ļ���(�����·��), Ĭ��Ϊ'Doxyfile'.
#DOXYFILE	:= Doxyfile

## �Զ�����(doxygen)�ĵ����Ŀ¼. 'make distclean'��������Ŀ¼,�����ĵ���Ҫ
## ����ڴ�Ŀ¼.
#DOCSDIR	:=

## �Ƿ�ʹ��Ĭ�ϵı������. Ĭ�ϱ������, 
##	debug: 		CFLAGS=-Wall -g -D_DEBUG, LDFLAGS= 
##	release:	CFLAGS=-Wall -O3, LDFLAGS=-Wl,-O3 
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
LDFLAGS		:= 
DLDFLAGS	:= 

## �������ָ��˳��DEFAULT FLAGS + PARENT FLAGS + THIS FLAGS 

## �趨make��make all��Ĭ�ϱ������Ϊrelease����debug. Ĭ��Ϊdebug, ��release=0
## ע��, ��������Ŀ���Ƿ��趨�����������ʹ�ø���Ŀ�����������ֵ.
#release	:= 1

## ��Ҫ�趨��������'MAKE_RULES_DIR'.
include $(MAKE_RULES_DIR)/rules.multi.mk