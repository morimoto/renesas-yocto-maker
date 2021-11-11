#! /bin/bash
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# target_checkout
#
# 2021/11/11 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/scripts/param.sh

COMMIT_POKY=`        grep "^${VER}_P" ${TOP}/scripts/version | sed -e "s/^${VER}_P=//g"`
COMMIT_OPENEMBEDDED=`grep "^${VER}_O" ${TOP}/scripts/version | sed -e "s/^${VER}_O=//g"`
COMMIT_RENESAS=`     grep "^${VER}_R" ${TOP}/scripts/version | sed -e "s/^${VER}_R=//g"`

target_clone() {
	[ ! -d poky ]			&& git clone git://git.yoctoproject.org/poky &
	[ ! -d meta-openembedded ]	&& git clone git://git.openembedded.org/meta-openembedded &
	[ ! -d meta-renesas ]		&& git clone git://github.com/renesas-rcar/meta-renesas.git &

	# Wait for all clone operations
	wait
}

target_checkout() {
	(
		cd ${1}
		git remote update --prune
		git checkout ${2}
		if [ $? != 0 ]; then
			error "${1} checkout error"
			exit 1
		fi
	)
}

target_clone
target_checkout poky			${COMMIT_POKY}
target_checkout meta-openembedded	${COMMIT_OPENEMBEDDED}
target_checkout meta-renesas		${COMMIT_RENESAS}
