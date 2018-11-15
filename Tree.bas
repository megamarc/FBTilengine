#include "Actor.bas"

type Tree
	as integer depth
	as integer x,y
	as ubyte side
end type

declare sub TreeTasks (actor as Actor ptr)
declare function CalcPerspective (u as single, u0 as single, u1 as single,z as single,z0 as single,z1 as single) as single

function CreateTree( x as integer, y as integer , side as ubyte ) as Actor ptr
	dim as Actor ptr actor
	dim as Tree ptr tree
	dim as integer index = GetAvailableActor (1, MAX_ACTOR)
    
	if index = -1 then return NULL
    
	actor = SetActor(index, 1, 0,0, 136,208, @TreeTasks)
	TLN_ConfigSprite (index, spritesets(SPRITESET_TREES), 0)
	tree = cast(Tree ptr, @(actor->usrdata(0)) )
	tree->x = x
	tree->y = y
	tree->depth = Z_FAR
	tree->side = side
	if side=0 then
		tree->x += pan
    else
		tree->x -= pan
    end if
	return actor
end function

sub TreeTasks(actor as actor ptr)
	
    dim as Tree ptr tree = cast(tree ptr,@(actor->usrdata(0)))
	dim as single scale
	actor->x = Z_NEAR*tree->x / tree->depth
	if (tree->side) then
		actor->x += 136
    else
		actor->x = 136 - actor->x
    end if
	actor->y = tree->y / tree->depth - 52
	scale = cast(single,Z_NEAR/tree->depth)
	TLN_SetSpriteScaling (actor->index, scale,scale)
	tree->depth -= speed
    
	' finaliza
	if (tree->depth<1) then
		ReleaseActor (actor)
    end if
end sub

function CalcPerspective (u as single, u0 as single, u1 as single,z as single,z0 as single,z1 as single) as single
	dim as single a = (u - u0)/(u1 - u0)
	dim as single fval = _
    ((1 - a)*(u0/z0) + a*(u1/z1)) / _
    ((1 - a)*( 1/z0) + a*( 1/z1))
    
	return u0 + fval*(u1 - u0)
end function
