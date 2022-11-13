USING: accessors button combinators formatting indices kernel 
math namespaces player random raylib sequences
strings unicode utils waves ;
IN: menu

INDEX: MENU_NONE MENU_ATTACK MENU_ACT MENU_ITEMS MENU_DIALOGUE MENU_BATTLE ;

TUPLE: item-vars
    { name string }
    { health integer read-only }
    { used boolean } ;
C: <item-vars> item-vars

! This should be an array but hardcoding it like this is easier...
! awful, but easier.
TUPLE: item-list
    { item-index integer }
    { item1 item-vars }
    { item2 item-vars }
    { item3 item-vars }
    { item4 item-vars } ;
C: <item-list> item-list

SYMBOL: Menu
TUPLE: text-vars
    { selected-text-menu integer }
    { selected-text-dialogue integer }
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
    { bubble-speech Texture2D }
    { player-leg Texture2D }
    { player-leg-rect Rectangle }
    { text-box-rect Rectangle }
    { trans-timer float }
    { attack-action-done boolean }
    { text text-vars }
    { items item-list } ;
C: <menu-vars> menu-vars

CONSTANT: MENU_TEXT
{
    "Flag of Sicily but it's a quirky|RPG battle."
    "Smells like Italian stereotypes...|and pizza pie."
    "What's your least favourite|country, Italy or France?|(nobody ever says Italy)"
    ! "When the moon hits your eye|like a big Pizza pie, that's AMORE"
    "Test text 2"
    "Test text 3"
}

CONSTANT: PRE_BATTLE_TEXT_IT
{
    "Lasciami in|pace..." ! Attack 1
    "Non voglio|davvero|essere qui..." ! Attack 2
    "..."
}

CONSTANT: PRE_BATTLE_TEXT_EN
{
    "Leave me|alone..."
    "I really|don't want|to be here..."
    "..."
}

: init-menu ( -- )
    BUTTON_ATTACK ! current button
    MENU_NONE ! current state
    "assets/graphics/The_armoured_triskelion_on_the_flag_of_the_Isle_of_Man.png" load-texture
    "assets/graphics/bubble.png" load-texture
    "assets/graphics/Isle-of-Man-Leg.png" load-texture
    520 -150 106 163 Rectangle boa
    100 300 get-screen-width 200 - 200 Rectangle boa
    0.0
    f
    ! Text {
    0 0 0 0.04 0.04 0 MENU_TEXT nth "" <text-vars>
    ! }
    ! Items {
    0 ! Current item selected (Items)
    "Priddhas an' Herrin'" 40 f <item-vars> "Manx Bonnag" 30 f <item-vars>
    "Prosciutto" 25 f <item-vars> "Pizza pie" 50 f <item-vars>
    <item-list>
    ! }
    <menu-vars> Menu set
    init-buttons
    init-waves ;

:: update-text ( is-dialogue -- )
    Menu get text>> :> text
    text current-character>> text current-text>> length <
    [   
        text delay>> 0 >
        [ text [ get-frame-time - ] change-delay drop ]
        [
            text
            text printed-text>> text current-character>> text current-text>> nth 1string string-append >>printed-text
            [ 1 + ] change-current-character
            dup max-delay>> >>delay drop
        ] if
    ]
    [
        is-dialogue KEY_Z is-key-pressed and
        [ Menu get MENU_BATTLE >>current-state drop ] when
    ] if ;

