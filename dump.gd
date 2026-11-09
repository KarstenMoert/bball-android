@tool
extends SceneTree

func _init():
	print("=== DUMP START ===")
	print("EditorInterface: ", EditorInterface.get_singleton())
	var export_singleton = EditorExport.get_singleton()
	print("export_singleton: ", export_singleton)
	if export_singleton == null:
		print("KEIN EditorExport gefunden!")
		print("=== DUMP END ===")
		quit()
		return
	print("presets: ", export_singleton.get_export_preset_count())
	for i in range(export_singleton.get_export_preset_count()):
		var preset = export_singleton.get_export_preset(i)
		print("preset: ", preset.get_name())
		var platform = preset.get_platform()
		print("platform: ", platform.get_name())
		var errs = platform.get_configuration_errors()
		print("config errors count: ", errs.size())
		for e in errs:
			print("ERR: [", e, "]")
		var err = ""
		var missing = false
		var can = platform.can_export(preset, err, missing)
		print("can_export: ", can)
		print("can_export err: [", err, "]")
		print("missing_templates: ", missing)
	print("=== DUMP END ===")
	quit()
