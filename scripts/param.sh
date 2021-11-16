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

while getopts bse OPT
do
	case $OPT in
		b) NAME_BIN=1;;
		s) NAME_SRC=1;;
		e) NAME_ENV=1;;
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
