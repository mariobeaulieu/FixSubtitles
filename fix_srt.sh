#!/bin/bash

srt_in=$1
f=$2
srt_out=${srt_in%.srt}_$f.srt

if [ "$srt_in" == "" -o "$srt_in" == "-h" -o "$f" == "" -o $(echo "$f" | grep -c "[^0-9]") != 0 ]; then
	echo "This script is used to multiply all time values in a subtitle file by a factor"
	echo "For instance, if the subtitle appears at minute 10 but should appear at minute 9"
	echo "then a factor 900 should be used (= (9min/10min)*1000 )"
	echo 
	echo "Usage:"
	echo "  $0 <srt file to modify>  <factor>"
	echo "  where <srt file to modify> is the name of the subtitles file"
	echo "  and   <factor> is a factor (*1000) to multiply the time with"
	echo
	echo "The time format in the srt should be like this:"
	echo "00:00:01,369 --> 00:00:02,215"
	echo
	echo "The output srt file will have the same name but with _<factor> added"
	echo
	echo "For instance, the command:"
	echo
	echo "$0 mymovie.srt 900"
	echo
	echo "Will create file  mymovie_900.srt  which will have its subtitles displayed 10% sooner"
	echo "Factors can be in the range 800 to 2000"
	echo
	exit
fi

echo "Converting file <$srt_in> by multiplying all time by <$f %>. Output will be in file <$srt_out>"

if [ ! -e "$srt_in" ]; then
	echo "File <$srt_in> not found"
	exit
fi

if [ $(echo "$f" | grep -c "[^0-9]") -ne 0 ]; then
	echo "Second parameter is the factor (/1000). Should be an integer between 800 and 2000"
	exit
fi

if [ $f -le 800 -o $f -gt 2000 ]; then
	echo "Factor is expected to be between 800 (for 80%) and 200 (for 2000%)"
	exit
fi

function getVal() {
	v=$1 # Value
	s=$2 # Start character
	n=$3 # nb digits
	x=${v:s:n}
	# This part is to remove leading 0s because it will make value octal
	while [ "${x:0:1}" == "0" -a ${#x} -gt 1 ]; do
		x=${x:1}
	done
	echo $x
}

function convertToMilliseconds() {
	t=$1
	h=$(getVal $t 0 2)
	m=$(getVal $t 3 2)
	s=$(getVal $t 6 2)
	ms=$(getVal $t 9 3)
	milliseconds=$(((((h*60)+m)*60+s)*1000+ms))
	echo $milliseconds
}

function convertMsToString() {
	h=$1
	#echo "h=$h"
	ms=$((h%1000)); ((h/=1000))
	#echo "ms=$ms"
	s=$(( h%60  )); ((h/=60))
	#echo "s=$s"
	m=$(( h%60  )); ((h/=60))
	#echo "m=$m, h=$h"
	printf "%02i:%02i:%02i,%03i\n" $h $m $s $ms
}

#read -p "Press ENTER to continue"
rm -f "$srt_out"
count=0
t0=0

while read -r ligne; do
	if [ $(echo "$ligne" | grep -c "[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]") -eq 1 ]; then
		temps=${ligne:0:12}
		t1=$(convertToMilliseconds $temps)
		if [ $t0 -gt $t1 ]; then echo -e "\nWARNING -- Back in time at original time $temps"; fi
		t0=$t1
		((t1*=f));((t1/=1000))
		v1=$(convertMsToString $t1)
		temps=${ligne:17}
		t2=$(convertToMilliseconds $temps)
		if [ $t0 -gt $t2 ]; then echo -e "\nWARNING -- Back in time at original time $temps"; fi
		t0=$t2
		((t2*=f));((t2/=1000))
		v2=$(convertMsToString $t2)
		if [ $count -eq 0 ]; then echo -e "The line: $ligne\nBecame:   $v1 --> $v2\n"; fi
		ligne="$v1 --> $v2"
		((count++))
		echo -n "$count "
	fi
	echo "$ligne" >> "$srt_out"
done < "$srt_in"
echo;echo "$count lines modified"
