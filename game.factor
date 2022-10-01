USING: boss classes.struct kernel menu namespaces raylib ;
IN: game

CONSTANT: SICILY-RED S{ Color f 218 18 26 255 }
CONSTANT: SICILY-YELLOW S{ Color f 252 221 9 255 }

: init-game ( -- )
    960 640 "Flag wars 2" init-window
    60 set-target-fps
    init-boss
    init-menu ;

: draw-background ( -- )
    SICILY-RED clear-background
    0 0 <Vector2>
    0 get-screen-height <Vector2>
    get-screen-width get-screen-height <Vector2>
    SICILY-YELLOW
    draw-triangle ;

: update-draw-game ( -- )
    [
        update-boss
        update-menu
        begin-drawing
        draw-background
        draw-boss
        draw-menu
        end-drawing
        window-should-close not
    ] loop ;

: unload-game ( -- )
    unload-boss
    unload-menu
    close-window ;