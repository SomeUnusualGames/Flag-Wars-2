! Copyright (C) 2022 SomeUnusualGames.
! See http://factorcode.org/license.txt for BSD license.
USING: boss classes.struct kernel namespaces raylib button ;
IN: flag-wars-2

CONSTANT: SICILY-RED S{ Color f 218 18 26 255 }
CONSTANT: SICILY-YELLOW S{ Color f 252 221 9 255 }

: draw-triangle-background ( -- )
    0 0 <Vector2>
    0 get-screen-height <Vector2>
    get-screen-width get-screen-height <Vector2>
    SICILY-YELLOW
    draw-triangle ;

: flag-wars-2 ( -- )
    960 640 "Flag wars 2" init-window
    60 set-target-fps
    init-boss
    init-buttons
    [
        update-boss
        begin-drawing
        SICILY-RED clear-background
        draw-triangle-background
        draw-boss
        draw-buttons
        end-drawing
        window-should-close not
    ] loop
    unload-boss
    close-window ;

: flag-wars-2-run ( -- ) flag-wars-2 ;

MAIN: flag-wars-2-run