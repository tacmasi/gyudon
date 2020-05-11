#/bin/bash

today=$(tail -1 ./withaddress/sukiya/date.csv)
pastday=$(tail -2 ./withaddress/sukiya/date.csv|head -1)
#outputfile
outputfile="./gyudon_alltxt.txt"

#題名
echo "[牛丼短観][牛丼週報][時給観測]牛丼チェーン店アルバイト時給観測(牛丼短観)" $today > $outputfile

echo $today "現在、吉野家・松屋・すき家のアルバイト募集状況(日中、各店舗下限値。高校生時給・研修時給除く)は以下のとおりです。" >>$outputfile

############
ncol=$(head -1 all_gyudon.csv|awk -F, '{print NF}')
#配列 [吉野家、松屋、すき家、合計]
#求人数店舗数
totalq=(0 0 0 0)
#totalstorefunc(1,2)#1:storetype, #2:id:0:吉野家,1:松屋,2:すき家
totalstorefunc(){
	echo "var=" $1 $2 $ncol
	totalq[$2]=$(awk -F, '{if($1=='"$1"' && $"'$ncol'"!="NA") print NR}' all_gyudon.csv|wc -l)
}
totalstorefunc "\"吉野家\"" 0
totalstorefunc "\"松屋"\" 1
totalstorefunc "\"すき家"\" 2
echo "合計 吉野家 松屋 すき家"
totalq[3]=$(expr ${totalq[0]} + ${totalq[1]} + ${totalq[2]})
echo "totalq" ${totalq[*]}

#####
#時給上下
#配列 [吉野家、松屋、すき家、合計]
upq=(0 0 0 0)
downq=(0 0 0 0)
diffq=(0 0 0 0)
#updn(1,2)#1:storetype, #2:id:0:吉野家,1:松屋,2:すき家
updn(){
	echo "var=" $1 $2
	upq[$2]=$(awk -F, '{if($1=='"$1"') print NR}' gyudon_up.csv|wc -l)
	downq[$2]=$(awk -F, '{if($1=='"$1"') print NR}' gyudon_down.csv|wc -l)
	diffq[$2]=$(expr ${upq[$2]} - ${downq[$2]} )
}
updn "\"吉野家\"" 0
updn "\"松屋"\" 1
updn "\"すき家"\" 2
echo "吉野家 松屋 すき家"
echo "up" ${upq[*]}
echo "down" ${downq[*]}
echo "diff" ${diffq[*]}

#合計
upq[3]=$(expr ${upq[0]} + ${upq[1]} + ${upq[2]})
downq[3]=$(expr ${downq[0]} + ${downq[1]} + ${downq[2]})
diffq[3]=$(expr ${diffq[0]} + ${diffq[1]} + ${diffq[2]})

############
#求人数増減
#配列 [吉野家、松屋、すき家]
newq=(0 0 0 0)
stopq=(0 0 0 0)
netnewq=(0 0 0 0)
#newstopdn(1,2)#1:storetype, #2:id:0:吉野家,1:松屋,2:すき家
newstop(){
	echo "var=" $1 $2
	newq[$2]=$(awk -F, '{if($1=='"$1"') print NR}' gyudon_new.csv|wc -l)
	stopq[$2]=$(awk -F, '{if($1=='"$1"') print NR}' gyudon_stop.csv|wc -l)
	netnewq[$2]=$(expr ${newq[$2]} - ${stopq[$2]} )
}
newstop "\"吉野家\"" 0
newstop "\"松屋"\" 1
newstop "\"すき家"\" 2
echo "吉野家 松屋 すき家"
echo "new" ${newq[*]}
echo "stop" ${stopq[*]}
echo "netnew" ${netnewq[*]}

#合計
newq[3]=$(expr ${newq[0]} + ${newq[1]} + ${newq[2]})
stopq[3]=$(expr ${stopq[0]} + ${stopq[1]} + ${stopq[2]})
netnewq[3]=$(expr ${netnewq[0]} + ${netnewq[1]} + ${netnewq[2]})
######

