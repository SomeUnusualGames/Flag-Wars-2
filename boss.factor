USING: accessors classes.struct kernel math math.constants math.functions namespaces raylib ;
IN: boss

SYMBOL: Boss
TUPLE: boss-legs
    { legsTexture Texture2D }
    { sprite Rectangle }
    { angle float } ;
C: <boss-legs> boss-legs

TUPLE: boss-head
    { headTexture Texture2D }
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
    "assets/graphics/Sicily_legs.png" 500 200 210 226 Rectangle boa
    "assets/graphics/Sicily_head.png" 500 200 217 226 Rectangle boa
    new-boss Boss set ;

:: update-boss ( -- )
    Boss get :> boss
    boss legs>> [ boss legs>> angle>> 40 get-frame-time * - ] change-angle 2drop
    boss head>> [ 5 1.5 get-time * sin * ] change-angle 2drop ;

:: draw-boss ( -- )
    Boss get :> boss
    boss legs>> legsTexture>>
    0 0 210 226 Rectangle boa
    boss legs>> sprite>>
    105 113 <Vector2>
    boss legs>> angle>>
    WHITE draw-texture-pro

    boss head>> headTexture>>
    0 0 217 226 Rectangle boa
    boss head>> sprite>>
    108.5 113 <Vector2>
    boss head>> angle>>
    WHITE draw-texture-pro ;

:: unload-boss ( -- )
    Boss get :> boss
    boss legs>> legsTexture>> unload-texture
    boss head>> headTexture>> unload-texture ;