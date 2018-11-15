' 
' * Tilengine - The 2D retro graphics engine with raster effects
' * Copyright (C) 2015-2018 Marc Palacios Domenech <mailto:megamarc@hotmail.com>
' * All rights reserved
' *
' * This library is free software; you can redistribute it and/or
' * modify it under the terms of the GNU Lesser General Public
' * License as published by the Free Software Foundation; either
' * version 2 of the License, or (at your option) any later version.
' *
' * This library is distributed in the hope that it will be useful,
' * but WITHOUT ANY WARRANTY; without even the implied warranty of
' * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
' * Library General Public License for more details.
' *
' * You should have received a copy of the GNU Library General Public
' * License along with this library. If not, see <http://www.gnu.org/licenses/>.
' 

#pragma once

#inclib "Tilengine"

#include once "crt.bi"

#ifndef NULL
  const NULL = 0  
#endif  

extern "C"

' version 
const TILENGINE_VER_MAJ	= 2
const TILENGINE_VER_MIN = 0
const TILENGINE_VER_REV	= 0
const TILENGINE_HEADER_VERSION = ((TILENGINE_VER_MAJ shl 16) or (TILENGINE_VER_MIN shl 8) or TILENGINE_VER_REV)

#define BITVAL(n) (1 shl (n))

' tile/sprite flags. Can be none or a combination of the following: 
enum TLN_TileFlags
	FLAG_NONE	  	= 0,		 ' no flags 
	FLAG_FLIPX		= BITVAL(15) ' horizontal flip 
	FLAG_FLIPY		= BITVAL(14) ' vertical flip 
	FLAG_ROTATE		= BITVAL(13) ' row/column flip (unsupported, Tiled compatibility) 
	FLAG_PRIORITY	= BITVAL(12) ' tile goes in front of sprite layer 
end enum

' fixed point helper 
type fix_t as integer
#define FIXED_BITS	16
#define float2fix(f)	cast(fix_t,(f*(1 shl FIXED_BITS)))
#define int2fix(i)		cast(integer,((i) shl FIXED_BITS))
#define fix2int(f)		cast(integer,((f+(1 shl (FIXED_BITS-1))) shr FIXED_BITS))
#define fix2float(f)	cast(single, ((f)/(1 shl FIXED_BITS)))

' layer blend modes. Must be one of these and are mutually exclusive:
enum TLN_Blend
	BLEND_NONE    ' blending disabled 
	BLEND_MIX25   ' color averaging 1 
	BLEND_MIX50   ' color averaging 2 
	BLEND_MIX75   ' color averaging 3 
	BLEND_ADD     ' color is always brighter (simulate light effects) 
	BLEND_SUB     ' color is always darker (simulate shadow effects) 
	BLEND_MOD     ' color is always darker (simulate shadow effects) 
	BLEND_CUSTOM  ' user provided blend declare function with TLN_SetCustomBlendFunction() 
	MAX_BLEND
	BLEND_MIX = BLEND_MIX50
end enum

' Affine transformation parameters  
type TLN_Affine
  as single angle	' rotation in degrees 
  as single dx		' horizontal translation 
  as single dy		' vertical translation 
  as single sx		' horizontal scaling 
  as single sy		' vertical scaling 
end type

' Tile item for Tilemap access methods 
type Tile
	as ushort index		' tile index 
	as ushort flags		' attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY) 
end type

' frame animation definition 
type TLN_SequenceFrame
	as integer index	' tile/sprite index 
	as integer delay	' time delay between frames 
end type

' color strip definition 
type TLN_ColorStrip
	as integer delay	' time delay between frames 
	as ubyte first		' index of first color to cycle 
	as ubyte count		' number of colors in the cycle 
	as ubyte dir	 	' direction: 0=descending, 1=ascending 
end type

' sequence info returned by TLN_GetSequenceInfo 
type TLN_SequenceInfo
	as zstring*32 name        ' sequence name 
	as integer    num_frames  ' 	< number of frames 
end type

' Sprite creation info for TLN_CreateSpriteset() 
type TLN_SpriteData
	as zstring*64 name ' entry name 
	as integer x	' horizontal position 
	as integer y	' vertical position 
	as integer w	' width 
	as integer h	' height 
end type

type TLN_SpriteInfo
	as integer w	' width of sprite 
	as integer h	' height of sprite 
end type

