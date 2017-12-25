extends Node

const USER_AGENT = "unirest-gdscript/1.0.0"

var _default_user_agent = USER_AGENT
var _default_headers = {}

"""
Create a new request object

@param {Integer} method (See HTTPClient
@param {String} url
@param {String | Dictionary} params
@param {Dictionary} headers
@param {Dictionary} auth
@param {FuncRef} callback
@return {Request}
"""
func request(method, url, params, headers, auth, callback = null):
	var r = Request.new()

	return r.client(_client)
	.header("user-agent", USER_AGENT)
	.header("accept-encoding", "gzip")
	.headers(_default_headers)
	.headers(headers)
	.method(method)
	.url(url)
	.query(params)
	.auth(auth)
	.complete(callback)

"""
Sets the default user agent

@param {String} value
@return {Unirest}
"""
func default_user_agent(value):
	_default_user_agent = str(value)
	return self

"""
Reset the default user agent

@return {Unirest}
"""
func reset_default_user_agent():
	_default_user_agent = USER_AGENT
	return self

"""
Set a default header by name and value

@param {String} name
@param {String} value
@return {Unirest}
"""
func default_header(name, value):
	_default_headers[str(name).to_lower()] = str(value)
	return self

"""
Clear all default headers

@return {Unirest}
"""
func clear_default_headers():
	_default_headers.clear()
	return self

"""
Create a GET request

@param {String} url
@param {Dictionary} params
@param {Dictionary} headers
@param {Dictionary} auth
@param {FuncRef} callback
@return {Request}
"""
func get(url, params = {}, headers = {}, auth = {}, callback = null):
	return request(HTTPClient.METHOD_GET, url, params, headers, auth, callback)

"""
Create a POST request

@param {String} url
@param {Dictionary} params
@param {Dictionary} headers
@param {Dictionary} auth
@param {FuncRef} callback
@return {Request}
"""
func post(url, params = {}, headers = {}, auth = {}, callback = null):
	return request(HTTPClient.METHOD_POST, url, params, headers, auth, callback)

"""
Create a PUT request

@param {String} url
@param {Dictionary} params
@param {Dictionary} headers
@param {Dictionary} auth
@param {FuncRef} callback
@return {Request}
"""
func put(url, params = {}, headers = {}, auth = {}, callback = null):
	return request(HTTPClient.METHOD_PUT, url, params, headers, auth, callback)

"""
Create a PATCH request

@param {String} url
@param {Dictionary} params
@param {Dictionary} headers
@param {Dictionary} auth
@param {FuncRef} callback
@return {Request}
"""
func patch(url, params = {}, headers = {}, auth = {}, callback = null):
	return request(HTTPClient.METHOD_PATCH, url, params, headers, auth, callback)

"""
Create a DELETE request

@param {String} url
@param {Dictionary} params
@param {Dictionary} headers
@param {Dictionary} auth
@param {FuncRef} callback
@return {Request}
"""
func delete(url, params = {}, headers = {}, auth = {}, callback = null):
	return request(HTTPClient.METHOD_DELETE, url, params, headers, auth, callback)

"""
Create a HEAD request

@param {String} url
@param {Dictionary} params
@param {Dictionary} headers
@param {Dictionary} auth
@param {FuncRef} callback
@return {Request}
"""
func head(url, params = {}, headers = {}, auth = {}, callback = null):
	return request(HTTPClient.METHOD_HEAD, url, params, headers, auth, callback)

"""
Create an OPTIONS request

@param {String} url
@param {Dictionary} params
@param {Dictionary} headers
@param {Dictionary} auth
@param {FuncRef} callback
@return {Request}
"""
func options(url, params = {}, headers = {}, auth = {}, callback = null):
	return request(HTTPClient.METHOD_OPTIONS, url, params, headers, auth, callback)

"""
Media type class to defined constants
"""
class MediaType:
	const APPLICATION_JSON = "application/json"
	const APPLICATION_XML = "application/xml"
	const TEXT_PLAIN = "text/plain"
	const TEXT_HTML = "text/html"

