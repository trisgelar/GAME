extends Node

# Cultural Exhibition Signals
signal on_collect_artifact(artifact_name: String, region: String)
signal on_learn_cultural_info(info: String, region: String)
signal on_complete_region(region: String)
signal on_session_time_update(remaining_time: float)

# NPC Interaction Signals
signal on_npc_interaction(npc_name: String, region: String)
signal on_npc_dialogue_start(npc_name: String, dialogue_id: String)
signal on_npc_dialogue_end(npc_name: String)

# Audio System Signals
signal on_region_audio_change(region: String, audio_type: String)
signal on_play_cultural_audio(audio_id: String, region: String)
signal on_play_ambient_audio(audio_id: String)
signal on_play_menu_audio(audio_id: String)
signal on_play_footstep_audio()
signal on_play_ui_audio(audio_id: String)
signal on_play_player_audio(action: String)
signal on_set_surface_type(surface_type: String)
signal on_set_running_state(running: bool)
signal on_stop_all_audio()

# UI System Signals
signal on_show_cultural_info(info_data: Dictionary)
signal on_hide_cultural_info()
signal on_update_inventory_display()

# Exhibition Progress Signals
signal on_exhibition_progress_update(progress_data: Dictionary)
