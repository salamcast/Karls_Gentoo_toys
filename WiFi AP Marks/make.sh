#!/bin/bash
SH=make-hit-lists.sh
MAC=00:23:4d:4e:e2:7d
wifi=wlan0
mon=mon0

XML_MARKS="schema.xml"
XSLT="wepcrack.xsl"

xsltproc --output ${SH} \
 --stringparam if "${wifi}" \
 --stringparam mac "${MAC}" \
 --stringparam mon "${mon}" ${XSLT} ${XML_MARKS}
chmod +x ${SH}
./${SH}

echo "Made WEP Hit list! check the folders for your six step program"
echo " open http://www.aircrack-ng.org/doku.php?id=simple_wep_crack for more help"
ls -d */