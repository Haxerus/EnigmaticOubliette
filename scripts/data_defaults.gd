extends Node

var enemy_stats = {
	"default": {
		"name": "Enemy",
		"position": Vector2(0, 0),
		"health": 10,
		"attack": 10,
		"defense": 10,
		"speed": 10,
	},
} setget ,_enemy_stat_getter

var player_stats = {
	"default": {
		"name": "Player",
		"position": Vector2(0, 0),
		"health": 10,
		"attack": 10,
		"defense": 10,
		"speed": 10,
		"movement": 3,
		"attack_range": 1,
	},
} setget ,_player_stat_getter

func _enemy_stat_getter():
	return enemy_stats.duplicate(true)

func _player_stat_getter():
	return player_stats.duplicate(true)
