#! /bin/bash
#===============================
#
# yocto-make
#
# 2021/06/10 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
COMMIT_POKY=$P
COMMIT_OPENEMBEDDED=$O
COMMIT_RENESAS=$R
CONF_PATH=$B

[ x${NAME_BIN} != x -a -f ${NAME_BIN}.tar.bz2 ] && echo "${NAME_BIN}.tar.bz2 already exist" && exit
[ x${NAME_SRC} != x -a -f ${NAME_SRC}.tar.bz2 ] && echo "${NAME_SRC}.tar.bz2 already exist" && exit

if [ x${COMMIT_POKY}		= x	-o\
     x${COMMIT_OPENEMBEDDED}	= x	-o\
     x${COMMIT_RENESAS}		= x	-o\
     x${CONF_PATH}		= x ]; then
	echo "parameter error"
	exit
fi

[ ! -d poky ]			&& git clone git://git.yoctoproject.org/poky
[ ! -d meta-openembedded ]	&& git clone git://git.openembedded.org/meta-openembedded
[ ! -d meta-renesas ]		&& git clone git://github.com/renesas-rcar/meta-renesas.git

checkout_target() {
	(
		cd ${1}
		git remote update --prune
		git checkout ${2}
		if [ $? != 0 ]; then
			echo "${1} checkout error"
			exit
		fi
	)
}

checkout_target poky			${COMMIT_POKY}
checkout_target meta-openembedded	${COMMIT_OPENEMBEDDED}
checkout_target meta-renesas		${COMMIT_RENESAS}

if [ ! -d  meta-renesas/${CONF_PATH} ]; then
	echo "no ${CONF_PATH} at renesas"
	exit
fi

(
	. poky/oe-init-build-env

	cp ../meta-renesas/${CONF_PATH}/*.conf ./conf/

	bitbake core-image-minimal
)
[ x$? != x0 ] && exit

if [ x${NAME_BIN} != x ]; then
	echo create ${NAME_BIN}
	ln -s build/tmp/deploy/images/${TARGET} ${NAME_BIN}
	tar -jchf ${NAME_BIN}.tar.bz2 ${NAME_BIN}
	rm ${NAME_BIN}
fi

if [ x${NAME_SRC} != x ]; then
	echo create ${NAME_SRC}
	mkdir -p ${NAME_SRC}/build
	ln -s ../../build/conf		${NAME_SRC}/build
	ln -s ../../build/downloads	${NAME_SRC}/build
	ln -s ../meta-openembedded	${NAME_SRC}
	ln -s ../meta-renesas		${NAME_SRC}
	ln -s ../poky			${NAME_SRC}

	tar -jchf ${NAME_SRC}.tar.bz2 ${NAME_SRC}
	rm -fr ${NAME_SRC}
fi
