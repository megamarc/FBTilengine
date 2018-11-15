' FBTilengine - FreeBasic binding for Tilengine - 2D retro graphics engine
' 2018 MyTDT-MySoft
'
' Screen composition using FreeBasic's own FBgfx subsystem

#include "TilengineFBgfx.bas"

#define ScrWIDTH	320
#define ScrHEIGHT	240

enum Sprites
    MAX_SPRITE
end enum

enum Animations
    AnimOcean
    MAX_ANIMATION
end enum

enum Layers
	LayerOver
    LayerFore
	LayerBack
	MAX_LAYER
end enum

function CreateTileSetFromBitmap( pBm as TLN_Bitmap , iWid as integer , iHei as integer , sp as TLN_SequencePack=0 , att as TLN_TileAttributes ptr=0 ) as TLN_TileSet

    var BmpRows = TLN_GetBitmapHeight(pBm), BmpCols = TLN_GetBitmapWidth(pBm)
    if iWid=0 or iHei=0 then return 0
    if (iWid and 7) orelse (iHei and 7) then return 0
    if (BmpRows mod iHei) orelse (BmpCols mod iWid) then return 0

    BmpRows \= iHei : BmpCols \= iWid
    var TilesInBmp = BmpRows*BmpCols
    var BmpPit = TLN_GetBitmapPitch( pBm )
    var BmpPal = TLN_GetBitmapPalette( pBm )
    var BmpSet = TLN_CreateTileset(TilesInBmp,iWid,iHei,BmpPal,sp,att)
    if BmpSet = 0 then return 0

    for iY as integer = 0 to BmpRows-1
        for iX as integer = 0 to BmpCols-1
            var pTileSrc = TLN_GetBitmapPtr( pBm , iX*iWid , iY*iHei )
            TLN_SetTilesetPixels( BmpSet , iY*BmpCols+iX+1 , pTileSrc , BmpPit )
        next iX
    next iY

    return BmpSet

end function

TLN_Init(ScrWIDTH, ScrHEIGHT, MAX_LAYER,MAX_SPRITE,MAX_ANIMATION)

dim shared as TLN_Bitmap bmBackground , bmSprites, bmMist
TLN_SetLoadPath ("assets/_png")
bmBackground = TLN_LoadBitmap("background.png")
bmMist = TLN_LoadBitmap("mist.png")
bmSprites = TLN_LoadBitmap("sprites.png")

TLN_DisableCRTEffect()

if TLN_CreateWindow (null, CWF_S2 or CWF_NEAREST)=0 then 'or CWF_VSYNC
    printf(!"Create Window Failed: '%s'\r\n",TLN_GetErrorString(TLN_GetLastError()))
    sleep : end
end if
TLN_DisableBGColor ()
TLN_SetBgBitmap( bmBackground )

'palette animation of background
dim as TLN_ColorStrip OceanStrips(...) = { _
    (8 ,  54 , ( 63-54 ) , 1 ) , _
    (8 ,  67 , ( 79-67 ) , 1 ) , _
    (8 ,  83 , ( 96-83 ) , 1 ) , _
    (8 ,  99 , (111-99 ) , 1 ) , _
    (8 , 115 , (127-115) , 1 ) }

var BgPal = TLN_GetBitmapPalette( bmBackground )
var OceanCycle = TLN_CreateCycle(null,5,@OceanStrips(0))
TLN_SetPaletteAnimation( AnimOcean , BgPal , OceanCycle , true )

'mist layer

static as Tile TilePlayer(63)
var PlayerSet = CreateTileSetFromBitmap( bmSprites , 64 , 64 )
var PlayerMap = TLN_CreateTilemap( 8 , 8 , @TilePlayer(0) , 0, PlayerSet )
TLN_SetLayer(LayerFore, PlayerSet, PlayerMap)
TLN_SetLayerScaling( LayerFore, 1 , 1 )

TLN_SetLayerBitmap( LayerOver , bmMist )
TLN_SetLayerBlendMode( LayerOver , BLEND_MIX25 , 0 )

dim as integer iFrameNum = 0
dim as integer iMistX, iMistY, iPlayerX, iPlayerRow

dim as longint llOldTicks, llFrameTicks
const TPS = 6000, cFPS = 60
#define Ticks() (TLN_GetTicks()*clngint(6))

while (TLN_ProcessWindow())

    if abs(Ticks()-llOldTicks) > TPS then llOldTicks = Ticks()
    while abs(Ticks()-llOldTicks) > (TPS\cFPS)

        var iSpec = (iPlayerX > ((ScrWidth\2)+(128-64))) and (iPlayerX < ((ScrWidth\2)+(128)))

        if (iFrameNum and 3)=0 then
            iMistX -= 1
            var iTile = iPlayerRow*12+iif(iSpec,11,10)+((iFrameNum\16) and 1)
            TLN_SetTilemapTile( PlayerMap , 0 , 0 , @Type<Tile>(iTile,0) )
            TLN_SetLayer(LayerFore, PlayerSet, PlayerMap)
        end if
        if (iFrameNum and 7)=0 then iMistY -= 1

        TLN_SetLayerPosition( LayerOver , iMistX , iMistY )

        TLN_SetLayerPosition( LayerFore , -(iPlayerX-128) , -160+sin(iFrameNum/64)*8 )

        if iSpec=0 orelse (iFrameNum and 1) then iPlayerX += 1

        if iPlayerX >= (ScrWIDTH+128) then
            iPlayerX -= (ScrWIDTH+128)
            iPlayerRow = (iPlayerRow+1) mod 14
        end if

        iFrameNum += 1 : llOldTicks += (TPS\cFPS)
    wend

    TLN_DrawFrame(iFrameNum)

wend
