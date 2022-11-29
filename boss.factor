USING: accessors classes.struct combinators kernel math
math.constants math.functions namespaces raylib ;
IN: boss

SYMBOL: Boss
TUPLE: boss-legs
    { legs-texture Texture2D }
    { sprite Rectangle }
    { angle float } ;
C: <boss-legs> boss-legs

TUPLE: boss-head
    { head-texture Texture2D }
    { head-red-texture Texture2D }
    { head-mad-texture Texture2D }
    { sprite Rectangle }
    { angle float } ;
C: <boss-head> boss-head

TUPLE: boss-vars
    { hp integer }
    { current-hp integer }
    { max-hp integer read-only }
    { damage integer }
    { legs boss-legs }
    { head boss-head }
    { alpha integer } ;
C: <boss-vars> boss-vars

:: new-boss ( legs-path legs-sprite head-path head-path-red head-path-mad head-sprite -- boss )
    999 999 999
    0
    legs-path load-texture
    legs-sprite
    0.0 <boss-legs>
    head-path load-texture
    head-path-red load-texture
    head-path-mad load-texture
    head-sprite
    0.0 <boss-head>
    255 <boss-vars> ;

: init-boss ( -- )
    "assets/graphics/Sicily_legs.png" 500 150 210 226 Rectangle boa
    "assets/graphics/Sicily_head.png" "assets/graphics/Sicily_head_red.png" "assets/graphics/Sicily_head_mad.png"
    500 150 217 226 Rectangle boa
    new-boss Boss set ;

: update-boss ( -- )
    Boss get
    dup legs>> dup angle>> 40 get-frame-time * - >>angle drop
    dup head>> 5 1.5 get-time * sin * >>angle 2drop ;

:: draw-boss ( draw-red draw-angry -- )
    Boss get :> boss
    boss legs>> legs-texture>>
    0 0 210 226 Rectangle boa
    boss legs>> sprite>>
    105 113 <Vector2>
    boss legs>> angle>>
    255 255 255 boss alpha>> Color boa
    draw-texture-pro

    {
        { [ draw-red ] [ boss head>> head-red-texture>> ] }
        { [ draw-angry ] [ boss head>> head-mad-texture>> ] }
        [ boss head>> head-texture>> ]
    } cond
    0 0 217 226 Rectangle boa
    boss head>> sprite>>
    108.5 113 <Vector2>
    boss head>> angle>>
    255 255 255 boss alpha>> Color boa
    draw-texture-pro ;

:: unload-boss ( -- )
    Boss get :> boss
    boss legs>> legs-texture>> unload-texture
    boss head>>
    dup head-texture>> unload-texture
    dup head-red-texture>> unload-texture
    head-mad-texture>> unload-texture ;