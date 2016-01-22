#/bin/bash
echo Date Min 1stQ Median 3rdQ Max >quartile.tsv
#フィールド数検出
nf=$(head -1 all_gyudon.csv|awk -F, '{print NF}')

#5列目〜最新データまでの分位数をprint
for timeF in `seq 5 $nf`
do
#$timeFでの時給抽出
DataDate=$(head -1 all_gyudon_colnameon.csv|awk -F, '{print $'"$timeF"'}')
#求人中店舗数検出
totalRow=$(cat all_gyudon.csv|awk -F, 'BEGIN{timeF='"$timeF"'} $timeF!="NA"{print $timeF}'|wc -l)

cat all_gyudon.csv|awk -F, 'BEGIN{timeF='"$timeF"'} $timeF!="NA"{print $timeF}'|sort -n|awk '
BEGIN{tRow='"$totalRow"';
FstQR=int(tRow/4);
FstQR_C=tRow/4-FstQR;
MedR=int(tRow/2);
MedR_C=tRow/2-MedR;
SrdQR=int(tRow*3/4);
SrdQR_C=tRow*3/4-SrdQR
} 
NR==1{Min=$0}
NR==FstQR{FstQ=$0 * (1 - FstQR_C)}
NR==FstQR+1{FstQ+=$0 * FstQR_C }
NR==MedR{Med=$0 * (1 - MedR_C)}
NR==MedR+1{Med+=$0 * MedR_C}
NR==SrdQR{SrdQ=$0 * (1 - SrdQR_C)}
NR==SrdQR+1{SrdQ+=$0 * SrdQR_C}
NR==tRow{Max=$0}
END{print '"$DataDate"',Min,FstQ,Med,SrdQ,Max}' >>quartile.tsv
done

echo 四分位点の時系列データを quartile.tsv へ保存しました
