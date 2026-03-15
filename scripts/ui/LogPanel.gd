extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready():
    EventBus.log_message.connect(_on_log_message)

func _on_log_message(message: String):
    rich_text_label.append_text(message + "\n")
    rich_text_label.scroll_to_line(max(rich_text_label.get_line_count() - 1, 0))
