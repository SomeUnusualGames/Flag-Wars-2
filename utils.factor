USING: math math.constants sequences splitting strings ;
IN: utils

: count-char ( str substr -- n ) split-subseq length 1 - ; inline
: deg>rad ( deg -- rad ) pi * 180 / ; inline
: rad>deg ( rad -- deg ) 180 * pi / ; inline