' Tile information returned by TLN_GetLayerTile() 
type TLN_TileInfo
	as ushort index ' tile index 
	as ushort flags ' attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY) 
	as integer row        ' row number in the tilemap 
	as integer col        ' col number in the tilemap 
	as integer xoffset    ' horizontal position inside the title 
	as integer yoffset    ' vertical position inside the title 
	as ubyte color  ' color index at collision point 
	as ubyte type   ' tile type 
	as boolean empty     ' cell is empty
end type

' Tileset attributes for TLN_CreateTileset() 
type TLN_TileAttributes
	as ubyte	type  ' tile type 
	as boolean	priority  ' priority flag set 
end type

' overlays for CRT effect 
enum TLN_Overlay
	TLN_OVERLAY_NONE        ' no overlay 
	TLN_OVERLAY_SHADOWMASK  ' Shadow mask pattern 
	TLN_OVERLAY_APERTURE    ' Aperture grille pattern 
	TLN_OVERLAY_SCANLINES,	' Scanlines pattern 
	TLN_OVERLAY_CUSTOM      ' User-provided when calling TLN_CreateWindow() 
	TLN_MAX_OVERLAY
end enum

' pixel mapping for TLN_SetLayerPixelMapping() 
type TLN_PixelMap
	as short dx	' horizontal pixel displacement 
	as short dy	' vertical pixel displacement 
end type

type TLN_Engine       as Engine			ptr ' Engine context 
type TLN_Tile         as Tile			ptr ' Tile reference 
type TLN_Tileset      as Tileset		ptr ' Opaque tileset reference 
type TLN_Tilemap      as Tilemap		ptr ' Opaque tilemap reference 
type TLN_Palette      as Palette		ptr	' Opaque palette reference 
type TLN_Spriteset    as Spriteset		ptr	' Opaque sspriteset reference 
type TLN_Sequence     as Sequence		ptr ' Opaque sequence reference 
type TLN_SequencePack as SequencePack	ptr	' Opaque sequence pack reference 
type TLN_Bitmap       as Bitmap			ptr	' Opaque bitmap reference 

#if 0 ' !!TODO!!
' callbacks 
typedef union SDL_Event SDL_Event;
typedef void(*TLN_SDLCallback)(SDL_Event*);
#endif
type TLN_VideoCallback as sub (scanline as integer)
type TLN_BlendFunction as function (src as ubyte, dst as ubyte) as ubyte

' Player index for input assignment declare functions 
enum TLN_Player
	PLAYER1	' Player 1 
	PLAYER2	' Player 2 
	PLAYER3	' Player 3 
	PLAYER4	' Player 4 
end enum

' Standard inputs query for TLN_GetInput() 
enum TLN_Input
	INPUT_NONE    ' no input 
	INPUT_UP      ' up direction 
	INPUT_DOWN    ' down direction 
	INPUT_LEFT    ' left direction 
	INPUT_RIGHT   ' right direction 
	INPUT_BUTTON1 ' 1st action button 
	INPUT_BUTTON2 ' 2nd action button 
	INPUT_BUTTON3 ' 3th action button 
	INPUT_BUTTON4 ' 4th action button 
	INPUT_BUTTON5 ' 5th action button 
	INPUT_BUTTON6 ' 6th action button 
	INPUT_START   ' Start button 

	INPUT_P1 = (PLAYER1 shl 4) 	' request player 1 input (default) 
	INPUT_P2 = (PLAYER2 shl 4)	' request player 2 input 
	INPUT_P3 = (PLAYER3 shl 4)	' request player 3 input 
	INPUT_P4 = (PLAYER4 shl 4)	' request player 4 input 
	
	' compatibility symbols for pre-1.18 input model  
	INPUT_A = INPUT_BUTTON1
	INPUT_B = INPUT_BUTTON2
	INPUT_C = INPUT_BUTTON3
	INPUT_D = INPUT_BUTTON4
	INPUT_E = INPUT_BUTTON5
	INPUT_F = INPUT_BUTTON6
end enum

