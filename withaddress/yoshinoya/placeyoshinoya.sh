#!/bin/bash
rm *.tmp *.html

todaydate=$(date +%Y%m%d)
getwage(){
#時給get
#-20161022
#grep -A3 "給与" nowdetailpage.html|grep "時給"|head -1|sed 's/ //g'|sed 's/　//g'|sed 's/,//g'|sed 's/給/Y/g'|sed 's/円/Y/g'|cut -dY -f2 >>wage.tmp
grep -A3 "給与" nowdetailpage.html|grep "時給"|grep "em"|sed 's/ //g'|sed 's/　//g'|sed 's/,//g'|sed 's/給/Y/g'|sed 's/円/Y/g'|cut -dY -f2 >>wage.tmp

#店舗名get
        grep  "勤務先：" nowdetailpage.html|sed 's/：/</g'|cut -d\< -f2|head -1 >>name.tmp
#勤務地get
        grep  "勤務先：" nowdetailpage.html|sed 's/>/</g'|cut -d\< -f3|head -1|sed 's/\t//g'|sed 's/,//g'|sed 's/　//g' >>place.tmp
}

getpage(){
#	wget -q http://www.baitoru.com/aspjlist/?st=2\&ASP_MGR_NO=4147\&ASP_VALUE=\&ASP_KEYWORD=-\&page=$1 -O nowdown.html
#変更20161022〜
	#wget -q http://www.baitoru.com/op71872/alist/tst2_btp1/wrd-/page$1/ -O nowdown.html
	if [ $1 -eq 1 ];then	
		wget -q  http://www.baitoru.com/op71872/alist/tst2_btp1/wrd-/ -O nowdown.html
	else
		wget -q  http://www.baitoru.com/op71872/alist/tst2_btp1/wrd-/page$1/ -O nowdown.html
	fi
}
pagecheck(){
	dwncnt=$(grep -c "内容を詳しく" nowdown.html)
}

getdetailpage(){
	#詳細ページをget
	wget -q $1 -O nowdetailpage.html
}

getdetailuri(){
	#詳細ページuriをget
	detail_a=$(grep "内容を詳しく" nowdown.html|cut -d\" -f2 | head -$1 |tail -1)
	#echo "http://www.baitoru.com$detail_a" >> detailuri.tmp
	#20161022変更
	echo "$detail_a" >> detailuri.tmp
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
		getdetailuri $dwncnt
		dwncnt=$(expr $dwncnt - 1)
	done
	echo "cnt=$cnt"
	cnt=$(expr $cnt + 1)
	rm nowdown.html
done
cnt=1
#行数
linec=$(wc -l detailuri.tmp |cut -f1 -d' ')
while [ $cnt -le $linec ]
do
	nowdwuri=$(head -$cnt detailuri.tmp | tail -1)
	getdetailpage $nowdwuri
	getwage
	cnt=$(expr $cnt + 1)
	rm nowdetailpage.html
	echo "cnt=$cnt"
done
#	cnt=$(expr $cnt + 1)

paste -d, name.tmp place.tmp wage.tmp > today_t.tmp
#重複削除(同一店舗名では賃金最低の求人を残す)
cat today_t.tmp |sort -t, -k 1,1 -k 3n |awk -F'[,]' '!a[$1]++ {print $0}' > ./data/detail$todaydate.csv
echo $todaydate >>date.csv
echo "data出力了"
#rm *.tmp *.html
