USING: accessors boss classes.struct kernel menu namespaces player raylib ;
IN: game

CONSTANT: SICILY-RED S{ Color f 218 18 26 255 }
CONSTANT: SICILY-YELLOW S{ Color f 252 221 9 255 }

: init-game ( -- )
    960 640 "Flag wars 2" init-window
    60 set-target-fps
    init-boss
    init-menu
    init-player ;

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
        Boss get Player get update-menu
        begin-drawing
        draw-background
        Menu get boss-is-flustered>> draw-boss
        Player get dup hp>> swap max-hp>> Boss get dup current-hp>> swap max-hp>> draw-menu
        end-drawing
        window-should-close not
    ] loop ;

: unload-game ( -- )
    unload-boss
    unload-menu
    close-window ;