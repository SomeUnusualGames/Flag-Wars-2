USING: accessors boss classes.struct kernel math menu namespaces player raylib ;
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
        Player get hp>> 0 >
        [
            update-boss
            Boss get Player get update-menu
        ]
        [
            Player get alpha>> 0 > [ Player get [ 1 - ] change-alpha drop ] when
        ] if
        begin-drawing
        draw-background
        ! Player get hp>> 0 >
        ! [
            Menu get boss-is-flustered>> draw-boss
            Player get dup hp>> swap max-hp>> Boss get dup current-hp>> swap max-hp>> draw-menu
            Player get hp>> 0 <= [ "Game Over! Press ESCAPE to quit." 100 10 40 WHITE draw-text ] when
        ! ] when
        end-drawing
        window-should-close not
    ] loop ;

: unload-game ( -- )
    unload-boss
    unload-menu
    close-window ;