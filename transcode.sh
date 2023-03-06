#!/bin/bash
#run script in the parent directory; crawls through all child directorys;
#the audio streams of all .mkv containing dts audio are transcoded to ac3!
R='\033[0;31m'   #'0;31' is Red's ANSI color code
G='\033[0;32m'   #'0;32' is Green's ANSI color code
Y='\033[1;32m'   #'1;32' is Yellow's ANSI color code
W='\033[0m'   	 #'0m' is White's ANSI color code

#check if all necessary commands are installed
echo "checking dependencies"
command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "I require ffmpeg but it's not installed.  Aborting."; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { echo >&2 "I require ffprobe but it's not installed.  Aborting."; exit 1; }
command -v grep >/dev/null 2>&1 || { echo >&2 "I require grep but it's not installed.  Aborting."; exit 1; }
command -v detox >/dev/null 2>&1 || { echo >&2 "I require detox but it's not installed.  Aborting."; exit 1; }
echo "dependencies ok"

echo -e "${G}" #switch to green
echo "getting filenames straight:"
echo -e "${W}" #switch back to white
echo -e "${Y}" #switch to yellow
detox -r -v $PWD #clears all toxic filenames
echo -e "${W}" #switch back to white

#start crawling
start_time=$(date +%s)
shopt -s globstar

for p in $PWD/*.mkv $PWD/**/*.mkv
do
fn=${p##*/}
d=${p%/*}
echo -e "${G}" #switch to green
echo "this file is under inspection:" $fn
echo "files directory:" $d
echo -e "${Y}" #switch to yellow
echo "making fileinfo"
echo -e "${W}" #switch back to white

ffprobe $p |& tee $d/fileinfo.txt
if ! grep "Audio: dts" $d/fileinfo.txt
then 
	echo -e "${G}" #switch to green
	echo "$fn not containing dts audio"
else 
	echo -e "${R}" #switch to red
	echo "$fn containing dts audio.... converting:"
	echo -e "${W}" #switch to back to white
	mkdir $d/temp
	ffmpeg -y -i "$p" -map 0:v -map 0:a -map 0:s -c:v copy -c:a ac3 -c:s copy "$d/temp/$fn" && mv "$d/temp/$fn" "$d/$fn"
	rmdir $d/temp
fi

done

echo -e "${R}" #switch to red
echo end!
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
echo elapsed time:$elapsed seconds
