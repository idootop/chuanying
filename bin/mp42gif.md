
ffmpeg -i play.mov -c copy -ss 00:01 -t 00:42 play2.mov

ffmpeg -i play2.mov -filter:v "setpts=0.3*PTS" -s 360x720 -r 10 play.gif