"""
Request builder class
"""
class Request:
	var _options = Options.new()
	var _http_request = HTTPRequest.new()
	var response

	func _onrequest_completed(result, response_code, headers, body):
		pass

	"""
	User agent for the request

	@param {String} value
	@return {Request}
	"""
	func agent(value):
		header("user-agent", str(value))
		return self

	"""
	Basic Header Authentication Method

	Supports user being an Object to reflect Request
	Supports user, password to reflect SuperAgent

	@param {String | Dictionary} user
	@param {String} password
	@param {Boolean} sendImmediately
	@return Request
	"""
	func auth(user, password = null, send_immediately = true):
		if typeof(user) == TYPE_DICTIONARY:
			_options.auth = {
				"user": str(user["user"]),
				"password": str(user["password"]),
				"send_immediately": bool(user["send_immediately"])
			}
			h["authorization"] = str("Basic ", Marshalls.utf8_to_base64(str(user, ":", password)))
		else:
			_options.auth = {
				"user": str(user),
				"password": str(password),
				"send_immediately": bool(send_immediately)
			}

		return self

	"""
	Sets the request body

	@param {Mixed} value
	@return {Request}
	"""
	func body(value):
		_options.body = value
		return self

	"""
	Sets the body size limit of the request

	@param {Integer} value
	@return {Request}
	"""
	func body_size_limit(value):
		_options.body_size_limit = int(value)
		return self

	"""
	Sends HTTP Request and awaits Response finalization. Request compression and Response decompression occurs here.
	Upon HTTP Response post-processing occurs and invokes `callback` with a single argument, the `[Response](#response)` object.

	@param {FuncRef} callback
	@return {Request}
	"""
	func complete(callback):
		if !(callback is FuncRef):
			print("Callback must be a function reference")

		_options.callback = callback

		return self

	"""
	Execute the HTTP request

	@return {Error}
	"""
	func execute():
		_http_request.connect("request_completed", self, "_on_request_completed")
		_http_request.body_size_limit = _options.body_size_limit
		_http_request.max_redirects = _options.max_redirects
		_http_request.use_threads = _options.use_threads

		# Build URL
		var url = _options.url
		if _options.qs.size() > 0:
			url += "?"
			for i in _options.qs:
				url += _options.qs[i]

		# Build headers
		var headers = PoolStringArray()
		for i in _options.headers:
			headers.append(str(i, ": ", _options.headers[i]))

		# Execute the http request
		return _http_request.request(
			url,
			headers,
			_options.verify_ssl,
			_options.method,
			_options.body
		)

	"""
	Sets header field to value

	@param {String} field Header field name
	@param {String} value Header field value
	@return {Request}
	"""
	func header(name, value):
		_options.headers[str(name).to_lower()] = value
		return self

	"""
	Alias for Request.header()
	"""
	func headers(value):
		if typeof(value) != TYPE_DICTIONARY:
			return

		for i in value:
			header(i, value[i])
		return self

	"""
	Sets the maximum number of redirects to follow.

	@param {Integer} value
	@return {Request}
	"""
	func max_redirects(value):
		_options.max_redirects = int(value)
		return self

	"""
	Set the HTTP method for the Request

	@param {String | Integer}
	@return {Request}
	"""
	func method(value):
		match str(value).to_upper():
			"GET": _options.method = HTTPClient.METHOD_GET
			"PUT": _options.method = HTTPClient.METHOD_PUT
			"POST": _options.method = HTTPClient.METHOD_POST
			"PATCH": _options.method = HTTPClient.METHOD_PATCH
			"DELETE": _options.method = HTTPClient.METHOD_DELETE
			"HEAD": _options.method = HTTPClient.METHOD_HEAD
			"OPTIONS": _options.method = HTTPClient.METHOD_OPTIONS
			"TRACE": _options.method = HTTPClient.METHOD_TRACE
			"CONNECT": _options.method = HTTPClient.METHOD_CONNECT
			_: _options.method = HTTPClient.METHOD_GET

		return self

	"""
	Serialize value as querystring representation, and append or set on `Request.options.url`

	@param {String | Object} value
	@return {Request}
	"""
	func query(value):
		match typeof(value):
			TYPE_STRING:
				_options.qs.append(value)
			TYPE_DICTIONARY:
				for i in value:
					_options.qs.append(str(i, "=", value[i]))

		return self

	"""
	Data marshalling for HTTP request body data

	Determines whether type is `form` or `json`.
	For irregular mime-types the `.type()` method is used to infer the `content-type` header.

	When mime-type is `application/x-www-form-urlencoded` data is appended rather than overwritten.

	@param {Mixed} value
	@return {Request}
	"""
	func send(value):
		return self

	"""
	Set Content-Type header.

	@param {String} type
	@return {Request}
	"""
	func type(value):
		var type = str(value).to_lower()

		match type:
			"json", MediaType.APPLICATION_JSON: header("content-type", MediaType.APPLICATION_JSON)
			"xml", MediaType.APPLICATION_XML: header("content-type", MediaType.APPLICATION_XML)
			"plain", MediaType.TEXT_PLAIN: header("content-type", MediaType.TEXT_PLAIN)
			"html", MediaType.TEXT_HTML: header("content-type", MediaType.TEXT_HTML)
			_: header("content-type", MediaType.TEXT_PLAIN)

		return self

	"""
	Url, or object parsed from url.parse()
	@param {String | Dictionary} value
	"""
	func url(value):
		var url = str(value)

		# Encode URL
		var parts = url.split("\\?")
		#url = parts[0].replace(" ", "%20")
		_options.url = parts[0]

		if len(url_parts) == 2:
			var query_params = url_parts[1].split("\\&")

			# [0]: name=Bob, [1]: age=32
			for i in query_params:
				query(query_params[i])

		if url.begins_with("https"):
			ssl(true)

		return self

	"""
	Set use_threads flag

	@param {Boolean} value
	@return {Request}
	"""
	func use_threads(value):
		_options.use_threads = bool(value)
		return self

	"""
	Sets verify_ssl flag to require that SSL certificates be valid on Request.options based on given value.
	"""
	func verify_ssl(value):
		_options.verify_ssl = bool(value)
		return self


