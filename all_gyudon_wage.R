#outputfile
outputfile<-"./gyudon_alltxt.txt"

##################データ生成start
matsuya<-read.csv("./withaddress/matsuya/data/detail.csv",header=F)
yoshinoya<-read.csv("./withaddress/yoshinoya/data/detail.csv",header=F)
sukiya<-read.csv("./withaddress/sukiya/data/detail.csv",header=F)


matsuya<-cbind(matsuya,"松屋",substring(matsuya[,2],1,3))
yoshinoya<-cbind(yoshinoya,"吉野家",substring(yoshinoya[,2],1,3))
sukiya<-cbind(sukiya,"すき家",substring(sukiya[,2],1,3))

datedate<-t(read.csv("./withaddress/matsuya/date.csv",header=F))
gyudon_names<-c("Storename","Address",datedate,"Storetype","Prefecture")
names(matsuya)<-gyudon_names
names(yoshinoya)<-gyudon_names
names(sukiya)<-gyudon_names

gyudon<-rbind(matsuya,yoshinoya,sukiya)
write.csv(gyudon,"all_gyudon.csv",row.names=F)

print("data保存OK(all_gyudon.csv)")

gyudon <- cbind(gyudon, (gyudon[,ncol(gyudon)-2] - gyudon[,ncol(gyudon)-3]), (gyudon[,ncol(gyudon)-2] - gyudon[,ncol(gyudon)-6]) )
names(gyudon)[c(ncol(gyudon)-1,ncol(gyudon))]<-c("diff_1week","diff_4weeks")

write.csv(gyudon,"all_gyudon_diff.csv",row.names=F)
x<-read.csv("all_gyudon_diff.csv")
sp_x<-split(x,x$Storetype)

##################データ生成end

###関数定義
#北海道データ抽出
gethokkaidodata<-function(data){
	return(data[data[,ncol(data)-2]=="北海道"])
}
#東北データ抽出
gettohokudata<-function(data){
	return(data[data[,ncol(data)-2]=="青森県"]|data[data[,ncol(data)-2]=="岩手県"]|data[data[,ncol(data)-2]=="秋田県"]|data[data[,ncol(data)-2]=="山形県"]|data[data[,ncol(data)-2]=="宮城県"]|data[data[,ncol(data)-2]=="福島県"],)
}
#北関東データ抽出
getkitakantodata<-function(data){
	return(data[data[,ncol(data)-2]=="栃木県"|data[,ncol(data)-2]=="群馬県"|data[,ncol(data)-2]=="茨城県",])
}
#東京データ抽出
gettokyodata<-function(data){
	return(data[data[,ncol(data)-2]=="東京都"|data[,ncol(data)-2]=="神奈川"|data[,ncol(data)-2]=="埼玉県"|data[,ncol(data)-2]=="千葉県",])
}
#東海データ抽出
#北陸中部データ抽出
#近畿データ抽出
#中国データ抽出
#四国データ抽出
getshikokudata<-function(data){
	return(data[data[,ncol(data)-2]=="徳島県"|data[,ncol(data)-2]=="香川県"|data[,ncol(data)-2]=="愛媛県"|data[,ncol(data)-2]=="高知県",])
}
#九州データ抽出
#沖縄データ抽出
getokinawadata<-function(data){
	return(data[data[,ncol(data)-2]=="沖縄県",])
}

###関数定義ここまで


##########################################

#メイン処理関数(対n週前)
mainoutput<-function(n){
sink(outputfile,append=T)
	#nthname : "先週"or"n週前"
	if(n==1){nthname="先週"
	}else{nthname=paste(n,"週前",sep="")
	}

#小見出し
cat("<h3>---対",nthname,"(",sub("X","",names(x)[length(x)-(4+n)]),")","比---</h3>\n",
"吉野家・松屋・すき家のアルバイト日中時給(各店舗下限値。高校生時給及び研修時給除く)について、対",nthname,"(",sub("X","",names(x)[length(x)-(4+n)]),")","比の状況は以下のとおりです。\n",sep="")
cat("|*",sub("X","",names(x)[length(x)-(4+n)]),"比|*求人中店舗数[件]|*上昇店舗数[件]|*下落店舗数[件]|*上昇-下落|\n",sep="")
output_diff(sp_x$吉野家,"吉野家",n)
output_diff(sp_x$松屋,"松屋",n)
output_diff(sp_x$すき家,"すき家",n)
output_diff(x,"計",n)

#出力先戻す
sink()
}
##########################################

