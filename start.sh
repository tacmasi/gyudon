#/bin/bash
export LC_COLLATE=ja_JP.utf8
export LC_ALL=

rm *.tmp
#./getgyudon.sh
./allgyudonwage.sh
./reportwrite.sh
#./med.sh
#./unique.sh
