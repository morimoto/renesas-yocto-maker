#! /usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# draak
#
# 2022/02/24 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
import guide

class guide(guide.guide):
    #--------------------
    # __setup
    #--------------------
    def __setup(self):
        #
        # default options
        #
        confirm		= "board:        {}\n".format(self.__board) +\
                          "version:      {}".format(self.__version)
        configs		= ""

        # add other options
        o = self.ask_tar_option()
        configs += o[0]
        confirm += o[1]

        self.msg(confirm)
        return ("core-image-minimal",
                "meta-renesas/meta-rcar-gen3/docs/sample/conf/draak/poky-gcc/bsp",
                "local.conf",
                configs)

    #--------------------
    # setup
    #-------------------
    def setup(self):
        self.build_script_check()

        while True:
            o = self.__setup()
            if (self.ask_yn()):
                break

        self.build_script_setup(o[0], o[1], o[2], o[3])
