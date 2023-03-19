#!/bin/bash
find ./ -type d -exec sed -ri 's#https://cdn1.tianli0.top/gh/linjiangyu2/halo/img#/https://cdn.staticaly.com/gh/linjiangyu2/halo@master/img/#g' {}/* \;
