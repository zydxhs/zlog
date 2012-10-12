#!/usr/bin/env python
# -*- coding=utf-8 -*-

import os
import sys
import shutil
import logging
import platform
import codecs
from argparse import ArgumentParser
import multiprocessing
from subprocess import Popen, PIPE

#===================================================
# 各种路径
#===================================================
# 项目所在文件夹
project_dir = os.getcwd()
# 编译文件夹
build_dir = project_dir + '/build/%s' % platform.system()

#====================================================
# cmake 参数
#====================================================
class CMakeOptions(object):
    """
    """
    def __init__(self):
        """
        """
        self._opts = ['cmake'] 

    def set_generater(self, toolset, env):
        """
        """
        if args.env == 'mingw64' and args.toolset == 'msvc':
            logging.error('mingw64 env not support msvc build tool!')
            return 

        if toolset == 'msvc':
            self._opts.append('-G')
            self._opts.append("Nmake Makefiles")
        elif env == 'mingw64':
            self._opts.append('-G')
            self._opts.append("MinGW Makefiles")
        else:
            self._opts.append('-G')
            self._opts.append("Unix Makefiles")

    def set_build_type(self, build_type):
        """
        """
        self._opts.append('-DCMAKE_BUILD_TYPE=%s' % build_type) 

    def set_env(self, env):
        """
        """
        if env == 'native':
            logging.info('use native environment.')
            return

        self._opts.append('-DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-%s.cmake' % env)

    def set_test(self, need_test):
        """
        """
        if need_test:
            self._opts.append('-DUNIT_TEST=1')

    def get_opts(self):
        return self._opts + [project_dir]

# 定义一个全局变量
cmake_options = CMakeOptions()

#===================================================
# 各种函数
#===================================================
def set_log(level):
    """
    设置日志级别
    """
    log_level = {
            'error' : logging.ERROR,
            'warning' : logging.WARNING,
            'info' : logging.INFO,
            'debug' : logging.DEBUG
            }
    logging.basicConfig(level = log_level[level])

def cvt_encoding(TO_NO_BOM = None):
    """
    vc必须只能识别带bom的utf-8编码，而gcc不能识别带bom的utf-8编码
    默认情况下，linux下使用无bom的utf-8编码，windows采用带bom的utf-8编码。
    ？？git是否可以自动转换？？这个需要确定。
    True : 将带BOM的utf-8格式文件转换为不带BOM的utf-8格式
    False: 将不带BOM的utf-8格式文件转换为带BOM的utf-8格式
    """
    file_types = set(['.cpp', '.hpp', '.ipp', '.c', '.h'])

    logging.warning('开始执行编码转换[cvt_encoding][TO_NO_BOM = %s]' % str(TO_NO_BOM))
    cvt_count = 0

    for r, ds, fs in os.walk('.'):
        # 忽略第三方头文件
        if 'thrid_part' in r:
            continue

        for fn in fs:
            # 只处理指定类型文件，如果不是指定类型，跳过
            ft = os.path.splitext(fn)[1]
            if ft not in file_types:
                continue

            # 读取文件内容
            buf = ''
            fn = r + os.sep + fn
            f = codecs.open(fn, 'r', encoding = 'utf-8')
            buf = f.read()
            f.close()

            # buf为空，不需要转换
            if len(buf) == 0:
                continue

            if buf[0] == '\ufeff' and TO_NO_BOM is True:
                buf = buf.lstrip('\ufeff')
            elif buf[0] != '\ufeff' and TO_NO_BOM is False:
                buf = '\ufeff' + buf
            else:
                # 已经是指定的格式，不需要转换
                continue

            logging.info('正在转换文件[%s]...' % fn)
            f = codecs.open(fn, 'w', encoding = 'utf-8')
            f.write(buf)

            logging.info('转换文件[%s]完成。' % fn)
            cvt_count += 1

    logging.info('成功转换%d个文件的编码。' % cvt_count)

def make_clean():
    """
    清除上次编译的结果
    """
    if os.path.isdir(build_dir) == False:
        return
    
    # 直接删除目录及其文件
    shutil.rmtree(build_dir)

    # 删除预编译头文件 todo

def get_make_cmd():
    """
    根据平台生成make命令行
    """
    make_cmd = []

    # 获取cpu核数, 用于制定并行工作线程数
    work_count = multiprocessing.cpu_count()
    if work_count > 1:
        work_count -= 1

    if os.name == 'posix':
        make_cmd.append('make')
        make_cmd.append('-j' + str(work_count))
        return make_cmd

    if os.name != 'nt':
        logging.warning('不支持的操作系统[%s]' % os.name)
        quit(-1)

    # todo add jom support
    make_cmd.append('mingw32-make')
    return make_cmd

