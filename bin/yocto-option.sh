#! /bin/sh
#===============================
#
# yocto-option
#
# 2021/06/11 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
DATE=`date +%Y%m%d`
while getopts bse OPT
do
  case $OPT in
     b) NAME_BIN=1;;
     s) NAME_SRC=1;;
     e) NAME_ENV=1;;
     *) exit 1;;
  esac
done
shift $(expr $OPTIND - 1)
TARGET=$1

# remove all parameter
shift 1

[ x$NAME_BIN != x ] && NAME_BIN="yocto-${VER}-${TARGET}-${DATE}-bin"
[ x$NAME_SRC != x ] && NAME_SRC="yocto-${VER}-${TARGET}-${DATE}-src"
[ x$NAME_ENV != x ] && NAME_ENV="yocto-${VER}-${TARGET}-${DATE}-env"
