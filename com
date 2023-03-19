#!/bin/bash
echo https://www.linjiangyu.com | hakrawler  | grep linjiangyu.com | grep -v 'collect' | grep '^https' | uniq | grep -vE 'css|js|json'  | grep post | sort | uniq
