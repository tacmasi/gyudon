#!/bin/bash
rm *.tmp *.html

todaydate=$(date +%Y%m%d)
touch ./data/detail$todaydate.csv
getwage(){
#時給一覧get
#	grep "時給&nbsp;" nowdetailpage.html|sed -e 's/&nbsp;/>/g'|sed -e 's/円/>/g'|cut -d'>' -f3 |sed 's/,//g'>>wage.tmp
nowwage1=$(grep "時給&nbsp" nowdetailpage.html|sed -e 's/;/円/g' -e 's/,//g'|awk -F'円' 'NR==1{print $2}')
#店舗一覧get
nowname1=$(grep -A1 "募集店舗" nowdetailpage.html|tail -1|sed -e 's/>/</g'|cut -d'<' -f3)
#勤務地get
nowplace1=$(grep -A2 "勤務地" nowdetailpage.html|tail -1|sed -e 's/\s//g'|sed -e 's/,/_/g'|sed 's/&nbsp;//g')
echo $nowname1,$nowplace1,$nowwage1>> ./data/detail$todaydate.csv
}

getpage(){
	wget --no-check-certificate -q https://jobs.sukiya.jp/shops?k=-\&page=$1 -O nowdown.html
}
pagecheck(){
	dwncnt=$(grep -c "詳細" nowdown.html)
}

getdetailpage(){
	#詳細ページをget
	detail_a=$(grep "詳細" nowdown.html|cut -d\" -f2 | head -$1 |tail -1|cut -d'?' -f1)
	wget --no-check-certificate -q https://jobs.sukiya.jp/$detail_a -O nowdetailpage.html
}

dwncnt=1
cnt=1
while [ $cnt -ne 0 ]
do
	getpage $cnt
	pagecheck $cnt
	echo "pagecheck=$dwncnt"
	if [ $dwncnt -eq 0 ];then
		break
	fi
	while [ $dwncnt -ne 0 ]
	do
		getdetailpage $dwncnt
		getwage
		dwncnt=$(expr $dwncnt - 1)
		rm nowdetailpage.html
	done
	echo "cnt=$cnt"
	cnt=$(expr $cnt + 1)
	rm nowdown.html
done
echo $todaydate >>date.csv

#rm *.tmp *.html
