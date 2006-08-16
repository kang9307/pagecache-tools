使用
1. 设定环境变量MAKE_RULES_DIR, 设为*.mk所在的目录. 

2. 拷贝对应的template.*.mk到你的工程目录, 修改相应的项

3. 可用的make目标有: all release debug dependency clean moreclean distclean cscope docs tags.
  (1) make/make all:  同make debug, 可以在makefilezhong设定release=1，则同make release
  (2) make release:   使用release的默认编译参数
  (3) make debug:     使用debug的默认编译参数
  (4) make dependency 用于解决依赖问题（由于.h文件删除或改名而产生） 
  (4) make clean:     清掉$(OBJECTS) 和 $(TARGET)对应生成文件
  (4) make moreclean: 清掉$(OBJECTS) 和 $(TARGET)对应生成的各个版本的文件
  (5) make distclean:清掉所有make目标生成内容
  (6) make cscope:   生成cscope使用的索引
  (7) make tags:     生成ctags使用的索引
  (8) make docs:     使用doxygen生成文档
  (9) 使用template.multi.mk, 还可以单独生成其中的某个子项目, 使用 'make 子项目名'
  (10)使用template.dirs.mk, 还可以单独编译其中的某个子目录, 使用 'make 子目录名'

4. 具体见相应的template.*.mk


TODO:
    1. 整理代码.
    2. 颜色变量定义与增强.
    3. gcc错误输出的加亮/着色增强.
    ...
    99.  another template, that uses shared vars define through parent to children.
    100. enhance multiple targets for same sources

PASS: If your remove/rename a '.h' file and 'make' report errors, your may need 'make depend'.

                
                                徐陈锋 2006/6/5 <johnx@mail.ustc.edu.cn>
