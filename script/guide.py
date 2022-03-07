#! /usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# guide
#
# 2022/02/16 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
from importlib import import_module
from argparse  import ArgumentParser

import sys
import os
import re
import subprocess
import time

#====================================
#
# base
#
# it supports do/run/run1 for using external command
#
#====================================
class base:
    __top = os.path.abspath(__file__ + "/../../");
    __cwd = os.getcwd()

    #--------------------
    # top
    # cwd
    #--------------------
    def top(self): return base.__top
    def cwd(self): return base.__cwd

    #--------------------
    # tolist()
    #--------------------
    def tolist(self, string):
        if (len(string) > 0):
            return string.split('\n');

        return [];

    #--------------------
    # run()
    #
    # run command and get result as plane text
    #--------------------
    def run(self, command):

        # Ughhhh
        # I don't like python external command !!
        # (ノ `Д´)ノ  go away !!
        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE)

        return result.stdout.decode("utf-8").rstrip("\n")

    #--------------------
    # runl()
    #
    # run command and get result as list
    #--------------------
    def runl(self, command):

        # call run() and exchange result as array
        #
        # "xxxxxxx
        #  yyyyyyy
        #  zzzzzzz"
        # ->
        # ["xxxxxxx",
        #  "yyyyyyy",
        #  "zzzzzzz"]
        return self.tolist(self.run(command));

    #--------------------
    # system()
    #--------------------
    def system(self, command):
        return subprocess.run(command, shell=True).returncode;

    #--------------------
    # input
    #--------------------
    def input(self, msg):
        try:
            return input(msg)
        except KeyboardInterrupt:
            sys.exit(1)

    #--------------------
    # select("message", ["hoge", "pkuku"])
    #--------------------
    def select(self, text, list):
        max = len(list)
        if (max == 1):
            return list[0]

        for i in range(max):
            text += "\n  {}) ".format(i + 1) + list[i]

        while 1:
            self.msg(text)
            try:
                ret = int(self.input("select number (1-{}): ".format(max)))
            except KeyboardInterrupt:
                sys.exit(1)
            except ValueError:
                ret = -1
            if (ret <= 0 or ret > max):
                self.error("select number in 1 - {}".format(max), quit=0)
            else:
                return list[ret - 1]

    #--------------------
    # ask_yn
    #--------------------
    def ask_yn(self, quit=None, default=None):
        while 1:
            msg = " <default {}>: ".format(default) if (default) else ": "
            ret = self.input("OK? (y/n)" + msg)
            if (default and ret == ""):
                ret = default
            if (ret == "y"):
                return 1
            if (ret == "n"):
                if (quit):
                    sys.exit(1)
                else:
                    return 0

    #--------------------
    # error
    #--------------------
    def error(self, text, quit=1):
        print()
        print("********* [error] *************")
        for txt in text.split("\n"):
            print("* {}".format(txt))
        print("*******************************")
        if (quit):
            sys.exit(1)
        else:
            self.ask_yn()

    #--------------------
    # msg
    #--------------------
    def msg(self, text):
        l = 0
        for txt in text.split("\n"):
            t = len(txt)
            if (t > l): l = t

        print()
        print("+-", end="")
        for i in range(l):
            print("-", end="")
        print("-+")

        for txt in text.split("\n"):
            print("| %-{}s |".format(l) % txt)

        print("+-", end="")
        for i in range(l):
            print("-", end="")
        print("-+")

