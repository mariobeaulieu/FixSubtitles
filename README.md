# FIX Subtitles
#
# This bash shell script will multiply all times in a subtitle file by a factor
# to fix subtitles that are too slow or too fast
#
# HOW TO USE:
# 1) Start the video you want to fix the subtitles for and enable its subtitles
# 2) Go towards the end of the video and identify a sentence said
#    For instance, someone says "Let's go" at time 50m0s
# 3) In the subtitle file find the time whete "Let's go" is said (let's say 55m0s)
# 4) Calculate the factor to use:
#    50min/55min=0.9090909
#    The factor to use will be 909  (1000*value found)
#    fix_srt.sh  mymovie.srt  909
#    A new file called mymovie_909.srt will be created.
#
# For more info, type 
#  fix_srt.sh -h
