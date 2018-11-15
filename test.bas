#include "Tilengine.bi"

#define ScrWIDTH	320
#define ScrHEIGHT	240

'*** this just assign names to our layers       ***
'*** those are not used yet as we have no tiles ***
enum
	LAYER_OVERLAY
    LAYER_FOREGROUND	
	MAX_LAYER
end enum

'***        select the base path for the assets      ***
'*** so we wont need this (as default is app folder) ***
TLN_SetLoadPath("assets/_png")

'*** initializing the screen ***
TLN_Init(ScrWIDTH, ScrHEIGHT, MAX_LAYER,1,3)

'load our bitamps
dim shared as TLN_Bitmap bmBackground , bmSprites , bmMist
bmBackground = TLN_LoadBitmap("background.png")
bmSprites = TLN_LoadBitmap("sprites.png")
bmMist = TLN_LoadBitmap("mist.png")

'*** Create the window... and disable the CRT effect ***
'*** the window is created with 2x scale...          ***
'*** and "nearest" filter (no resize blur)           ***
TLN_CreateWindow (null, CWF_S2 or CWF_NEAREST)
TLN_DisableCRTEffect()

'we will use the background as an image...
'while tiled games usually have them as a "color"
'our bitmap is 320x240 just like our Screen width
'otherwise we would need to scale it to cover everything
TLN_DisableBGColor ()
TLN_SetBGBitmap( bmBackground )
TLN_SetLayerBitmap( LAYER_OVERLAY , bmMist ) 
TLN_SetLayerBlendMode( LAYER_OVERLAY , BLEND_MIX25 , 0 )

'set mist layer

'*** this is the main loop ***
'*** TLN_ProcessWindow() process the events for the engine   ***
'*** it reads pending events like INPUT events or quit event ***
dim as integer iFrameNum = 0, iMistX, iMistY
dim as integer iMistWid = TLN_GetBitmapWidth( bmMist )
dim as integer iMistHei = TLN_GetBitmapHeight( bmMist )

dim as TLN_Affine affine : affine.sx = 1 : affine.sy = 1
dim as longint llOldTicks, llFrameTicks, llLimitTicks
dim as integer iFPS
const TPS = 6000, cEngineFPS = 30, cLimitFps = 10

#define Ticks() (TLN_GetTicks()*clngint(6))
while (TLN_ProcessWindow())
    
    if abs(Ticks()-llFrameTicks) > TPS then llOldTicks = Ticks()
    if abs(Ticks()-llFrameTicks) > TPS then
        TLN_SetWindowTitle("TileEngine: " & iFPS & " fps")
        iFPS = 0 : llFrameTicks=Ticks()
    end if
    
    do
        if abs(Ticks()-llOldTicks) < (TPS\cEngineFPS) then exit do
        
        TLN_SetLayerPosition( LAYER_OVERLAY , iMistX , iMistY )
        TLN_SetLayerAffineTransform(LAYER_OVERLAY, @affine)
        affine.angle += .05
        
        if (iFrameNum and 1) then
            iMistX = (iMistX+1) mod iMistWid
            iMistY = (iMistY+1) mod iMistHei
        end if
        
        iFrameNum += 1 : llOldTicks += (TPS\cEngineFPS)    
    loop
    
    '*** draws the frame... "iFrameNum" is for the engine    ***
    '*** to know in which frame an animated sprite/tile is   ***
    '*** as those can be handled automatically by the engine ***  
    TLN_DrawFrame(iFrameNum) : iFps += 1
    
wend
