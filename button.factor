USING: accessors classes.struct index kernel
math namespaces raylib strings ;
IN: button

SYMBOL: ButtonList
INDEX: ATTACK ACT ITEMS ;

TUPLE: button-vars
    { type integer }
    { name string }
    { iconWidth integer }
    { rectangle Rectangle }
    { texture Texture2D } ;
C: <button-vars> button-vars

TUPLE: button-list
    { attackButton button-vars }
    { actButton button-vars }
    { itemButton button-vars } ; 
C: <button-list> button-list

: new-button ( type rect texture selected -- button ) <button-vars> ; inline

: create-buttons ( -- button-list )
    ! Attack {
        ATTACK
        "Attack"
        25
        130 550 240 80 Rectangle boa
        "assets/graphics/Sri-Lanka-Sword.png" load-texture
        <button-vars>
    ! }
    ! Act {
        ACT
        "Act"
        40
        370 550 240 80 Rectangle boa
        "assets/graphics/Rwanda-R-1962-2001.png" load-texture
        <button-vars>
    ! }
    ! Items {
        ITEMS
        "Items"
        70
        570 550 240 80 Rectangle boa
        "assets/graphics/Switzerland.png" load-texture
        <button-vars>
    ! }
    <button-list> ;

: init-buttons ( -- ) create-buttons ButtonList set ; inline

:: draw-button ( button rect-offset current-button player-cursor -- )
    button rectangle>> width>> 6 + :> rect-width
    button rectangle>> x>> 3 -
    button rectangle>> y>> 3 -
    rect-width rect-offset - 6 +
    button rectangle>> height>> 6 +
    Rectangle boa
    BLACK
    draw-rectangle-rec
    
    button rectangle>> x>>
    button rectangle>> y>>
    rect-width rect-offset -
    button rectangle>> height>>
    Rectangle boa
    120 120 120 255 Color boa
    draw-rectangle-rec

    button texture>> :> texture

    button type>> current-button =
    [
        player-cursor
        0 0 player-cursor width>> player-cursor height>> Rectangle boa
        button rectangle>> x>> button name>> 40 measure-text + 30 +
        button rectangle>> y>> 15 + 40 40 Rectangle boa
        0 0 <Vector2>
        0.0
        WHITE
        draw-texture-pro
    ]
    [
        texture
        0 0 texture width>> texture height>> Rectangle boa
        button rectangle>> x>> button name>> 40 measure-text + 30 +
        button rectangle>> y>> 5 + button iconWidth>> button rectangle>> height>> 10 - Rectangle boa
        0 0 <Vector2>
        0.0
        WHITE
        draw-texture-pro
    ] if

    button name>>
    button rectangle>> x>> 10 +
    button rectangle>> y>> 15 +
    40
    WHITE
    draw-text ;

:: draw-buttons ( current-button player-cursor -- )
    ButtonList get :> buttonList
    buttonList attackButton>> 30 current-button player-cursor draw-button
    buttonList actButton>> 80 current-button player-cursor draw-button
    buttonList itemButton>> 20 current-button player-cursor draw-button ;

:: unload-buttons ( -- )
    ButtonList get :> buttonList
    buttonList attackButton>> texture>> unload-texture
    buttonList actButton>> texture>> unload-texture
    buttonList itemButton>> texture>> unload-texture ;

