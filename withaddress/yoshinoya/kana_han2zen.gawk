#!/usr/bin/gawk -f
#gawk用
#半角カナ to 全角カナ and 全角英数 to 半角英数
#牛丼短観用
#
#ex. $ ./kana_hantozen.gawk test.txt
#参考:http://www.geocities.jp/cygnus_odile/tategaki/script-sjis/han2zen.awk.txt
#

BEGIN{
	split("０１２３４５６７８９", az, "");
	split("0123456789", ah, "");

	split("ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ", bz, "");
	split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", bh, "");

	split("･ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ", kh, "");
	split("・ヲァィゥェォャュョッーアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワン", kz, "");


	split("ｳｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾊﾋﾌﾍﾎ", khb, ""); #濁点可能性文字
	split("ヴガギグゲゴザジズゼゾダヂヅデドバビブベボ", kzd, "");

	split("ﾊﾋﾌﾍﾎ", hhm, ""); #半濁点可能性文字
	split("パピプペポ", kze, "");
}
#main
{
		for(cnt in az)	gsub(az[cnt],ah[cnt]);	#全角英数to半角
		for(cnt in bz)	gsub(bz[cnt],bh[cnt]);	#全角英数to半角
		for(cnt in khb)	gsub(khb[cnt] "ﾞ",kzd[cnt]); #半角濁点文字to全角
		for(cnt in hhm)	gsub(hhm[cnt] "ﾟ",kze[cnt]); #半角パ行to全角
		for(cnt in kh)	gsub(kh[cnt],kz[cnt]);	#han2zen
		print; #出力
}
