#/bin/bash

##################データ生成start
##storetype, prefecture, storename, address, wage1,wage2,...wageN
gawk -F, '{print "吉野家," substr($2,1,3) "," $0 }' ./withaddress/yoshinoya/data/detail.csv > yoshinoya.tmp
gawk -F, '{print "松屋," substr($2,1,3) "," $0 }' ./withaddress/matsuya/data/detail.csv > matsuya.tmp
gawk -F, '{print "すき家," substr($2,1,3) "," $0 }' ./withaddress/sukiya/data/detail.csv > sukiya.tmp

##データ出力
cat yoshinoya.tmp >all_gyudon.csv
cat matsuya.tmp >>all_gyudon.csv
cat sukiya.tmp >>all_gyudon.csv
####無効データomit
cat all_gyudon.csv | sed -e 's/時給//g' -e 's/〜//g' > tmp
mv tmp all_gyudon.csv
rm tmp
####
echo "all_gyudon.csv に時給データを保存しました"

##colname
hh1=$(awk -v ORS="," 'BEGIN{print "storetype,prefecture,storename,address"} {print $0}' ./withaddress/sukiya/date.csv )
echo ${hh1/%?/} >all_gyudon_colnameon.csv
cat all_gyudon.csv >> all_gyudon_colnameon.csv
echo "all_gyudon_colnameon.csv に列名入りデータを保存しました"

#######
#列番号取得
lastcol=$(head -1 all_gyudon.csv|awk -F, '{print NF}')
pastcol=$(expr $lastcol - 1)
past4weekcol=$(expr $lastcol - 4)

echo "lastcol=" $lastcol
echo "pastcol=" $pastcol
echo "past4weekcol=" $past4weekcol

#上昇取得(+1〜+650yen)
awk -F, '{print $1 "," $2 "," $3 "," $4 "," $'"$pastcol"' "," $'"$lastcol"' "," $'"$lastcol"' - $'" $pastcol"'}' all_gyudon.csv | awk -F, '{if($7>0 && $7 < 650) print $0} ' > gyudon_up.csv
echo "時給上昇店舗を ./gyudon_up.csv に保存しました"

#下落取得(-650〜-1yen)
awk -F, '{print $1 "," $2 "," $3 "," $4 "," $'"$pastcol"' "," $'"$lastcol"' "," $'"$lastcol"' - $'" $pastcol"'}' all_gyudon.csv | awk -F, '{if($1<7 && $7 > -650) print $0} ' > gyudon_down.csv
echo "時給下落店舗を ./gyudon_down.csv に保存しました"

#新規求人店舗取得(+650yen〜)
awk -F, '{print $1 "," $2 "," $3 "," $4 "," $'"$pastcol"' "," $'"$lastcol"' "," $'"$lastcol"' - $'" $pastcol"'}' all_gyudon.csv | awk -F, '{if($7 > 650) print $0} ' > gyudon_new.csv
echo "新規求人開始店舗を ./gyudon_new.csv に保存しました"
#求人停止取得(〜-650yen)
awk -F, '{print $1 "," $2 "," $3 "," $4 "," $'"$pastcol"' "," $'"$lastcol"' "," $'"$lastcol"' - $'" $pastcol"'}' all_gyudon.csv | awk -F, '{if($7 < -650) print $0} ' > gyudon_stop.csv
echo "求人停止店舗を ./gyudon_stop.csv に保存しました"