def make():
    """
    编译
    cmake -> make
    """
    # 创建编译目录
    if os.path.isdir(build_dir) == False:
        os.makedirs(build_dir)

    os.chdir(build_dir)

    # cmake 建立 Makefile
    logging.info(' '.join(x for x in cmake_options.get_opts()))
    proc = Popen(cmake_options.get_opts())
    proc.communicate()
    if proc.wait() != 0:
        logging.error( 'cmake fail.' )
        quit(-1)

    make_cmd = get_make_cmd()

    logging.info(''.join(x + ' ' for x in make_cmd))
    proc = Popen(make_cmd)
    proc.communicate()
    if proc.wait() != 0:
        logging.error( 'make fail.' )
        quit(-1)

    os.chdir(project_dir)

def get_test_cmd():
    """
    """
    if os.name == 'posix':
        return ['make', 'test']
    else:
        return ''

def make_test():
    """
    单元测试。
    """
    os.chdir(build_dir)

    make_cmd = get_test_cmd()

    logging.info(''.join(x + ' ' for x in make_cmd))
    proc = Popen(make_cmd)
    proc.communicate()
    if proc.wait() != 0:
        logging.error('make test fail.' )
        quit(-1)

    os.chdir(project_dir)

def get_package_cmd():
    """
    """
    if os.name == 'posix':
        return ['cpack', '--config']
    else:
        return ''

def make_package():
    """
    打包
    """
    os.chdir(build_dir)

    make_cmd = get_package_cmd()

    for r, dirs, files in os.walk('cpack/'):
        for f in files:
            if f != 'CPackConfig.cmake':
                continue

            p = r + '/' + f
            c = []
            c.extend(make_cmd)
            c.append(p)
            logging.info(''.join(x + ' ' for x in c))

            proc = Popen(c)
            proc.communicate()
            if proc.wait() != 0:
                logging.error('make package fail.' )
                quit(-1)

    os.chdir(project_dir)

def get_doc_cmd():
    """
    """
    if os.name == 'posix':
        return ['make', 'doc']
    else:
        return ''

def make_doc():
    """
    打包
    """
    os.chdir(build_dir)

    make_cmd = get_doc_cmd()

    logging.info(''.join(x + ' ' for x in make_cmd))
    proc = Popen(make_cmd)
    proc.communicate()
    if proc.wait() != 0:
        logging.error('make doc fail.' )
        quit(-1)

    os.chdir(project_dir)

#==============================================================
# main 入口
#==============================================================
if __name__ == '__main__':
    """
    """
    set_log('info')

    parser = ArgumentParser()

    parser.add_argument('-c', '--clean', action='store_true', help = 'clean project.')
    parser.add_argument('-p', '--package', action='store_true', help = 'clean project.')
    parser.add_argument('-b', '--build', choices=['Debug', 'Release'], default='Release', help = 'build release or debug version.')
    parser.add_argument('-t', '--toolset', choices=['gcc', 'msvc'], default = 'gcc', help = 'specify the build tool set.')
    parser.add_argument('-a', '--arch', choices=['i686', 'x86_64'], default=platform.processor(), help = '32bit or 64bit version.')
    parser.add_argument('-e', '--env', choices=['native', 'mingw64'], default='native', help = 'build enviroment, support host native or mingw64 environment.')
    parser.add_argument('--gendoc', action='store_true', help = 'generate develop doc.')
    parser.add_argument('--test', action='store_false', help = 'run unittest after build.')
    parser.add_argument('--codecoverage', action='store_true', help = 'run unittest and code coverage after build.')

    args = parser.parse_args()

    logging.info('build with below options:')
    logging.info(args)

    if args.clean:
        make_clean()
        exit(0)

    if platform.system() == 'Windows' and args.toolset == 'msvc':
        cvt_encoding(TO_NO_BOM = False)
    else:
        cvt_encoding(TO_NO_BOM = True)

    cmake_options.set_build_type(args.build)
    cmake_options.set_env(args.env)
    cmake_options.set_test(args.codecoverage or args.test)
    cmake_options.set_generater(args.toolset, args.env)
    
    make()

    if args.package:
        make_package()

    if args.gendoc:
        make_doc()

    if args.codecoverage:
        make_code_coverage()
    elif args.test:
        make_test()


