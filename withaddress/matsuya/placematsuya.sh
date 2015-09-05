#!/bin/bash
rm *.tmp *.html

todaydate=$(date +%Y%m%d)
getwage(){
#時給一覧get
	grep "\">時給" nowdetailpage.html|sed 's/給 /z/g'|sed 's/円/z/g'|cut -dz -f2|sed 's/,//g' >>wage.tmp
#店舗一覧get

	grep "h4" nowdetailpage.html|grep "span02"|head -1|sed 's/>/</g'|cut -d'<' -f5 >>name.tmp
#勤務地get
	grep -A2 "勤務地" nowdetailpage.html|head -3|tail -1|cut -d'<' -f1|sed 's/\s//g'|sed 's/,//g' >>place.tmp
}

getpage(){

	wget -q http://www.matswork.biz/op182246/alist/tst2/page$1/ -O nowdown.html
	if [ $1 -eq 1 ];then
	wget -q http://www.matswork.biz/op182246/alist/tst2/ -O nowdown.html
	fi
}
pagecheck(){
	dwncnt=$(grep -c "内容を詳しく" nowdown.html)
}

getdetailpage(){
	#詳細ページをget
	detail_a=$(grep "内容を詳しく" nowdown.html|cut -d\" -f2 | head -$1 |tail -1)
	wget -q $detail_a -O nowdetailpage.html
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
paste -d, name.tmp place.tmp wage.tmp > ./data/detail$todaydate.csv
echo $todaydate >>date.csv

#rm *.tmp *.html
