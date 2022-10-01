USING: accessors alien.syntax alien.enums classes.struct kernel
math namespaces raylib strings ;
IN: button

SYMBOL: ButtonList
ENUM: ButtonType
    ATTACK
    ACT
    ITEMS ;

TUPLE: button-vars
    { buttonType integer }
    { name string }
    { iconWidth integer }
    { rectangle Rectangle }
    { texture Texture2D }
    { selected boolean } ;
C: <button-vars> button-vars

TUPLE: button-list
    { attackButton button-vars }
    { actButton button-vars }
    { itemButton button-vars } ; 
C: <button-list> button-list

: new-button ( type rect texture selected -- button ) <button-vars> ; inline

: create-buttons ( -- button-list )
    ! Attack {
        ATTACK enum>number
        "Attack"
        25
        130 500 240 80 Rectangle boa
        "assets/graphics/Sri-Lanka-Sword.png" load-texture
        t <button-vars>
    ! }
    ! Act {
        ACT enum>number
        "Act"
        40
        370 500 240 80 Rectangle boa
        "assets/graphics/Rwanda-R-1962-2001.png" load-texture
        f <button-vars>
    ! }
    ! Items {
        ITEMS enum>number
        "Items"
        70
        570 500 240 80 Rectangle boa
        "assets/graphics/Switzerland.png" load-texture
        f <button-vars>
    ! }
    <button-list> ;

: init-buttons ( -- ) create-buttons ButtonList set ; inline

:: draw-button ( button rect-offset -- )
    button rectangle>> width>> 6 + :> rect-width
    button rectangle>> x>> 3 -
    button rectangle>> y>> 3 -
    rect-width rect-offset + 6 +
    button rectangle>> height>> 6 +
    Rectangle boa
    BLACK
    draw-rectangle-rec
    
    button rectangle>> x>>
    button rectangle>> y>>
    rect-width rect-offset +
    button rectangle>> height>>
    Rectangle boa
    120 120 120 255 Color boa
    draw-rectangle-rec

    button texture>> :> texture

    texture
    0 0 texture width>> texture height>> Rectangle boa
    button rectangle>> x>> button name>> 40 measure-text + 30 +
    button rectangle>> y>> 5 + button iconWidth>> button rectangle>> height>> 10 - Rectangle boa
    0 0 Vector2 boa
    0.0
    WHITE
    draw-texture-pro

    button name>>
    button rectangle>> x>> 10 +
    button rectangle>> y>> 15 +
    40
    WHITE
    draw-text ;

:: draw-buttons ( -- )
    ButtonList get :> buttonList
    buttonList attackButton>> -30 draw-button
    buttonList actButton>> -80 draw-button
    buttonList itemButton>> -20 draw-button ;