:: update-menu-none ( boss! -- )
    Menu get :> menu
    Waves get :> wave
    f update-text
    KEY_D is-key-pressed KEY_RIGHT is-key-pressed or menu current-button>> 2 < and
    [ menu [ 1 + ] change-current-button drop ] when

    KEY_A is-key-pressed KEY_LEFT is-key-pressed or menu current-button>> 0 > and
    [ menu [ 1 - ] change-current-button drop ] when

    KEY_Z is-key-pressed
    [
        {
            { 
                [ menu current-button>> BUTTON_ATTACK = ] 
                [ 
                    menu MENU_ATTACK >>current-state drop
                    wave [ 1 + ] change-current-wave f >>change-menu drop
                    boss 100 random 150 + >>damage
                    dup [ boss damage>> - ] change-hp boss!
                    drop
                ] }
            { [ menu current-button>> BUTTON_ACT = ] [ menu MENU_ACT >>current-state drop ] }
            { [ menu current-button>> BUTTON_ITEMS = ] [ menu MENU_ITEMS >>current-state drop ] }
            [ ]
        } cond
    ] when ;

:: update-menu-items ( is-act -- )
    Menu get :> menu
    menu items>> item-index>> :> new-index!

    KEY_D is-key-pressed KEY_RIGHT is-key-pressed or menu items>> item-index>> 2 mod 0 = and
    [ menu items>> item-index>> 1 + new-index! ] when
    KEY_A is-key-pressed KEY_LEFT is-key-pressed or menu items>> item-index>> 2 mod 0 = not and
    [ menu items>> item-index>> 1 - new-index! ] when

    KEY_W is-key-pressed KEY_UP is-key-pressed or menu items>> item-index>> 2 >= and
    [ menu items>> item-index>> 2 - new-index! ] when
    KEY_S is-key-pressed KEY_DOWN is-key-pressed or menu items>> item-index>> 2 < and
    [ menu items>> item-index>> 2 + new-index! ] when

    is-act not is-act new-index 3 < and or
    [ menu items>> new-index >>item-index drop ] when

    KEY_X is-key-pressed
    [ 
        menu MENU_NONE >>current-state
        items>> 0 >>item-index drop
    ] when ;

:: update-menu-attack ( boss! -- )
    boss current-hp>> boss hp>> >
    [ 
        boss
        [ 5 - ] change-current-hp boss!
        boss current-hp>> boss hp>> - 0 <   ! Check if current-hp < hp
        [ boss dup hp>> >>current-hp boss! ] when
    ] when

   
    Menu get
    dup attack-action-done>> 
    [
        dup trans-timer>> 0 >
        [ [ get-frame-time - ] change-trans-timer ]
        [
            MENU_DIALOGUE >>current-state
            dup text>>
            dup selected-text-dialogue>> PRE_BATTLE_TEXT_IT nth >>current-text
            0 >>current-character
            "" >>printed-text
            drop
            520 -150 106 163 Rectangle boa >>player-leg-rect
            f >>attack-action-done
        ] if
        drop
    ]
    [
        dup player-leg-rect>>
        dup y>> 70 <=
        [ [ 500 get-frame-time * + ] change-y >>player-leg-rect ]
        [ drop 1.0 >>trans-timer t >>attack-action-done ] if
        drop
    ] if ;

:: update-menu ( boss! player! -- )
    Menu get :> menu
    {
        { [ menu current-state>> MENU_NONE = ] [ boss update-menu-none ] }
        { [ menu current-state>> MENU_ATTACK = ] [ boss update-menu-attack ] }
        { [ menu current-state>> MENU_ITEMS = ] [ f update-menu-items ] }
        { [ menu current-state>> MENU_ACT = ] [ t update-menu-items ] }
        { [ menu current-state>> MENU_DIALOGUE = ] [ t update-text ] }
        { 
            [ menu current-state>> MENU_BATTLE = ]
            [
                menu text-box-rect>> player update-wave
                menu text-box-rect>> update-player
                Waves get change-menu>>
                [
                    Waves get f >>box-size-changed drop
                    menu
                    MENU_NONE >>current-state
                    dup text>>
                    0 >>current-character
                    "" >>printed-text
                    [ 1 + ] change-selected-text-menu
                    [ 1 + ] change-selected-text-dialogue
                    dup selected-text-menu>> MENU_TEXT nth >>current-text >>text
                    drop
                ] when
            ]
        }
        [ ]
    } cond ;

