extends Node2D

enum CELLTYPES { 
	EMPTY=-1,
	PLAYER, 
	BLOCK, 
	OBJECT
}
export(CELLTYPES) var type = CELLTYPES.PLAYER
