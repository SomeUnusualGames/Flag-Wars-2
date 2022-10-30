USING: accessors combinators indices kernel math math.constants namespaces
random raylib sequences ;
IN: waves

INDEX: WAVE_NONE WAVE_1 ;

SYMBOL: Waves
TUPLE: Bullet
    { hitbox Rectangle }
    { direction Vector2 }
    { angle float }
    { time-spawn float } ;
C: <Bullet> Bullet

TUPLE: wave-vars
    { current-wave integer }
    { current-box Rectangle }
    { wave-timer float }
    { box Rectangle }
    { leg-texture Texture2D }
    { bullet-list sequence }
    { box-size-changed boolean } 
    { change-menu boolean } ;
C: <wave-vars> wave-vars

: init-waves ( -- )
    WAVE_NONE
    100 300 get-screen-width 200 - 200 Rectangle boa
    0.0
    105 305 get-screen-width 210 - 190 Rectangle boa
    "assets/graphics/Sicily_leg.png" load-texture
    0 { } new-sequence f f <wave-vars> Waves set ;

:: update-wave ( text-box-rect! player! -- )
    Waves get :> wave
    wave box-size-changed>> not
    [
        {
            {
                [ wave current-wave>> WAVE_1 = ]
                [
                    wave
                    350 300 get-screen-width 700 - 200 Rectangle boa >>current-box
                    t >>box-size-changed
                    15.0 >>wave-timer
                    14
                    [| i |
                        ! wave bullet-list>> length .
                        ! "--" print
                        wave 
                        dup bullet-list>>
                        250 random 350 + get-screen-height 100 + 60 152 Rectangle boa
                        0 -250 <Vector2>
                        0.0
                        i 1.2 /
                        <Bullet> suffix
                        >>bullet-list drop
                        ! TODO: Decrease wave timer and go back to the menu
                    ] each-integer
                    drop
                ]
            }
            [ ]
        } cond
    ]
    [
        ! TODO: go back to the menu when box is the same size as the regular box
        text-box-rect x>> wave current-box>> x>> - dup 0 =
        [ text-box-rect [ swap sgn 10 * - ] change-x ] unless

        text-box-rect width>> wave current-box>> width>> - dup 0 =
        [ text-box-rect [ swap sgn 20 * - ] change-width ] unless
        2drop
        wave dup wave-timer>> 0 <= text-box-rect width>> get-screen-width 200 - >= and >>change-menu drop
    ] if
    wave wave-timer>> 0 >
    [
        wave bullet-list>>
        [| bullet |
            bullet time-spawn>> 0 >
            [ bullet [ get-frame-time - ] change-time-spawn drop ]
            [
                ! TODO: Do proper movement based on the angle
                bullet hitbox>>
                [ bullet direction>> y>> get-frame-time * + ] change-y
                player box>> x>> player box>> y>> player size>> x>> player size>> y>> Rectangle boa check-collision-recs
                [ player [ 0.3 - ] change-hp player! ] when
                ! drop
            ] if
        ] each
        wave
        [ get-frame-time - ] change-wave-timer
        wave-timer>> 0 <=
        [
            wave
            t >>box-size-changed
            100 300 get-screen-width 200 - 200 Rectangle boa >>current-box
            0 { } new-sequence >>bullet-list
            drop
        ] when
    ] when
    ;

:: draw-waves ( -- )
    Waves get :> wave
    wave bullet-list>>
    [| bullet |
        bullet time-spawn>> 0 <=
        [
            wave leg-texture>>
            0 0 60 152 Rectangle boa
            bullet hitbox>>
            0 0 <Vector2>
            bullet angle>> 180 * pi /
            WHITE
            draw-texture-pro
            ! bullet hitbox>> WHITE draw-rectangle-rec
        ] when
    ] each ;

: unload-waves ( -- )
    Waves get
    leg-texture>> unload-texture ;