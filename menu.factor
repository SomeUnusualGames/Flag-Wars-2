USING: accessors alien.enums button kernel math namespaces raylib ;
IN: menu

SYMBOL: Menu
TUPLE: menu-vars
    { currentButton integer } 
    { playerCursor Texture2D } ;
C: <menu-vars> menu-vars

: init-menu ( -- )
    ATTACK enum>number
    "assets/graphics/The_armoured_triskelion_on_the_flag_of_the_Isle_of_Man.png" load-texture
    <menu-vars> Menu set
    init-buttons ;

:: update-menu ( -- )
    Menu get :> menu
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
    menu currentButton>> menu playerCursor>> draw-buttons ;

: unload-menu ( -- )
    Menu get playerCursor>> unload-texture
    unload-buttons ;