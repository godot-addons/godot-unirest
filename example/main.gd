extends Node

const Unirest = preload("res://addons/godot-unirest/unirest.gd")

onready var unirest = Unirest.create("https://api.mydomain.com/v1")

func test():
	# Set some default headers for all requests
	unirest.default_headers({
		"Accept": Unirest.MediaType.APPLICATION_JSON,
		"Content-Type": Unirest.MediaType.APPLICATION_JSON
	})
	
	var r = unirest.get("/resource/123").header("Accept-Language", "en").complete(funcref(self, "_on_complete"))
	var status = r.execute()
	
func _on_complete(response):
	print("http status: ", response.response_code)
	
	for i in response.headers:
		print("header: name=", i, ", value=", response.headers[i])
	
	print("body=", response.body)
