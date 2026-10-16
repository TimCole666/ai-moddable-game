class_name AIFakeTransport
extends RefCounted

## Fake AIGateway transport for headless replays (ticket 06): performs NO
## network activity. Responses queued with queue_response() are returned one
## per post() call; the last request is kept for assertions against the
## request dialect (URL, headers, body shape).

var calls := 0
var last_url := ""
var last_headers: PackedStringArray = PackedStringArray()
var last_body := ""

var _responses: Array = []


func queue_response(response: Dictionary) -> void:
	_responses.append(response)


## Transport contract: {"status": int, "body": String} or {"error": String}.
func post(url: String, headers: PackedStringArray, body: String) -> Dictionary:
	calls += 1
	last_url = url
	last_headers = headers
	last_body = body
	if _responses.is_empty():
		return {"error": "fake transport: no queued response"}
	return _responses.pop_front()


## An OpenAI-compatible chat-completions success reply whose assistant
## message content is `content` (the model's output text).
static func chat_response(content: String) -> Dictionary:
	return {
		"status": 200,
		"body": JSON.stringify({"choices": [{"message": {"role": "assistant", "content": content}}]}),
	}
