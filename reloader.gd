################################################################################
##                  stravant's Godot plugin auto-reloader                     ##
##                      For ease of plugin development                        ##
##                              MIT licensed                                  ##
##                                                                            ##
## Call preload("./reloader.gd").new() in your EditorPlugin component's       ##
## _enter_tree method to enable automatic reloading whenever you save changes ##
## to any of the plugin files for a tighter plugin rapid prototyping loop.    ##
##                                                                            ##
## Source: https://gist.github.com/stravant/7aec484bb5e34e3a6196faaa13159ac3  ##
################################################################################

@tool
extends Node

var reloading = false
var startup = 0

func get_plugin_name() -> String:
	var path = get_script().resource_path
	var last_slash_index = path.rfind("/")
	var second_last_slash_index = path.rfind("/", last_slash_index - 1)
	var plugin_name = path.substr(second_last_slash_index + 1,
		last_slash_index - second_last_slash_index - 1)
	return plugin_name

func _init():
	startup = Time.get_ticks_msec()
	var fs = EditorInterface.get_resource_filesystem()
	if fs.filesystem_changed.is_connected(_on_change):
		fs.filesystem_changed.disconnect(_on_change)
	fs.filesystem_changed.connect(_on_change)

func _on_change():
	if reloading:
		return
	if Time.get_ticks_msec() - startup < 1000:
		return
	reloading = true
	var name = get_plugin_name()
	EditorInterface.call_deferred("set_plugin_enabled", name, false)
	EditorInterface.call_deferred("set_plugin_enabled", name, true)