' CreateWindow flags. Can be none or a combination of the following: 
enum TLN_WindowFlags
	CWF_FULLSCREEN		=	(1 shl 0) ' create a fullscreen window 
	CWF_VSYNC		    =	(1 shl 1) ' 	< sync frame updates with vertical retrace 
	CWF_S1		    	=	(1 shl 2) ' create a window the same size as the framebuffer 
	CWF_S2		    	=	(2 shl 2) ' create a window 2x the size the framebuffer 
	CWF_S3		    	=	(3 shl 2) ' create a window 3x the size the framebuffer 
	CWF_S4		    	=	(4 shl 2) ' create a window 4x the size the framebuffer 
	CWF_S5			    =	(5 shl 2) ' create a window 5x the size the framebuffer 
	CWF_NEAREST			=	(1 shl 6) ' unfiltered upscaling 
end enum

' Error codes 
enum TLN_Error
	TLN_ERR_OK              ' No error 
	TLN_ERR_OUT_OF_MEMORY   ' Not enough memory 
	TLN_ERR_IDX_LAYER       ' Layer index out of range 
	TLN_ERR_IDX_SPRITE      ' Sprite index out of range 
	TLN_ERR_IDX_ANIMATION   ' Animation index out of range 
	TLN_ERR_IDX_PICTURE     ' Picture or tile index out of range 
	TLN_ERR_REF_TILESET     ' Invalid TLN_Tileset reference 
	TLN_ERR_REF_TILEMAP     ' Invalid TLN_Tilemap reference 
	TLN_ERR_REF_SPRITESET   ' Invalid TLN_Spriteset reference 
	TLN_ERR_REF_PALETTE     ' Invalid TLN_Palette reference 
	TLN_ERR_REF_SEQUENCE    ' Invalid TLN_Sequence reference 
	TLN_ERR_REF_SEQPACK     ' Invalid TLN_SequencePack reference 
	TLN_ERR_REF_BITMAP      ' Invalid TLN_Bitmap reference 
	TLN_ERR_NULL_POINTER    ' Null pointer as argument  
	TLN_ERR_FILE_NOT_FOUND  ' Resource file not found 
	TLN_ERR_WRONG_FORMAT    ' Resource file has invalid format 
	TLN_ERR_WRONG_SIZE      ' A width or height parameter is invalid 
	TLN_ERR_UNSUPPORTED     ' Unsupported function 
	TLN_MAX_ERR
end enum

' Basic setup and management 
declare function TLN_Init(hres as integer, vres as integer, numlayers as integer, numsprites as integer , numanimations as integer ) as TLN_Engine 
declare sub      TLN_Deinit ()
declare function TLN_DeleteContext (context as TLN_Engine) as boolean
declare function TLN_SetContext(context as TLN_Engine) as boolean
declare function TLN_GetContext() as TLN_Engine
declare function TLN_GetWidth () as integer
declare function TLN_GetHeight () as integer
declare function TLN_GetBPP () as integer
declare function TLN_GetNumObjects () as uinteger
declare function TLN_GetUsedMemory () as uinteger
declare function TLN_GetVersion () as uinteger
declare function TLN_GetNumLayers () as integer
declare function TLN_GetNumSprites () as integer
declare sub      TLN_SetBGColor (r as ubyte, g as ubyte, b as ubyte)
declare function TLN_SetBGColorFromTilemap (tilemap as TLN_Tilemap) as boolean
declare sub      TLN_DisableBGColor ()
declare function TLN_SetBGBitmap (bitmap as TLN_Bitmap) as boolean
declare function TLN_SetBGPalette (palette as TLN_Palette) as boolean
declare sub      TLN_SetRasterCallback(as TLN_VideoCallback)
declare sub      TLN_SetFrameCallback(as TLN_VideoCallback)
declare sub      TLN_SetRenderTarget (data as ubyte ptr, pitch as integer)
declare sub      TLN_UpdateFrame (time as integer)
declare sub      TLN_BeginFrame (time as integer)
declare function TLN_DrawNextScanline() as boolean
declare sub      TLN_SetLoadPath (path as const zstring ptr)
declare sub      TLN_SetCustomBlendFunction (as TLN_BlendFunction)

' Error handling 
declare sub      TLN_SetLastError (error as TLN_Error)
declare function TLN_GetLastError () as TLN_Error
declare function TLN_GetErrorString (error as TLN_Error) as const zstring ptr

