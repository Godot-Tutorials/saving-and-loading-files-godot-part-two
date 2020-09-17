extends Node2D

class_name Circle

var circleColor: Color = Color.white
var circleRadius: float = 5.0
var circlePosition: Vector2

func _init(position: Vector2) -> void:
	circlePosition = position

func _draw() -> void:
	self.draw_circle(circlePosition, circleRadius, circleColor)
	

func updatePosition(position: Vector2) -> void:
	circlePosition = position
	update()
