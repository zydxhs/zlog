#!/usr/bin/env python
# -*- coding=utf-8 -*-

import os
import sys
#===================================================
# 各种路径
#===================================================
# 项目所在文件夹
project_dir = os.path.abspath(os.path.dirname(sys.argv[0]))
# 编译文件夹
build_dir = os.path.join(project_dir, 'build')

# 有些老版本缺少库，需要从这里加载
sys.path.append(os.path.join(project_dir, 'dist-packages'))

import glob
import shutil
import logging
import platform
import codecs
from argparse import ArgumentParser
import multiprocessing
from subprocess import Popen, PIPE


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

    def set_generater(self, toolset, arch):
        """
        """
        if arch == 'mingw64' and toolset == 'msvc':
            logging.error('mingw64 env not support msvc build tool!')
            return 

        if toolset == 'msvc':
            self._opts.append('-G')
            self._opts.append("Nmake Makefiles")
        elif arch == 'mingw64':
            self._opts.append('-G')
            self._opts.append("MinGW Makefiles")
        else:
            self._opts.append('-G')
            self._opts.append("Unix Makefiles")

        if arch != platform.processor():
            self.set_test(False)
            toolchain = os.path.join(project_dir, 'cmake', 'toolchain-%s.cmake' % arch)
            if os.path.isfile(toolchain):
                self._opts.append('-DCMAKE_TOOLCHAIN_FILE=%s' % toolchain)
            else:
                logging.error("%s not exist, architectrue %s not support!" % (toolchain, arch))

    def set_verbose(self, verbose):
        """
        """
        if verbose:
            self._opts.append('-DCMAKE_VERBOSE_MAKEFILE=ON')

    def set_build_type(self, build_type):
        """
        """
        self._opts.append('-DCMAKE_BUILD_TYPE=%s' % build_type) 

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

def make_clean():
    """
    清除上次编译的结果
    """
    if not os.path.isdir(build_dir):
        return
    
    # 直接删除目录及其文件
    shutil.rmtree(build_dir)

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

def cmake():
    """
    编译
    cmake -> make
    """
    # 创建编译目录
    if os.path.isdir(build_dir) == False:
        os.makedirs(build_dir)

    os.chdir(build_dir)

    # cmake 建立 Makefile
    logging.info('exec : ' + ' '.join(x for x in cmake_options.get_opts()))
    proc = Popen(cmake_options.get_opts())
    proc.communicate()
    if proc.wait() != 0:
        logging.error( 'cmake fail.' )
        sys.exit(1)

    os.chdir(project_dir)

def make(args):
    # 创建编译目录
    if os.path.isdir(build_dir) == False:
        os.makedirs(build_dir)

    os.chdir(build_dir)
    make_cmd = get_make_cmd(args)

    logging.info('exec : ' + ' '.join(x for x in make_cmd))
    proc = Popen(make_cmd)
    proc.communicate()
    if proc.wait() != 0:
        logging.error( 'make fail.' )
        sys.exit(1)

    os.chdir(project_dir)


def get_test_cmd():
    """
    """
    if os.name == 'posix':
        return ['make', 'test']
    else:
        return ['mingw32-make', 'test']

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
    parser.add_argument('--nopackage', action='store_true', help = 'clean project.')
    parser.add_argument('-b', '--build', choices=['Debug', 'Release'], default='Release', help = 'build release or debug version.')
    parser.add_argument('-t', '--toolset', choices=['gcc', 'msvc'], default = 'gcc', help = 'specify the build tool set.')
    parser.add_argument('-a', '--arch', choices=['i686', 'x86_64', 'ia64', 'ppc64', 'mingw64'], default=platform.processor(), help = '32bit or 64bit version.')
    parser.add_argument('--gendoc', action='store_true', help = 'generate develop doc.')
    parser.add_argument('--test', action='store_false', help = 'run unittest after build.')
    parser.add_argument('--codecoverage', action='store_true', help = 'run unittest and code coverage after build.')
    parser.add_argument('--verbose', action='store_true', help = 'show gcc args.')

    args = parser.parse_args()

    logging.info('build with below options:')
    logging.info(args)

    build_dir = os.path.join(build_dir, args.arch)
    if args.clean:
        make_clean()
        exit(0)

    cmake_options.set_build_type(args.build)
    cmake_options.set_test(args.codecoverage or args.test)
    cmake_options.set_generater(args.toolset, args.arch)
    cmake_options.set_verbose(args.verbose)
    
    cmake()

    if not args.nopackage:
        make_package()
        sys.exit(0)
    else:
        make()

    if args.gendoc:
        make_doc()

    if args.codecoverage:
        make_code_coverage()
    elif args.test:
        make_test()


