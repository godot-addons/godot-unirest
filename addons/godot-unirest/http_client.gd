extends HTTPClient

signal connected()
signal connecting()
signal disconnected()
signal resolving()
signal resolve_failed()
signal body_received(bytes)
signal ssl_handshake_failed()

var uri

"""
Factory convenience method
"""
static func create_client(url):
	var client = new()
	client.uri = URI.create(url)

	return client

class URI:
	var scheme
	var host
	var port = -1
	var path
	var query = {}

	static func create(url):
		var uri = new()

		if url.begins_with("https://"):
			uri.scheme = "https"
			url = url.substr(0, 8)
		elif url.begins_with("http://"):
			uri.scheme = "http"
			url = url.substr(0, 7)
		else:
			uri.scheme = "http"

		# URL should now be domain.com:port/path/?name=Bob&age=30
		var query_pos = url.find("?")
		if query_pos >= 0:
			# q: name=Bob&age=30
			var q = url.substr(query_pos, len(url))

			# params: ["name=Bob", "age=30"]
			var params = q.split("&")

			# query: { "name": "Bob", "age": 30 }
			for i in params:
				var parts = params[i].split("=")
				uri.query[parts[0]] = parts[1]

			# URL should now be domain.com:port/path/
			url = url.substr(0, query_pos)

		var slash_pos = url.find("/")
		if slash_pos >= 0:
			uri.path = url.substr(slash_pos, len(url))

			# URL should now be domain.com:port
			url = url.substr(0, slash_pos)

		var port_pos = url.find(":")
		if port_pos >= 0:
			uri.port = url.substr(port_pos, len(url))

			# URL should now be domain.com
			url = url.substr(0, port_pos)

		# Assign remaining string to host
		uri.host = url

		if uri.port < 0:
			match uri.scheme:
				"https": uri.port = 443
				"http": uri.port = 80
				_: uri.port = 80

		return uri
