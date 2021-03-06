#! /bin/bash
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# build
#
# 2022/02/18 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================

#
# This file will be loaded from each Yocto work dir.
# It should have ${TOP}.
#

OUT_DIR=${BOARD}-${VER}
NAME="yocto-${VER}-${BOARD}${SUFFIX}-"`date +%Y%m%d`

#
# checkout
#
OPTION=""
if [ x${FLAG_META_RCAR} = x1 ]; then
	OPTION="-r"
fi

${TOP}/script/checkout.sh ${OPTION} ${VER}

cd ${TOP}/yocto

#
# create output dir and conf
# and copy META_DIR conf
#
mkdir -p ${OUT_DIR}/conf
cp -fr ${META_DIR}/*.conf ${OUT_DIR}/conf/

# my_conf is edited by user
# see
#	guide.build_script_setup()
cp ${OUT_DIR}/my_conf ${OUT_DIR}/conf/local.conf

#
# Start Poky
#
. ./poky/oe-init-build-env ${OUT_DIR}

# Now PWD = ${OUT_DIR}

[ x${FLAG_SRC}	!= x   ] && cat ../../script/src_conf >> ./conf/local.conf
[ x${LAYER}	!= x   ] && bitbake-layers add-layer ../${LAYER}
if [ x${DIR_FOR_COPY} != x ]; then
	(
		if [ ! -d ${TOP}/package/${OUT_DIR} ]; then
			echo "no package/${OUT_DIR}"
			exit 1
		fi

		cd ${TOP}/yocto/${DIR_FOR_COPY}
		${TOP}/yocto/${COPY_SCRIPT} -f ${TOP}/package/${OUT_DIR}
	)
fi

bitbake ${IMAGE}
[ x$? != x0 ] && exit

if [ x${FLAG_BIN} != x ]; then
	NAME_BIN="${NAME}-bin"
	echo "create yocto/${OUT_DIR}/${NAME_BIN}.tar.bz2"

	ln -s ./tmp/deploy/images/${BOARD} ${NAME_BIN}
	tar -jchf ${NAME_BIN}.tar.bz2 ${NAME_BIN}
	rm ${NAME_BIN}
fi

if [ x${FLAG_SRC} != x ]; then
	NAME_SRC="${NAME}-src"
	echo "create yocto/${OUT_DIR}/${NAME_SRC}.tar.bz2"

	# see script/src_conf :: ARCHIVER_MODE
	# It is assuming "patched"

	mkdir ${NAME_SRC}
	SRC=`find ./tmp/deploy/sources/ | grep patched`
	cp ${SRC} ${NAME_SRC}
	tar -jchf ${NAME_SRC}.tar.bz2 ${NAME_SRC}
	rm -fr ${NAME_SRC}
fi
