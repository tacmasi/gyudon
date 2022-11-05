#!/bin/bash
rm *.tmp *.html

todaydate=$(date +%Y%m%d)
touch today_t.tmp
getwage(){
#時給get
nowwage1=$(grep -A3 "時給" nowdetailpage.html | grep \<em\> | sed -e 's/給/Y/' -e 's/円/Y/' -e 's/,//'|awk -F'Y' 'NR==1{print $2 } ')
echo $nowwage1
#店舗名get
nowname1=$(grep -A3 "勤務先" nowdetailpage.html |head -2|tail -1|sed -e 's/>/</'|awk -F\< 'NR==1{print $3}'|awk -F[ '{print $1}' |sed 's/　/ /g')
echo $nowname1
#勤務地get
nowplace1=$(grep -A4  "住所" nowdetailpage.html|grep li|sed -e 's/>/</'|awk -F\< 'NR==1{print $3}'|sed -e 's/,/、/g')
echo $nowplace1

echo $nowname1,$nowplace1,$nowwage1>> today_t.tmp
}

getpage(){
#	wget -q http://www.baitoru.com/aspjlist/?st=2\&ASP_MGR_NO=4147\&ASP_VALUE=\&ASP_KEYWORD=-\&page=$1 -O nowdown.html
#変更20161022〜
	#wget -q http://www.baitoru.com/op71872/alist/tst2_btp1/wrd-/page$1/ -O nowdown.html
	if [ $1 -eq 1 ];then	
	wget -q  http://www.yoshinoya.com/baito/op71872/alist/tst2_btp1/wrd-/ -O nowdown.html
	else
		wget -q  http://www.yoshinoya.com/baito/op71872/alist/tst2_btp1/wrd-/page$1/ -O nowdown.html
	fi
}
pagecheck(){
		#詳細記載URL
	#-20170831
	#dwncnt=$(grep -c "内容を詳しく" nowdown.html)
	#dwncnt=$(grep -c job_mgr_no nowdown.html)
	#20180407
	dwncnt=$(cat nowdown.html |grep h3|grep href|grep -c job )
}

getdetailpage(){
	#詳細ページをget
	wget -q $1 -O nowdetailpage.html
	echo $1
}

getdetailuri(){
	#詳細ページuriをget
	#detail_a=$(grep "内容を詳しく" nowdown.html|cut -d\" -f2 | head -$1 |tail -1)
	#echo "http://www.baitoru.com$detail_a" >> detailuri.tmp
	#20161022変更
	#20180831
	#echo "$detail_a" >> detailuri.tmp

	#grep job_mgr_no nowdown.html|awk -F\" '{print "http://www.yoshinoya.com/baito/op71872/job"$2"/"}' >> detailuri.tmp
	#20180407
	cat nowdown.html |grep h3|grep href|grep job|awk -F\" '{print $2}' >> detailuri.tmp
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
	#while [ $dwncnt -ne 0 ]
	#do
		getdetailuri $dwncnt
	#	dwncnt=$(expr $dwncnt - 1)
	#done
	echo "cnt=$cnt"
	cnt=$(expr $cnt + 1)
	rm nowdown.html
done
cnt=1
#行数
linec=$(cat detailuri.tmp | wc -l)
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

#重複削除(同一店舗名では賃金最低の求人を残す)
cat today_t.tmp |sort -t, -k 1,1 -k 3n |awk -F'[,]' '!a[$1]++ {print $0}' > ./data/detail$todaydate.csv
echo $todaydate >>date.csv
echo "data出力了"
#rm *.tmp *.html
