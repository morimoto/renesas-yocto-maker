#! /usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# salvator-x
#
# 2022/02/17 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
import guide

class guide(guide.guide):
    #--------------------
    # __init__
    #--------------------
    def __init__(self, board=None, ver=None, debug=None):
        super().__init__(board, ver, debug)

        self.package_how_to_step = [
            # Step0
            "[STEP0]\n"\
            "You need to prepare necessary package (3D Graphics / MultiMedia)\n"\
            "by yourself, unfortunately this command can't help you.\n"\
            "It will indicate how to prepare package for you.\n"\
            "  [STEP1] How to get package.\n"\
            "  [STEP2] How to set up package.",

            # Step1
            "[STEP1] How to get package.\n\n"\
            "Contact to [Renesas Sales team] or\n"\
            "[Renesas appointed store Sales team]\n"\
            "and get necessary packages.",

            # Step2
            "[STEP2] How to set up package\n\n"\
            "Open other terminal, and run below\n\n"\
            "Create package folder and copy these.\n\n"\
            "  > mkdir -p         ${{renesas-yocto-maker}}/{0}\n"\
            "  > cp <zip_package> ${{renesas-yocto-maker}}/{0}\n"\
            "                                                    ^^^^^^^^^^^^\n"\
            "  > ls ${{renesas-yocto-maker}}/{0}  (sample)\n"\
            "  RCH3G001L5101ZDO_xxx.zip            RTM8RC0000ZMX0LQ00JPL3E_xxx.zip  RTM8RC0000ZNX0LQ00JPL3E_xxx.zip\n"\
            "  RCM3G001L5101ZDO_xxx.zip            RTM8RC0000ZMD0LQ00JPL3E_xxx.zip  RTM8RC0000ZND1LQ00JPL3E_xxx.zip\n"\
            "  RTM8RC7796ZG300Q10JPL3E_xxx.zip     RTM8RC0000ZMD1LQ00JPL3E_xxx.zip  RTM8RC0000ZNE1LQ00JPL3E_xxx.zip\n"\
            "  RTM8RC7795ZG300Q10JPL3E_xxx.zip     RTM8RC0000ZME0LQ00JPL3E_xxx.zip\n"\
            "  RTM8RC0000ZAD1LQ00JPL3E_xxx.zip     RTM8RC0000ZME1LQ00JPL3E_xxx.zip\n"\
            "  RTM8RC0000ZAE1LQ00JPL3E_xxx.zip     RTM8RC0000ZMX0DQ00JFL3E_xxx.zip".format(self.package_dir()),
        ]

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
        image		= "core-image-minimal"
        my_conf		= "local.conf"
        meta_dir	= "meta-renesas/meta-rcar-gen3/docs/sample/conf/{}/poky-gcc".format(self.__board)
        meta		= "bsp"
        package_list	= ["BSP",
                           "BSP + 3D Graphics",
                           "BSP + 3D Graphics + MultiMedia"]
        name_suffix	= ""

        # share with ebisu
        my_conf_msg	= ""
        if (self.__board == "salvator-x"):
            my_conf_msg = "You need to select SoC family.\n"\
                           "Please find and edit [SOC_FAMILY]"

        #
        # ask package
        #
        package = self.select("You can choose some packages.\n", package_list)

        #
        # Indicate How to get if user use package
        #
        if (not package == package_list[0]):
            self.ask_package_dir_setup()

        #
        # GFX is selected
        #	for [GFX only] or [GFX+MMP])
        #
        if (not package == package_list[0]):
            meta	 = "gfx-only"
            my_conf	 = "local-wayland.conf"
            configs	+= "DIR_FOR_COPY=meta-renesas\n"\
                           "COPY_SCRIPT=meta-renesas/meta-rcar-gen3/docs/sample/copyscript/copy_proprietary_softwares.sh\n"\
                           "DIR_PACKAGE={}\n".format(self.package_dir())
            image	 = "core-image-weston"
            name_suffix	+= "-gfx"
            confirm	+= "\noption:       use 3D Graphics package"

        #
        # MMP is selected
        #
        if (package == package_list[2]):
            meta		=  "mmp"
            name_suffix		+= "+mmp"
            confirm		+= "\noption:       use MultiMedia package"

            # share with ebisu
            if (len(my_conf_msg) > 0):
                my_conf_msg += "\n\n"

            my_conf_msg		+= "It already have default multimedia feature settings,\n"\
                                   "but you can add extra optional features if you want.\n"\
                                   "Please find and edit [DISTRO_FEATURES_append]\n"\
                                   "on above setting file."

        # add other options
        o = self.ask_tar_option()
        configs += "SUFFIX={}\n".format(name_suffix) +\
                   o[0]
        confirm += o[1]

        self.msg(confirm)
        return (image,
                "{}/{}".format(meta_dir, meta),
                my_conf,
                configs,
                my_conf_msg)

    #--------------------
    # setup
    #-------------------
    def setup(self):
        self.build_script_check()

        while True:
            o = self.__setup()
            if (self.ask_yn()):
                break

        self.build_script_setup(o[0], o[1], o[2], o[3], o[4])