##関数定義
##最新データの記述統計
#
#|*Storetype|*求人中店舗数[件]|*最小値[円]|*第一四分位点[円]|*中央値[円]|*第三四分位点[円]|*最高値[円]|*平均値[円]|
#
output_N<-function(xdata,xname){
	s_xdata<-summary(xdata[,ncol(xdata)-4])
	l_xdata<-length(na.omit(xdata[,ncol(xdata)-4]))
	cat("|*",xname,"|",l_xdata,"|",s_xdata[1],"|",s_xdata[2],"|",s_xdata[3],"|",s_xdata[5],"|",s_xdata[6],"|",s_xdata[4],"|\n",sep="")

}
##差の記述統計
#Storetype、求人数、上昇、下落、上昇-下落
output_diff<-function(xdata,xname,n1){
	l_xdata<-length(na.omit(xdata[,ncol(xdata)-4])) #求人数
	ge0_q<-length(na.omit(xdata[ ( xdata[,ncol(xdata)-4] - xdata[,ncol(xdata)-(4 + n1), ncol(xdata)-4 ] ) >0, ncol(xdata)-4 ])) #上昇店舗数
	le0_q<-length(na.omit(xdata[ ( xdata[,ncol(xdata)-4] - xdata[,ncol(xdata)-(4 + n1), ncol(xdata)-4 ] ) <0, ncol(xdata)-4 ])) #下落店舗数
	cat("|*",xname,"|",l_xdata,"|",ge0_q,"|",le0_q,"|",ge0_q-le0_q,"|\n",sep="")
}
##
##差のある店舗一覧