' Built-in window and input management 
declare function TLN_CreateWindow (overlay as const zstring ptr, flags as TLN_WindowFlags ) as boolean
declare function TLN_CreateWindowThread (overlay as const zstring ptr, flags as TLN_WindowFlags) as boolean
declare sub      TLN_SetWindowTitle (title as const zstring ptr)
declare function TLN_ProcessWindow () as boolean
declare function TLN_IsWindowActive () as boolean
declare function TLN_GetInput (id as TLN_Input) as boolean
declare sub      TLN_EnableInput (player as TLN_Player, enable as boolean)
declare sub      TLN_AssignInputJoystick (player as TLN_Player, index as integer)
declare sub      TLN_DefineInputKey (player as TLN_Player, input as TLN_Input, keycode as uinteger)
declare sub      TLN_DefineInputButton (player as TLN_Player, input as TLN_Input, joybutton as ubyte)
declare sub      TLN_DrawFrame (time as integer)
declare sub      TLN_WaitRedraw ()
declare sub      TLN_DeleteWindow ()
declare sub      TLN_EnableCRTEffect (overlay as TLN_Overlay, overlay_factor as ubyte , threshold as ubyte , v0 as ubyte, v1 as ubyte, v2 as ubyte, v3 as ubyte, blur as boolean, glow_factor as ubyte)
declare sub      TLN_DisableCRTEffect ()
' declare sub      TLN_SetSDLCallback(TLN_SDLCallback)
declare sub      TLN_Delay (msecs as uinteger)
declare function TLN_GetTicks () as uinteger
declare sub      TLN_BeginWindowFrame (time as integer)
declare sub      TLN_EndWindowFrame ()

' Spriteset resources management for sprites 
declare function TLN_CreateSpriteset (bitmap as TLN_Bitmap, data as TLN_SpriteData ptr , num_entries as integer) as TLN_Spriteset
declare function TLN_LoadSpriteset (name as const zstring ptr) as TLN_Spriteset
declare function TLN_CloneSpriteset (src as TLN_Spriteset) as TLN_Spriteset
declare function TLN_GetSpriteInfo (spriteset as TLN_Spriteset, entry as integer, info as TLN_SpriteInfo ptr) as boolean
declare function TLN_GetSpritesetPalette (spriteset as TLN_Spriteset) as TLN_Palette
declare function TLN_FindSpritesetSprite (spriteset as TLN_Spriteset, name as zstring ptr) as integer
declare function TLN_SetSpritesetData (spriteset as TLN_Spriteset, entry as integer, data as TLN_SpriteData ptr, pixels as any ptr, pitch as integer) as boolean
declare function TLN_DeleteSpriteset (Spriteset as TLN_Spriteset) as boolean

' Tileset resources management for background layers 
declare function TLN_CreateTileset (numtiles as integer, width as integer, height as integer , palette as TLN_Palette, sp as TLN_SequencePack, attributes as TLN_TileAttributes ptr) as TLN_Tileset
declare function TLN_LoadTileset (filename as const zstring ptr) as TLN_Tileset
declare function TLN_CloneTileset (src as TLN_Tileset) as TLN_Tileset
declare function TLN_SetTilesetPixels (tileset as TLN_Tileset, entry as integer, srcdata as ubyte ptr, srcpitch as integer) as boolean
declare function TLN_CopyTile (tileset as TLN_Tileset, src as integer, dst as integer) as boolean
declare function TLN_GetTileWidth (tileset as TLN_Tileset) as integer
declare function TLN_GetTileHeight (tileset as TLN_Tileset) as integer
declare function TLN_GetTilesetPalette (tileset as TLN_Tileset) as TLN_Palette
declare function TLN_GetTilesetSequencePack (tileset as TLN_Tileset) as TLN_SequencePack
declare function TLN_DeleteTileset (tileset as TLN_Tileset) as boolean

' Tilemap resources management for background layers 
declare function TLN_CreateTilemap (rows as integer, cols as integer, tiles as TLN_Tile, bgcolor as uinteger, tileset as TLN_Tileset) as TLN_Tilemap
declare function TLN_LoadTilemap (filename as const zstring ptr, layername as const zstring ptr) as TLN_Tilemap
declare function TLN_CloneTilemap (src as TLN_Tilemap) as TLN_Tilemap
declare function TLN_GetTilemapRows (tilemap as TLN_Tilemap) as integer
declare function TLN_GetTilemapCols (tilemap as TLN_Tilemap) as integer
declare function TLN_GetTilemapTileset (tilemap as TLN_Tilemap) as TLN_Tileset
declare function TLN_GetTilemapTile (tilemap as TLN_Tilemap, row as integer, col as integer, tile as TLN_Tile) as boolean
declare function TLN_SetTilemapTile (tilemap as TLN_Tilemap, row as integer, col as integer, tile as TLN_Tile) as boolean
declare function TLN_CopyTiles (src as TLN_Tilemap, srcrow as integer, srccol as integer, rows as integer, cols as integer, dst as TLN_Tilemap, dstrow as integer, dstcol as integer) as boolean
declare function TLN_DeleteTilemap (tilemap as TLN_Tilemap) as boolean

