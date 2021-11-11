#! /bin/bash
# SPDX-License-Identifier: Apache-2.0
#===============================
#
# help
#
# 2021/04/14 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`

README=${TOP}/README

LINE1=`grep -n -w "^* How to use ?" ${README} | awk -F ":" '{print $1}'`
LINE1=`expr ${LINE1} + 2`

LINE2=`tail -n +${LINE1} ${README} | egrep -n "^----" | head -n 1 | awk -F ":" '{print $1}'`
LINE2=`expr ${LINE1} + ${LINE2} - 2`

sed -n ${LINE1},${LINE2}p ${README} | less -F
