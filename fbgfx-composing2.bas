' FBTilengine - FreeBasic binding for Tilengine - 2D retro graphics engine
' 2018 MyTDT-MySoft
'
' Screen composition using FreeBasic's own FBgfx subsystem

#include "fbgfx.bi"
#include "GfxResize.bas"

const ScrWid=320,ScrHei=240
const SpriteWid=64,SpriteHei=64

type pixel as ushort '16bpp
#if sizeof(pixel)=2
type pixel2 as ulong
#else
type pixel2 as ulongint
#endif

static shared as pixel2 tPixConv(255,255)

sub UpdateBigPal( pPal as pixel ptr , iStart as integer , iEnd as integer )
    for Y as integer = iStart to iEnd
        for X as integer = iStart to iEnd
            tPixConv(X,Y) = (pPal[Y]) or (cast(pixel2,pPal[X]) shl (sizeof(pixel)*8))
        next X
    next Y
end sub
sub ConvertPal ( pPal as pixel ptr )
    select case sizeof(pixel)
    case 2 '16bpp
        for N as integer = 0 to 255
            var Pix = cptr(ulong ptr,pPal)[N]
            var iR = (Pix and &h3E0000) shr 17
            var iG = (Pix and &h003F00) shr 3
            var iB = (Pix and &h00003E) shl 10
            pPal[N] = iR or iG or iB
        next N
    case 4 '32bpp
        for N as integer = 0 to 255
            var Pix = pPal[N]
            var iR = ((Pix and &hFC0000) shr 14): if iR >= &h00007F then iR or= &h000003
            var iG = ((Pix and &h00FC00) shl 2) : if iG >= &h007F00 then iG or= &h000300
            var iB = ((Pix and &h0000FC) shl 18): if iB >= &h7F0000 then iB or= &h030000
            pPal[N] = iR or iG or iB
        next N
    end select
    UpdateBigPal( pPal , 0 , 255 )
end sub

sub Put256( pTarget as fb.image ptr , pSource as fb.image ptr , pPal as pixel ptr )
    dim as pixel ptr pTgt = any
    if pTarget then
        pTgt = cptr(pixel ptr,pTarget+1)
    else
        pTgt = screenptr
    end if
    var SrcWid = pSource->width, SrcHei = pSource->height
    var pSrc = cptr(ubyte ptr, pSource+1)
    for Y as integer = 0 to SrcHei-1
        for X as integer = 0 to SrcWid-1
            pTgt[X] = pPal[pSrc[X]]
        next X
        pSrc += pSource->pitch
        pTgt += ScrWid
    next Y
end sub

sub RotatePal cdecl ( pPal as pixel ptr , ... ) 'iStart as integer , iAmount as integer )
    var pPair = cptr(any ptr,@pPal)+sizeof(pPal)
    do
        var iStart = *cptr(integer ptr,pPair)
        if cuint(iStart) > 255 then exit do
        pPair += sizeof(integer)
        var iAmount = *cptr(integer ptr,pPair)
        if iAmount <= 0 then exit do
        if cuint(iStart+iAmount) > 256 then exit do
        pPair += sizeof(integer)
        dim as ulong lColor = pPal[iStart]
        memcpy(pPal+iStart,pPal+iStart+1,(iAmount-1)*sizeof(*pPal))
        pPal[iStart+(iAmount-1)] = lColor
        UpdateBigPal( pPal , iStart , iStart+iAmount-1 )
    loop
end sub

gfx.PreResize()
screenres ScrWid,ScrHei,sizeof(pixel)*8
gfx.Resize(ScrWid*2,ScrHei*2)

dim as fb.image ptr pBack, pSprites, pMist
static shared as pixel MyPal(511)

pBack = ImageCreate(320,240,,8)
pSprites = ImageCreate(768,896)
pMist = ImageCreate(640,240)

bload "assets/_bmp/background.bmp", pBack, @MyPal(0)
bload "assets/_bmp/sprites.bmp", pSprites
bload "assets/_bmp/mist.bmp", pMist

ConvertPal(@MyPal(0))

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

            if (iFrame and 7)=0 then 'every 8 frames
                RotatePal( @MyPal(0) ,  54,10 , 67,13 , 83,13 , 99,13 , 115,13 , -1 )
            end if

        end if
    end if

    screenlock 'prevent the screen from update

    'draw background
    Put256(0,pBack,@MyPal(0))

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

    static as double TMR
    if abs(timer-TMR) > 1 then TMR = timer
    while abs(timer-TMR) < 1/60
        sleep 1,1
    wend
    TMR += 1/60
    iFrame += 1 : iFPS += 1

loop until len(inkey$)