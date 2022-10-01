USING: accessors alien.enums button kernel math namespaces raylib sequences strings unicode ;
IN: menu

SYMBOL: Menu
TUPLE: text-vars
    { selected-text integer }
    { current-character integer }
    { max-delay float }
    { delay float }
    { current-text string }
    { printed-text string } ;
C: <text-vars> text-vars

TUPLE: menu-vars
    { currentButton integer } 
    { playerCursor Texture2D }
    { text text-vars } ;
C: <menu-vars> menu-vars

CONSTANT: MENU_TEXT
    { 
        "Smells like Italian stereotypes...|and pizza"
        "Test text 2"
        "Test text 3"
    }

: init-menu ( -- )
    ATTACK enum>number
    "assets/graphics/The_armoured_triskelion_on_the_flag_of_the_Isle_of_Man.png" load-texture
    0 0 0.04 0.04 0 MENU_TEXT nth "" <text-vars>
    <menu-vars> Menu set
    init-buttons ;

:: draw-text-new-line ( text x y font-size color -- )
    text "|" string-append :> final-text
    "" :> current-text!
    y :> y-pos!
    final-text length
    [| i |
        i final-text nth 1string "|" =
        [
            current-text x y-pos font-size color draw-text
            "" current-text!
            y-pos font-size + y-pos!
        ]
        [
            current-text i final-text nth 1string string-append current-text!
        ] if
    ] each-integer ;

:: update-text ( -- )
    Menu get text>> :> text
    text current-character>> text current-text>> length <
    [   
        text delay>> 0 >
        [ text [ text delay>> get-frame-time - ] change-delay 2drop ]
        [
            text
            [
                text printed-text>>
                text current-character>> text current-text>> nth 1string
                { } 2sequence concat
            ] change-printed-text nip
            dup [ 1 + ] change-current-character nip
            [ text max-delay>> ] change-delay 2drop
        ] if
    ] when ;

:: update-menu ( -- )
    Menu get :> menu
    update-text
    KEY_D is-key-pressed KEY_RIGHT is-key-pressed or menu currentButton>> 2 < and
    [
        menu [ menu currentButton>> 1 + ] change-currentButton 2drop 
    ] when

    KEY_A is-key-pressed KEY_LEFT is-key-pressed or menu currentButton>> 0 > and
    [
        menu [ menu currentButton>> 1 - ] change-currentButton 2drop 
    ] when ;

:: draw-menu ( -- )
    Menu get :> menu
    menu text>> :> text
    menu currentButton>> menu playerCursor>> draw-buttons

    100 300 get-screen-width 200 - 200 Rectangle boa
    WHITE
    draw-rectangle-rec

    105 305 get-screen-width 210 - 190 Rectangle boa
    BLACK
    draw-rectangle-rec

    text printed-text>> 150 330 40 WHITE draw-text-new-line ;
    ! text printed-text>> 150 330 40 WHITE draw-text ;

: unload-menu ( -- )
    Menu get playerCursor>> unload-texture
    unload-buttons ;