' Color palette resources management for sprites and background layers 
declare function TLN_CreatePalette (entries as integer) as TLN_Palette
declare function TLN_LoadPalette (filename as const zstring ptr) as TLN_Palette
declare function TLN_ClonePalette (src as TLN_Palette) as TLN_Palette
declare function TLN_SetPaletteColor (palette as TLN_Palette, color as integer, r as ubyte, g as ubyte, b as ubyte) as boolean
declare function TLN_MixPalettes (src1 as TLN_Palette, src2 as TLN_Palette, dst as TLN_Palette, factor as ubyte) as boolean
declare function TLN_AddPaletteColor (palette as TLN_Palette, r as ubyte, g as ubyte, b as ubyte, start as ubyte, num as ubyte) as boolean
declare function TLN_SubPaletteColor (palette as TLN_Palette, r as ubyte, g as ubyte, b as ubyte, start as ubyte, num as ubyte) as boolean
declare function TLN_ModPaletteColor (palette as TLN_Palette, r as ubyte, g as ubyte, b as ubyte, start as ubyte, num as ubyte) as boolean
declare function TLN_GetPaletteData (palette as TLN_Palette, index as integer) as ubyte ptr
declare function TLN_DeletePalette (palette as TLN_Palette) as boolean

' Bitmap management 
declare function TLN_CreateBitmap (width as integer, height as integer, bpp as integer) as TLN_Bitmap
declare function TLN_LoadBitmap (filename as const zstring ptr) as TLN_Bitmap
declare function TLN_CloneBitmap (src as TLN_Bitmap) as TLN_Bitmap
declare function TLN_GetBitmapPtr (bitmap as TLN_Bitmap, x as integer, y as integer) as ubyte ptr
declare function TLN_GetBitmapWidth (bitmap as TLN_Bitmap) as integer
declare function TLN_GetBitmapHeight (bitmap as TLN_Bitmap) as integer
declare function TLN_GetBitmapDepth (bitmap as TLN_Bitmap) as integer
declare function TLN_GetBitmapPitch (bitmap as TLN_Bitmap) as integer
declare function TLN_GetBitmapPalette (bitmap as TLN_Bitmap) as TLN_Palette
declare function TLN_SetBitmapPalette (bitmap as TLN_Bitmap, palette as TLN_Palette) as boolean
declare function TLN_DeleteBitmap (bitmap as TLN_Bitmap) as boolean

' Background layers management 
declare function TLN_SetLayer (nlayer as integer, tileset as TLN_Tileset, tilemap as TLN_Tilemap) as boolean
declare function TLN_SetLayerBitmap(nlayer as integer, bitmap as TLN_Bitmap) as boolean
declare function TLN_SetLayerPalette (nlayer as integer, palette as TLN_Palette) as boolean
declare function TLN_SetLayerPosition (nlayer as integer, hstart as integer, vstart as integer) as boolean
declare function TLN_SetLayerScaling (nlayer as integer, xfactor as single, yfactor as single) as boolean
declare function TLN_SetLayerAffineTransform (nlayer as integer, affine as TLN_Affine ptr) as boolean
declare function TLN_SetLayerTransform (nlayer as integer, angle as single, dx as single, dy as single, sx as single, sy as single) as boolean
declare function TLN_SetLayerPixelMapping (nlayer as integer, table as TLN_PixelMap ptr ) as boolean
declare function TLN_SetLayerBlendMode (nlayer as integer, mode as TLN_Blend, factor as ubyte) as boolean
declare function TLN_SetLayerColumnOffset (nlayer as integer, offset as integer ptr) as boolean
declare function TLN_SetLayerClip (nlayer as integer, x1 as integer, y1 as integer, x2 as integer, y2 as integer) as boolean
declare function TLN_DisableLayerClip (nlayer as integer) as boolean
declare function TLN_SetLayerMosaic (nlayer as integer, width as integer, height as integer) as boolean
declare function TLN_DisableLayerMosaic (nlayer as integer) as boolean
declare function TLN_ResetLayerMode (nlayer as integer) as boolean
declare function TLN_DisableLayer (nlayer as integer) as boolean
declare function TLN_GetLayerPalette (nlayer as integer) as TLN_Palette
declare function TLN_GetLayerTile (nlayer as integer, x as integer, y as integer, info as TLN_TileInfo ptr) as boolean
declare function TLN_GetLayerWidth (nlayer as integer) as integer
declare function TLN_GetLayerHeight (nlayer as integer) as integer

