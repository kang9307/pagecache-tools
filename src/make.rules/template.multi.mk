################################################################################
## @file: 	template.multi.mk
## @author:	徐陈锋 <johnx@mail.ustc.edu.cn>
## @brief	同一目录下多个生成目标的makefile模板.
## @version	1.1
###############################################################################

## NOTE: 这里认为一个生成目标对应一个工程. '当前目录'指$(MAKEFILE)所在目录.

## makefile 文件名，默认为 'Makefile'. 如果文件名不为'Makefile', 必须设定.
MAKEFILE	:=

## 子工程列表. 注意: 
##	1. 如果包含子目录需引用另一个makefile, 如对应的Makefile.dirs;
##	2. 每个子工程的makefile名为: $(MAKEFILE).'子工程名';
## 例子:
## 当前目录下有以下目录: dir1 dir2
## 有以下makefile: Makefile Makefile.proj1 Makefile.proj2 Makefile.dirs
## Makefile使用此模板, 其中'MAKEFILE:=Makefile', 'PROJS:= proj1 proj2 dirs';
## Makefile.dirs使用template.dir.mk模板, 其中'MAKEFILE:=Makefile.dirs', 
## 'DIRS:=dir1 dir2'.
PROJS		:=

## DOXYGEN配置文件名(需包含路径), 默认为'Doxyfile'.
#DOXYFILE	:= Doxyfile

## 自动生成(doxygen)文档存放目录. 'make distclean'会清空这个目录,其他文档不要
## 存放在此目录.
#DOCSDIR	:=

## 是否使用默认的编译参数. 默认编译参数, 
##	debug: 		CFLAGS=-Wall -g -D_DEBUG, LDFLAGS= 
##	release:	CFLAGS=-Wall -O3, LDFLAGS=-Wl,-O3 
## 在使用默认参数的情况下, 还可以使用下面的CFLAGS, LDFLAGS, DCFLAGS, DLDFLAGS
## 增加编译参数, 甚至覆盖. 默认为使用编译参数. 注意, 无论子项目里是否设定这个
## 参数，都使用父项目的这个参数的值.
#DEFAULT_FLAGS	:= 0

## 是否使用父项目的FLAGS. 默认使用
#USE_PARENT_FLAGS := 0

## 编译和链接参数设定. 无论C还是C++都使用CFLAGS LDFLAGS, 即CPPFLAGS or CXXFLAGS
## 没有被使用. 注意: 这样是不支持C和C++或其他语言混编的, 当然C代码可以当成C++来
## 编译. 如果是个子项目, 使用父项目的编译参数, 注释掉相应的行. CFLAGS和
## LDFLAGS用于release编译参数; DCFLAGS和DLDFLAGS用于debug编译参数.
CFLAGS		:= 
DCFLAGS		:=
LDFLAGS		:= 
DLDFLAGS	:= 

## 编译参数指定顺序：DEFAULT FLAGS + PARENT FLAGS + THIS FLAGS 

## 设定make和make all的默认编译参数为release还是debug. 默认为debug, 即release=0
## 注意, 无论子项目里是否设定这个参数，都使用父项目的这个参数的值.
#release	:= 1

## 需要设定环境变量'MAKE_RULES_DIR'.
include $(MAKE_RULES_DIR)/rules.multi.mk
