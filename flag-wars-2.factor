! Copyright (C) 2022 SomeUnusualGames.
! See http://factorcode.org/license.txt for BSD license.
USE: game
IN: flag-wars-2

: main ( -- )
    init-game
    update-draw-game
    unload-game ;

: flag-wars-2-run ( -- ) main ;

MAIN: flag-wars-2-run