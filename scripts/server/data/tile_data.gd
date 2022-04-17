extends Reference
# THIS CLASS IS UNUSED

var id
var data = {}

func _init(tid: int):
	id = tid
	
func serialize():
	return {
		"id": id,
		"data": data,
	}
