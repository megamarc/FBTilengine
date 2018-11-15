'*****************************************************************************
'*
'* Tilengine sample
'* 2015 Marc Palacios
'* http://www.tilengine.org
'*
'* This example show a classic pseudo-3D road like the Sega game Super Hang-On
'* It uses a single layer with palette cycling to simulate depth, linescroll
'* to simulate lateral movement and scaling sprites for the approaching trees
'*
'*****************************************************************************

#include "TilengineFBgfx.bas"

const ScrWIDTH  = 400
const ScrHEIGHT = 240
const MAX_ACTOR = 40
const Z_NEAR    = 50
const Z_FAR     = 1000

enum
	SPRITESET_TREES
	MAX_SPRITESET
end enum

' layers
enum
	LAYER_PLAYFIELD
	MAX_LAYER
end enum

static shared as TLN_Spriteset spritesets(MAX_SPRITESET-1)
static shared as TLN_Palette palettes(2-1)
dim shared as integer ipos, speed, last_tree, pan
dim shared as uinteger uframe, utime

#include "Tree.bas"

declare sub raster_callback cdecl (iLine as integer)

#define MAX_SPEED	6
#define MAX_STEER	58

' linear interploation
#define lerp(x, x0,x1, fx0,fx1) ((fx0) + ((fx1) - (fx0))*((x) - (x0))/((x1) - (x0)))

type iRGB
    as	integer r,g,b
end type

static shared as iRGB sky(...) = { (&h66,&h22,&hEE) , (&hCC,&hCC,&hEE) }
declare sub InterpolateColor (v as integer, v1 as integer, v2 as integer, color1 as iRGB ptr, color2 as iRGB ptr, result as iRGB ptr)

dim as TLN_Tilemap tilemap

' init engine and load resources
TLN_Init (ScrWIDTH,ScrHEIGHT, MAX_LAYER,MAX_ACTOR, 0)
TLN_SetRasterCallback(@raster_callback)

' load resources
TLN_SetLoadPath ("assets/racer")
tilemap = TLN_LoadTilemap ("racer.tmx", NULL)
TLN_SetLayer (LAYER_PLAYFIELD, NULL, tilemap)
palettes(0) = TLN_GetLayerPalette (LAYER_PLAYFIELD)
palettes(1) = TLN_LoadPalette ("racer.act")
spritesets(SPRITESET_TREES) = TLN_LoadSpriteset ("trees")

' startup display
TLN_CreateWindow (NULL, CWF_S2)' or CWF_VSYNC)
TLN_SetWindowTitle("Raaaaacer!")

CreateActors (MAX_ACTOR)

dim as longint llOldTicks, llFrameTicks
dim as integer iFPS

' main loop
while TLN_ProcessWindow()
    ' timekeeper
    utime = uframe

    const TPS = 6000, cFPS = 60
    #define Ticks() (TLN_GetTicks()*clngint(6))

    dim as longint llTicks = Ticks()
    if abs(llTicks-llOldTicks) > TPS then llOldTicks = llTicks
    if abs(llTicks-llFrameTicks) > TPS then
        TLN_SetWindowTitle("Racer: " & iFPS & " fps")
        iFPS = 0 : llFrameTicks=llTicks
    end if

    while abs(Ticks()-llOldTicks) > (TPS\cFPS)
        TLN_SetLayerPosition (LAYER_PLAYFIELD, 56,72)
        if (ipos - last_tree) >= 100 then
            CreateTree (240,184,0)
            CreateTree (240,184,1)
            last_tree = ipos
        end if

        ' input
        if ((utime and &h7) = 0) then
            if (TLN_GetInput (INPUT_UP) andalso speed < MAX_SPEED) then speed += 1
        elseif ((TLN_GetInput(INPUT_UP)=0) andalso speed > 0) then
            speed -= 1
        end if

        if (TLN_GetInput(INPUT_LEFT) andalso pan > -MAX_STEER) then
            pan -= 2
        elseif (TLN_GetInput (INPUT_RIGHT) andalso pan < MAX_STEER) then
            pan += 2
        end if

        ' actores
        ipos += speed
        TasksActors(utime)

        uframe += 1 : llOldTicks += (TPS\cFPS)

    wend

    ' render to window
    TLN_DrawFrame(utime)
    iFPS += 1

wend

' deinit
TLN_DeleteTilemap(tilemap)
TLN_DeleteSpriteset(spritesets(SPRITESET_TREES))
TLN_Deinit()

' raster callback (virtual HBLANK)
sub raster_callback cdecl (iline as integer)

    ' sky gradient
	if (iline < 56) then
		dim as iRGB ucolor
		InterpolateColor(iline, 0,56, @sky(0), @sky(1), @ucolor)
		TLN_SetBGColor (ucolor.r, ucolor.g, ucolor.b)
    end if

	' road
	if iline >= 56 then
		dim as integer depth = lerp (iline, 56,240, Z_NEAR,Z_FAR)
		dim as integer value = ipos + 32768/depth
		dim as integer phase = (value shr 5) and 1
		dim as integer dx = lerp(iline, 56,240, 0,pan)
		dim as integer c = 240 - iline - 1
		dim as integer s = ((c*(c + 1))/2)/128
		TLN_SetLayerPalette(LAYER_PLAYFIELD, palettes(phase))
		TLN_SetLayerPosition(LAYER_PLAYFIELD, 56 + dx , 72) '+s
    end if
end sub

sub InterpolateColor (v as integer, v1 as integer, v2 as integer, color1 as iRGB ptr, color2 as iRGB ptr, result as iRGB ptr)
    result->r = lerp (v, v1,v2, color1->r, color2->r)
	result->g = lerp (v, v1,v2, color1->g, color2->g)
	result->b = lerp (v, v1,v2, color1->b, color2->b)
end sub
