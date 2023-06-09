#!/usr/bin/env bash
echoerr() { echo "$@" 1>&2; }
while getopts 'o:' OPT; do
  case $OPT in
    o) O_PATH="$OPTARG";;
    *) echoerr "Unknown error while processing options";;
  esac
done
curl -sS https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt | \
  base64 -d | sort -u | sed '/^$\|@@/d'| sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' | \
  sed '/apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /qq\.com/d' | \
  sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$/d' | grep '^[0-9a-zA-Z\.-]\+$' | \
  grep '\.' | sed 's#^\.\+##' | sort -u > /tmp/temp_gfwlist1

curl -sS https://raw.githubusercontent.com/hq450/fancyss/master/rules/gfwlist.conf | \
  sed 's/ipset=\/\.//g; s/\/gfwlist//g; /^server/d' > /tmp/temp_gfwlist2

curl -sS https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt > /tmp/temp_gfwlist3

cat /tmp/temp_gfwlist1 /tmp/temp_gfwlist2 /tmp/temp_gfwlist3 | sort -u | sed 's/^\.*//g' > /tmp/temp_gfwlist
cat /tmp/temp_gfwlist | sed 's/^/\./g' > /tmp/gfwlist.conf
sed -i 's/^/nameserver \//' /tmp/gfwlist.conf
sed -i 's/$/\/gfw/' /tmp/gfwlist.conf
if [ -z $O_PATH ];then
  cat /tmp/gfwlist.conf 
else
  cat /tmp/gfwlist.conf > ${O_PATH}/gfwlist.conf
fi
rm -f /tmp/temp_gfwlist1 /tmp/temp_gfwlist2 /tmp/temp_gfwlist3 /tmp/temp_gfwlist /tmp/gfwlist.conf
