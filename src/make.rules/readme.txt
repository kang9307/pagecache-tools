ʹ��
1. �趨��������MAKE_RULES_DIR, ��Ϊ*.mk���ڵ�Ŀ¼. 

2. ������Ӧ��template.*.mk����Ĺ���Ŀ¼, �޸���Ӧ����

3. ���õ�makeĿ����: all release debug dependency clean moreclean distclean cscope docs tags.
  (1) make/make all:  ͬmake debug, ������makefilezhong�趨release=1����ͬmake release
  (2) make release:   ʹ��release��Ĭ�ϱ������
  (3) make debug:     ʹ��debug��Ĭ�ϱ������
  (4) make dependency ���ڽ���������⣨����.h�ļ�ɾ��������������� 
  (4) make clean:     ���$(OBJECTS) �� $(TARGET)��Ӧ�����ļ�
  (4) make moreclean: ���$(OBJECTS) �� $(TARGET)��Ӧ���ɵĸ����汾���ļ�
  (5) make distclean:�������makeĿ����������
  (6) make cscope:   ����cscopeʹ�õ�����
  (7) make tags:     ����ctagsʹ�õ�����
  (8) make docs:     ʹ��doxygen�����ĵ�
  (9) ʹ��template.multi.mk, �����Ե����������е�ĳ������Ŀ, ʹ�� 'make ����Ŀ��'
  (10)ʹ��template.dirs.mk, �����Ե����������е�ĳ����Ŀ¼, ʹ�� 'make ��Ŀ¼��'

4. �������Ӧ��template.*.mk


TODO:
    1. �������.
    2. ��ɫ������������ǿ.
    3. gcc��������ļ���/��ɫ��ǿ.
    ...
    99.  another template, that uses shared vars define through parent to children.
    100. enhance multiple targets for same sources

PASS: If your remove/rename a '.h' file and 'make' report errors, your may need 'make depend'.

                
                                ��·� 2006/6/5 <johnx@mail.ustc.edu.cn>
