extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal valueChanged
func colsChanged(value = null):
	get_node("colValue").set_text(str(value))
	emit_signal("valueChanged")

func rowsChanged(value = null):
	get_node("rowValue").set_text(str(value))
	emit_signal("valueChanged")

func _ready():
	get_node("cols").connect("value_changed",self,"colsChanged")
	get_node("rows").connect("value_changed",self,"rowsChanged")