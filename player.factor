USING: accessors kernel math math.constants math.functions math.libm namespaces raylib ;
IN: player

SYMBOL: Player

TUPLE: player-vars
    { texture Texture2D }
    { box Rectangle }
    { angle float } ;
C: <player-vars> player-vars

CONSTANT: PLAYER-SPEED 3.0

: init-player ( -- )
    "assets/graphics/The_armoured_triskelion_on_the_flag_of_the_Isle_of_Man.png" load-texture
    480 450 40 40 Rectangle boa
    0.0
    <player-vars> Player set ;

:: player-movement ( player! -- )
    player angle>> :> new-angle!
    0 0 <Vector2> :> movement!
    player box>> x>> player box>> y>> 40 40 Rectangle boa :> current-box!

    KEY_A is-key-down KEY_LEFT is-key-down or
    [ 
        pi neg 2 / new-angle!
        movement PLAYER-SPEED neg >>x movement!
    ] when
    KEY_D is-key-down KEY_RIGHT is-key-down or
    [
        new-angle pi 2 / + new-angle!
        movement PLAYER-SPEED >>x movement!
    ] when

    KEY_W is-key-down KEY_UP is-key-down or
    [
        new-angle 0 = not
        [
            pi 4 /
            new-angle 0 < [ neg ] when
            new-angle!
        ]
        [ 0.0 new-angle! ] if
        movement PLAYER-SPEED neg >>y movement!
    ] when
    KEY_S is-key-down KEY_DOWN is-key-down or
    [
        new-angle 0 = not
        [
            3 pi * 4 /
            new-angle 0 < [ neg ] when
            new-angle!
        ]
        [ pi new-angle! ] if
        movement PLAYER-SPEED >>y movement!
    ] when

    movement x>> 2 fpow movement y>> 2 fpow + sqrt :> magnitude
    magnitude PLAYER-SPEED >
    [
        movement dup x>> 2 sqrt / >>x movement!
        movement dup y>> 2 sqrt / >>y movement!
    ] when

    movement x>> 0 = not
    [ current-box dup x>> movement x>> + >>x current-box! ] when
    movement y>> 0 = not
    [ current-box dup y>> movement y>> + >>y current-box! ] when

    current-box x>> 127 > current-box x>> get-screen-width 130 - < and
    [ player box>> current-box x>> >>x drop ] when

    current-box y>> 325 > current-box y>> 473 < and
    [ player box>> current-box y>> >>y drop ] when ;

: update-player ( -- )
    Player get
    dup angle>> 40 get-frame-time * - >>angle
    player-movement ;

:: draw-player ( -- )
    Player get :> player
    player texture>>
    0 0 271 240 Rectangle boa
    player box>>
    20 20 <Vector2>
    player angle>>
    WHITE
    draw-texture-pro ;