' Sprites management 
declare function TLN_ConfigSprite (nsprite as integer, spriteset as TLN_Spriteset, flags as TLN_TileFlags) as boolean
declare function TLN_SetSpriteSet (nsprite as integer, spriteset as TLN_Spriteset) as boolean
declare function TLN_SetSpriteFlags (nsprite as integer, flags as TLN_TileFlags) as boolean
declare function TLN_SetSpritePosition (nsprite as integer, x as integer, y as integer) as boolean
declare function TLN_SetSpritePicture (nsprite as integer, entry as integer) as boolean
declare function TLN_SetSpritePalette (nsprite as integer, palette as TLN_Palette) as boolean
declare function TLN_SetSpriteBlendMode (nsprite as integer, mode as TLN_Blend, factor as ubyte) as boolean
declare function TLN_SetSpriteScaling (nsprite as integer, sx as single, sy as single) as boolean
declare function TLN_ResetSpriteScaling (nsprite as integer) as boolean
declare function TLN_GetSpritePicture (nsprite as integer) as integer
declare function TLN_GetAvailableSprite () as integer
declare function TLN_EnableSpriteCollision (nsprite as integer, enable as boolean) as boolean
declare function TLN_GetSpriteCollision (nsprite as integer) as boolean
declare function TLN_DisableSprite (nsprite as integer) as boolean
declare function TLN_GetSpritePalette (nsprite as integer) as TLN_Palette

' Sequence resources management for layer, sprite and palette animations 
declare function TLN_CreateSequence (name as const zstring ptr, target as integer , num_frames as integer , frames as TLN_SequenceFrame ptr) as TLN_Sequence
declare function TLN_CreateCycle (name as const zstring ptr, num_strips as integer , strips as TLN_ColorStrip ptr) as TLN_Sequence
declare function TLN_CloneSequence (src as TLN_Sequence) as TLN_Sequence
declare function TLN_GetSequenceInfo (sequence as TLN_Sequence, info as TLN_SequenceInfo ptr) as boolean
declare function TLN_DeleteSequence (sequence as TLN_Sequence) as boolean

' Sequence pack manager for grouping and finding sequences 
declare function TLN_CreateSequencePack () as TLN_SequencePack
declare function TLN_LoadSequencePack (filename as const zstring ptr) as TLN_SequencePack
declare function TLN_CloneSequencePack (src as TLN_SequencePack) as TLN_SequencePack
declare function TLN_GetSequence (sp as TLN_SequencePack, index as integer) as TLN_Sequence
declare function TLN_FindSequence (sp as TLN_SequencePack, name as const zstring ptr) as TLN_Sequence
declare function TLN_GetSequencePackCount (sp as TLN_SequencePack) as integer
declare function TLN_AddSequenceToPack (sp as TLN_SequencePack, sequence as TLN_Sequence) as boolean
declare function TLN_DeleteSequencePack (sp as TLN_SequencePack) as boolean

' Animation engine manager 
declare function TLN_SetPaletteAnimation (index as integer, palette as TLN_Palette, sequence as TLN_Sequence, blend as boolean ) as boolean
declare function TLN_SetPaletteAnimationSource (index as integer, palette as TLN_Palette) as boolean
declare function TLN_SetTilesetAnimation (index as integer, nlayer as integer, sequence as TLN_Sequence) as boolean
declare function TLN_SetTilemapAnimation (index as integer, nlayer as integer, sequence as TLN_Sequence) as boolean
declare function TLN_SetSpriteAnimation (index as integer, nsprite as integer, sequence as TLN_Sequence, loop as integer) as boolean
declare function TLN_GetAnimationState (index as integer) as boolean
declare function TLN_SetAnimationDelay (index as integer, delay as integer) as boolean
declare function TLN_GetAvailableAnimation () as integer
declare function TLN_DisableAnimation (index as integer) as boolean

end extern