wageup<-function(n){

sink(outputfile,append=T)
#nthname : "先週"or"n週前"
	if(n==1){nthname="先週"
	}else{nthname=paste(n,"週前",sep="")
	}

	if(length(na.omit(sp_x$すき家[sp_x$すき家[ncol(sp_x$すき家)-1]>0,ncol(sp_x$すき家)-1])) + length(na.omit(sp_x$松屋[sp_x$松屋[ncol(sp_x$松屋)-1]>0,ncol(sp_x$松屋)-1])) + length(na.omit(sp_x$吉野家[sp_x$吉野家[ncol(sp_x$吉野家)-1]>0,ncol(sp_x$吉野家)-1])) == 0){ cat("<h3>---時給上昇店舗---</h3>\n",
"対",nthname,"(",sub("X","",names(x)[length(x)-(4+n)]),")","比で時給が上昇した店舗はありません。\n",sep="")
 }
else{
	#小見出し
cat("<h3>---時給上昇店舗---</h3>\n",
"対",nthname,"(",sub("X","",names(x)[length(x)-(4+n)]),")","比で時給が上昇した店舗は以下のとおりです。\n",sep="")
cat("|*店舗名","|*Storetype","|*都道府県","|*",sub("X","",names(x)[length(x)-(4+n)]),"時給[円]|*",names(x)[length(x)-4],"時給[円]|*上昇額[円]|\n",sep="")
#
#
wageup_diff<-function(xdata){
	tmpx <- na.omit(xdata[xdata[,ncol(xdata)-1]>=1,c(1,ncol(xdata)-c(3,2,(4+1),4,1))])
	tmpx<-tmpx[order(tmpx[,3]),]
	if(nrow(tmpx)!=0){
		for(i in 1:nrow(tmpx)){
			cat("|*",as.character(tmpx[i,1]),"|",as.character(tmpx[i,2]),"|",as.character(tmpx[i,3]),"|",tmpx[i,4],"|",tmpx[i,5],"|",tmpx[i,6],"|\n",sep="")
		}
	}
}
wageup_diff(sp_x$吉野家)
wageup_diff(sp_x$松屋)
wageup_diff(sp_x$すき家)

}
#出力先戻す
sink()
}
##
##
wagedown<-function(n){

sink(outputfile,append=T)
	#nthname : "先週"or"n週前"
	if(n==1){nthname="先週"
	}else{nthname=paste(n,"週前",sep="")
	}
	if(length(na.omit(sp_x$すき家[sp_x$すき家[ncol(sp_x$すき家)-1]<0,ncol(sp_x$すき家)-1])) + length(na.omit(sp_x$松屋[sp_x$松屋[ncol(sp_x$松屋)-1]<0,ncol(sp_x$松屋)-1])) + length(na.omit(sp_x$吉野家[sp_x$吉野家[ncol(sp_x$吉野家)-1]<0,ncol(sp_x$吉野家)-1])) == 0){ cat("<h3>---時給下落店舗---</h3>\n",
"対",nthname,"(",sub("X","",names(x)[length(x)-(4+n)]),")","比で時給が下落した店舗はありません。\n",sep="")
 }
else{

#小見出し
cat("<h3>---時給下落店舗---</h3>\n",
"対",nthname,"(",sub("X","",names(x)[length(x)-(4+n)]),")","比で時給が下落した店舗は以下のとおりです。\n",sep="")
cat("|*店舗名","|*Storetype","|*都道府県","|*",sub("X","",names(x)[length(x)-(4+n)]),"時給[円]|*",names(x)[length(x)-4],"時給[円]|*変化額[円]|\n",sep="")

wagedown_diff<-function(xdata){
	tmpx <- na.omit(xdata[xdata[,ncol(xdata)-1]<=-1,c(1,ncol(xdata)-c(3,2,(4+1),4,1))])
	tmpx<-tmpx[order(tmpx[,3]),]
	if(nrow(tmpx)!=0){
		for(i in 1:nrow(tmpx)){
			cat("|*",as.character(tmpx[i,1]),"|",as.character(tmpx[i,2]),"|",as.character(tmpx[i,3]),"|",tmpx[i,4],"|",tmpx[i,5],"|",tmpx[i,6],"|\n",sep="")
		}
	}
}
wagedown_diff(sp_x$吉野家)
wagedown_diff(sp_x$松屋)
wagedown_diff(sp_x$すき家)
}#ifここまで
#出力先戻す
sink()
}
#######################

#ファイルをカラにする
write("",outputfile)
#メイン処理
###########
#共通
sink(outputfile,append=T)
cat("[牛丼短観][牛丼週報][時給観測]牛丼チェーン店アルバイト時給観測(牛丼短観)",sub("X","",names(x)[length(x)-4]),"\n",sep="")
cat(sub("X","",names(x)[length(x)-4]),"現在、吉野家・松屋・すき家のアルバイト募集状況(日中、各店舗下限値。高校生時給・研修時給除く)は以下のとおりです。\n",
sep="")
cat("|*Storetype|*求人中店舗数[件]|*最小値[円]|*第一四分位点[円]|*中央値[円]|*第三四分位点[円]|*最高値[円]|*平均値[円]|\n")
output_N(sp_x$吉野家,"吉野家")
output_N(sp_x$松屋,"松屋")
output_N(sp_x$すき家,"すき家")
output_N(x,"計")

#出力先戻す
sink()
############
#先週比
mainoutput(1)
#先週比時急上昇店舗
wageup(1)
#先週比時急下落店舗
wagedown(1)
#4週前比
mainoutput(4)

sink(outputfile,append=T)

cat("データ元：\n -松屋:「バイトル(時間：「昼」) http://www.baitoru.com/aspjlist/?st=1&ASP_MGR_NO=4254&ASP_VALUE=asp%3A1013&ASP_KEYWORD=-&page=1 \n -吉野家：「バイトル(検索ワード:\"-\")」http://www.baitoru.com/aspjlist/?st=2&ASP_MGR_NO=3706&ASP_VALUE=&ASP_KEYWORD=-&page=1 \n -すき家：「すき家公式サイト(検索ワード:\"-\")」http://jobs.sukiya.jp/shops?k=-&page=1 \n")
#出力先戻す
sink()