#Storetype、求人数、上昇、下落、上昇-下落
#Storetype、求人数、新規求人、求人停止、新規-停止
echo "|*Storetype|*求人中店舗数[件]|*上昇件数[件]|*下落件数[件]|*上昇-下落[件]|*新規件数[件]|*停止件数[件]|*新規-停止[件]|" >>$outputfile
echo "|*吉野家|" ${totalq[0]} "|" ${upq[0]} "|" ${downq[0]} "|" ${diffq[0]} "|" ${newq[0]} "|" ${stopq[0]} "|" ${netnewq[0]} "|" >>$outputfile
echo "|*松屋|" ${totalq[1]} "|" ${upq[1]} "|" ${downq[1]} "|" ${diffq[1]} "|" ${newq[1]} "|" ${stopq[1]} "|" ${netnewq[1]} "|" >>$outputfile
echo "|*すき家|" ${totalq[2]} "|" ${upq[2]} "|" ${downq[2]} "|" ${diffq[2]} "|" ${newq[2]} "|" ${stopq[2]} "|" ${netnewq[2]} "|" >>$outputfile
echo "|*合計|" ${totalq[3]} "|" ${upq[3]} "|" ${downq[3]} "|" ${diffq[3]} "|" ${newq[3]} "|" ${stopq[3]} "|" ${netnewq[3]} "|" >>$outputfile

######
echo "<hr>">>$outputfile
if [ -s ./gyudon_up.csv  ]; then
	nl=$(awk 'END{print NR}' gyudon_up.csv)
	echo $today "において、前回集計時(" $pastday  ")以降、日中求人時給が上昇した店舗は下記" $nl "件です。" >>$outputfile
	echo "|*Storetype|*都道府県|*上昇店舗名|*" $pastday  "時給[円]|*" $today "時給[円]|*対先週差[円]"  >>$outputfile
	#求人停止店舗
	cut -d, -f1,2,3,5,6,7 gyudon_up.csv |sort -t, -k1,2 |sed 's/,/|/g'|awk '{print "|" $0 "|"}' >>$outputfile
else
	echo $today "において、" $pastday "以降日中求人時給が上昇した店舗はありません。" >>$outputfile
fi

echo "<hr>">>$outputfile
if [ -s ./gyudon_down.csv  ]; then
	nl=$(awk 'END{print NR}' gyudon_down.csv)
	echo $today "において、前回集計時(" $pastday ")以降、日中求人時給が下落した店舗は下記" $nl "件です。" >>$outputfile
	echo "|*Storetype|*都道府県|*下落店舗名|*" $pastday  "時給[円]|*" $today "時給[円]|*対先週差[円]"  >>$outputfile
	#求人停止店舗
	cut -d, -f1,2,3,5,6,7 gyudon_down.csv |sort -t, -k1,2 |sed 's/,/|/g'|awk '{print "|" $0 "|"}' >>$outputfile
else
	echo $today "において、前回集計時(" $pastday ")以降日中求人時給が下落した店舗はありません。" >>$outputfile
fi

echo "<hr>">>$outputfile

if [ -s ./gyudon_new.csv  ]; then
	nl=$(awk 'END{print NR}' gyudon_new.csv)
	echo $today "において、前回集計時(" $pastday ")以降日中求人を開始した店舗は下記" $nl "件です。" >>$outputfile
	echo "|*Storetype|*都道府県|*新規求人店舗名|*時給|" >>$outputfile
	#求人停止店舗
	cut -d, -f1,2,3,6 gyudon_new.csv |sort -t, -k1,2 |sed 's/,/|/g'|awk '{print "|" $0 "|"}' >>$outputfile
else
	echo $today "において、前回集計時(" $pastday ")以降日中求人を開始した店舗はありません。" >>$outputfile
fi

