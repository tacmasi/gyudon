#!/bin/bash

#locale
#export LC_ALL=C
#export LANG=C
export LC_COLLATE=ja_JP.utf8

#copy
dateline=$(wc -l date.csv|cut -f1 -d' ')
#cp ./data/detail$(head -1 date.csv).csv ./data/detail.csv
#スペース半角化
#cat ./data/detail$(head -1 date.csv).csv|sed 's/　/ /g' > ./data/detail.csv
#全角→半角
cat ./data/detail$(head -1 date.csv).csv|sed 's/　/ /g'|sed 'y/ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ１２３４５６７８９０/ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/' -e 's/R//g'> ./data/detail.csv
##

#処理
#n番目の日付のデータをdetail.csvに結合
func() {
#temp削除
echo 'remove tmp'
rm ./data/*.tmp

#メインデータフィールド数
#fieldsize=$(head -1  ./data/detail.csv|sed 's/ //g'|sed 's/　//g'|sed 's/,/ /g'|wc -w)
fieldsize=$(head -1  ./data/detail.csv|sed 's/ //g'|sed 's/　//g'|sed 's/,/ /g'|awk 'NR==1{print NF}')

echo 'fieldsize=' $fieldsize

#本日のデータ
todaydate=$(head -$1 date.csv|tail -1)
echo $todaydate
#データソート
echo "sort"
sort -k 1,1 -t, ./data/detail.csv >./data/a.tmp
#&スペース半角化
#sort -k 1,1 -t, ./data/detail$todaydate.csv >./data/b.tmp
#cat ./data/detail$todaydate.csv|sed 's/　/ /g'|sort -k 1,1 -t, >./data/b.tmp
echo "trans"
cat ./data/detail$todaydate.csv|sed 's/　/ /g'|sed 'y/ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ１２３４５６７８９０/ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/' -e 's/R//g'|sort -k 1,1 -t, >./data/b.tmp

echo "trans done"
#結合
echo 'join'
join -11 -21 -t, ./data/a.tmp ./data/b.tmp >./data/join1.tmp
cut -d, -f1,2,3-$fieldsize,$(expr $fieldsize + 2) ./data/join1.tmp > ./data/join2.tmp
#matchしなかったもの
#元ファイルのみ
join -11 -21 -t, -v1 ./data/a.tmp ./data/b.tmp >./data/detail_a.tmp
er1f=$(wc -l  ./data/detail_a.tmp|cut -d' ' -f1 )

echo "欠損データ処理"
while [ $er1f -ne 0 ]
do
	echo $(tail -$er1f ./data/detail_a.tmp|head -1)",NA" >>./data/da.tmp
	er1f=$(expr $er1f - 1)
done
#新規店舗
join -11 -21 -t, -v2 ./data/a.tmp ./data/b.tmp >./data/detail_b.tmp
er2f=$(wc -l  ./data/detail_b.tmp|cut -d' ' -f1 )

echo "欠損データ処理2"
while [ $er2f -ne 0 ]
do
	tmpb_w=$(tail -$er2f ./data/detail_b.tmp|head -1|cut -d, -f3)
	tmpb=$(tail -$er2f ./data/detail_b.tmp|head -1|cut -d, -f1,2)
	ib=2
	while [ $ib -lt $fieldsize ]
	do
		tmpb=$(echo $tmpb",NA")
		ib=$(expr $ib + 1)
	done
	echo $tmpb","$tmpb_w>>./data/db.tmp
	er2f=$(expr $er2f - 1)
done

cat ./data/join2.tmp>./data/detail.csv
cat ./data/da.tmp>>./data/detail.csv
cat ./data/db.tmp>>./data/detail.csv

echo $1

#重複削除
uniq ./data/detail.csv > ./data/uni1.tmp
cp ./data/uni1.tmp  ./data/detail.csv
#半角スペースを置換
sed 's/&nbsp;//g' detail.csv > detail.csv
}
n=2
while [ $n -le $dateline ];
do
	func $n
	n=$(expr $n + 1)
done
echo "Done(｀・ω・´)"

#unset locale
unset LC_ALL LANG
