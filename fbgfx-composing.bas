' FBTilengine - FreeBasic binding for Tilengine - 2D retro graphics engine
' 2018 MyTDT-MySoft
'
' Screen composition using FreeBasic's own FBgfx subsystem

#include "fbgfx.bi"
#include "GfxResize.bas"

const ScrWid=320,ScrHei=240
const SpriteWid=64,SpriteHei=64

gfx.PreResize()
screenres ScrWid,ScrHei,32
gfx.Resize(ScrWid*2,ScrHei*2)

dim as fb.image ptr pBack, pSprites, pMist

pBack = ImageCreate(320,240)
pSprites = ImageCreate(768,896)
pMist = ImageCreate(640,240)

bload "assets/_bmp/background.bmp", pBack
bload "assets/_bmp/sprites.bmp", pSprites
bload "assets/_bmp/mist.bmp", pMist

dim as integer iMistX,iMistY,iFrame
dim as integer iPlayerX=-SpriteWid,iPlayerY
dim as integer iPX, iPY

dim as double TMR = timer
dim as integer iFPS, iStallFrames = 0

do

    if abs(timer-TMR) >= 1 then
        TMR = timer
        WindowTitle("fbgfx demo: " & iFps & "fps")
        iFPS = 0
    end if

    var iPlayerOnMid = abs(iPlayerX-((ScrWid\2)-32)) < 4
    if (iFrame and 1)=0 then 'every 2 frames
        if iPlayerOnMid then
            if (iFrame and 15)=0 then iPlayerX += 1
        else
            iPlayerX += 1
        end if
        if iPlayerX = ScrWid then
            iPlayerX = -SpriteWid   'wrap back to left
            iPY = (iPY+SpriteHei) mod 896  'next sprite "row"
        end if
        if (iFrame and 3)=0 then 'every 4 frames
            iMistX = (iMistX+1) mod pMist->Width
            iMistY = (iMistY+1) mod pMist->Height
        end if
    end if

    screenlock 'prevent the screen from update

    'draw background
    put(0,0),pBack,pset

    'draw the sprite
    iPX = 9+((iFrame\16) and 1)
    if iPlayerOnMid then
        iPX = (10+((iFrame\12) and 1))*SpriteWid
        iStallFrames += 1
    else
        iPX = (9+((iFrame\16) and 1))*SpriteWid
    end if
    iPlayerY=160+sin((iFrame-iStallFrames)/64)*10
    put(iPlayerX,iPlayerY),pSprites,(iPX,iPY)-step(SpriteWid-1,SPriteHei-1),trans

    'draw the mist (repeating to fill the screen)
    for iY as integer = -iMistY to ScrHei-1 step pMist->Height
        for iX as integer = -iMistX to ScrWid step pMist->Width
            put(iX,iY),pMist,alpha,64 '25% alpha
        next iX
    next iY
    screenunlock 'allow the screen to update

    sleep 0,1
    iFrame += 1 : iFPS += 1

loop until len(inkey$)