'*****************************************************************************
'*
'* Tilengine sample
'* 2015 Marc Palacios
'* http://www.tilengine.org
'*
'* This example show a classic Mode 7 perspective projection plane like the 
'* one seen in SNES games like Super Mario Kart. It uses a single transformed
'* layer with a raster effect setting the scaling factor for each line
'*
'*****************************************************************************

#include "Tilengine.bi"
#include "Sin.bas"

const iScale = 2
const ScrWIDTH  = 400*iScale
const ScrHEIGHT	= 240*iScale

' linear interploation 
#define lerp(x, x0,x1, fx0,fx1) ((fx0) + ((fx1) - (fx0))*((x) - (x0))/((x1) - (x0)))

' layers 
enum
	LAYER_FOREGROUND
	LAYER_BACKGROUND
	MAX_LAYER
end enum

enum
	MAP_HORIZON
	MAP_TRACK
	MAX_MAP
end enum

static shared as integer pos_background(6-1) = {0}
static shared as integer inc_background(6-1) = {0}
static shared as TLN_Tileset tilesets(MAX_MAP-1)
static shared as TLN_Tilemap tilemaps(MAX_MAP-1)
dim shared as uinteger uframe
dim shared as uinteger utime

dim shared as fix_t x,y,s,a

static shared as TLN_Affine affine,affine2
static shared as integer angle

declare sub raster_callback cdecl (iline as integer)

' Begin of main program *******************************************************

' setup engine 
TLN_Init (ScrWIDTH,ScrHEIGHT, MAX_LAYER, 0, 5)
TLN_SetRasterCallback(@raster_callback)
TLN_SetBGColor (255,0,255)
TLN_DisableBGColor ()

' load resources
TLN_SetLoadPath ("assets/smk")
tilesets(MAP_HORIZON) = TLN_LoadTileset ("track1_bg.tsx")
tilemaps(MAP_HORIZON) = TLN_LoadTilemap ("track1_bg.tmx", NULL)
tilesets(MAP_TRACK  ) = TLN_LoadTileset ("track1.tsx")
tilemaps(MAP_TRACK  ) = TLN_LoadTilemap ("track1.tmx", NULL)

' startup display 
TLN_CreateWindow (null, iif(iScale>1,CWF_S1,CWF_S2))' or CWF_VSYNC) 'CWF_VSYNC)

x = int2fix(-136)
y = int2fix(336)
s = 0
a = float2fix(0.2f)
angle = 0
BuildSinTable ()

affine.dx = (ScrWIDTH/2)
affine.dy = (ScrHEIGHT)
affine.sx = iScale
affine.sy = iScale
affine.angle = cast(single,angle)

affine2.sx = iScale
affine2.sy = iScale

' main loop 
while TLN_ProcessWindow()
	utime = uframe

	TLN_SetLayer (LAYER_FOREGROUND, tilesets(MAP_HORIZON), tilemaps(MAP_HORIZON))
	TLN_SetLayer (LAYER_BACKGROUND, tilesets(MAP_HORIZON), tilemaps(MAP_HORIZON))
	TLN_SetLayerPosition (LAYER_FOREGROUND, lerp(angle*2, 0,360, 0,256), 24)
	TLN_SetLayerPosition (LAYER_BACKGROUND, lerp(angle, 0,360, 0,256), 0)

	if iScale > 1 then
		TLN_SetLayerAffineTransform (LAYER_BACKGROUND, @affine2)
		TLN_SetLayerAffineTransform (LAYER_FOREGROUND, @affine2)
	else
		TLN_SetLayerAffineTransform (LAYER_BACKGROUND, null)
	end if

	' input 		
	static as double TMR
	if abs(timer-TMR) > 2 then TMR = timer    
		while abs(timer-TMR) > (1/60)
		if (TLN_GetInput (INPUT_LEFT)) then
			angle -= 2
		elseif (TLN_GetInput (INPUT_RIGHT)) then
			angle += 2
	end if
	
	if TLN_GetInput(INPUT_UP) then		
		s += a
		if s > int2fix(2) then s = int2fix(2)	
			elseif (s >= a) then
		s -= a
	end if

	if (TLN_GetInput (INPUT_DOWN)) then		
		s -= a
		if (s < -int2fix(2)) then
			s = -int2fix(2)
	end if		
	
	elseif (s <= -a) then
		s += a
	end if

	if (s <> 0) then		
		angle = angle mod 360
		if (angle < 0) then angle += 360			
			x += CalcSin (angle, s)
			y -= CalcCos (angle, s)
	end if

	affine.angle = cast(single,angle)      
	TMR += (1/60) : uframe += 1

wend

' render to window 
TLN_DrawFrame(utime)
sleep 1,1

wend

' deinit 
TLN_DeleteTileset (tilesets(MAP_HORIZON))
TLN_DeleteTilemap (tilemaps(MAP_HORIZON))
TLN_DeleteTileset (tilesets(MAP_TRACK  ))
TLN_DeleteTilemap (tilemaps(MAP_TRACK  ))
TLN_DeleteWindow ()
TLN_Deinit ()
' End of main program *********************************************************

' raster callback (virtual HBLANK) 
sub raster_callback cdecl (iline as integer)
  if iline = 24*iScale then	
		TLN_SetLayer (LAYER_BACKGROUND, tilesets(MAP_TRACK), tilemaps(MAP_TRACK))
		TLN_SetLayerPosition (LAYER_BACKGROUND, fix2int(x*iScale), fix2int(y*iScale))
		TLN_DisableLayer (LAYER_FOREGROUND)
	end if

	if iline >= 24*iScale then	
		dim as fix_t  s0 = float2fix (0.2f)
		dim as fix_t  s1 = float2fix (5.0f)
		dim as fix_t  s  = (lerp (iline, 24*iScale,ScrHEIGHT, s0,s1))
		dim as single scale = fix2float (s)

		affine.sx = scale*iScale
		affine.sy = scale*iScale
		TLN_SetLayerAffineTransform (LAYER_BACKGROUND, @affine)
	end if
end sub
