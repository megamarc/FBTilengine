declare function __timeBeginPeriod lib "winmm" alias "timeBeginPeriod"  (as integer) as integer

#include once "fbgfx.bi"
#include once "GfxResize.bas"
#include once "Tilengine.bi"

__timeBeginPeriod(1)

static shared as integer TLN_iVsync

#undef TLN_SetWindowTitle
sub TLN_SetWindowTitle(pzTitle as zstring ptr)
    if pzTitle then WindowTitle(*pzTitle)
end sub

#undef TLN_CreateWindow
function TLN_CreateWindow(pOverlay as any ptr, dwFlags as integer) as bool
    var iWid=TLN_GetWidth() , iHei=TLN_GetHeight()
    var iScale = (dwFlags shr 2) and 15
    if (dwFlags and CWF_FULLSCREEN) then iScale = -1
    TLN_iVsync = iif(dwFlags and CWF_VSYNC,1,0)
    
    Gfx.PreResize()
    screenres iWid , iHei,32,,iif(iScale=-1,fb.gfx_no_frame,0)
    if iScale>0 then
        Gfx.Resize(iWid*iScale,iHei*iScale)
    else
        Gfx.Resize()
    end if
    
    if screenptr=0 then TLN_SetLastError(TLN_ERR_UNSUPPORTED): return false
    
    dim as integer ScrPitch=any : screeninfo ,,,,ScrPitch
    TLN_SetRenderTarget(screenptr,ScrPitch)  
    
    return true
end function

#undef TLN_DrawFrame
sub TLN_DrawFrame( iTime as integer )
    
    static as double TMR
    
    screenlock
    TLN_UpdateFrame(iTime)
    if TLN_iVsync then 
        screensync : screenunlock
    else
        screenunlock
        if abs(timer-TMR) > 2 then TMR = timer
        while abs(timer-TMR) < 1/60
            sleep 1,1
        wend
        TMR += 1/60
    end if
    
end sub

#undef TLN_ProcessWindow
function TLN_ProcessWindow() as bool
    dim as fb.event Ev = any
    while screenevent(@Ev)
        select case Ev.type
        case fb.EVENT_KEY_PRESS
            if Ev.scancode = fb.SC_ESCAPE then return false
        end select
    wend
    return true
end function

#undef TLN_GetInput
function TLN_GetInput( iButton as integer ) as bool
    select case iButton
    case INPUT_UP   : iButton = fb.SC_UP
    case INPUT_DOWN : iButton = fb.SC_DOWN
    case INPUT_LEFT : iButton = fb.SC_LEFT
    case INPUT_RIGHT: iButton = fb.SC_RIGHT
    end select
    return multikey(iButton)
end function