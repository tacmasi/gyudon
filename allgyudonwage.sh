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


#######
#データクリア
rm ./gyudon_up.csv  ./gyudon_down.csv ./gyudon_new.csv  ./gyudon_stop.csv 
touch ./gyudon_up.csv  ./gyudon_down.csv ./gyudon_new.csv  ./gyudon_stop.csv 

today=$(tail -1 ./withaddress/sukiya/date.csv)
pastday=$(tail -2 ./withaddress/sukiya/date.csv|head -1)
##all_gyudon.csv: storetype, prefecure, name, address, wage, date
#上昇取得()
gawk --assign today=$today --assign pastday=$pastday -F, 'BEGIN{upcnt=0; dwncnt=0; begincnt=0; stopcnt=0; name="dum"; wage=0; date=0 } 
{ if(name!=$3 && date==pastday && date>$6){print dat >> "gyudon_stop.csv"} #stop
	if($6==today){ #今週データ
		if($3!=name || ($3==name && date<pastday)){print >> "gyudon_new.csv"} #先週データがない場合:new
		if($3==name && date==pastday){ #同店舗かつ先週データがある場合
			if($5>wage){print $0 "," wage "," ($5)-wage  >> "gyudon_up.csv"} #up
			if($5<wage){print $0 "," wage "," ($5)-wage >> "gyudon_down.csv"} #down 
		}
	}
	name=$3; wage=$5; date=$6; dat=$0  #データ格納
}
' all_gyudon.csv
echo "時給上昇店舗を ./gyudon_up.csv に保存しました"
#下落取得()
echo "時給下落店舗を ./gyudon_down.csv に保存しました"

#新規求人店舗取得()
echo "新規求人開始店舗を ./gyudon_new.csv に保存しました"
#求人停止取得()
echo "求人停止店舗を ./gyudon_stop.csv に保存しました"
