#/bin/bash
export LC_COLLATE=ja_JP.utf8

rm *.tmp
./getgyudon.sh
./allgyudonwage.sh
./reportwrite.sh
#./med.sh
./unique.sh
