' FBTilengine - FreeBasic binding for Tilengine - 2D retro graphics engine
' 2018 MyTDT-MySoft
'
' Manages a simple actor list for generic gameplay

type Hitbox
	as integer x1,y1,x2,y2
end type

type Actor
	as integer index
	as integer itype
	as integer state
	as integer w,h
	as integer x,y
	as integer vx,vy
	as integer life
	as Hitbox hitbox
	as uinteger timers(4-1)
	callback as sub (as Actor ptr)
	as ubyte usrdata(64-1)
end type

' local variables
static shared as Actor ptr actors
static shared as integer act_count = 0
static shared as uinteger act_utime

' local prototypes
declare sub TasksActor(actor as actor ptr)

' create actors array
function CreateActors(num as integer) as boolean
	dim as integer size = sizeof(Actor)*num

	if (actors <> NULL) then return false

	actors = callocate(size)
	if (actors) then
		act_count = num
		return true
	end if
	return false
end function

' delete actors array
function DeleteActors() as boolean
	if (actors <> NULL) then
		deallocate(actors)
		actors = NULL
		act_count = 0
		return true
	end if
	return false
end function

' returns index of first available actor (-1 = all used)
function GetAvailableActor (first as integer, ilen as integer) as integer

  dim as integer c, last

	if (actors=0) then return -1

	last = first + ilen
	for c=first to (last-1)
		if (actors[c].state=0) then return c
	next c

	return -1

end function

' gets actor pointer from index
function GetActor (index as integer) as Actor ptr
	if (actors andalso index<act_count) then
		return @actors[index]
	else
		return NULL
  end if
end function

' sets collision box
sub UpdateActorHitbox (actor as Actor ptr)
	actor->hitbox.x1 = actor->x
	actor->hitbox.y1 = actor->y
	actor->hitbox.x2 = actor->x + actor->w
	actor->hitbox.y2 = actor->y + actor->h
end sub

' sets actor properties
function SetActor(index as integer, itype as integer, x as integer, y as integer, w as integer, h as integer, callback as sub(as Actor ptr)) as actor ptr
  if (actors andalso index<act_count) then
		dim as Actor ptr actor = @actors[index]
		actor->index = index
		actor->itype = itype
		actor->callback = callback
		actor->state = 1
		actor->x = x
		actor->y = y
		actor->w = w
		actor->h = h
		UpdateActorHitbox(actor)
		return actor
	end if
	return NULL
end function

' releases actor
sub ReleaseActor (actor as actor ptr)
	TLN_SetSpriteBlendMode (actor->index, BLEND_NONE, 0)
	actor->state = 0
end sub

' Periodic tasks
sub TasksActors (t as uinteger)
	dim as integer c

	if actors=0 then exit sub

	act_utime = t

	for c=0 to act_count-1
		dim as Actor ptr actor = @actors[c]
		if (actor->state <> 0) then
			TasksActor (actor)
    end if
	next c
end sub

' returns collision between two actors
function CheckActorCollision (actor1 as actor ptr, actor2 as actor ptr) as boolean
	return _
		actor1->hitbox.x1 < actor2->hitbox.x2 andalso _
		actor1->hitbox.x2 > actor2->hitbox.x1 andalso _
		actor1->hitbox.y1 < actor2->hitbox.y2 andalso _
		actor1->hitbox.y2 > actor2->hitbox.y1
end function

' sets generic timeout
sub SetActorTimeout (actor as actor ptr, itimer as integer, timeout as integer)
	actor->timers(itimer) = act_utime + timeout
end sub

' gets generic timeout ended
function GetActorTimeout (actor as actor ptr, itimer as integer) as boolean
	return act_utime >= actor->timers(itimer)
end function

' TasksActor
sub TasksActor (actor as Actor ptr)
	' motion
	actor->x += actor->vx
	actor->y += actor->vy
	if (actor->callback) then
		actor->callback(actor)
  end if

	' updates associated sprite
	if (actor->state <> 0) then
		UpdateActorHitbox(actor)
		TLN_SetSpritePosition (actor->index, actor->x, actor->y)
	else
		TLN_DisableSprite (actor->index)
		TLN_DisableAnimation (actor->index)
	end if
end sub
