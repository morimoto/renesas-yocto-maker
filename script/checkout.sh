#! /bin/bash
#===============================
#
# checkout
#
# 2022/03/03 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`

#
# parse option
#
while getopts r OPT
do
	case $OPT in
		r) FLAG_META_RCAR=1;;
	esac
done
shift $(expr $OPTIND - 1)

VER=$1

#
# load version settings
#
. ${TOP}/script/version/${VER}


#
# GIT info
#
LIST_DIR=(poky
	  meta-openembedded
	  meta-renesas)
LIST_GIT=(git://git.yoctoproject.org/poky
	  git://git.openembedded.org/meta-openembedded
	  https://github.com/renesas-rcar/meta-renesas.git)
LIST_CMT=(${POKY}
	  ${OPEN}
	  ${RENE})

# for Kingfisher
if [ x${FLAG_META_RCAR} = x1 ]; then
	LIST_DIR+=(meta-rcar)
	LIST_GIT+=(https://github.com/CogentEmbedded/meta-rcar.git)
	LIST_CMT+=(${RCAR})
fi

#
# create yocot and goto there
#
mkdir -p ${TOP}/yocto
cd ${TOP}/yocto

#
# clone git if not exist
#
for ((i = 0; i < ${#LIST_DIR[@]}; i++)) {
	[ ! -d ./${LIST_DIR[$i]} ] && git clone ${LIST_GIT[$i]} &
}
wait

#
# git checkout
#
for ((i = 0; i < ${#LIST_DIR[@]}; i++)) {
	(
		cd ./${LIST_DIR[$i]}
		git checkout ${LIST_CMT[$i]}
	)
}
