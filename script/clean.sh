#! /bin/bash
#===============================
#
# clean
#
# 2022/03/07 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
#
# check
#
ls | grep -w "build.sh" > /dev/null
[ $? != 0 ] && exit

ls | grep -w "clean.sh" > /dev/null
[ $? != 0 ] && exit

ls | grep -w "my_conf" > /dev/null
[ $? != 0 ] && exit

ls | grep -v build.sh | grep -v clean.sh | grep -v my_conf | xargs rm -fr
