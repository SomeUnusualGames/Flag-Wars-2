! 2022 nomennescio
! https://paste.factorcode.org/paste?id=4347
USING:  kernel lexer math parser words.constant ;
IN: indices

: (create-indices) ( n -- m ) ";" [ create-word-in over define-constant 1 + ] each-token ;

SYNTAX: INDEX: 0 (create-indices) drop ;
SYNTAX: +INDEX: scan-number (create-indices) drop ;


! usage:
! INDEX: zero one two three four five six seven eight nine ;
! INDEX: sunday monday tuesday wednesday thursday friday saturday ;

! usage :
! +INDEX: 0 zero one two three four five six seven eight nine ;