:: draw-item-name ( index name -- )
    160 :> x-pos!
    330 :> y-pos!
    index 2 mod 0 = [ 560 x-pos! ] unless
    index 2 >= [ 400 y-pos! ] when
    name length 0 > [ name x-pos y-pos 30 WHITE draw-text ] when ;

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

:: draw-menu ( player-hp max-hp boss-current-hp boss-max-hp -- )
    Menu get :> menu
    menu text>> :> text
    menu current-button>> menu player-cursor>> draw-buttons

    menu text-box-rect>> WHITE draw-rectangle-rec
    menu text-box-rect>>
    dup x>> 5 + swap dup y>> 5 + swap dup width>> 10 - swap height>> 10 - Rectangle boa BLACK draw-rectangle-rec

    "Mann" 100 510 30 WHITE draw-text
    ! 350 510 player-hp 30 Rectangle boa GREEN draw-rectangle-rec
    ! 350 510 max-hp 2 * 30 Rectangle boa RED draw-rectangle-rec
    370 505 max-hp 2 * 12 Rectangle boa 109 169 210 255 Color boa draw-rectangle-rec
    370 517 max-hp 2 * 12 Rectangle boa WHITE draw-rectangle-rec
    370 519 player-hp 2 * 4 Rectangle boa BLACK draw-rectangle-rec
    370 525 max-hp 2 * 12 Rectangle boa 109 169 210 255 Color boa draw-rectangle-rec
    player-hp max-hp "HP %d/%d" sprintf 215 507 30 WHITE draw-text

    {
        {
            [ menu current-state>> MENU_NONE = ]
            [ text printed-text>> 150 330 40 WHITE draw-text-new-line ]
        }
        {
            [ menu current-state>> MENU_ATTACK = ]
            [
                250 20 boss-max-hp 2 / 40 Rectangle boa BLACK draw-rectangle-rec
                250 20 boss-current-hp 2 / 40 Rectangle boa GREEN draw-rectangle-rec
                menu player-leg>>
                0 0 106 163 Rectangle boa
                menu player-leg-rect>>
                53 81.5 <Vector2>
                45
                WHITE
                draw-texture-pro
            ]
        }
        {
            [ menu current-state>> MENU_ITEMS = menu current-state>> MENU_ACT = or ]
            [
                menu items>> :> items
                menu current-state>> MENU_ITEMS =
                [
                    0 items item1>> name>> draw-item-name
                    1 items item2>> name>> draw-item-name
                    2 items item3>> name>> draw-item-name
                    3 items item4>> name>> draw-item-name
                ]
                [
                    0 "Check" draw-item-name
                    1 "Tease" draw-item-name
                    2 "Flirt" draw-item-name
                ] if

                menu player-cursor>>
                0 0 menu player-cursor>> width>> menu player-cursor>> height>> Rectangle boa
                items item-index>> dup 2 mod 0 = 110 515 ? swap 2 >= 400 330 ? 40 40 Rectangle boa
                0 0 <Vector2>
                0.0
                WHITE
                draw-texture-pro
            ]
        }
        {
            [ menu current-state>> MENU_DIALOGUE = ]
            [ 
                menu bubble-speech>>
                0 0 243 233 Rectangle boa
                590 55 243
                get-font-default text current-text>> 30 1 measure-text-ex y>>
                text current-text>> "|" count-char 1 + *
                20 +
                Rectangle boa                
                0 0 <Vector2> ! 121.5 151.5 <Vector2>
                0.0
                WHITE
                draw-texture-pro
                text printed-text>> 630 60 30 BLACK draw-text-new-line
            ]
        }
        {
            [ menu current-state>> MENU_BATTLE = ]
            [
                draw-player
                draw-waves
            ]
        }
        [ ]
    } cond ;

: unload-menu ( -- )
    Menu get
    dup player-cursor>> unload-texture
    player-leg>> unload-texture
    unload-buttons ;