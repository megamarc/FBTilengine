' FBTilengine - FreeBasic binding for Tilengine - 2D retro graphics engine
' 2018 MyTDT-MySoft
'
' Screen composition using built-in SDL2 window

#include "windows.bi"
#include "Tilengine.bi"

dim as integer iFrames
dim shared as TLN_Bitmap bmBack, bmWall

const lMaxSprites = 1
const lMaxAnimations = 1

enum
	lOverlay
	lFore
	lMaxLayers
end enum

TLN_Init(320, 240, lMaxLayers, lMaxSprites, lMaxAnimations)
TLN_SetLoadPath("assets/_png")
bmBack=TLN_LoadBitmap("background.png")
bmWall=TLN_LoadBitmap("wall.png")

TLN_CreateWindow (NULL, CWF_S2 or CWF_NEAREST or CWF_VSYNC)
TLN_DisableCRTEffect()

TLN_SetBGBitmap(bmBack)
TLN_SetLayerBitmap( lOverlay , bmWall )
TLN_SetLayerBlendMode( lOverlay , BLEND_MIX75 , 100 )

dim as integer iWallX,iWallY, iSpeedX=1,iSpeedY=1, iOff=0
dim as longint llOldTicks, llFrameTicks
const MaxOffX = 160-64 , MaxOffY = 120-64

while (TLN_ProcessWindow())

	const TPS = 6000, cFPS = 60
	#define Ticks() (TLN_GetTicks()*clngint(6))

	while abs(Ticks()-llOldTicks) > (TPS\cFPS)

		TLN_SetLayerScaling( lOverlay , 1+(iOFF/640) , 1+(iOFF/480) )
		TLN_SetLayerPosition( lOverlay , iOff , (iOff*120)\160 )

		iOff += 1
		if iOff > 160 then iOff=160
        iFrames += 1
        llOldTicks += (TPS\cFPS)

	wend

	TLN_DrawFrame(iFrames)

wend