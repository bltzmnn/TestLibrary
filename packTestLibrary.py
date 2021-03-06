# -*- coding: utf-8 -*-

import os
import shutil
import compileall
import Tkinter

from sys import argv

# 库名称
pack_list = ['TestCenter', 'WireShark', 'Wireless']


# 打包类
class Pack(object):

    work_path = "F:\\GitHub\\TestLibrary"
    compiler_path = "C:\\Users\\zhaojun\\Desktop\\plugin"

    # 初始化相应变量
    def __init__(self, name):
        self.name = name

    # 复制工作文件到指定编译输出路径
    def file_copy(self, work_dir, compiler_dir, filename):
        work_dir_file = os.path.join(work_dir, filename)
        compiler_file = os.path.join(compiler_dir, filename)
        shutil.copyfile(work_dir_file, compiler_file)

        return compiler_file

    # tcl文件编译方法
    def tcl_compile(self, compiler_file):
        tcl_obj = Tkinter.Tcl()

        cmd = 'exec tclcompiler {%s}' % (compiler_file)
        tcl_ret = tcl_obj.eval(cmd)

        return tcl_ret

    # py文件编译方法
    def py_compile(self, compile_file):

        py_ret = compileall.compile_file(compile_file)

        return py_ret


# 一般库打包
def pack_default(name):
    if name == 'TestCenter':
        pack_testcenter()
    else:
        plugin = Pack(name)

        work_dir = os.path.join(plugin.work_path, plugin.name, 'Trunk')
        compiler_dir = os.path.join(plugin.compiler_path, plugin.name)

        if not os.path.exists(compiler_dir):
            os.makedirs(compiler_dir)

        name = 'ATT' + plugin.name + '.py'
        compiler_file1 = plugin.file_copy(work_dir, compiler_dir, '__init__.py')
        compiler_file2 = plugin.file_copy(work_dir, compiler_dir, name)

        try:

            plugin.py_compile(compiler_file1)
            plugin.py_compile(compiler_file2)
            print u"编译py文件成功"

        except Exception,e:
            info = u"编译文件发生异常，错误信息为：%s" % e
            print info

        os.remove(compiler_file1)
        os.remove(compiler_file2)

# TestCenter库打包
def pack_testcenter():
    testcenter = Pack('TestCenter')

    work_dir = os.path.join(testcenter.work_path, 'TestCenter', 'Trunk')
    compiler_dir = os.path.join(testcenter.compiler_path, 'TestCenter')
    work_dir_client = os.path.join(work_dir, 'client')
    work_dir_server = os.path.join(work_dir, 'server')
    compiler_dir_client = os.path.join(compiler_dir, 'client')
    compiler_dir_server = os.path.join(compiler_dir, 'server')

    if not os.path.exists(compiler_dir):
        os.makedirs(compiler_dir)

    if not os.path.exists(compiler_dir_client):
        os.makedirs(compiler_dir_client)

    if not os.path.exists(compiler_dir_server):
        os.makedirs(compiler_dir_server)

    compiler_file1 = testcenter.file_copy(work_dir, compiler_dir, '__init__.py')
    compiler_file2 = testcenter.file_copy(work_dir_client, compiler_dir_client, 'ATTTestCenter.py')
    compiler_file3 = testcenter.file_copy(work_dir_client, compiler_dir_client, 'ATTTestCenter.tcl')
    compiler_file4 = testcenter.file_copy(work_dir_server, compiler_dir_server, 'ATTTestCenter.tcl')
    compiler_file5 = testcenter.file_copy(work_dir_server, compiler_dir_server, 'TestCenter.tcl')

    try:

        testcenter.py_compile(compiler_file1)
        testcenter.py_compile(compiler_file2)
        print u"编译py文件成功"
        testcenter.tcl_compile(compiler_file3)
        testcenter.tcl_compile(compiler_file4)
        testcenter.tcl_compile(compiler_file5)
        print u"编译tcl文件成功"

    except Exception,e:
        info = u"编译文件发生异常，错误信息为：%s" % e
        print info

    os.remove(compiler_file1)
    os.remove(compiler_file2)
    os.remove(compiler_file3)
    os.remove(compiler_file4)
    os.remove(compiler_file5)

# 判断用户输入编译库名
if len(argv) == 1:
    for var in pack_list:
        pack_default(var)
else:
    argv = argv[1:]
    for var in argv:
        if var in pack_list:
            pack_default(var)
        else:
            print u"不存在 %s 库" % var
