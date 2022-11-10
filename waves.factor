USING: accessors combinators indices kernel math math.constants namespaces
random raylib sequences ;
IN: waves

INDEX: WAVE_NONE WAVE_1 WAVE_2 ;

SYMBOL: Waves
TUPLE: Bullet
    { hitbox Rectangle }
    { direction Vector2 }
    { angle-direction float }
    { angle-facing float }
    { time-spawn float }
    { special-flag boolean } ;
C: <Bullet> Bullet

TUPLE: wave-vars
    { current-wave integer }
    { current-box Rectangle }
    { wave-timer float }
    { box Rectangle }
    { leg-texture Texture2D }
    { pizza-texture Texture2D }
    { bullet-list sequence }
    { box-size-changed boolean } 
    { change-menu boolean } ;
C: <wave-vars> wave-vars

: deg>rad ( deg -- rad ) pi * 180 / ; inline

: init-waves ( -- )
    WAVE_NONE
    100 300 get-screen-width 200 - 200 Rectangle boa
    0.0
    105 305 get-screen-width 210 - 190 Rectangle boa
    "assets/graphics/Sicily_leg.png" load-texture
    "assets/graphics/pizza.png" load-texture
    0 { } new-sequence f f <wave-vars> Waves set ;

:: create-pizza ( i -- )
    Waves get :> wave
    250 random 350 + :> x
    -50 :> y

    ! True pizza lovers know that real pizzas have 6 slices
    wave
    dup bullet-list>>
    x 10 + y 8 + 15 15 Rectangle boa 250 250 <Vector2> 0.0  55.0 deg>rad i 1.2 / f <Bullet> suffix
    x      y 1 + 15 15 Rectangle boa 250 250 <Vector2> 0.0  0.0  deg>rad i 1.2 / f <Bullet> suffix
    x 10 - y 8 + 15 15 Rectangle boa 250 250 <Vector2> 0.0 -55.0 deg>rad i 1.2 / f <Bullet> suffix
    
    x 10 + y 23 + 15 15 Rectangle boa 250 250 <Vector2> 0.0 125.0 deg>rad i 1.2 / f <Bullet> suffix
    x      y 30 + 15 15 Rectangle boa 250 250 <Vector2> 0.0 180.0 deg>rad i 1.2 / f <Bullet> suffix
    x 10 - y 23 + 15 15 Rectangle boa 250 250 <Vector2> 0.0 235.0 deg>rad i 1.2 / f <Bullet> suffix
    >>bullet-list drop ;

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
                        wave 
                        dup bullet-list>>
                        250 random 350 + get-screen-height 100 + 60 152 Rectangle boa
                        0 -250 <Vector2>
                        0.0 0.0
                        i 1.2 /
                        f
                        <Bullet> suffix
                        >>bullet-list drop
                    ] each-integer
                    drop
                ]
            }
            {
                [ wave current-wave>> WAVE_2 = ]
                [
                    wave
                    250 300 get-screen-width 500 - 200 Rectangle boa >>current-box
                    t >>box-size-changed
                    18.0 >>wave-timer
                    18 [ create-pizza ] each-integer drop
                ]
            }
            [ ]
        } cond
    ]
    [
        text-box-rect x>> wave current-box>> x>> - dup 0 =
        [ text-box-rect [ swap sgn 10 * - ] change-x ] unless

        text-box-rect width>> wave current-box>> width>> - dup 0 =
        [ text-box-rect [ swap sgn 20 * - ] change-width ] unless
        2drop
        ! wave wave-timer>> . "wave-timer<-" print
        wave dup wave-timer>> 0 <= text-box-rect width>> get-screen-width 200 - >= and >>change-menu drop
    ] if
    wave wave-timer>> 0 >
    [
        wave bullet-list>>
        [| bullet i |
            bullet time-spawn>> 0 >
            [ bullet [ get-frame-time - ] change-time-spawn drop ]
            [
                bullet hitbox>>
                [ bullet direction>> y>> get-frame-time * bullet angle-direction>> cos * + ] change-y
                [ bullet direction>> x>> get-frame-time * bullet angle-direction>> sin * + ] change-x                
                bullet hitbox>> y>> get-screen-height 1.6 / > bullet special-flag>> not and wave current-wave>> WAVE_2 = and
                [
                    bullet
                    t >>special-flag
                    dup angle-facing>> 10.0 deg>rad - >>angle-direction
                    drop
                ] when
                player box>> x>> player box>> y>> player size>> x>> player size>> y>> Rectangle boa check-collision-recs
                [ player [ 0.3 - ] change-hp player! ] when
                ! drop
            ] if
        ] each-index
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
            {
                {
                    [ wave current-wave>> WAVE_1 = ]
                    [
                        wave leg-texture>>
                        0 0 60 152 Rectangle boa
                        bullet hitbox>>
                        0 0 <Vector2>
                        bullet angle-facing>> 180 * pi /
                        WHITE
                        draw-texture-pro
                    ]
                }
                {
                    [ wave current-wave>> WAVE_2 = ]
                    [ 
                        wave pizza-texture>>
                        0 0 30 30 Rectangle boa
                        bullet hitbox>> x>> bullet hitbox>> y>> 30 30 Rectangle boa
                        15 15 <Vector2>
                        bullet angle-facing>> 180 * pi /
                        WHITE
                        draw-texture-pro
                        bullet hitbox>> WHITE draw-rectangle-rec
                    ]
                }
            } cond
            ! bullet hitbox>> WHITE draw-rectangle-rec
        ] when
    ] each ;

: unload-waves ( -- )
    Waves get
    dup leg-texture>> unload-texture 
    pizza-texture>> unload-texture ;