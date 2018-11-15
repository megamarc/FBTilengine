' FBTilengine - FreeBasic binding for Tilengine - 2D retro graphics engine
' 2018 MyTDT-MySoft
'
' Screen composition using the built-in SDL2 window

#include "Tilengine.bi"

#define ScrWIDTH	320
#define ScrHEIGHT	240

enum Sprites
	SprPlayer
	MAX_SPRITE
end enum

enum AllSprites
	DinoU , DinoU1 , DinoU2
	DinoD , DinoD1 , DinoD2
	DinoL , DinoL1 , DinoL2
	DinoR , DinoR1 , DinoR2
end enum

enum Animations
    AnimOcean
    MAX_ANIMATION
end enum

enum
	LayerFore
	LayerBack
	MAX_LAYER
end enum

' Begin of main program *******************************************************

TLN_Init(ScrWIDTH, ScrHEIGHT, MAX_LAYER,MAX_SPRITE,MAX_ANIMATION)

dim shared as TLN_Bitmap bmBackground , bmSprites, bmMist
TLN_SetLoadPath("assets/_png")
bmBackground = TLN_LoadBitmap("background.png")
bmSprites = TLN_LoadBitmap("sprites.png")
bmMist = TLN_LoadBitmap("mist2.png")

' Create Sprites
dim as TLN_SpriteData aDino(11)
for N as integer = 0 to ubound(aDino)
	with aDino(N)
		.x = N*64 : .y = 5*64
		.w = 64 : .h = 64
    end with
next N
var DinoSprites = TLN_CreateSpriteset( bmSprites , @aDino(0) , ubound(aDino)+1 )

TLN_CreateWindow (null, CWF_S2 or CWF_NEAREST or CWF_VSYNC)
TLN_DisableCRTEffect()

TLN_DisableBGColor ()
TLN_SetBgBitmap( bmBackground )

' palette animation of background
dim as TLN_ColorStrip OceanStrips(...) = { _
    (8 ,  54 , ( 63-54 ) , 1 ) , _
    (8 ,  67 , ( 79-67 ) , 1 ) , _
    (8 ,  83 , ( 96-83 ) , 1 ) , _
    (8 ,  99 , (111-99 ) , 1 ) , _
    (8 , 115 , (127-115) , 1 ) }

var BgPal = TLN_GetBitmapPalette( bmBackground )
var OceanCycle = TLN_CreateCycle(null,5,@OceanStrips(0))
TLN_SetPaletteAnimation( AnimOcean , BgPal , OceanCycle , true )

' mist layer
const MistRows = 240\16, MistCols = 640\16
const TilesInBmp = MistRows*MistCols
static as TLN_TileAttributes aMistAtt( TilesInBmp-1 )
static as Tile aMistMap( TilesInBmp-1 )
for N as integer = 0 to TilesInBmp-1
	aMistMap(N).index = N+1
	aMistMap(N).flags = 0 'FLAG_PRIORITY
	aMistAtt(N).type = 1
	aMistAtt(N).priority = false
next N

var MistPit = TLN_GetBitmapPitch( bmMist )
var MistPal = TLN_GetBitmapPalette( bmMist )
var MistSet = TLN_CreateTileset(TilesInBmp,16,16,MistPal,0,@aMistAtt(0))
var MistMap = TLN_CreateTilemap(MistRows,MistCols,@aMistMap(0),&hFF8844,MistSet)

for iY as integer = 0 to MistRows-1
	for iX as integer = 0 to MistCols-1
		var pTileSrc = TLN_GetBitmapPtr( bmMist , iX*16 , iY*16 )
		TLN_SetTilesetPixels( MistSet , iY*MistCols+iX+1 , pTileSrc , MistPit )
    next iX
next iY

'TLN_SetLayerBitmap( LayerFore , bmMist )
TLN_SetLayer( LayerFore , MistSet , MistMap )
TLN_SetLayerBlendMode( LayerFore , BLEND_ADD , 0 )

'sprite
TLN_ConfigSprite( sprPlayer , DinoSprites , 0 ) 'FLAG_FLIPX
TLN_SetSpritePicture( sprPlayer , DinoR )
TLN_SetSpriteScaling( sprPlayer , 2 , 2 )

dim as integer iFrameNum = 0
dim as integer iMistX, iMistY, iDinoX

dim as longint llOldTicks, llFrameTicks
const TPS = 6000, cFPS = 120
#define Ticks() (TLN_GetTicks()*clngint(6))

' main loop
while (TLN_ProcessWindow())

	if abs(Ticks()-llOldTicks) > TPS then llOldTicks = Ticks()
	while abs(Ticks()-llOldTicks) > (TPS\cFPS)
		if (iFrameNum and 3)=0 then
			iMistX -= 1
			TLN_SetSpritePicture( sprPlayer , DinoR+((iFrameNum\8) mod 2) )
        end if
		if (iFrameNum and 7)=0 then iMistY -= 1

		TLN_SetLayerPosition( LayerFore , iMistX , iMistY )
		TLN_SetSpritePosition( sprPlayer , iDinoX-64 , 140 )
		iDinoX = (iDinoX+1) mod (320+128)

		iFrameNum += 1 : llOldTicks += (TPS\cFPS)
    wend

	TLN_DrawFrame(iFrameNum)

wend

' End of main program *********************************************************