echo "<hr>">>$outputfile
if [ -s ./gyudon_stop.csv  ]; then
	nl=$(awk 'END{print NR}' gyudon_stop.csv)
	echo $today "において、前回集計時(" $pastday ")以降日中求人を停止した店舗は下記" $nl "件です。" >>$outputfile
	echo "|*Storetype|*都道府県|*求人停止店舗名|" >>$outputfile
	#求人停止店舗
	cut -d, -f1,2,3 gyudon_stop.csv |sort -t, -k1,2 |sed 's/,/|/g'|awk '{print "|" $0 "|"}' >>$outputfile
else
	echo $today "において、前回集計時(" $pastday ")以降日中求人を停止した店舗はありません。" >>$outputfile
fi
echo "<hr>">>$outputfile
#########対前月比
echo "<br>">>$outputfile
echo "<hr>">>$outputfile
echo "時系列での各店舗時給上昇件数(対4週前比)は下記の通りです。">>$outputfile
#echo "|*Date|*吉野家[件]|*松屋[件]|*すき家[件]|上昇店舗計[件]|">>$outputfile
echo "|*Date|*吉↑|*松↑|*す↑|*上昇計|*吉↓|*松↓|*す↓|*下落計|">>$outputfile
for i in $(seq 0 4 240)
do
#cat all_gyudon_colnameon.csv|awk -F, -v l="$i" 'NR==1{print} NR!=1 && $(NF-l)!="NA" && $(NF-l-4)!="NA" && $(NF-l)>$(NF-l-4){print}'|awk -F, -v l="$i" 'BEGIN{y=0;m=0;s=0}NR==1{d=$(NF-l)}$1=="吉野家"{y++} $1=="松屋"{m++} $1=="すき家"{s++} END{print "|"d"|" y"|" m"|"  s"|" NR"|" }' >>$outputfile
up_num=$(cat all_gyudon_colnameon.csv|awk -F, -v l="$i" 'NR==1{print} NR!=1 && $(NF-l)!="NA" && $(NF-l-4)!="NA" && $(NF-l)>$(NF-l-4){print}'|awk -F, -v l="$i" 'BEGIN{y=0;m=0;s=0}NR==1{d=$(NF-l)}$1=="吉野家"{y++} $1=="松屋"{m++} $1=="すき家"{s++} END{print "|"d"|" y"|" m"|"  s"|" y+m+s"|" }')
down_num=$(cat all_gyudon_colnameon.csv|awk -F, -v l="$i" 'NR==1{print} NR!=1 && $(NF-l)!="NA" && $(NF-l-4)!="NA" && $(NF-l)<$(NF-l-4){print}'|awk -F, -v l="$i" 'BEGIN{y=0;m=0;s=0}NR==1{d=$(NF-l)}$1=="吉野家"{y++} $1=="松屋"{m++} $1=="すき家"{s++} END{print y"|" m"|"  s"|" y+m+s"|" }')
echo $up_num$down_num >> $outputfile
done
echo "<hr>">>$outputfile
#########対前月比
#取得元変更20161022
#echo -e "データ元：\n -松屋:「バイトル(時間：「昼」)http://www.matswork.biz/op182246/alist/tst2/ \n -吉野家：「バイトル(検索ワード:\"-\")」http://www.baitoru.com/aspjlist/?st=2&ASP_MGR_NO=4147&ASP_VALUE=&ASP_KEYWORD=-&page=1 \n -すき家：「すき家公式サイト(検索ワード:\"-\")」http://jobs.sukiya.jp/shops?k=-&page=1 \n" >>$outputfile
echo -e "データ元：\n -松屋:「バイトル(時間：「昼」)http://www.matswork.biz/op182246/alist/tst2/ \n -吉野家：「バイトル(検索ワード:\"-\")」 http://www.baitoru.com/op71872/alist/tst2_btp1/wrd-/ \n -すき家：「すき家公式サイト(検索ワード:\"-\")」http://jobs.sukiya.jp/shops?k=-&page=1 \n" >>$outputfile
echo -e "データは下記リンク先の通りです。 \n https://raw.githubusercontent.com/tacmasi/gyudon/master/all_gyudon_colnameon.csv \n" >>$outputfile

