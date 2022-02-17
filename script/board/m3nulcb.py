#! /usr/bin/env python3
#===============================
#
# m3nulcb
#
# 2022/02/17 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
import guide
import board.h3ulcb

#
# Almost all are same as H3 ULCB.
# use M3N original settings here.
#
class guide(board.h3ulcb.guide):

    #--------------------
    # __init__
    #--------------------
    def __init__(self, board=None, ver=None, debug=None):
        # FIXME!!  How to call super's super class ??
        super().__init__(board, ver, debug)

        self.package_how_to_step = [
            # Step0
            "You need to prepare package by yourself,\n"\
            "and this command can't confirm it.\n"\
            "This script shows the procedure.",

            # Step1
            "[STEP1]\n"\
            "Contact to [Renesas Sales team] or\n"\
            "[Renesas appointed store Sales team]\n"\
            "and get necessary packages.",

            # Step3
            "[STEP2]\n"\
            "Create package folder and copy these.\n\n"\
            "  > mkdir -p         ${{renesas-yocto-maker}}/{0}\n"\
            "  > cp <zip_package> ${{renesas-yocto-maker}}/{0}\n"\
            "                                                  ^^^^^^^^^^^^\n"\
            "  > ls ${{renesas-yocto-maker}}/{0}  (sample)\n"\
            "  RTM8RC7795ZG300Q10JPL3E_xxx.zip     RTM8RC0000ZAE1LQ00JPL3E_xxx.zip  RTM8RC0000ZMX0LQ00JPL3E_xxx.zip"
            "  RTM8RC7796ZG300Q10JPL3E_xxx.zip     RTM8RC0000ZMD0LQ00JPL3E_xxx.zip  RTM8RC0000ZND1LQ00JPL3E_xxx.zip"\
            "  LICENSE.TXT                         RTM8RC0000ZMD1LQ00JPL3E_xxx.zip  RTM8RC0000ZNE1LQ00JPL3E_xxx.zip"\
            "  RCH3G001L5101ZDO_xxx.zip            RTM8RC0000ZME0LQ00JPL3E_xxx.zip  RTM8RC0000ZNX0LQ00JPL3E_xxx.zip"\
            "  RCM3G001L5101ZDO_xxx.zip            RTM8RC0000ZME1LQ00JPL3E_xxx.zip  readme.txt"\
            "  RTM8RC0000ZAD1LQ00JPL3E_xxx.zip     RTM8RC0000ZMX0DQ00JFL3E_xxx.zip".format(self.package_dir()),
            ]
