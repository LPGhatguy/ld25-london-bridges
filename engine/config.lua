return
{
	--core
	engine_path = nil, --filled in by engine initialization
	--core.lib_manage
	lib_core = {":core.utility", ":core.oop", ":core.logging", ":core.event", ":core.lib_manage"},
	lib_engine = {":extend.event_def", ":extend.debris", ":extend.debris_manager", ":extend.delayed"},
	--core.logging
	log_realtime_enabled = true,
	log_history_enabled = true,
	log_recording_enabled = false,
	log_directory = "logs"
}