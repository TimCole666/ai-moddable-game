class_name AIHttpTransport
extends Node

## Default real transport for AIGateway (ticket 06): one awaited HTTP POST
## per call, through a throwaway HTTPRequest node. This is the ONLY place the
## AI Entry touches the network; tests inject a fake transport instead and
## never construct this node. It never logs the request or response bodies —
## the Authorization header carries the player's API key.

const TIMEOUT_SECONDS := 120.0


## Transport contract (see AIGateway): POST the body, await the response.
## Returns {"status": int, "body": String} on an HTTP completion or
## {"error": String} when the request could not be carried out at all.
func post(url: String, headers: PackedStringArray, body: String) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = TIMEOUT_SECONDS
	add_child(http)
	var err := http.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		http.queue_free()
		return {"error": "request could not start (%s)" % [error_string(err)]}
	var result: Array = await http.request_completed
	http.queue_free()
	var http_result: int = result[0]
	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]
	if http_result != HTTPRequest.RESULT_SUCCESS:
		return {"error": "HTTP request failed (result %d)" % [http_result]}
	return {"status": response_code, "body": response_body.get_string_from_utf8()}