"""
Response class holding data about the response
"""
class Response:
	var code
	var headers
	var raw_body
	var body

	func _init(code_, headers_, body_):
		code = int(code_)
		headers = headers_
		body = body_

		if headers.has("Content-Encoding"):
			pass

		if headers.has("Content-Type") && headers["Content-Type"] == MediaType.APPLICATION_JSON:
			pass

"""
Request option container for details about the request.
@type {Variant}
"""
class Options:
	"""
	See Request.auth()
	@type {Dictionary}
	"""
	var auth

	"""
	Entity body for certain requests
	@type {String | Dictionary}
	"""
	var body

	"""
	Function callback to call when request finishes
	@type {FuncRef}
	"""
	var callback

	"""
	List of headers with case-sensitive fields.
	@type {Dictionary}
	"""
	var headers = {}

	"""
	Maximum redirects to follow
	@type {Integer}
	"""
	var max_redirects = 5

	"""
	Method obtained from request method arguments.
	@type {Integer}
	"""
	var method = HTTPClient.METHOD_GET

	"""
	Object consisting of querystring values to append to url upon request.
	@type {PoolStringArray}
	"""
	var qs = PoolStringArray()

	"""
	Url obtained from request method arguments.
	@type {String}
	"""
	var url = ""

	"""
	Use threads for improved performance
	@type {Boolean}
	"""
	var use_threads = true

	"""
	Sets verify_ssl flag to require that SSL certificates be valid on Request.options based on given value.
	@type {Boolean}
	"""
	var verify_ssl = true
