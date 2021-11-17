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

COMMIT_POKY=`        get_param "${VER}_P"`
COMMIT_OPENEMBEDDED=`get_param "${VER}_O"`
COMMIT_RENESAS=`     get_param "${VER}_R"`
COMMIT_RCAR=`        get_param "${VER}_C"`

target_clone() {
	[ ! -d poky ]			&& git clone git://git.yoctoproject.org/poky &
	[ ! -d meta-openembedded ]	&& git clone git://git.openembedded.org/meta-openembedded &
	[ ! -d meta-renesas ]		&& git clone https://github.com/renesas-rcar/meta-renesas.git &
	[ ! -d meta-rcar ]		&& git clone https://github.com/CogentEmbedded/meta-rcar.git &

	# Wait for all clone operations
	wait
}

target_checkout() {
	# ignore if no commit
	[ x${2} = x ] && return

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
target_checkout meta-rcar		${COMMIT_RCAR}
