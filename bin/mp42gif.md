
cd /Users/wjg/Desktop

ffmpeg -i 2.mp4 -filter:v "setpts=0.5*PTS" -s 640x360 -r 10 2.gif