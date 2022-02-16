#! /bin/bash
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# param.sh
#
# 2021/11/11 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
error() {
	echo
	echo "***********************************"
	echo $@
	echo "***********************************"
	echo
}

get_param() {
	grep "^${1}" ${TOP}/scripts/version | cut -d = -f 2
}

while getopts bseam OPT
do
	case $OPT in
		b) NAME_BIN=1;;
		s) NAME_SRC=1;;
		e) NAME_ENV=1;;
		a) FLAG_ADAS=1;;
		m) FLAG_MMP=1;;
		*) ${TOP}/scripts/help.sh && exit 1;;
	esac
done
shift $(expr $OPTIND - 1)

VER=$1
TARGET=$2

# remove all parameters
shift 2

DATE=`date +%Y%m%d`

# param check
if [ x${VER} = x -o x${TARGET} = x ]; then
	${TOP}/scripts/help.sh
	exit 1
fi

# VAR check
grep ^${VER} ${TOP}/scripts/version 1>/dev/null 2>&1
if [ $? != 0 ]; then
	error "version \"${VER}\" is not supported"
	${TOP}/scripts/help.sh
	exit 1
fi

# TARGET check
LIST=`get_param "${VER}_L"`
echo ${LIST} | grep -w ${TARGET} 1>/dev/null 2>&1
if [ $? != 0 ]; then
	error "\"${TARGET}\" is not supported board"
	echo
	echo "supported boards for ${VER} are..."
	echo " ${LIST}"
	echo
	exit 1
fi

# ADAS check
if [[ x${FLAG_ADAS} = x1 && ! ${TARGET} =~ "h3ulcb" && ! ${TARGET} =~ "m3ulcb" ]]; then
	error "${TARGET} can't use -a (ADAS) option "
	exit 1
fi

# MMP check
if [ x${FLAG_MMP} = x1 ]; then

	ZIP=`get_param "${VER}_M"`
	if [ x"${ZIP}" = x ]; then
		error "${VER} doesn't support -m (MMP) option"
		exit 1
	fi

	if [[ ! ${TARGET} =~ "h3ulcb" && \
	      ! ${TARGET} =~ "m3ulcb" ]]; then
		error "H3/M3 only supports -m (MMP) option"
		exit 1
	fi

	ZIP=`echo "${ZIP}" | sed -e "s/ /\n/g" | sed -e "s|^|\tpackage/${VER}/|g"`
	ls ${ZIP} > /dev/null 2>&1
	if [[ x${FLAG_MMP} = x1 && ! $? = 0 ]]; then
		error "You don't have required files for -m (MMP) option"
		echo
		echo "The graphics and multimedia acceleration packages for"
		echo "the R-Car Gen3 board BSP can be downloaded from"
		echo
		echo "	https://www.renesas.com/us/en/application/automotive/r-car-h3-m3-documents-software"
		echo
		echo "You need to have packages in"
		echo
		echo "${ZIP}"
		exit 1
	fi
fi
