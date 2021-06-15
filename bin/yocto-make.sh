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
ARCH_MODE=patched # original  patched  configured

[ x${NAME_BIN} != x -a -f ${NAME_BIN}.tar.bz2 ] && echo "${NAME_BIN}.tar.bz2 already exist" && exit
[ x${NAME_SRC} != x -a -f ${NAME_SRC}.tar.bz2 ] && echo "${NAME_SRC}.tar.bz2 already exist" && exit
[ x${NAME_ENV} != x -a -f ${NAME_ENV}.tar.bz2 ] && echo "${NAME_ENV}.tar.bz2 already exist" && exit

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

(
	. poky/oe-init-build-env

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

if [ x${NAME_BIN} != x ]; then
	echo create ${NAME_BIN}
	ln -s build/tmp/deploy/images/${TARGET} ${NAME_BIN}
	tar -jchf ${NAME_BIN}.tar.bz2 ${NAME_BIN}
	rm ${NAME_BIN}
fi

if [ x${NAME_SRC} != x ]; then
	echo create ${NAME_SRC}

	if [ x$ARCH_MODE = xoriginal ]; then
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
