#include "Tilenginefbgfx.bas"

#define ScrWIDTH	400
#define ScrHEIGHT	240

' layers 
enum
	LAYER_FOREGROUND
	LAYER_BACKGROUND
	MAX_LAYER
end enum

dim as TLN_SequencePack sp
dim as TLN_Sequence seq_walking
dim as TLN_Spriteset spriteset
dim as TLN_Tilemap tilemaps(MAX_LAYER-1)
dim as integer frame = 0
dim as integer player_x = -16
dim as integer player_y = 160

' basic setup 
TLN_Init (ScrWIDTH, ScrHEIGHT, MAX_LAYER,1,3)
TLN_SetBGColor (0, 96, 184)

' load resources 
TLN_SetLoadPath ("assets/smw")

tilemaps(LAYER_FOREGROUND) = TLN_LoadTilemap ("smw_foreground.tmx", NULL)
tilemaps(LAYER_BACKGROUND) = TLN_LoadTilemap ("smw_background.tmx", NULL)
TLN_SetLayer (LAYER_FOREGROUND, NULL, tilemaps(LAYER_FOREGROUND))
TLN_SetLayer (LAYER_BACKGROUND, NULL, tilemaps(LAYER_BACKGROUND))
TLN_SetLayerPosition (LAYER_FOREGROUND, 0,48)
TLN_SetLayerPosition (LAYER_BACKGROUND, 0,80)

' setup sprite 
spriteset = TLN_LoadSpriteset ("smw_sprite")
TLN_SetSpriteSet (0, spriteset)
TLN_SetSpritePicture (0, 0)
TLN_SetSpritePosition (0, player_x, player_y)

' setup animations 
sp = TLN_LoadSequencePack ("sequences.sqx")
seq_walking = TLN_FindSequence (sp, "seq_walking")
TLN_SetSpriteAnimation (2, 0, seq_walking, 0)

' main loop 

if TLN_CreateWindow (null, CWF_S2)=0 then
    printf(!"Create Window Failed: '%s'\r\n",TLN_GetErrorString(TLN_GetLastError()))
    sleep : end
end if

TLN_DisableCRTEffect()

dim as longint llOldTicks, llFrameTicks
dim as integer iFPS

while (TLN_ProcessWindow())	    
    
    const TPS = 6000, cFPS = 60
    #define Ticks() (TLN_GetTicks()*clngint(6))
    
    dim as longint llTicks = Ticks()
    if abs(llTicks-llOldTicks) > TPS then llOldTicks = llTicks
    if abs(llTicks-llFrameTicks) > TPS then
        WindowTitle("SuperMarioClone: " & iFPS & " fps")
        iFPS = 0 : llFrameTicks=llTicks
    end if
    
    while abs(Ticks()-llOldTicks) > (TPS\cFPS)
        player_x += 1
        if player_x >= ScrWIDTH then
            player_x = -16
        end if
        frame += 1: llOldTicks += (TPS\cFPS)
    wend
    TLN_SetSpritePosition (0, player_x, player_y)
    
    TLN_DrawFrame(frame) : iFPS += 1
wend

' deinit 
TLN_DeleteTilemap(tilemaps(LAYER_FOREGROUND))
TLN_DeleteTilemap(tilemaps(LAYER_BACKGROUND))
TLN_DeleteSequencePack(sp)
TLN_Deinit()
