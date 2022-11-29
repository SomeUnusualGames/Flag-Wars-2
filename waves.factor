USING: accessors combinators indices kernel math math.functions
namespaces random raylib sequences utils ;
IN: waves

INDEX: WAVE_NONE WAVE_1 WAVE_2 WAVE_3 ;

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
    { damage float }
    { wave-timer float }
    { box Rectangle }
    { leg-texture Texture2D }
    { pizza-texture Texture2D }
    { tower-texture Texture2D }
    { bullet-list sequence }
    { box-size-changed boolean }
    { set-random-wave boolean }
    { change-menu boolean } ;
C: <wave-vars> wave-vars

: init-waves ( -- )
    WAVE_NONE
    100 300 get-screen-width 200 - 200 Rectangle boa
    0.3
    0.0
    105 305 get-screen-width 210 - 190 Rectangle boa
    "assets/graphics/Sicily_leg.png" load-texture
    "assets/graphics/pizza.png" load-texture
    "assets/graphics/pisa_tower.png" load-texture
    0 { } new-sequence f f f <wave-vars> Waves set ;

:: set-wave-1 ( -- )
    Waves get
    350 300 get-screen-width 700 - 200 Rectangle boa >>current-box
    t >>box-size-changed
    15.0 >>wave-timer drop
    14
    [| i |
        Waves get
        dup bullet-list>>
        250 random 350 + get-screen-height 100 + 60 152 Rectangle boa
        0 -250 <Vector2>
        0.0 0.0
        i 1.2 /
        f
        <Bullet> suffix
        >>bullet-list drop
    ] each-integer ;

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

: set-wave-2 ( -- )
    Waves get
    250 300 get-screen-width 500 - 200 Rectangle boa >>current-box
    t >>box-size-changed
    18.0 >>wave-timer drop
    18 [ create-pizza ] each-integer ;

:: set-wave-3 ( -- )
    Waves get
    350 300 get-screen-width 700 - 200 Rectangle boa >>current-box
    t >>box-size-changed
    20.0 >>wave-timer drop
    14
    [| i |
        Waves get
        dup bullet-list>>
        100 random :> rand-n
        rand-n 2 mod 0 = 380 get-screen-width 480 - ? get-screen-height 200 + 56 339 Rectangle boa
        0 -320 <Vector2>
        0.0 rand-n 2 mod 0 = 3.97 -3.97 ?
        i i +
        f
        <Bullet> suffix
        >>bullet-list drop
    ] each-integer ;

:: change-box-size ( text-box-rect! player! -- )
    Waves get :> wave
    text-box-rect x>> wave current-box>> x>> - dup 0 =
    [ text-box-rect [ swap sgn 10 * - ] change-x ] unless
    text-box-rect width>> wave current-box>> width>> - dup 0 =
    [ text-box-rect [ swap sgn 20 * - ] change-width ] unless
    2drop

    text-box-rect y>> wave current-box>> y>> - dup 0 =
    [ text-box-rect [ swap sgn 10 * - ] change-y ] unless
    text-box-rect height>> wave current-box>> height>> - dup 0 =
    [ text-box-rect [ swap sgn 10 * - ] change-height ] unless
    2drop

    ! wave wave-timer>> . "wave-timer<-" print
    wave wave-timer>> 0 <= text-box-rect width>> get-screen-width 200 - >= and
    [
        wave
        t >>change-menu
        dup current-wave>> WAVE_3 =
        [ t >>set-random-wave ] when
        drop
        player 480 450 40 40 Rectangle boa >>box drop
    ] when ;

:: update-bullet ( player! boss-is-flustered boss-is-annoyed -- )
    Waves get :> wave
    wave
    {
        { [ boss-is-flustered ] [ 0.1 ] }
        { [ boss-is-annoyed ] [ 0.6 ] }
        [ 0.3 ]
    } cond >>damage drop
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
            [ player [ wave damage>> - ] change-hp player! ] when
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
    ] when ;

:: update-wave ( text-box-rect! player! boss-is-flustered boss-is-annoyed -- )
    Waves get :> wave
    wave box-size-changed>> not
    [
        {
            { [ wave current-wave>> WAVE_1 = ] [ set-wave-1 ] }
            { [ wave current-wave>> WAVE_2 = ] [ set-wave-2 ] }
            { [ wave current-wave>> WAVE_3 = ] [ set-wave-3 ] }
            [ ]
        } cond
    ]
    [ text-box-rect player change-box-size ] if
    wave wave-timer>> 0 > [ player boss-is-flustered boss-is-annoyed update-bullet ] when ;

:: draw-wave-1 ( wave bullet -- )
    wave leg-texture>>
    0 0 60 152 Rectangle boa
    bullet hitbox>>
    0 0 <Vector2>
    bullet angle-facing>> rad>deg
    WHITE
    draw-texture-pro ;

:: draw-wave-2 ( wave bullet -- )
    wave pizza-texture>>
    0 0 30 30 Rectangle boa
    bullet hitbox>> x>> bullet hitbox>> y>> 30 30 Rectangle boa
    15 15 <Vector2>
    bullet angle-facing>> rad>deg
    WHITE
    draw-texture-pro ;
    ! bullet hitbox>> WHITE draw-rectangle-rec ;

:: draw-wave-3 ( wave bullet -- )
    350 300 get-screen-width 700 - 200 begin-scissor-mode
    wave tower-texture>>
    0 0 112 339 Rectangle boa
    bullet hitbox>> x>> bullet hitbox>> y>> 112 339 Rectangle boa
    0 0 <Vector2>
    bullet angle-facing>>
    WHITE
    draw-texture-pro
    ! bullet hitbox>> WHITE draw-rectangle-rec
    end-scissor-mode ;

:: draw-waves ( -- )
    Waves get :> wave
    wave bullet-list>>
    [| bullet |
        bullet time-spawn>> 0 <=
        [
            {
                { [ wave current-wave>> WAVE_1 = ] [ wave bullet draw-wave-1 ] }
                { [ wave current-wave>> WAVE_2 = ] [ wave bullet draw-wave-2 ] }
                { [ wave current-wave>> WAVE_3 = ] [ wave bullet draw-wave-3 ] }
                [ ]
            } cond
        ] when
    ] each ;

: unload-waves ( -- )
    Waves get
    dup leg-texture>> unload-texture 
    dup pizza-texture>> unload-texture
    tower-texture>> unload-texture ;