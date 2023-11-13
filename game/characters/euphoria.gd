extends Character

func fact_changed(fact_name: String, new_value: bool):
	match fact_name:
		"transplanted_eye":
			for c in find_child("Expressions").get_children():
				for cc in c.get_children():
					if cc.name == "Eye":
						cc.visible = not new_value
