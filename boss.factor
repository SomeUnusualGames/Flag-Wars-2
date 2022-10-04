USING: accessors classes.struct kernel math math.constants math.functions namespaces raylib ;
IN: boss

SYMBOL: Boss
TUPLE: boss-legs
    { legs-texture Texture2D }
    { sprite Rectangle }
    { angle float } ;
C: <boss-legs> boss-legs

TUPLE: boss-head
    { head-texture Texture2D }
    { sprite Rectangle }
    { angle float } ;
C: <boss-head> boss-head

TUPLE: boss-vars
    { legs boss-legs }
    { head boss-head } ;
C: <boss-vars> boss-vars

:: new-boss ( legs-path legs-sprite head-path head-sprite -- boss )
    legs-path load-texture
    legs-sprite
    0.0 <boss-legs>
    head-path load-texture
    head-sprite
    0.0 <boss-head>
    <boss-vars> ;

: init-boss ( -- )
    "assets/graphics/Sicily_legs.png" 500 150 210 226 Rectangle boa
    "assets/graphics/Sicily_head.png" 500 150 217 226 Rectangle boa
    new-boss Boss set ;

: update-boss ( -- )
    Boss get
    dup legs>> dup angle>> 40 get-frame-time * - >>angle drop
    dup head>> 5 1.5 get-time * sin * >>angle 2drop ;

:: draw-boss ( -- )
    Boss get :> boss
    boss legs>> legs-texture>>
    0 0 210 226 Rectangle boa
    boss legs>> sprite>>
    105 113 <Vector2>
    boss legs>> angle>>
    WHITE draw-texture-pro

    boss head>> head-texture>>
    0 0 217 226 Rectangle boa
    boss head>> sprite>>
    108.5 113 <Vector2>
    boss head>> angle>>
    WHITE draw-texture-pro ;

:: unload-boss ( -- )
    Boss get :> boss
    boss legs>> legs-texture>> unload-texture
    boss head>> head-texture>> unload-texture ;