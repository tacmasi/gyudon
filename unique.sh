head -1 all_gyudon_colnameon.csv|awk -F, '{print $NF}' > unique.csv
echo Quantity Gyudon_Wage>> unique.csv
awk -F, '$NF != "NA"{print $NF}' all_gyudon.csv |sort -n|uniq -c >> unique.csv
