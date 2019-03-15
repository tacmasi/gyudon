head -1 all_gyudon_colnameon.csv|awk -F, '{print $NF}' > unique.csv
echo Quantity Gyudon_Wage>> unique.csv
awk -F, '$NF != "NA"{print $NF}' all_gyudon.csv |sort -n|uniq -c >> unique.csv
head -1 all_gyudon_colnameon.csv|awk -F, '{print $NF}' > except_tokyo.csv
echo Quantity Gyudon_Wage_except_Tokyo_Kanagawa_Chiba_Saitama>> except_tokyo.csv
cat all_gyudon.csv|grep -v 東京都|grep -v 神奈川|grep -v 埼玉県 |grep -v 千葉県|awk -F, '$NF != "NA"{print $NF}' |sort -n|uniq -c >> except_tokyo.csv
