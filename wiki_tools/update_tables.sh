#!/bin/bash

file=$1

cat ${file} | sed -E "s/\s-(.*)$/<ul><li>\1<\/li><\/ul>/" | sed -E "s/-([a-zA-Z0-9])*/|/" | sed -E "s/([✅🔜] )(.*$)/\2 | \1|/" | sed -E "s/([^|])$/\1 | ➖ |/"
