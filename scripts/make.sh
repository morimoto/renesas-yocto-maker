#! /bin/bash
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# make
#
# 2021/11/11 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/scripts/param.sh

[ x$NAME_BIN != x ] && NAME_BIN="yocto-${VER}-${TARGET}-${DATE}-bin"
[ x$NAME_SRC != x ] && NAME_SRC="yocto-${VER}-${TARGET}-${DATE}-src"
[ x$NAME_ENV != x ] && NAME_ENV="yocto-${VER}-${TARGET}-${DATE}-env"

[ x${NAME_BIN} != x -a -f ${NAME_BIN}.tar.bz2 ] && echo "${NAME_BIN}.tar.bz2 already exist" && exit 1
[ x${NAME_SRC} != x -a -f ${NAME_SRC}.tar.bz2 ] && echo "${NAME_SRC}.tar.bz2 already exist" && exit 1
[ x${NAME_ENV} != x -a -f ${NAME_ENV}.tar.bz2 ] && echo "${NAME_ENV}.tar.bz2 already exist" && exit 1

CONF_PATH=meta-rcar-gen3/docs/sample/conf/${TARGET}/poky-gcc/bsp
ARCH_MODE=patched # original  patched  configured

conf_path_check() {

	if [ ! -d  meta-renesas/${CONF_PATH} ]; then
		echo "no ${CONF_PATH} at renesas"
		exit
	fi

	grep -w "INHERIT" meta-renesas/${CONF_PATH}/local.conf > /dev/null
	if [ $? = 0 ]; then
		echo "unexpected: renesas local.conf has INHERIT!"
		exit
	fi

	grep -w "ARCHIVER_MODE" meta-renesas/${CONF_PATH}/local.conf > /dev/null
	if [ $? = 0 ]; then
		echo "unexpected: renesas local.conf has ARCHIVER_MODE!"
		exit
	fi
}

target_build() {
	(
		. poky/oe-init-build-env

		grep ${VER}   ${TOP}/build/renesas-version 2>/dev/null
		[ $? != 0 ] && echo "removing previous build/tmp" && rm -fr build/tmp
		echo ${VER} > ${TOP}/build/renesas-version

		cp ../meta-renesas/${CONF_PATH}/*.conf ./conf/

		if [ x${NAME_SRC} != x ]; then
			echo						>> ./conf/local.conf
			echo "# added by renesas-yocto-maker"		>> ./conf/local.conf
			echo "INHERIT += \"archiver\""			>> ./conf/local.conf
			echo "ARCHIVER_MODE[src] = \"$ARCH_MODE\""	>> ./conf/local.conf
		fi

		bitbake core-image-minimal
	)
	[ x$? != x0 ] && exit
}

run_option() {

	if [ x${NAME_BIN} != x ]; then
		echo create ${NAME_BIN}
		ln -s build/tmp/deploy/images/${TARGET} ${NAME_BIN}
		tar -jchf ${NAME_BIN}.tar.bz2 ${NAME_BIN}
		rm ${NAME_BIN}
	fi

	if [ x${NAME_SRC} != x ]; then
		echo create ${NAME_SRC}

		if [ x${ARCH_MODE} = xoriginal ]; then
			ln -s build/tmp/deploy/sources	${NAME_SRC}
		else
			mkdir ${NAME_SRC}
			SRC=`find build/tmp/deploy/sources/ | grep ${ARCH_MODE}`
			cp ${SRC} ${NAME_SRC}
		fi

		tar -jchf ${NAME_SRC}.tar.bz2 ${NAME_SRC}
		rm -fr ${NAME_SRC}
	fi

	if [ x${NAME_ENV} != x ]; then
		echo create ${NAME_ENV}
		mkdir -p ${NAME_ENV}/build
		ln -s ../../build/conf		${NAME_ENV}/build
		ln -s ../../build/downloads	${NAME_ENV}/build
		ln -s ../meta-openembedded	${NAME_ENV}
		ln -s ../meta-renesas		${NAME_ENV}
		ln -s ../poky			${NAME_ENV}
		tar -jchf ${NAME_ENV}.tar.bz2	${NAME_ENV}
		rm -fr ${NAME_ENV}
	fi
}

conf_path_check
target_build
run_option
