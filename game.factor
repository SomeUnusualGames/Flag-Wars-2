USING: accessors boss classes.struct kernel math menu namespaces player raylib ;
IN: game

CONSTANT: SICILY-RED S{ Color f 218 18 26 255 }
CONSTANT: SICILY-YELLOW S{ Color f 252 221 9 255 }

SYMBOL: SplashScreen
TUPLE: splash-screen-vars
    { logo Texture2D }
    { screen-timer float }
    { texture-timer float } ;
C: <splash-screen-vars> splash-screen-vars

: init-game ( -- )
    960 640 "Flag wars 2" init-window
    60 set-target-fps
    960 640 set-window-size
    init-audio-device
    init-boss
    init-menu
    init-player
    "assets/graphics/sug_logo2.png" load-texture 8.0 8.0 <splash-screen-vars> SplashScreen set ;

: draw-background ( -- )
    SICILY-RED clear-background
    0 0 <Vector2>
    0 get-screen-height <Vector2>
    get-screen-width get-screen-height <Vector2>
    SICILY-YELLOW
    draw-triangle ;

: update-draw-splashscreen ( -- timer-counting )
    ! NOTE: Closing the game here means that all textures won't be unloaded,
    ! but that really shouldn't matter...
    window-should-close [ close-window 0 exit ] when
    SplashScreen get
    [ get-frame-time - ] change-texture-timer
    [ get-frame-time - ] change-screen-timer
    dup screen-timer>> 0 > swap
    begin-drawing
    WHITE clear-background
    dup logo>> swap
    texture-timer>> dup 3.8 > swap 4 < and
    [ 300 0 300 264 Rectangle boa ] [ 0 0 300 264 Rectangle boa ] if
    400 50 150 132 Rectangle boa 0 0 <Vector2> 0.0 WHITE draw-texture-pro
    "By SomeUnusualGames" 200 200 50 BLACK draw-text
    "Powered by: Raylib and the Factor language" 20 350 40 BLACK draw-text
    end-drawing ;

: unload-splashscreen ( -- ) SplashScreen get logo>> unload-texture ;

: update-draw-game ( -- )
    [
        Player get hp>> 0 >
        [
            update-boss
            Boss get current-hp>> 0 > Menu get attack-action-done>> not or 
            [ Boss get Player get update-menu ]
            [ Boss get alpha>> 0 > [ Boss get [ 1 - ] change-alpha drop ] when ] if
        ]
        [ Player get alpha>> 0 > [ Player get [ 1 - ] change-alpha drop ] when ] if
        begin-drawing
        draw-background
        Menu get boss-is-flustered>> Menu get boss-is-annoyed>> draw-boss
        Player get dup hp>> swap max-hp>> Boss get dup current-hp>> swap max-hp>> draw-menu
        Player get hp>> 0 <= [ "Game Over! Press ESCAPE to quit." 100 10 40 WHITE draw-text ] when
        Boss get hp>> 0 <= [ "You won! Press ESCAPE to quit." 150 330 40 WHITE draw-text ] when
        end-drawing
        window-should-close not
    ] loop ;

: unload-game ( -- )
    close-audio-device
    unload-boss
    unload-menu
    close-window ;