#!/bin/bash

#locale
#export LC_ALL=C
#export LANG=C
export LC_COLLATE=ja_JP.utf8

#copy
dateline=$(wc -l date.csv|cut -f1 -d' ')
echo "N = 1"
#第1期データをコピー(半角to全角を噛ませる)
./kana_han2zen.gawk ./data/detail$(head -1 date.csv).csv > ./data/detail.csv
##

#処理
#n番目の日付のデータをdetail.csvに結合
func() {
#temp削除
rm ./data/*.tmp

#現在のメインデータフィールド数
fieldsize=$(head -1  ./data/detail.csv|sed -e 's/ //g' -e 's/　//g' -e 's/,/ /g'|wc -w)


#本日のデータ
todaydate=$(head -$1 date.csv|tail -1)
#データソートしてa.tmpへ
sort -k1,1 -t, ./data/detail.csv >./data/a.tmp
#todaydate分b.tmpへ(半角to全角を噛ませる)
./kana_han2zen.gawk ./data/detail$todaydate.csv |sort -k1,1 -t, >./data/b.tmp

#detailへtodaydate分を結合
join -11 -21 -t, ./data/a.tmp ./data/b.tmp >./data/join1.tmp
#cut -d, -f1,2,3-$fieldsize,$(expr $fieldsize + 2) ./data/join1.tmp > ./data/join2.tmp
#住所をすべて最新とする
gawk -F, 'BEGIN{OFS=","}{$2=$(NF-1);$(NF-1)=$NF;$NF="nono";print}' ./data/join1.tmp|gawk -F',nono' '{print $1}' >./data/join2.tmp
#matchしなかったもの(停止店舗)
#元ファイルのみ
join -11 -21 -t, -v1 ./data/a.tmp ./data/b.tmp >./data/detail_a.tmp

#停止店舗について、最新時給にNA代入
#※ fsize+1th col ( 最新データ )へNA挿入
cat ./data/detail_a.tmp | gawk -F, '{
	printf $0",NA\n";
}'>./data/da.tmp

#新規店舗
join -11 -21 -t, -v2 ./data/a.tmp ./data/b.tmp >./data/detail_b.tmp

#新規店について、募集前時給にNA代入
#(3rd col to fsize col)へNA ※ fsize+1th col = 最新データ
cat ./data/detail_b.tmp|gawk -F, -v fsize="$fieldsize" '{
		printf $1","$2",";
		ib=3;
		while( ib < fsize + 1 ){
				printf "NA,";
				ib++
		}
		printf $3"\n";
}' > ./data/db.tmp
#
#データ出力
cat ./data/join2.tmp>./data/detail.csv
#停止店舗データ出力
cat ./data/da.tmp>>./data/detail.csv
#新規店舗データ出力
cat ./data/db.tmp>>./data/detail.csv


#重複削除
uniq ./data/detail.csv > ./data/uni1.tmp
cp ./data/uni1.tmp  ./data/detail.csv
#半角スペースを置換
sed 's/&nbsp;//g' detail.csv > detail.csv
}

n=2
while [ $n -le $dateline ];
do
	echo "N = " $n
	func $n
	n=$(expr $n + 1)
done
echo "Done(｀・ω・´)"
#unset locale
unset LC_ALL LANG
