#!/bin/bash
#locale
#export LC_ALL=C
#export LANG=C
export LC_COLLATE=ja_JP.utf8

#savefile
savefile=detail.csv
#店種
store=松屋

#copy
dateline=$(wc -l date.csv|cut -f1 -d' ')
#echo "N = 1"
##

#処理
#n番目の日付のデータをdetail.csvに結合
func() {
#temp削除

#本日のデータ
todaydate=$(head -$1 date.csv|tail -1)
#todaydate分追加(カナは半角to全角, スペースは全角to半角を噛ませる-> 接頭'FC'削除)
#./kana_han2zen.gawk ./data/detail$todaydate.csv| sed -e 's/　/ /g' -e 's/FC//g' -e "s/^/$store,/" -e "s/$/,$todaydate/">> ./data/$savefile
./kana_han2zen.gawk ./data/detail$todaydate.csv| sed -e 's/　/ /g' -e 's/FC//g' -e "s/$/,$todaydate/">> ./data/$savefile

}

n=1
rm data/$savefile #初期化
while [ $n -le $dateline ];
do
	echo "N = " $n
	func $n
	n=$(expr $n + 1)
done

#sort 店名でソート→同じ店名は日付順にソート
sort -t, -k 1,1 -k4n  ./data/$savefile > ./data/a.tmp
cat ./data/a.tmp > ./data/$savefile
rm ./data/*.tmp
echo "Done(｀・ω・´)"
#unset locale
unset LC_ALL LANG
