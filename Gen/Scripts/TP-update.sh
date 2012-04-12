#!/bin/sh

#  TP-update.sh
#  Gen
#  Скрипт для автоматической переупаковки атласов текстур при изменении исходных изображений (for Texture Packer)
#  Created by Andrey Korikov on 12.04.12.
#  Copyright (c) 2012 Atom Games. All rights reserved.

TP=/usr/local/bin/TexturePacker
if [ "${ACTION}" = "clean" ]
then
# remove sheets - please add a matching expression here
rm -f ${PROJECT_DIR}/Images/*.pvr.ccz
rm -f ${PROJECT_DIR}/Images/*.plist
else
# create all assets from tps files

${TP} *.tps
fi
exit 0