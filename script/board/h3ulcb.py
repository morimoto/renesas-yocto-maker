#! /usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# h3ulcb
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
            "You need to prepare package by yourself,\n"\
            "and this command can't confirm it.\n"\
            "This script shows the procedure after <y>.",

            # Step1
            "[STEP1]\n"\
            "You need to download package from elinux page.\n"\
            "https://elinux.org/R-Car/Boards/Yocto-Gen3/v{}#Required_packages\n".format(self.__version) +\
            "                                           ^^^^^^^\n"\
            "Download below files.\n\n"\
            "R-Car_Gen3_Series_Evaluation_Software_Package_for_Linux-xxx.zip\n"\
            "R-Car_Gen3_Series_Evaluation_Software_Package_of_Linux_Drivers-xxx.zip",

            # Step3
            "[STEP2]\n"\
            "Create package folder and unzip these.\n\n"\
            "  > mkdir -p ${{renesas-yocto-maker}}/{0}\n"\
            "  > cd       ${{renesas-yocto-maker}}/{0}\n"\
            "                                            ^^^^^^^^^^^^\n"\
            "  > unzip -o ${{download}}/R-Car_Gen3_Series_Evaluation_Software_Package_for_Linux-xxx.zip\n"\
            "  > unzip -o ${{download}}/R-Car_Gen3_Series_Evaluation_Software_Package_of_Linux_Drivers-xxx.zip\n"\
            "\n"\
            "  > ls ${{renesas-yocto-maker}}/{0} (sample)\n"\
            "  INFRTM8RC7795ZG300Q10JPL3E_xxx.zip  RTM8RC0000ZAE1LQ00JPL3E_xxx.zip  RTM8RC0000ZMX0LQ00JPL3E_xxx.zip\n"\
            "  INFRTM8RC7796ZG300Q10JPL3E_xxx.zip  RTM8RC0000ZMD0LQ00JPL3E_xxx.zip  RTM8RC0000ZND1LQ00JPL3E_xxx.zip\n"\
            "  LICENSE.TXT                         RTM8RC0000ZMD1LQ00JPL3E_xxx.zip  RTM8RC0000ZNE1LQ00JPL3E_xxx.zip\n"\
            "  RCH3G001L5101ZDO_xxx.zip            RTM8RC0000ZME0LQ00JPL3E_xxx.zip  RTM8RC0000ZNX0LQ00JPL3E_xxx.zip\n"\
            "  RCM3G001L5101ZDO_xxx.zip            RTM8RC0000ZME1LQ00JPL3E_xxx.zip  readme.txt\n"\
            "  RTM8RC0000ZAD1LQ00JPL3E_xxx.zip     RTM8RC0000ZMX0DQ00JFL3E_xxx.zip".format(self.package_dir()),
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
        my_conf_msg	= ""
        meta_dir	= "meta-renesas/meta-rcar-gen3/docs/sample/conf/{}/poky-gcc".format(self.__board)
        meta		= "bsp"
        package_list	= ["BSP",
                           "BSP + 3D Graphics",
                           "BSP + 3D Graphics + MultiMedia"]
        name_suffix	= ""

        #
        # H3/M3 can use Kingfisher.
        # It requires GFX/MMP package
        #
        self.msg("{} can use with Kingfisher\n"
                 "Do you want Yocto for it ?\n"
                 "(Needs 3D Graphics + MultiMedia package)".format(self.__board))

        package = None
        if (self.ask_yn()):
            #
            # Kingfisher
            #
            configs		+= "LAYER=meta-rcar/meta-rcar-gen3-adas\n"\
                                   "FLAG_META_RCAR=1\n"
            package		 = package_list[2]
            name_suffix		 = "-kingfisher"
            confirm		+= "\noption:       use Kingfisher board"

        #
        # ask package
        #
        if (not package):
            package = self.select("Select target.\n", package_list)

        #
        # Indicate How to get package,
        # and ask to create it if needed.
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
                           "COPY_SCRIPT=meta-renesas/meta-rcar-gen3/docs/sample/copyscript/copy_evaproprietary_softwares.sh\n"\
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
            my_conf_msg		=  "It already have default multimedia feature settings,\n"\
                                   "but you can add extra optional features if you want.\n"\
                                   "Please find and edit [DISTRO_FEATURES_append]\n"\
                                   "on above setting file."
            confirm		+= "\noption:       use MultiMedia package"

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