#====================================
#
# guide
#
#====================================
class guide(base):
    #--------------------
    # __init__
    #--------------------
    def __init__(self, board=None, ver=None, debug=None):
        self.__board		= board
        self.__version		= ver
        self.__debug		= debug

    #--------------------
    # build_dir
    #--------------------
    def full_path(self,   full): return "{}/".format(self.top()) if full else ""
    def build_dir(self,   full=False): return "{}yocto/{}-{}".format(self.full_path(full), self.__board, self.__version)
    def package_dir(self, full=False): return "{}package/{}-{}".format(self.full_path(full), self.__board, self.__version)
    def my_conf(self,     full=False): return "{}/my_conf".format(self.build_dir(full))
    def build_sh(self,    full=False): return "{}/build.sh".format(self.build_dir(full))

    #--------------------
    # checkout
    #--------------------
    def checkout(self, option = ""):
        return self.system("{}/script/checkout.sh {} {} {}".format(
            self.top(), self.__board, self.__version, option))

    #--------------------
    # build
    #--------------------
    def build(self, option, image, meta, suffix = ""):
        return self.system("{}/script/build.sh {} {} {} {} {} {}".format(
            self.top(), option, self.__board, self.__version, image, meta, suffix))

    #--------------------
    # ask_package_dir_setup
    #--------------------
    def ask_package_dir_setup(self):
        while True:
            if (os.path.exists(self.package_dir(True))):
                break
            for how_to in self.package_how_to_step:
                self.msg(how_to)
                self.ask_yn(True)

    #--------------------
    # build_script_check
    # build_script_setup
    #--------------------
    def build_script_check(self):
        if (os.path.exists(self.build_sh(True))):
            self.msg("You already have build script of {} for Yocto {}\n".format(self.__board, self.__version) +\
                     "(${{renesas-yocto-maker}}/{})\n\n".format(self.build_sh()) +\
                     "You can build it with prevous settings by this script.\n"\
                     "But, do you want to re-setup it ?")
            self.ask_yn(True)

            # remove old build.sh
            os.remove(self.build_sh(True))

    def build_script_setup(self, image, meta_dir, conf_file, configs, msg = None):
        #
        # checkout target version of yocto to copy conf_file.
        # checkout.sh can use -r option, but it is not needed so far.
        #
        self.system("{}/script/checkout.sh {}".format(self.top(), self.__version))

        # copy meta file to my_conf and specify DL_DIR on it.
        # see
        #	script/build.sh
        self.system("mkdir -p {}".format(self.build_dir()))
        num = self.run("grep -n \"^#DL_DIR\" {}/yocto/{}/{} | cut -d \":\" -f 1".format(self.top(), meta_dir, conf_file))
        self.system("cat {}/yocto/{}/{} | sed {}a\"DL_DIR = \\\"\\${{TOPDIR}}/../downloads\\\"\" > {}".format(
            self.top(), meta_dir, conf_file, num, self.my_conf(True)))

        with open(self.build_sh(True), mode="w") as f:
            f.write("#! /bin/bash\n")
            f.write("#\n")
            f.write("# It will use below config file.\n")
            f.write("# You need to setup it.\n")
            f.write("#\n")
            f.write("#	{}\n".format(self.my_conf()))
            f.write("#\n")
            f.write("TOP=`readlink -f \"$0\" | xargs dirname | xargs dirname | xargs dirname`\n")
            f.write("BOARD={}\n".format(self.__board))
            f.write("VER={}\n".format(self.__version))
            f.write("IMAGE={}\n".format(image))
            f.write("META_DIR={}\n".format(meta_dir))
            f.write(configs)
            f.write(". ${TOP}/script/build.sh\n")
        os.chmod(self.build_sh(True), 0o755)

        if (msg):
            self.msg("You can/need to edit config file by yourself.\n"\
                     "Unfortunately, this script can't do it for you.\n"\
                     "Please edit below file (it will be used as local.conf).\n\n" +\
                     "   ${{renesas-yocto-maker}}/{}\n\n".format(self.my_conf()) + msg)
            self.ask_yn()

        self.msg("The work dir is [{}]\n".format(self.build_dir()) +\
                 "and it created build script as below.\n\n" +\
                 "  ${{renesas-yocto-maker}}/{}\n\n".format(self.build_sh()) +\
                 "You can whenever run it by yourself.\n"\
                 "Do you want to run it now ?")
        if (self.ask_yn()):
            self.system(self.build_sh(True))

    #--------------------
    # ask_tar_option
    #--------------------
    def ask_tar_option(self):
        ret = ""
        con = ""
        self.msg("Do you want to create bin.tar.bz2 from it ?\n"
                 "(Archive file for Yocto Binary files)")
        if (self.ask_yn(default="n")):
            ret += "FLAG_BIN=1\n"
            con += "\noption:       create bin.tar.bz2"

        self.msg("Do you want to create src.tar.bz2 from it ?\n"
                 "(Archive file for Yocto Source files)")
        if (self.ask_yn(default="n")):
                 ret += "FLAG_SRC=1\n"
                 con += "\noption:       create src.tar.bz2"

        return ret, con

    #--------------------
    # start
    #--------------------
    def start(self, debug=None):
        if (not os.path.exists("{}/yocto".format(self.top()))):
            self.msg("Did you install necessary tools ?\n"
                     "You can find and run script\n"
                     "   > ${renesas-yocto-maker}/script/tool_install.${os}")
            self.ask_yn(True)

        #
        # Board select
        #
        list = self.runl("ls {}/script/board/ | grep \"\.py$\" | sed -e \"s/\.py$//g\"".format(self.top()))
        board = self.select("Board Select", list)

        #
        # Version select
        #
        list = self.runl("grep -lw {} script/version/* | sed -e \"s|script/version/||g\" | sort -Vr".format(board, self.top()))
        version = self.select("Version Select", list)

        #
        # Board Setup
        #
        board = import_module("board.{}".format(board)).guide(board, version, debug)
        board.setup()

#====================================
#
# As command
#
#====================================
if __name__=='__main__':
    argp = ArgumentParser()
    argp.add_argument('-d', '--debug', action='store_true')
    debug = argp.parse_args().debug

    guide().start(debug)
