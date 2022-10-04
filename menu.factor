USING: accessors button combinators index indices kernel math namespaces
raylib sequences strings unicode ;
IN: menu

INDEX: MENU_NONE MENU_ATTACK MENU_ACT MENU_ITEMS ;

TUPLE: item-vars
    { name string }
    { health integer read-only }
    { used boolean } ;
C: <item-vars> item-vars

TUPLE: item-list
    { item-index integer }
    { item1 item-vars }
    { item2 item-vars }
    { item3 item-vars }
    { item4 item-vars } ;
C: <item-list> item-list

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
    { current-button integer }
    { current-state integer }
    { player-cursor Texture2D }
    { text text-vars }
    { items item-list } ;
C: <menu-vars> menu-vars

CONSTANT: MENU_TEXT
    { 
        "Flag of Sicily but it's a quirky|RPG battle."
        "Smells like Italian stereotypes...|and pizza."
        "Test text 2"
        "Test text 3"
    }

: init-menu ( -- )
    BUTTON_ATTACK ! current button
    MENU_NONE ! current state
    "assets/graphics/The_armoured_triskelion_on_the_flag_of_the_Isle_of_Man.png" load-texture
    ! Text {
    0 0 0.04 0.04 0 MENU_TEXT nth "" <text-vars>
    ! }
    ! Items {
    0 ! Current item selected (Items)
    "Priddhas an' Herrin'" 40 f <item-vars> "Manx Bonnag" 30 f <item-vars>
    "Prosciutto" 25 f <item-vars> "Pizza pie" 50 f <item-vars>
    <item-list>
    ! }
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
        [ text dup delay>> get-frame-time - >>delay drop ]
        [
            text
            text printed-text>> text current-character>> text current-text>> nth 1string string-append
            >>printed-text
            dup current-character>> 1 + >>current-character
            dup max-delay>> >>delay drop
        ] if
    ] when ;

:: draw-item-name ( index name -- )
    160 :> x-pos!
    330 :> y-pos!
    index 2 mod 0 = not [ 560 x-pos! ] when
    index 2 >= [ 400 y-pos! ] when
    name length 0 > [ name x-pos y-pos 30 WHITE draw-text ] when ;

:: update-menu-none ( -- )
    Menu get :> menu
    update-text
    KEY_D is-key-pressed KEY_RIGHT is-key-pressed or menu current-button>> 2 < and
    [
        menu dup current-button>> 1 + >>current-button drop
    ] when

    KEY_A is-key-pressed KEY_LEFT is-key-pressed or menu current-button>> 0 > and
    [
        menu dup current-button>> 1 - >>current-button drop
    ] when

    KEY_Z is-key-pressed
    [
        {
            { 
                [ menu current-button>> BUTTON_ITEMS = ]
                [ menu MENU_ITEMS >>current-state drop ]
            }
            [ ]
        } cond
    ] when ;

:: update-menu-items ( -- )
    Menu get :> menu

    KEY_D is-key-pressed KEY_RIGHT is-key-pressed or menu items>> item-index>> 2 mod 0 = and
    [ menu items>> dup item-index>> 1 + >>item-index drop ] when
    KEY_A is-key-pressed KEY_LEFT is-key-pressed or menu items>> item-index>> 2 mod 0 = not and
    [ menu items>> dup item-index>> 1 - >>item-index drop ] when

    KEY_W is-key-pressed KEY_UP is-key-pressed or menu items>> item-index>> 2 >= and
    [ menu items>> dup item-index>> 2 - >>item-index drop ] when
    KEY_S is-key-pressed KEY_DOWN is-key-pressed or menu items>> item-index>> 2 < and
    [ menu items>> dup item-index>> 2 + >>item-index drop ] when

    KEY_X is-key-pressed [ menu MENU_NONE >>current-state drop ] when ;

:: update-menu ( -- )
    Menu get :> menu
    {
        { [ menu current-state>> MENU_NONE = ] [ update-menu-none ] }
        { [ menu current-state>> MENU_ITEMS = ] [ update-menu-items ] }
        [ ]
    } cond ;

:: draw-menu ( -- )
    Menu get :> menu
    menu text>> :> text
    menu current-button>> menu player-cursor>> draw-buttons

    100 300 get-screen-width 200 - 200 Rectangle boa
    WHITE
    draw-rectangle-rec

    105 305 get-screen-width 210 - 190 Rectangle boa
    BLACK
    draw-rectangle-rec

    {
        {
            [ menu current-state>> MENU_NONE = ]
            [ text printed-text>> 150 330 40 WHITE draw-text-new-line ]
        }
        {
            [ menu current-state>> MENU_ITEMS = ]
            [
                menu items>> :> items
                0 items item1>> name>> draw-item-name
                1 items item2>> name>> draw-item-name
                2 items item3>> name>> draw-item-name
                3 items item4>> name>> draw-item-name

                menu player-cursor>>
                0 0 menu player-cursor>> width>> menu player-cursor>> height>> Rectangle boa
                items item-index>> dup 2 mod 0 = 110 515 ? swap 2 >= 400 330 ? 40 40 Rectangle boa
                0 0 <Vector2>
                0.0
                WHITE
                draw-texture-pro
            ]
        }
        [ ]
    } cond ;

: unload-menu ( -- )
    Menu get player-cursor>> unload-texture
    unload-buttons ;