USING: accessors classes.struct index indices kernel
math namespaces raylib strings ;
IN: button

SYMBOL: ButtonList
INDEX: BUTTON_ATTACK BUTTON_ACT BUTTON_ITEMS ;

TUPLE: button-vars
    { type integer }
    { name string }
    { icon-width integer }
    { rectangle Rectangle }
    { texture Texture2D } ;
C: <button-vars> button-vars

TUPLE: button-list
    { attack-button button-vars }
    { act-button button-vars }
    { item-button button-vars } ; 
C: <button-list> button-list

: new-button ( type rect texture selected -- button ) <button-vars> ; inline

: create-buttons ( -- button-list )
    ! Attack {
        BUTTON_ATTACK
        "Attack"
        25
        130 550 240 80 Rectangle boa
        "assets/graphics/Sri-Lanka-Sword.png" load-texture
        <button-vars>
    ! }
    ! Act {
        BUTTON_ACT
        "Act"
        40
        370 550 240 80 Rectangle boa
        "assets/graphics/Rwanda-R-1962-2001.png" load-texture
        <button-vars>
    ! }
    ! Items {
        BUTTON_ITEMS
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
        button rectangle>> y>> 5 + button icon-width>> button rectangle>> height>> 10 - Rectangle boa
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
    buttonList attack-button>> 30 current-button player-cursor draw-button
    buttonList act-button>> 80 current-button player-cursor draw-button
    buttonList item-button>> 20 current-button player-cursor draw-button ;

:: unload-buttons ( -- )
    ButtonList get :> buttonList
    buttonList attack-button>> texture>> unload-texture
    buttonList act-button>> texture>> unload-texture
    buttonList item-button>> texture>> unload-texture ;

