; HEADER_BLOCK_START
; BambuStudio 02.08.02.61
; model printing time: 16m 58s; total estimated time: 34m 26s
; total layer number: 30
; total filament length [mm] : 3094.19
; total filament volume [cm^3] : 7442.41
; total filament weight [g] : 7.74
; filament_density: 1.04,1.24,1.04,1.04,1.04
; filament_diameter: 1.75,1.75,1.75,1.75,1.75
; max_z_height: 6.00
; filament: 1
; support_material_on_wipe_tower: 0
; HEADER_BLOCK_END

; CONFIG_BLOCK_START
; accel_to_decel_enable = 0
; accel_to_decel_factor = 50%
; activate_air_filtration = 1,0,1,1,1
; additional_cooling_fan_speed = 0,70,0,0,0
; additional_fan_full_speed_layer = 0,0,0,0,0
; alternate_extra_wall = 0
; ams_filament_load_time_ams = 0
; ams_filament_load_time_ams_lite = 0
; ams_filament_load_time_n3f_s = 0
; ams_filament_unload_time_ams = 0
; ams_filament_unload_time_ams_lite = 0
; ams_filament_unload_time_n3f_s = 0
; apply_scarf_seam_on_circles = 1
; auxiliary_fan = 1
; avoid_crossing_wall_includes_support = 0
; bed_custom_model = 
; bed_custom_texture = 
; bed_exclude_area = 
; bed_heat_soak_area = 
; bed_temperature_formula = by_highest_temp
; before_layer_change_gcode = 
; best_object_pos = 0.3,0.5
; bottom_color_penetration_layers = 3
; bottom_shell_layers = 4
; bottom_shell_thickness = 0
; bottom_surface_density = 100%
; bottom_surface_pattern = monotonic
; bridge_angle = 0
; bridge_flow = 1
; bridge_no_support = 0
; bridge_speed = 50,50
; brim_object_gap = 0.1
; brim_type = auto_brim
; brim_width = 5
; chamber_temperatures = 60,0,60,60,60
; change_filament_gcode = ;======== H2D ========\n;===== 20260528 =====\nM993 A2 B2 C2 ; nozzle cam detection allow status save.\nM993 A0 B0 C0 ; nozzle cam detection not allowed.\n\n{if (filament_type[next_filament_id] == \"PLA\") ||  (filament_type[next_filament_id] == \"PETG\")\n ||  (filament_type[next_filament_id] == \"PLA-CF\")  ||  (filament_type[next_filament_id] == \"PETG-CF\")}\nM1015.4 S1 K0 ;disable E air printing detect\n{else}\nM1015.4 S0 ; disable E air printing detect\n{endif}\n\nM620 S[next_filament_id]A H[next_hotend]\nM1002 gcode_claim_action : 4\nM204 S9000\n\nG1 Z{max_layer_z + 3.0} F1200\n\nM400\nM106 P1 S0\nM106 P2 S0\n\n{if toolchange_count == 2}\n; get travel path for change filament\n;M620.1 X[travel_point_1_x] Y[travel_point_1_y] F21000 P0\n;M620.1 X[travel_point_2_x] Y[travel_point_2_y] F21000 P1\n;M620.1 X[travel_point_3_x] Y[travel_point_3_y] F21000 P2\n{endif}\n\n{if ((filament_type[current_filament_id] == \"PLA\") || (filament_type[current_filament_id] == \"PLA-CF\") || (filament_type[current_filament_id] == \"PETG\")) && (nozzle_diameter_at_nozzle_id[current_nozzle_id] == 0.2)}\nM620.10 A0 F74.8347 L[flush_length] H{nozzle_diameter_at_nozzle_id[current_nozzle_id]} T{flush_temperatures[current_filament_id]} P[old_filament_temp] S1\n{else}\nM620.10 A0 F{flush_volumetric_speeds[current_filament_id]/2.4053*60*0.8} L[flush_length] H{nozzle_diameter_at_nozzle_id[current_nozzle_id]} T{flush_temperatures[current_filament_id]} P[old_filament_temp] S1\n{endif}\n\n{if ((filament_type[next_filament_id] == \"PLA\") || (filament_type[next_filament_id] == \"PLA-CF\") || (filament_type[next_filament_id] == \"PETG\")) && (nozzle_diameter_at_nozzle_id[next_nozzle_id] == 0.2)}\nM620.10 A1 F74.8347 L[flush_length] H{nozzle_diameter_at_nozzle_id[next_nozzle_id]} T{flush_temperatures[next_filament_id]} P[new_filament_temp] S1\n{else}\nM620.10 A1 F{flush_volumetric_speeds[next_filament_id]/2.4053*60*0.8} L[flush_length] H{nozzle_diameter_at_nozzle_id[next_nozzle_id]} T{flush_temperatures[next_filament_id]} P[new_filament_temp] S1\n{endif}\n\n{if long_retraction_when_cut}\nM620.11 P1 I[current_filament_id] B[current_hotend] E-{retraction_distance_when_cut} F{max((flush_volumetric_speeds[current_filament_id]/2.4053*60), 200)}\n{else}\nM620.11 P0 I[current_filament_id] B[current_hotend] E0\n{endif}\n\n{if long_retraction_when_ec}\nM620.11 K1 I[current_filament_id] B[current_hotend] R{retraction_distance_when_ec} F{max((flush_volumetric_speeds[current_filament_id]/2.4053*60), 200)}\n{else}\nM620.11 K0 I[current_filament_id] B[current_hotend] R0\n{endif}\n\nM620.15 C{new_filament_temp - filament_cooling_before_tower[next_filament_id]}\n\nM628 S1\n{if filament_type[current_filament_id] == \"TPU\"}\nM620.11 S0 L0 I[current_filament_id] B[current_hotend] E-{retraction_distances_when_cut[current_filament_id]} F{max((flush_volumetric_speeds[current_filament_id]/2.4053*60), 200)}\n{else}\n{if (filament_type[current_filament_id] == \"PA\") || (filament_type[current_filament_id] == \"PA-GF\")}\nM620.11 S1 L0 I[current_filament_id] B[current_hotend] R4 D2 E-{retraction_distances_when_cut[current_filament_id]} F{max((flush_volumetric_speeds[current_filament_id]/2.4053*60), 200)}\n{else}\nM620.11 S1 L0 I[current_filament_id] B[current_hotend] R10 D8 E-{retraction_distances_when_cut[current_filament_id]} F{max((flush_volumetric_speeds[current_filament_id]/2.4053*60), 200)}\n{endif}\n{endif}\nM629\n\n{if (filament_type[current_filament_id] == \"TPU\") && (filament_map[current_filament_id] == 2) && (nozzle_volume_types[current_nozzle_id] != \"TPU High Flow\")}\nM620.11 H2 C331\n{else}\nM620.11 H0\n{endif}\n\n{if  (nozzle_volume_types[current_nozzle_id] == \"TPU High Flow\") && (filament_map[current_filament_id] == 2) && (filament_map[next_filament_id] == 1)}\n;sw from R2L&TPU kit, travel run a distance for sketch TPU\nG1 X30 Y30 F5000\nM400\nG1 X300 Y30 F5000\nM400\n{endif}\n\nT[next_filament_id] H[next_hotend]\n\n;deretract\n{if filament_type[next_filament_id] == \"TPU\"}\n{else}\n{if (filament_type[next_filament_id] == \"PA\") || (filament_type[next_filament_id] == \"PA-GF\")}\n;VG1 E1 F{max(new_filament_e_feedrate, 200)}\n;VG1 E1 F{max(new_filament_e_feedrate/2, 100)}\n{else}\n;VG1 E4 F{max(new_filament_e_feedrate, 200)}\n;VG1 E4 F{max(new_filament_e_feedrate/2, 100)}\n{endif}\n{endif}\n\n; VFLUSH_START\n\n{if flush_length>41.5}\n;VG1 E41.5 F{min(old_filament_e_feedrate,new_filament_e_feedrate)}\n;VG1 E{flush_length-41.5} F{new_filament_e_feedrate}\n{else}\n;VG1 E{flush_length} F{min(old_filament_e_feedrate,new_filament_e_feedrate)}\n{endif}\n\nSYNC T{ceil(flush_length / 125) * 5}\n\n; compensate for heating and cooling\n{if flush_length > 0}\n{if flush_temperatures[next_filament_id] > new_filament_temp}\nSYNC T{(flush_temperatures[next_filament_id]-(new_filament_temp - filament_cooling_before_tower[next_filament_id]))/hotend_cooling_rate[filament_map[next_filament_id]-1]}\nSYNC T{(flush_temperatures[next_filament_id]-(new_filament_temp - filament_cooling_before_tower[next_filament_id]))/hotend_heating_rate[filament_map[next_filament_id]-1]}\n{else}\nSYNC T{(new_filament_temp - filament_cooling_before_tower[next_filament_id] -flush_temperatures[next_filament_id])/hotend_cooling_rate[filament_map[next_filament_id]-1]}\nSYNC T{(new_filament_temp - filament_cooling_before_tower[next_filament_id] -flush_temperatures[next_filament_id])/hotend_heating_rate[filament_map[next_filament_id]-1]}\n{endif}\n{endif}\n\n\n; VFLUSH_END\n\nM1002 set_filament_type:{filament_type[next_filament_id]}\n\nM400\nM83\n{if next_filament_id < 255}\n\nM620.10 R{new_extruder_retracted_length}\nM628 S0\n;VM109 S[new_filament_temp]\nM629\nM400\n\n;prime_tower_interface\n{if is_prime_tower_interface && filament_tower_interface_purge_volume !=0}\nG150.1\nM620.13 W0 L{filament_tower_interface_purge_volume} T{filament_tower_interface_print_temp} R0.0\n{endif}\n;prime_tower_interface\n\nM983.3 F{filament_max_volumetric_speed[next_filament_id]/2.4} A0.4 R{new_extruder_retracted_length}\n\nM400\n{if wipe_avoid_perimeter}\nG1 Y320 F30000\nG1 X{wipe_avoid_pos_x} F30000\n{endif}\nG1 Y295 F30000\nG1 Y265 F18000\nG1 Z{max_layer_z + 3.0} F3000\n{if layer_z <= (initial_layer_print_height + 0.001)}\nM204 S[initial_layer_acceleration]\n{else}\nM204 S[default_acceleration]\n{endif}\n{else}\nG1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F12000\n{endif}\nM621 S[next_filament_id]A\n\nM622.1 S0 ;for prev version, default skip\nM1002 judge_flag powerloss_resume_flag\nM622 J1\nM983.3 F{filament_max_volumetric_speed[next_filament_id]/2.4} A0.4 R{new_extruder_retracted_length}\nM400\n{if wipe_avoid_perimeter}\nG1 Y320 F30000\nG1 X{wipe_avoid_pos_x} F30000\n{endif}\nG1 Y295 F30000\nG1 Y265 F18000\nG1 Z{max_layer_z + 3.0} F3000\n{if layer_z <= (initial_layer_print_height + 0.001)}\nM204 S[initial_layer_acceleration]\n{else}\nM204 S[default_acceleration]\n{endif}\nM1002 set_flag powerloss_resume_flag=0\nM623\n\nM993 A3 B3 C3 ; nozzle cam detection allow status restore.\n\n{if (filament_type[next_filament_id]  == \"TPU\")}\nM1015.3 S1;enable tpu clog detect\n{else}\nM1015.3 S0;disable tpu clog detect\n{endif}\n\n{if (filament_type[next_filament_id] == \"PLA\") ||  (filament_type[next_filament_id] == \"PETG\")\n ||  (filament_type[next_filament_id] == \"PLA-CF\")  ||  (filament_type[next_filament_id] == \"PETG-CF\")}\nM1015.4 S1 K1 H{nozzle_diameter_at_nozzle_id[next_nozzle_id]} ;enable E air printing detect\n{else}\nM1015.4 S0 ; disable E air printing detect\n{endif}\n\nM620.6 I[next_filament_id] H[next_hotend] W1 ;enable ams air printing detect\nM620 Q{toolchange_count + 1}\nM1002 gcode_claim_action : 0\n
; circle_compensation_manual_offset = 0
; circle_compensation_speed = 200,200,200,200,200
; close_additional_fan_first_x_layers = 3,1,3,3,3
; close_fan_the_first_x_layers = 3,1,3,3,3
; complete_print_exhaust_fan_speed = 70,70,70,70,70
; cool_plate_temp = 0,35,0,0,0
; cool_plate_temp_initial_layer = 0,35,0,0,0
; cooling_filter_enabled = 0
; cooling_perimeter_transition_distance = 10,10,10,10,10
; cooling_slowdown_logic = uniform_cooling,uniform_cooling,uniform_cooling,uniform_cooling,uniform_cooling
; counter_coef_1 = 0,0,0,0,0
; counter_coef_2 = 0.008,0.008,0.008,0.008,0.008
; counter_coef_3 = -0.041,-0.041,-0.041,-0.041,-0.041
; counter_limit_max = 0.033,0.033,0.033,0.033,0.033
; counter_limit_min = -0.035,-0.035,-0.035,-0.035,-0.035
; counterbore_hole_bridging = none
; curr_bed_type = Textured PEI Plate
; default_acceleration = 4000,4000
; default_ams_type = -1
; default_filament_colour = ;;;;
; default_filament_profile = "Bambu PLA Basic @BBL H2D"
; default_jerk = 0
; default_nozzle_volume_type = Standard,Standard
; default_print_profile = 0.20mm Standard @BBL H2D
; deretraction_speed = 30,30
; detect_floating_vertical_shell = 1
; detect_narrow_internal_solid_infill = 1
; detect_overhang_wall = 1
; detect_thin_wall = 0
; diameter_limit = 50,50,50,50,50
; draft_shield = disabled
; during_print_exhaust_fan_speed = 70,70,70,70,70
; elefant_foot_compensation = 0.15
; embedding_wall_into_infill = 0
; enable_arc_fitting = 1
; enable_circle_compensation = 0
; enable_filament_dynamic_map = 0
; enable_height_slowdown = 0,0
; enable_long_retraction_when_cut = 2
; enable_mixed_color_sublayer = 0
; enable_order_independent_overlap_carving = 0
; enable_overhang_bridge_fan = 1,1,1,1,1
; enable_overhang_speed = 1,1
; enable_pre_heating = 1
; enable_pressure_advance = 0,0,0,0,0
; enable_prime_tower = 0
; enable_support = 0
; enable_support_ironing = 0
; enable_tower_interface_features = 1
; enable_wrapping_detection = 0
; enforce_support_layers = 0
; eng_plate_temp = 100,55,100,100,100
; eng_plate_temp_initial_layer = 100,55,100,100,100
; ensure_vertical_shell_thickness = enabled
; exclude_object = 1
; extruder_ams_count = 1#0|4#0;1#0|4#1
; extruder_clearance_dist_to_rod = 50
; extruder_clearance_height_to_lid = 201
; extruder_clearance_height_to_rod = 47.4
; extruder_clearance_max_radius = 96
; extruder_colour = #018001;#018001
; extruder_max_nozzle_count = 1,1
; extruder_nozzle_stats = Standard#1;Standard#1
; extruder_nozzle_stats_new = 
; extruder_offset = 0x0,0x0
; extruder_printable_area = 0x0,325x0,325x320,0x320#25x0,350x0,350x320,25x320
; extruder_printable_height = 320,325
; extruder_type = Direct Drive,Direct Drive
; extruder_variant_list = "Direct Drive Standard,Direct Drive High Flow,Direct Drive E3D High Flow";"Direct Drive Standard,Direct Drive High Flow,Direct Drive TPU High Flow,Direct Drive E3D High Flow"
; fan_cooling_layer_time = 35,100,35,35,35
; fan_direction = left
; fan_max_speed = 80,100,80,80,80
; fan_min_speed = 10,100,10,10,10
; farthest_point_timelapse = 1
; filament_adaptive_volumetric_speed = 0,0,0,0,0
; filament_adhesiveness_category = 200,100,200,200,200
; filament_bridge_speed = 25,25,25,25,25
; filament_change_length = 10,10,10,10,10
; filament_change_length_nc = 10,10,10,10,10
; filament_colour = #FFFFFF;#161616;#FFF144;#F72323;#161616
; filament_colour_type = 0;0;0;0;0
; filament_cooling_before_tower = 10,10,10,10,10
; filament_cost = 20,20,20,20,20
; filament_density = 1.04,1.24,1.04,1.04,1.04
; filament_dev_ams_drying_ams_limitations = 1;1;0;1;1;1
; filament_dev_ams_drying_heat_distortion_temperature = 100,45,100,100,100
; filament_dev_ams_drying_temperature = 65,80,65,80,45,45,45,45,65,80,65,80,65,80,65,80,65,80,65,80
; filament_dev_ams_drying_time = 12,8,12,8,12,12,12,12,12,8,12,8,12,8,12,8,12,8,12,8
; filament_dev_chamber_drying_bed_temperature = 90,70,90,90,90
; filament_dev_chamber_drying_time = 12,12,12,12,12
; filament_dev_drying_cooling_temperature = 85,45,85,85,85
; filament_dev_drying_softening_temperature = 85,50,85,85,85
; filament_diameter = 1.75,1.75,1.75,1.75,1.75
; filament_enable_overhang_speed = 1,1,1,1,1
; filament_end_gcode = "; filament end gcode \n";"; filament end gcode \n";"; filament end gcode \n";"; filament end gcode \n";"; filament end gcode \n"
; filament_extruder_compatibility = 0,0,0,0,0
; filament_extruder_variant = "Direct Drive Standard";"Direct Drive Standard";"Direct Drive Standard";"Direct Drive Standard";"Direct Drive Standard"
; filament_flow_ratio = 0.95,0.98,0.95,0.95,0.95
; filament_flush_temp = 0,0,0,0,0
; filament_flush_temp_fast = 0,0,0,0,0
; filament_flush_volumetric_speed = 0,0,0,0,0
; filament_ids = GFB98;GFL99;GFB98;GFB98;GFB98
; filament_is_mixed = 0,0,0,0,0
; filament_is_support = 0,0,0,0,0
; filament_map = 1,1,1,1,1
; filament_map_2 = 0,0,0,0,0
; filament_map_mode = Auto For Flush
; filament_max_volumetric_speed = 12,12,12,12,12
; filament_metal_stickiness = None,None,None,None,None
; filament_minimal_purge_on_wipe_tower = 15,15,15,15,15
; filament_mixed_components = ""
; filament_mixed_gradient = 0,0,0,0,0
; filament_mixed_gradient_curve = ;;;;
; filament_mixed_gradient_per_part = 0,0,0,0,0
; filament_mixed_gradient_range = ""
; filament_mixed_sublayer_ratios = ""
; filament_multi_colour = #FFFFFF;#161616;#FFF144;#F72323;#161616
; filament_notes = 
; filament_nozzle_map = 0,0,0,0,0
; filament_overhang_1_4_speed = 0,0,0,0,0
; filament_overhang_2_4_speed = 50,50,50,50,50
; filament_overhang_3_4_speed = 30,30,30,30,30
; filament_overhang_4_4_speed = 10,10,10,10,10
; filament_overhang_totally_speed = 10,10,10,10,10
; filament_pre_cooling_temperature = 0,0,0,0,0
; filament_pre_cooling_temperature_nc = 0,0,0,0,0
; filament_preheat_temperature_delta = 10,10,10,10,10
; filament_prime_volume = 45,45,45,45,45
; filament_prime_volume_nc = 60,60,60,60,60
; filament_printable = 3,3,3,3,3
; filament_ramming_travel_time = 0,0,0,0,0
; filament_ramming_travel_time_nc = 0,0,0,0,0
; filament_ramming_volumetric_speed = -1,-1,-1,-1,-1
; filament_ramming_volumetric_speed_nc = -1,-1,-1,-1,-1
; filament_retract_length_nc = 14,14,14,14,14
; filament_scarf_gap = 0%,15%,0%,0%,0%
; filament_scarf_height = 10%,10%,10%,10%,10%
; filament_scarf_length = 10,10,10,10,10
; filament_scarf_seam_type = none,none,none,none,none
; filament_self_index = 1,2,3,4,5
; filament_settings_id = "Generic ASA @BBL H2D";"Generic PLA @BBL H2D";"Generic ASA @BBL H2D";"Generic ASA @BBL H2D";"Generic ASA @BBL H2D"
; filament_shrink = 100%,100%,100%,100%,100%
; filament_soluble = 0,0,0,0,0
; filament_start_gcode = "; filament start gcode\n";"; filament start gcode\n";"; filament start gcode\n";"; filament start gcode\n";"; filament start gcode\n"
; filament_tower_interface_pre_extrusion_dist = 10,10,10,10,10
; filament_tower_interface_pre_extrusion_length = 0,0,0,0,0
; filament_tower_interface_print_temp = -1,-1,-1,-1,-1
; filament_tower_interface_purge_volume = 20,20,20,20,20
; filament_tower_ironing_area = 4,4,4,4,4
; filament_type = ASA;PLA;ASA;ASA;ASA
; filament_velocity_adaptation_factor = 1,1,1,1,1
; filament_vendor = Generic;Generic;Generic;Generic;Generic
; filament_volume_map = 0,0,0,0,0
; filename_format = {input_filename_base}_{filament_type[0]}_{print_time}.gcode
; fill_multiline = 1
; filter_out_gap_fill = 0
; first_layer_print_sequence = 0
; first_x_layer_fan_speed = 0,0,0,0,0
; first_x_layer_part_fan_speed = 0,0,0,0,0
; flush_into_infill = 0
; flush_into_objects = 0
; flush_into_support = 1
; flush_multiplier = 1,1
; flush_multiplier_fast = 1.2,1.2
; flush_volumes_matrix = 0,90,90,349,90,900,0,900,505,190,900,150,0,321,150,650,230,583,0,230,900,190,900,505,0,0,90,90,364,90,900,0,900,520,205,900,150,0,336,150,665,245,598,0,245,900,205,900,520,0
; flush_volumes_vector = 140,140,140,140,140,140,140,140,140,140
; full_fan_speed_layer = 0,0,0,0,0
; fuzzy_skin = none
; fuzzy_skin_first_layer = 0
; fuzzy_skin_mode = displacement
; fuzzy_skin_noise_type = classic
; fuzzy_skin_octaves = 4
; fuzzy_skin_persistence = 0.5
; fuzzy_skin_point_distance = 0.8
; fuzzy_skin_scale = 1
; fuzzy_skin_thickness = 0.3
; gap_infill_speed = 250,250
; gcode_add_line_number = 0
; gcode_flavor = marlin
; grab_length = 0,0
; group_algo_with_time = 0
; has_filament_switcher = 0
; has_scarf_joint_seam = 0
; head_wrap_detect_zone = 
; hole_coef_1 = 0,0,0,0,0
; hole_coef_2 = -0.008,-0.008,-0.008,-0.008,-0.008
; hole_coef_3 = 0.23415,0.23415,0.23415,0.23415,0.23415
; hole_limit_max = 0.22,0.22,0.22,0.22,0.22
; hole_limit_min = 0.088,0.088,0.088,0.088,0.088
; host_type = octoprint
; hot_plate_temp = 100,55,100,100,100
; hot_plate_temp_initial_layer = 100,55,100,100,100
; hotend_cooling_rate = 2,2
; hotend_heating_rate = 3.6,3.6
; impact_strength_z = 4.9,10,4.9,4.9,4.9
; independent_support_layer_height = 1
; infill_combination = 0
; infill_direction = 45
; infill_instead_top_bottom_surfaces = 0
; infill_jerk = 9
; infill_lock_depth = 1
; infill_rotate_step = 0
; infill_shift_step = 0.4
; infill_wall_overlap = 15%
; initial_layer_acceleration = 500,500
; initial_layer_flow_ratio = 1
; initial_layer_infill_speed = 105,105
; initial_layer_jerk = 9
; initial_layer_line_width = 0.5
; initial_layer_print_height = 0.2
; initial_layer_speed = 50,50
; initial_layer_travel_acceleration = 6000,6000
; inner_wall_acceleration = 0,0
; inner_wall_jerk = 9
; inner_wall_line_width = 0.45
; inner_wall_speed = 150,150
; interface_shells = 0
; interlocking_beam = 0
; interlocking_beam_layer_count = 2
; interlocking_beam_width = 0.8
; interlocking_boundary_avoidance = 2
; interlocking_depth = 2
; interlocking_orientation = 22.5
; internal_bridge_support_thickness = 0.8
; internal_solid_infill_line_width = 0.42
; internal_solid_infill_pattern = zig-zag
; internal_solid_infill_speed = 200,200
; ironing_direction = 45
; ironing_fan_speed = -1,-1,-1,-1,-1
; ironing_flow = 10%
; ironing_inset = 0.21
; ironing_pattern = zig-zag
; ironing_spacing = 0.15
; ironing_speed = 30
; ironing_type = no ironing
; is_infill_first = 0
; layer_change_gcode = ;======== H2D 20250710 layer_change ========\n; layer num/total_layer_count: {layer_num+1}/[total_layer_count]\n; update layer progress\nM73 L{layer_num+1}\nM991 S0 P{layer_num} ;notify layer change\n
; layer_height = 0.2
; line_width = 0.42
; locked_skeleton_infill_pattern = zigzag
; locked_skin_infill_pattern = crosszag
; long_retractions_when_cut = 0,0
; long_retractions_when_ec = 1,1,1,1,1
; machine_bed_mass_Y = 0
; machine_end_gcode = ;========== H2D end ==========\n;===== date: 2026/07/29 =====\n\nM1003 S0\nM73 P100 R0\n\nG392 S0 ;turn off nozzle clog detect\nM993 A0 B0 C0 ; nozzle cam detection not allowed.\n\nM400 ; wait for buffer to clear\nG92 E0 ; zero the extruder\nM211 Z1\n\nG90\nG1 Z{max_layer_z + 0.4} F900 ; lower z a little\nM1002 judge_flag timelapse_record_flag\nM622 J1\n    G150.3\n    M400 ; wait all motion done\n    M991 S0 P-1 ;end smooth timelapse at safe pos\n    M400 S5 ;wait for last picture to be taken\nM623  ;end of \"timelapse_record_flag\"\n\nG90\nG1 Z{max_layer_z + 10} F900 ; lower z a little\n\nG90\nM141 S0 ; turn off chamber heating\nM140 S0 ; turn off bed\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off remote part cooling fan\nM106 P3 S0 ; turn off chamber cooling fan\nM106 P9 S0 ; turn off ext toodhead cooling fan\n; pull back filament to AMS\nM620 S65535\nT65535\nG150.2\nM621 S65535\n\nM620 S65279\nT65279\nG150.2\nM621 S65279\n\nG150.3\n\nM104 S0 T0; turn off hotend\nM104 S0 T1; turn off hotend\n\nM400 ; wait all motion done\nM17 S\nM17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom\n{if (100.0 - max_layer_z/2) > 0}\n    {if (max_layer_z + 100.0 - max_layer_z/2) < 320}\n        G1 Z{max_layer_z + 100.0 - max_layer_z/2} F600\n        G1 Z{max_layer_z + 98.0 - max_layer_z/2}\n    {else}\n        G1 Z320 F600\n        G1 Z320\n    {endif}\n{else}\n    {if (max_layer_z + 4.0) < 320}\n        G1 Z{max_layer_z + 4.0} F600\n        G1 Z{max_layer_z + 2.0}\n    {else}\n        G1 Z320 F600\n        G1 Z320\n    {endif}\n{endif}\nM400 P100\nM17 R ; restore z current\n\nM220 S100  ; Reset feedrate magnitude\nM201.2 K1.0 ; Reset acc magnitude\nM73.2   R1.0 ;Reset left time magnitude\nM1002 set_gcode_claim_speed_level : 0\n\nM1015.4 S0 K0 ;disable air printing detect\n\n;=====printer finish air purification=========\nM622.1 S0\nM1002 judge_flag print_finish_air_filt_flag\n\nM622 J1\nM1002 gcode_claim_action : 66\nM145 P1\nM106 P6 S255\nM400 S180\nM106 P6 S0\nM623\n\nM622 J2\nM1002 gcode_claim_action : 66\nM145 P0\nM106 P3 S127\nM400 S180\nM106 P3 S0\nM623\n;=====printer finish air purification=========\n\n\n;=====printer finish  sound=========\nM17\nM400 S1\nM1006 S1\nM1006 A53 B10 L99 C53 D10 M99 E53 F10 N99 \nM1006 A57 B10 L99 C57 D10 M99 E57 F10 N99 \nM1006 A0 B15 L0 C0 D15 M0 E0 F15 N0 \nM1006 A53 B10 L99 C53 D10 M99 E53 F10 N99 \nM1006 A57 B10 L99 C57 D10 M99 E57 F10 N99 \nM1006 A0 B15 L0 C0 D15 M0 E0 F15 N0 \nM1006 A48 B10 L99 C48 D10 M99 E48 F10 N99 \nM1006 A0 B15 L0 C0 D15 M0 E0 F15 N0 \nM1006 A60 B10 L99 C60 D10 M99 E60 F10 N99 \nM1006 W\n;=====printer finish  sound=========\nM400\nM18\n\n
; machine_hotend_change_time = 0
; machine_load_filament_time = 26
; machine_max_acceleration_e = 5000,5000,5000,5000
; machine_max_acceleration_extruding = 20000,20000,20000,20000
; machine_max_acceleration_retracting = 5000,5000,5000,5000
; machine_max_acceleration_travel = 9000,9000,9000,9000
; machine_max_acceleration_x = 20000,20000,20000,20000
; machine_max_acceleration_y = 20000,20000,20000,20000
; machine_max_acceleration_z = 500,500,500,500
; machine_max_force_Y = 0
; machine_max_jerk_e = 2.5,2.5,2.5,2.5
; machine_max_jerk_x = 9,9,9,9
; machine_max_jerk_y = 9,9,9,9
; machine_max_jerk_z = 3,3,3,3
; machine_max_printed_mass = 0
; machine_max_speed_e = 50,50,50,50
; machine_max_speed_x = 1000,1000,1000,1000
; machine_max_speed_y = 1000,1000,1000,1000
; machine_max_speed_z = 30,30,30,30
; machine_min_extruding_rate = 0,0
; machine_min_travel_rate = 0,0
; machine_pause_gcode = M400 U1
; machine_prepare_compensation_time = 260
; machine_start_gcode = ;===== machine: H2D =========================\n;===== date: 20260605 =====================\n\n;M1002 set_flag extrude_cali_flag=1\n;M1002 set_flag g29_before_print_flag=1\n;M1002 set_flag auto_cali_toolhead_offset_flag=1\n;M1002 set_flag build_plate_detect_flag=1\n\nM993 A0 B0 C0 ; nozzle cam detection not allowed.\n\nM400\n;M73 P99\n\nM960 S10 P1 ; ext fan led\n\n;=====printer start sound ===================\nM17\nM400 S1\nM1006 S1\nM1006 A53 B9 L99 C53 D9 M99 E53 F9 N99\nM1006 A56 B9 L99 C56 D9 M99 E56 F9 N99\nM1006 A61 B9 L99 C61 D9 M99 E61 F9 N99\nM1006 A53 B9 L99 C53 D9 M99 E53 F9 N99\nM1006 A56 B9 L99 C56 D9 M99 E56 F9 N99\nM1006 A61 B18 L99 C61 D18 M99 E61 F18 N99\nM1006 W\n;=====printer start sound ===================\n\n;===== reset machine status =================\nM204 S10000\nM630 S0 P0\n\nG90\nM17 D ; reset motor current to default\nM960 S5 P1 ; turn on logo lamp\nG90\nM1002 set_gcode_claim_speed_level 5 ;Reset speed level\nM220 S100 ;Reset Feedrate\nM221 S100 ;Reset Flowrate\nM73.2   R1.0 ;Reset left time magnitude\nG29.1 Z{+0.0} ; clear z-trim value first\nM983.1 M1\nM901 D4\nM481 S0 ; turn off cutter pos comp\nG28.140 D0; reset pre-extrude z pos\n;===== reset machine status =================\n\nM620 M ;enable remap\n\n;===== avoid end stop =================\nG91\nG380 S2 Z42 F1200\nG380 S2 Z-12 F1200\nG90\n;===== avoid end stop =================\n\n;==== set airduct mode ====\n\n{if (overall_chamber_temperature >= 40)}\n\n    M145 P1 ; set airduct mode to heating mode for heating\n    M106 P2 S0 ; turn off auxiliary fan\n    M106 P3 S0 ; turn off chamber fan\n\n{else}\n    M145 P0 ; set airduct mode to cooling mode for cooling\n    M106 P2 S178 ; turn on auxiliary fan for cooling\n    M106 P3 S127 ; turn on chamber fan for cooling\n    M140 S0 ; stop heatbed from heating\n\n    M1002 gcode_claim_action : 29\n    M191 S0 ; wait for chamber temp\n    M106 P2 S0 ; turn off auxiliary fan\n    {if (min_vitrification_temperature <= 50)}\n        {if (nozzle_diameter_at_nozzle_id[initial_nozzle_id] == 0.2)}\n            M142 P1 R30 S35 T40 U0.3 V0.5 W0.8 O40 ; set PLA/TPU ND0.2 chamber autocooling\n        {else}\n            M142 P1 R30 S40 T45 U0.3 V0.5 W0.8 O45; set PLA/TPU ND0.4 chamber autocooling\n        {endif}\n    {else}\n        {if (!is_all_bbl_filament)}\n            M142 P1 R35 S40 T45 U0.3 V0.5 W0.8 O45 L1 ; set third-party PETG chamber autocooling\n        {else}\n            {if (nozzle_diameter_at_nozzle_id[initial_nozzle_id] == 0.2)}\n                M142 P1 R35 S45 T50 U0.3 V0.5 W0.8 O50 L1 ; set PETG ND0.2 chamber autocooling\n            {else}\n                M142 P1 R35 S50 T55 U0.3 V0.5 W0.8 O55 L1 ; set PETG ND0.4 chamber autocooling\n            {endif}\n        {endif}\n    {endif}\n    {if(cooling_filter_enabled)}\n        M145.2 P0 F0\n    {else}\n        M145.2 P0 F1\n    {endif}\n{endif}\n\n;==== set airduct mode ====\n\n;===== start to heat heatbed & hotend==========\n\n    M1002 set_filament_type:{filament_type[initial_no_support_filament_id]}\n\n    M104 S140 A\n    M140 S[bed_temperature_initial_layer_single]\n\n    ;===== set chamber temperature ==========\n    {if (overall_chamber_temperature >= 40)}\n        M145 P1 ; set airduct mode to heating mode\n        M141 S[overall_chamber_temperature] ; Let Chamber begin to heat\n    {endif}\n    ;===== set chamber temperature ==========\n\n;===== start to heat heatbead & hotend==========\n\n;====== cog noise reduction=================\nM982.2 S1 ; turn on cog noise reduction\n\n;===== first homing start =====\nM1002 gcode_claim_action : 13\n\nG28 X T300\n\nG150.1 F18000 ; wipe mouth to avoid filament stick to heatbed\nG150.3 F18000\nM400 P200\nM972 S24 P0 T2000\n\nM1002 gcode_claim_action : 74 ; Heatbed surface foreign object detection\n{if curr_bed_type==\"Textured PEI Plate\"}\nM972 S26 P0 C0\n{else}\nM972 S36 P0 C0 X1\n{endif}\nM972 S35 P0 C0\n\nM972 S41 P0 T5000 ; trash can anti-collision\n\nM1009 Q1 L1\nG91\nG380 S2 Z30 F1200 ; lower heatbed to move toolhead\nG90\nG1 X175 Y160 F30000\nG28 Z P0 T250\nM1009 Q1 L0\n\n;===== first homing end =====\n\nM400\n;M73 P99\n\n;===== detection start =====\n\nM1002 judge_flag build_plate_detect_flag\nM622 S1\n    ;M1002 gcode_claim_action : 11 ; Indentifying build plate type\n    M972 S19 P0 C0    ; heatbed presence detection\n    M972 S31 P0 T5000 ; toolhead camera dirty detection\n    ;M1002 gcode_claim_action : 73 ; Build plate alignment detection\n    M972 S34 P0 T5000 ; heatbed plate offset detection\nM623\n\nM1002 gcode_claim_action : 72 ; Hotend Type Detection\nT1001\nM972 S14 P0 T5000 ; nozzle type detection\n\nM104 S{nozzle_temperature_initial_layer[initial_no_support_filament_id]} T{filament_map[initial_no_support_filament_id] % 2} ; rise temp in advance\n\nG151 P{filament_map[initial_no_support_filament_id] % 2} M ; plug the heat nozzle\n\n{if max_print_z >= 145}\nM1002 gcode_claim_action : 75 ; Heatbed underside foreign object detection\nG3811 Z{max_print_z}  ; Detect obstacles at the bottom of the heated bed\n{endif}\n\n;===== detection end =====\n\nM400\n;M73 P99\n\n;===== prepare print temperature and material ==========\nM400\nM211 X0 Y0 Z0 ;turn off soft endstop\nM975 S1 ; turn on input shaping\n\nG29.2 S0 ; avoid invalid abl data\n\n{if ((filament_type[initial_no_support_filament_id] == \"PLA\") || (filament_type[initial_no_support_filament_id] == \"PLA-CF\") || (filament_type[initial_no_support_filament_id] == \"PETG\")) && (nozzle_diameter_at_nozzle_id[initial_nozzle_id] == 0.2)}\nM620.10 A0 F74.8347 H{nozzle_diameter_at_nozzle_id[initial_nozzle_id]} T{flush_temperatures[initial_no_support_filament_id]} P{nozzle_temperature_initial_layer[initial_no_support_filament_id]} S1\nM620.10 A1 F74.8347 H{nozzle_diameter_at_nozzle_id[initial_nozzle_id]} T{flush_temperatures[initial_no_support_filament_id]} P{nozzle_temperature_initial_layer[initial_no_support_filament_id]} S1\n{else}\nM620.10 A0 F{flush_volumetric_speeds[initial_no_support_filament_id]/2.4053*60*0.8} H{nozzle_diameter_at_nozzle_id[initial_nozzle_id]} T{flush_temperatures[initial_no_support_filament_id]} P{nozzle_temperature_initial_layer[initial_no_support_filament_id]} S1\nM620.10 A1 F{flush_volumetric_speeds[initial_no_support_filament_id]/2.4053*60*0.8} H{nozzle_diameter_at_nozzle_id[initial_nozzle_id]} T{flush_temperatures[initial_no_support_filament_id]} P{nozzle_temperature_initial_layer[initial_no_support_filament_id]} S1\n{endif}\n\nM620.11 P0 I[initial_no_support_filament_id] B[initial_no_support_hotend] E0\n\n{if long_retraction_when_ec }\nM620.11 K1 I[initial_no_support_filament_id] B[initial_no_support_hotend] R{retraction_distance_when_ec} F{max((flush_volumetric_speeds[initial_no_support_filament_id]/2.4053*60), 200)}\n{else}\nM620.11 K0 I[initial_no_support_filament_id] B[initial_no_support_hotend] R0\n{endif}\n\nM628 S1\n{if filament_type[initial_no_support_filament_id] == \"TPU\"}\n    M620.11 S0 L0 I[initial_no_support_filament_id] B[initial_no_support_hotend] E-{retraction_distances_when_cut[initial_no_support_filament_id]} F{flush_volumetric_speeds[initial_no_support_filament_id]/2.4053*60}\n{else}\n{if (filament_type[initial_no_support_filament_id] == \"PA\") ||  (filament_type[initial_no_support_filament_id] == \"PA-GF\")}\n    M620.11 S1 L0 I[initial_no_support_filament_id] B[initial_no_support_hotend] R4 D2 E-{retraction_distances_when_cut[initial_no_support_filament_id]} F{flush_volumetric_speeds[initial_no_support_filament_id]/2.4053*60}\n{else}\n    M620.11 S1 L0 I[initial_no_support_filament_id] B[initial_no_support_hotend] R10 D8 E-{retraction_distances_when_cut[initial_no_support_filament_id]} F{flush_volumetric_speeds[initial_no_support_filament_id]/2.4053*60}\n{endif}\n{endif}\nM629\n\nM620 S[initial_no_support_filament_id]A H[initial_no_support_hotend] ; switch material if AMS exist\nM1002 gcode_claim_action : 4\nM1002 set_filament_type:UNKNOWN\nM400\nT[initial_no_support_filament_id] H[initial_no_support_hotend]\nM400\nM628 S0\nM629\nM400\nM1002 set_filament_type:{filament_type[initial_no_support_filament_id]}\nM621 S[initial_no_support_filament_id]A\n\nM104 S{nozzle_temperature_initial_layer[initial_no_support_filament_id]}\nM400\nM106 P1 S0\n\nG29.2 S1\n;===== prepare print temperature and material ==========\n\nM400\n;M73 P99\n\n;===== auto extrude cali start =========================\nM975 S1\nM1002 judge_flag extrude_cali_flag\n\nM622 J0\n    M983.3 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4} A0.4 ; cali dynamic extrusion compensation\nM623\n\nM622 J1\n    M1002 set_filament_type:{filament_type[initial_no_support_filament_id]}\n    M1002 gcode_claim_action : 8\n\n    M109 S{nozzle_temperature[initial_no_support_filament_id]}\n\n    G90\n    M83\n    M983.3 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4} A0.4 ; cali dynamic extrusion compensation\n\n    M400\n    M106 P1 S255\n    M400 S5\n    M106 P1 S0\n    G150.3\nM623\n\nM622 J2\n    M1002 set_filament_type:{filament_type[initial_no_support_filament_id]}\n    M1002 gcode_claim_action : 8\n\n    M109 S{nozzle_temperature[initial_no_support_filament_id]}\n\n    G90\n    M83\n    M983.3 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4} A0.4 ; cali dynamic extrusion compensation\n\n    M400\n    M106 P1 S255\n    M400 S5\n    M106 P1 S0\n    G150.3\nM623\n\n;===== auto extrude cali end =========================\n\n{if filament_type[initial_no_support_filament_id] == \"TPU\"}\n    G150.2\n    G150.1\n    G150.2\n    G150.1\n    G150.2\n    G150.1\n{else}\n    M106 P1 S0\n    M400 S2\n    M109 S{nozzle_temperature[initial_no_support_filament_id]} ; wait tmpr to extrude\n    M83\n    {if(nozzle_diameter_at_nozzle_id[initial_nozzle_id] == 0.8)}\n        G1 E60 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4053*60}\n    {else}\n        G1 E45 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4053*60}\n    {endif}\n    G1 E-3 F1800\n    M400 P500\n    G150.2\n    G150.1\n{endif}\n\nG91\nG1 Y-16 F12000 ; move away from the trash bin\nG90\n\nM400\n;M73 P99\n\n;===== wipe right nozzle start =====\n\nM1002 gcode_claim_action : 14\n    G150 T{nozzle_temperature_initial_layer[initial_no_support_filament_id]}\n    {if (overall_chamber_temperature >= 40)}\n        G150 T{nozzle_temperature_initial_layer[initial_no_support_filament_id] - 80}\n    {endif}\nM106 S255 ; turn on fan to cool the nozzle\n\n;===== wipe left nozzle end =====\n\nM400\n;M73 P99\n\n{if (overall_chamber_temperature >= 40)}\n    M1002 gcode_claim_action : 49\n    M191 S[overall_chamber_temperature] ; wait for chamber temp\n{endif}\n\nM400\n;M73 P99\n\n;===== bed leveling ==================================\n\nM1002 judge_flag g29_before_print_flag\n\nM190 S[bed_temperature_initial_layer_single]; ensure bed temp\nM109 S140 A\nM106 S0 ; turn off fan , too noisy\n\nG91\nG1 Z5 F1200\nG90\nG1 X175 Y160 F30000\n\nM622 J1\n    M1002 gcode_claim_action : 1\n    G29.20 A3\n    G29 A1 O X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]} R\n    M400\nM623\n\nM622 J2\n    M1002 gcode_claim_action : 1\n    {if has_tpu_in_first_layer}\n        G29.20 A3\n        G29 A1 O X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]} R\n    {else}\n        G29.20 A4\n        G29 A2 O X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]} R\n    {endif}\n    M400\nM623\n\nM622 J0\n    G28 R\nM623\n\n;===== bed leveling end ================================\n\n;===== z ofst cali start =====\n\n    M190 S[bed_temperature_initial_layer_single]; ensure bed temp\n\n    G383 O0 M2 T140\n\n;===== z ofst cali end =====\n\nG39.1 ; cali nozzle wrapped detection pos\n\nG90\nG1 Z5 F1200\nG1 X270 Y-0.5 F60000\nG28.140 S0 ; cali pre-extrude z pos\n\nM141 S[overall_chamber_temperature]\nM104 S{nozzle_temperature_initial_layer[initial_no_support_filament_id]} A\n\n;===== mech mode sweep start =====\n    M1002 gcode_claim_action : 3\n\n    G90\n    G1 Z5 F1200\n    G1 X187 Y160 F20000\n    T1000\n    M400 P200\n\n    M970.3 Q1 A5 K0 O1\n    M974 Q1 S2 P0\n\n    M970.3 Q0 A5 K0 O1\n    M974 Q0 S2 P0\n\n    M970.2 Q2 K0 W38 Z0.01\n    M974 Q2 S2 P0\n\n    M975 S1\n;===== mech mode sweep end =====\n\nM400\n;M73 P99\n\nG150.3 ; move to garbage can to wait for temp\nM1026\nG29.9\n\n;===== xy ofst cali start =====\n\nM1002 judge_flag auto_cali_toolhead_offset_flag\n\nM622 J0\n    M1012.5 N1 R1\nM623\n\nM622 J1\n    M1002 gcode_claim_action : 39\n    M141 S0\n    M620.17 T0 S{nozzle_temperature_initial_layer[(first_non_support_filaments[0] != -1 ? first_non_support_filaments[0] : (first_filaments[0] != -1 ? first_filaments[0] : 0))]} L{(first_non_support_filaments[0] != -1 ? first_non_support_filaments[0] : (first_filaments[0] != -1 ? first_filaments[0] : 0))}\n    M620.17 T1 S{nozzle_temperature_initial_layer[(first_non_support_filaments[1] != -1 ? first_non_support_filaments[1] : (first_filaments[1] != -1 ? first_filaments[1] : 0))]} L{(first_non_support_filaments[1] != -1 ? first_non_support_filaments[1] : (first_filaments[1] != -1 ? first_filaments[1] : 0))}\n    M620 D[initial_no_support_hotend]\n    G383 O1 T{nozzle_temperature_initial_layer[initial_no_support_filament_id]} L{initial_no_support_filament_id}\n    M141 S[overall_chamber_temperature]\nM623\n\nM622 J2\n    M1002 gcode_claim_action : 39\n    M141 S0\n    M620.17 T0 S{nozzle_temperature_initial_layer[(first_non_support_filaments[0] != -1 ? first_non_support_filaments[0] : (first_filaments[0] != -1 ? first_filaments[0] : 0))]} L{(first_non_support_filaments[0] != -1 ? first_non_support_filaments[0] : (first_filaments[0] != -1 ? first_filaments[0] : 0))}\n    M620.17 T1 S{nozzle_temperature_initial_layer[(first_non_support_filaments[1] != -1 ? first_non_support_filaments[1] : (first_filaments[1] != -1 ? first_filaments[1] : 0))]} L{(first_non_support_filaments[1] != -1 ? first_non_support_filaments[1] : (first_filaments[1] != -1 ? first_filaments[1] : 0))}\n    M620 D[initial_no_support_hotend]\n    G383.3 T{nozzle_temperature_initial_layer[initial_no_support_filament_id]} L{initial_no_support_filament_id}\n    M141 S[overall_chamber_temperature]\nM623\n;===== xy ofst cali end =====\n\nM400\n;M73 P99\n\nM1002 gcode_claim_action : 0\nM400\n\n;============switch again==================\nM211 X0 Y0 Z0 ;turn off soft endstop\nG91\nG1 Z6 F1200\nG90\nM1002 set_filament_type:{filament_type[initial_no_support_filament_id]}\nM620 S[initial_no_support_filament_id]A H[initial_no_support_hotend]\nM400\nT[initial_no_support_filament_id] H[initial_no_support_hotend]\nM400\nM628 S0\nM629\nM400\nM621 S[initial_no_support_filament_id]A\n\n;============switch again==================\n\nM400\n;M73 P99\n\n;===== wait temperature reaching the reference value =======\n\nM104 S{nozzle_temperature_initial_layer[initial_no_support_filament_id]} ; rise to print tmpr\n\nM140 S[bed_temperature_initial_layer_single]\nM190 S[bed_temperature_initial_layer_single]\n\n    ;========turn off light and fans =============\n    M960 S1 P0 ; turn off laser\n    M960 S2 P0 ; turn off laser\n    M106 S0 ; turn off fan\n    M106 P2 S0 ; turn off big fan\n    ;==== set ext toodhead cooling fan ====\n    {if (min_vitrification_temperature <= 50)}\n    M106 P9 S255\n    {endif}\n    ;============set motor current==================\n    M400 S1\n\n;===== wait temperature reaching the reference value =======\n\nM400\n;M73 P99\n\n;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==\n    {if curr_bed_type==\"Textured PEI Plate\"}\n        {if nozzle_diameter_at_nozzle_id[initial_nozzle_id] == 0.2}\n            G29.1 Z{-0.01} ; for Textured PEI Plate\n        {else}\n            G29.1 Z{-0.02} ; for Textured PEI Plate\n        {endif}\n    {else}\n        {if nozzle_diameter_at_nozzle_id[initial_nozzle_id] == 0.2}\n            G29.1 Z{0.01}\n        {endif}\n    {endif}\n\nG150.1\n\nM975 S1 ; turn on mech mode supression\nM983.4 S1 ; turn on deformation compensation\nG29.2 S1 ; turn on pos comp\nG29.7 S1\n\nG90\nG1 Z5 F1200\nG1 Y295 F30000\nG1 Y265 F18000\n\n;===== nozzle load line ===============================\n    G29.2 S1 ; ensure z comp turn on\n    G90\n    M83\n    G1 Z5 F1200\n    G1 X270 Y-0.5 F60000\n    G28.14 R0\n    G29.2 S0\n    G91\n    G1 Z0.8 F1200\n    G90\n    G1 X250 F60000\n    M400 P50\n    M500 D1\n    M400 S3\n    M109 S{nozzle_temperature_initial_layer[initial_no_support_filament_id]}\n    M83\n{if nozzle_diameter_at_nozzle_id[initial_nozzle_id] == 0.8}\n    G1 E5 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4053*60}\n{endif}\n{if (filament_type[initial_no_support_filament_id] == \"TPU\")}\n    G1 E5 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4053*60}\n{endif}\n    G1 E5 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4053*60}\n    G1 X290 E10 F{filament_max_volumetric_speed[initial_no_support_filament_id]/2.4053*60}\n    G91\n    G3 Z0.4 I1.217 J0 P1 F60000\n    G90\n    M83\n    G29.2 S1 ; ensure z comp turn on\n;===== noozle load line end ===========================\n\nM400\n;M73 P99\n\nM993 A1 B1 C1 ; nozzle cam detection allowed.\n\n{if (filament_type[initial_no_support_filament_id] == \"TPU\")}\nM1015.3 S1;enable tpu clog detect\n{else}\nM1015.3 S0;disable tpu clog detect\n{endif}\n\n{if (filament_type[initial_no_support_filament_id] == \"PLA\") ||  (filament_type[initial_no_support_filament_id] == \"PETG\")\n ||  (filament_type[initial_no_support_filament_id] == \"PLA-CF\")  ||  (filament_type[initial_no_support_filament_id] == \"PETG-CF\")}\nM1015.4 S1 K1 H{nozzle_diameter_at_nozzle_id[initial_nozzle_id]} ;enable E air printing detect\n{else}\nM1015.4 S0 K0 H{nozzle_diameter_at_nozzle_id[initial_nozzle_id]} ;disable E air printing detect\n{endif}\n\nM620.6 I[initial_no_support_filament_id] H[initial_no_support_hotend] W1 ;enable ams air printing detect\nM620 Q1\n\nM211 Z1\nG29.99\n
; machine_switch_extruder_time = 5.6
; machine_unload_filament_time = 26
; master_extruder_id = 2
; max_bridge_length = 0
; max_layer_height = 0.28,0.28
; max_travel_detour_distance = 0
; min_bead_width = 85%
; min_feature_size = 25%
; min_layer_height = 0.08,0.08
; minimum_sparse_infill_area = 15
; mmu_segmented_region_interlocking_depth = 0
; mmu_segmented_region_max_width = 0
; monotonic_travel_into_wall = 45%
; no_slow_down_for_cooling_on_outwalls = 0,0,0,0,0
; nozzle_diameter = 0.4,0.4
; nozzle_flush_dataset = 1,1
; nozzle_height = 4
; nozzle_temperature = 260,220,260,260,260
; nozzle_temperature_initial_layer = 260,220,260,260,260
; nozzle_temperature_range_high = 280,240,280,280,280
; nozzle_temperature_range_low = 240,190,240,240,240
; nozzle_type = hardened_steel,hardened_steel
; nozzle_volume = 130,145
; nozzle_volume_type = Standard,Standard
; only_one_wall_first_layer = 0
; ooze_prevention = 0
; other_layers_print_sequence = 0
; other_layers_print_sequence_nums = 0
; outer_wall_acceleration = 2000,2000
; outer_wall_jerk = 9
; outer_wall_line_width = 0.42
; outer_wall_speed = 60,60
; overhang_1_4_speed = 0,0
; overhang_2_4_speed = 30,30
; overhang_3_4_speed = 10,10
; overhang_4_4_speed = 10,10
; overhang_fan_speed = 80,100,80,80,80
; overhang_fan_threshold = 25%,50%,25%,25%,25%
; overhang_threshold_participating_cooling = 95%,95%,95%,95%,95%
; overhang_totally_speed = 10,10
; override_filament_scarf_seam_setting = 0
; override_process_overhang_speed = 0,0,0,0,0
; physical_extruder_map = 1,0
; post_process = 
; pre_start_fan_time = 0,0,0,0,0
; precise_outer_wall = 0
; precise_z_height = 0
; pressure_advance = 0.02,0.02,0.02,0.02,0.02
; prime_tower_brim_width = -1
; prime_tower_enable_framework = 0
; prime_tower_extra_rib_length = 0
; prime_tower_fillet_wall = 1
; prime_tower_flat_ironing = 1
; prime_tower_infill_gap = 150%
; prime_tower_lift_height = -1
; prime_tower_lift_speed = 90
; prime_tower_max_speed = 90
; prime_tower_rib_wall = 1
; prime_tower_rib_width = 8
; prime_tower_skip_points = 1
; prime_tower_width = 60
; prime_volume_mode = Default
; print_compatible_printers = "Bambu Lab H2D 0.4 nozzle"
; print_extruder_id = 1,2
; print_extruder_variant = "Direct Drive Standard";"Direct Drive Standard"
; print_flow_ratio = 1
; print_in_clockwise = 0
; print_sequence = by layer
; print_settings_id = 0.20mm Balanced Strength @BBL H2D
; printable_area = 0x0,350x0,350x320,0x320
; printable_height = 325
; printer_extruder_id = 1,2
; printer_extruder_variant = "Direct Drive Standard";"Direct Drive Standard"
; printer_model = Bambu Lab H2D
; printer_notes = 
; printer_settings_id = Bambu Lab H2D 0.4 nozzle
; printer_structure = corexy
; printer_technology = FFF
; printer_variant = 0.4
; printhost_authorization_type = key
; printhost_ssl_ignore_revoke = 0
; printing_by_object_gcode = 
; process_notes = 
; raft_contact_distance = 0.1
; raft_expansion = 1.5
; raft_first_layer_density = 90%
; raft_first_layer_expansion = -1
; raft_layers = 0
; reduce_crossing_wall = 0
; reduce_fan_stop_start_freq = 1,1,1,1,1
; reduce_infill_retraction_mode = Auto
; required_nozzle_HRC = 3,3,3,3,3
; resolution = 0.012
; retract_before_wipe = 0%,0%
; retract_length_toolchange = 2,2
; retract_lift_above = 0,0
; retract_lift_below = 319,319
; retract_restart_extra = 0,0
; retract_restart_extra_toolchange = 0,0
; retract_when_changing_layer = 1,1
; retraction_distances_when_cut = 10,10
; retraction_distances_when_ec = 10,10,10,10,10
; retraction_length = 0.8,0.8
; retraction_minimum_travel = 1,1
; retraction_speed = 30,30
; role_base_wipe_speed = 1
; scan_first_layer = 0
; scarf_angle_threshold = 155
; seam_gap = 15%
; seam_placement_away_from_overhangs = 0
; seam_position = aligned
; seam_slope_conditional = 1
; seam_slope_entire_loop = 0
; seam_slope_gap = 0
; seam_slope_inner_walls = 1
; seam_slope_min_length = 10
; seam_slope_start_height = 10%
; seam_slope_steps = 10
; seam_slope_type = none
; silent_mode = 0
; single_extruder_multi_material = 1
; skeleton_infill_density = 15%
; skeleton_infill_line_width = 0.45
; skin_infill_density = 15%
; skin_infill_depth = 2
; skin_infill_line_width = 0.45
; skirt_distance = 2
; skirt_height = 1
; skirt_loops = 0
; skirt_per_object = 1
; slice_closing_radius = 0.049
; slicing_mode = regular
; slow_down_for_layer_cooling = 1,1,1,1,1
; slow_down_layer_time = 3,8,3,3,3
; slow_down_min_speed = 20,20,20,20,20
; slowdown_end_acc = 100000,100000
; slowdown_end_height = 400,400
; slowdown_end_speed = 1000,1000
; slowdown_start_acc = 100000,100000
; slowdown_start_height = 0,0
; slowdown_start_speed = 1000,1000
; small_perimeter_speed = 50%,50%
; small_perimeter_threshold = 0,0
; smooth_coefficient = 4
; smooth_speed_discontinuity_area = 1
; solid_infill_filament = 0
; sparse_infill_acceleration = 100%,100%
; sparse_infill_anchor = 400%
; sparse_infill_anchor_max = 20
; sparse_infill_density = 15%
; sparse_infill_filament = 0
; sparse_infill_lattice_angle_1 = -45
; sparse_infill_lattice_angle_2 = 45
; sparse_infill_line_width = 0.45
; sparse_infill_pattern = grid
; sparse_infill_speed = 200,200
; spiral_mode = 0
; spiral_mode_max_xy_smoothing = 200%
; spiral_mode_smooth = 0
; standby_temperature_delta = -5
; start_end_points = 30x-3,54x245
; supertack_plate_temp = 0,45,0,0,0
; supertack_plate_temp_initial_layer = 0,45,0,0,0
; support_air_filtration = 0
; support_angle = 0
; support_base_pattern = default
; support_base_pattern_spacing = 2.5
; support_bottom_interface_spacing = 0.5
; support_bottom_z_distance = 0.2
; support_chamber_temp_control = 1
; support_cooling_filter = 1
; support_critical_regions_only = 0
; support_expansion = 0
; support_fast_purge_mode = 0
; support_filament = 0
; support_interface_bottom_layers = 2
; support_interface_filament = 0
; support_interface_loop_pattern = 0
; support_interface_not_for_body = 1
; support_interface_pattern = auto
; support_interface_spacing = 0.5
; support_interface_speed = 80,80
; support_interface_top_layers = 2
; support_ironing_direction = 0
; support_ironing_flow = 10%
; support_ironing_inset = 0
; support_ironing_pattern = zig-zag
; support_ironing_spacing = 0.15
; support_ironing_speed = 30
; support_line_width = 0.42
; support_object_first_layer_gap = 0.2
; support_object_skip_flush = 0
; support_object_xy_distance = 0.35
; support_on_build_plate_only = 0
; support_remove_small_overhang = 1
; support_speed = 150,150
; support_style = default
; support_threshold_angle = 30
; support_top_z_distance = 0.2
; support_type = tree(auto)
; symmetric_infill_y_axis = 0
; temperature_vitrification = 100,45,100,100,100
; template_custom_gcode = 
; textured_plate_temp = 100,55,100,100,100
; textured_plate_temp_initial_layer = 100,55,100,100,100
; thick_bridges = 0
; thumbnail_size = 50x50
; time_lapse_gcode = ;======== H2D 20260731========\n; SKIPPABLE_START\n; SKIPTYPE: timelapse\nM622.1 S1 ; for prev firmware, default turned on\n\nM1002 judge_flag timelapse_record_flag\nM622 J1\n    {if !spiral_mode && !timelapse_inline_photo}\n        M993 A2 B2 C2\n        M993 A0 B0 C0\n    {endif}\n\n    {if timelapse_inline_photo}\n        M971 S11 C10 O0\n        M1004 S5 P1  ; external shutter\n    {else}\n        M622.1 S0 ; for prev firmware, default turn off\n        M1002 set_flag smooth_safe_pos_suppoprt_flag=1\n        M1002 judge_flag smooth_safe_pos_suppoprt_flag\n        \n        M622 J0\n            {if !spiral_mode && !(has_timelapse_safe_pos && timelapse_type == 0) }\n                {if most_used_physical_extruder_id!= curr_physical_extruder_id || timelapse_type == 1}\n                    M83\n                    G1 Z{max_layer_z + 0.4} F1200\n                    M400\n                {endif}\n            {endif}\n\n            {if has_timelapse_safe_pos && timelapse_type == 0 && !spiral_mode}\n                M9711 M{timelapse_type} E{most_used_physical_extruder_id} X{timelapse_pos_x} Y{timelapse_pos_y} Z{layer_z + (farthest_point_timelapse_enabled ? 0.0 : 0.4)} S11 C10 O0 T3000\n            {else}\n                {if spiral_mode}\n                    M971 S11 C10 O0\n                    M1004 S5 P1  ; external shutter\n                {else}\n                    M9711 M{timelapse_type} E{most_used_physical_extruder_id} Z{layer_z + (farthest_point_timelapse_enabled ? 0.0 : 0.4)} S11 C10 O0 T3000\n                {endif}\n            {endif}\n\n            {if !spiral_mode && !(has_timelapse_safe_pos && timelapse_type == 0) }\n                {if most_used_physical_extruder_id!= curr_physical_extruder_id || timelapse_type == 1}\n                    G90\n                    G1 Z{max_layer_z + 3.0} F1200\n                    G1 Y295 F30000\n                    G1 Y265 F18000\n                    M83\n                {endif}\n            {endif}\n        M623\n\n        M622 J1\n            {if !spiral_mode && !(has_timelapse_safe_pos) }\n                {if most_used_physical_extruder_id!= curr_physical_extruder_id || timelapse_type == 1}\n                    M83\n                    G1 Z{max_layer_z + 0.4} F1200\n                    M400\n                {endif}\n            {endif}\n\n            {if has_timelapse_safe_pos && !spiral_mode}\n                M9711 M{timelapse_type} E{most_used_physical_extruder_id} U{timelapse_pos_x} V{timelapse_pos_y} Z{layer_z + (farthest_point_timelapse_enabled ? 0.0 : 0.4)} S11 C10 O0 T3000\n            {else}\n                {if spiral_mode}\n                    M971 S11 C10 O0\n                    M1004 S5 P1  ; external shutter\n                {else}\n                    M9711 M{timelapse_type} E{most_used_physical_extruder_id} Z{layer_z + (farthest_point_timelapse_enabled ? 0.0 : 0.4)} S11 C10 O0 T3000\n                {endif}\n            {endif}\n\n            {if !spiral_mode && !(has_timelapse_safe_pos) }\n                {if most_used_physical_extruder_id!= curr_physical_extruder_id || timelapse_type == 1}\n                    G90\n                    G1 Z{max_layer_z + 3.0} F1200\n                    G1 Y295 F30000\n                    G1 Y265 F18000\n                    M83\n                {endif}\n            {endif}\n        M623\n    {endif}\n    \n    {if !spiral_mode && !timelapse_inline_photo}\n        M993 A3 B3 C3\n    {endif}\nM623\n; SKIPPABLE_END\n
; timelapse_type = 0
; top_area_threshold = 200%
; top_color_penetration_layers = 5
; top_one_wall_type = all top
; top_shell_layers = 6
; top_shell_thickness = 1
; top_solid_infill_flow_ratio = 1,1
; top_surface_acceleration = 2000,2000
; top_surface_density = 100%
; top_surface_jerk = 9
; top_surface_line_width = 0.42
; top_surface_pattern = monotonicline
; top_surface_speed = 150,150
; top_z_overrides_xy_distance = 0
; travel_acceleration = 10000,10000
; travel_jerk = 9
; travel_short_distance_acceleration = 250,250
; travel_speed = 500,500
; travel_speed_z = 0,0
; tree_support_branch_angle = 45
; tree_support_branch_diameter = 2
; tree_support_branch_diameter_angle = 5
; tree_support_branch_distance = 5
; tree_support_wall_count = -1
; upward_compatible_machine = "Bambu Lab H2D Pro 0.4 nozzle"
; use_firmware_retraction = 0
; use_relative_e_distances = 1
; vertical_shell_speed = 80%,80%
; volumetric_speed_coefficients = "0 0 0 0 0 0";"0 0 0 0 0 0";"0 0 0 0 0 0";"0 0 0 0 0 0";"0 0 0 0 0 0"
; wall_distribution_count = 1
; wall_filament = 0
; wall_generator = classic
; wall_loops = 2
; wall_sequence = inner wall/outer wall
; wall_transition_angle = 10
; wall_transition_filter_deviation = 25%
; wall_transition_length = 100%
; wipe = 1,1
; wipe_distance = 2,2
; wipe_speed = 80%
; wipe_tower_no_sparse_layers = 0
; wipe_tower_rotation_angle = 0
; wipe_tower_x = 165
; wipe_tower_y = 250
; wrapping_detection_gcode = ;======== H2D 20250729 clumping ========\n{if !spiral_mode}\n    M622.1 S0 ; for previous firmware, default turn off\n    M1002 set_flag g39_forced_detection_flag=1\n    M1002 judge_flag g39_forced_detection_flag\n    M622 J1\n        {if layer_num == 3 || layer_num == 10 || layer_num == 19}\n            M993 A2 B2 C2 ; nozzle cam detection allow status save.\n            M993 A0 B0 C0 ; nozzle cam detection not allowed.\n\n            M400 P100\n\n            G39\n\n            G90\n            G1 Y295 F30000\n            G1 Y265 F18000\n            \n            M993 A3 B3 C3 ; nozzle cam detection allow status restore.\n        {endif}\n    M623\n{endif}\n
; wrapping_detection_layers = 20
; wrapping_exclude_area = 145x310,256x310,256x326,145x326
; xy_contour_compensation = 0
; xy_hole_compensation = 0
; z_direction_outwall_speed_continuous = 1
; z_hop = 0.4,0.4
; z_hop_types = Auto Lift,Auto Lift
; CONFIG_BLOCK_END

; EXECUTABLE_BLOCK_START
M73 P0 R34
M201 X20000 Y20000 Z500 E5000
M203 X1000 Y1000 Z30 E50
M204 P20000 R5000 T20000
M205 X9.00 Y9.00 Z3.00 E2.50
M106 S0
M106 P2 S0
; FEATURE: Custom
;===== machine: H2D =========================
;===== date: 20260605 =====================

;M1002 set_flag extrude_cali_flag=1
;M1002 set_flag g29_before_print_flag=1
;M1002 set_flag auto_cali_toolhead_offset_flag=1
;M1002 set_flag build_plate_detect_flag=1

M993 A0 B0 C0 ; nozzle cam detection not allowed.

M400
;M73 P99

M960 S10 P1 ; ext fan led

;=====printer start sound ===================
M17
M400 S1
M1006 S1
M1006 A53 B9 L99 C53 D9 M99 E53 F9 N99
M1006 A56 B9 L99 C56 D9 M99 E56 F9 N99
M1006 A61 B9 L99 C61 D9 M99 E61 F9 N99
M1006 A53 B9 L99 C53 D9 M99 E53 F9 N99
M1006 A56 B9 L99 C56 D9 M99 E56 F9 N99
M1006 A61 B18 L99 C61 D18 M99 E61 F18 N99
M1006 W
;=====printer start sound ===================

;===== reset machine status =================
M204 S10000
M630 S0 P0

G90
M17 D ; reset motor current to default
M960 S5 P1 ; turn on logo lamp
G90
M1002 set_gcode_claim_speed_level 5 ;Reset speed level
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
G29.1 Z0 ; clear z-trim value first
M983.1 M1
M901 D4
M481 S0 ; turn off cutter pos comp
G28.140 D0; reset pre-extrude z pos
;===== reset machine status =================

M620 M ;enable remap

;===== avoid end stop =================
G91
G380 S2 Z42 F1200
G380 S2 Z-12 F1200
G90
;===== avoid end stop =================

;==== set airduct mode ====



    M145 P1 ; set airduct mode to heating mode for heating
    M106 P2 S0 ; turn off auxiliary fan
    M106 P3 S0 ; turn off chamber fan



;==== set airduct mode ====

;===== start to heat heatbed & hotend==========

    M1002 set_filament_type:ASA

    M104 S140 A
    M140 S100

    ;===== set chamber temperature ==========
    
        M145 P1 ; set airduct mode to heating mode
        M141 S60 ; Let Chamber begin to heat
    
    ;===== set chamber temperature ==========

;===== start to heat heatbead & hotend==========

;====== cog noise reduction=================
M982.2 S1 ; turn on cog noise reduction

;===== first homing start =====
M1002 gcode_claim_action : 13

G28 X T300

G150.1 F18000 ; wipe mouth to avoid filament stick to heatbed
G150.3 F18000
M400 P200
M972 S24 P0 T2000

M1002 gcode_claim_action : 74 ; Heatbed surface foreign object detection

M972 S26 P0 C0

M972 S35 P0 C0

M972 S41 P0 T5000 ; trash can anti-collision

M1009 Q1 L1
G91
G380 S2 Z30 F1200 ; lower heatbed to move toolhead
G90
G1 X175 Y160 F30000
G28 Z P0 T250
M1009 Q1 L0

;===== first homing end =====

M400
;M73 P99

;===== detection start =====

M1002 judge_flag build_plate_detect_flag
M622 S1
    ;M1002 gcode_claim_action : 11 ; Indentifying build plate type
    M972 S19 P0 C0    ; heatbed presence detection
    M972 S31 P0 T5000 ; toolhead camera dirty detection
    ;M1002 gcode_claim_action : 73 ; Build plate alignment detection
    M972 S34 P0 T5000 ; heatbed plate offset detection
M623

M1002 gcode_claim_action : 72 ; Hotend Type Detection
T1001
M972 S14 P0 T5000 ; nozzle type detection

M104 S260 T1 ; rise temp in advance

G151 P1 M ; plug the heat nozzle



;===== detection end =====

M400
;M73 P99

;===== prepare print temperature and material ==========
M400
M211 X0 Y0 Z0 ;turn off soft endstop
M975 S1 ; turn on input shaping

G29.2 S0 ; avoid invalid abl data


M620.10 A0 F239.471 H0.4 T280 P260 S1
M620.10 A1 F239.471 H0.4 T280 P260 S1


M620.11 P0 I0 B-1 E0


M620.11 K1 I0 B-1 R10 F299.339


M628 S1


    M620.11 S1 L0 I0 B-1 R10 D8 E-10 F299.339


M629

M620 S0A H-1 ; switch material if AMS exist
M1002 gcode_claim_action : 4
M1002 set_filament_type:UNKNOWN
M400
T0 H-1
M400
M628 S0
M629
M400
M1002 set_filament_type:ASA
M621 S0A

M104 S260
M400
M106 P1 S0

G29.2 S1
;===== prepare print temperature and material ==========

M400
;M73 P99

;===== auto extrude cali start =========================
M975 S1
M1002 judge_flag extrude_cali_flag

M622 J0
    M983.3 F5 A0.4 ; cali dynamic extrusion compensation
M623

M622 J1
    M1002 set_filament_type:ASA
    M1002 gcode_claim_action : 8

    M109 S260

    G90
    M83
    M983.3 F5 A0.4 ; cali dynamic extrusion compensation

    M400
    M106 P1 S255
    M400 S5
    M106 P1 S0
    G150.3
M623

M622 J2
    M1002 set_filament_type:ASA
    M1002 gcode_claim_action : 8

    M109 S260

    G90
    M83
    M983.3 F5 A0.4 ; cali dynamic extrusion compensation

    M400
    M106 P1 S255
    M400 S5
    M106 P1 S0
    G150.3
M623

;===== auto extrude cali end =========================


    M106 P1 S0
    M400 S2
    M109 S260 ; wait tmpr to extrude
    M83
    
        G1 E45 F299.339
    
    G1 E-3 F1800
    M400 P500
    G150.2
    G150.1


G91
M73 P1 R33
G1 Y-16 F12000 ; move away from the trash bin
G90

M400
;M73 P99

;===== wipe right nozzle start =====

M1002 gcode_claim_action : 14
    G150 T260
    
        G150 T180
    
M106 S255 ; turn on fan to cool the nozzle

;===== wipe left nozzle end =====

M400
;M73 P99


    M1002 gcode_claim_action : 49
    M191 S60 ; wait for chamber temp


M400
;M73 P99

;===== bed leveling ==================================

M1002 judge_flag g29_before_print_flag

M190 S100; ensure bed temp
M109 S140 A
M106 S0 ; turn off fan , too noisy

G91
M73 P2 R33
G1 Z5 F1200
G90
G1 X175 Y160 F30000

M622 J1
    M1002 gcode_claim_action : 1
    G29.20 A3
    G29 A1 O X145 Y130 I60 J60 R
    M400
M623

M622 J2
    M1002 gcode_claim_action : 1
    
        G29.20 A4
        G29 A2 O X145 Y130 I60 J60 R
    
    M400
M623

M622 J0
    G28 R
M623

;===== bed leveling end ================================

;===== z ofst cali start =====

    M190 S100; ensure bed temp

    G383 O0 M2 T140

;===== z ofst cali end =====

G39.1 ; cali nozzle wrapped detection pos

G90
M73 P49 R17
G1 Z5 F1200
G1 X270 Y-0.5 F60000
G28.140 S0 ; cali pre-extrude z pos

M141 S60
M104 S260 A

;===== mech mode sweep start =====
    M1002 gcode_claim_action : 3

    G90
    G1 Z5 F1200
    G1 X187 Y160 F20000
    T1000
    M400 P200

    M970.3 Q1 A5 K0 O1
    M974 Q1 S2 P0

    M970.3 Q0 A5 K0 O1
    M974 Q0 S2 P0

    M970.2 Q2 K0 W38 Z0.01
    M974 Q2 S2 P0

    M975 S1
;===== mech mode sweep end =====

M400
;M73 P99

G150.3 ; move to garbage can to wait for temp
M1026
G29.9

;===== xy ofst cali start =====

M1002 judge_flag auto_cali_toolhead_offset_flag

M622 J0
    M1012.5 N1 R1
M623

M622 J1
    M1002 gcode_claim_action : 39
    M141 S0
    M620.17 T0 S260 L0
    M620.17 T1 S260 L0
    M620 D-1
    G383 O1 T260 L0
    M141 S60
M623

M622 J2
    M1002 gcode_claim_action : 39
    M141 S0
    M620.17 T0 S260 L0
    M620.17 T1 S260 L0
    M620 D-1
    G383.3 T260 L0
    M141 S60
M623
;===== xy ofst cali end =====

M400
;M73 P99

M1002 gcode_claim_action : 0
M400

;============switch again==================
M211 X0 Y0 Z0 ;turn off soft endstop
G91
G1 Z6 F1200
G90
M1002 set_filament_type:ASA
M620 S0A H-1
M400
T0 H-1
M400
M628 S0
M629
M400
M621 S0A

;============switch again==================

M400
;M73 P99

;===== wait temperature reaching the reference value =======

M104 S260 ; rise to print tmpr

M140 S100
M190 S100

    ;========turn off light and fans =============
    M960 S1 P0 ; turn off laser
    M960 S2 P0 ; turn off laser
    M106 S0 ; turn off fan
    M106 P2 S0 ; turn off big fan
    ;==== set ext toodhead cooling fan ====
    
    ;============set motor current==================
    M400 S1

;===== wait temperature reaching the reference value =======

M400
;M73 P99

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
    
        
            G29.1 Z-0.02 ; for Textured PEI Plate
        
    

G150.1

M975 S1 ; turn on mech mode supression
M983.4 S1 ; turn on deformation compensation
G29.2 S1 ; turn on pos comp
G29.7 S1

G90
G1 Z5 F1200
G1 Y295 F30000
G1 Y265 F18000

;===== nozzle load line ===============================
    G29.2 S1 ; ensure z comp turn on
    G90
    M83
M73 P50 R17
    G1 Z5 F1200
    G1 X270 Y-0.5 F60000
    G28.14 R0
    G29.2 S0
    G91
    G1 Z0.8 F1200
    G90
    G1 X250 F60000
    M400 P50
    M500 D1
    M400 S3
    M109 S260
    M83


    G1 E5 F299.339
    G1 X290 E10 F299.339
    G91
    G3 Z0.4 I1.217 J0 P1 F60000
    G90
    M83
    G29.2 S1 ; ensure z comp turn on
;===== noozle load line end ===========================

M400
;M73 P99

M993 A1 B1 C1 ; nozzle cam detection allowed.


M1015.3 S0;disable tpu clog detect



M1015.4 S0 K0 H0.4 ;disable E air printing detect


M620.6 I0 H-1 W1 ;enable ams air printing detect
M620 Q1

M211 Z1
G29.99
; MACHINE_START_GCODE_END
; filament start gcode
;VT0 H-1
G90
G21
M83 ; use relative distances for extrusion
M981 S1 P20000 ;open spaghetti detector
; CHANGE_LAYER
; Z_HEIGHT: 0.2
; LAYER_HEIGHT: 0.2
G1 E-.8 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 1/30
; update layer progress
M73 L1
M991 S0 P0 ;notify layer change

M106 S0
M106 P2 S0
; OBJECT_ID: 378
G1 X170.06 Y167.351 F30000
M204 S6000
G1 Z.4
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.5
M73 P50 R16
G1 F3000
M204 S500
G1 X169.612 Y167.022 E.02007
G3 X174.715 Y151.152 I5.397 J-7.02 E.78429
G3 X179.429 Y152.329 I.279 J8.907 E.17769
G3 X170.112 Y167.38 I-4.421 J7.673 E1.02463
M204 S6000
G1 X170.326 Y166.98 F30000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X169.89 Y166.659 E.01953
G3 X174.73 Y151.609 I5.119 J-6.657 E.74373
G3 X178.715 Y152.466 I.289 J8.35 E.14869
G3 X170.378 Y167.007 I-3.706 J7.536 E.9911
; WIPE_START
G1 X169.89 Y166.659 E-.2276
G1 X169.461 Y166.316 E-.20884
G1 X169.06 Y165.94 E-.20886
G1 X168.854 Y165.72 E-.11469
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X162.317 Y161.78 Z.6 F30000
G1 X146.851 Y152.457 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X147.404 Y150.633 E.06885
G1 X148.076 Y148.848 E.06885
G1 X148.878 Y147.082 E.07002
G1 X149.762 Y145.429 E.0677
G1 X150.769 Y143.809 E.06885
G1 X151.88 Y142.259 E.06886
G1 X153.09 Y140.785 E.06886
G1 X154.393 Y139.393 E.06886
G1 X155.785 Y138.09 E.06884
G1 X157.259 Y136.88 E.06886
G1 X158.809 Y135.769 E.06887
G1 X160.429 Y134.762 E.06885
G1 X162.111 Y133.863 E.06886
G1 X163.848 Y133.076 E.06886
G1 X165.633 Y132.404 E.06886
G1 X167.457 Y131.851 E.06885
G1 X169.315 Y131.417 E.06885
G1 X171.196 Y131.107 E.06886
G1 X173.094 Y130.92 E.06884
G1 X175.032 Y130.859 E.07003
G1 X175.487 Y130.873 E.01643
G1 X176.906 Y130.92 E.05126
G1 X178.804 Y131.107 E.06885
G1 X180.686 Y131.418 E.06887
G1 X182.543 Y131.851 E.06885
G1 X184.367 Y132.404 E.06885
G1 X186.152 Y133.076 E.06886
G1 X187.918 Y133.878 E.07002
G1 X189.571 Y134.762 E.0677
G1 X191.191 Y135.769 E.06885
G1 X192.741 Y136.88 E.06887
G1 X194.215 Y138.089 E.06884
G1 X195.607 Y139.393 E.06885
G1 X196.911 Y140.785 E.06886
G1 X198.12 Y142.259 E.06884
G1 X199.231 Y143.809 E.06887
G1 X200.238 Y145.429 E.06885
G1 X201.137 Y147.111 E.06886
G1 X201.924 Y148.848 E.06886
G1 X202.596 Y150.633 E.06886
G1 X203.15 Y152.457 E.06886
G1 X203.583 Y154.315 E.06885
G1 X203.893 Y156.196 E.06886
G1 X204.08 Y158.094 E.06885
G1 X204.142 Y160 E.06885
G1 X204.08 Y161.906 E.06885
G1 X203.893 Y163.804 E.06885
G1 X203.582 Y165.686 E.06887
G1 X203.15 Y167.543 E.06885
G1 X202.596 Y169.367 E.06885
G1 X201.924 Y171.152 E.06885
G1 X201.122 Y172.918 E.07002
G1 X200.238 Y174.571 E.0677
G1 X199.231 Y176.191 E.06885
G1 X198.12 Y177.741 E.06887
G1 X196.911 Y179.215 E.06884
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.607 Y180.607 E.06886
G1 X194.215 Y181.911 E.06885
G1 X192.741 Y183.12 E.06885
G1 X191.191 Y184.231 E.06887
G1 X189.571 Y185.238 E.06885
G1 X187.889 Y186.137 E.06886
G1 X186.152 Y186.924 E.06886
G1 X184.367 Y187.596 E.06886
G1 X182.543 Y188.15 E.06886
G1 X180.685 Y188.583 E.06885
G1 X178.804 Y188.893 E.06886
G1 X176.906 Y189.08 E.06885
G1 X175 Y189.142 E.06885
G1 X173.094 Y189.08 E.06885
G1 X171.196 Y188.893 E.06885
G1 X169.314 Y188.582 E.06887
G1 X167.457 Y188.15 E.06885
G1 X165.633 Y187.596 E.06885
G1 X163.848 Y186.924 E.06886
G1 X162.082 Y186.122 E.07002
G1 X160.429 Y185.238 E.0677
G1 X158.809 Y184.231 E.06885
G1 X157.259 Y183.12 E.06887
G1 X155.785 Y181.911 E.06884
G1 X154.393 Y180.607 E.06885
G1 X153.089 Y179.215 E.06886
G1 X151.88 Y177.741 E.06884
G1 X150.769 Y176.191 E.06887
G1 X149.762 Y174.571 E.06885
G1 X148.863 Y172.889 E.06886
G1 X148.076 Y171.152 E.06886
G1 X147.404 Y169.367 E.06886
G1 X146.851 Y167.543 E.06885
G1 X146.417 Y165.685 E.06885
G1 X146.107 Y163.804 E.06886
G1 X145.92 Y161.906 E.06885
G1 X145.858 Y160 E.06885
G1 X145.92 Y158.094 E.06885
G1 X146.107 Y156.196 E.06885
G1 X146.418 Y154.314 E.06887
G1 X146.837 Y152.516 E.06668
M204 S6000
G1 X146.409 Y152.339 F30000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X146.971 Y150.486 E.06993
G1 X147.653 Y148.673 E.06994
G1 X148.468 Y146.88 E.0711
G1 X149.366 Y145.2 E.06877
G1 X150.389 Y143.555 E.06993
G1 X151.517 Y141.981 E.06994
G1 X152.746 Y140.483 E.06994
M73 P51 R16
G1 X154.07 Y139.07 E.06994
G1 X155.483 Y137.746 E.06993
G1 X156.981 Y136.517 E.06994
G1 X158.555 Y135.389 E.06994
G1 X160.2 Y134.366 E.06993
G1 X161.908 Y133.453 E.06994
G1 X163.673 Y132.653 E.06993
G1 X165.486 Y131.971 E.06994
G1 X167.339 Y131.409 E.06994
G1 X169.225 Y130.969 E.06993
G1 X171.137 Y130.653 E.06995
G1 X173.064 Y130.464 E.06992
G1 X175.032 Y130.401 E.07111
G1 X175.502 Y130.417 E.01696
G1 X176.936 Y130.464 E.0518
G1 X178.863 Y130.653 E.06993
G1 X180.775 Y130.969 E.06995
G1 X182.661 Y131.409 E.06992
G1 X184.514 Y131.971 E.06993
G1 X186.327 Y132.653 E.06994
G1 X188.12 Y133.468 E.0711
G1 X189.8 Y134.366 E.06877
G1 X191.445 Y135.389 E.06993
G1 X193.019 Y136.517 E.06994
G1 X194.516 Y137.746 E.06993
G1 X195.93 Y139.07 E.06993
G1 X197.254 Y140.484 E.06994
G1 X198.483 Y141.981 E.06993
G1 X199.611 Y143.555 E.06994
G1 X200.634 Y145.2 E.06993
G1 X201.547 Y146.908 E.06994
G1 X202.347 Y148.673 E.06993
G1 X203.029 Y150.486 E.06994
G1 X203.591 Y152.339 E.06994
G1 X204.031 Y154.225 E.06993
G1 X204.347 Y156.137 E.06995
G1 X204.536 Y158.064 E.06993
G1 X204.6 Y160 E.06994
G1 X204.536 Y161.936 E.06994
G1 X204.347 Y163.863 E.06993
G1 X204.031 Y165.775 E.06995
G1 X203.591 Y167.661 E.06992
G1 X203.029 Y169.514 E.06994
G1 X202.347 Y171.327 E.06994
G1 X201.532 Y173.12 E.0711
G1 X200.634 Y174.8 E.06877
G1 X199.611 Y176.445 E.06993
G1 X198.483 Y178.019 E.06994
G1 X197.254 Y179.516 E.06993
G1 X195.93 Y180.93 E.06994
G1 X194.517 Y182.254 E.06993
G1 X193.019 Y183.483 E.06993
G1 X191.445 Y184.611 E.06994
G1 X189.8 Y185.634 E.06993
G1 X188.092 Y186.547 E.06994
G1 X186.327 Y187.347 E.06993
G1 X184.514 Y188.029 E.06994
G1 X182.661 Y188.591 E.06994
G1 X180.775 Y189.031 E.06993
G1 X178.863 Y189.347 E.06995
G1 X176.936 Y189.536 E.06993
G1 X175 Y189.6 E.06994
G1 X173.064 Y189.536 E.06994
G1 X171.137 Y189.347 E.06993
G1 X169.225 Y189.031 E.06995
G1 X167.339 Y188.591 E.06992
G1 X165.486 Y188.029 E.06994
G1 X163.673 Y187.347 E.06994
G1 X161.88 Y186.532 E.0711
G1 X160.2 Y185.634 E.06877
G1 X158.555 Y184.611 E.06993
G1 X156.981 Y183.483 E.06994
G1 X155.484 Y182.254 E.06993
G1 X154.07 Y180.93 E.06993
G1 X152.746 Y179.516 E.06994
G1 X151.517 Y178.019 E.06993
G1 X150.389 Y176.445 E.06994
G1 X149.366 Y174.8 E.06993
G1 X148.453 Y173.092 E.06994
G1 X147.653 Y171.327 E.06993
G1 X146.971 Y169.514 E.06994
G1 X146.409 Y167.661 E.06994
G1 X145.969 Y165.775 E.06993
G1 X145.653 Y163.863 E.06995
G1 X145.464 Y161.936 E.06993
G1 X145.4 Y160 E.06994
G1 X145.464 Y158.064 E.06993
G1 X145.653 Y156.137 E.06993
G1 X145.969 Y154.225 E.06995
G1 X146.395 Y152.398 E.06776
; WIPE_START
G1 X146.971 Y150.486 E-.75878
G1 X146.972 Y150.483 E-.00122
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X154.308 Y148.377 Z.6 F30000
G1 X192.949 Y137.287 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.50295
G1 F6300
M204 S500
G1 X195.361 Y139.699 E.12396
G1 X196.618 Y141.041 E.06682
G1 X197.812 Y142.496 E.06837
G1 X198.582 Y143.571 E.04807
G1 X191.429 Y136.418 E.36761
G1 X190.975 Y136.092 E.02031
G1 X189.595 Y135.234 E.05905
G1 X199.766 Y145.405 E.5227
G1 X199.902 Y145.623 E.00933
G1 X200.554 Y146.844 E.05029
G1 X188.156 Y134.446 E.63713
G2 X186.904 Y133.844 I-5.297 J9.415 E.05054
G1 X201.158 Y148.099 E.73256
G1 X201.565 Y148.997 E.03583
G1 X201.661 Y149.252 E.00992
G1 X185.748 Y133.339 E.81782
G1 X184.705 Y132.946 E.04051
G1 X202.054 Y150.295 E.8916
G3 X202.386 Y151.278 I-7.332 J3.023 E.0377
G1 X183.722 Y132.614 E.95913
G1 X182.788 Y132.331 E.03546
G1 X202.669 Y152.212 E1.02169
G3 X202.898 Y153.092 I-6.599 J2.191 E.03308
G1 X181.908 Y132.102 E1.07871
G1 X181.06 Y131.904 E.03166
G1 X203.096 Y153.94 E1.13248
G3 X203.262 Y154.756 I-6.139 J1.669 E.03027
G1 X180.244 Y131.738 E1.18291
G1 X179.465 Y131.61 E.0287
G1 X203.39 Y155.535 E1.22956
G3 X203.514 Y156.31 I-5.85 J1.331 E.02851
G1 X178.69 Y131.486 E1.27571
G1 X177.969 Y131.415 E.02635
G1 X203.585 Y157.031 E1.31645
G1 X203.656 Y157.753 E.02635
G1 X177.247 Y131.344 E1.35719
G2 X176.55 Y131.297 I-.707 J5.295 E.02542
G1 X203.703 Y158.45 E1.39545
G1 X203.725 Y159.123 E.02445
G1 X175.877 Y131.275 E1.43114
G1 X175.204 Y131.253 E.02445
G1 X203.747 Y159.796 E1.46684
G3 X203.739 Y160.438 I-4.91 J.263 E.02338
G1 X174.563 Y131.262 E1.49941
G1 X173.932 Y131.282 E.02293
G1 X203.719 Y161.068 E1.53076
G1 X203.698 Y161.698 E.0229
G1 X173.302 Y131.302 E1.56211
G2 X172.698 Y131.349 I.052 J4.55 E.02201
G1 X203.651 Y162.302 E1.59068
G1 X203.592 Y162.894 E.02163
G1 X172.106 Y131.408 E1.61811
G1 X171.514 Y131.466 E.02163
G1 X203.534 Y163.486 E1.64555
G3 X203.457 Y164.06 I-4.411 J-.3 E.02105
G1 X170.94 Y131.543 E1.67108
G1 X170.382 Y131.635 E.02057
G1 X203.365 Y164.618 E1.69504
G1 X203.273 Y165.176 E.02057
G1 X169.824 Y131.727 E1.719
G2 X169.272 Y131.826 I.481 J4.262 E.02038
G1 X203.174 Y165.728 E1.74225
G1 X203.051 Y166.256 E.01969
G1 X168.744 Y131.949 E1.76304
G1 X168.217 Y132.072 E.01969
G1 X202.928 Y166.783 E1.78383
G1 X202.805 Y167.311 E.01969
G1 X167.689 Y132.195 E1.80462
G2 X167.183 Y132.34 I.846 J3.928 E.01914
M73 P52 R16
G1 X202.66 Y167.817 E1.82322
G1 X202.509 Y168.316 E.01896
G1 X166.684 Y132.491 E1.84109
G1 X166.185 Y132.643 E.01895
G1 X202.357 Y168.815 E1.85896
G3 X202.202 Y169.311 I-3.857 J-.937 E.01888
G1 X165.689 Y132.798 E1.87643
G1 X165.217 Y132.976 E.01835
G1 X202.024 Y169.783 E1.89158
G1 X201.846 Y170.256 E.01835
G1 X164.744 Y133.154 E1.90673
G1 X164.271 Y133.331 E.01835
G1 X201.668 Y170.729 E1.92188
G3 X201.48 Y171.191 I-3.562 J-1.184 E.01815
G1 X163.809 Y133.52 E1.93595
G1 X163.361 Y133.723 E.01786
G1 X201.277 Y171.638 E1.94851
G1 X201.073 Y172.085 E.01785
G1 X162.914 Y133.926 E1.96107
G1 X162.466 Y134.128 E.01786
G1 X200.87 Y172.533 E1.97364
G3 X200.655 Y172.968 I-3.479 J-1.452 E.01766
G1 X182.915 Y155.228 E.91168
G2 X179.772 Y152.085 I-7.811 J4.668 E.16315
G1 X162.032 Y134.345 E.91168
G1 X161.608 Y134.572 E.01747
G1 X178.467 Y151.431 E.8664
G2 X177.481 Y151.096 I-3.052 J7.359 E.03786
G1 X161.184 Y134.799 E.83753
G1 X160.76 Y135.025 E.01747
G1 X176.64 Y150.904 E.81605
G2 X175.886 Y150.801 I-1.162 J5.692 E.02766
G1 X160.352 Y135.267 E.79831
G1 X159.951 Y135.517 E.01717
G1 X175.194 Y150.76 E.78338
G2 X174.552 Y150.768 I-.209 J8.67 E.02335
G1 X159.55 Y135.766 E.77099
G1 X159.148 Y136.016 E.01717
G1 X173.95 Y150.817 E.76069
G2 X173.383 Y150.901 I.34 J4.3 E.02086
G1 X158.763 Y136.28 E.75135
G1 X158.384 Y136.552 E.01694
G1 X172.845 Y151.013 E.74319
G2 X172.333 Y151.152 I.8 J3.97 E.01929
G1 X158.005 Y136.823 E.73635
G1 X157.626 Y137.095 E.01694
G1 X171.844 Y151.314 E.73071
G2 X171.377 Y151.497 I1.185 J3.717 E.01826
G1 X157.261 Y137.381 E.72542
G1 X156.904 Y137.674 E.0168
G1 X170.929 Y151.699 E.72076
G2 X170.504 Y151.925 I1.489 J3.316 E.0175
G1 X156.546 Y137.967 E.71729
G1 X156.189 Y138.261 E.0168
G1 X170.096 Y152.167 E.71468
G2 X169.704 Y152.426 I1.778 J3.119 E.01708
G1 X155.844 Y138.566 E.71227
G1 X155.508 Y138.881 E.01673
G1 X169.327 Y152.7 E.71019
G1 X168.97 Y152.994 E.0168
G1 X155.172 Y139.196 E.70909
G1 X154.836 Y139.51 E.01673
G1 X168.63 Y153.304 E.70889
G2 X168.305 Y153.63 I2.321 J2.646 E.01673
G1 X154.511 Y139.836 E.70889
G1 X154.196 Y140.172 E.01673
G1 X167.994 Y153.969 E.70909
G1 X167.701 Y154.327 E.0168
G1 X153.882 Y140.508 E.71019
G1 X153.567 Y140.843 E.01673
G1 X167.427 Y154.703 E.71226
G2 X167.168 Y155.095 I2.862 J2.172 E.01708
G1 X153.261 Y141.188 E.71468
G1 X152.968 Y141.546 E.0168
G1 X166.925 Y155.503 E.71728
G2 X166.7 Y155.928 I3.128 J1.934 E.0175
G1 X152.675 Y141.903 E.72075
G1 X152.382 Y142.26 E.0168
G1 X166.497 Y156.375 E.7254
G2 X166.314 Y156.843 I3.478 J1.628 E.01827
G1 X152.096 Y142.625 E.7307
G1 X151.824 Y143.004 E.01694
M73 P53 R16
G1 X166.152 Y157.332 E.73634
G2 X166.014 Y157.844 I3.831 J1.313 E.01929
G1 X151.552 Y143.383 E.74317
G1 X151.281 Y143.762 E.01694
G1 X165.901 Y158.382 E.75133
G2 X165.817 Y158.949 I4.285 J.919 E.02085
G1 X151.016 Y144.148 E.76066
G1 X150.767 Y144.549 E.01717
G1 X165.768 Y159.551 E.77096
G2 X165.76 Y160.193 I4.894 J.385 E.02336
G1 X150.517 Y144.95 E.78335
G1 X150.268 Y145.351 E.01717
G1 X165.801 Y160.884 E.79828
G2 X165.904 Y161.638 I5.8 J-.409 E.02766
G1 X150.026 Y145.76 E.81601
G1 X149.799 Y146.183 E.01747
G1 X166.095 Y162.48 E.83747
G2 X166.43 Y163.465 I7.692 J-2.065 E.03785
G1 X149.42 Y146.455 E.87414
; WIPE_START
G1 X150.835 Y147.87 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X158.23 Y149.759 Z.6 F30000
G1 X183.166 Y156.13 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X200.428 Y173.392 E.88711
G1 X200.201 Y173.816 E.01747
G1 X183.904 Y157.519 E.83752
G3 X184.096 Y158.36 I-10.836 J2.905 E.03138
G1 X199.975 Y174.24 E.81605
G3 X199.733 Y174.648 I-3.241 J-1.644 E.01727
G1 X184.199 Y159.114 E.79831
G3 X184.24 Y159.806 I-5.259 J.66 E.0252
G1 X199.483 Y175.049 E.78338
G1 X199.234 Y175.45 E.01717
G1 X184.232 Y160.448 E.77099
G3 X184.183 Y161.05 I-4.624 J-.073 E.02195
G1 X198.984 Y175.852 E.76068
G3 X198.72 Y176.237 I-3.077 J-1.828 E.01702
G1 X184.099 Y161.617 E.75135
G3 X183.987 Y162.155 I-4.163 J-.591 E.01998
G1 X198.448 Y176.616 E.74319
G1 X198.177 Y176.995 E.01694
G1 X183.848 Y162.667 E.73635
G3 X183.686 Y163.156 I-3.813 J-.99 E.01872
G1 X197.905 Y177.374 E.73071
G3 X197.619 Y177.739 I-2.926 J-1.998 E.01685
G1 X183.504 Y163.624 E.72541
G1 X183.301 Y164.071 E.01786
G1 X197.326 Y178.096 E.72076
G1 X197.033 Y178.454 E.0168
G1 X183.075 Y164.496 E.71729
G3 X182.833 Y164.904 I-3.233 J-1.646 E.01726
G1 X196.739 Y178.811 E.71468
G3 X196.434 Y179.156 I-2.78 J-2.157 E.01676
G1 X182.574 Y165.296 E.71227
G3 X182.3 Y165.673 I-3.004 J-1.901 E.01693
M73 P53 R15
G1 X196.119 Y179.492 E.71019
G1 X195.804 Y179.828 E.01673
G1 X182.006 Y166.03 E.70909
G3 X181.696 Y166.37 I-2.747 J-2.198 E.01675
G1 X195.49 Y180.164 E.70889
G3 X195.164 Y180.489 I-2.644 J-2.318 E.01673
G1 X181.37 Y166.695 E.70889
G3 X181.031 Y167.006 I-2.533 J-2.429 E.01675
G1 X194.828 Y180.804 E.70909
G1 X194.492 Y181.118 E.01673
G1 X180.673 Y167.299 E.71019
G3 X180.297 Y167.573 I-2.285 J-2.74 E.01693
G1 X194.157 Y181.433 E.71226
G3 X193.812 Y181.739 I-2.504 J-2.475 E.01676
G1 X179.905 Y167.832 E.71468
G3 X179.497 Y168.075 I-2.057 J-2.994 E.01726
G1 X193.454 Y182.032 E.71728
G1 X193.097 Y182.325 E.0168
G1 X179.072 Y168.3 E.72075
G1 X178.624 Y168.503 E.01787
G1 X192.74 Y182.619 E.72541
G3 X192.375 Y182.904 I-2.365 J-2.641 E.01685
G1 X178.157 Y168.686 E.7307
G3 X177.668 Y168.848 I-1.479 J-3.65 E.01872
G1 X191.996 Y183.176 E.73634
G1 X191.617 Y183.448 E.01694
G1 X177.156 Y168.986 E.74317
G3 X176.618 Y169.099 I-1.13 J-4.051 E.01998
G1 X191.238 Y183.719 E.75133
G3 X190.852 Y183.984 I-2.215 J-2.813 E.01702
G1 X176.051 Y169.183 E.76066
G3 X175.449 Y169.232 I-.675 J-4.566 E.02195
G1 X190.451 Y184.233 E.77096
G1 X190.05 Y184.483 E.01717
G1 X174.807 Y169.24 E.78335
G3 X174.116 Y169.199 I-.033 J-5.298 E.0252
G1 X189.649 Y184.732 E.79828
G3 X189.24 Y184.974 I-2.053 J-2.999 E.01727
G1 X173.362 Y169.096 E.81601
G3 X172.52 Y168.905 I2.061 J-11.029 E.03137
G1 X188.817 Y185.201 E.83747
G1 X188.393 Y185.428 E.01747
G1 X171.132 Y168.167 E.88702
; WIPE_START
G1 X172.547 Y169.582 E-.76
; WIPE_END
M73 P54 R15
G1 E-.04 F1800
M204 S6000
G1 X177.832 Y175.088 Z.6 F30000
G1 X188.121 Y185.806 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X170.231 Y167.917 E.91935
G3 X167.083 Y164.769 I4.666 J-7.815 E.16345
G1 X149.346 Y147.031 E.91154
G2 X149.13 Y147.466 I3.264 J1.888 E.01766
G1 X187.535 Y185.871 E1.97366
G1 X187.087 Y186.074 E.01786
G1 X148.927 Y147.914 E1.9611
G1 X148.724 Y148.361 E.01785
G1 X186.639 Y186.277 E1.94854
G1 X186.192 Y186.48 E.01786
G1 X148.52 Y148.808 E1.93597
G2 X148.332 Y149.27 I3.375 J1.647 E.01815
G1 X185.73 Y186.668 E1.92191
G1 X185.257 Y186.846 E.01835
G1 X148.154 Y149.743 E1.90676
G1 X147.976 Y150.216 E.01835
G1 X184.784 Y187.024 E1.89161
G1 X184.312 Y187.202 E.01835
G1 X147.798 Y150.688 E1.87646
G2 X147.643 Y151.184 I3.7 J1.432 E.01888
G1 X183.816 Y187.357 E1.85899
G1 X183.317 Y187.509 E.01895
G1 X147.491 Y151.683 E1.84112
G1 X147.34 Y152.182 E.01895
G1 X182.818 Y187.66 E1.82325
G3 X182.312 Y187.804 I-1.355 J-3.79 E.01914
G1 X147.196 Y152.688 E1.80466
G1 X147.073 Y153.216 E.01969
G1 X181.784 Y187.927 E1.78387
G1 X181.257 Y188.05 E.01969
G1 X146.95 Y153.743 E1.76308
G1 X146.827 Y154.271 E.01969
G1 X180.729 Y188.173 E1.74229
G3 X180.178 Y188.273 I-1.032 J-4.157 E.02037
G1 X146.727 Y154.822 E1.71905
G1 X146.635 Y155.381 E.02057
G1 X179.619 Y188.365 E1.69509
G1 X179.061 Y188.457 E.02057
G1 X146.543 Y155.939 E1.67113
G2 X146.466 Y156.513 I4.336 J.874 E.02105
G1 X178.487 Y188.534 E1.64561
G1 X177.895 Y188.592 E.02163
G1 X146.408 Y157.105 E1.61817
G1 X146.349 Y157.697 E.02163
G1 X177.303 Y188.651 E1.59073
G3 X176.7 Y188.698 I-.664 J-4.576 E.022
G1 X146.302 Y158.3 E1.56218
G1 X146.281 Y158.93 E.0229
G1 X176.07 Y188.719 E1.53087
G1 X175.44 Y188.739 E.0229
G1 X146.261 Y159.56 E1.49955
G2 X146.253 Y160.203 I4.9 J.38 E.02338
G1 X174.797 Y188.747 E1.46691
G1 X174.124 Y188.725 E.02445
G1 X146.275 Y160.876 E1.43122
G1 X146.297 Y161.548 E.02445
G1 X173.452 Y188.703 E1.39552
G3 X172.754 Y188.656 I.008 J-5.338 E.02542
G1 X146.344 Y162.246 E1.35727
G1 X146.415 Y162.967 E.02635
G1 X172.033 Y188.585 E1.31653
G1 X171.311 Y188.514 E.02635
M73 P55 R15
G1 X146.486 Y163.689 E1.27579
G2 X146.609 Y164.463 I5.959 J-.554 E.02851
G1 X170.537 Y188.391 E1.22966
G1 X169.758 Y188.262 E.0287
G1 X146.738 Y165.242 E1.183
G2 X146.903 Y166.058 I6.31 J-.853 E.03027
G1 X168.942 Y188.097 E1.13259
G1 X168.093 Y187.899 E.03166
G1 X147.101 Y166.907 E1.07882
G2 X147.33 Y167.786 I6.823 J-1.308 E.03307
G1 X167.214 Y187.67 E1.02182
G1 X166.28 Y187.386 E.03546
G1 X147.614 Y168.72 E.95926
G2 X147.945 Y169.702 I7.662 J-2.039 E.03769
G1 X165.298 Y187.055 E.89175
G1 X164.254 Y186.662 E.04051
G1 X148.338 Y170.746 E.81796
G1 X148.435 Y171.003 E.01001
G1 X148.841 Y171.899 E.03573
G1 X163.099 Y186.157 E.73274
G3 X161.846 Y185.555 I4.041 J-10.015 E.05052
G1 X149.445 Y173.153 E.63735
G1 X150.098 Y174.377 E.05041
G1 X150.232 Y174.591 E.00918
G1 X160.409 Y184.768 E.52299
G1 X159.025 Y183.908 E.0592
G1 X158.576 Y183.586 E.0201
G1 X151.414 Y176.424 E.36802
G1 X152.188 Y177.504 E.04827
G1 X153.382 Y178.959 E.06837
G1 X154.619 Y180.28 E.06579
G1 X157.058 Y182.719 E.12534
; CHANGE_LAYER
; Z_HEIGHT: 0.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F6300
G1 X155.644 Y181.305 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 2/30
; update layer progress
M73 L2
M991 S0 P1 ;notify layer change

; open powerlost recovery
M1003 S1
; OBJECT_ID: 378
M204 S10000
G17
G3 Z.6 I.847 J.873 P1  F30000
G1 X170.229 Y167.155 Z.6
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X170.202 Y167.133 E.00114
G3 X174.465 Y151.415 I4.805 J-7.134 E.6875
G3 X175.563 Y151.416 I.542 J8.369 E.03533
G3 X170.701 Y167.444 I-.556 J8.583 E.996
G1 X170.28 Y167.187 E.01588
M204 S250
G1 X170.437 Y166.823 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.42 Y166.806 E.0007
G3 X174.49 Y151.807 I4.586 J-6.808 E.60776
G3 X175.537 Y151.807 I.517 J7.987 E.03122
G3 X170.898 Y167.105 I-.531 J8.191 E.88048
G1 X170.488 Y166.854 E.01431
; WIPE_START
M204 S4000
G1 X170.42 Y166.806 E-.03149
G1 X170.002 Y166.514 E-.19404
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20416
G1 X168.968 Y165.563 E-.12617
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.391 Y161.69 Z.8 F30000
G1 X146.604 Y152.391 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06186
G1 X147.84 Y148.75 E.06186
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06185
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06186
G1 X154.213 Y139.213 E.06186
G1 X155.677 Y137.848 E.06438
G1 X157.104 Y136.677 E.05934
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06185
G1 X161.998 Y133.634 E.06187
G1 X163.75 Y132.84 E.06186
G1 X165.55 Y132.163 E.06186
G1 X167.391 Y131.604 E.06186
G1 X169.265 Y131.167 E.06187
G1 X171.163 Y130.854 E.06186
G1 X173.077 Y130.665 E.06186
G1 X175.078 Y130.605 E.06438
G1 X176.923 Y130.665 E.05934
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06186
G1 X186.25 Y132.84 E.06186
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06185
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06186
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06185
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06185
G1 X201.366 Y146.998 E.06187
G1 X202.16 Y148.75 E.06186
G1 X202.837 Y150.55 E.06186
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06186
G1 X204.335 Y158.077 E.06186
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06185
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06186
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06185
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06185
G1 X188.002 Y186.366 E.06187
G1 X186.25 Y187.16 E.06186
G1 X184.45 Y187.837 E.06186
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06186
G1 X176.923 Y189.335 E.06186
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06185
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06186
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06185
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06185
G1 X148.634 Y173.002 E.06187
G1 X147.84 Y171.25 E.06186
G1 X147.163 Y169.45 E.06186
G1 X146.604 Y167.609 E.06186
G1 X146.167 Y165.735 E.06187
G1 X145.854 Y163.837 E.06186
G1 X145.665 Y161.923 E.06186
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
M204 S250
G1 X146.225 Y152.289 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05804
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05807
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05807
G1 X155.429 Y137.545 E.06078
G1 X156.865 Y136.366 E.05535
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05806
G1 X161.824 Y133.282 E.05807
G1 X163.6 Y132.478 E.05806
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.782 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175.091 Y130.213 E.06078
G1 X176.948 Y130.274 E.05535
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05806
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05807
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05807
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05806
G1 X201.718 Y146.824 E.05807
G1 X202.522 Y148.6 E.05806
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.218 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05806
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05807
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05807
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05806
G1 X188.176 Y186.718 E.05807
G1 X186.4 Y187.522 E.05806
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05806
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05807
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05807
G1 X152.545 Y179.571 E.06078
G1 X151.366 Y178.135 E.05535
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05806
G1 X148.282 Y173.176 E.05807
G1 X147.478 Y171.4 E.05806
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.212 Y152.348 E.0563
; WIPE_START
M204 S4000
G1 X146.789 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.833 Y143.96 Z.8 F30000
G1 X152.321 Y141.577 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42037
G1 F9537.687
M204 S4000
G1 X154.467 Y139.432 E.09047
G1 X155.897 Y138.099 E.05829
G1 X157.307 Y136.942 E.05439
G1 X157.954 Y136.478 E.02374
G1 X151.478 Y142.954 E.27307
G2 X150.375 Y144.591 I11.934 J9.232 E.05889
G1 X159.591 Y135.375 E.38859
G3 X160.902 Y134.598 I6.584 J9.611 E.04549
G1 X149.598 Y145.902 E.47667
G1 X148.985 Y147.049 E.03877
G1 X162.049 Y133.985 E.55087
G1 X163.039 Y133.528 E.03252
G1 X148.528 Y148.039 E.61188
G1 X148.103 Y148.998 E.03128
G1 X163.998 Y133.103 E.67025
G1 X164.854 Y132.781 E.02727
G1 X147.781 Y149.854 E.71993
G1 X147.464 Y150.705 E.02706
G1 X165.705 Y132.464 E.76914
G1 X166.471 Y132.232 E.02387
G1 X147.232 Y151.471 E.81125
G1 X146.999 Y152.237 E.02387
G1 X167.237 Y131.999 E.85336
G3 X167.955 Y131.815 I1.765 J5.385 E.02212
G1 X146.815 Y152.955 E.89141
G1 X146.652 Y153.651 E.02131
G1 X168.651 Y131.652 E.92761
G3 X169.346 Y131.492 I1.575 J5.221 E.02128
G1 X146.492 Y154.346 E.96368
G1 X146.386 Y154.985 E.01932
G1 X169.985 Y131.386 E.99509
G1 X170.625 Y131.28 E.01932
G1 X146.281 Y155.625 E1.0265
G2 X146.179 Y156.26 I4.798 J1.091 E.01919
G1 X171.26 Y131.179 E1.05755
G1 X171.852 Y131.121 E.01774
G1 X146.121 Y156.852 E1.08498
G1 X146.063 Y157.444 E.01774
G1 X172.444 Y131.063 E1.1124
G1 X173.036 Y131.004 E.01774
G1 X146.004 Y158.036 E1.13983
G2 X145.982 Y158.592 I4.232 J.449 E.01661
G1 X173.591 Y130.983 E1.16416
G1 X174.141 Y130.967 E.01642
G1 X145.964 Y159.144 E1.18813
G1 X145.946 Y159.696 E.01646
G1 X174.692 Y130.95 E1.21211
G3 X175.232 Y130.943 I.323 J4.288 E.01612
G1 X145.943 Y160.232 E1.23499
G1 X145.96 Y160.749 E.01542
G1 X175.749 Y130.96 E1.25607
G1 X176.266 Y130.977 E.01542
G1 X145.977 Y161.266 E1.27715
G1 X145.994 Y161.783 E.01542
G1 X176.783 Y130.994 E1.29823
G3 X177.276 Y131.035 I-.065 J3.783 E.01476
G1 X146.035 Y162.276 E1.3173
G1 X146.083 Y162.762 E.01456
G1 X177.762 Y131.083 E1.33577
G1 X178.248 Y131.131 E.01456
G1 X146.131 Y163.248 E1.35424
G1 X146.179 Y163.734 E.01456
G1 X178.734 Y131.179 E1.37272
G3 X179.195 Y131.251 I-.32 J3.559 E.01394
G1 X146.251 Y164.195 E1.38913
G1 X146.326 Y164.653 E.01385
M73 P56 R15
G1 X179.653 Y131.326 E1.40526
G1 X180.112 Y131.402 E.01385
G1 X146.402 Y165.112 E1.42139
G1 X146.478 Y165.57 E.01385
G1 X180.57 Y131.478 E1.43752
G3 X181.008 Y131.573 I-.508 J3.39 E.01339
G1 X146.573 Y166.008 E1.45199
G1 X146.674 Y166.441 E.01325
G1 X181.441 Y131.674 E1.46598
G1 X181.874 Y131.775 E.01325
G1 X146.775 Y166.874 E1.47998
G1 X146.876 Y167.307 E.01325
G1 X182.307 Y131.876 E1.49397
G3 X182.728 Y131.988 I-.648 J3.267 E.01301
G1 X146.988 Y167.728 E1.50698
G1 X147.113 Y168.137 E.01276
G1 X183.137 Y132.113 E1.51901
G1 X183.547 Y132.237 E.01276
G1 X147.237 Y168.547 E1.53105
G1 X147.361 Y168.957 E.01276
G1 X183.957 Y132.361 E1.54308
G3 X184.365 Y132.487 I-.755 J3.182 E.01274
G1 X147.487 Y169.365 E1.555
G1 X147.633 Y169.753 E.01236
G1 X184.753 Y132.633 E1.5652
G1 X185.14 Y132.779 E.01236
G1 X147.779 Y170.14 E1.5754
G1 X147.925 Y170.528 E.01236
G1 X185.528 Y132.925 E1.5856
G1 X185.916 Y133.071 E.01236
G1 X148.071 Y170.916 E1.59579
G2 X148.226 Y171.294 I2.962 J-.997 E.0122
G1 X186.294 Y133.226 E1.60518
G1 X186.662 Y133.393 E.01202
G1 X148.393 Y171.662 E1.61366
G1 X148.559 Y172.029 E.01202
G1 X187.029 Y133.559 E1.62213
G1 X187.396 Y133.725 E.01202
G1 X148.725 Y172.396 E1.6306
G1 X148.892 Y172.764 E.01202
G1 X187.764 Y133.892 E1.63907
G3 X188.116 Y134.073 I-1.203 J2.778 E.01183
G1 X148.948 Y173.242 E1.65159
M204 S10000
G1 X193.429 Y182.674 F30000
G1 F9537.687
M204 S4000
G1 X195.554 Y180.548 E.08962
G1 X196.852 Y179.163 E.05658
G1 X198.058 Y177.693 E.05671
G1 X198.519 Y177.05 E.0236
G1 X192.05 Y183.519 E.27279
G3 X190.412 Y184.623 I-9.241 J-11.942 E.05893
G1 X199.623 Y175.412 E.3884
G2 X200.401 Y174.1 I-9.618 J-6.591 E.04551
G1 X189.1 Y185.401 E.47652
G1 X187.953 Y186.014 E.03877
G1 X201.014 Y172.953 E.55071
G1 X201.471 Y171.963 E.03253
G1 X186.963 Y186.471 E.61175
M73 P56 R14
G1 X186.003 Y186.897 E.03129
G1 X201.897 Y171.003 E.67015
G1 X202.219 Y170.147 E.02727
G1 X185.147 Y187.219 E.71983
G1 X184.297 Y187.536 E.02706
G1 X202.536 Y169.297 E.76905
G1 X202.768 Y168.531 E.02387
G1 X183.531 Y187.768 E.81116
G1 X182.764 Y188 E.02387
G1 X203 Y167.764 E.85327
G2 X203.185 Y167.046 I-5.383 J-1.766 E.02213
G1 X182.046 Y188.185 E.89134
G1 X181.35 Y188.347 E.02131
G1 X203.347 Y166.35 E.92753
G2 X203.508 Y165.655 I-5.221 J-1.576 E.02128
G1 X180.655 Y188.508 E.96362
G1 X180.016 Y188.614 E.01932
G1 X203.614 Y165.016 E.99503
G1 X203.719 Y164.377 E.01932
G1 X179.377 Y188.719 E1.02644
G3 X178.741 Y188.821 I-1.093 J-4.808 E.01919
G1 X203.821 Y163.741 E1.05749
G1 X203.879 Y163.149 E.01774
G1 X178.149 Y188.879 E1.08492
G1 X177.557 Y188.937 E.01774
G1 X203.937 Y162.557 E1.11235
G1 X203.996 Y161.965 E.01774
G1 X176.965 Y188.996 E1.13977
G3 X176.409 Y189.018 I-.45 J-4.241 E.01661
G1 X204.018 Y161.409 E1.16417
G1 X204.036 Y160.857 E.01646
G1 X175.857 Y189.036 E1.1882
G1 X175.305 Y189.054 E.01646
G1 X204.054 Y160.305 E1.21224
G2 X204.057 Y159.769 I-4.088 J-.287 E.016
G1 X174.769 Y189.057 E1.23495
G1 X174.252 Y189.04 E.01542
G1 X204.04 Y159.252 E1.25603
G1 X204.023 Y158.735 E.01542
G1 X173.735 Y189.023 E1.27711
G1 X173.218 Y189.006 E.01542
G1 X204.006 Y158.218 E1.29819
G2 X203.965 Y157.725 I-3.785 J.064 E.01476
G1 X172.725 Y188.965 E1.31726
G1 X172.239 Y188.917 E.01456
G1 X203.917 Y157.239 E1.33573
G1 X203.869 Y156.753 E.01456
G1 X171.753 Y188.869 E1.35421
G1 X171.267 Y188.822 E.01456
G1 X203.822 Y156.267 E1.37268
G2 X203.749 Y155.806 I-3.56 J.32 E.01394
G1 X170.806 Y188.749 E1.3891
G1 X170.348 Y188.674 E.01385
G1 X203.674 Y155.348 E1.40523
G1 X203.598 Y154.889 E.01385
G1 X169.889 Y188.598 E1.42136
G1 X169.431 Y188.522 E.01385
G1 X203.522 Y154.431 E1.43749
G2 X203.427 Y153.993 I-3.394 J.508 E.01339
G1 X168.993 Y188.427 E1.45196
G1 X168.56 Y188.326 E.01325
G1 X203.326 Y153.56 E1.46595
G1 X203.225 Y153.127 E.01325
G1 X168.127 Y188.225 E1.47995
G1 X167.694 Y188.124 E.01325
G1 X203.124 Y152.694 E1.49395
G2 X203.012 Y152.273 I-3.267 J.648 E.01301
G1 X167.273 Y188.012 E1.50696
G1 X166.863 Y187.888 E.01276
G1 X202.888 Y151.863 E1.51899
G1 X202.763 Y151.454 E.01276
G1 X166.454 Y187.763 E1.53102
G1 X166.044 Y187.639 E.01276
G1 X202.639 Y151.044 E1.54305
M73 P57 R14
G2 X202.514 Y150.636 I-3.192 J.757 E.01275
G1 X165.636 Y187.514 E1.55498
G1 X165.248 Y187.368 E.01236
G1 X202.368 Y150.248 E1.56518
G1 X202.222 Y149.86 E.01236
G1 X164.86 Y187.222 E1.57538
G1 X164.473 Y187.076 E.01236
G1 X202.076 Y149.473 E1.58557
G1 X201.93 Y149.085 E.01236
G1 X164.085 Y186.93 E1.59577
G3 X163.706 Y186.774 I.997 J-2.963 E.0122
G1 X201.774 Y148.706 E1.60517
G1 X201.608 Y148.339 E.01202
G1 X163.339 Y186.608 E1.61364
G1 X162.972 Y186.441 E.01202
G1 X201.441 Y147.972 E1.62211
G1 X201.275 Y147.604 E.01202
G1 X162.604 Y186.275 E1.63058
G1 X162.237 Y186.108 E.01202
G1 X201.108 Y147.237 E1.63905
G2 X200.927 Y146.884 I-2.784 J1.206 E.01183
G1 X161.884 Y185.927 E1.64629
G1 X161.536 Y185.741 E.01176
G1 X179.656 Y167.621 E.76404
G3 X178.545 Y168.199 I-4.805 J-7.892 E.03736
G1 X161.189 Y185.555 E.73187
G1 X160.841 Y185.37 E.01176
G1 X177.695 Y168.515 E.71067
G3 X176.964 Y168.713 I-1.869 J-5.472 E.02259
G1 X160.493 Y185.184 E.69451
G3 X160.162 Y184.98 I1.381 J-2.614 E.01158
G1 X176.306 Y168.836 E.68073
G3 X175.704 Y168.905 I-.825 J-4.56 E.01809
G1 X159.833 Y184.776 E.6692
G1 X159.504 Y184.571 E.01156
G1 X175.144 Y168.931 E.65947
G3 X174.618 Y168.923 I-.204 J-4.007 E.0157
G1 X159.175 Y184.366 E.65117
G3 X158.846 Y184.161 I1.405 J-2.619 E.01156
G1 X174.12 Y168.888 E.64403
G3 X173.645 Y168.828 I.215 J-3.645 E.01427
G1 X158.535 Y183.938 E.63713
G1 X158.224 Y183.716 E.01141
G1 X173.191 Y168.749 E.63109
G1 X172.758 Y168.648 E.01325
G1 X157.913 Y183.493 E.62595
G1 X157.602 Y183.27 E.01141
G1 X172.345 Y168.527 E.62163
G3 X171.945 Y168.393 I.826 J-3.112 E.01257
G1 X157.292 Y183.046 E.61787
G1 X156.999 Y182.806 E.01131
G1 X171.559 Y168.246 E.61393
G1 X171.191 Y168.079 E.01203
G1 X156.706 Y182.565 E.6108
G1 X156.413 Y182.324 E.01131
G1 X170.836 Y167.901 E.60817
G3 X170.491 Y167.713 I1.199 J-2.609 E.01174
G1 X156.12 Y182.084 E.60597
G3 X155.827 Y181.843 I1.7 J-2.36 E.01131
G1 X170.162 Y167.507 E.60446
G3 X169.843 Y167.292 I1.561 J-2.66 E.01147
G1 X155.551 Y181.584 E.60264
G1 X155.276 Y181.326 E.01126
G1 X169.534 Y167.068 E.60122
G1 X169.241 Y166.827 E.01131
G1 X155 Y181.068 E.60048
G1 X154.724 Y180.81 E.01126
G1 X168.957 Y166.577 E.60014
G1 X168.682 Y166.319 E.01126
G1 X154.449 Y180.552 E.60014
G1 X154.191 Y180.276 E.01126
G1 X168.424 Y166.043 E.60014
G3 X168.173 Y165.76 I2.033 J-2.047 E.01128
G1 X153.932 Y180 E.60048
G1 X153.674 Y179.725 E.01126
G1 X167.933 Y165.466 E.60122
G3 X167.708 Y165.157 I2.254 J-1.871 E.0114
G1 X153.416 Y179.449 E.60264
G1 X153.158 Y179.174 E.01126
G1 X167.492 Y164.839 E.60442
G1 X167.288 Y164.51 E.01156
G1 X152.917 Y178.881 E.60596
G1 X152.676 Y178.588 E.01131
G1 X167.099 Y164.165 E.60817
G3 X166.921 Y163.809 I2.622 J-1.538 E.01187
G1 X152.436 Y178.295 E.61079
G1 X152.195 Y178.001 E.01131
G1 X166.754 Y163.442 E.61392
G3 X166.607 Y163.055 I2.864 J-1.312 E.01234
G1 X151.954 Y177.708 E.61786
G3 X151.731 Y177.398 I2.251 J-1.86 E.01141
G1 X166.473 Y162.656 E.62162
G3 X166.352 Y162.243 I3.091 J-1.125 E.01285
G1 X151.508 Y177.087 E.62594
G1 X151.285 Y176.776 E.01141
G1 X166.251 Y161.81 E.63108
G3 X166.172 Y161.356 I3.436 J-.836 E.01376
G1 X151.062 Y176.465 E.63712
G1 X150.839 Y176.154 E.01141
G1 X166.113 Y160.881 E.64401
G3 X166.077 Y160.383 I3.786 J-.523 E.0149
G1 X150.634 Y175.826 E.65115
G1 X150.429 Y175.497 E.01156
G1 X166.069 Y159.857 E.65945
G3 X166.095 Y159.297 I4.283 J-.081 E.01672
G1 X150.225 Y175.167 E.66918
G1 X150.02 Y174.838 E.01156
G1 X166.164 Y158.695 E.6807
G3 X166.287 Y158.038 I5.077 J.613 E.01995
G1 X149.817 Y174.508 E.69448
G1 X149.631 Y174.16 E.01176
G1 X166.484 Y157.307 E.71063
G3 X166.8 Y156.457 I9.327 J2.987 E.02706
G1 X149.445 Y173.812 E.73182
G1 X149.259 Y173.464 E.01176
G1 X167.379 Y155.345 E.76403
G3 X170.347 Y152.377 I7.496 J4.528 E.12638
G1 X188.464 Y134.259 E.76395
G1 X188.812 Y134.445 E.01176
G1 X171.457 Y151.8 E.73181
G3 X172.307 Y151.484 I3.839 J9.015 E.02706
G1 X189.16 Y134.631 E.71063
G1 X189.508 Y134.817 E.01176
G1 X173.038 Y151.287 E.69448
G3 X173.695 Y151.164 I1.272 J4.96 E.01995
G1 X189.838 Y135.02 E.6807
G1 X190.167 Y135.225 E.01156
G1 X174.296 Y151.096 E.66924
G3 X174.857 Y151.069 I.502 J4.486 E.01677
G1 X190.497 Y135.429 E.65945
G1 X190.826 Y135.634 E.01156
G1 X175.383 Y151.077 E.65115
G3 X175.881 Y151.113 I-.025 J3.82 E.0149
G1 X191.154 Y135.839 E.64401
G1 X191.465 Y136.062 E.01141
G1 X176.356 Y151.172 E.63712
G3 X176.81 Y151.251 I-.379 J3.505 E.01376
G1 X191.776 Y136.285 E.63108
G1 X192.087 Y136.508 E.01141
G1 X177.243 Y151.352 E.62594
G3 X177.656 Y151.473 I-.711 J3.21 E.01285
G1 X192.398 Y136.731 E.62162
G3 X192.708 Y136.954 I-1.553 J2.478 E.01141
G1 X178.055 Y151.607 E.61786
G3 X178.442 Y151.754 I-.937 J3.042 E.01234
G1 X193.002 Y137.195 E.61392
G1 X193.295 Y137.436 E.01131
G1 X178.809 Y151.921 E.61079
G3 X179.165 Y152.099 I-1.18 J2.796 E.01187
G1 X193.588 Y137.676 E.60817
G1 X193.881 Y137.917 E.01131
G1 X179.51 Y152.288 E.60596
G1 X179.838 Y152.493 E.01155
G1 X194.174 Y138.158 E.60446
G1 X194.449 Y138.416 E.01126
G1 X180.157 Y152.708 E.60264
G3 X180.467 Y152.933 I-1.558 J2.473 E.0114
G1 X194.725 Y138.674 E.60122
G1 X195 Y138.932 E.01126
G1 X180.76 Y153.173 E.60048
G3 X181.043 Y153.424 I-1.766 J2.287 E.01128
G1 X195.276 Y139.191 E.60014
G1 X195.552 Y139.449 E.01126
G1 X181.319 Y153.682 E.60014
G1 X181.577 Y153.957 E.01126
G1 X195.81 Y139.724 E.60014
G1 X196.068 Y140 E.01126
G1 X181.827 Y154.241 E.60048
G1 X182.068 Y154.534 E.01131
G1 X196.326 Y140.276 E.60122
G1 X196.584 Y140.551 E.01126
G1 X182.292 Y154.843 E.60264
G3 X182.508 Y155.161 I-2.317 J1.806 E.01147
G1 X196.843 Y140.827 E.60442
G3 X197.084 Y141.12 I-2.12 J1.994 E.01131
G1 X182.713 Y155.491 E.60597
G3 X182.901 Y155.836 I-2.538 J1.607 E.01174
G1 X197.324 Y141.413 E.60817
G1 X197.565 Y141.706 E.01131
G1 X183.079 Y156.191 E.6108
G1 X183.246 Y156.559 E.01202
G1 X197.806 Y141.999 E.61392
G1 X198.046 Y142.292 E.01131
G1 X183.393 Y156.945 E.61786
G3 X183.527 Y157.345 I-2.979 J1.225 E.01257
G1 X198.27 Y142.602 E.62163
G1 X198.493 Y142.913 E.01141
G1 X183.648 Y157.758 E.62595
G1 X183.749 Y158.191 E.01325
G1 X198.716 Y143.224 E.63109
G1 X198.938 Y143.535 E.01141
M73 P58 R14
G1 X183.828 Y158.645 E.63713
G3 X183.888 Y159.12 I-3.589 J.689 E.01427
G1 X199.161 Y143.846 E.64403
G3 X199.366 Y144.175 I-2.414 J1.734 E.01156
G1 X183.923 Y159.618 E.65117
G3 X183.931 Y160.144 I-4.002 J.322 E.0157
G1 X199.571 Y144.504 E.65947
G1 X199.776 Y144.833 E.01156
G1 X183.905 Y160.704 E.6692
G3 X183.836 Y161.306 I-4.624 J-.222 E.01809
G1 X199.98 Y145.162 E.68073
G3 X200.184 Y145.493 I-2.417 J1.715 E.01158
G1 X183.713 Y161.964 E.69451
G3 X183.515 Y162.695 I-5.674 J-1.139 E.02259
G1 X200.37 Y145.841 E.71067
G1 X200.556 Y146.189 E.01176
G1 X183.199 Y163.545 E.73187
G3 X182.62 Y164.658 I-8.321 J-3.622 E.03743
G1 X200.867 Y146.411 E.76941
; CHANGE_LAYER
; Z_HEIGHT: 0.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9537.687
G1 X199.453 Y147.825 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 3/30
; update layer progress
M73 L3
M991 S0 P2 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z.8 I-.671 J-1.015 P1  F30000
G1 X170.209 Y167.144 Z.8
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X169.768 Y166.818 E.01762
G3 X174.501 Y151.414 I5.239 J-6.819 E.6713
G3 X176.678 Y151.563 I.512 J8.509 E.07038
G3 X170.261 Y167.17 I-1.671 J8.436 E.97636
; COOLING_NODE: 0
M204 S250
G1 X170.437 Y166.825 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.508 E.01594
G3 X174.514 Y151.806 I5.002 J-6.508 E.59317
G3 X176.072 Y151.86 I.463 J9.084 E.0465
G3 X170.487 Y166.85 I-1.064 J8.139 E.87897
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.508 E-.22404
G1 X169.587 Y166.173 E-.20406
G1 X169.195 Y165.805 E-.20417
G1 X168.965 Y165.56 E-.12773
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.388 Y161.687 Z1 F30000
G1 X146.604 Y152.391 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06186
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06185
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.55 Y132.163 E.06186
G1 X167.391 Y131.604 E.06186
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175.144 Y130.607 E.06648
G1 X176.923 Y130.665 E.05723
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06186
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06186
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06185
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.837 Y150.55 E.06186
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.837 Y169.45 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06186
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06185
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.45 Y187.837 E.06186
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.55 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06186
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06185
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.163 Y169.45 E.06186
G1 X146.604 Y167.609 E.06186
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.225 Y152.29 E.00002
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05807
G1 X155.479 Y137.503 E.06273
G1 X156.865 Y136.366 E.0534
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05806
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175.157 Y130.215 E.06273
G1 X176.948 Y130.274 E.0534
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05807
G1 X197.397 Y140.358 E.05807
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05806
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05806
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05807
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05806
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05806
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05807
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05806
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.211 Y152.349 E.05626
; WIPE_START
M204 S4000
G1 X146.225 Y152.29 E-.02308
G1 X146.788 Y150.434 E-.73692
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X151.885 Y144.753 Z1 F30000
G1 X161.411 Y134.133 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42037
G1 F9537.687
M204 S4000
G1 X179.656 Y152.378 E.76933
G2 X178.545 Y151.801 I-4.806 J7.894 E.03735
G1 X161.189 Y134.444 E.73187
G1 X160.841 Y134.63 E.01176
G1 X177.695 Y151.485 E.71067
G2 X176.964 Y151.287 I-1.868 J5.47 E.02259
G1 X160.493 Y134.816 E.69451
G2 X160.162 Y135.02 I1.392 J2.632 E.01158
G1 X176.306 Y151.164 E.68073
G2 X175.704 Y151.095 I-.825 J4.563 E.01809
G1 X159.833 Y135.224 E.6692
G1 X159.504 Y135.429 E.01156
G1 X175.144 Y151.069 E.65947
G2 X174.618 Y151.077 I-.204 J4.009 E.0157
G1 X159.175 Y135.634 E.65117
G2 X158.846 Y135.839 I1.398 J2.608 E.01156
G1 X174.122 Y151.114 E.6441
G2 X173.645 Y151.172 I.161 J3.325 E.01431
G1 X158.535 Y136.062 E.63713
G1 X158.224 Y136.284 E.01141
G1 X173.191 Y151.251 E.63109
G1 X172.758 Y151.352 E.01325
G1 X157.913 Y136.507 E.62595
G1 X157.602 Y136.73 E.01141
G1 X172.345 Y151.473 E.62163
G2 X171.945 Y151.607 I.825 J3.112 E.01257
G1 X157.292 Y136.954 E.61786
G1 X156.999 Y137.194 E.01131
G1 X171.559 Y151.754 E.61392
G1 X171.191 Y151.921 E.01202
G1 X156.706 Y137.435 E.6108
G1 X156.413 Y137.676 E.01131
G1 X170.836 Y152.099 E.60817
G2 X170.491 Y152.287 I1.263 J2.728 E.01174
G1 X156.12 Y137.916 E.60597
G2 X155.827 Y138.157 I1.691 J2.349 E.01131
G1 X170.161 Y152.492 E.60442
G2 X169.845 Y152.709 I1.692 J2.799 E.01145
G1 X155.551 Y138.416 E.60271
G1 X155.276 Y138.674 E.01126
G1 X169.534 Y152.932 E.60122
G1 X169.241 Y153.173 E.01131
G1 X155 Y138.932 E.60048
G1 X154.724 Y139.19 E.01126
G1 X168.957 Y153.423 E.60014
G1 X168.682 Y153.681 E.01126
G1 X154.449 Y139.448 E.60014
G1 X154.191 Y139.724 E.01126
G1 X168.424 Y153.957 E.60014
G2 X168.173 Y154.24 I2.038 J2.052 E.01128
G1 X153.932 Y140 E.60048
G1 X153.674 Y140.275 E.01126
G1 X167.933 Y154.533 E.60122
G2 X167.708 Y154.843 I2.245 J1.865 E.0114
G1 X153.416 Y140.551 E.60264
G1 X153.158 Y140.826 E.01126
G1 X167.492 Y155.161 E.60442
G1 X167.288 Y155.49 E.01156
G1 X152.917 Y141.119 E.60596
G1 X152.676 Y141.412 E.01131
G1 X167.099 Y155.835 E.60817
G2 X166.921 Y156.191 I2.62 J1.537 E.01187
G1 X152.436 Y141.705 E.61079
G1 X152.195 Y141.999 E.01131
G1 X166.754 Y156.558 E.61392
G2 X166.607 Y156.945 I2.869 J1.314 E.01234
G1 X151.954 Y142.292 E.61786
G2 X151.731 Y142.602 I2.26 J1.867 E.01141
G1 X166.473 Y157.344 E.62162
G2 X166.352 Y157.757 I3.089 J1.125 E.01285
G1 X151.508 Y142.913 E.62594
G1 X151.285 Y143.224 E.01141
G1 X166.251 Y158.19 E.63108
G2 X166.172 Y158.644 I3.423 J.833 E.01376
G1 X151.062 Y143.535 E.63712
G1 X150.839 Y143.846 E.01141
G1 X166.113 Y159.119 E.64401
G2 X166.077 Y159.617 I3.784 J.523 E.0149
G1 X150.634 Y144.174 E.65115
G1 X150.429 Y144.503 E.01156
G1 X166.069 Y160.143 E.65945
G2 X166.095 Y160.703 I4.29 J.08 E.01673
G1 X150.225 Y144.833 E.66918
G1 X150.02 Y145.162 E.01156
G1 X166.164 Y161.305 E.6807
G2 X166.287 Y161.962 I5.08 J-.614 E.01995
G1 X149.817 Y145.492 E.69448
G1 X149.631 Y145.84 E.01176
G1 X166.484 Y162.693 E.71063
G2 X166.8 Y163.543 I9.322 J-2.985 E.02706
G1 X149.445 Y146.188 E.73182
G1 X149.259 Y146.536 E.01176
G1 X167.377 Y164.653 E.76395
G2 X170.347 Y167.623 I7.503 J-4.534 E.12645
G1 X188.464 Y185.741 E.76395
G1 X188.812 Y185.555 E.01176
G1 X171.457 Y168.199 E.73182
G2 X172.307 Y168.516 I3.837 J-9.009 E.02706
G1 X189.16 Y185.369 E.71063
G1 X189.508 Y185.183 E.01176
G1 X173.038 Y168.713 E.69448
G2 X173.695 Y168.836 I1.271 J-4.956 E.01995
G1 X189.838 Y184.98 E.6807
G1 X190.167 Y184.775 E.01156
G1 X174.297 Y168.905 E.66918
G2 X174.857 Y168.931 I.479 J-4.261 E.01672
G1 X190.497 Y184.571 E.65945
G1 X190.826 Y184.366 E.01156
G1 X175.383 Y168.923 E.65115
G2 X175.881 Y168.887 I-.025 J-3.822 E.0149
G1 X191.154 Y184.161 E.64401
G1 X191.465 Y183.938 E.01141
G1 X176.356 Y168.828 E.63712
G2 X176.81 Y168.749 I-.381 J-3.512 E.01376
G1 X191.776 Y183.715 E.63108
G1 X192.087 Y183.492 E.01141
G1 X177.243 Y168.648 E.62594
G2 X177.656 Y168.527 I-.712 J-3.213 E.01285
G1 X192.398 Y183.269 E.62162
G2 X192.708 Y183.046 I-1.551 J-2.476 E.01141
G1 X178.055 Y168.393 E.61786
G2 X178.442 Y168.246 I-.927 J-3.015 E.01234
G1 X193.002 Y182.805 E.61392
G1 X193.295 Y182.565 E.01131
G1 X178.809 Y168.079 E.61079
G2 X179.165 Y167.901 I-1.184 J-2.802 E.01187
G1 X193.588 Y182.324 E.60817
G1 X193.881 Y182.083 E.01131
M73 P59 R14
G1 X179.51 Y167.712 E.60596
G1 X179.839 Y167.508 E.01156
G1 X194.174 Y181.842 E.60442
G1 X194.449 Y181.584 E.01126
G1 X180.156 Y167.29 E.60271
G2 X180.466 Y167.067 I-1.386 J-2.263 E.01142
G1 X194.725 Y181.326 E.60122
G1 X195 Y181.068 E.01126
G1 X180.76 Y166.827 E.60048
G2 X181.043 Y166.576 I-1.765 J-2.286 E.01128
G1 X195.276 Y180.809 E.60014
G1 X195.552 Y180.551 E.01126
G1 X181.319 Y166.318 E.60014
G1 X181.577 Y166.043 E.01126
G1 X195.81 Y180.276 E.60014
G1 X196.068 Y180 E.01126
G1 X181.827 Y165.759 E.60048
G1 X182.068 Y165.466 E.01131
G1 X196.326 Y179.724 E.60122
G1 X196.584 Y179.449 E.01126
G1 X182.292 Y165.157 E.60264
G2 X182.508 Y164.839 I-2.316 J-1.805 E.01147
G1 X196.843 Y179.173 E.60442
G2 X197.084 Y178.88 I-2.103 J-1.979 E.01131
G1 X182.713 Y164.509 E.60597
G2 X182.901 Y164.164 I-2.536 J-1.606 E.01174
G1 X197.324 Y178.587 E.60817
G1 X197.565 Y178.294 E.01131
G1 X183.079 Y163.809 E.6108
G1 X183.246 Y163.441 E.01202
G1 X197.806 Y178.001 E.61393
G1 X198.046 Y177.708 E.01131
G1 X183.393 Y163.055 E.61787
G2 X183.527 Y162.655 I-2.98 J-1.225 E.01257
G1 X198.27 Y177.398 E.62163
G1 X198.493 Y177.087 E.01141
G1 X183.648 Y162.242 E.62595
G1 X183.749 Y161.809 E.01325
G1 X198.716 Y176.776 E.63109
G1 X198.938 Y176.465 E.01141
G1 X183.828 Y161.355 E.63713
G2 X183.888 Y160.88 I-3.591 J-.689 E.01427
G1 X199.161 Y176.154 E.64403
G2 X199.366 Y175.825 I-2.43 J-1.744 E.01156
G1 X183.923 Y160.382 E.65117
G2 X183.931 Y159.856 I-4.005 J-.323 E.0157
G1 X199.571 Y175.496 E.65947
G1 X199.776 Y175.167 E.01156
G1 X183.905 Y159.296 E.6692
G2 X183.836 Y158.694 I-4.631 J.223 E.01809
G1 X199.98 Y174.838 E.68073
G2 X200.184 Y174.507 I-2.413 J-1.712 E.01158
G1 X183.713 Y158.036 E.69451
G2 X183.515 Y157.305 I-5.673 J1.139 E.02259
G1 X200.37 Y174.159 E.71067
G1 X200.556 Y173.811 E.01176
G1 X183.199 Y156.455 E.73187
G2 X182.622 Y155.344 I-8.47 J3.695 E.03735
G1 X200.741 Y173.464 E.76404
G1 X200.927 Y173.116 E.01176
G1 X161.884 Y134.073 E1.64629
G3 X162.237 Y133.892 I1.559 J2.603 E.01183
G1 X201.108 Y172.763 E1.63905
G1 X201.275 Y172.396 E.01202
G1 X162.604 Y133.725 E1.63058
G1 X162.972 Y133.559 E.01202
G1 X201.441 Y172.028 E1.62211
G1 X201.608 Y171.661 E.01202
G1 X163.339 Y133.392 E1.61364
G1 X163.706 Y133.226 E.01202
G1 X201.774 Y171.294 E1.60517
G2 X201.93 Y170.915 I-2.807 J-1.375 E.0122
M73 P59 R13
G1 X164.085 Y133.07 E1.59577
G1 X164.472 Y132.924 E.01236
G1 X202.076 Y170.528 E1.58558
G1 X202.222 Y170.14 E.01236
G1 X164.86 Y132.778 E1.57538
G1 X165.248 Y132.632 E.01236
G1 X202.368 Y169.752 E1.56518
G1 X202.514 Y169.364 E.01236
G1 X165.636 Y132.486 E1.55498
G3 X166.044 Y132.361 I1.163 J3.057 E.01275
G1 X202.639 Y168.956 E1.54305
G1 X202.763 Y168.546 E.01276
G1 X166.454 Y132.237 E1.53102
G1 X166.863 Y132.112 E.01276
G1 X202.888 Y168.137 E1.51899
G1 X203.012 Y167.727 E.01276
G1 X167.273 Y131.988 E1.50696
G3 X167.694 Y131.876 I1.069 J3.157 E.01301
G1 X203.124 Y167.306 E1.49395
G1 X203.225 Y166.873 E.01325
G1 X168.127 Y131.775 E1.47995
G1 X168.56 Y131.674 E.01325
G1 X203.326 Y166.44 E1.46595
G1 X203.427 Y166.007 E.01325
G1 X168.993 Y131.573 E1.45196
G3 X169.431 Y131.478 I.945 J3.293 E.01339
G1 X203.522 Y165.569 E1.43749
G1 X203.598 Y165.111 E.01385
G1 X169.889 Y131.402 E1.42136
G1 X170.348 Y131.326 E.01385
G1 X203.674 Y164.652 E1.40523
G1 X203.749 Y164.194 E.01385
G1 X170.806 Y131.251 E1.3891
G3 X171.267 Y131.178 I.782 J3.49 E.01394
G1 X203.822 Y163.733 E1.37268
G1 X203.869 Y163.247 E.01456
G1 X171.753 Y131.131 E1.35421
G1 X172.239 Y131.083 E.01456
G1 X203.917 Y162.761 E1.33573
G1 X203.965 Y162.275 E.01456
G1 X172.725 Y131.035 E1.31726
G3 X173.219 Y130.995 I.533 J3.503 E.01478
G1 X204.006 Y161.782 E1.29816
G1 X204.023 Y161.265 E.01542
G1 X173.738 Y130.98 E1.27699
G1 X174.257 Y130.965 E.01549
G1 X204.04 Y160.748 E1.25581
G1 X204.057 Y160.231 E.01542
G1 X174.776 Y130.951 E1.23463
G3 X175.305 Y130.946 I.306 J4.336 E.01578
G1 X204.054 Y159.695 E1.21224
G1 X204.036 Y159.143 E.01646
G1 X175.857 Y130.964 E1.1882
G1 X176.409 Y130.982 E.01646
G1 X204.018 Y158.591 E1.16417
G2 X203.996 Y158.035 I-4.253 J-.107 E.01661
G1 X176.965 Y131.004 E1.13977
G1 X177.557 Y131.063 E.01774
G1 X203.937 Y157.443 E1.11235
G1 X203.879 Y156.851 E.01774
G1 X178.149 Y131.121 E1.08492
G1 X178.741 Y131.179 E.01774
G1 X203.821 Y156.259 E1.0575
G2 X203.719 Y155.623 I-4.896 J.456 E.01919
G1 X179.377 Y131.281 E1.02644
G1 X180.016 Y131.386 E.01932
G1 X203.614 Y154.984 E.99503
G1 X203.508 Y154.345 E.01932
G1 X180.655 Y131.492 E.96362
G3 X181.35 Y131.653 I-.877 J5.364 E.02128
G1 X203.347 Y153.65 E.92753
G1 X203.185 Y152.954 E.02131
G1 X182.046 Y131.815 E.89134
G3 X182.764 Y132 I-1.048 J5.57 E.02213
G1 X203 Y152.236 E.85327
G1 X202.768 Y151.469 E.02387
G1 X183.531 Y132.232 E.81116
G1 X184.297 Y132.464 E.02387
M73 P60 R13
G1 X202.536 Y150.703 E.76905
G1 X202.219 Y149.853 E.02706
G1 X185.147 Y132.781 E.71983
G1 X186.003 Y133.103 E.02727
G1 X201.897 Y148.997 E.67015
G1 X201.471 Y148.037 E.03129
G1 X186.963 Y133.529 E.61176
G1 X187.953 Y133.986 E.03253
G1 X201.014 Y147.047 E.55072
G1 X200.401 Y145.9 E.03877
G1 X189.1 Y134.599 E.47652
G3 X190.412 Y135.377 I-5.277 J10.392 E.04551
G1 X199.623 Y144.588 E.3884
G2 X198.519 Y142.95 I-13.046 J7.603 E.05893
G1 X192.05 Y136.481 E.2728
G1 X192.693 Y136.942 E.0236
G1 X194.163 Y138.148 E.05671
G1 X195.548 Y139.446 E.05658
G1 X197.674 Y141.571 E.08963
M204 S10000
G1 X188.242 Y186.052 F30000
G1 F9537.687
M204 S4000
G1 X149.073 Y146.884 E1.65159
G2 X148.892 Y147.236 I2.601 J1.559 E.01183
G1 X187.764 Y186.108 E1.63907
G1 X187.396 Y186.275 E.01202
G1 X148.725 Y147.604 E1.6306
G1 X148.559 Y147.971 E.01202
G1 X187.029 Y186.441 E1.62213
G1 X186.662 Y186.607 E.01202
G1 X148.393 Y148.338 E1.61366
G1 X148.226 Y148.706 E.01202
G1 X186.294 Y186.774 E1.60518
G3 X185.916 Y186.929 I-1.376 J-2.808 E.0122
G1 X148.071 Y149.084 E1.59579
G1 X147.925 Y149.472 E.01236
G1 X185.528 Y187.075 E1.5856
G1 X185.14 Y187.221 E.01236
G1 X147.779 Y149.86 E1.5754
G1 X147.633 Y150.247 E.01236
G1 X184.753 Y187.367 E1.5652
G1 X184.365 Y187.513 E.01236
G1 X147.487 Y150.635 E1.555
G2 X147.361 Y151.043 I3.04 J1.158 E.01274
G1 X183.957 Y187.639 E1.54308
G1 X183.547 Y187.763 E.01276
G1 X147.237 Y151.453 E1.53105
G1 X147.113 Y151.863 E.01276
G1 X183.137 Y187.887 E1.51901
G1 X182.728 Y188.012 E.01276
G1 X146.988 Y152.272 E1.50698
G2 X146.876 Y152.693 I3.157 J1.07 E.01301
G1 X182.307 Y188.124 E1.49397
G1 X181.874 Y188.225 E.01325
G1 X146.775 Y153.126 E1.47998
G1 X146.674 Y153.559 E.01325
G1 X181.441 Y188.326 E1.46598
G1 X181.008 Y188.427 E.01325
G1 X146.573 Y153.992 E1.45199
G2 X146.478 Y154.43 I3.294 J.946 E.01339
G1 X180.57 Y188.522 E1.43752
G1 X180.112 Y188.598 E.01385
G1 X146.402 Y154.888 E1.42139
G1 X146.326 Y155.347 E.01385
G1 X179.653 Y188.674 E1.40526
G1 X179.195 Y188.749 E.01385
G1 X146.251 Y155.805 E1.38913
G2 X146.179 Y156.266 I3.494 J.783 E.01394
G1 X178.734 Y188.821 E1.37272
G1 X178.248 Y188.869 E.01456
G1 X146.131 Y156.752 E1.35424
G1 X146.083 Y157.238 E.01456
G1 X177.762 Y188.917 E1.33577
G1 X177.276 Y188.965 E.01456
G1 X146.035 Y157.724 E1.3173
G2 X145.994 Y158.217 I3.743 J.558 E.01476
G1 X176.783 Y189.006 E1.29823
G1 X176.266 Y189.023 E.01542
G1 X145.977 Y158.734 E1.27715
G1 X145.96 Y159.251 E.01542
G1 X175.749 Y189.04 E1.25607
G1 X175.232 Y189.057 E.01542
G1 X145.943 Y159.768 E1.23499
G2 X145.946 Y160.304 I4.087 J.25 E.016
G1 X174.696 Y189.054 E1.21228
G1 X174.144 Y189.036 E.01646
G1 X145.964 Y160.856 E1.18825
G1 X145.982 Y161.408 E.01646
G1 X173.592 Y189.018 E1.16422
G3 X173.036 Y188.996 I-.107 J-4.256 E.01661
G1 X146.004 Y161.964 E1.13983
G1 X146.063 Y162.556 E.01774
G1 X172.444 Y188.937 E1.1124
G1 X171.852 Y188.879 E.01774
G1 X146.121 Y163.148 E1.08498
G1 X146.179 Y163.74 E.01774
G1 X171.26 Y188.821 E1.05755
G3 X170.625 Y188.72 I.456 J-4.9 E.01919
G1 X146.281 Y164.375 E1.0265
G1 X146.386 Y165.015 E.01932
G1 X169.985 Y188.614 E.99509
G1 X169.346 Y188.508 E.01932
G1 X146.492 Y165.654 E.96368
G2 X146.652 Y166.349 I5.375 J-.879 E.02127
G1 X168.651 Y188.348 E.92761
G1 X167.955 Y188.185 E.02131
G1 X146.815 Y167.045 E.89141
G2 X146.999 Y167.763 I5.571 J-1.047 E.02212
G1 X167.237 Y188.001 E.85336
G1 X166.471 Y187.768 E.02387
G1 X147.232 Y168.529 E.81125
G1 X147.464 Y169.295 E.02387
G1 X165.705 Y187.536 E.76914
G1 X164.854 Y187.219 E.02706
G1 X147.781 Y170.146 E.71993
G1 X148.103 Y171.002 E.02727
G1 X163.998 Y186.897 E.67025
G1 X163.039 Y186.472 E.03128
G1 X148.528 Y171.961 E.61188
G1 X148.985 Y172.951 E.03252
G1 X162.049 Y186.015 E.55087
G1 X160.902 Y185.402 E.03877
G1 X149.598 Y174.098 E.47667
G2 X150.375 Y175.409 I10.391 J-5.275 E.04549
G1 X159.591 Y184.625 E.38859
G3 X157.954 Y183.522 I7.596 J-13.038 E.05889
G1 X151.478 Y177.046 E.27307
G1 X151.942 Y177.693 E.02373
G1 X153.149 Y179.163 E.05672
G1 X154.43 Y180.531 E.05588
G1 X156.577 Y182.679 E.09055
; CHANGE_LAYER
; Z_HEIGHT: 0.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9537.687
G1 X155.163 Y181.265 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 4/30
; update layer progress
M73 L4
M991 S0 P3 ;notify layer change

M106 S25.5
; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z1 I.833 J.887 P1  F30000
G1 X170.209 Y167.144 Z1
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X169.769 Y166.818 E.01762
G3 X174.518 Y151.413 I5.24 J-6.819 E.67176
G3 X176.678 Y151.563 I.498 J8.489 E.06982
G3 X170.261 Y167.169 I-1.669 J8.436 E.97646
; COOLING_NODE: 0
M204 S250
G1 X170.437 Y166.825 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.007 Y166.507 E.01593
G3 X174.531 Y151.805 I5.001 J-6.508 E.59366
G3 X176.602 Y151.948 I.482 J8.112 E.062
G3 X170.486 Y166.849 I-1.594 J8.051 E.86288
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.007 Y166.507 E-.22371
G1 X169.587 Y166.173 E-.20414
G1 X169.195 Y165.805 E-.20413
G1 X168.964 Y165.56 E-.12801
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.388 Y161.686 Z1.2 F30000
G1 X146.604 Y152.391 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06185
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06186
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06185
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.55 Y132.163 E.06186
G1 X167.391 Y131.604 E.06186
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.209 Y130.609 E.00673
G1 X176.923 Y130.665 E.05513
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06185
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
M73 P61 R13
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06186
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.837 Y150.55 E.06186
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.837 Y169.45 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06185
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06185
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.45 Y187.837 E.06186
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.55 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06185
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06185
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.163 Y169.45 E.06186
G1 X146.604 Y167.609 E.06186
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.289 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05804
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05807
G1 X155.53 Y137.462 E.00662
G1 X156.865 Y136.366 E.05145
G1 X158.45 Y135.231 E.05807
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05806
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.222 Y130.217 E.00662
G1 X176.948 Y130.274 E.05145
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05807
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05807
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05806
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05806
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05806
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05806
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05806
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.212 Y152.348 E.0563
; WIPE_START
M204 S4000
G1 X146.789 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.833 Y143.96 Z1.2 F30000
G1 X152.321 Y141.577 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42037
G1 F9537.687
M204 S4000
G1 X154.469 Y139.43 E.09055
G1 X155.837 Y138.148 E.05589
G1 X157.307 Y136.942 E.05671
G1 X157.954 Y136.478 E.02374
G1 X151.478 Y142.954 E.27307
G2 X150.375 Y144.591 I11.933 J9.231 E.05889
G1 X159.591 Y135.375 E.38859
G3 X160.902 Y134.598 I6.585 J9.611 E.04549
G1 X149.598 Y145.902 E.47667
G1 X148.985 Y147.049 E.03877
G1 X162.049 Y133.985 E.55086
G1 X163.039 Y133.528 E.03252
G1 X148.528 Y148.039 E.61188
G1 X148.103 Y148.998 E.03128
G1 X163.998 Y133.103 E.67025
G1 X164.854 Y132.781 E.02727
G1 X147.781 Y149.854 E.71993
G1 X147.464 Y150.705 E.02706
G1 X165.705 Y132.464 E.76914
G1 X166.471 Y132.232 E.02387
G1 X147.232 Y151.471 E.81125
G1 X146.999 Y152.237 E.02387
G1 X167.237 Y131.999 E.85336
G3 X167.955 Y131.815 I1.765 J5.383 E.02212
G1 X146.815 Y152.955 E.89141
G1 X146.652 Y153.651 E.02131
G1 X168.651 Y131.652 E.92761
G3 X169.346 Y131.492 I1.571 J5.205 E.02127
G1 X146.492 Y154.346 E.96368
G1 X146.386 Y154.985 E.01932
G1 X169.985 Y131.386 E.99509
G1 X170.625 Y131.28 E.01932
G1 X146.281 Y155.625 E1.0265
G2 X146.179 Y156.26 I4.789 J1.09 E.01919
G1 X171.26 Y131.179 E1.05755
G1 X171.852 Y131.121 E.01774
G1 X146.121 Y156.852 E1.08498
G1 X146.063 Y157.444 E.01774
G1 X172.444 Y131.063 E1.1124
G1 X173.036 Y131.004 E.01774
G1 X146.004 Y158.036 E1.13983
G2 X145.982 Y158.592 I4.235 J.449 E.01661
G1 X173.592 Y130.982 E1.16422
G1 X174.144 Y130.964 E.01646
G1 X145.964 Y159.144 E1.18825
G1 X145.946 Y159.696 E.01646
G1 X174.696 Y130.946 E1.21228
G3 X175.198 Y130.942 I.277 J3.828 E.01499
G1 X175.232 Y130.943 E.00101
G1 X145.943 Y160.232 E1.23499
G1 X145.96 Y160.749 E.01542
G1 X175.749 Y130.96 E1.25607
G1 X176.266 Y130.977 E.01542
G1 X145.977 Y161.266 E1.27715
G1 X145.994 Y161.783 E.01542
G1 X176.783 Y130.994 E1.29823
G3 X177.276 Y131.035 I-.065 J3.785 E.01476
G1 X146.035 Y162.276 E1.3173
G1 X146.083 Y162.762 E.01456
G1 X177.762 Y131.083 E1.33577
G1 X178.248 Y131.131 E.01456
G1 X146.131 Y163.248 E1.35424
G1 X146.179 Y163.734 E.01456
G1 X178.734 Y131.179 E1.37272
G3 X179.195 Y131.251 I-.32 J3.558 E.01394
G1 X146.251 Y164.195 E1.38913
G1 X146.326 Y164.653 E.01385
G1 X179.653 Y131.326 E1.40526
G1 X180.112 Y131.402 E.01385
G1 X146.402 Y165.111 E1.42139
G1 X146.478 Y165.57 E.01385
G1 X180.57 Y131.478 E1.43752
G3 X181.008 Y131.573 I-.508 J3.393 E.01339
G1 X146.573 Y166.008 E1.45199
G1 X146.674 Y166.441 E.01325
G1 X181.441 Y131.674 E1.46598
G1 X181.874 Y131.775 E.01325
G1 X146.775 Y166.874 E1.47998
G1 X146.876 Y167.307 E.01325
G1 X182.307 Y131.876 E1.49397
G3 X182.728 Y131.988 I-.648 J3.266 E.01301
G1 X146.988 Y167.728 E1.50698
G1 X147.113 Y168.137 E.01276
G1 X183.137 Y132.113 E1.51901
G1 X183.547 Y132.237 E.01276
G1 X147.237 Y168.547 E1.53105
G1 X147.361 Y168.957 E.01276
G1 X183.957 Y132.361 E1.54308
G3 X184.365 Y132.487 I-.75 J3.166 E.01274
G1 X147.487 Y169.365 E1.555
G1 X147.633 Y169.753 E.01236
G1 X184.753 Y132.633 E1.5652
G1 X185.14 Y132.779 E.01236
G1 X147.779 Y170.14 E1.5754
G1 X147.925 Y170.528 E.01236
G1 X185.528 Y132.925 E1.5856
G1 X185.916 Y133.071 E.01236
G1 X148.071 Y170.916 E1.59579
G2 X148.226 Y171.294 I2.966 J-.999 E.0122
G1 X186.294 Y133.226 E1.60518
G1 X186.662 Y133.393 E.01202
G1 X148.393 Y171.662 E1.61365
G1 X148.559 Y172.029 E.01202
G1 X187.029 Y133.559 E1.62213
G1 X187.396 Y133.725 E.01202
G1 X148.725 Y172.396 E1.6306
G1 X148.892 Y172.764 E.01202
G1 X187.764 Y133.892 E1.63907
G3 X188.116 Y134.073 I-1.205 J2.78 E.01183
G1 X148.948 Y173.242 E1.65159
M204 S10000
G1 X193.429 Y182.674 F30000
G1 F9537.687
M204 S4000
G1 X195.554 Y180.548 E.08963
M73 P62 R13
G1 X196.852 Y179.163 E.05658
G1 X198.058 Y177.693 E.05672
G1 X198.519 Y177.05 E.0236
G1 X192.05 Y183.519 E.2728
G3 X190.412 Y184.623 I-9.241 J-11.943 E.05893
G1 X199.623 Y175.412 E.3884
G2 X200.401 Y174.1 I-9.617 J-6.591 E.04551
G1 X189.1 Y185.401 E.47652
G1 X187.953 Y186.014 E.03877
G1 X201.014 Y172.953 E.55072
G1 X201.471 Y171.963 E.03253
G1 X186.963 Y186.471 E.61176
G1 X186.003 Y186.897 E.03129
G1 X201.897 Y171.003 E.67015
G1 X202.219 Y170.147 E.02727
G1 X185.147 Y187.219 E.71983
G1 X184.297 Y187.536 E.02706
G1 X202.536 Y169.297 E.76905
G1 X202.768 Y168.531 E.02387
G1 X183.531 Y187.768 E.81116
G1 X182.764 Y188 E.02387
G1 X203 Y167.764 E.85327
G2 X203.185 Y167.046 I-5.386 J-1.766 E.02213
G1 X182.046 Y188.185 E.89134
G1 X181.35 Y188.347 E.02131
G1 X203.347 Y166.35 E.92753
G2 X203.508 Y165.655 I-5.213 J-1.574 E.02128
G1 X180.655 Y188.508 E.96362
G1 X180.016 Y188.614 E.01932
G1 X203.614 Y165.016 E.99503
G1 X203.719 Y164.377 E.01932
G1 X179.377 Y188.719 E1.02644
G3 X178.741 Y188.821 I-1.091 J-4.796 E.01919
G1 X203.821 Y163.741 E1.0575
G1 X203.879 Y163.149 E.01774
G1 X178.149 Y188.879 E1.08492
G1 X177.557 Y188.937 E.01774
G1 X203.937 Y162.557 E1.11235
G1 X203.996 Y161.965 E.01774
G1 X176.965 Y188.996 E1.13977
G3 X176.409 Y189.018 I-.449 J-4.239 E.01661
G1 X204.018 Y161.409 E1.16417
G1 X204.036 Y160.857 E.01646
G1 X175.857 Y189.036 E1.1882
G1 X175.305 Y189.054 E.01646
G1 X204.054 Y160.305 E1.21224
G2 X204.057 Y159.769 I-4.088 J-.287 E.016
G1 X174.769 Y189.057 E1.23495
G1 X174.252 Y189.04 E.01542
G1 X204.04 Y159.252 E1.25603
G1 X204.023 Y158.735 E.01542
M73 P62 R12
G1 X173.735 Y189.023 E1.27711
G1 X173.218 Y189.006 E.01542
G1 X204.006 Y158.218 E1.29819
G2 X203.965 Y157.725 I-3.786 J.065 E.01476
G1 X172.725 Y188.965 E1.31726
G1 X172.239 Y188.917 E.01456
G1 X203.917 Y157.239 E1.33574
G1 X203.869 Y156.753 E.01456
G1 X171.753 Y188.869 E1.35421
G1 X171.267 Y188.822 E.01456
G1 X203.822 Y156.267 E1.37268
G2 X203.749 Y155.806 I-3.553 J.319 E.01394
G1 X170.806 Y188.749 E1.3891
G1 X170.348 Y188.674 E.01385
G1 X203.674 Y155.348 E1.40523
G1 X203.598 Y154.889 E.01385
G1 X169.889 Y188.598 E1.42136
G1 X169.431 Y188.522 E.01385
G1 X203.522 Y154.431 E1.43749
G2 X203.427 Y153.993 I-3.393 J.508 E.01339
G1 X168.993 Y188.427 E1.45196
G1 X168.56 Y188.326 E.01325
G1 X203.326 Y153.56 E1.46595
G1 X203.225 Y153.127 E.01325
G1 X168.127 Y188.225 E1.47995
G1 X167.694 Y188.124 E.01325
G1 X203.124 Y152.694 E1.49395
G2 X203.012 Y152.273 I-3.27 J.648 E.01301
G1 X167.273 Y188.012 E1.50696
G1 X166.863 Y187.888 E.01276
G1 X202.888 Y151.863 E1.51899
G1 X202.763 Y151.454 E.01276
G1 X166.454 Y187.763 E1.53102
G1 X166.044 Y187.639 E.01276
G1 X202.639 Y151.044 E1.54305
G2 X202.514 Y150.636 I-3.179 J.753 E.01275
G1 X165.636 Y187.514 E1.55498
G1 X165.248 Y187.368 E.01236
G1 X202.368 Y150.248 E1.56518
G1 X202.222 Y149.86 E.01236
G1 X164.86 Y187.222 E1.57538
G1 X164.472 Y187.076 E.01236
G1 X202.076 Y149.472 E1.58557
G1 X201.93 Y149.085 E.01236
G1 X164.085 Y186.93 E1.59577
G3 X163.706 Y186.774 I.996 J-2.962 E.0122
G1 X201.774 Y148.706 E1.60517
G1 X201.608 Y148.339 E.01202
G1 X163.339 Y186.608 E1.61364
G1 X162.972 Y186.441 E.01202
G1 X201.441 Y147.972 E1.62211
G1 X201.275 Y147.604 E.01202
G1 X162.604 Y186.275 E1.63058
G1 X162.237 Y186.108 E.01202
G1 X201.108 Y147.237 E1.63905
G2 X200.927 Y146.884 I-2.783 J1.206 E.01183
G1 X161.884 Y185.927 E1.64629
G1 X161.536 Y185.741 E.01176
G1 X179.656 Y167.622 E.76404
G3 X178.545 Y168.199 I-4.804 J-7.891 E.03735
G1 X161.189 Y185.555 E.73187
G1 X160.841 Y185.37 E.01176
G1 X177.695 Y168.515 E.71067
G3 X176.964 Y168.713 I-1.868 J-5.472 E.02259
G1 X160.493 Y185.184 E.69451
G3 X160.162 Y184.98 I1.385 J-2.621 E.01158
G1 X176.306 Y168.836 E.68073
G3 X175.704 Y168.905 I-.825 J-4.557 E.01809
G1 X159.833 Y184.776 E.6692
G1 X159.504 Y184.571 E.01156
G1 X175.144 Y168.931 E.65947
G3 X174.618 Y168.923 I-.203 J-4.013 E.0157
G1 X159.175 Y184.366 E.65117
G3 X158.846 Y184.161 I1.405 J-2.618 E.01156
G1 X174.12 Y168.888 E.64403
G3 X173.645 Y168.828 I.215 J-3.647 E.01427
G1 X158.535 Y183.938 E.63713
G1 X158.224 Y183.716 E.01141
G1 X173.191 Y168.749 E.63109
G1 X172.758 Y168.648 E.01325
G1 X157.913 Y183.493 E.62595
G1 X157.602 Y183.27 E.01141
G1 X172.345 Y168.527 E.62163
G3 X171.945 Y168.393 I.828 J-3.12 E.01257
G1 X157.292 Y183.046 E.61787
G1 X156.999 Y182.806 E.01131
G1 X171.559 Y168.246 E.61393
G1 X171.192 Y168.079 E.01202
G1 X156.706 Y182.565 E.6108
G1 X156.413 Y182.324 E.01131
G1 X170.836 Y167.901 E.60817
G3 X170.491 Y167.713 I1.26 J-2.723 E.01174
G1 X156.12 Y182.084 E.60596
G3 X155.827 Y181.843 I1.701 J-2.361 E.01131
G1 X170.161 Y167.508 E.60442
G3 X169.843 Y167.292 I1.488 J-2.533 E.01147
G1 X155.551 Y181.584 E.60264
G1 X155.276 Y181.326 E.01126
G1 X169.534 Y167.068 E.60122
G1 X169.241 Y166.827 E.01131
M73 P63 R12
G1 X155 Y181.068 E.60048
G1 X154.724 Y180.81 E.01126
G1 X168.957 Y166.577 E.60014
G1 X168.682 Y166.319 E.01126
G1 X154.449 Y180.552 E.60014
G1 X154.191 Y180.276 E.01126
G1 X168.424 Y166.043 E.60014
G3 X168.173 Y165.76 I2.037 J-2.05 E.01128
G1 X153.932 Y180 E.60048
G1 X153.674 Y179.725 E.01126
G1 X167.933 Y165.467 E.60122
G3 X167.708 Y165.157 I2.248 J-1.867 E.0114
G1 X153.416 Y179.449 E.60264
G1 X153.158 Y179.174 E.01126
G1 X167.492 Y164.839 E.60442
G1 X167.288 Y164.51 E.01156
G1 X152.917 Y178.881 E.60596
G1 X152.676 Y178.588 E.01131
G1 X167.099 Y164.165 E.60817
G3 X166.921 Y163.809 I2.623 J-1.538 E.01187
G1 X152.436 Y178.295 E.61079
G1 X152.195 Y178.001 E.01131
G1 X166.754 Y163.442 E.61392
G3 X166.607 Y163.055 I2.879 J-1.318 E.01234
G1 X151.954 Y177.708 E.61786
G3 X151.731 Y177.398 I2.262 J-1.868 E.01141
G1 X166.473 Y162.656 E.62162
G3 X166.352 Y162.243 I3.091 J-1.125 E.01285
G1 X151.508 Y177.087 E.62594
G1 X151.285 Y176.776 E.01141
G1 X166.251 Y161.81 E.63108
G3 X166.172 Y161.356 I3.43 J-.835 E.01376
G1 X151.062 Y176.465 E.63712
G1 X150.839 Y176.154 E.01141
G1 X166.113 Y160.881 E.64401
G3 X166.077 Y160.383 I3.787 J-.523 E.0149
G1 X150.634 Y175.826 E.65115
G1 X150.429 Y175.497 E.01156
G1 X166.069 Y159.857 E.65945
G3 X166.095 Y159.297 I4.289 J-.08 E.01673
G1 X150.225 Y175.167 E.66918
G1 X150.02 Y174.838 E.01156
G1 X166.164 Y158.695 E.6807
G3 X166.287 Y158.038 I5.08 J.614 E.01995
G1 X149.817 Y174.508 E.69448
G1 X149.631 Y174.16 E.01176
G1 X166.484 Y157.307 E.71063
G3 X166.801 Y156.457 I9.337 J2.991 E.02706
G1 X149.445 Y173.812 E.73182
G1 X149.259 Y173.464 E.01176
G1 X167.377 Y155.347 E.76395
G3 X170.347 Y152.377 I7.503 J4.533 E.12646
G1 X188.464 Y134.259 E.76395
G1 X188.812 Y134.445 E.01176
G1 X171.457 Y151.8 E.73182
G3 X172.307 Y151.484 I3.836 J9.007 E.02706
G1 X189.16 Y134.631 E.71063
G1 X189.508 Y134.817 E.01176
G1 X173.038 Y151.287 E.69448
G3 X173.695 Y151.164 I1.271 J4.959 E.01995
G1 X189.838 Y135.02 E.6807
G1 X190.167 Y135.225 E.01156
G1 X174.293 Y151.099 E.66935
G3 X174.857 Y151.069 I.546 J4.914 E.01685
G1 X190.497 Y135.429 E.65945
G1 X190.826 Y135.634 E.01156
G1 X175.383 Y151.077 E.65115
G3 X175.881 Y151.113 I-.025 J3.823 E.0149
G1 X191.154 Y135.839 E.64401
G1 X191.465 Y136.062 E.01141
G1 X176.356 Y151.172 E.63712
G3 X176.81 Y151.251 I-.381 J3.514 E.01376
G1 X191.776 Y136.285 E.63108
G1 X192.087 Y136.508 E.01141
G1 X177.243 Y151.352 E.62594
G3 X177.656 Y151.473 I-.711 J3.207 E.01285
G1 X192.398 Y136.731 E.62162
G3 X192.708 Y136.954 I-1.557 J2.484 E.01141
G1 X178.055 Y151.607 E.61786
G3 X178.442 Y151.754 I-.933 J3.03 E.01234
G1 X193.001 Y137.195 E.61392
G1 X193.295 Y137.436 E.01131
G1 X178.809 Y151.921 E.61079
G3 X179.165 Y152.099 I-1.183 J2.801 E.01187
G1 X193.588 Y137.676 E.60817
G1 X193.881 Y137.917 E.01131
G1 X179.51 Y152.288 E.60596
G1 X179.839 Y152.492 E.01156
G1 X194.174 Y138.158 E.60442
G1 X194.449 Y138.416 E.01126
G1 X180.157 Y152.708 E.60264
G3 X180.467 Y152.933 I-1.551 J2.464 E.0114
G1 X194.725 Y138.674 E.60122
G1 X195 Y138.932 E.01126
G1 X180.76 Y153.173 E.60048
G3 X181.043 Y153.424 I-1.768 J2.288 E.01128
G1 X195.276 Y139.191 E.60014
G1 X195.552 Y139.449 E.01126
G1 X181.319 Y153.682 E.60014
G1 X181.577 Y153.957 E.01126
G1 X195.81 Y139.724 E.60014
G1 X196.068 Y140 E.01126
G1 X181.827 Y154.241 E.60048
G1 X182.068 Y154.534 E.01131
G1 X196.326 Y140.276 E.60122
G1 X196.584 Y140.551 E.01126
G1 X182.292 Y154.843 E.60264
G3 X182.508 Y155.161 I-2.319 J1.807 E.01147
G1 X196.843 Y140.827 E.60442
G3 X197.084 Y141.12 I-2.121 J1.995 E.01131
G1 X182.713 Y155.491 E.60597
G3 X182.901 Y155.836 I-2.534 J1.606 E.01174
G1 X197.324 Y141.413 E.60817
G1 X197.565 Y141.706 E.01131
G1 X183.079 Y156.191 E.6108
G1 X183.246 Y156.559 E.01202
G1 X197.806 Y141.999 E.61393
G1 X198.046 Y142.292 E.01131
G1 X183.393 Y156.945 E.61787
G3 X183.527 Y157.345 I-2.98 J1.225 E.01257
G1 X198.27 Y142.602 E.62163
G1 X198.493 Y142.913 E.01141
G1 X183.648 Y157.758 E.62595
G1 X183.749 Y158.191 E.01325
G1 X198.716 Y143.224 E.63109
G1 X198.938 Y143.535 E.01141
G1 X183.828 Y158.645 E.63713
G3 X183.888 Y159.12 I-3.586 J.689 E.01427
G1 X199.161 Y143.846 E.64403
G3 X199.366 Y144.175 I-2.375 J1.71 E.01156
G1 X183.923 Y159.618 E.65117
G3 X183.931 Y160.144 I-4.005 J.323 E.0157
G1 X199.571 Y144.504 E.65947
G1 X199.776 Y144.833 E.01156
G1 X183.905 Y160.704 E.6692
G3 X183.836 Y161.306 I-4.623 J-.222 E.01809
G1 X199.98 Y145.162 E.68073
G3 X200.184 Y145.493 I-2.41 J1.711 E.01158
G1 X183.713 Y161.964 E.69451
G3 X183.515 Y162.695 I-5.663 J-1.136 E.02259
G1 X200.37 Y145.841 E.71067
G1 X200.556 Y146.189 E.01176
G1 X183.199 Y163.545 E.73187
G3 X182.622 Y164.656 I-8.463 J-3.691 E.03735
G1 X200.867 Y146.411 E.76933
; CHANGE_LAYER
; Z_HEIGHT: 1
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9537.687
G1 X199.453 Y147.825 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 5/30
; update layer progress
M73 L5
M991 S0 P4 ;notify layer change

M106 S147.9
; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z1.2 I-.671 J-1.015 P1  F30000
G1 X170.209 Y167.144 Z1.2
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X169.767 Y166.819 E.01762
G3 X174.536 Y151.413 I5.241 J-6.819 E.67239
G3 X177.226 Y151.691 I.445 J8.855 E.08733
G3 X170.261 Y167.172 I-2.218 J8.31 E.95842
; COOLING_NODE: 0
M204 S250
G1 X170.437 Y166.825 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.007 Y166.508 E.01594
G3 X174.548 Y151.805 I5.003 J-6.508 E.59413
G3 X176.602 Y151.948 I.468 J8.094 E.06148
G3 X170.487 Y166.85 I-1.592 J8.052 E.86305
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.007 Y166.508 E-.224
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20413
G1 X168.965 Y165.56 E-.12773
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.388 Y161.687 Z1.4 F30000
G1 X146.604 Y152.391 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06186
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X155.829 Y137.723 E.00884
G1 X157.104 Y136.677 E.05303
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.275 Y130.611 E.00884
G1 X176.923 Y130.665 E.05303
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06186
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.837 Y169.45 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06186
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.55 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06186
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06186
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X149.411 Y174.456 E.00884
G1 X148.634 Y173.002 E.05302
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.289 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05804
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X151.549 Y141.643 E.00857
G1 X152.603 Y140.358 E.0495
G1 X153.935 Y138.935 E.05807
G1 X155.358 Y137.603 E.05806
G1 X155.58 Y137.42 E.00857
G1 X156.865 Y136.366 E.0495
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X160.359 Y134.066 E.00857
G1 X161.824 Y133.282 E.0495
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.287 Y130.22 E.00857
G1 X176.948 Y130.274 E.0495
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05807
G1 X197.397 Y140.358 E.05806
G1 X197.58 Y140.58 E.00857
G1 X198.634 Y141.865 E.0495
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X200.934 Y145.359 E.00857
G1 X201.718 Y146.824 E.0495
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05806
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05806
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05807
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X189.641 Y185.934 E.00857
G1 X188.176 Y186.718 E.0495
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05806
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05806
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05807
G1 X152.603 Y179.642 E.05807
G1 X152.42 Y179.42 E.00857
G1 X151.366 Y178.135 E.0495
G1 X150.231 Y176.55 E.05807
G1 X149.201 Y174.895 E.05807
G1 X149.066 Y174.641 E.00857
G1 X148.282 Y173.176 E.0495
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.212 Y152.348 E.0563
; WIPE_START
M204 S4000
G1 X146.789 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.057 Z1.4 F30000
G1 X147.687 Y169.854 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
M73 P64 R12
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X167.633 Y165.078 F30000
G1 F8843.478
M204 S4000
G2 X168.671 Y166.329 I7.988 J-5.569 E.05235
G1 X154.459 Y180.541 E.64629
G3 X150.988 Y176.336 I22.869 J-22.415 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G3 X154.459 Y139.459 I26.34 J18.211 E.17554
G1 X168.671 Y153.671 E.64629
G3 X169.922 Y152.633 I6.82 J6.95 E.05235
; WIPE_START
G1 X168.671 Y153.671 E-.61792
G1 X168.406 Y153.406 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X175.994 Y154.23 Z1.4 F30000
G1 X182.367 Y154.922 Z1.4
G1 Z1
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y153.671 I-7.988 J5.569 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.868 J22.414 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.87 Y161.194 I-11.532 J1.194 E.07693
G1 X199.012 Y176.336 E.6886
G1 X198.064 Y177.66 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.929 J-3.526 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I1.938 J12.284 E.05239
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J11.214 E.07694
G1 X158.664 Y135.988 E.6886
G1 X157.34 Y136.936 E.05236
; WIPE_START
G1 X158.664 Y135.988 E-.61876
G1 X158.927 Y136.251 E-.14124
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X163.742 Y142.172 Z1.4 F30000
G1 X182.367 Y165.078 Z1.4
G1 Z1
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X181.329 Y166.329 I-15.038 J-11.416 E.05231
G1 X195.541 Y180.541 E.64629
G3 X191.336 Y184.012 I-22.416 J-22.87 E.17554
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X167.92 Y188.162 F30000
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.526 J-11.929 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.281 J1.937 E.05239
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G2 X146.007 Y158.289 I35.37 J6.347 E.1226
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J28.108 E.11008
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.937 J12.282 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 1.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X180.492 Y131.48 E-.61863
G1 X180.229 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 6/30
; update layer progress
M73 L6
M991 S0 P5 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z1.4 I-1.171 J-.331 P1  F30000
G1 X170.209 Y167.144 Z1.4
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.768 Y166.818 E.01763
G3 X174.553 Y151.412 I5.24 J-6.819 E.67291
G3 X177.765 Y151.854 I.462 J8.537 E.1049
G3 X170.261 Y167.17 I-2.757 J8.145 E.94018
; COOLING_NODE: 0
M204 S250
G1 X170.437 Y166.825 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.508 E.01594
G3 X174.566 Y151.804 I5.002 J-6.508 E.59467
G3 X177.125 Y152.07 I.417 J8.444 E.07693
G3 X170.487 Y166.85 I-2.116 J7.931 E.847
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.508 E-.22414
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20413
G1 X168.965 Y165.56 E-.12758
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.388 Y161.687 Z1.6 F30000
G1 X146.604 Y152.391 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06185
G1 X151.677 Y142.104 E.06187
G1 X152.898 Y140.617 E.06185
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06185
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.34 Y130.614 E.01094
G1 X176.923 Y130.665 E.05092
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06185
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06186
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06185
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.837 Y169.45 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06185
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06186
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06185
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.55 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06185
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06186
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06185
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.225 Y152.29 E.00002
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05807
G1 X155.358 Y137.603 E.05806
G1 X155.631 Y137.379 E.01052
G1 X156.865 Y136.366 E.04755
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.353 Y130.222 E.01052
G1 X176.948 Y130.274 E.04755
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05807
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05806
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05807
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05806
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05807
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.211 Y152.349 E.05626
; WIPE_START
M204 S4000
G1 X146.225 Y152.29 E-.02304
G1 X146.788 Y150.434 E-.73696
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X151.489 Y144.421 Z1.6 F30000
G1 X157.34 Y136.936 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X158.664 Y135.988 E.05236
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J11.154 E.07694
G1 X191.336 Y135.988 E.6886
G1 X192.66 Y136.936 E.05236
M204 S10000
G1 X182.08 Y131.838 F30000
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.525 J11.924 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X175.329 Y130.962 E.04447
G2 X173.289 Y131.007 I-.675 J15.57 E.06564
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I35.843 J2.566 E.1226
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
M204 S10000
G1 X198.064 Y177.66 F30000
G1 F8843.478
M204 S4000
G1 X199.012 Y176.336 E.05236
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.532 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-23.082 J15.521 E.17561
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.952 J6.822 E.05235
; WIPE_START
G1 X181.329 Y153.671 E-.61792
G1 X181.594 Y153.406 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X173.978 Y152.902 Z1.6 F30000
G1 X169.922 Y152.633 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X168.671 Y153.671 I5.571 J7.99 E.05235
M73 P65 R12
G1 X154.459 Y139.459 E.64629
G2 X150.988 Y143.664 I22.867 J22.414 E.17554
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.532 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.341 J-18.211 E.17554
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.952 J-6.822 E.05235
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X157.34 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y184.012 E.05236
G1 X173.806 Y168.87 E.6886
G2 X176.194 Y168.87 I1.194 J-11.532 E.07693
G1 X191.336 Y184.012 E.6886
G2 X195.541 Y180.541 I-18.21 J-26.34 E.17554
G1 X181.329 Y166.329 E.64629
G3 X180.078 Y167.367 I-6.822 J-6.952 E.05235
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.929 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.938 J-12.287 E.05239
; WIPE_START
G1 X169.508 Y188.52 E-.61863
G1 X169.771 Y188.257 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X169.521 Y180.628 Z1.6 F30000
M73 P65 R11
G1 X167.92 Y131.838 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X169.508 Y131.48 I3.526 J11.926 E.05239
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.287 J-1.938 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 1.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X203.52 Y165.492 E-.61863
G1 X203.257 Y165.229 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 7/30
; update layer progress
M73 L7
M991 S0 P6 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z1.6 I-.07 J-1.215 P1  F30000
G1 X170.209 Y167.144 Z1.6
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.819 E.01763
G3 X174.57 Y151.412 I5.242 J-6.819 E.67348
G3 X177.765 Y151.854 I.446 J8.533 E.10434
G3 X170.261 Y167.172 I-2.756 J8.147 E.94033
; COOLING_NODE: 0
M204 S250
G1 X170.437 Y166.825 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.007 Y166.507 E.01594
G3 X174.583 Y151.804 I5.001 J-6.507 E.59516
G3 X177.639 Y152.226 I.432 J8.146 E.09244
G3 X170.487 Y166.849 I-2.631 J7.774 E.83089
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.007 Y166.507 E-.22379
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20413
G1 X168.964 Y165.56 E-.12794
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.388 Y161.687 Z1.8 F30000
G1 X146.604 Y152.391 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06186
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X155.93 Y137.64 E.01305
G1 X157.104 Y136.677 E.04882
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06185
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.405 Y130.616 E.01304
G1 X176.923 Y130.665 E.04882
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06186
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06185
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.837 Y169.45 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06186
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.55 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06186
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06185
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.225 Y152.29 E.00002
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05807
G1 X155.358 Y137.603 E.05806
G1 X155.682 Y137.337 E.01247
G1 X156.865 Y136.366 E.0456
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.418 Y130.224 E.01246
G1 X176.948 Y130.274 E.0456
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05807
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05806
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05807
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05807
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05806
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05807
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.211 Y152.349 E.05626
; WIPE_START
M204 S4000
G1 X146.225 Y152.29 E-.02302
G1 X146.788 Y150.434 E-.73698
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.058 Z1.8 F30000
G1 X147.687 Y169.854 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X167.633 Y165.078 F30000
G1 F8843.478
M204 S4000
G2 X168.671 Y166.329 I7.99 J-5.57 E.05235
G1 X154.459 Y180.541 E.64629
G3 X150.988 Y176.336 I22.871 J-22.417 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G3 X154.459 Y139.459 I26.342 J18.212 E.17554
G1 X168.671 Y153.671 E.64629
G3 X169.922 Y152.633 I6.822 J6.952 E.05235
; WIPE_START
G1 X168.671 Y153.671 E-.61792
G1 X168.406 Y153.406 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X175.994 Y154.23 Z1.8 F30000
G1 X182.367 Y154.922 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y153.671 I-7.99 J5.57 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.871 J22.416 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.874 Y161.168 I-9.421 J1.198 E.07616
G1 X199.012 Y176.336 E.68909
G1 X198.064 Y177.66 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.929 J-3.526 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I1.938 J12.284 E.05239
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J11.093 E.07694
G1 X158.664 Y135.988 E.6886
G1 X157.34 Y136.936 E.05236
; WIPE_START
G1 X158.664 Y135.988 E-.61876
G1 X158.927 Y136.251 E-.14125
; WIPE_END
G1 E-.03999 F1800
M204 S10000
G1 X163.217 Y142.563 Z1.8 F30000
G1 X180.078 Y167.367 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y166.329 I-5.57 J-7.99 E.05235
G1 X195.541 Y180.541 E.64629
G3 X191.336 Y184.012 I-22.414 J-22.867 E.17554
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X167.92 Y188.162 F30000
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.526 J-11.929 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.287 J1.938 E.05239
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G2 X146.007 Y158.289 I35.37 J6.347 E.1226
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J29.112 E.11008
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.937 J12.282 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 1.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X180.492 Y131.48 E-.61863
G1 X180.229 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 8/30
; update layer progress
M73 L8
M991 S0 P7 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z1.8 I-1.171 J-.331 P1  F30000
G1 X170.209 Y167.144 Z1.8
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.82 E.01764
G3 X174.588 Y151.411 I5.241 J-6.819 E.67406
G3 X178.292 Y152.052 I.401 J8.704 E.12184
G3 X170.261 Y167.173 I-3.284 J7.949 E.92218
; COOLING_NODE: 0
M204 S250
G1 X170.437 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
M73 P66 R11
G1 F3600
M204 S2000
G1 X170.007 Y166.507 E.01595
G3 X174.601 Y151.803 I5.002 J-6.507 E.59562
G3 X177.639 Y152.226 I.416 J8.141 E.09192
G3 X170.486 Y166.849 I-2.63 J7.774 E.83094
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.007 Y166.507 E-.22366
G1 X169.587 Y166.173 E-.20414
G1 X169.195 Y165.805 E-.20413
G1 X168.964 Y165.559 E-.12807
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.387 Y161.686 Z2 F30000
G1 X146.604 Y152.391 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.471 Y130.618 E.01515
G1 X176.923 Y130.665 E.04671
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.289 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05805
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X155.732 Y137.296 E.01442
G1 X156.865 Y136.366 E.04366
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.484 Y130.226 E.01441
G1 X176.948 Y130.274 E.04365
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.212 Y152.348 E.05629
; WIPE_START
M204 S4000
G1 X146.789 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.885 Y143.993 Z2 F30000
G1 X151.936 Y142.34 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X150.988 Y143.664 E.05236
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.531 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.342 J-18.212 E.17554
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.952 J-6.822 E.05235
; WIPE_START
G1 X168.671 Y166.329 E-.61792
G1 X168.406 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X175.994 Y165.77 Z2 F30000
G1 X182.367 Y165.078 Z2
G1 Z1.6
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X181.329 Y166.329 I-15.038 J-11.416 E.05231
G1 X195.541 Y180.541 E.64629
G2 X199.012 Y176.336 I-22.87 J-22.416 E.17554
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.531 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-23.082 J15.521 E.17561
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.952 J6.822 E.05235
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J11.034 E.07694
G1 X158.664 Y135.988 E.6886
G2 X154.459 Y139.459 I15.521 J23.083 E.17561
G1 X168.671 Y153.671 E.64629
G2 X167.633 Y154.922 I6.955 J6.824 E.05235
M204 S10000
G1 X167.92 Y131.838 F30000
G1 F8843.478
M204 S4000
G3 X169.508 Y131.48 I3.526 J11.926 E.05239
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.287 J-1.938 E.05239
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.929 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.938 J-12.287 E.05239
M204 S10000
G1 X192.66 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y184.012 E.05236
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X182.08 Y131.838 F30000
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.525 J11.924 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X175.459 Y130.966 E.04026
G2 X173.289 Y131.007 I-.773 J16.568 E.06984
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I35.843 J2.566 E.1226
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
; CHANGE_LAYER
; Z_HEIGHT: 1.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X186.894 Y186.486 E-.14097
G1 X188.046 Y185.334 E-.61903
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 9/30
; update layer progress
M73 L9
M991 S0 P8 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z2 I.869 J-.852 P1  F30000
G1 X170.209 Y167.144 Z2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.819 E.01764
G3 X174.605 Y151.411 I5.242 J-6.818 E.67457
G3 X178.292 Y152.052 I.385 J8.699 E.12128
G3 X170.261 Y167.172 I-3.283 J7.949 E.9222
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.007 Y166.508 E.01595
G3 X174.618 Y151.802 I5.003 J-6.507 E.59615
G3 X177.639 Y152.226 I.4 J8.136 E.0914
G3 X170.487 Y166.85 I-2.629 J7.775 E.83104
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.007 Y166.508 E-.22413
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20413
G1 X168.965 Y165.56 E-.12759
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.388 Y161.687 Z2.2 F30000
G1 X146.604 Y152.391 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X156.032 Y137.557 E.01725
G1 X157.104 Y136.677 E.04461
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06185
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.536 Y130.62 E.01725
G1 X176.923 Y130.665 E.04461
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06185
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.837 Y169.45 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.55 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06185
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.289 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05805
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X155.783 Y137.254 E.01637
G1 X156.865 Y136.366 E.04171
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.549 Y130.228 E.01636
G1 X176.948 Y130.274 E.0417
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05806
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05807
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05806
G1 X165.424 Y188.209 E.05806
M73 P67 R11
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X152.254 Y179.217 E.01637
G1 X151.366 Y178.135 E.04171
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.212 Y152.348 E.05629
; WIPE_START
M204 S4000
G1 X146.789 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.057 Z2.2 F30000
G1 X147.687 Y169.854 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X167.633 Y165.078 F30000
G1 F8843.478
M204 S4000
G2 X168.671 Y166.329 I7.99 J-5.57 E.05235
G1 X154.459 Y180.541 E.64629
G3 X150.988 Y176.336 I22.871 J-22.417 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G3 X154.459 Y139.459 I23.082 J15.52 E.17561
G1 X168.671 Y153.671 E.64629
G2 X167.633 Y154.922 I6.952 J6.822 E.05235
; WIPE_START
G1 X168.671 Y153.671 E-.61792
G1 X168.406 Y153.406 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X175.994 Y154.23 Z2.2 F30000
G1 X182.367 Y154.922 Z2.2
G1 Z1.8
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y153.671 I-7.99 J5.57 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.869 J22.415 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.874 Y161.168 I-9.421 J1.198 E.07616
G1 X199.012 Y176.336 E.68909
G1 X198.064 Y177.66 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.932 J-3.527 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I1.938 J12.284 E.05239
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J10.974 E.07694
G1 X158.664 Y135.988 E.6886
G1 X157.34 Y136.936 E.05236
; WIPE_START
G1 X158.664 Y135.988 E-.61876
G1 X158.927 Y136.251 E-.14124
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X163.742 Y142.172 Z2.2 F30000
G1 X182.367 Y165.078 Z2.2
G1 Z1.8
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X181.329 Y166.329 I-7.99 J-5.57 E.05235
G1 X195.541 Y180.541 E.64629
G3 X191.336 Y184.012 I-22.413 J-22.867 E.17554
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X167.92 Y188.162 F30000
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.527 J-11.932 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.287 J1.938 E.05239
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G2 X146.007 Y158.289 I35.37 J6.347 E.1226
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J30.106 E.11008
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.938 J12.284 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X180.492 Y131.48 E-.61863
G1 X180.229 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 10/30
; update layer progress
M73 L10
M991 S0 P9 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z2.2 I-1.171 J-.331 P1  F30000
G1 X170.209 Y167.144 Z2.2
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.819 E.01764
G3 X174.623 Y151.41 I5.242 J-6.818 E.67511
G3 X178.292 Y152.052 I.368 J8.696 E.12072
G3 X170.261 Y167.172 I-3.283 J7.949 E.92225
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.509 E.01596
G3 X174.636 Y151.802 I5.003 J-6.507 E.59673
G3 X178.142 Y152.415 I.356 J8.3 E.10685
G3 X170.487 Y166.852 I-3.133 J7.587 E.81498
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.509 E-.22458
G1 X169.587 Y166.173 E-.20416
G1 X169.195 Y165.805 E-.20413
G1 X168.966 Y165.561 E-.12713
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.389 Y161.688 Z2.4 F30000
G1 X146.604 Y152.391 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.602 Y130.622 E.01936
G1 X176.923 Y130.665 E.0425
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06186
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.225 Y152.29 E.00001
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.614 Y130.23 E.01831
G1 X176.948 Y130.274 E.03975
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05807
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.211 Y152.349 E.05626
; WIPE_START
M204 S4000
G1 X146.225 Y152.29 E-.02298
G1 X146.788 Y150.434 E-.73702
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X151.489 Y144.421 Z2.4 F30000
G1 X157.34 Y136.936 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X158.664 Y135.988 E.05236
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J10.911 E.07695
G1 X191.336 Y135.988 E.6886
G1 X192.66 Y136.936 E.05236
M204 S10000
G1 X182.08 Y131.838 F30000
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.527 J11.931 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X175.59 Y130.97 E.03605
G2 X173.289 Y131.007 I-.871 J17.559 E.07405
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I35.846 J2.566 E.1226
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
M204 S10000
M73 P68 R11
G1 X198.064 Y177.66 F30000
G1 F8843.478
M204 S4000
G1 X199.012 Y176.336 E.05236
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.532 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-23.08 J15.519 E.17561
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.952 J6.822 E.05235
; WIPE_START
G1 X181.329 Y153.671 E-.61792
G1 X181.594 Y153.406 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X174.006 Y154.23 Z2.4 F30000
G1 X167.633 Y154.922 Z2.4
G1 Z2
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X168.671 Y153.671 I15.036 J11.414 E.05231
G1 X154.459 Y139.459 E.64629
G2 X150.988 Y143.664 I22.872 J22.418 E.17554
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.532 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.345 J-18.214 E.17554
M73 P68 R10
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.952 J-6.822 E.05235
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X157.34 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y184.012 E.05236
G1 X173.806 Y168.87 E.6886
G2 X176.194 Y168.87 I1.194 J-11.531 E.07693
G1 X191.336 Y184.012 E.6886
G2 X195.541 Y180.541 I-18.211 J-26.34 E.17554
G1 X181.329 Y166.329 E.64629
G3 X180.078 Y167.367 I-6.822 J-6.952 E.05235
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.929 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.939 J-12.289 E.05239
; WIPE_START
G1 X169.508 Y188.52 E-.61863
G1 X169.771 Y188.257 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X169.521 Y180.628 Z2.4 F30000
G1 X167.92 Y131.838 Z2.4
G1 Z2
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X169.508 Y131.48 I3.526 J11.926 E.05239
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.289 J-1.939 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 2.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X203.52 Y165.492 E-.61863
G1 X203.257 Y165.229 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 11/30
; update layer progress
M73 L11
M991 S0 P10 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z2.4 I-.07 J-1.215 P1  F30000
G1 X170.209 Y167.144 Z2.4
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.768 Y166.818 E.01764
G3 X174.64 Y151.409 I5.241 J-6.818 E.67564
G3 X178.805 Y152.285 I.376 J8.554 E.13829
G3 X170.262 Y167.171 I-3.796 J7.716 E.90398
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.508 E.01596
G3 X174.653 Y151.801 I5.003 J-6.507 E.59721
G3 X178.142 Y152.415 I.339 J8.297 E.10633
G3 X170.487 Y166.851 I-3.133 J7.587 E.815
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.508 E-.22447
G1 X169.587 Y166.173 E-.20416
G1 X169.195 Y165.805 E-.20413
G1 X168.966 Y165.561 E-.12724
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.389 Y161.688 Z2.6 F30000
G1 X146.604 Y152.391 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X156.133 Y137.474 E.02146
G1 X157.104 Y136.677 E.0404
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06185
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.667 Y130.624 E.02146
G1 X176.923 Y130.665 E.0404
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06185
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06185
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06185
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.225 Y152.29 E.00001
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X151.798 Y141.339 E.02027
G1 X152.603 Y140.358 E.03781
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X155.884 Y137.171 E.02026
G1 X156.865 Y136.366 E.03781
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.68 Y130.232 E.02026
G1 X176.948 Y130.274 E.03781
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X197.829 Y140.884 E.02026
G1 X198.634 Y141.865 E.03781
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X152.171 Y179.116 E.02026
G1 X151.366 Y178.135 E.03781
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.211 Y152.349 E.05627
; WIPE_START
M204 S4000
G1 X146.225 Y152.29 E-.02296
G1 X146.788 Y150.434 E-.73704
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.058 Z2.6 F30000
G1 X147.687 Y169.854 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X151.936 Y177.66 F30000
G1 F8843.478
M204 S4000
G1 X150.988 Y176.336 E.05236
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G3 X154.459 Y139.459 I26.344 J18.213 E.17554
G1 X168.671 Y153.671 E.64629
G3 X169.922 Y152.633 I6.822 J6.952 E.05235
; WIPE_START
G1 X168.671 Y153.671 E-.61792
G1 X168.406 Y153.406 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X173.302 Y159.262 Z2.6 F30000
G1 X180.078 Y167.367 Z2.6
G1 Z2.2
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y166.329 I-5.57 J-7.99 E.05235
G1 X195.541 Y180.541 E.64629
G3 X191.336 Y184.012 I-22.415 J-22.869 E.17554
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G3 X154.459 Y180.541 I15.522 J-23.084 E.17561
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.952 J-6.822 E.05235
M204 S10000
G1 X167.92 Y188.162 F30000
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.526 J-11.929 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.285 J1.938 E.05239
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.929 J-3.526 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I1.937 J12.282 E.05239
M204 S10000
G1 X157.34 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y135.988 E.05236
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J10.848 E.07695
G1 X191.336 Y135.988 E.6886
G3 X195.541 Y139.459 I-18.213 J26.343 E.17554
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.952 J6.822 E.05235
M204 S10000
G1 X198.064 Y177.66 F30000
G1 F8843.478
M204 S4000
G1 X199.012 Y176.336 E.05236
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.531 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G1 X198.064 Y142.34 E.05236
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G2 X146.007 Y158.289 I35.37 J6.347 E.1226
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J31.104 E.11007
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.937 J12.282 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 2.4
; LAYER_HEIGHT: 0.2
; WIPE_START
M73 P69 R10
G1 F8843.478
G1 X180.492 Y131.48 E-.61863
G1 X180.229 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 12/30
; update layer progress
M73 L12
M991 S0 P11 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z2.6 I-1.171 J-.331 P1  F30000
G1 X170.209 Y167.145 Z2.6
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.82 E.01765
G3 X174.658 Y151.409 I5.242 J-6.818 E.67625
G3 X178.805 Y152.285 I.36 J8.553 E.13773
G3 X170.262 Y167.173 I-3.796 J7.717 E.90409
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.508 E.01597
G3 X174.67 Y151.801 I5.003 J-6.507 E.5977
G3 X178.142 Y152.415 I.322 J8.295 E.10581
G3 X170.487 Y166.851 I-3.132 J7.587 E.81502
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.508 E-.22442
G1 X169.587 Y166.173 E-.20408
G1 X169.195 Y165.805 E-.20416
G1 X168.966 Y165.561 E-.12733
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.389 Y161.688 Z2.8 F30000
G1 X146.604 Y152.391 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.732 Y130.626 E.02357
G1 X176.923 Y130.665 E.0383
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.225 Y152.29 E.00001
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.745 Y130.234 E.02221
G1 X176.948 Y130.274 E.03586
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.211 Y152.349 E.05627
; WIPE_START
M204 S4000
G1 X146.225 Y152.29 E-.02294
G1 X146.788 Y150.434 E-.73706
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X151.489 Y144.421 Z2.8 F30000
G1 X157.34 Y136.936 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X158.664 Y135.988 E.05236
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J10.787 E.07695
G1 X191.336 Y135.988 E.6886
G1 X192.66 Y136.936 E.05236
M204 S10000
G1 X182.08 Y131.838 F30000
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.525 J11.924 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X175.721 Y130.974 E.03184
G2 X173.289 Y131.007 I-.969 J18.557 E.07826
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I35.843 J2.566 E.1226
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
M204 S10000
G1 X192.66 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y184.012 E.05236
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X167.633 Y154.922 F30000
G1 F8843.478
M204 S4000
G3 X168.671 Y153.671 I15.04 J11.418 E.05231
G1 X154.459 Y139.459 E.64629
G2 X150.988 Y143.664 I22.871 J22.417 E.17554
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.531 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.345 J-18.214 E.17554
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.949 J-6.82 E.05235
; WIPE_START
G1 X168.671 Y166.329 E-.61792
G1 X168.406 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X175.994 Y165.77 Z2.8 F30000
G1 X182.367 Y165.078 Z2.8
G1 Z2.4
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X181.329 Y166.329 I-15.04 J-11.418 E.05231
G1 X195.541 Y180.541 E.64629
G2 X199.012 Y176.336 I-22.87 J-22.416 E.17554
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.531 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-26.345 J18.214 E.17554
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.949 J6.82 E.05235
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.927 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.938 J-12.287 E.05239
; WIPE_START
G1 X169.508 Y188.52 E-.61863
G1 X169.771 Y188.257 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X169.521 Y180.628 Z2.8 F30000
G1 X167.92 Y131.838 Z2.8
G1 Z2.4
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X169.508 Y131.48 I3.525 J11.924 E.05239
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.287 J-1.938 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 2.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X203.52 Y165.492 E-.61863
G1 X203.257 Y165.229 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 13/30
; update layer progress
M73 L13
M991 S0 P12 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z2.8 I-.07 J-1.215 P1  F30000
G1 X170.21 Y167.145 Z2.8
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.82 E.01765
G3 X174.675 Y151.408 I5.242 J-6.818 E.67679
G3 X178.805 Y152.285 I.343 J8.553 E.13717
G3 X170.262 Y167.173 I-3.796 J7.717 E.9041
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.007 Y166.507 E.01597
G3 X174.688 Y151.8 I5.002 J-6.506 E.59821
G3 X178.631 Y152.637 I.329 J8.162 E.12132
G3 X170.487 Y166.849 I-3.622 J7.364 E.79889
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.007 Y166.507 E-.22396
G1 X169.587 Y166.173 E-.20408
G1 X169.195 Y165.805 E-.20416
G1 X168.965 Y165.56 E-.12781
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.388 Y161.687 Z3 F30000
G1 X146.604 Y152.391 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.798 Y130.628 E.02567
G1 X176.923 Y130.665 E.03619
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.225 Y152.29 E.00001
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X151.881 Y141.238 E.02416
G1 X152.603 Y140.358 E.03391
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.811 Y130.237 E.02416
G1 X176.948 Y130.274 E.03391
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
M73 P70 R10
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.211 Y152.349 E.05627
; WIPE_START
M204 S4000
G1 X146.225 Y152.29 E-.02292
G1 X146.788 Y150.434 E-.73708
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.058 Z3 F30000
G1 X147.687 Y169.854 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X167.633 Y165.078 F30000
G1 F8843.478
M204 S4000
G2 X168.671 Y166.329 I7.99 J-5.571 E.05235
G1 X154.459 Y180.541 E.64629
G3 X150.988 Y176.336 I22.873 J-22.419 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G3 X154.459 Y139.459 I26.344 J18.213 E.17554
G1 X168.671 Y153.671 E.64629
G2 X167.633 Y154.922 I6.953 J6.823 E.05235
; WIPE_START
G1 X168.671 Y153.671 E-.61792
G1 X168.406 Y153.406 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X175.994 Y154.23 Z3 F30000
G1 X182.367 Y154.922 Z3
G1 Z2.6
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y153.671 I-7.99 J5.571 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.873 J22.419 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.874 Y161.168 I-9.421 J1.198 E.07616
G1 X199.012 Y176.336 E.68909
G1 X198.064 Y177.66 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.929 J-3.526 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I1.937 J12.282 E.05239
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J10.722 E.07695
G1 X158.664 Y135.988 E.6886
G1 X157.34 Y136.936 E.05236
; WIPE_START
G1 X158.664 Y135.988 E-.61876
G1 X158.927 Y136.251 E-.14125
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X163.742 Y142.172 Z3 F30000
G1 X182.367 Y165.078 Z3
G1 Z2.6
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X181.329 Y166.329 I-15.04 J-11.418 E.05231
G1 X195.541 Y180.541 E.64629
G3 X191.336 Y184.012 I-22.415 J-22.869 E.17554
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X167.92 Y188.162 F30000
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.526 J-11.929 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.285 J1.938 E.05239
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G2 X146.007 Y158.289 I35.37 J6.347 E.1226
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J32.103 E.11007
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.937 J12.282 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 2.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X180.492 Y131.48 E-.61863
G1 X180.229 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 14/30
; update layer progress
M73 L14
M991 S0 P13 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z3 I-1.171 J-.331 P1  F30000
G1 X170.21 Y167.145 Z3
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.819 E.01766
G3 X174.693 Y151.408 I5.242 J-6.818 E.67733
G3 X178.805 Y152.285 I.326 J8.552 E.13661
G3 X170.262 Y167.173 I-3.796 J7.717 E.9041
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.509 E.01597
G3 X174.705 Y151.8 I5.003 J-6.507 E.59877
G3 X178.631 Y152.637 I.312 J8.162 E.1208
G3 X170.487 Y166.852 I-3.622 J7.365 E.79895
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.509 E-.2246
G1 X169.587 Y166.173 E-.20409
G1 X169.195 Y165.805 E-.20416
G1 X168.966 Y165.561 E-.12715
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.389 Y161.688 Z3.2 F30000
G1 X146.604 Y152.391 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X156.284 Y137.35 E.02778
G1 X157.104 Y136.677 E.03409
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.863 Y130.631 E.02777
G1 X176.923 Y130.665 E.03409
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05805
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X151.922 Y141.187 E.02611
G1 X152.603 Y140.358 E.03196
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.036 Y137.047 E.02611
G1 X156.865 Y136.366 E.03196
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.876 Y130.239 E.02611
G1 X176.948 Y130.274 E.03196
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X197.953 Y141.036 E.02611
G1 X198.634 Y141.865 E.03196
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X152.047 Y178.964 E.02611
G1 X151.366 Y178.135 E.03196
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.212 Y152.348 E.05629
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.885 Y143.993 Z3.2 F30000
G1 X151.936 Y142.34 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X150.988 Y143.664 E.05236
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.532 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.342 J-18.212 E.17554
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.948 J-6.819 E.05235
; WIPE_START
G1 X168.671 Y166.329 E-.61792
G1 X168.406 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X176.022 Y167.098 Z3.2 F30000
G1 X180.078 Y167.367 Z3.2
G1 Z2.8
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y166.329 I-5.567 J-7.986 E.05235
G1 X195.541 Y180.541 E.64629
G2 X199.012 Y176.336 I-22.87 J-22.416 E.17554
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.532 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-23.082 J15.521 E.17561
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.948 J6.819 E.05235
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J10.66 E.07695
G1 X158.664 Y135.988 E.6886
G2 X154.459 Y139.459 I18.212 J26.343 E.17554
G1 X168.671 Y153.671 E.64629
G3 X169.922 Y152.633 I6.819 J6.948 E.05235
M204 S10000
M73 P70 R9
G1 X167.92 Y131.838 F30000
G1 F8843.478
M204 S4000
M73 P71 R9
G3 X169.508 Y131.48 I3.525 J11.925 E.05239
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.287 J-1.938 E.05239
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.927 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.938 J-12.287 E.05239
M204 S10000
G1 X192.66 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y184.012 E.05236
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X182.08 Y131.838 F30000
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.525 J11.924 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X175.852 Y130.979 E.02763
G2 X173.289 Y131.007 I-1.067 J19.554 E.08246
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I35.843 J2.566 E.1226
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
; CHANGE_LAYER
; Z_HEIGHT: 3
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X186.894 Y186.486 E-.14097
G1 X188.046 Y185.334 E-.61903
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 15/30
; update layer progress
M73 L15
M991 S0 P14 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z3.2 I.869 J-.852 P1  F30000
G1 X170.21 Y167.145 Z3.2
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.819 E.01766
G3 X174.71 Y151.407 I5.242 J-6.818 E.67789
G3 X178.805 Y152.285 I.308 J8.552 E.13604
G3 X170.262 Y167.173 I-3.795 J7.717 E.9041
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.509 E.01597
G3 X174.723 Y151.799 I5.003 J-6.507 E.59929
G3 X178.631 Y152.637 I.295 J8.162 E.12028
G3 X170.487 Y166.852 I-3.622 J7.365 E.79896
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.509 E-.22458
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20413
G1 X168.966 Y165.561 E-.12714
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.389 Y161.688 Z3.4 F30000
G1 X146.604 Y152.391 Z3.4
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.929 Y130.633 E.02988
G1 X176.923 Y130.665 E.03198
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.167 Y154.265 E.06187
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05805
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X151.964 Y141.137 E.02806
G1 X152.603 Y140.358 E.03001
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.086 Y137.005 E.02806
G1 X156.865 Y136.366 E.03001
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X175.941 Y130.241 E.02806
G1 X176.948 Y130.274 E.03001
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.783 Y154.188 E.05807
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.057 Z3.4 F30000
G1 X147.687 Y169.854 Z3.4
G1 Z3
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X157.34 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y184.012 E.05236
G1 X173.806 Y168.87 E.6886
G2 X176.194 Y168.87 I1.194 J-11.531 E.07693
G1 X191.336 Y184.012 E.6886
G1 X192.66 Y183.064 E.05236
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G2 X146.007 Y158.289 I35.37 J6.347 E.1226
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J33.109 E.11007
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.937 J12.282 E.05239
M204 S10000
G1 X182.367 Y154.922 F30000
G1 F8843.478
M204 S4000
G2 X181.329 Y153.671 I-7.992 J5.572 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.873 J22.419 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.874 Y161.168 I-9.421 J1.198 E.07616
G1 X199.012 Y176.336 E.68909
G3 X195.541 Y180.541 I-26.341 J-18.211 E.17554
G1 X181.329 Y166.329 E.64629
G2 X182.367 Y165.078 I-6.955 J-6.825 E.05235
; WIPE_START
G1 X181.329 Y166.329 E-.61788
G1 X181.594 Y166.594 E-.14212
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X174.006 Y165.77 Z3.4 F30000
G1 X167.633 Y165.078 Z3.4
G1 Z3
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X168.671 Y166.329 I7.992 J-5.572 E.05235
G1 X154.459 Y180.541 E.64629
G3 X150.988 Y176.336 I22.873 J-22.419 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G1 X151.936 Y142.34 E.05236
M204 S10000
G1 X167.633 Y154.922 F30000
G1 F8843.478
M204 S4000
G3 X168.671 Y153.671 I15.04 J11.418 E.05231
G1 X154.459 Y139.459 E.64629
G3 X158.664 Y135.988 I22.417 J22.872 E.17554
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J9.205 E.07701
G1 X191.336 Y135.988 E.6886
M73 P72 R9
G1 X192.66 Y136.936 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.929 J-3.526 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I1.937 J12.282 E.05239
; WIPE_START
G1 X169.508 Y131.48 E-.61863
G1 X169.771 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X169.521 Y139.371 Z3.4 F30000
G1 X167.92 Y188.162 Z3.4
G1 Z3
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.526 J-11.929 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.285 J1.938 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 3.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X203.52 Y154.508 E-.61863
G1 X203.257 Y154.771 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 16/30
; update layer progress
M73 L16
M991 S0 P15 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z3.4 I-.427 J-1.14 P1  F30000
G1 X170.21 Y167.145 Z3.4
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.82 E.01767
G3 X174.727 Y151.407 I5.242 J-6.818 E.67847
G3 X178.805 Y152.285 I.291 J8.552 E.13548
G3 X170.262 Y167.173 I-3.795 J7.717 E.90413
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.509 E.01598
G3 X174.74 Y151.798 I5.003 J-6.507 E.59981
G3 X178.631 Y152.637 I.278 J8.162 E.11976
G3 X170.487 Y166.852 I-3.622 J7.365 E.79896
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.509 E-.22454
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20413
G1 X168.966 Y165.561 E-.12718
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.389 Y161.688 Z3.6 F30000
G1 X146.604 Y152.391 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X168.36 Y131.378 E.03199
G1 X169.265 Y131.167 E.02988
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X175.994 Y130.635 E.03198
G1 X176.923 Y130.665 E.02988
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.378 Y166.64 E.03199
G1 X146.167 Y165.735 E.02988
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.016 Y155.182 E.03199
G1 X146.167 Y154.265 E.02988
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X168.271 Y130.996 E.03001
G1 X169.188 Y130.783 E.02806
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.007 Y130.243 E.03001
G1 X176.948 Y130.274 E.02806
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.996 Y166.729 E.03001
G1 X145.783 Y165.812 E.02806
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.629 Y155.118 E.03001
G1 X145.783 Y154.188 E.02806
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.885 Y143.993 Z3.6 F30000
G1 X151.936 Y142.34 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X150.988 Y143.664 E.05236
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.531 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.345 J-18.214 E.17554
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.95 J-6.821 E.05235
; WIPE_START
G1 X168.671 Y166.329 E-.61792
G1 X168.406 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X176.022 Y167.098 Z3.6 F30000
G1 X180.078 Y167.367 Z3.6
G1 Z3.2
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y166.329 I-5.569 J-7.988 E.05235
G1 X195.541 Y180.541 E.64629
G2 X199.012 Y176.336 I-22.87 J-22.416 E.17554
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.531 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-26.345 J18.214 E.17554
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.95 J6.821 E.05235
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J9.187 E.07701
G1 X158.664 Y135.988 E.6886
G2 X154.459 Y139.459 I18.211 J26.341 E.17554
G1 X168.671 Y153.671 E.64629
G3 X169.922 Y152.633 I6.821 J6.95 E.05235
M204 S10000
G1 X167.92 Y131.838 F30000
G1 F8843.478
M204 S4000
G1 X168.439 Y131.717 E.01714
G3 X169.508 Y131.48 I2.343 J8.03 E.03523
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.287 J-1.938 E.05239
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.927 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.938 J-12.287 E.05239
M204 S10000
G1 X192.66 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y184.012 E.05236
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X182.08 Y131.838 F30000
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.525 J11.924 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X175.983 Y130.983 E.02342
G2 X173.289 Y131.007 I-1.165 J20.547 E.08667
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I39.151 J2.98 E.12259
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
; CHANGE_LAYER
; Z_HEIGHT: 3.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X186.894 Y186.486 E-.14097
G1 X188.046 Y185.334 E-.61903
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 17/30
; update layer progress
M73 L17
M991 S0 P16 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z3.6 I.869 J-.852 P1  F30000
G1 X170.21 Y167.145 Z3.6
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.819 E.01767
G3 X174.745 Y151.406 I5.242 J-6.818 E.67901
G3 X178.805 Y152.285 I.274 J8.553 E.13492
G3 X170.262 Y167.173 I-3.795 J7.717 E.90409
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.509 E.01598
G3 X174.758 Y151.798 I5.003 J-6.507 E.60033
G3 X178.631 Y152.637 I.26 J8.163 E.11924
G3 X170.487 Y166.852 I-3.622 J7.365 E.79896
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.509 E-.22458
G1 X169.587 Y166.173 E-.20416
G1 X169.195 Y165.805 E-.20413
G1 X168.966 Y165.561 E-.12714
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.389 Y161.688 Z3.8 F30000
G1 X146.604 Y152.391 Z3.8
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X168.424 Y131.363 E.03409
G1 X169.265 Y131.167 E.02777
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.059 Y130.637 E.03409
G1 X176.923 Y130.665 E.02777
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.363 Y166.576 E.03409
G1 X146.167 Y165.735 E.02777
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.027 Y155.117 E.03409
G1 X146.167 Y154.265 E.02777
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
M73 P73 R9
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X168.335 Y130.982 E.03196
G1 X169.188 Y130.783 E.02611
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.072 Y130.245 E.03196
G1 X176.948 Y130.274 E.02611
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.982 Y166.665 E.03196
G1 X145.783 Y165.812 E.02611
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.64 Y155.053 E.03196
G1 X145.783 Y154.188 E.02611
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.057 Z3.8 F30000
G1 X147.687 Y169.854 Z3.8
G1 Z3.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X157.34 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y184.012 E.05236
G1 X173.806 Y168.87 E.6886
G2 X176.194 Y168.87 I1.194 J-11.531 E.07693
G1 X191.336 Y184.012 E.6886
G1 X192.66 Y183.064 E.05236
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G1 X146.37 Y155.174 E.0217
G2 X146.007 Y158.289 I34.265 J5.575 E.1009
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J34.108 E.11006
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.937 J12.282 E.05239
M204 S10000
G1 X180.078 Y152.633 F30000
G1 F8843.478
M204 S4000
G3 X181.329 Y153.671 I-5.57 J7.99 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.873 J22.419 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.874 Y161.168 I-9.421 J1.198 E.07616
G1 X199.012 Y176.336 E.68909
G3 X195.541 Y180.541 I-26.341 J-18.211 E.17554
G1 X181.329 Y166.329 E.64629
G2 X182.367 Y165.078 I-6.952 J-6.822 E.05235
; WIPE_START
G1 X181.329 Y166.329 E-.61792
G1 X181.594 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X173.978 Y167.098 Z3.8 F30000
G1 X169.922 Y167.367 Z3.8
G1 Z3.4
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X168.671 Y166.329 I5.57 J-7.99 E.05235
G1 X154.459 Y180.541 E.64629
G3 X150.988 Y176.336 I22.873 J-22.419 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G1 X151.936 Y142.34 E.05236
M204 S10000
G1 X167.633 Y154.922 F30000
G1 F8843.478
M204 S4000
G3 X168.671 Y153.671 I7.99 J5.57 E.05235
G1 X154.459 Y139.459 E.64629
G3 X158.664 Y135.988 I22.417 J22.871 E.17554
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J11.499 E.07693
G1 X191.336 Y135.988 E.6886
G1 X192.66 Y136.936 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.929 J-3.526 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I8.503 J41.378 E.05235
; WIPE_START
G1 X169.508 Y131.48 E-.61863
G1 X169.771 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X169.521 Y139.371 Z3.8 F30000
G1 X167.92 Y188.162 Z3.8
G1 Z3.4
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.526 J-11.929 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.285 J1.938 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 3.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X203.52 Y154.508 E-.61863
G1 X203.257 Y154.771 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 18/30
; update layer progress
M73 L18
M991 S0 P17 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z3.8 I-.427 J-1.14 P1  F30000
G1 X170.21 Y167.145 Z3.8
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.82 E.01767
G3 X174.762 Y151.405 I5.242 J-6.818 E.6796
G3 X178.805 Y152.285 I.256 J8.554 E.13436
G3 X170.262 Y167.174 I-3.796 J7.717 E.90412
; COOLING_NODE: 0
M204 S250
G1 X170.438 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.006 Y166.509 E.01599
G3 X174.775 Y151.797 I5.003 J-6.507 E.60086
G3 X178.631 Y152.637 I.243 J8.163 E.11872
G3 X170.487 Y166.852 I-3.622 J7.365 E.79895
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.006 Y166.509 E-.22458
G1 X169.587 Y166.173 E-.20416
G1 X169.195 Y165.805 E-.20413
G1 X168.966 Y165.561 E-.12714
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.389 Y161.688 Z4 F30000
G1 X146.604 Y152.391 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X168.487 Y131.349 E.03619
G1 X169.265 Y131.167 E.02567
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.125 Y130.639 E.03619
G1 X176.923 Y130.665 E.02567
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.349 Y166.513 E.03619
G1 X146.167 Y165.735 E.02567
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.037 Y155.052 E.0362
G1 X146.167 Y154.265 E.02567
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.225 Y152.29 E0
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X149.802 Y144.138 E.03391
G1 X150.231 Y143.45 E.02416
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.381 Y139.527 E.0339
G1 X153.935 Y138.935 E.02416
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X168.398 Y130.967 E.03391
G1 X169.188 Y130.783 E.02416
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.138 Y130.247 E.03391
G1 X176.948 Y130.274 E.02416
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X190.862 Y134.802 E.03391
G1 X191.55 Y135.231 E.02416
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X200.198 Y175.862 E.03391
G1 X199.769 Y176.55 E.02416
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X159.138 Y185.198 E.03391
G1 X158.45 Y184.769 E.02416
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
M73 P73 R8
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.967 Y166.602 E.03391
G1 X145.783 Y165.812 E.02416
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.65 Y154.989 E.03391
G1 X145.783 Y154.188 E.02416
G1 X146.212 Y152.348 E.05627
; WIPE_START
M204 S4000
G1 X146.225 Y152.29 E-.02284
G1 X146.788 Y150.433 E-.73716
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.885 Y143.993 Z4 F30000
G1 X151.936 Y142.34 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X150.988 Y143.664 E.05236
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.531 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.345 J-18.214 E.17554
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.949 J-6.82 E.05235
; WIPE_START
G1 X168.671 Y166.329 E-.61792
G1 X168.406 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X175.994 Y165.77 Z4 F30000
G1 X182.367 Y165.078 Z4
G1 Z3.6
G1 E.8 F1800
G1 F8843.478
M204 S4000
G3 X181.329 Y166.329 I-7.987 J-5.569 E.05235
G1 X195.541 Y180.541 E.64629
G2 X199.012 Y176.336 I-22.869 J-22.415 E.17554
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.531 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-26.345 J18.214 E.17554
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.949 J6.82 E.05235
M204 S10000
M73 P74 R8
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J11.501 E.07693
G1 X158.664 Y135.988 E.6886
G2 X154.459 Y139.459 I18.213 J26.343 E.17554
G1 X168.671 Y153.671 E.64629
G2 X167.633 Y154.922 I6.949 J6.82 E.05235
M204 S10000
G1 X167.92 Y131.838 F30000
G1 F8843.478
M204 S4000
G1 X168.566 Y131.688 E.02135
G3 X169.508 Y131.48 I2.053 J7.073 E.03102
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.287 J-1.938 E.05239
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.927 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.938 J-12.287 E.05239
M204 S10000
G1 X192.66 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y184.012 E.05236
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X182.08 Y131.838 F30000
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.525 J11.924 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X176.113 Y130.987 E.01921
G2 X173.289 Y131.007 I-1.263 J21.544 E.09088
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I40.811 J3.187 E.12259
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
; CHANGE_LAYER
; Z_HEIGHT: 3.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X186.894 Y186.486 E-.14097
G1 X188.046 Y185.334 E-.61903
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 19/30
; update layer progress
M73 L19
M991 S0 P18 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z4 I.869 J-.852 P1  F30000
G1 X170.21 Y167.145 Z4
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.82 E.01768
G3 X174.78 Y151.405 I5.242 J-6.818 E.68016
G3 X178.805 Y152.285 I.238 J8.555 E.1338
G3 X170.262 Y167.173 I-3.796 J7.717 E.90407
; COOLING_NODE: 0
M204 S250
G1 X170.439 Y166.826 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.007 Y166.507 E.01599
G3 X174.793 Y151.797 I5.002 J-6.507 E.60133
G3 X178.631 Y152.637 I.225 J8.165 E.11821
G3 X170.487 Y166.849 I-3.622 J7.364 E.79889
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.007 Y166.507 E-.22393
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20413
G1 X168.965 Y165.56 E-.1278
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.388 Y161.687 Z4.2 F30000
G1 X146.604 Y152.391 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X168.551 Y131.334 E.0383
G1 X169.265 Y131.167 E.02357
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.19 Y130.641 E.03829
G1 X176.923 Y130.665 E.02357
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.334 Y166.449 E.0383
G1 X146.167 Y165.735 E.02357
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.048 Y154.988 E.0383
G1 X146.167 Y154.265 E.02357
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X168.462 Y130.952 E.03586
G1 X169.188 Y130.783 E.02221
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.203 Y130.249 E.03586
G1 X176.948 Y130.274 E.02221
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.952 Y166.538 E.03586
G1 X145.783 Y165.812 E.02221
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.661 Y154.924 E.03586
G1 X145.783 Y154.188 E.02221
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.057 Z4.2 F30000
G1 X147.687 Y169.854 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X157.34 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y184.012 E.05236
G1 X173.806 Y168.87 E.6886
G2 X176.194 Y168.87 I1.194 J-11.531 E.07693
G1 X191.336 Y184.012 E.6886
G1 X192.66 Y183.064 E.05236
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G1 X146.391 Y155.045 E.01749
G2 X146.007 Y158.289 I34.223 J5.702 E.10511
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J35.107 E.11006
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.937 J12.282 E.05239
M204 S10000
G1 X182.367 Y154.922 F30000
G1 F8843.478
M204 S4000
G2 X181.329 Y153.671 I-7.989 J5.57 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.873 J22.419 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.874 Y161.168 I-9.421 J1.198 E.07616
G1 X199.012 Y176.336 E.68909
G3 X195.541 Y180.541 I-26.341 J-18.211 E.17554
G1 X181.329 Y166.329 E.64629
G3 X180.078 Y167.367 I-6.821 J-6.951 E.05235
; WIPE_START
G1 X181.329 Y166.329 E-.61792
G1 X181.594 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X174.006 Y165.77 Z4.2 F30000
G1 X167.633 Y165.078 Z4.2
G1 Z3.8
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X168.671 Y166.329 I7.989 J-5.57 E.05235
G1 X154.459 Y180.541 E.64629
M73 P75 R8
G3 X150.988 Y176.336 I22.873 J-22.419 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G1 X151.936 Y142.34 E.05236
M204 S10000
G1 X169.922 Y152.633 F30000
G1 F8843.478
M204 S4000
G2 X168.671 Y153.671 I5.57 J7.989 E.05235
G1 X154.459 Y139.459 E.64629
G3 X158.664 Y135.988 I22.416 J22.87 E.17554
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J11.501 E.07693
G1 X191.336 Y135.988 E.6886
G1 X192.66 Y136.936 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.929 J-3.526 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I7.495 J36.913 E.05235
; WIPE_START
G1 X169.508 Y131.48 E-.61863
G1 X169.771 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X169.521 Y139.371 Z4.2 F30000
G1 X167.92 Y188.162 Z4.2
G1 Z3.8
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.526 J-11.929 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.285 J1.938 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X203.52 Y154.508 E-.61863
G1 X203.257 Y154.771 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 20/30
; update layer progress
M73 L20
M991 S0 P19 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z4.2 I-.427 J-1.14 P1  F30000
G1 X170.21 Y167.145 Z4.2
G1 Z4
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X169.767 Y166.82 E.01768
G3 X174.797 Y151.404 I5.242 J-6.818 E.68074
G3 X178.805 Y152.285 I.221 J8.556 E.13324
G3 X170.262 Y167.173 I-3.796 J7.717 E.90406
; COOLING_NODE: 0
M204 S250
G1 X170.442 Y166.821 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G3 X174.81 Y151.796 I4.567 J-6.82 E.61785
G3 X178.142 Y152.415 I.181 J8.308 E.10166
G3 X170.492 Y166.854 I-3.132 J7.587 E.81484
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.002 Y166.514 E-.22685
G1 X169.587 Y166.173 E-.20422
G1 X169.195 Y165.805 E-.20413
G1 X168.97 Y165.566 E-.12481
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.394 Y161.692 Z4.4 F30000
G1 X146.604 Y152.391 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X168.615 Y131.319 E.0404
G1 X169.265 Y131.167 E.02146
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.256 Y130.643 E.0404
G1 X176.923 Y130.665 E.02146
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.319 Y166.385 E.0404
G1 X146.167 Y165.735 E.02146
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.059 Y154.923 E.04041
G1 X146.167 Y154.265 E.02146
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X168.526 Y130.937 E.03781
G1 X169.188 Y130.783 E.02026
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.268 Y130.252 E.0378
G1 X176.948 Y130.274 E.02026
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.937 Y166.474 E.03781
G1 X145.783 Y165.812 E.02026
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.672 Y154.859 E.03781
G1 X145.783 Y154.188 E.02026
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.885 Y143.993 Z4.4 F30000
G1 X151.936 Y142.34 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X150.988 Y143.664 E.05236
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.531 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.345 J-18.214 E.17554
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.949 J-6.82 E.05235
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X157.34 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y184.012 E.05236
G1 X173.806 Y168.87 E.6886
G2 X176.194 Y168.87 I1.194 J-11.531 E.07693
G1 X191.336 Y184.012 E.6886
G2 X195.541 Y180.541 I-18.211 J-26.341 E.17554
G1 X181.329 Y166.329 E.64629
G3 X180.078 Y167.367 I-6.82 J-6.949 E.05235
M204 S10000
G1 X198.064 Y177.66 F30000
G1 F8843.478
M204 S4000
G1 X199.012 Y176.336 E.05236
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.531 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-26.345 J18.214 E.17554
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.949 J6.82 E.05235
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J11.503 E.07693
G1 X158.664 Y135.988 E.6886
G2 X154.459 Y139.459 I18.211 J26.341 E.17554
G1 X168.671 Y153.671 E.64629
G3 X169.922 Y152.633 I6.82 J6.949 E.05235
M204 S10000
G1 X167.92 Y131.838 F30000
G1 F8843.478
M204 S4000
G1 X168.694 Y131.658 E.02556
G3 X169.508 Y131.48 I1.763 J6.118 E.02681
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.287 J-1.938 E.05239
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.927 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.938 J-12.287 E.05239
; WIPE_START
G1 X169.508 Y188.52 E-.61863
G1 X169.771 Y188.257 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X171.398 Y180.8 Z4.4 F30000
G1 X182.08 Y131.838 Z4.4
G1 Z4
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.525 J11.924 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X176.244 Y130.992 E.01501
G2 X173.289 Y131.007 I-1.361 J22.54 E.09509
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I42.471 J3.395 E.12259
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
; CHANGE_LAYER
; Z_HEIGHT: 4.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X186.894 Y186.486 E-.14097
G1 X188.046 Y185.334 E-.61903
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 21/30
; update layer progress
M73 L21
M991 S0 P20 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z4.4 I.869 J-.852 P1  F30000
G1 X170.232 Y167.159 Z4.4
G1 Z4.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X170.225 Y167.146 E.00047
G3 X174.815 Y151.404 I4.784 J-7.146 E.69934
G3 X178.805 Y152.285 I.203 J8.558 E.13268
G3 X170.702 Y167.444 I-3.796 J7.716 E.8873
G1 X170.283 Y167.19 E.01576
; COOLING_NODE: 0
M204 S250
G1 X170.442 Y166.821 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G3 X174.827 Y151.796 I4.567 J-6.82 E.6184
G3 X178.142 Y152.415 I.162 J8.314 E.10114
G3 X170.492 Y166.855 I-3.133 J7.587 E.81482
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.002 Y166.514 E-.22684
G1 X169.587 Y166.173 E-.20422
G1 X169.195 Y165.805 E-.20413
G1 X168.97 Y165.566 E-.12481
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.394 Y161.692 Z4.6 F30000
G1 X146.604 Y152.391 Z4.6
G1 Z4.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.321 Y130.646 E.0425
G1 X176.923 Y130.665 E.01936
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
M73 P76 R8
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.931 Y165.141 E.04251
G1 X203.833 Y165.735 E.01936
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06186
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.859 Y188.931 E.04251
G1 X169.265 Y188.833 E.01936
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.069 Y154.859 E.04251
G1 X146.167 Y154.265 E.01936
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.334 Y130.254 E.03975
G1 X176.948 Y130.274 E.01831
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.318 Y165.205 E.03976
G1 X204.217 Y165.812 E.01831
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.795 Y189.318 E.03976
G1 X169.188 Y189.217 E.01831
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.682 Y154.795 E.03976
G1 X145.783 Y154.188 E.01831
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.057 Z4.6 F30000
G1 X147.687 Y169.854 Z4.6
G1 Z4.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X157.34 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y184.012 E.05236
G1 X173.806 Y168.87 E.6886
G2 X176.194 Y168.87 I1.194 J-11.531 E.07693
G1 X191.336 Y184.012 E.6886
G1 X192.66 Y183.064 E.05236
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G1 X146.413 Y154.915 E.01328
G2 X146.007 Y158.289 I34.34 J5.843 E.10932
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J36.105 E.11006
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.938 J12.284 E.05239
M204 S10000
G1 X182.367 Y154.922 F30000
G1 F8843.478
M204 S4000
G2 X181.329 Y153.671 I-7.987 J5.569 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.873 J22.419 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.874 Y161.168 I-9.421 J1.198 E.07616
G1 X199.012 Y176.336 E.68909
G3 X195.541 Y180.541 I-26.341 J-18.211 E.17554
G1 X181.329 Y166.329 E.64629
G3 X180.078 Y167.367 I-6.82 J-6.949 E.05235
; WIPE_START
G1 X181.329 Y166.329 E-.61792
G1 X181.594 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X174.006 Y165.77 Z4.6 F30000
G1 X167.633 Y165.078 Z4.6
G1 Z4.2
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X168.671 Y166.329 I7.987 J-5.569 E.05235
G1 X154.459 Y180.541 E.64629
G3 X150.988 Y176.336 I22.873 J-22.419 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G1 X151.936 Y142.34 E.05236
M204 S10000
G1 X169.922 Y152.633 F30000
G1 F8843.478
M204 S4000
G2 X168.671 Y153.671 I5.569 J7.987 E.05235
G1 X154.459 Y139.459 E.64629
G3 X158.664 Y135.988 I22.416 J22.87 E.17554
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J11.505 E.07693
G1 X191.336 Y135.988 E.6886
G1 X192.66 Y136.936 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.929 J-3.526 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I1.938 J12.284 E.05239
; WIPE_START
G1 X169.508 Y131.48 E-.61863
G1 X169.771 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X169.521 Y139.371 Z4.6 F30000
G1 X167.92 Y188.162 Z4.6
G1 Z4.2
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.526 J-11.929 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.287 J1.938 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 4.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X203.52 Y154.508 E-.61863
G1 X203.257 Y154.771 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 22/30
; update layer progress
M73 L22
M991 S0 P21 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z4.6 I-.427 J-1.139 P1  F30000
G1 X170.232 Y167.16 Z4.6
G1 Z4.4
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X170.224 Y167.148 E.00046
G3 X174.832 Y151.403 I4.785 J-7.146 E.69994
G3 X178.292 Y152.052 I.155 J8.716 E.11399
G3 X170.702 Y167.445 I-3.283 J7.949 E.90559
G1 X170.283 Y167.191 E.01575
; COOLING_NODE: 0
M204 S250
G1 X170.439 Y166.827 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.442 Y166.822 E.00017
G3 X174.845 Y151.795 I4.567 J-6.82 E.61895
G3 X178.142 Y152.415 I.142 J8.321 E.10062
G3 X170.898 Y167.106 I-3.133 J7.587 E.80059
G1 X170.49 Y166.858 E.01421
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.442 Y166.822 E-.02292
G1 X170.002 Y166.514 E-.20406
G1 X169.587 Y166.173 E-.20422
G1 X169.195 Y165.805 E-.20413
G1 X168.97 Y165.566 E-.12468
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.394 Y161.692 Z4.8 F30000
G1 X146.604 Y152.391 Z4.8
G1 Z4.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06186
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.386 Y130.648 E.04461
G1 X176.923 Y130.665 E.01725
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06186
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
M73 P76 R7
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.08 Y154.794 E.04461
G1 X146.167 Y154.265 E.01725
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.399 Y130.256 E.0417
G1 X176.948 Y130.274 E.01636
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.693 Y154.73 E.04171
G1 X145.783 Y154.188 E.01637
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.885 Y143.993 Z4.8 F30000
G1 X151.936 Y142.34 Z4.8
G1 Z4.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X150.988 Y143.664 E.05236
G1 X166.13 Y158.806 E.6886
G2 X166.13 Y161.194 I11.531 J1.194 E.07693
G1 X150.988 Y176.336 E.6886
G2 X154.459 Y180.541 I26.345 J-18.214 E.17554
G1 X168.671 Y166.329 E.64629
G3 X167.633 Y165.078 I6.951 J-6.821 E.05235
; WIPE_START
G1 X168.671 Y166.329 E-.61792
M73 P77 R7
G1 X168.406 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X176.022 Y167.098 Z4.8 F30000
G1 X180.078 Y167.367 Z4.8
G1 Z4.4
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X181.329 Y166.329 I-5.57 J-7.989 E.05235
G1 X195.541 Y180.541 E.64629
G2 X199.012 Y176.336 I-22.87 J-22.416 E.17554
G1 X183.87 Y161.194 E.6886
G2 X183.87 Y158.806 I-11.531 J-1.194 E.07693
G1 X199.012 Y143.664 E.6886
G2 X195.541 Y139.459 I-26.345 J18.214 E.17554
G1 X181.329 Y153.671 E.64629
G3 X182.367 Y154.922 I-6.951 J6.821 E.05235
M204 S10000
G1 X192.66 Y136.936 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y135.988 E.05236
G1 X176.194 Y151.13 E.6886
G2 X173.806 Y151.13 I-1.194 J11.506 E.07693
G1 X158.664 Y135.988 E.6886
G2 X154.459 Y139.459 I18.211 J26.341 E.17554
G1 X168.671 Y153.671 E.64629
G3 X169.922 Y152.633 I6.821 J6.951 E.05235
M204 S10000
G1 X167.92 Y131.838 F30000
G1 F8843.478
M204 S4000
G3 X169.508 Y131.48 I3.526 J11.926 E.05239
G1 X203.52 Y165.492 E1.54673
G3 X203.162 Y167.08 I-12.289 J-1.939 E.05239
M204 S10000
G1 X203.162 Y152.92 F30000
G1 F8843.478
M204 S4000
G3 X203.52 Y154.508 I-11.929 J3.526 E.05239
G1 X169.508 Y188.52 E1.54673
G3 X167.92 Y188.162 I1.939 J-12.289 E.05239
M204 S10000
G1 X192.66 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X191.336 Y184.012 E.05236
G1 X176.194 Y168.87 E.6886
G3 X173.806 Y168.87 I-1.194 J-11.531 E.07693
G1 X158.664 Y184.012 E.6886
G1 X157.34 Y183.064 E.05236
M204 S10000
G1 X148.361 Y171.556 F30000
G1 F8843.478
M204 S4000
G1 X148.514 Y171.894 E.01193
G1 X163.106 Y186.486 E.66356
G1 X163.629 Y186.723 E.01847
G1 X201.723 Y148.629 E1.73234
G1 X201.486 Y148.106 E.01847
G1 X186.894 Y133.514 E.66356
G1 X186.371 Y133.277 E.01847
G1 X148.277 Y171.371 E1.73234
G3 X147.687 Y169.854 I11.269 J-5.26 E.05238
M204 S10000
G1 X182.08 Y131.838 F30000
G1 F8843.478
M204 S4000
G2 X180.492 Y131.48 I-3.526 J11.926 E.05239
G1 X146.48 Y165.492 E1.54673
G3 X146.007 Y161.711 I35.372 J-6.347 E.1226
G1 X173.289 Y188.993 E1.2407
G2 X176.711 Y188.993 I1.711 J-26.09 E.11009
G1 X203.993 Y161.711 E1.2407
G2 X203.993 Y158.289 I-26.091 J-1.711 E.1101
G1 X176.711 Y131.007 E1.2407
G1 X176.375 Y130.996 E.0108
G2 X173.289 Y131.007 I-1.459 J23.537 E.0993
G1 X146.007 Y158.289 E1.2407
G3 X146.48 Y154.508 I44.109 J3.6 E.12258
G1 X180.492 Y188.52 E1.54673
G2 X186.371 Y186.723 I-6.003 J-30.15 E.19801
G1 X148.277 Y148.629 E1.73234
G1 X148.514 Y148.106 E.01847
G1 X163.106 Y133.514 E.66356
G1 X163.629 Y133.277 E.01847
G1 X201.723 Y171.371 E1.73234
G1 X201.486 Y171.894 E.01847
G1 X186.894 Y186.486 E.66356
G1 X186.556 Y186.639 E.01193
; CHANGE_LAYER
; Z_HEIGHT: 4.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X186.894 Y186.486 E-.14097
G1 X188.046 Y185.334 E-.61903
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 23/30
; update layer progress
M73 L23
M991 S0 P22 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z4.8 I.869 J-.852 P1  F30000
G1 X170.232 Y167.16 Z4.8
G1 Z4.6
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X170.224 Y167.147 E.00047
G3 X174.849 Y151.403 I4.785 J-7.146 E.70052
G3 X178.292 Y152.052 I.136 J8.724 E.11343
G3 X170.702 Y167.445 I-3.283 J7.949 E.90554
G1 X170.283 Y167.191 E.01574
; COOLING_NODE: 0
M204 S250
G1 X170.439 Y166.827 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.442 Y166.822 E.00017
G3 X174.862 Y151.794 I4.566 J-6.821 E.6195
G3 X178.142 Y152.415 I.123 J8.33 E.1001
G3 X170.898 Y167.106 I-3.134 J7.586 E.80055
G1 X170.49 Y166.858 E.0142
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.442 Y166.822 E-.02296
G1 X170.002 Y166.514 E-.20412
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20416
G1 X168.97 Y165.566 E-.1246
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.394 Y161.692 Z5 F30000
G1 X146.604 Y152.391 Z5
G1 Z4.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06186
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06185
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.452 Y130.65 E.04671
G1 X176.923 Y130.665 E.01515
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06186
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.091 Y154.73 E.04672
G1 X146.167 Y154.265 E.01515
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.605 Y139.289 E.04365
G1 X153.935 Y138.935 E.01441
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.465 Y130.258 E.04365
G1 X176.948 Y130.274 E.01441
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.704 Y154.666 E.04366
G1 X145.783 Y154.188 E.01442
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.141 Y158.057 Z5 F30000
G1 X147.687 Y169.854 Z5
G1 Z4.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X148.277 Y171.371 I11.86 J-3.743 E.05238
G1 X186.371 Y133.277 E1.73234
G1 X186.894 Y133.514 E.01847
G1 X201.486 Y148.106 E.66356
G1 X201.723 Y148.629 E.01847
G1 X163.629 Y186.723 E1.73234
G1 X163.106 Y186.486 E.01847
G1 X148.514 Y171.894 E.66356
G1 X148.361 Y171.556 E.01193
M204 S10000
G1 X157.34 Y183.064 F30000
G1 F8843.478
M204 S4000
G1 X158.664 Y184.012 E.05236
G1 X173.806 Y168.87 E.6886
G2 X176.194 Y168.87 I1.194 J-11.531 E.07693
G1 X191.336 Y184.012 E.6886
G1 X192.66 Y183.064 E.05236
M204 S10000
G1 X186.556 Y186.639 F30000
G1 F8843.478
M204 S4000
G1 X186.894 Y186.486 E.01193
G1 X201.486 Y171.894 E.66356
G1 X201.723 Y171.371 E.01847
G1 X163.629 Y133.277 E1.73234
G1 X163.106 Y133.514 E.01847
G1 X148.514 Y148.106 E.66356
G1 X148.277 Y148.629 E.01847
G1 X186.371 Y186.723 E1.73234
G3 X180.492 Y188.52 I-11.882 J-28.353 E.19801
G1 X146.48 Y154.508 E1.54673
G1 X146.434 Y154.786 E.00907
G2 X146.007 Y158.289 I34.576 J5.995 E.11353
G1 X173.289 Y131.007 E1.2407
G3 X176.711 Y131.007 I1.711 J37.103 E.11006
G1 X203.993 Y158.289 E1.2407
G1 X204.049 Y160 E.05504
G1 X203.993 Y161.711 E.05504
G1 X176.711 Y188.993 E1.2407
G3 X173.289 Y188.993 I-1.711 J-26.09 E.11009
G1 X146.007 Y161.711 E1.2407
G2 X146.48 Y165.492 I35.845 J-2.566 E.1226
G1 X180.492 Y131.48 E1.54673
G3 X182.08 Y131.838 I-1.938 J12.284 E.05239
M204 S10000
G1 X182.367 Y154.922 F30000
G1 F8843.478
M204 S4000
G2 X181.329 Y153.671 I-7.987 J5.568 E.05235
G1 X195.541 Y139.459 E.64629
G3 X199.012 Y143.664 I-22.873 J22.419 E.17554
G1 X183.87 Y158.806 E.6886
G3 X183.874 Y161.168 I-9.421 J1.198 E.07616
M73 P78 R7
G1 X199.012 Y176.336 E.68909
G3 X195.541 Y180.541 I-26.341 J-18.211 E.17554
G1 X181.329 Y166.329 E.64629
G3 X180.078 Y167.367 I-6.82 J-6.949 E.05235
; WIPE_START
G1 X181.329 Y166.329 E-.61792
G1 X181.594 Y166.594 E-.14208
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X174.006 Y165.77 Z5 F30000
G1 X167.633 Y165.078 Z5
G1 Z4.6
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X168.671 Y166.329 I7.987 J-5.568 E.05235
G1 X154.459 Y180.541 E.64629
G3 X150.988 Y176.336 I22.873 J-22.419 E.17554
G1 X166.13 Y161.194 E.6886
G3 X166.13 Y158.806 I11.531 J-1.194 E.07693
G1 X150.988 Y143.664 E.6886
G1 X151.936 Y142.34 E.05236
M204 S10000
G1 X169.922 Y152.633 F30000
G1 F8843.478
M204 S4000
G2 X168.671 Y153.671 I5.568 J7.987 E.05235
G1 X154.459 Y139.459 E.64629
G3 X158.664 Y135.988 I22.416 J22.87 E.17554
G1 X173.806 Y151.13 E.6886
G3 X176.194 Y151.13 I1.194 J11.508 E.07693
G1 X191.336 Y135.988 E.6886
G1 X192.66 Y136.936 E.05236
M204 S10000
G1 X203.162 Y167.08 F30000
G1 F8843.478
M204 S4000
G2 X203.52 Y165.492 I-11.931 J-3.527 E.05239
G1 X169.508 Y131.48 E1.54673
G2 X167.92 Y131.838 I1.937 J12.282 E.05239
; WIPE_START
G1 X169.508 Y131.48 E-.61863
G1 X169.771 Y131.743 E-.14137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X169.521 Y139.371 Z5 F30000
G1 X167.92 Y188.162 Z5
G1 Z4.6
G1 E.8 F1800
G1 F8843.478
M204 S4000
G2 X169.508 Y188.52 I3.527 J-11.931 E.05239
G1 X203.52 Y154.508 E1.54673
G2 X203.162 Y152.92 I-12.285 J1.938 E.05239
; CHANGE_LAYER
; Z_HEIGHT: 4.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X203.52 Y154.508 E-.61863
G1 X203.257 Y154.771 E-.14137
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 24/30
; update layer progress
M73 L24
M991 S0 P23 ;notify layer change

M106 S122.4
; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z5 I-.427 J-1.139 P1  F30000
G1 X170.232 Y167.16 Z5
G1 Z4.8
G1 E.8 F1800
; FEATURE: Inner wall
G1 F8843.478
M204 S4000
G1 X170.224 Y167.148 E.00047
G3 X174.867 Y151.402 I4.784 J-7.147 E.70113
G3 X178.292 Y152.052 I.116 J8.734 E.11287
G3 X170.702 Y167.445 I-3.284 J7.949 E.90551
G1 X170.283 Y167.191 E.01574
; COOLING_NODE: 0
M204 S250
G1 X170.439 Y166.827 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.442 Y166.821 E.00019
G3 X174.88 Y151.794 I4.567 J-6.82 E.61999
G3 X177.639 Y152.226 I.139 J8.143 E.0836
G3 X170.898 Y167.105 I-2.63 J7.775 E.8166
G1 X170.491 Y166.858 E.01419
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.442 Y166.821 E-.02308
G1 X170.002 Y166.514 E-.20409
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20416
G1 X168.971 Y165.566 E-.12452
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.394 Y161.692 Z5.2 F30000
G1 X146.604 Y152.391 Z5.2
G1 Z4.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06186
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.517 Y130.652 E.04882
G1 X176.923 Y130.665 E.01304
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06186
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.101 Y154.665 E.04882
G1 X146.167 Y154.265 E.01304
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.649 Y139.241 E.0456
G1 X153.935 Y138.935 E.01246
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.53 Y130.26 E.0456
G1 X176.948 Y130.274 E.01247
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.714 Y154.601 E.04561
G1 X145.783 Y154.188 E.01247
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.981 Y150.435 Z5.2 F30000
G1 Z4.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G3 X148.562 Y148.914 I11.885 J3.67 E.05239
G1 X186.086 Y186.438 E1.70642
G1 X187.651 Y185.729 E.05526
G1 X200.728 Y172.651 E.5947
G1 X201.438 Y171.086 E.05526
G1 X163.914 Y133.562 E1.70642
G1 X162.349 Y134.271 E.05526
G1 X149.272 Y147.349 E.5947
G1 X148.646 Y148.729 E.04872
M204 S10000
G1 X169.653 Y152.362 F30000
G1 F8843.478
M204 S4000
G2 X168.404 Y153.404 I12.603 J16.372 E.05231
G1 X154.726 Y139.726 E.62202
G2 X151.258 Y143.934 I22.706 J22.244 E.17556
G1 X165.802 Y158.478 E.66139
G2 X165.802 Y161.522 I10.465 J1.522 E.09823
G1 X151.258 Y176.066 E.66139
G1 X152.207 Y177.389 E.05236
M204 S10000
G1 X168.245 Y187.85 F30000
G1 F8843.478
M204 S4000
G2 X169.836 Y188.192 I3.403 J-11.968 E.05238
G1 X203.192 Y154.836 E1.51689
G3 X203.587 Y157.883 I-23.046 J4.535 E.09886
G1 X177.117 Y131.413 E1.20372
G3 X180.164 Y131.808 I-1.488 J23.441 E.09886
G1 X146.808 Y165.164 E1.51689
G3 X146.413 Y162.117 I23.049 J-4.535 E.09886
G1 X172.883 Y188.587 E1.20372
G2 X177.117 Y188.587 I2.117 J-20.259 E.13641
G1 X203.587 Y162.117 E1.20372
G3 X203.192 Y165.164 I-23.439 J-1.488 E.09886
G1 X169.836 Y131.808 E1.51689
G3 X172.883 Y131.413 I4.535 J23.047 E.09886
G1 X146.413 Y157.883 E1.20372
G3 X146.808 Y154.836 I23.441 J1.488 E.09886
G1 X180.164 Y188.192 E1.51689
G2 X181.755 Y187.85 I-1.812 J-12.309 E.05238
M204 S10000
G1 X186.111 Y186.825 F30000
; Slow Down Start
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F3000;_EXTRUDE_SET_SPEED
M204 S4000
G1 X184.333 Y187.494 E.05103
G1 X182.515 Y188.045 E.05103
G1 X180.665 Y188.477 E.05102
G1 X178.79 Y188.786 E.05104
G1 X176.899 Y188.972 E.05103
G1 X175 Y189.035 E.05103
G1 X173.101 Y188.972 E.05103
G1 X171.21 Y188.786 E.05103
G1 X169.336 Y188.477 E.05104
G1 X167.485 Y188.045 E.05102
G1 X165.667 Y187.494 E.05103
G1 X163.889 Y186.825 E.05103
G1 X162.158 Y186.04 E.05103
G1 X160.483 Y185.145 E.05103
G1 X158.869 Y184.141 E.05104
G1 X157.325 Y183.035 E.05102
G1 X155.856 Y181.829 E.05102
G1 X154.473 Y180.534 E.05089
G1 X153.171 Y179.144 E.05117
G1 X151.965 Y177.675 E.05103
G1 X150.859 Y176.131 E.05102
G1 X149.855 Y174.517 E.05104
G1 X148.96 Y172.842 E.05103
G1 X148.175 Y171.111 E.05103
G1 X147.506 Y169.333 E.05103
G1 X146.955 Y167.515 E.05103
G1 X146.523 Y165.664 E.05102
G1 X146.214 Y163.79 E.05104
G1 X146.028 Y161.899 E.05103
G1 X145.965 Y160 E.05103
G1 X146.028 Y158.101 E.05103
G1 X146.214 Y156.21 E.05103
G1 X146.523 Y154.336 E.05103
G1 X146.955 Y152.485 E.05102
G1 X147.506 Y150.667 E.05103
G1 X148.175 Y148.889 E.05102
G1 X148.96 Y147.158 E.05103
G1 X149.855 Y145.483 E.05103
G1 X150.862 Y143.865 E.05117
G1 X151.965 Y142.325 E.05089
G1 X153.17 Y140.856 E.05102
G1 X154.469 Y139.469 E.05103
G1 X155.856 Y138.17 E.05103
G1 X157.325 Y136.965 E.05102
G1 X158.869 Y135.859 E.05102
G1 X160.483 Y134.855 E.05104
G1 X162.158 Y133.96 E.05103
G1 X163.889 Y133.175 E.05103
G1 X165.667 Y132.506 E.05103
G1 X167.485 Y131.955 E.05103
G1 X169.336 Y131.523 E.05102
G1 X171.21 Y131.214 E.05104
G1 X173.101 Y131.028 E.05103
G1 X175 Y130.965 E.05103
G1 X176.899 Y131.028 E.05103
G1 X178.79 Y131.214 E.05103
G1 X180.664 Y131.523 E.05103
G1 X182.515 Y131.955 E.05102
G1 X184.333 Y132.506 E.05103
G1 X186.111 Y133.175 E.05102
G1 X187.842 Y133.96 E.05103
G1 X189.517 Y134.855 E.05103
G1 X191.131 Y135.859 E.05104
G1 X192.675 Y136.965 E.05102
G1 X194.14 Y138.167 E.05089
G1 X195.531 Y139.469 E.05116
G1 X196.829 Y140.856 E.05103
G1 X198.035 Y142.325 E.05102
G1 X199.141 Y143.869 E.05102
G1 X200.145 Y145.483 E.05104
G1 X201.04 Y147.158 E.05103
G1 X201.825 Y148.889 E.05103
G1 X202.494 Y150.667 E.05103
G1 X203.045 Y152.485 E.05103
G1 X203.477 Y154.335 E.05102
G1 X203.786 Y156.21 E.05104
G1 X203.972 Y158.101 E.05103
G1 X204.035 Y160 E.05103
G1 X203.972 Y161.899 E.05103
G1 X203.786 Y163.79 E.05103
G1 X203.477 Y165.664 E.05104
G1 X203.044 Y167.52 E.05117
G1 X202.494 Y169.333 E.05089
G1 X201.825 Y171.111 E.05103
G1 X201.04 Y172.842 E.05103
G1 X200.145 Y174.517 E.05103
G1 X199.141 Y176.131 E.05104
G1 X198.035 Y177.675 E.05102
G1 X196.83 Y179.144 E.05102
G1 X195.531 Y180.531 E.05103
G1 X194.144 Y181.829 E.05103
G1 X192.675 Y183.035 E.05102
G1 X191.131 Y184.141 E.05102
G1 X189.517 Y185.145 E.05104
G1 X187.842 Y186.04 E.05103
G1 X186.166 Y186.8 E.04942
; Slow Down End
M204 S10000
G1 X180.347 Y167.638 F30000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G2 X181.596 Y166.596 I-12.603 J-16.372 E.05231
G1 X195.274 Y180.274 E.62202
G2 X198.742 Y176.066 I-22.705 J-22.244 E.17556
G1 X184.198 Y161.522 E.66139
G2 X184.198 Y158.478 I-10.465 J-1.522 E.09823
G1 X198.742 Y143.934 E.66139
G1 X197.793 Y142.611 E.05236
M204 S10000
G1 X184.565 Y132.981 F30000
G1 F8843.478
M204 S4000
G3 X186.086 Y133.562 I-3.672 J11.89 E.05239
G1 X148.562 Y171.086 E1.70642
G1 X149.272 Y172.651 E.05526
G1 X162.349 Y185.728 E.5947
G1 X163.914 Y186.438 E.05526
G1 X201.438 Y148.914 E1.70642
G1 X200.729 Y147.349 E.05526
G1 X187.651 Y134.272 E.5947
M73 P79 R7
G1 X186.271 Y133.646 E.04872
M204 S10000
G1 X182.638 Y154.653 F30000
G1 F8843.478
M204 S4000
G2 X181.596 Y153.404 I-16.372 J12.603 E.05231
G1 X195.274 Y139.726 E.62202
G2 X191.066 Y136.258 I-22.245 J22.708 E.17556
G1 X176.522 Y150.802 E.66139
G2 X173.478 Y150.802 I-1.522 J10.444 E.09824
G1 X158.934 Y136.258 E.66139
G1 X157.611 Y137.207 E.05236
M204 S10000
G1 X167.362 Y165.347 F30000
G1 F8843.478
M204 S4000
G2 X168.404 Y166.596 I16.38 J-12.609 E.05231
G1 X154.726 Y180.274 E.62202
G2 X158.934 Y183.742 I22.245 J-22.708 E.17556
G1 X173.478 Y169.198 E.66139
G2 X176.522 Y169.198 I1.522 J-10.465 E.09823
G1 X191.066 Y183.742 E.66139
G1 X192.389 Y182.793 E.05236
M204 S10000
G1 X183.965 Y160 F30000
; Slow Down Start
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F3000;_EXTRUDE_SET_SPEED
M204 S4000
G1 X183.965 Y160.005 E.00014
G3 X174.869 Y151.047 I-8.961 J.002 E1.13061
G3 X183.963 Y159.94 I.148 J8.945 E.38002
; Slow Down End
; CHANGE_LAYER
; Z_HEIGHT: 5
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F3000
G1 X183.946 Y159.414 E-.20008
G1 X183.889 Y158.83 E-.22299
G1 X183.793 Y158.251 E-.22296
G1 X183.725 Y157.959 E-.11397
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 25/30
; update layer progress
M73 L25
M991 S0 P24 ;notify layer change

M106 S25.5
; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z5.2 I-.686 J-1.005 P1  F30000
G1 X170.232 Y167.16 Z5.2
G1 Z5
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X170.224 Y167.147 E.00048
G3 X174.884 Y151.401 I4.785 J-7.147 E.70167
G3 X177.765 Y151.854 I.135 J8.536 E.09424
G3 X170.702 Y167.445 I-2.756 J8.147 E.92367
G1 X170.284 Y167.191 E.01573
; COOLING_NODE: 0
M204 S250
G1 X170.439 Y166.827 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.443 Y166.82 E.00023
G3 X174.897 Y151.793 I4.565 J-6.82 E.62051
G3 X177.639 Y152.226 I.12 J8.149 E.08308
G3 X170.988 Y167.155 I-2.631 J7.774 E.81339
G1 X170.491 Y166.858 E.01724
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.443 Y166.82 E-.02315
G1 X170.002 Y166.514 E-.20411
G1 X169.587 Y166.173 E-.20415
G1 X169.195 Y165.805 E-.20416
G1 X168.971 Y165.566 E-.12443
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.394 Y161.693 Z5.4 F30000
G1 X146.604 Y152.391 Z5.4
G1 Z5
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06186
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.583 Y130.654 E.05092
G1 X176.923 Y130.665 E.01094
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06186
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.112 Y154.6 E.05093
G1 X146.167 Y154.265 E.01094
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.596 Y130.262 E.04755
G1 X176.948 Y130.274 E.01052
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.725 Y154.537 E.04756
G1 X145.783 Y154.188 E.01052
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X149.311 Y146.086 Z5.4 F30000
G1 Z5
G1 E.8 F1800
; FEATURE: Bridge
; LINE_WIDTH: 0.40004
; LAYER_HEIGHT: 0.4
M106 S204
G1 F3000
M204 S4000
G1 X166.754 Y163.528 E1.22454
G3 X166.398 Y162.537 I9.119 J-3.825 E.05231
G1 X149.683 Y145.821 E1.17355
G3 X149.909 Y145.41 I3.244 J1.519 E.02328
G1 X166.19 Y161.692 E1.14308
G3 X166.082 Y160.948 I5.611 J-1.194 E.03737
G1 X150.153 Y145.018 E1.11836
G1 X150.397 Y144.625 E.02294
G1 X166.036 Y160.265 E1.09799
G3 X166.04 Y159.632 I4.825 J-.291 E.03145
G1 X150.641 Y144.233 E1.0811
G3 X150.886 Y143.842 I3.102 J1.68 E.02293
G1 X166.084 Y159.04 E1.06693
G3 X166.162 Y158.481 I4.297 J.317 E.02801
G1 X151.152 Y143.472 E1.05376
G1 X151.418 Y143.101 E.02264
G1 X166.269 Y157.952 E1.04266
G3 X166.403 Y157.449 I3.901 J.765 E.02586
G1 X151.683 Y142.73 E1.03337
G1 X151.949 Y142.359 E.02264
G1 X166.559 Y156.969 E1.02569
G3 X166.736 Y156.51 I12.683 J4.629 E.02444
M73 P79 R6
G1 X152.234 Y142.008 E1.01811
G1 X152.521 Y141.658 E.02245
G1 X166.935 Y156.072 E1.0119
G3 X167.154 Y155.655 I3.284 J1.463 E.02341
G1 X152.808 Y141.309 E1.00718
G1 X153.095 Y140.959 E.02245
G1 X167.391 Y155.255 E1.00363
G3 X167.643 Y154.871 I3.058 J1.735 E.02283
G1 X153.397 Y140.625 E1.00016
G1 X153.705 Y140.296 E.02235
G1 X167.911 Y154.502 E.99736
G1 X168.198 Y154.153 E.02245
G1 X154.013 Y139.967 E.99589
G1 X154.32 Y139.639 E.02235
G1 X168.502 Y153.82 E.9956
G3 X168.82 Y153.502 I2.591 J2.273 E.02236
G1 X154.639 Y139.321 E.9956
G1 X154.967 Y139.013 E.02235
G1 X169.153 Y153.198 E.99589
G1 X169.502 Y152.911 E.02245
G1 X155.296 Y138.705 E.99736
G1 X155.624 Y138.397 E.02235
G1 X169.871 Y152.643 E1.00016
G3 X170.023 Y152.535 I.766 J.914 E.00931
G1 X170.255 Y152.391 E.01353
G1 X155.959 Y138.095 E1.00363
G1 X156.309 Y137.808 E.02245
G1 X170.655 Y152.154 E1.00717
G3 X171.072 Y151.935 I1.883 J3.071 E.02341
G1 X156.658 Y137.521 E1.0119
G1 X157.008 Y137.235 E.02245
M73 P80 R6
G1 X171.51 Y151.736 E1.01811
G3 X171.969 Y151.559 I1.582 J3.415 E.02445
G1 X157.359 Y136.949 E1.02569
G1 X157.73 Y136.684 E.02264
G1 X172.449 Y151.403 E1.03336
G3 X172.952 Y151.269 I1.267 J3.763 E.02586
G1 X158.101 Y136.418 E1.04265
G1 X158.471 Y136.152 E.02264
G1 X173.481 Y151.162 E1.05375
G3 X174.039 Y151.084 I1.184 J6.422 E.02799
G1 X158.842 Y135.887 E1.06692
G3 X159.233 Y135.641 I2.069 J2.855 E.02293
G1 X174.632 Y151.04 E1.08109
G3 X175.268 Y151.04 I.317 J5.873 E.03162
G1 X159.625 Y135.397 E1.09823
G1 X160.018 Y135.153 E.02294
G1 X175.947 Y151.082 E1.11835
G3 X176.555 Y151.168 I-.348 J4.676 E.03049
G1 X176.692 Y151.19 E.00688
G1 X160.41 Y134.909 E1.14306
G3 X160.82 Y134.683 I1.929 J3.017 E.02328
G1 X177.536 Y151.398 E1.17352
G3 X178.527 Y151.753 I-2.659 J8.99 E.0523
G1 X161.235 Y134.461 E1.214
G1 X161.65 Y134.239 E.02335
G1 X200.761 Y173.35 E2.74579
G1 X200.539 Y173.765 E.02335
G1 X183.247 Y156.473 E1.214
G3 X183.602 Y157.464 I-9.133 J3.829 E.0523
G1 X200.317 Y174.18 E1.17352
G3 X200.091 Y174.59 I-3.239 J-1.516 E.02328
G1 X183.81 Y158.308 E1.14306
G3 X183.918 Y159.053 I-5.618 J1.195 E.03737
G1 X199.847 Y174.983 E1.11834
G1 X199.603 Y175.375 E.02294
G1 X183.964 Y159.735 E1.09798
G3 X183.96 Y160.368 I-4.822 J.291 E.03145
G1 X199.359 Y175.767 E1.08109
G3 X199.113 Y176.158 I-3.107 J-1.683 E.02293
G1 X183.916 Y160.961 E1.06692
G3 X183.838 Y161.519 I-4.291 J-.317 E.028
G1 X198.848 Y176.529 E1.05375
G1 X198.582 Y176.9 E.02264
G1 X183.731 Y162.048 E1.04265
G3 X183.597 Y162.551 I-3.897 J-.764 E.02586
G1 X198.316 Y177.27 E1.03336
G1 X198.051 Y177.641 E.02264
G1 X183.441 Y163.031 E1.02569
G3 X183.264 Y163.49 I-12.615 J-4.604 E.02444
G1 X197.765 Y177.992 E1.01811
G1 X197.479 Y178.342 E.02245
G1 X183.065 Y163.928 E1.0119
G3 X182.846 Y164.345 I-3.396 J-1.522 E.02341
G1 X197.192 Y178.691 E1.00717
G1 X196.905 Y179.041 E.02245
G1 X182.609 Y164.745 E1.00363
G3 X182.357 Y165.129 I-3.056 J-1.734 E.02283
G1 X196.603 Y179.376 E1.00016
G1 X196.295 Y179.704 E.02235
G1 X182.089 Y165.498 E.99736
G1 X181.802 Y165.847 E.02245
G1 X195.987 Y180.033 E.99589
G1 X195.679 Y180.361 E.02235
G1 X181.498 Y166.18 E.9956
G3 X181.18 Y166.498 I-2.592 J-2.274 E.02236
G1 X195.361 Y180.68 E.9956
G1 X195.033 Y180.987 E.02235
G1 X180.847 Y166.802 E.99589
G1 X180.498 Y167.089 E.02245
G1 X194.704 Y181.295 E.99736
G1 X194.375 Y181.603 E.02235
G1 X180.129 Y167.357 E1.00017
G3 X179.745 Y167.609 I-2.123 J-2.81 E.02283
G1 X194.041 Y181.905 E1.00364
G1 X193.691 Y182.192 E.02245
G1 X179.345 Y167.846 E1.00718
G3 X178.928 Y168.065 I-1.883 J-3.069 E.02341
G1 X193.342 Y182.479 E1.01191
G1 X192.992 Y182.766 E.02245
G1 X178.49 Y168.264 E1.01811
G3 X178.031 Y168.441 I-1.581 J-3.414 E.02445
G1 X192.641 Y183.051 E1.02569
G1 X192.27 Y183.317 E.02264
G1 X177.551 Y168.597 E1.03337
G3 X177.048 Y168.731 I-1.267 J-3.763 E.02586
G1 X191.899 Y183.582 E1.04266
G1 X191.528 Y183.848 E.02264
G1 X176.519 Y168.838 E1.05376
G3 X175.96 Y168.916 I-1.301 J-7.257 E.02799
M73 P81 R6
G1 X191.158 Y184.114 E1.06693
G3 X190.767 Y184.359 I-2.073 J-2.86 E.02293
G1 X175.368 Y168.96 E1.0811
G3 X174.735 Y168.964 I-.342 J-4.822 E.03145
G1 X190.375 Y184.603 E1.09799
G1 X189.982 Y184.847 E.02294
G1 X174.052 Y168.918 E1.11836
G3 X173.445 Y168.832 I.347 J-4.672 E.03046
G1 X173.308 Y168.81 E.00691
G1 X189.59 Y185.091 E1.14308
G3 X189.179 Y185.317 I-1.925 J-3.011 E.02328
G1 X172.463 Y168.602 E1.17354
G3 X171.472 Y168.246 I2.657 J-8.981 E.05231
G1 X188.765 Y185.539 E1.21404
G1 X188.35 Y185.761 E.02335
G1 X149.239 Y146.65 E2.74578
G1 X149.017 Y147.065 E.02335
G1 X187.935 Y185.983 E2.73222
G3 X187.502 Y186.186 I-1.772 J-3.2 E.02376
G1 X148.814 Y147.498 E2.71616
G1 X148.615 Y147.936 E.02387
G1 X187.064 Y186.385 E2.69934
G1 X186.626 Y186.583 E.02387
G1 X148.417 Y148.374 E2.68253
G1 X148.218 Y148.812 E.02387
G1 X186.188 Y186.782 E2.66571
G3 X185.731 Y186.96 I-1.59 J-3.403 E.02442
G1 X148.04 Y149.269 E2.64609
G1 X147.866 Y149.732 E.02453
G1 X185.268 Y187.134 E2.62585
G1 X184.806 Y187.308 E.02453
G1 X147.692 Y150.194 E2.6056
G1 X147.518 Y150.657 E.02453
G1 X184.343 Y187.482 E2.58536
G3 X183.856 Y187.631 I-1.392 J-3.686 E.02533
G1 X147.369 Y151.144 E2.56157
G1 X147.221 Y151.633 E.02533
G1 X183.367 Y187.779 E2.53769
G1 X182.879 Y187.928 E.02533
G1 X147.072 Y152.121 E2.51381
G2 X146.931 Y152.616 I3.703 J1.323 E.02558
G1 X182.384 Y188.069 E2.48895
G1 X181.868 Y188.189 E.02631
G1 X146.811 Y153.132 E2.46117
G1 X146.691 Y153.648 E.02631
G1 X181.352 Y188.309 E2.43338
G1 X180.835 Y188.43 E.02631
G1 X146.57 Y154.165 E2.40559
G2 X146.477 Y154.661 I3.741 J.963 E.02508
M73 P82 R6
G1 X146.47 Y154.701 E.00201
G1 X180.299 Y188.53 E2.37499
G1 X179.753 Y188.62 E.02749
G1 X146.38 Y155.247 E2.34297
G1 X146.29 Y155.793 E.02749
G1 X179.207 Y188.71 E2.31095
G3 X178.653 Y188.793 I-.906 J-4.184 E.02783
G1 X146.207 Y156.347 E2.27784
G1 X146.15 Y156.927 E.0289
G1 X178.073 Y188.85 E2.24117
G1 X177.494 Y188.907 E.0289
G1 X146.093 Y157.506 E2.2045
G1 X146.036 Y158.085 E.0289
G1 X176.915 Y188.964 E2.16783
G3 X176.299 Y188.985 I-.469 J-4.683 E.03058
G1 X146.015 Y158.701 E2.12612
G1 X145.995 Y159.317 E.03061
G1 X175.683 Y189.005 E2.08427
G1 X175.067 Y189.026 E.03061
G1 X145.974 Y159.933 E2.04242
G2 X145.992 Y160.587 I4.998 J.197 E.03247
G1 X174.413 Y189.008 E1.99535
G1 X173.755 Y188.987 E.03268
G1 X146.013 Y161.245 E1.94764
G2 X146.035 Y161.903 I5.157 J.158 E.03272
G1 X173.097 Y188.965 E1.89989
G1 X172.391 Y188.896 E.03522
M73 P82 R5
G1 X146.104 Y162.609 E1.84545
G1 X146.174 Y163.315 E.03522
G1 X171.685 Y188.826 E1.791
G3 X170.96 Y188.738 I.31 J-5.571 E.03626
G1 X146.262 Y164.04 E1.73395
G1 X146.388 Y164.802 E.03836
G1 X170.198 Y188.612 E1.6716
G1 X169.436 Y188.486 E.03836
G1 X146.514 Y165.564 E1.60924
G2 X146.699 Y166.385 I6.356 J-.998 E.04181
G1 X168.615 Y188.302 E1.53863
G1 X167.785 Y188.108 E.04231
G1 X146.892 Y167.215 E1.46677
G2 X147.139 Y168.099 I6.865 J-1.444 E.04558
G1 X166.901 Y187.861 E1.38738
G1 X165.987 Y187.584 E.04739
G1 X147.416 Y169.013 E1.30379
G2 X147.763 Y169.996 I7.674 J-2.154 E.0518
G1 X165.004 Y187.237 E1.2104
G1 X163.984 Y186.853 E.05413
G1 X148.147 Y171.016 E1.11178
G1 X148.662 Y172.167 E.06258
G1 X162.833 Y186.338 E.99487
G3 X161.583 Y185.725 I4.056 J-9.845 E.06916
G1 X149.275 Y173.417 E.86407
G1 X149.861 Y174.514 E.06173
M73 P83 R5
G1 X150.068 Y174.847 E.01947
G1 X160.153 Y184.932 E.708
G1 X158.873 Y184.136 E.07483
G1 X158.335 Y183.75 E.03284
G1 X150.484 Y175.899 E.55118
M106 S25.5
M204 S10000
G1 X161.915 Y133.868 F30000
M106 S204
G1 F3000
M204 S4000
G1 X200.982 Y172.935 E2.74274
G2 X201.186 Y172.503 I-3.198 J-1.772 E.02376
G1 X162.497 Y133.814 E2.71617
G1 X162.935 Y133.615 E.02387
G1 X201.385 Y172.065 E2.69936
G1 X201.583 Y171.627 E.02387
G1 X163.373 Y133.417 E2.68254
G1 X163.811 Y133.218 E.02387
G1 X201.782 Y171.189 E2.66572
G2 X201.96 Y170.731 I-3.401 J-1.59 E.02442
G1 X164.269 Y133.04 E2.64611
G1 X164.732 Y132.866 E.02453
G1 X202.134 Y170.268 E2.62586
G1 X202.308 Y169.806 E.02453
G1 X165.194 Y132.692 E2.60562
G1 X165.656 Y132.518 E.02453
G1 X202.482 Y169.344 E2.58537
G2 X202.631 Y168.856 I-3.632 J-1.375 E.02533
G1 X166.144 Y132.369 E2.56159
G1 X166.632 Y132.221 E.02533
G1 X202.779 Y168.368 E2.53771
G1 X202.927 Y167.879 E.02533
G1 X167.121 Y132.073 E2.51382
G3 X167.616 Y131.931 I1.324 J3.704 E.02558
G1 X203.069 Y167.384 E2.48897
G1 X203.189 Y166.868 E.02631
G1 X168.132 Y131.811 E2.46118
G1 X168.648 Y131.691 E.02631
G1 X203.309 Y166.352 E2.4334
G1 X203.43 Y165.836 E.02631
G1 X169.164 Y131.57 E2.40561
G3 X169.7 Y131.47 I1.033 J4.041 E.0271
G1 X203.53 Y165.3 E2.37501
G1 X203.62 Y164.753 E.02748
G1 X170.247 Y131.38 E2.34299
G1 X170.793 Y131.29 E.02749
G1 X203.71 Y164.207 E2.31097
G2 X203.793 Y163.653 I-4.185 J-.906 E.02783
G1 X171.347 Y131.207 E2.27786
G1 X171.926 Y131.15 E.0289
M73 P84 R5
G1 X203.85 Y163.074 E2.24119
G1 X203.907 Y162.494 E.0289
G1 X172.506 Y131.093 E2.20452
G1 X173.085 Y131.036 E.0289
G1 X203.964 Y161.915 E2.16786
G2 X203.985 Y161.3 I-4.693 J-.47 E.03058
G1 X173.7 Y131.015 E2.12615
G1 X174.317 Y130.995 E.03061
G1 X204.005 Y160.683 E2.0843
G1 X204.026 Y160.067 E.03061
G1 X174.933 Y130.974 E2.04245
G3 X175.586 Y130.991 I.197 J4.99 E.03247
G1 X204.009 Y159.414 E1.99539
G1 X203.987 Y158.756 E.03268
G1 X176.244 Y131.013 E1.94768
G1 X176.903 Y131.035 E.0327
G1 X203.965 Y158.097 E1.89993
G1 X203.896 Y157.391 E.03522
G1 X177.609 Y131.104 E1.84549
G1 X178.315 Y131.174 E.03522
G1 X203.826 Y156.685 E1.79104
G2 X203.738 Y155.961 I-5.571 J.309 E.03626
G1 X179.039 Y131.262 E1.734
G1 X179.801 Y131.388 E.03836
G1 X203.612 Y155.199 E1.67164
G1 X203.486 Y154.436 E.03836
G1 X180.564 Y131.514 E1.60929
G3 X181.385 Y131.698 I-.999 J6.36 E.04181
G1 X203.302 Y153.615 E1.53868
G1 X203.108 Y152.785 E.04231
G1 X182.215 Y131.892 E1.46682
G3 X183.098 Y132.139 I-1.442 J6.859 E.04558
G1 X202.861 Y151.902 E1.38744
G1 X202.584 Y150.988 E.04739
G1 X184.012 Y132.416 E1.30384
G3 X184.995 Y132.763 I-3.244 J10.765 E.05178
G1 X202.237 Y150.005 E1.21047
G1 X201.853 Y148.984 E.05413
G1 X186.016 Y133.147 E1.11185
G1 X187.167 Y133.661 E.06257
G1 X201.339 Y147.834 E.99496
G2 X200.725 Y146.584 I-9.839 J4.053 E.06915
G1 X188.416 Y134.275 E.86417
G1 X189.514 Y134.861 E.06178
G1 X189.846 Y135.068 E.0194
G1 X199.932 Y145.154 E.70814
G1 X199.136 Y143.873 E.07489
G1 X198.751 Y143.337 E.03275
G1 X191.663 Y136.249 E.49764
G1 X192.671 Y136.971 E.06155
G1 X194.139 Y138.176 E.0943
G1 X195.52 Y139.469 E.09388
G1 X197.884 Y141.833 E.16602
M106 S25.5
; CHANGE_LAYER
; Z_HEIGHT: 5.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F3000
G1 X196.47 Y140.419 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 26/30
; update layer progress
M73 L26
M991 S0 P25 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z5.4 I-.869 J-.852 P1  F30000
G1 X170.236 Y167.162 Z5.4
G1 Z5.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X170.225 Y167.146 E.00061
G3 X174.902 Y151.401 I4.783 J-7.147 E.70222
G3 X177.765 Y151.854 I.115 J8.542 E.09368
G3 X170.788 Y167.492 I-2.757 J8.145 E.92033
G1 X170.287 Y167.193 E.01875
; COOLING_NODE: 0
M204 S250
G1 X170.44 Y166.827 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.442 Y166.821 E.00018
G3 X174.915 Y151.793 I4.567 J-6.821 E.62107
G3 X177.125 Y152.07 I.05 J8.556 E.06654
G3 X170.972 Y167.148 I-2.116 J7.931 E.83008
G1 X170.491 Y166.858 E.01672
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.442 Y166.821 E-.02322
G1 X170.002 Y166.514 E-.20405
G1 X169.587 Y166.173 E-.20422
G1 X169.195 Y165.805 E-.20413
G1 X168.971 Y165.567 E-.12438
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.395 Y161.693 Z5.6 F30000
G1 X146.604 Y152.391 Z5.6
G1 Z5.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.648 Y130.656 E.05302
G1 X176.923 Y130.665 E.00884
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
M73 P85 R5
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.122 Y154.536 E.05303
G1 X146.167 Y154.265 E.00884
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.661 Y130.264 E.0495
G1 X176.948 Y130.274 E.00857
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.736 Y154.472 E.0495
G1 X145.783 Y154.188 E.00857
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.832 Y143.96 Z5.6 F30000
G1 X152.321 Y141.577 Z5.6
G1 Z5.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42037
G1 F9537.687
M204 S4000
G1 X154.469 Y139.43 E.09055
G1 X155.837 Y138.148 E.05588
G1 X157.307 Y136.942 E.05671
G1 X157.954 Y136.478 E.02374
G1 X151.478 Y142.954 E.27307
G2 X150.375 Y144.591 I11.933 J9.231 E.05889
G1 X159.591 Y135.375 E.38859
G3 X160.902 Y134.598 I6.586 J9.613 E.04549
G1 X149.598 Y145.902 E.47667
G1 X148.985 Y147.049 E.03877
G1 X162.049 Y133.985 E.55087
G1 X163.039 Y133.528 E.03252
G1 X148.528 Y148.039 E.61188
G1 X148.103 Y148.998 E.03128
G1 X163.998 Y133.103 E.67025
G1 X164.854 Y132.781 E.02727
G1 X147.781 Y149.854 E.71993
G1 X147.464 Y150.705 E.02706
G1 X165.705 Y132.464 E.76914
G1 X166.471 Y132.232 E.02387
G1 X147.232 Y151.471 E.81125
G1 X146.999 Y152.237 E.02387
G1 X167.237 Y131.999 E.85336
G3 X167.955 Y131.815 I1.765 J5.387 E.02212
G1 X146.815 Y152.955 E.89141
G1 X146.652 Y153.651 E.02131
G1 X168.651 Y131.652 E.92761
G3 X169.346 Y131.492 I1.577 J5.229 E.02128
G1 X146.492 Y154.346 E.96368
G1 X146.386 Y154.985 E.01932
G1 X169.985 Y131.386 E.99509
G1 X170.625 Y131.281 E.01932
G1 X146.281 Y155.625 E1.0265
G2 X146.179 Y156.26 I4.795 J1.091 E.01919
G1 X171.26 Y131.179 E1.05755
G1 X171.852 Y131.121 E.01774
G1 X146.121 Y156.852 E1.08498
G1 X146.063 Y157.444 E.01774
G1 X172.444 Y131.063 E1.1124
G1 X173.036 Y131.004 E.01774
G1 X146.004 Y158.036 E1.13983
G2 X145.982 Y158.592 I4.235 J.449 E.01661
G1 X173.592 Y130.982 E1.16422
G1 X174.144 Y130.964 E.01646
G1 X145.964 Y159.144 E1.18825
G1 X145.946 Y159.696 E.01646
G1 X174.696 Y130.946 E1.21228
G3 X175.232 Y130.943 I.286 J4.087 E.016
G1 X145.943 Y160.232 E1.23499
G1 X145.96 Y160.749 E.01542
G1 X175.749 Y130.96 E1.25607
G1 X176.266 Y130.977 E.01542
G1 X145.977 Y161.266 E1.27715
G1 X145.994 Y161.783 E.01542
G1 X176.783 Y130.994 E1.29823
G3 X177.276 Y131.035 I-.064 J3.78 E.01476
G1 X146.035 Y162.276 E1.3173
G1 X146.083 Y162.762 E.01456
G1 X177.762 Y131.083 E1.33577
G1 X178.248 Y131.131 E.01456
M73 P85 R4
G1 X146.131 Y163.248 E1.35424
G1 X146.179 Y163.734 E.01456
G1 X178.734 Y131.179 E1.37272
G3 X179.195 Y131.251 I-.32 J3.558 E.01394
G1 X146.251 Y164.195 E1.38913
G1 X146.326 Y164.653 E.01385
G1 X179.653 Y131.326 E1.40526
G1 X180.112 Y131.402 E.01385
G1 X146.402 Y165.111 E1.42139
G1 X146.478 Y165.57 E.01385
G1 X180.57 Y131.478 E1.43752
G3 X181.008 Y131.573 I-.508 J3.392 E.01339
G1 X146.573 Y166.008 E1.45199
G1 X146.674 Y166.441 E.01325
G1 X181.441 Y131.674 E1.46598
G1 X181.874 Y131.775 E.01325
G1 X146.775 Y166.874 E1.47998
G1 X146.876 Y167.307 E.01325
G1 X182.307 Y131.876 E1.49397
G3 X182.728 Y131.988 I-.648 J3.266 E.01301
G1 X146.989 Y167.728 E1.50698
G1 X147.113 Y168.137 E.01276
G1 X183.137 Y132.113 E1.51901
G1 X183.547 Y132.237 E.01276
G1 X147.237 Y168.547 E1.53104
G1 X147.361 Y168.956 E.01276
G1 X183.957 Y132.361 E1.54308
G3 X184.365 Y132.487 I-.75 J3.166 E.01274
G1 X147.487 Y169.365 E1.555
G1 X147.633 Y169.753 E.01236
G1 X184.753 Y132.633 E1.5652
G1 X185.14 Y132.779 E.01236
G1 X147.779 Y170.14 E1.5754
G1 X147.925 Y170.528 E.01236
G1 X185.528 Y132.925 E1.5856
G1 X185.916 Y133.071 E.01236
G1 X148.071 Y170.916 E1.59579
G2 X148.226 Y171.294 I2.963 J-.997 E.0122
G1 X186.294 Y133.226 E1.60518
G1 X186.662 Y133.393 E.01202
G1 X148.393 Y171.662 E1.61365
G1 X148.559 Y172.029 E.01202
G1 X187.029 Y133.559 E1.62213
G1 X187.396 Y133.725 E.01202
G1 X148.725 Y172.396 E1.6306
G1 X148.892 Y172.764 E.01202
G1 X187.764 Y133.892 E1.63907
G3 X188.116 Y134.073 I-1.205 J2.78 E.01183
G1 X148.948 Y173.242 E1.65159
M204 S10000
G1 X193.429 Y182.674 F30000
G1 F9537.687
M204 S4000
G1 X195.554 Y180.548 E.08962
G1 X196.852 Y179.163 E.05658
G1 X198.058 Y177.693 E.05672
G1 X198.519 Y177.05 E.0236
G1 X192.05 Y183.519 E.2728
G3 X190.412 Y184.623 I-9.24 J-11.941 E.05893
G1 X199.623 Y175.412 E.3884
G2 X200.401 Y174.1 I-9.62 J-6.592 E.04551
G1 X189.1 Y185.401 E.47652
G1 X187.953 Y186.014 E.03877
M73 P86 R4
G1 X201.014 Y172.953 E.55072
G1 X201.471 Y171.963 E.03253
G1 X186.963 Y186.471 E.61176
G1 X186.003 Y186.897 E.03129
G1 X201.897 Y171.003 E.67015
G1 X202.219 Y170.147 E.02727
G1 X185.147 Y187.219 E.71983
G1 X184.297 Y187.536 E.02706
G1 X202.536 Y169.297 E.76905
G1 X202.768 Y168.531 E.02387
G1 X183.531 Y187.768 E.81116
G1 X182.764 Y188 E.02387
G1 X203 Y167.764 E.85327
G2 X203.185 Y167.046 I-5.388 J-1.767 E.02213
G1 X182.046 Y188.185 E.89134
G1 X181.35 Y188.347 E.02131
G1 X203.347 Y166.35 E.92753
G2 X203.508 Y165.655 I-5.221 J-1.576 E.02128
G1 X180.655 Y188.508 E.96362
G1 X180.016 Y188.614 E.01932
G1 X203.614 Y165.016 E.99503
G1 X203.719 Y164.377 E.01932
G1 X179.377 Y188.719 E1.02644
G3 X178.741 Y188.821 I-1.091 J-4.794 E.01919
G1 X203.821 Y163.741 E1.0575
G1 X203.879 Y163.149 E.01774
G1 X178.149 Y188.879 E1.08492
G1 X177.557 Y188.937 E.01774
G1 X203.937 Y162.557 E1.11235
G1 X203.996 Y161.965 E.01774
G1 X176.965 Y188.996 E1.13977
G3 X176.409 Y189.018 I-.45 J-4.241 E.01661
G1 X204.018 Y161.409 E1.16417
G1 X204.036 Y160.857 E.01646
G1 X175.857 Y189.036 E1.1882
G1 X175.305 Y189.054 E.01646
G1 X204.054 Y160.305 E1.21224
G2 X204.057 Y159.769 I-4.088 J-.287 E.016
G1 X174.769 Y189.057 E1.23495
G1 X174.252 Y189.04 E.01542
G1 X204.04 Y159.252 E1.25603
G1 X204.023 Y158.735 E.01542
G1 X173.735 Y189.023 E1.27711
G1 X173.218 Y189.006 E.01542
G1 X204.006 Y158.218 E1.29819
G2 X203.965 Y157.725 I-3.787 J.065 E.01476
G1 X172.725 Y188.965 E1.31726
G1 X172.239 Y188.917 E.01456
G1 X203.917 Y157.239 E1.33573
G1 X203.869 Y156.753 E.01456
G1 X171.753 Y188.869 E1.35421
G1 X171.267 Y188.822 E.01456
G1 X203.822 Y156.267 E1.37268
G2 X203.749 Y155.806 I-3.562 J.32 E.01394
G1 X170.806 Y188.749 E1.3891
G1 X170.348 Y188.674 E.01385
G1 X203.674 Y155.348 E1.40523
G1 X203.598 Y154.889 E.01385
G1 X169.889 Y188.598 E1.42136
G1 X169.431 Y188.522 E.01385
G1 X203.522 Y154.431 E1.43749
G2 X203.427 Y153.993 I-3.392 J.508 E.01339
G1 X168.993 Y188.427 E1.45196
G1 X168.56 Y188.326 E.01325
G1 X203.326 Y153.56 E1.46595
G1 X203.225 Y153.127 E.01325
G1 X168.127 Y188.225 E1.47995
G1 X167.694 Y188.124 E.01325
G1 X203.124 Y152.694 E1.49395
G2 X203.012 Y152.273 I-3.272 J.649 E.01301
G1 X167.273 Y188.012 E1.50696
G1 X166.863 Y187.888 E.01276
G1 X202.888 Y151.863 E1.51899
G1 X202.763 Y151.454 E.01276
G1 X166.454 Y187.763 E1.53102
G1 X166.044 Y187.639 E.01276
G1 X202.639 Y151.044 E1.54305
G2 X202.514 Y150.636 I-3.176 J.752 E.01275
G1 X165.636 Y187.514 E1.55498
G1 X165.248 Y187.368 E.01236
G1 X202.368 Y150.248 E1.56518
G1 X202.222 Y149.86 E.01236
G1 X164.86 Y187.222 E1.57538
G1 X164.472 Y187.076 E.01236
G1 X202.076 Y149.472 E1.58557
G1 X201.93 Y149.085 E.01236
G1 X164.085 Y186.93 E1.59577
G3 X163.706 Y186.774 I.996 J-2.962 E.0122
G1 X201.774 Y148.706 E1.60517
G1 X201.608 Y148.339 E.01202
G1 X163.339 Y186.608 E1.61364
G1 X162.972 Y186.441 E.01202
G1 X201.441 Y147.972 E1.62211
G1 X201.275 Y147.604 E.01202
G1 X162.604 Y186.275 E1.63058
G1 X162.237 Y186.108 E.01202
G1 X201.108 Y147.237 E1.63905
G2 X200.927 Y146.884 I-2.783 J1.206 E.01183
G1 X161.884 Y185.927 E1.64629
G1 X161.536 Y185.741 E.01176
G1 X179.656 Y167.621 E.76404
G3 X178.545 Y168.199 I-4.804 J-7.889 E.03735
G1 X161.189 Y185.555 E.73187
G1 X160.841 Y185.37 E.01176
G1 X177.695 Y168.515 E.71067
G3 X176.964 Y168.713 I-1.868 J-5.47 E.02259
G1 X160.493 Y185.184 E.69451
G3 X160.162 Y184.98 I1.383 J-2.618 E.01158
G1 X176.306 Y168.836 E.68073
G3 X175.704 Y168.905 I-.825 J-4.559 E.01809
G1 X159.833 Y184.776 E.6692
G1 X159.504 Y184.571 E.01156
G1 X175.144 Y168.931 E.65947
G3 X174.618 Y168.923 I-.204 J-4.009 E.0157
G1 X159.175 Y184.366 E.65117
G3 X158.846 Y184.161 I1.38 J-2.579 E.01156
G1 X174.12 Y168.888 E.64403
G3 X173.645 Y168.828 I.215 J-3.647 E.01427
G1 X158.535 Y183.938 E.63713
G1 X158.224 Y183.716 E.01141
G1 X173.191 Y168.749 E.63109
G1 X172.758 Y168.648 E.01325
G1 X157.913 Y183.493 E.62595
G1 X157.602 Y183.27 E.01141
G1 X172.345 Y168.527 E.62163
G3 X171.945 Y168.393 I.826 J-3.114 E.01257
G1 X157.292 Y183.046 E.61787
G1 X156.999 Y182.806 E.01131
G1 X171.559 Y168.246 E.61393
G1 X171.191 Y168.079 E.01202
G1 X156.706 Y182.565 E.6108
G1 X156.413 Y182.324 E.01131
G1 X170.836 Y167.901 E.60817
G3 X170.491 Y167.713 I1.26 J-2.723 E.01174
G1 X156.12 Y182.084 E.60596
G3 X155.827 Y181.843 I1.701 J-2.361 E.01131
G1 X170.161 Y167.508 E.60442
G3 X169.843 Y167.292 I1.49 J-2.537 E.01147
G1 X155.551 Y181.584 E.60264
G1 X155.276 Y181.326 E.01126
G1 X169.534 Y167.068 E.60122
G1 X169.241 Y166.827 E.01131
G1 X155 Y181.068 E.60048
G1 X154.724 Y180.81 E.01126
G1 X168.957 Y166.577 E.60014
G1 X168.682 Y166.319 E.01126
G1 X154.449 Y180.552 E.60014
G1 X154.191 Y180.276 E.01126
M73 P87 R4
G1 X168.424 Y166.043 E.60014
G3 X168.173 Y165.76 I2.036 J-2.049 E.01128
G1 X153.932 Y180 E.60048
G1 X153.674 Y179.725 E.01126
G1 X167.933 Y165.467 E.60122
G3 X167.708 Y165.157 I2.248 J-1.867 E.0114
G1 X153.416 Y179.449 E.60264
G1 X153.158 Y179.174 E.01126
G1 X167.492 Y164.839 E.60442
G1 X167.288 Y164.51 E.01156
G1 X152.917 Y178.881 E.60596
G1 X152.676 Y178.588 E.01131
G1 X167.099 Y164.165 E.60817
G3 X166.921 Y163.809 I2.622 J-1.538 E.01187
G1 X152.436 Y178.295 E.61079
G1 X152.195 Y178.001 E.01131
G1 X166.754 Y163.442 E.61392
G3 X166.607 Y163.055 I2.891 J-1.322 E.01234
G1 X151.954 Y177.708 E.61786
G3 X151.731 Y177.398 I2.263 J-1.869 E.01141
G1 X166.473 Y162.656 E.62162
G3 X166.352 Y162.243 I3.086 J-1.124 E.01285
G1 X151.508 Y177.087 E.62594
G1 X151.285 Y176.776 E.01141
G1 X166.251 Y161.81 E.63108
G3 X166.172 Y161.356 I3.432 J-.835 E.01376
G1 X151.062 Y176.465 E.63712
G1 X150.839 Y176.154 E.01141
G1 X166.113 Y160.881 E.64402
G3 X166.077 Y160.383 I3.789 J-.523 E.0149
G1 X150.634 Y175.826 E.65115
G1 X150.429 Y175.497 E.01156
G1 X166.069 Y159.857 E.65945
G3 X166.095 Y159.297 I4.289 J-.08 E.01673
G1 X150.225 Y175.167 E.66918
G1 X150.02 Y174.838 E.01156
G1 X166.164 Y158.695 E.6807
G3 X166.287 Y158.038 I5.085 J.615 E.01995
G1 X149.817 Y174.508 E.69448
G1 X149.631 Y174.16 E.01176
G1 X166.484 Y157.307 E.71063
G3 X166.801 Y156.457 I9.331 J2.989 E.02706
G1 X149.445 Y173.812 E.73182
G1 X149.259 Y173.464 E.01176
G1 X167.377 Y155.347 E.76395
G3 X170.347 Y152.377 I7.503 J4.533 E.12645
G1 X188.464 Y134.259 E.76395
G1 X188.812 Y134.445 E.01176
G1 X171.457 Y151.8 E.73182
G3 X172.307 Y151.484 I3.839 J9.015 E.02706
G1 X189.16 Y134.631 E.71063
G1 X189.508 Y134.817 E.01176
G1 X173.038 Y151.287 E.69448
G3 X173.695 Y151.164 I1.271 J4.958 E.01995
G1 X189.838 Y135.02 E.6807
G1 X190.167 Y135.225 E.01156
G1 X174.297 Y151.095 E.66918
G3 X174.857 Y151.069 I.479 J4.26 E.01672
G1 X190.497 Y135.429 E.65945
G1 X190.826 Y135.634 E.01156
G1 X175.381 Y151.078 E.65123
G3 X175.881 Y151.113 I.024 J3.337 E.01495
G1 X191.154 Y135.839 E.64401
G1 X191.465 Y136.062 E.01141
G1 X176.356 Y151.172 E.63712
G3 X176.81 Y151.251 I-.381 J3.515 E.01376
G1 X191.776 Y136.285 E.63108
G1 X192.087 Y136.508 E.01141
G1 X177.243 Y151.352 E.62594
G3 X177.656 Y151.473 I-.711 J3.208 E.01285
G1 X192.398 Y136.731 E.62162
G3 X192.708 Y136.954 I-1.557 J2.484 E.01141
G1 X178.055 Y151.607 E.61786
G3 X178.442 Y151.754 I-.936 J3.038 E.01234
G1 X193.001 Y137.195 E.61392
G1 X193.295 Y137.436 E.01131
G1 X178.809 Y151.921 E.61079
G3 X179.165 Y152.099 I-1.184 J2.804 E.01187
G1 X193.588 Y137.676 E.60817
G1 X193.881 Y137.917 E.01131
G1 X179.51 Y152.288 E.60596
G1 X179.839 Y152.492 E.01156
G1 X194.174 Y138.158 E.60442
G1 X194.449 Y138.416 E.01126
G1 X180.157 Y152.708 E.60264
G3 X180.467 Y152.933 I-1.555 J2.469 E.0114
G1 X194.725 Y138.674 E.60122
G1 X195 Y138.932 E.01126
G1 X180.76 Y153.173 E.60048
G3 X181.043 Y153.424 I-1.764 J2.284 E.01128
G1 X195.276 Y139.191 E.60014
G1 X195.552 Y139.449 E.01126
G1 X181.319 Y153.682 E.60014
G1 X181.577 Y153.957 E.01126
G1 X195.81 Y139.724 E.60014
G1 X196.068 Y140 E.01126
G1 X181.827 Y154.241 E.60048
G1 X182.068 Y154.534 E.01131
G1 X196.326 Y140.276 E.60122
G1 X196.584 Y140.551 E.01126
G1 X182.292 Y154.843 E.60264
G3 X182.508 Y155.161 I-2.318 J1.807 E.01147
G1 X196.843 Y140.827 E.60442
G3 X197.084 Y141.12 I-2.14 J2.01 E.01131
G1 X182.713 Y155.491 E.60597
G3 X182.901 Y155.836 I-2.536 J1.606 E.01174
G1 X197.324 Y141.413 E.60817
G1 X197.565 Y141.706 E.01131
G1 X183.079 Y156.191 E.6108
G1 X183.246 Y156.559 E.01202
G1 X197.806 Y141.999 E.61393
G1 X198.046 Y142.292 E.01131
G1 X183.393 Y156.945 E.61787
G3 X183.527 Y157.345 I-2.98 J1.225 E.01257
G1 X198.27 Y142.602 E.62163
G1 X198.493 Y142.913 E.01141
G1 X183.648 Y157.758 E.62595
G1 X183.749 Y158.191 E.01325
G1 X198.716 Y143.224 E.63109
G1 X198.938 Y143.535 E.01141
G1 X183.828 Y158.645 E.63713
G3 X183.888 Y159.12 I-3.587 J.689 E.01427
G1 X199.161 Y143.846 E.64403
G3 X199.366 Y144.175 I-2.375 J1.71 E.01156
G1 X183.923 Y159.618 E.65117
G3 X183.931 Y160.144 I-4.005 J.323 E.0157
G1 X199.571 Y144.504 E.65947
G1 X199.776 Y144.833 E.01156
G1 X183.905 Y160.704 E.6692
G3 X183.836 Y161.306 I-4.623 J-.222 E.01809
G1 X199.98 Y145.162 E.68073
G3 X200.184 Y145.493 I-2.426 J1.72 E.01158
G1 X183.713 Y161.964 E.69451
G3 X183.515 Y162.695 I-5.666 J-1.137 E.02259
G1 X200.37 Y145.841 E.71067
G1 X200.556 Y146.189 E.01176
G1 X183.199 Y163.545 E.73187
G3 X182.622 Y164.656 I-8.469 J-3.694 E.03735
G1 X200.867 Y146.411 E.76933
; CHANGE_LAYER
; Z_HEIGHT: 5.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9537.687
G1 X199.453 Y147.825 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 27/30
; update layer progress
M73 L27
M991 S0 P26 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z5.6 I-.672 J-1.015 P1  F30000
G1 X170.233 Y167.16 Z5.6
G1 Z5.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X170.224 Y167.147 E.00049
G3 X174.919 Y151.4 I4.784 J-7.147 E.70283
G3 X177.226 Y151.691 I.041 J8.983 E.07499
G3 X170.702 Y167.445 I-2.218 J8.31 E.94174
G1 X170.284 Y167.191 E.01572
; COOLING_NODE: 0
M204 S250
G1 X170.44 Y166.827 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.443 Y166.82 E.00023
G3 X174.932 Y151.792 I4.566 J-6.82 E.62153
G3 X176.602 Y151.948 I.09 J8.072 E.05004
G3 X170.899 Y167.104 I-1.592 J8.052 E.8486
G1 X170.491 Y166.858 E.01418
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.443 Y166.82 E-.02328
G1 X170.002 Y166.514 E-.20408
G1 X169.587 Y166.173 E-.20422
G1 X169.195 Y165.805 E-.20413
G1 X168.971 Y165.567 E-.12431
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.395 Y161.693 Z5.8 F30000
G1 X146.604 Y152.391 Z5.8
G1 Z5.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.713 Y130.658 E.05513
G1 X176.923 Y130.665 E.00673
G1 X178.837 Y130.854 E.06185
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.133 Y154.471 E.05513
G1 X146.167 Y154.265 E.00674
G1 X146.59 Y152.45 E.05993
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.935 Y138.935 E.05806
G1 X155.358 Y137.603 E.05806
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.726 Y130.267 E.05145
G1 X176.948 Y130.274 E.00662
G1 X178.888 Y130.465 E.05806
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.746 Y154.407 E.05145
G1 X145.783 Y154.188 E.00662
G1 X146.212 Y152.348 E.05628
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X151.885 Y144.752 Z5.8 F30000
G1 X161.411 Y134.133 Z5.8
G1 Z5.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42037
G1 F9537.687
M204 S4000
G1 X179.656 Y152.379 E.76933
G2 X178.545 Y151.801 I-4.805 J7.891 E.03735
G1 X161.189 Y134.444 E.73187
G1 X160.841 Y134.63 E.01176
G1 X177.695 Y151.485 E.71067
G2 X176.964 Y151.287 I-1.867 J5.467 E.02259
G1 X160.493 Y134.816 E.69451
G2 X160.162 Y135.02 I1.378 J2.61 E.01158
G1 X176.306 Y151.164 E.68073
G2 X175.704 Y151.095 I-.825 J4.561 E.01809
M73 P88 R4
G1 X159.833 Y135.224 E.6692
G1 X159.504 Y135.429 E.01156
G1 X175.148 Y151.072 E.65962
G2 X174.618 Y151.077 I-.228 J4.626 E.0158
G1 X159.175 Y135.634 E.65117
G2 X158.846 Y135.839 I1.405 J2.618 E.01156
G1 X174.12 Y151.112 E.64403
G2 X173.645 Y151.172 I.215 J3.648 E.01427
G1 X158.535 Y136.062 E.63713
G1 X158.224 Y136.284 E.01141
G1 X173.191 Y151.251 E.63109
G1 X172.758 Y151.352 E.01325
G1 X157.913 Y136.507 E.62595
G1 X157.602 Y136.73 E.01141
G1 X172.345 Y151.473 E.62163
G2 X171.945 Y151.607 I.826 J3.115 E.01257
G1 X157.292 Y136.954 E.61787
G1 X156.999 Y137.194 E.01131
G1 X171.559 Y151.754 E.61393
G1 X171.192 Y151.921 E.01202
G1 X156.706 Y137.435 E.6108
G1 X156.413 Y137.676 E.01131
G1 X170.836 Y152.099 E.60817
G2 X170.491 Y152.287 I1.264 J2.731 E.01174
G1 X156.12 Y137.916 E.60597
G2 X155.827 Y138.157 I1.694 J2.352 E.01131
G1 X170.161 Y152.492 E.60442
G2 X169.843 Y152.708 I1.487 J2.532 E.01147
G1 X155.551 Y138.416 E.60264
G1 X155.276 Y138.674 E.01126
G1 X169.534 Y152.932 E.60122
G1 X169.241 Y153.173 E.01131
G1 X155 Y138.932 E.60048
G1 X154.724 Y139.19 E.01126
G1 X168.957 Y153.423 E.60014
G1 X168.682 Y153.681 E.01126
G1 X154.449 Y139.448 E.60014
G1 X154.191 Y139.724 E.01126
G1 X168.424 Y153.957 E.60014
G2 X168.173 Y154.24 I2.038 J2.051 E.01128
G1 X153.932 Y140 E.60048
G1 X153.674 Y140.275 E.01126
G1 X167.933 Y154.533 E.60122
G2 X167.708 Y154.843 I2.245 J1.865 E.0114
G1 X153.416 Y140.551 E.60264
G1 X153.158 Y140.826 E.01126
G1 X167.492 Y155.161 E.60442
G1 X167.288 Y155.49 E.01156
G1 X152.917 Y141.119 E.60596
G1 X152.676 Y141.412 E.01131
G1 X167.099 Y155.835 E.60817
G2 X166.921 Y156.191 I2.622 J1.538 E.01187
G1 X152.436 Y141.705 E.61079
G1 X152.195 Y141.998 E.01131
G1 X166.754 Y156.558 E.61392
G2 X166.607 Y156.945 I2.887 J1.321 E.01234
G1 X151.954 Y142.292 E.61786
G2 X151.731 Y142.602 I2.25 J1.86 E.01141
G1 X166.473 Y157.344 E.62162
G2 X166.352 Y157.757 I3.09 J1.125 E.01285
G1 X151.508 Y142.913 E.62594
G1 X151.285 Y143.224 E.01141
G1 X166.251 Y158.19 E.63108
G2 X166.172 Y158.644 I3.436 J.836 E.01376
G1 X151.062 Y143.535 E.63712
G1 X150.839 Y143.846 E.01141
G1 X166.113 Y159.119 E.64401
G2 X166.077 Y159.617 I3.786 J.523 E.0149
G1 X150.634 Y144.174 E.65115
G1 X150.429 Y144.503 E.01156
G1 X166.069 Y160.143 E.65945
G2 X166.095 Y160.703 I4.289 J.08 E.01673
G1 X150.225 Y144.833 E.66918
G1 X150.02 Y145.162 E.01156
G1 X166.164 Y161.305 E.6807
G2 X166.287 Y161.962 I5.081 J-.614 E.01995
G1 X149.817 Y145.492 E.69448
G1 X149.631 Y145.84 E.01176
G1 X166.484 Y162.693 E.71063
G2 X166.801 Y163.543 I9.329 J-2.988 E.02706
G1 X149.445 Y146.188 E.73182
G1 X149.259 Y146.536 E.01176
G1 X167.377 Y164.653 E.76395
G2 X170.347 Y167.623 I7.503 J-4.533 E.12646
G1 X188.464 Y185.741 E.76395
G1 X188.812 Y185.555 E.01176
G1 X171.457 Y168.2 E.73182
G2 X172.307 Y168.516 I3.84 J-9.017 E.02706
G1 X189.16 Y185.369 E.71063
M73 P88 R3
G1 X189.508 Y185.183 E.01176
G1 X173.038 Y168.713 E.69448
G2 X173.695 Y168.836 I1.271 J-4.957 E.01995
G1 X189.838 Y184.98 E.6807
G1 X190.167 Y184.775 E.01156
G1 X174.297 Y168.905 E.66918
G2 X174.857 Y168.931 I.48 J-4.262 E.01673
G1 X190.497 Y184.571 E.65945
G1 X190.826 Y184.366 E.01156
G1 X175.383 Y168.923 E.65115
G2 X175.881 Y168.887 I-.025 J-3.825 E.0149
G1 X191.154 Y184.161 E.64401
G1 X191.465 Y183.938 E.01141
G1 X176.356 Y168.828 E.63712
G2 X176.81 Y168.749 I-.38 J-3.507 E.01376
G1 X191.776 Y183.715 E.63108
G1 X192.087 Y183.492 E.01141
G1 X177.243 Y168.648 E.62594
G2 X177.656 Y168.527 I-.709 J-3.203 E.01285
G1 X192.398 Y183.269 E.62162
G2 X192.708 Y183.046 I-1.559 J-2.487 E.01141
G1 X178.055 Y168.393 E.61786
G2 X178.442 Y168.246 I-.932 J-3.028 E.01234
G1 X193.002 Y182.805 E.61392
G1 X193.295 Y182.564 E.01131
G1 X178.809 Y168.079 E.61079
G2 X179.165 Y167.901 I-1.183 J-2.801 E.01187
G1 X193.588 Y182.324 E.60817
G1 X193.881 Y182.083 E.01131
G1 X179.51 Y167.712 E.60596
G1 X179.839 Y167.508 E.01156
G1 X194.174 Y181.842 E.60442
G1 X194.449 Y181.584 E.01126
G1 X180.157 Y167.292 E.60264
G2 X180.467 Y167.067 I-1.56 J-2.476 E.0114
G1 X194.725 Y181.326 E.60122
G1 X195 Y181.068 E.01126
G1 X180.76 Y166.827 E.60048
G2 X181.043 Y166.576 I-1.767 J-2.288 E.01128
G1 X195.276 Y180.809 E.60014
G1 X195.552 Y180.551 E.01126
G1 X181.319 Y166.318 E.60014
G1 X181.577 Y166.043 E.01126
G1 X195.81 Y180.276 E.60014
G1 X196.068 Y180 E.01126
G1 X181.827 Y165.759 E.60048
G1 X182.068 Y165.466 E.01131
G1 X196.326 Y179.724 E.60122
G1 X196.584 Y179.449 E.01126
G1 X182.292 Y165.157 E.60264
G2 X182.508 Y164.839 I-2.316 J-1.805 E.01147
G1 X196.843 Y179.173 E.60442
G2 X197.084 Y178.88 I-2.113 J-1.988 E.01131
G1 X182.713 Y164.509 E.60597
G2 X182.901 Y164.164 I-2.539 J-1.608 E.01174
G1 X197.324 Y178.587 E.60817
G1 X197.565 Y178.294 E.01131
G1 X183.079 Y163.808 E.6108
G1 X183.246 Y163.441 E.01202
G1 X197.806 Y178.001 E.61393
G1 X198.046 Y177.708 E.01131
G1 X183.393 Y163.055 E.61787
G2 X183.527 Y162.655 I-2.983 J-1.227 E.01257
G1 X198.27 Y177.398 E.62163
G1 X198.493 Y177.087 E.01141
G1 X183.648 Y162.242 E.62595
G1 X183.749 Y161.809 E.01325
G1 X198.716 Y176.776 E.63109
G1 X198.938 Y176.465 E.01141
G1 X183.828 Y161.355 E.63713
G2 X183.888 Y160.88 I-3.589 J-.689 E.01427
G1 X199.161 Y176.154 E.64403
G2 X199.366 Y175.825 I-2.413 J-1.734 E.01156
G1 X183.923 Y160.382 E.65117
G2 X183.931 Y159.856 I-4.006 J-.323 E.0157
G1 X199.571 Y175.496 E.65947
G1 X199.776 Y175.167 E.01156
G1 X183.905 Y159.296 E.6692
G2 X183.836 Y158.694 I-4.63 J.223 E.01809
G1 X199.98 Y174.838 E.68073
G2 X200.184 Y174.507 I-2.406 J-1.708 E.01158
G1 X183.713 Y158.036 E.69451
G2 X183.515 Y157.305 I-5.665 J1.137 E.02259
G1 X200.37 Y174.159 E.71067
G1 X200.556 Y173.811 E.01176
G1 X183.199 Y156.455 E.73187
G2 X182.621 Y155.344 I-8.465 J3.692 E.03735
G1 X200.741 Y173.464 E.76405
G1 X200.927 Y173.116 E.01176
G1 X161.884 Y134.073 E1.64629
G3 X162.237 Y133.892 I1.558 J2.602 E.01183
G1 X201.108 Y172.763 E1.63905
G1 X201.275 Y172.396 E.01202
G1 X162.604 Y133.725 E1.63058
G1 X162.972 Y133.559 E.01202
G1 X201.441 Y172.028 E1.62211
G1 X201.608 Y171.661 E.01202
G1 X163.339 Y133.392 E1.61364
G1 X163.706 Y133.226 E.01202
G1 X201.774 Y171.294 E1.60517
G2 X201.93 Y170.915 I-2.807 J-1.375 E.0122
G1 X164.085 Y133.07 E1.59577
G1 X164.473 Y132.924 E.01236
G1 X202.076 Y170.527 E1.58557
G1 X202.222 Y170.14 E.01236
G1 X164.86 Y132.778 E1.57538
G1 X165.248 Y132.632 E.01236
G1 X202.368 Y169.752 E1.56518
G1 X202.514 Y169.364 E.01236
G1 X165.636 Y132.486 E1.55498
M73 P89 R3
G3 X166.044 Y132.361 I1.158 J3.04 E.01275
G1 X202.639 Y168.956 E1.54305
G1 X202.763 Y168.546 E.01276
G1 X166.454 Y132.237 E1.53102
G1 X166.863 Y132.112 E.01276
G1 X202.888 Y168.137 E1.51899
G1 X203.012 Y167.727 E.01276
G1 X167.273 Y131.988 E1.50696
G3 X167.694 Y131.876 I1.069 J3.155 E.01301
G1 X203.124 Y167.306 E1.49395
G1 X203.225 Y166.873 E.01325
G1 X168.127 Y131.775 E1.47995
G1 X168.56 Y131.674 E.01325
G1 X203.326 Y166.44 E1.46595
G1 X203.427 Y166.007 E.01325
G1 X168.993 Y131.573 E1.45196
G3 X169.431 Y131.478 I.945 J3.293 E.01339
G1 X203.522 Y165.569 E1.43749
G1 X203.598 Y165.111 E.01385
G1 X169.889 Y131.402 E1.42136
G1 X170.348 Y131.326 E.01385
G1 X203.674 Y164.652 E1.40523
G1 X203.749 Y164.194 E.01385
G1 X170.806 Y131.251 E1.3891
G3 X171.267 Y131.178 I.782 J3.488 E.01394
G1 X203.822 Y163.733 E1.37268
G1 X203.869 Y163.247 E.01456
G1 X171.753 Y131.131 E1.35421
G1 X172.239 Y131.083 E.01456
G1 X203.917 Y162.761 E1.33573
G1 X203.965 Y162.275 E.01456
G1 X172.725 Y131.035 E1.31726
G3 X173.218 Y130.994 I.557 J3.74 E.01476
G1 X204.006 Y161.782 E1.29819
G1 X204.023 Y161.265 E.01542
G1 X173.735 Y130.977 E1.27711
G1 X174.252 Y130.96 E.01542
G1 X204.04 Y160.748 E1.25603
G1 X204.057 Y160.231 E.01542
G1 X174.769 Y130.943 E1.23495
G3 X175.305 Y130.946 I.25 J4.086 E.016
G1 X204.054 Y159.695 E1.21223
G1 X204.036 Y159.143 E.01646
G1 X175.857 Y130.964 E1.1882
G1 X176.409 Y130.982 E.01646
G1 X204.018 Y158.591 E1.16417
G2 X203.996 Y158.035 I-4.248 J-.107 E.01661
G1 X176.965 Y131.004 E1.13977
G1 X177.557 Y131.063 E.01774
G1 X203.937 Y157.443 E1.11235
G1 X203.879 Y156.851 E.01774
G1 X178.149 Y131.121 E1.08492
G1 X178.741 Y131.179 E.01774
G1 X203.821 Y156.259 E1.05749
G2 X203.719 Y155.623 I-4.9 J.457 E.01919
G1 X179.377 Y131.281 E1.02643
G1 X180.016 Y131.386 E.01932
G1 X203.614 Y154.984 E.99503
G1 X203.508 Y154.345 E.01932
G1 X180.655 Y131.492 E.96362
G3 X181.35 Y131.653 I-.891 J5.426 E.02128
G1 X203.347 Y153.65 E.92753
G1 X203.185 Y152.954 E.02131
G1 X182.046 Y131.815 E.89134
G3 X182.764 Y132 I-1.047 J5.568 E.02213
G1 X203 Y152.236 E.85327
G1 X202.768 Y151.469 E.02387
G1 X183.531 Y132.232 E.81116
G1 X184.297 Y132.464 E.02387
G1 X202.536 Y150.703 E.76905
G1 X202.219 Y149.853 E.02706
G1 X185.147 Y132.781 E.71983
G1 X186.003 Y133.103 E.02727
G1 X201.897 Y148.997 E.67015
G1 X201.471 Y148.037 E.03129
G1 X186.963 Y133.529 E.61175
G1 X187.953 Y133.986 E.03253
G1 X201.014 Y147.047 E.55071
G1 X200.401 Y145.9 E.03877
G1 X189.1 Y134.599 E.47652
G3 X190.412 Y135.377 I-5.276 J10.391 E.04551
G1 X199.623 Y144.588 E.3884
G2 X198.519 Y142.95 I-13.044 J7.602 E.05893
G1 X192.05 Y136.481 E.27279
G1 X192.693 Y136.942 E.0236
G1 X194.163 Y138.149 E.05672
G1 X195.548 Y139.446 E.05657
G1 X197.674 Y141.571 E.08962
M204 S10000
G1 X188.242 Y186.052 F30000
G1 F9537.687
M204 S4000
G1 X149.073 Y146.884 E1.65159
G2 X148.892 Y147.236 I2.604 J1.56 E.01183
G1 X187.764 Y186.108 E1.63907
G1 X187.396 Y186.275 E.01202
G1 X148.725 Y147.604 E1.6306
G1 X148.559 Y147.971 E.01202
G1 X187.029 Y186.441 E1.62213
G1 X186.662 Y186.607 E.01202
G1 X148.393 Y148.338 E1.61366
G1 X148.226 Y148.706 E.01202
G1 X186.294 Y186.774 E1.60518
G3 X185.916 Y186.929 I-1.376 J-2.808 E.0122
G1 X148.071 Y149.084 E1.59579
G1 X147.925 Y149.472 E.01236
G1 X185.528 Y187.075 E1.5856
G1 X185.14 Y187.221 E.01236
G1 X147.779 Y149.86 E1.5754
G1 X147.633 Y150.247 E.01236
G1 X184.753 Y187.367 E1.5652
G1 X184.365 Y187.513 E.01236
G1 X147.487 Y150.635 E1.555
G2 X147.361 Y151.043 I3.059 J1.164 E.01274
G1 X183.957 Y187.639 E1.54308
G1 X183.547 Y187.763 E.01276
G1 X147.237 Y151.453 E1.53104
G1 X147.113 Y151.863 E.01276
G1 X183.137 Y187.887 E1.51901
G1 X182.728 Y188.011 E.01276
G1 X146.989 Y152.272 E1.50698
G2 X146.876 Y152.693 I3.155 J1.069 E.01301
G1 X182.307 Y188.124 E1.49397
G1 X181.874 Y188.225 E.01325
G1 X146.775 Y153.126 E1.47998
G1 X146.674 Y153.559 E.01325
G1 X181.441 Y188.326 E1.46598
G1 X181.008 Y188.427 E.01325
G1 X146.573 Y153.992 E1.45199
G2 X146.478 Y154.43 I3.302 J.948 E.01339
G1 X180.57 Y188.522 E1.43752
G1 X180.112 Y188.598 E.01385
G1 X146.402 Y154.888 E1.42139
G1 X146.326 Y155.347 E.01385
M73 P90 R3
G1 X179.653 Y188.674 E1.40526
G1 X179.195 Y188.749 E.01385
G1 X146.251 Y155.805 E1.38913
G2 X146.179 Y156.266 I3.494 J.783 E.01394
G1 X178.734 Y188.821 E1.37272
G1 X178.248 Y188.869 E.01456
G1 X146.131 Y156.752 E1.35424
G1 X146.083 Y157.238 E.01456
G1 X177.762 Y188.917 E1.33577
G1 X177.276 Y188.965 E.01456
G1 X146.035 Y157.724 E1.3173
G2 X145.994 Y158.217 I3.737 J.557 E.01476
G1 X176.783 Y189.006 E1.29823
G1 X176.266 Y189.023 E.01542
G1 X145.977 Y158.734 E1.27715
G1 X145.96 Y159.251 E.01542
G1 X175.749 Y189.04 E1.25607
G1 X175.232 Y189.057 E.01542
G1 X145.943 Y159.768 E1.23499
G2 X145.946 Y160.304 I4.087 J.25 E.016
G1 X174.696 Y189.054 E1.21228
G1 X174.144 Y189.036 E.01646
G1 X145.964 Y160.856 E1.18825
G1 X145.982 Y161.408 E.01646
G1 X173.592 Y189.018 E1.16422
G3 X173.036 Y188.996 I-.107 J-4.264 E.01661
G1 X146.004 Y161.964 E1.13983
G1 X146.063 Y162.556 E.01774
G1 X172.444 Y188.937 E1.1124
G1 X171.852 Y188.879 E.01774
G1 X146.121 Y163.148 E1.08498
G1 X146.179 Y163.74 E.01774
G1 X171.26 Y188.821 E1.05755
G3 X170.625 Y188.719 I.456 J-4.898 E.01919
G1 X146.281 Y164.375 E1.0265
G1 X146.386 Y165.015 E.01932
G1 X169.985 Y188.614 E.99509
G1 X169.346 Y188.508 E.01932
G1 X146.492 Y165.654 E.96368
G2 X146.652 Y166.349 I5.383 J-.88 E.02128
G1 X168.651 Y188.348 E.92761
G1 X167.955 Y188.185 E.02131
G1 X146.815 Y167.045 E.89141
G2 X146.999 Y167.763 I5.569 J-1.047 E.02212
G1 X167.237 Y188.001 E.85336
G1 X166.471 Y187.768 E.02387
G1 X147.232 Y168.529 E.81125
G1 X147.464 Y169.295 E.02387
G1 X165.705 Y187.536 E.76914
G1 X164.854 Y187.219 E.02706
G1 X147.781 Y170.146 E.71993
G1 X148.103 Y171.002 E.02727
G1 X163.998 Y186.897 E.67025
G1 X163.039 Y186.472 E.03128
G1 X148.528 Y171.961 E.61188
G1 X148.985 Y172.951 E.03252
G1 X162.049 Y186.015 E.55087
G1 X160.902 Y185.402 E.03877
G1 X149.598 Y174.098 E.47667
G2 X150.375 Y175.409 I10.388 J-5.273 E.04549
G1 X159.591 Y184.625 E.38859
G3 X157.954 Y183.522 I7.595 J-13.037 E.05889
G1 X151.478 Y177.046 E.27308
G1 X151.942 Y177.693 E.02374
G1 X153.149 Y179.163 E.05672
G1 X154.429 Y180.531 E.05586
G1 X156.577 Y182.679 E.09057
; CHANGE_LAYER
; Z_HEIGHT: 5.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9537.687
G1 X155.163 Y181.265 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 28/30
; update layer progress
M73 L28
M991 S0 P27 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z5.8 I.832 J.889 P1  F30000
G1 X170.233 Y167.16 Z5.8
G1 Z5.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X170.226 Y167.145 E.00053
G3 X174.937 Y151.4 I4.784 J-7.146 E.7033
G3 X176.678 Y151.563 I.085 J8.469 E.05636
G3 X170.703 Y167.443 I-1.669 J8.436 E.95976
G1 X170.284 Y167.191 E.01572
; COOLING_NODE: 0
M204 S250
G1 X170.44 Y166.827 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.443 Y166.82 E.00023
G3 X174.949 Y151.792 I4.565 J-6.821 E.62214
G3 X176.602 Y151.948 I.068 J8.1 E.04952
G3 X170.899 Y167.104 I-1.594 J8.051 E.84843
G1 X170.491 Y166.858 E.01417
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.443 Y166.82 E-.02337
G1 X170.002 Y166.514 E-.20404
G1 X169.587 Y166.173 E-.20418
G1 X169.195 Y165.805 E-.20416
G1 X168.971 Y165.567 E-.12425
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.395 Y161.693 Z6 F30000
G1 X146.604 Y152.391 Z6
G1 Z5.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.162 Y150.551 E.06185
G1 X147.84 Y148.75 E.06187
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.779 Y130.661 E.05723
G1 X178.837 Y130.854 E.06647
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.449 Y132.162 E.06185
G1 X186.25 Y132.84 E.06187
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06187
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.838 E.06186
G1 X163.75 Y187.16 E.06187
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.144 Y154.407 E.05724
G1 X146.591 Y152.45 E.06455
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.828 Y139.05 E.05339
G1 X155.358 Y137.603 E.06272
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.792 Y130.269 E.0534
G1 X178.888 Y130.465 E.06272
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.757 Y154.343 E.0534
G1 X146.212 Y152.348 E.06094
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.832 Y143.96 Z6 F30000
G1 X152.321 Y141.577 Z6
G1 Z5.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42037
G1 F9537.687
M204 S4000
G1 X154.469 Y139.43 E.09054
G1 X155.837 Y138.148 E.05589
G1 X157.307 Y136.942 E.05671
G1 X157.954 Y136.478 E.02374
G1 X151.478 Y142.954 E.27307
G2 X150.375 Y144.591 I11.933 J9.231 E.05889
G1 X159.591 Y135.375 E.38859
G3 X160.902 Y134.598 I6.586 J9.613 E.04549
G1 X149.598 Y145.902 E.47667
G1 X148.985 Y147.049 E.03877
G1 X162.049 Y133.985 E.55087
G1 X163.039 Y133.528 E.03252
G1 X148.528 Y148.039 E.61188
G1 X148.103 Y148.998 E.03128
G1 X163.998 Y133.103 E.67025
G1 X164.854 Y132.781 E.02727
G1 X147.781 Y149.854 E.71993
G1 X147.464 Y150.705 E.02706
G1 X165.705 Y132.464 E.76914
G1 X166.471 Y132.232 E.02387
G1 X147.232 Y151.471 E.81125
G1 X146.999 Y152.237 E.02387
G1 X167.237 Y131.999 E.85336
G3 X167.955 Y131.815 I1.765 J5.387 E.02212
G1 X146.818 Y152.952 E.89128
G1 X146.66 Y153.644 E.02116
G1 X168.651 Y131.652 E.9273
G3 X169.346 Y131.492 I1.577 J5.229 E.02128
G1 X146.502 Y154.336 E.96325
G2 X146.386 Y154.985 I5.266 J1.274 E.01969
G1 X169.985 Y131.386 E.99509
G1 X170.625 Y131.281 E.01932
G1 X146.281 Y155.625 E1.0265
G2 X146.179 Y156.26 I4.79 J1.09 E.01919
G1 X171.26 Y131.179 E1.05755
G1 X171.852 Y131.121 E.01774
G1 X146.121 Y156.852 E1.08498
G1 X146.063 Y157.444 E.01774
G1 X172.444 Y131.063 E1.1124
G1 X173.036 Y131.004 E.01774
G1 X146.004 Y158.036 E1.13983
G2 X145.982 Y158.592 I4.235 J.449 E.01661
G1 X173.592 Y130.982 E1.16422
G1 X174.144 Y130.964 E.01646
G1 X145.964 Y159.144 E1.18825
G1 X145.946 Y159.696 E.01646
G1 X174.696 Y130.946 E1.21228
G3 X175.232 Y130.943 I.286 J4.089 E.016
G1 X145.943 Y160.232 E1.23499
G1 X145.96 Y160.749 E.01542
M73 P91 R3
G1 X175.749 Y130.96 E1.25607
G1 X176.266 Y130.977 E.01542
G1 X145.977 Y161.266 E1.27715
G1 X145.994 Y161.783 E.01542
G1 X176.781 Y130.996 E1.29817
G1 X177.269 Y131.041 E.01461
G1 X146.035 Y162.276 E1.31703
G1 X146.083 Y162.762 E.01456
G1 X177.757 Y131.087 E1.33559
G1 X178.245 Y131.133 E.01461
G1 X146.131 Y163.248 E1.35414
G1 X146.179 Y163.734 E.01456
G1 X178.733 Y131.179 E1.3727
G3 X179.195 Y131.251 I-.281 J3.324 E.01395
G1 X146.251 Y164.195 E1.38913
G1 X146.326 Y164.653 E.01385
G1 X179.653 Y131.326 E1.40526
G1 X180.112 Y131.402 E.01385
G1 X146.402 Y165.111 E1.42139
G1 X146.478 Y165.57 E.01385
G1 X180.57 Y131.478 E1.43752
G3 X181.008 Y131.573 I-.508 J3.392 E.01339
G1 X146.573 Y166.008 E1.45199
G1 X146.674 Y166.441 E.01325
G1 X181.441 Y131.674 E1.46598
G1 X181.874 Y131.775 E.01325
G1 X146.775 Y166.874 E1.47998
G1 X146.876 Y167.307 E.01325
G1 X182.307 Y131.876 E1.49397
G3 X182.728 Y131.988 I-.648 J3.266 E.01301
G1 X146.989 Y167.728 E1.50698
G1 X147.113 Y168.137 E.01276
G1 X183.137 Y132.113 E1.51901
G1 X183.547 Y132.237 E.01276
G1 X147.237 Y168.547 E1.53104
G1 X147.361 Y168.956 E.01276
G1 X183.957 Y132.361 E1.54308
G3 X184.365 Y132.487 I-.75 J3.166 E.01274
M73 P91 R2
G1 X147.487 Y169.365 E1.555
G1 X147.633 Y169.753 E.01236
G1 X184.753 Y132.633 E1.5652
G1 X185.14 Y132.779 E.01236
G1 X147.779 Y170.14 E1.5754
G1 X147.925 Y170.528 E.01236
G1 X185.528 Y132.925 E1.5856
G1 X185.916 Y133.071 E.01236
G1 X148.071 Y170.916 E1.59579
G2 X148.226 Y171.294 I2.963 J-.997 E.0122
G1 X186.294 Y133.226 E1.60518
G1 X186.662 Y133.393 E.01202
G1 X148.393 Y171.662 E1.61365
G1 X148.559 Y172.029 E.01202
G1 X187.029 Y133.559 E1.62213
G1 X187.396 Y133.725 E.01202
G1 X148.725 Y172.396 E1.6306
G1 X148.892 Y172.764 E.01202
G1 X187.764 Y133.892 E1.63907
G3 X188.116 Y134.073 I-1.205 J2.78 E.01183
G1 X148.948 Y173.242 E1.65159
M204 S10000
G1 X193.429 Y182.674 F30000
G1 F9537.687
M204 S4000
G1 X195.554 Y180.548 E.08962
G1 X196.852 Y179.163 E.05658
G1 X198.058 Y177.693 E.05672
G1 X198.519 Y177.05 E.0236
G1 X192.05 Y183.519 E.2728
G3 X190.412 Y184.623 I-9.24 J-11.941 E.05893
G1 X199.623 Y175.412 E.3884
G2 X200.401 Y174.1 I-9.62 J-6.592 E.04551
G1 X189.1 Y185.401 E.47652
G1 X187.953 Y186.014 E.03877
G1 X201.014 Y172.953 E.55072
G1 X201.471 Y171.963 E.03253
G1 X186.963 Y186.471 E.61176
G1 X186.003 Y186.897 E.03129
G1 X201.897 Y171.003 E.67015
G1 X202.219 Y170.147 E.02727
G1 X185.147 Y187.219 E.71983
G1 X184.297 Y187.536 E.02706
G1 X202.536 Y169.297 E.76905
G1 X202.768 Y168.531 E.02387
G1 X183.531 Y187.768 E.81116
G1 X182.764 Y188 E.02387
G1 X203 Y167.764 E.85327
G2 X203.185 Y167.046 I-5.388 J-1.767 E.02213
G1 X182.046 Y188.185 E.89134
G1 X181.35 Y188.347 E.02131
G1 X203.347 Y166.35 E.92753
G2 X203.508 Y165.655 I-5.212 J-1.574 E.02128
G1 X180.655 Y188.508 E.96362
G1 X180.016 Y188.614 E.01932
G1 X203.614 Y165.016 E.99503
G1 X203.719 Y164.377 E.01932
G1 X179.377 Y188.719 E1.02644
G3 X178.741 Y188.821 I-1.091 J-4.794 E.01919
G1 X203.821 Y163.741 E1.0575
G1 X203.879 Y163.149 E.01774
G1 X178.149 Y188.879 E1.08492
G1 X177.557 Y188.937 E.01774
G1 X203.937 Y162.557 E1.11235
G1 X203.996 Y161.965 E.01774
G1 X176.965 Y188.996 E1.13977
G3 X176.409 Y189.018 I-.45 J-4.241 E.01661
G1 X204.018 Y161.409 E1.16417
G1 X204.036 Y160.857 E.01646
G1 X175.857 Y189.036 E1.1882
G1 X175.305 Y189.054 E.01646
G1 X204.054 Y160.305 E1.21224
G2 X204.057 Y159.769 I-4.088 J-.287 E.016
G1 X174.769 Y189.057 E1.23495
G1 X174.252 Y189.04 E.01542
G1 X204.04 Y159.252 E1.25603
G1 X204.023 Y158.735 E.01542
G1 X173.735 Y189.023 E1.27711
G1 X173.218 Y189.006 E.01542
G1 X204.006 Y158.218 E1.29819
G2 X203.965 Y157.725 I-3.787 J.065 E.01476
G1 X172.725 Y188.965 E1.31726
G1 X172.239 Y188.917 E.01456
G1 X203.917 Y157.239 E1.33573
G1 X203.869 Y156.753 E.01456
G1 X171.753 Y188.869 E1.35421
G1 X171.267 Y188.822 E.01456
G1 X203.822 Y156.267 E1.37268
G2 X203.749 Y155.806 I-3.562 J.32 E.01394
G1 X170.806 Y188.749 E1.3891
G1 X170.348 Y188.674 E.01385
G1 X203.674 Y155.348 E1.40523
G1 X203.598 Y154.889 E.01385
G1 X169.889 Y188.598 E1.42136
G1 X169.431 Y188.522 E.01385
G1 X203.522 Y154.431 E1.43749
G2 X203.427 Y153.993 I-3.392 J.508 E.01339
G1 X168.993 Y188.427 E1.45196
G1 X168.56 Y188.326 E.01325
M73 P92 R2
G1 X203.326 Y153.56 E1.46595
G1 X203.225 Y153.127 E.01325
G1 X168.127 Y188.225 E1.47995
G1 X167.694 Y188.124 E.01325
G1 X203.124 Y152.694 E1.49395
G2 X203.012 Y152.273 I-3.272 J.649 E.01301
G1 X167.273 Y188.012 E1.50696
G1 X166.863 Y187.888 E.01276
G1 X202.888 Y151.863 E1.51899
G1 X202.763 Y151.454 E.01276
G1 X166.454 Y187.763 E1.53102
G1 X166.044 Y187.639 E.01276
G1 X202.639 Y151.044 E1.54305
G2 X202.514 Y150.636 I-3.176 J.752 E.01275
G1 X165.636 Y187.514 E1.55498
G1 X165.248 Y187.368 E.01236
G1 X202.368 Y150.248 E1.56518
G1 X202.222 Y149.86 E.01236
G1 X164.86 Y187.222 E1.57538
G1 X164.472 Y187.076 E.01236
G1 X202.076 Y149.472 E1.58557
G1 X201.93 Y149.085 E.01236
G1 X164.085 Y186.93 E1.59577
G3 X163.706 Y186.774 I.996 J-2.962 E.0122
G1 X201.774 Y148.706 E1.60517
G1 X201.608 Y148.339 E.01202
G1 X163.339 Y186.608 E1.61364
G1 X162.972 Y186.441 E.01202
G1 X201.441 Y147.972 E1.62211
G1 X201.275 Y147.604 E.01202
G1 X162.604 Y186.275 E1.63058
G1 X162.237 Y186.108 E.01202
G1 X201.108 Y147.237 E1.63905
G2 X200.927 Y146.884 I-2.783 J1.206 E.01183
G1 X161.884 Y185.927 E1.64629
G1 X161.536 Y185.741 E.01176
G1 X179.656 Y167.621 E.76405
G3 X178.545 Y168.199 I-4.803 J-7.887 E.03735
G1 X161.189 Y185.555 E.73187
G1 X160.841 Y185.37 E.01176
G1 X177.695 Y168.515 E.71067
G3 X176.964 Y168.713 I-1.868 J-5.47 E.02259
G1 X160.493 Y185.184 E.69451
G3 X160.162 Y184.98 I1.383 J-2.618 E.01158
G1 X176.306 Y168.836 E.68073
G3 X175.704 Y168.905 I-.825 J-4.556 E.01809
G1 X159.833 Y184.776 E.6692
G1 X159.504 Y184.571 E.01156
G1 X175.144 Y168.931 E.65947
G3 X174.618 Y168.923 I-.203 J-4.013 E.0157
G1 X159.175 Y184.366 E.65117
G3 X158.846 Y184.161 I1.38 J-2.579 E.01156
G1 X174.12 Y168.888 E.64403
G3 X173.645 Y168.828 I.215 J-3.647 E.01427
G1 X158.535 Y183.938 E.63713
G1 X158.224 Y183.716 E.01141
G1 X173.191 Y168.749 E.63109
G1 X172.758 Y168.648 E.01325
G1 X157.913 Y183.493 E.62595
G1 X157.602 Y183.27 E.01141
G1 X172.345 Y168.527 E.62163
G3 X171.945 Y168.393 I.827 J-3.117 E.01257
G1 X157.292 Y183.046 E.61787
G1 X156.999 Y182.806 E.01131
G1 X171.559 Y168.246 E.61393
G1 X171.191 Y168.079 E.01202
G1 X156.706 Y182.565 E.6108
G1 X156.413 Y182.324 E.01131
G1 X170.836 Y167.901 E.60817
G3 X170.491 Y167.713 I1.268 J-2.737 E.01174
G1 X156.12 Y182.084 E.60597
G3 X155.827 Y181.843 I1.701 J-2.361 E.01131
G1 X170.161 Y167.508 E.60442
G3 X169.843 Y167.292 I1.489 J-2.535 E.01147
G1 X155.551 Y181.584 E.60264
G1 X155.276 Y181.326 E.01126
G1 X169.534 Y167.068 E.60122
G1 X169.241 Y166.827 E.01131
G1 X155 Y181.068 E.60048
G1 X154.724 Y180.81 E.01126
G1 X168.957 Y166.577 E.60014
G1 X168.682 Y166.319 E.01126
G1 X154.449 Y180.552 E.60014
G1 X154.191 Y180.276 E.01126
G1 X168.424 Y166.043 E.60014
G3 X168.173 Y165.76 I2.037 J-2.05 E.01128
G1 X153.932 Y180 E.60048
G1 X153.674 Y179.725 E.01126
G1 X167.933 Y165.467 E.60122
G3 X167.708 Y165.157 I2.247 J-1.866 E.0114
G1 X153.416 Y179.449 E.60264
G1 X153.158 Y179.174 E.01126
G1 X167.492 Y164.839 E.60442
G1 X167.288 Y164.51 E.01156
G1 X152.917 Y178.881 E.60596
G1 X152.676 Y178.588 E.01131
G1 X167.099 Y164.165 E.60817
G3 X166.921 Y163.809 I2.622 J-1.538 E.01187
G1 X152.436 Y178.295 E.61079
G1 X152.195 Y178.001 E.01131
G1 X166.754 Y163.442 E.61392
G3 X166.607 Y163.055 I2.883 J-1.319 E.01234
G1 X151.954 Y177.708 E.61786
G3 X151.731 Y177.398 I2.263 J-1.869 E.01141
G1 X166.473 Y162.656 E.62162
G3 X166.352 Y162.243 I3.086 J-1.124 E.01285
G1 X151.508 Y177.087 E.62594
G1 X151.285 Y176.776 E.01141
G1 X166.251 Y161.81 E.63108
G3 X166.172 Y161.356 I3.435 J-.835 E.01376
G1 X151.062 Y176.465 E.63712
G1 X150.839 Y176.154 E.01141
G1 X166.113 Y160.881 E.64401
G3 X166.077 Y160.383 I3.786 J-.523 E.0149
G1 X150.634 Y175.826 E.65115
G1 X150.429 Y175.497 E.01156
G1 X166.069 Y159.857 E.65945
G3 X166.095 Y159.297 I4.289 J-.08 E.01673
G1 X150.225 Y175.167 E.66918
G1 X150.02 Y174.838 E.01156
G1 X166.164 Y158.695 E.6807
G3 X166.287 Y158.038 I5.08 J.614 E.01995
G1 X149.817 Y174.508 E.69448
G1 X149.631 Y174.16 E.01176
G1 X166.484 Y157.307 E.71063
G3 X166.801 Y156.457 I9.335 J2.99 E.02706
G1 X149.445 Y173.812 E.73182
G1 X149.259 Y173.464 E.01176
G1 X167.377 Y155.346 E.76395
G3 X170.347 Y152.377 I7.503 J4.534 E.12645
G1 X188.464 Y134.259 E.76395
G1 X188.812 Y134.445 E.01176
G1 X171.457 Y151.8 E.73182
G3 X172.307 Y151.484 I3.838 J9.012 E.02706
G1 X189.16 Y134.631 E.71063
G1 X189.508 Y134.817 E.01176
G1 X173.038 Y151.287 E.69448
G3 X173.695 Y151.164 I1.271 J4.954 E.01995
G1 X189.838 Y135.02 E.6807
G1 X190.167 Y135.225 E.01156
G1 X174.297 Y151.095 E.66918
G3 X174.857 Y151.069 I.479 J4.258 E.01672
G1 X190.497 Y135.429 E.65945
G1 X190.826 Y135.634 E.01156
G1 X175.382 Y151.078 E.6512
G3 X175.881 Y151.113 I.01 J3.474 E.01493
G1 X191.154 Y135.839 E.64401
G1 X191.465 Y136.062 E.01141
G1 X176.356 Y151.172 E.63712
G3 X176.81 Y151.251 I-.381 J3.514 E.01376
G1 X191.776 Y136.285 E.63108
G1 X192.087 Y136.508 E.01141
G1 X177.243 Y151.352 E.62594
G3 X177.656 Y151.473 I-.711 J3.208 E.01285
G1 X192.398 Y136.731 E.62162
G3 X192.708 Y136.954 I-1.557 J2.484 E.01141
G1 X178.055 Y151.607 E.61786
G3 X178.442 Y151.754 I-.938 J3.044 E.01234
G1 X193.001 Y137.195 E.61392
G1 X193.295 Y137.436 E.01131
G1 X178.809 Y151.921 E.61079
G3 X179.165 Y152.099 I-1.181 J2.798 E.01187
G1 X193.588 Y137.676 E.60817
G1 X193.881 Y137.917 E.01131
G1 X179.51 Y152.288 E.60596
G1 X179.839 Y152.492 E.01156
G1 X194.174 Y138.158 E.60442
G1 X194.449 Y138.416 E.01126
G1 X180.157 Y152.708 E.60264
G3 X180.467 Y152.933 I-1.555 J2.468 E.0114
G1 X194.725 Y138.674 E.60122
G1 X195 Y138.932 E.01126
G1 X180.76 Y153.173 E.60048
G3 X181.043 Y153.424 I-1.766 J2.287 E.01128
G1 X195.276 Y139.191 E.60014
G1 X195.552 Y139.449 E.01126
G1 X181.319 Y153.682 E.60014
G1 X181.577 Y153.957 E.01126
M73 P93 R2
G1 X195.81 Y139.724 E.60014
G1 X196.068 Y140 E.01126
G1 X181.827 Y154.241 E.60048
G1 X182.068 Y154.534 E.01131
G1 X196.326 Y140.276 E.60122
G1 X196.584 Y140.551 E.01126
G1 X182.292 Y154.843 E.60264
G3 X182.508 Y155.161 I-2.318 J1.806 E.01147
G1 X196.843 Y140.827 E.60442
G3 X197.084 Y141.12 I-2.14 J2.01 E.01131
G1 X182.713 Y155.491 E.60597
G3 X182.901 Y155.836 I-2.536 J1.606 E.01174
G1 X197.324 Y141.413 E.60817
G1 X197.565 Y141.706 E.01131
G1 X183.079 Y156.191 E.6108
G1 X183.246 Y156.559 E.01202
G1 X197.806 Y141.999 E.61393
G1 X198.046 Y142.292 E.01131
G1 X183.393 Y156.945 E.61787
G3 X183.527 Y157.345 I-2.98 J1.225 E.01257
G1 X198.27 Y142.602 E.62163
G1 X198.493 Y142.913 E.01141
G1 X183.648 Y157.758 E.62595
G1 X183.749 Y158.191 E.01325
G1 X198.716 Y143.224 E.63109
G1 X198.938 Y143.535 E.01141
G1 X183.828 Y158.645 E.63713
G3 X183.888 Y159.12 I-3.588 J.689 E.01427
G1 X199.161 Y143.846 E.64403
G3 X199.366 Y144.175 I-2.375 J1.71 E.01156
G1 X183.923 Y159.618 E.65117
G3 X183.931 Y160.144 I-4.005 J.323 E.0157
G1 X199.571 Y144.504 E.65947
G1 X199.776 Y144.833 E.01156
G1 X183.905 Y160.704 E.6692
G3 X183.836 Y161.306 I-4.623 J-.222 E.01809
G1 X199.98 Y145.162 E.68073
G3 X200.184 Y145.493 I-2.426 J1.72 E.01158
G1 X183.713 Y161.964 E.69451
G3 X183.515 Y162.695 I-5.664 J-1.136 E.02259
G1 X200.37 Y145.841 E.71067
G1 X200.556 Y146.189 E.01176
G1 X183.199 Y163.545 E.73187
G3 X182.621 Y164.656 I-8.469 J-3.694 E.03735
G1 X200.867 Y146.411 E.76933
; CHANGE_LAYER
; Z_HEIGHT: 5.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9537.687
G1 X199.453 Y147.825 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 29/30
; update layer progress
M73 L29
M991 S0 P28 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z6 I-.672 J-1.015 P1  F30000
G1 X170.234 Y167.161 Z6
G1 Z5.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X170.223 Y167.151 E.00048
G3 X174.438 Y151.416 I4.777 J-7.152 E.68791
G3 X175.562 Y151.416 I.563 J9.005 E.03617
G3 X170.724 Y167.461 I-.562 J8.582 E.99472
G1 X170.285 Y167.192 E.01654
; COOLING_NODE: 0
M204 S250
G1 X170.44 Y166.827 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.441 Y166.824 E.00009
G3 X174.463 Y151.807 I4.559 J-6.826 E.60814
G3 X175.537 Y151.807 I.537 J8.601 E.032
G3 X170.919 Y167.121 I-.537 J8.191 E.87935
G1 X170.491 Y166.859 E.01496
; COOLING_NODE: 0
; WIPE_START
M204 S4000
G1 X170.441 Y166.824 E-.02325
G1 X170.002 Y166.514 E-.20421
G1 X169.587 Y166.173 E-.20419
G1 X169.195 Y165.805 E-.20416
G1 X168.971 Y165.567 E-.1242
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.395 Y161.693 Z6.2 F30000
G1 X146.604 Y152.391 Z6.2
G1 Z5.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S4000
G1 X147.163 Y150.55 E.06186
G1 X147.84 Y148.75 E.06186
G1 X148.634 Y146.998 E.06186
G1 X149.541 Y145.301 E.06186
G1 X150.557 Y143.668 E.06186
G1 X151.677 Y142.104 E.06186
G1 X152.898 Y140.617 E.06187
G1 X154.213 Y139.213 E.06186
G1 X155.617 Y137.898 E.06186
G1 X157.104 Y136.677 E.06187
G1 X158.668 Y135.557 E.06186
G1 X160.301 Y134.541 E.06186
G1 X161.998 Y133.634 E.06186
G1 X163.75 Y132.84 E.06186
G1 X165.551 Y132.162 E.06187
G1 X167.391 Y131.604 E.06185
G1 X169.265 Y131.167 E.06186
G1 X171.163 Y130.854 E.06187
G1 X173.077 Y130.665 E.06185
G1 X175 Y130.602 E.06186
G1 X176.844 Y130.663 E.05934
G1 X178.837 Y130.854 E.06437
G1 X180.735 Y131.167 E.06187
G1 X182.609 Y131.604 E.06186
G1 X184.45 Y132.162 E.06186
G1 X186.25 Y132.84 E.06186
G1 X188.002 Y133.634 E.06186
G1 X189.699 Y134.541 E.06186
G1 X191.332 Y135.557 E.06186
G1 X192.896 Y136.677 E.06186
G1 X194.383 Y137.898 E.06187
G1 X195.787 Y139.213 E.06186
G1 X197.102 Y140.617 E.06186
G1 X198.323 Y142.104 E.06187
G1 X199.443 Y143.668 E.06186
G1 X200.459 Y145.301 E.06186
G1 X201.366 Y146.998 E.06186
G1 X202.16 Y148.75 E.06186
G1 X202.838 Y150.551 E.06187
G1 X203.396 Y152.391 E.06186
G1 X203.833 Y154.265 E.06186
G1 X204.146 Y156.163 E.06187
G1 X204.335 Y158.077 E.06185
G1 X204.398 Y160 E.06186
G1 X204.335 Y161.923 E.06186
G1 X204.146 Y163.837 E.06185
G1 X203.833 Y165.735 E.06187
G1 X203.396 Y167.609 E.06186
G1 X202.838 Y169.449 E.06186
G1 X202.16 Y171.25 E.06186
G1 X201.366 Y173.002 E.06186
G1 X200.459 Y174.699 E.06186
G1 X199.443 Y176.332 E.06186
G1 X198.323 Y177.896 E.06186
G1 X197.102 Y179.383 E.06187
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X195.787 Y180.787 E.06186
G1 X194.383 Y182.102 E.06186
G1 X192.896 Y183.323 E.06187
G1 X191.332 Y184.443 E.06186
G1 X189.699 Y185.459 E.06186
G1 X188.002 Y186.366 E.06186
G1 X186.25 Y187.16 E.06186
G1 X184.449 Y187.838 E.06187
G1 X182.609 Y188.396 E.06186
G1 X180.735 Y188.833 E.06186
G1 X178.837 Y189.146 E.06187
G1 X176.923 Y189.335 E.06185
G1 X175 Y189.398 E.06186
G1 X173.077 Y189.335 E.06186
G1 X171.163 Y189.146 E.06185
G1 X169.265 Y188.833 E.06187
G1 X167.391 Y188.396 E.06186
G1 X165.551 Y187.837 E.06186
G1 X163.75 Y187.16 E.06186
G1 X161.998 Y186.366 E.06186
G1 X160.301 Y185.459 E.06186
G1 X158.668 Y184.443 E.06186
G1 X157.104 Y183.323 E.06186
G1 X155.617 Y182.102 E.06187
G1 X154.213 Y180.787 E.06186
G1 X152.898 Y179.383 E.06186
G1 X151.677 Y177.896 E.06187
G1 X150.557 Y176.332 E.06186
G1 X149.541 Y174.699 E.06186
G1 X148.634 Y173.002 E.06186
G1 X147.84 Y171.25 E.06186
G1 X147.162 Y169.449 E.06187
G1 X146.604 Y167.609 E.06185
G1 X146.167 Y165.735 E.06186
G1 X145.854 Y163.837 E.06187
G1 X145.665 Y161.923 E.06185
G1 X145.602 Y160 E.06186
G1 X145.665 Y158.077 E.06186
G1 X145.854 Y156.163 E.06185
G1 X146.154 Y154.342 E.05934
G1 X146.591 Y152.45 E.06245
; COOLING_NODE: 1
M204 S250
G1 X146.225 Y152.29 F30000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.231 Y143.45 E.05807
G1 X151.366 Y141.865 E.05806
G1 X152.603 Y140.358 E.05807
G1 X153.873 Y139.002 E.05534
G1 X155.358 Y137.603 E.06078
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.188 Y130.783 E.05807
G1 X171.112 Y130.465 E.05807
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.857 Y130.271 E.05535
G1 X178.888 Y130.465 E.06077
G1 X180.812 Y130.783 E.05807
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.55 Y135.231 E.05807
G1 X193.135 Y136.366 E.05806
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05807
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.217 Y165.812 E.05807
G1 X203.775 Y167.71 E.05807
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.769 Y176.55 E.05807
G1 X198.634 Y178.135 E.05806
G1 X197.397 Y179.642 E.05807
G1 X196.065 Y181.065 E.05806
G1 X194.642 Y182.397 E.05806
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05807
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.188 Y189.217 E.05807
G1 X167.29 Y188.775 E.05807
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.45 Y184.769 E.05807
G1 X156.865 Y183.634 E.05806
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.783 Y165.812 E.05807
G1 X145.465 Y163.888 E.05807
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.768 Y154.278 E.05535
G1 X146.212 Y152.348 E.05899
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X151.885 Y144.752 Z6.2 F30000
G1 X161.411 Y134.133 Z6.2
G1 Z5.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42037
G1 F9537.687
M204 S4000
G1 X179.66 Y152.382 E.76947
G2 X178.545 Y151.801 I-4.692 J7.649 E.03749
G1 X161.189 Y134.444 E.73187
G1 X160.841 Y134.63 E.01176
G1 X177.695 Y151.485 E.71067
G2 X176.964 Y151.287 I-1.868 J5.469 E.02259
G1 X160.493 Y134.816 E.69451
G2 X160.162 Y135.02 I1.378 J2.61 E.01158
G1 X176.306 Y151.164 E.68073
G2 X175.704 Y151.095 I-.825 J4.557 E.01809
G1 X159.833 Y135.224 E.6692
G1 X159.504 Y135.429 E.01156
G1 X175.145 Y151.07 E.65953
G2 X174.618 Y151.077 I-.212 J4.231 E.01573
G1 X159.175 Y135.634 E.65117
G2 X158.846 Y135.839 I1.405 J2.618 E.01156
G1 X174.12 Y151.112 E.64403
G2 X173.645 Y151.172 I.215 J3.645 E.01427
G1 X158.535 Y136.062 E.63713
G1 X158.224 Y136.284 E.01141
G1 X173.191 Y151.251 E.63109
G1 X172.758 Y151.352 E.01325
G1 X157.913 Y136.507 E.62595
G1 X157.602 Y136.73 E.01141
G1 X172.345 Y151.473 E.62163
G2 X171.945 Y151.607 I.827 J3.116 E.01257
G1 X157.292 Y136.954 E.61787
G1 X156.999 Y137.194 E.01131
G1 X171.559 Y151.754 E.61393
G1 X171.192 Y151.921 E.01202
G1 X156.706 Y137.435 E.6108
G1 X156.413 Y137.676 E.01131
G1 X170.836 Y152.099 E.60817
G2 X170.491 Y152.287 I1.263 J2.728 E.01174
G1 X156.12 Y137.916 E.60597
G2 X155.827 Y138.157 I1.694 J2.352 E.01131
G1 X170.161 Y152.492 E.60442
G2 X169.843 Y152.708 I1.489 J2.534 E.01147
G1 X155.551 Y138.416 E.60264
G1 X155.276 Y138.674 E.01126
G1 X169.534 Y152.932 E.60122
G1 X169.241 Y153.173 E.01131
G1 X155 Y138.932 E.60048
G1 X154.724 Y139.19 E.01126
G1 X168.957 Y153.423 E.60014
G1 X168.682 Y153.681 E.01126
G1 X154.449 Y139.448 E.60014
G1 X154.191 Y139.724 E.01126
G1 X168.424 Y153.957 E.60014
G2 X168.173 Y154.24 I2.034 J2.047 E.01128
G1 X153.932 Y140 E.60048
G1 X153.674 Y140.275 E.01126
G1 X167.933 Y154.533 E.60122
G2 X167.708 Y154.843 I2.242 J1.863 E.0114
G1 X153.416 Y140.551 E.60264
G1 X153.158 Y140.826 E.01126
G1 X167.493 Y155.161 E.60443
G1 X167.289 Y155.491 E.01156
G1 X152.917 Y141.119 E.60601
G1 X152.676 Y141.412 E.01131
G1 X167.099 Y155.835 E.60817
G2 X166.921 Y156.191 I2.62 J1.537 E.01187
G1 X152.436 Y141.705 E.61079
G1 X152.195 Y141.998 E.01131
G1 X166.754 Y156.558 E.61392
G2 X166.607 Y156.945 I2.88 J1.318 E.01234
G1 X151.954 Y142.292 E.61786
G2 X151.731 Y142.602 I2.25 J1.86 E.01141
G1 X166.473 Y157.344 E.62162
G2 X166.352 Y157.757 I3.084 J1.123 E.01285
G1 X151.508 Y142.913 E.62594
G1 X151.285 Y143.224 E.01141
G1 X166.251 Y158.19 E.63108
G2 X166.172 Y158.644 I3.431 J.835 E.01376
G1 X151.062 Y143.535 E.63712
G1 X150.839 Y143.846 E.01141
G1 X166.113 Y159.119 E.64401
G2 X166.077 Y159.617 I3.786 J.523 E.0149
G1 X150.634 Y144.174 E.65115
G1 X150.429 Y144.503 E.01156
G1 X166.069 Y160.143 E.65945
G2 X166.095 Y160.703 I4.288 J.08 E.01673
G1 X150.225 Y144.833 E.66918
G1 X150.02 Y145.162 E.01156
G1 X166.164 Y161.305 E.6807
G2 X166.287 Y161.962 I5.079 J-.613 E.01995
G1 X149.817 Y145.492 E.69448
G1 X149.631 Y145.84 E.01176
G1 X166.484 Y162.693 E.71063
G2 X166.801 Y163.543 I9.329 J-2.988 E.02706
G1 X149.445 Y146.188 E.73182
G1 X149.259 Y146.536 E.01176
G1 X167.377 Y164.653 E.76395
G2 X170.343 Y167.62 I7.491 J-4.525 E.12632
G1 X188.464 Y185.741 E.76409
G1 X188.812 Y185.555 E.01176
G1 X171.457 Y168.2 E.73182
G2 X172.307 Y168.516 I3.84 J-9.017 E.02706
G1 X189.16 Y185.369 E.71063
G1 X189.508 Y185.183 E.01176
G1 X173.038 Y168.713 E.69448
G2 X173.695 Y168.836 I1.27 J-4.954 E.01995
M73 P94 R2
G1 X189.838 Y184.98 E.6807
G1 X190.167 Y184.775 E.01156
G1 X174.297 Y168.905 E.66918
G2 X174.857 Y168.931 I.48 J-4.262 E.01673
G1 X190.497 Y184.571 E.65945
G1 X190.826 Y184.366 E.01156
G1 X175.383 Y168.923 E.65115
G2 X175.881 Y168.887 I-.025 J-3.822 E.0149
G1 X191.154 Y184.161 E.64401
G1 X191.465 Y183.938 E.01141
G1 X176.356 Y168.828 E.63712
G2 X176.81 Y168.749 I-.38 J-3.509 E.01376
G1 X191.776 Y183.715 E.63108
G1 X192.087 Y183.492 E.01141
G1 X177.243 Y168.648 E.62594
G2 X177.656 Y168.527 I-.712 J-3.211 E.01285
G1 X192.398 Y183.269 E.62162
G2 X192.708 Y183.046 I-1.559 J-2.487 E.01141
G1 X178.055 Y168.393 E.61786
G2 X178.442 Y168.245 I-.927 J-3.014 E.01234
G1 X193.002 Y182.805 E.61392
G1 X193.295 Y182.564 E.01131
G1 X178.809 Y168.079 E.61079
G2 X179.165 Y167.901 I-1.182 J-2.8 E.01187
G1 X193.588 Y182.324 E.60817
G1 X193.881 Y182.083 E.01131
G1 X179.51 Y167.712 E.60596
G1 X179.839 Y167.508 E.01156
G1 X194.174 Y181.842 E.60442
G1 X194.449 Y181.584 E.01126
G1 X180.157 Y167.292 E.60264
G2 X180.467 Y167.067 I-1.554 J-2.468 E.0114
G1 X194.725 Y181.326 E.60122
G1 X195 Y181.068 E.01126
G1 X180.76 Y166.827 E.60048
G2 X181.043 Y166.576 I-1.766 J-2.286 E.01128
G1 X195.276 Y180.809 E.60014
G1 X195.552 Y180.551 E.01126
G1 X181.319 Y166.318 E.60014
G1 X181.577 Y166.043 E.01126
G1 X195.81 Y180.276 E.60014
G1 X196.068 Y180 E.01126
G1 X181.827 Y165.759 E.60048
G1 X182.068 Y165.466 E.01131
G1 X196.326 Y179.724 E.60122
G1 X196.584 Y179.449 E.01126
G1 X182.292 Y165.157 E.60264
G2 X182.508 Y164.838 I-2.211 J-1.73 E.01147
M73 P94 R1
G1 X196.843 Y179.173 E.60444
G2 X197.084 Y178.88 I-2.113 J-1.988 E.01131
G1 X182.712 Y164.508 E.60601
G2 X182.901 Y164.164 I-2.669 J-1.693 E.01173
G1 X197.324 Y178.587 E.60817
G1 X197.565 Y178.294 E.01131
G1 X183.079 Y163.808 E.6108
G1 X183.246 Y163.441 E.01202
G1 X197.806 Y178.001 E.61393
G1 X198.046 Y177.708 E.01131
G1 X183.393 Y163.055 E.61787
G2 X183.527 Y162.655 I-2.98 J-1.226 E.01257
G1 X198.27 Y177.398 E.62163
G1 X198.493 Y177.087 E.01141
G1 X183.648 Y162.242 E.62595
G1 X183.749 Y161.809 E.01325
G1 X198.716 Y176.776 E.63109
G1 X198.938 Y176.465 E.01141
G1 X183.828 Y161.355 E.63713
G2 X183.888 Y160.88 I-3.588 J-.689 E.01427
G1 X199.161 Y176.154 E.64403
G2 X199.366 Y175.825 I-2.413 J-1.734 E.01156
G1 X183.923 Y160.382 E.65117
G2 X183.931 Y159.856 I-4.005 J-.323 E.0157
G1 X199.571 Y175.496 E.65947
G1 X199.776 Y175.167 E.01156
G1 X183.905 Y159.296 E.6692
G2 X183.836 Y158.694 I-4.623 J.222 E.01809
G1 X199.98 Y174.838 E.68073
G2 X200.184 Y174.507 I-2.406 J-1.708 E.01158
G1 X183.713 Y158.036 E.69451
G2 X183.515 Y157.305 I-5.666 J1.137 E.02259
G1 X200.37 Y174.159 E.71067
G1 X200.556 Y173.811 E.01176
G1 X183.199 Y156.455 E.73187
G2 X182.621 Y155.344 I-8.467 J3.693 E.03735
G1 X200.741 Y173.464 E.76405
G1 X200.927 Y173.116 E.01176
G1 X161.884 Y134.073 E1.64629
G3 X162.237 Y133.892 I1.558 J2.602 E.01183
G1 X201.108 Y172.763 E1.63905
G1 X201.275 Y172.396 E.01202
G1 X162.604 Y133.725 E1.63058
G1 X162.972 Y133.559 E.01202
G1 X201.441 Y172.028 E1.62211
G1 X201.608 Y171.661 E.01202
G1 X163.339 Y133.392 E1.61364
G1 X163.706 Y133.226 E.01202
G1 X201.774 Y171.294 E1.60517
G2 X201.93 Y170.915 I-2.809 J-1.376 E.0122
G1 X164.085 Y133.07 E1.59577
G1 X164.473 Y132.924 E.01236
G1 X202.076 Y170.527 E1.58557
G1 X202.222 Y170.14 E.01236
G1 X164.86 Y132.778 E1.57538
G1 X165.248 Y132.632 E.01236
G1 X202.368 Y169.752 E1.56518
G1 X202.514 Y169.364 E.01236
G1 X165.636 Y132.486 E1.55498
G3 X166.044 Y132.361 I1.158 J3.04 E.01275
G1 X202.639 Y168.956 E1.54305
G1 X202.763 Y168.546 E.01276
G1 X166.454 Y132.237 E1.53102
G1 X166.863 Y132.112 E.01276
G1 X202.888 Y168.137 E1.51899
G1 X203.012 Y167.727 E.01276
G1 X167.273 Y131.988 E1.50696
G3 X167.694 Y131.876 I1.069 J3.155 E.01301
G1 X203.124 Y167.306 E1.49395
G1 X203.225 Y166.873 E.01325
G1 X168.127 Y131.775 E1.47995
G1 X168.56 Y131.674 E.01325
G1 X203.326 Y166.44 E1.46595
G1 X203.427 Y166.007 E.01325
G1 X168.993 Y131.573 E1.45196
G3 X169.431 Y131.478 I.945 J3.293 E.01339
G1 X203.522 Y165.569 E1.43749
G1 X203.598 Y165.111 E.01385
G1 X169.889 Y131.402 E1.42136
G1 X170.348 Y131.326 E.01385
G1 X203.674 Y164.652 E1.40523
G1 X203.749 Y164.194 E.01385
G1 X170.806 Y131.251 E1.3891
G3 X171.267 Y131.178 I.78 J3.477 E.01394
G1 X203.822 Y163.733 E1.37268
G1 X203.869 Y163.247 E.01456
G1 X171.753 Y131.131 E1.35421
G1 X172.239 Y131.083 E.01456
G1 X203.917 Y162.761 E1.33573
G1 X203.965 Y162.275 E.01456
G1 X172.725 Y131.035 E1.31726
G3 X173.218 Y130.994 I.557 J3.74 E.01476
G1 X204.006 Y161.782 E1.29819
G1 X204.023 Y161.265 E.01542
G1 X173.735 Y130.977 E1.27711
G1 X174.252 Y130.96 E.01542
G1 X204.04 Y160.748 E1.25603
G1 X204.057 Y160.231 E.01542
G1 X174.769 Y130.943 E1.23495
G3 X175.305 Y130.946 I.25 J4.086 E.016
G1 X204.054 Y159.695 E1.21223
G1 X204.036 Y159.143 E.01646
G1 X175.857 Y130.964 E1.1882
G1 X176.409 Y130.982 E.01646
G1 X204.018 Y158.591 E1.16417
G2 X203.996 Y158.035 I-4.248 J-.107 E.01661
G1 X176.97 Y131.01 E1.13955
G1 X177.561 Y131.066 E.01768
G1 X203.937 Y157.443 E1.11219
G1 X203.879 Y156.851 E.01774
M73 P95 R1
G1 X178.151 Y131.123 E1.08484
G1 X178.742 Y131.18 E.01768
G1 X203.821 Y156.259 E1.05749
G2 X203.719 Y155.623 I-4.9 J.457 E.01919
G1 X179.377 Y131.281 E1.02643
G1 X180.016 Y131.386 E.01932
G1 X203.614 Y154.984 E.99503
G1 X203.508 Y154.345 E.01932
G1 X180.655 Y131.492 E.96362
G3 X181.35 Y131.653 I-.885 J5.399 E.02128
G1 X203.347 Y153.65 E.92753
G1 X203.185 Y152.954 E.02131
G1 X182.046 Y131.815 E.89134
G3 X182.764 Y132 I-1.048 J5.57 E.02213
G1 X203 Y152.236 E.85327
G1 X202.768 Y151.469 E.02387
G1 X183.531 Y132.232 E.81116
G1 X184.297 Y132.464 E.02387
G1 X202.536 Y150.703 E.76905
G1 X202.219 Y149.853 E.02706
G1 X185.147 Y132.781 E.71983
G1 X186.003 Y133.103 E.02727
G1 X201.897 Y148.997 E.67015
G1 X201.471 Y148.037 E.03129
G1 X186.963 Y133.529 E.61175
G1 X187.953 Y133.986 E.03253
G1 X201.014 Y147.047 E.55071
G1 X200.401 Y145.9 E.03877
G1 X189.1 Y134.599 E.47652
G3 X190.412 Y135.377 I-5.276 J10.391 E.04551
G1 X199.623 Y144.588 E.3884
G2 X198.519 Y142.95 I-13.044 J7.602 E.05893
G1 X192.05 Y136.481 E.27279
G1 X192.693 Y136.942 E.0236
G1 X194.163 Y138.149 E.05672
G1 X195.548 Y139.446 E.05657
G1 X197.674 Y141.571 E.08962
M204 S10000
G1 X188.242 Y186.052 F30000
G1 F9537.687
M204 S4000
G1 X149.073 Y146.884 E1.65159
G2 X148.892 Y147.236 I2.604 J1.56 E.01183
G1 X187.764 Y186.108 E1.63907
G1 X187.396 Y186.275 E.01202
G1 X148.725 Y147.604 E1.6306
G1 X148.559 Y147.971 E.01202
G1 X187.029 Y186.441 E1.62213
G1 X186.662 Y186.607 E.01202
G1 X148.393 Y148.338 E1.61366
G1 X148.226 Y148.706 E.01202
G1 X186.294 Y186.774 E1.60518
G3 X185.916 Y186.929 I-1.376 J-2.808 E.0122
G1 X148.071 Y149.084 E1.59579
G1 X147.925 Y149.472 E.01236
G1 X185.528 Y187.075 E1.5856
G1 X185.14 Y187.221 E.01236
G1 X147.779 Y149.86 E1.5754
G1 X147.633 Y150.247 E.01236
G1 X184.753 Y187.367 E1.5652
G1 X184.365 Y187.513 E.01236
G1 X147.487 Y150.635 E1.555
G2 X147.361 Y151.043 I3.066 J1.166 E.01274
G1 X183.957 Y187.639 E1.54308
G1 X183.547 Y187.763 E.01276
G1 X147.237 Y151.453 E1.53105
G1 X147.113 Y151.863 E.01276
G1 X183.137 Y187.887 E1.51901
G1 X182.728 Y188.011 E.01276
G1 X146.989 Y152.272 E1.50698
G2 X146.876 Y152.694 I3.035 J1.033 E.01302
G1 X182.307 Y188.124 E1.49395
G1 X181.874 Y188.225 E.01325
G1 X146.776 Y153.128 E1.47992
G1 X146.676 Y153.561 E.01327
G1 X181.441 Y188.326 E1.46588
G1 X181.008 Y188.427 E.01325
G1 X146.576 Y153.995 E1.45184
G2 X146.478 Y154.43 I3.418 J1.004 E.01331
G1 X180.57 Y188.522 E1.43752
G1 X180.112 Y188.598 E.01385
G1 X146.402 Y154.888 E1.42139
G1 X146.326 Y155.347 E.01385
G1 X179.653 Y188.674 E1.40526
G1 X179.195 Y188.749 E.01385
G1 X146.251 Y155.805 E1.38913
G2 X146.179 Y156.266 I3.487 J.782 E.01394
G1 X178.734 Y188.821 E1.37272
G1 X178.248 Y188.869 E.01456
G1 X146.131 Y156.752 E1.35424
G1 X146.083 Y157.238 E.01456
G1 X177.762 Y188.917 E1.33577
G1 X177.276 Y188.965 E.01456
G1 X146.035 Y157.724 E1.3173
G2 X145.994 Y158.217 I3.737 J.557 E.01476
G1 X176.783 Y189.006 E1.29823
G1 X176.266 Y189.023 E.01542
G1 X145.977 Y158.734 E1.27715
G1 X145.96 Y159.251 E.01542
G1 X175.749 Y189.04 E1.25607
G1 X175.232 Y189.057 E.01542
G1 X145.943 Y159.768 E1.23499
G2 X145.946 Y160.304 I4.087 J.25 E.016
G1 X174.696 Y189.054 E1.21228
G1 X174.144 Y189.036 E.01646
G1 X145.964 Y160.856 E1.18825
G1 X145.982 Y161.408 E.01646
G1 X173.592 Y189.018 E1.16422
G3 X173.036 Y188.996 I-.107 J-4.264 E.01661
G1 X146.004 Y161.964 E1.13983
G1 X146.063 Y162.556 E.01774
G1 X172.444 Y188.937 E1.1124
G1 X171.852 Y188.879 E.01774
G1 X146.121 Y163.148 E1.08498
G1 X146.179 Y163.74 E.01774
G1 X171.26 Y188.821 E1.05755
G3 X170.625 Y188.719 I.456 J-4.898 E.01919
G1 X146.281 Y164.375 E1.0265
G1 X146.386 Y165.015 E.01932
G1 X169.985 Y188.614 E.99509
G1 X169.346 Y188.508 E.01932
G1 X146.492 Y165.654 E.96368
G2 X146.652 Y166.349 I5.383 J-.88 E.02128
G1 X168.651 Y188.348 E.92761
G1 X167.955 Y188.185 E.02131
G1 X146.815 Y167.045 E.89141
G2 X146.999 Y167.763 I5.569 J-1.047 E.02212
G1 X167.237 Y188.001 E.85336
G1 X166.471 Y187.768 E.02387
G1 X147.232 Y168.529 E.81125
G1 X147.464 Y169.295 E.02387
G1 X165.705 Y187.536 E.76914
G1 X164.854 Y187.219 E.02706
G1 X147.781 Y170.146 E.71993
G1 X148.103 Y171.002 E.02727
G1 X163.998 Y186.897 E.67025
G1 X163.039 Y186.472 E.03128
G1 X148.528 Y171.961 E.61188
G1 X148.985 Y172.951 E.03252
G1 X162.049 Y186.015 E.55087
G1 X160.902 Y185.402 E.03877
G1 X149.598 Y174.098 E.47667
G2 X150.375 Y175.409 I10.388 J-5.273 E.04549
G1 X159.591 Y184.625 E.38859
G3 X157.954 Y183.522 I7.595 J-13.037 E.05889
G1 X151.478 Y177.046 E.27308
G1 X151.942 Y177.693 E.02374
M73 P96 R1
G1 X153.149 Y179.163 E.05672
G1 X154.429 Y180.531 E.05586
G1 X156.577 Y182.679 E.09057
; CHANGE_LAYER
; Z_HEIGHT: 6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9537.687
G1 X155.163 Y181.265 E-.76
; WIPE_END
G1 E-.04 F1800
;======== H2D 20250710 layer_change ========
; layer num/total_layer_count: 30/30
; update layer progress
M73 L30
M991 S0 P29 ;notify layer change

; OBJECT_ID: 378
; COOLING_NODE: 0
M204 S10000
G17
G3 Z6.2 I.836 J.884 P1  F30000
G1 X170.44 Y166.827 Z6.2
G1 Z6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X170.44 Y166.825 E.00006
G3 X174.463 Y151.807 I4.556 J-6.827 E.60835
G1 X174.991 Y151.79 E.01574
G3 X170.903 Y167.113 I.004 J8.208 E.89579
G1 X170.491 Y166.859 E.01443
; COOLING_NODE: 1
; WIPE_START
M204 S4000
G1 X170.44 Y166.825 E-.02336
G1 X170.002 Y166.514 E-.20416
G1 X169.587 Y166.173 E-.20416
G1 X169.195 Y165.805 E-.20422
G1 X168.971 Y165.567 E-.12409
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X162.38 Y161.719 Z6.4 F30000
G1 X146.225 Y152.29 Z6.4
G1 Z6
G1 E.8 F1800
G1 F3600
M204 S2000
G1 X146.791 Y150.424 E.05806
G1 X147.478 Y148.6 E.05807
G1 X148.282 Y146.824 E.05807
G1 X149.201 Y145.105 E.05806
G1 X150.213 Y143.477 E.0571
G1 X151.366 Y141.865 E.05903
G1 X152.603 Y140.358 E.05807
G1 X153.913 Y138.959 E.05709
G1 X155.358 Y137.603 E.05904
G1 X156.865 Y136.366 E.05807
G1 X158.45 Y135.231 E.05806
G1 X160.105 Y134.201 E.05807
G1 X161.824 Y133.282 E.05806
G1 X163.6 Y132.478 E.05807
G1 X165.424 Y131.791 E.05807
G1 X167.29 Y131.225 E.05806
G1 X169.157 Y130.79 E.0571
G1 X171.112 Y130.465 E.05904
G1 X173.052 Y130.274 E.05806
G1 X175 Y130.21 E.05807
G1 X176.916 Y130.273 E.05709
G1 X178.888 Y130.465 E.05904
G1 X180.812 Y130.782 E.05806
G1 X182.71 Y131.225 E.05807
G1 X184.576 Y131.791 E.05806
G1 X186.4 Y132.478 E.05807
G1 X188.176 Y133.282 E.05807
G1 X189.895 Y134.201 E.05806
G1 X191.523 Y135.213 E.0571
G1 X193.135 Y136.366 E.05903
G1 X194.642 Y137.603 E.05807
G1 X196.065 Y138.935 E.05806
G1 X197.397 Y140.358 E.05806
G1 X198.634 Y141.865 E.05807
G1 X199.769 Y143.45 E.05806
G1 X200.799 Y145.105 E.05807
G1 X201.718 Y146.824 E.05806
G1 X202.522 Y148.6 E.05807
G1 X203.209 Y150.424 E.05807
G1 X203.775 Y152.29 E.05806
G1 X204.217 Y154.188 E.05806
G1 X204.535 Y156.112 E.05807
G1 X204.726 Y158.052 E.05806
G1 X204.79 Y160 E.05807
G1 X204.726 Y161.948 E.05807
G1 X204.535 Y163.888 E.05806
G1 X204.223 Y165.78 E.0571
G1 X203.775 Y167.71 E.05904
G1 X203.209 Y169.576 E.05806
G1 X202.522 Y171.4 E.05807
G1 X201.718 Y173.176 E.05807
G1 X200.799 Y174.895 E.05806
G1 X199.787 Y176.523 E.0571
G1 X198.634 Y178.135 E.05903
G1 X197.397 Y179.642 E.05807
;======== H2D 20260731========
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on

M1002 judge_flag timelapse_record_flag
M622 J1
    

    
        M971 S11 C10 O0
        M1004 S5 P1  ; external shutter
    
    
    
M623
; SKIPPABLE_END

G1 X196.065 Y181.065 E.05807
G1 X194.642 Y182.397 E.05807
G1 X193.135 Y183.634 E.05807
G1 X191.55 Y184.769 E.05806
G1 X189.895 Y185.799 E.05807
G1 X188.176 Y186.718 E.05806
G1 X186.4 Y187.522 E.05807
G1 X184.576 Y188.209 E.05807
G1 X182.71 Y188.775 E.05806
G1 X180.812 Y189.217 E.05806
G1 X178.888 Y189.535 E.05807
G1 X176.948 Y189.726 E.05806
G1 X175 Y189.79 E.05807
G1 X173.052 Y189.726 E.05807
G1 X171.112 Y189.535 E.05806
G1 X169.22 Y189.223 E.0571
G1 X167.29 Y188.775 E.05904
G1 X165.424 Y188.209 E.05806
G1 X163.6 Y187.522 E.05807
G1 X161.824 Y186.718 E.05807
G1 X160.105 Y185.799 E.05806
G1 X158.477 Y184.787 E.0571
G1 X156.865 Y183.634 E.05903
G1 X155.358 Y182.397 E.05807
G1 X153.935 Y181.065 E.05806
G1 X152.603 Y179.642 E.05806
G1 X151.366 Y178.135 E.05807
G1 X150.231 Y176.55 E.05806
G1 X149.201 Y174.895 E.05807
G1 X148.282 Y173.176 E.05806
G1 X147.478 Y171.4 E.05807
G1 X146.791 Y169.576 E.05807
G1 X146.225 Y167.71 E.05806
G1 X145.79 Y165.843 E.0571
G1 X145.465 Y163.888 E.05904
G1 X145.274 Y161.948 E.05806
G1 X145.21 Y160 E.05807
G1 X145.274 Y158.052 E.05807
G1 X145.465 Y156.112 E.05806
G1 X145.777 Y154.22 E.0571
G1 X146.212 Y152.348 E.05725
; WIPE_START
M204 S4000
G1 X146.788 Y150.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X153.561 Y153.952 Z6.4 F30000
G1 X198.847 Y177.481 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Top surface
G1 F9000
M204 S2000
G1 X192.478 Y183.85 E.26831
; WIPE_START
M204 S4000
G1 X193.892 Y182.436 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X190.806 Y184.988 Z6.4 F30000
G1 Z6
G1 E.8 F1800
G1 F9000
M204 S2000
G1 X199.988 Y175.806 E.38678
; WIPE_START
M204 S4000
G1 X198.574 Y177.22 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X200.791 Y174.47 Z6.4 F30000
G1 Z6
G1 E.8 F1800
G1 F9000
M204 S2000
G1 X189.47 Y185.791 E.47687
; WIPE_START
M204 S4000
G1 X190.884 Y184.377 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X188.325 Y186.403 Z6.4 F30000
G1 Z6
G1 E.8 F1800
G1 F9000
M204 S2000
G1 X201.403 Y173.325 E.55092
G1 X201.537 Y173.191
G1 X202.014 Y172.18
G1 X201.881 Y172.314
G1 X187.314 Y186.881 E.61363
G1 X187.18 Y187.014
G1 X186.205 Y187.456
G1 X186.339 Y187.322
G1 X202.322 Y171.339 E.67331
G1 X202.456 Y171.205
G1 X202.78 Y170.348
G1 X202.646 Y170.481
G1 X185.481 Y187.646 E.72307
G1 X185.348 Y187.78
G1 X184.493 Y188.102
G1 X184.626 Y187.968
G1 X202.968 Y169.626 E.77265
G1 X203.102 Y169.493
G1 X203.346 Y168.715
G1 X203.213 Y168.849
G1 X183.849 Y188.213 E.81571
G1 X183.715 Y188.346
G1 X182.949 Y188.579
G1 X183.083 Y188.445
G1 X203.445 Y168.083 E.85774
G1 X203.579 Y167.949
G1 X203.779 Y167.215
G1 X203.646 Y167.349
G1 X182.349 Y188.646 E.89713
G1 X182.215 Y188.78
G1 X181.52 Y188.942
G1 X181.653 Y188.808
G1 X203.807 Y166.655 E.93321
G1 X203.94 Y166.521
G1 X204.102 Y165.827
G1 X203.968 Y165.96
G1 X180.958 Y188.97 E.96929
G1 X180.824 Y189.104
G1 X180.17 Y189.225
G1 X180.304 Y189.091
G1 X204.091 Y165.304 E1.00203
G1 X204.225 Y165.17
G1 X204.33 Y164.532
G1 X204.197 Y164.665
G1 X179.665 Y189.197 E1.03337
G1 X179.532 Y189.33
G1 X178.893 Y189.436
G1 X179.026 Y189.302
G1 X204.302 Y164.026 E1.06472
G1 X204.436 Y163.893
G1 X204.506 Y163.289
G1 X204.373 Y163.423
G1 X178.423 Y189.373 E1.09312
G1 X178.289 Y189.506
G1 X177.698 Y189.564
G1 X177.831 Y189.431
G1 X204.431 Y162.831 E1.12049
G1 X204.564 Y162.698
G1 X204.623 Y162.106
G1 X204.489 Y162.24
G1 X177.24 Y189.489 E1.14787
G1 X177.106 Y189.623
G1 X176.534 Y189.661
G1 X176.668 Y189.528
G1 X204.528 Y161.668 E1.1736
G1 X204.661 Y161.534
G1 X204.68 Y160.983
G1 X204.546 Y161.116
G1 X176.116 Y189.546 E1.19758
G1 X175.983 Y189.679
G1 X175.431 Y189.698
G1 X175.565 Y189.564
G1 X204.564 Y160.565 E1.22156
G1 X204.698 Y160.431
G1 X204.716 Y159.88
G1 X204.582 Y160.014
G1 X175.014 Y189.582 E1.24555
G1 X174.88 Y189.716
G1 X174.363 Y189.7
G1 X174.497 Y189.566
G1 X204.566 Y159.497 E1.26666
G1 X204.7 Y159.363
G1 X204.683 Y158.847
G1 X204.549 Y158.98
G1 X173.98 Y189.549 E1.2877
G1 X173.847 Y189.683
G1 X173.33 Y189.666
G1 X173.464 Y189.532
G1 X204.532 Y158.464 E1.30874
G1 X204.666 Y158.33
G1 X204.642 Y157.821
G1 X204.508 Y157.955
G1 X172.955 Y189.508 E1.32918
G1 X172.821 Y189.642
G1 X172.335 Y189.594
G1 X172.469 Y189.46
G1 X204.46 Y157.469 E1.34762
G1 X204.594 Y157.335
G1 X204.546 Y156.85
G1 X204.413 Y156.984
G1 X171.984 Y189.413 E1.36605
G1 X171.85 Y189.546
G1 X171.365 Y189.498
G1 X171.498 Y189.365
G1 X204.365 Y156.498 E1.38449
G1 X204.498 Y156.365
G1 X204.443 Y155.886
G1 X204.31 Y156.02
G1 X171.02 Y189.31 E1.40232
G1 X170.886 Y189.443
G1 X170.429 Y189.368
G1 X170.562 Y189.234
G1 X204.234 Y155.562 E1.41841
G1 X204.368 Y155.429
G1 X204.292 Y154.971
G1 X204.159 Y155.105
G1 X170.105 Y189.159 E1.43451
G1 X169.971 Y189.292
G1 X169.513 Y189.217
G1 X169.647 Y189.083
G1 X204.083 Y154.647 E1.45061
G1 X204.217 Y154.513
G1 X204.139 Y154.058
G1 X204.005 Y154.191
G1 X169.193 Y189.004 E1.46645
G1 X169.059 Y189.137
G1 X168.627 Y189.037
G1 X168.76 Y188.903
G1 X203.904 Y153.759 E1.48043
G1 X204.038 Y153.625
G1 X203.937 Y153.193
G1 X203.804 Y153.327
G1 X168.327 Y188.803 E1.49442
G1 X168.194 Y188.936
G1 X167.761 Y188.836
G1 X167.895 Y188.702
G1 X203.703 Y152.894 E1.50841
G1 X203.836 Y152.76
G1 X203.736 Y152.328
G1 X203.602 Y152.462
G1 X167.462 Y188.602 E1.52239
G1 X167.328 Y188.735
G1 X166.913 Y188.618
G1 X167.046 Y188.484
G1 X203.484 Y152.046 E1.53494
G1 X203.618 Y151.913
G1 X203.494 Y151.503
G1 X203.36 Y151.637
G1 X166.637 Y188.36 E1.54695
G1 X166.503 Y188.494
G1 X166.094 Y188.37
G1 X166.228 Y188.236
G1 X203.236 Y151.228 E1.55895
G1 X203.37 Y151.094
G1 X203.246 Y150.685
G1 X203.112 Y150.819
G1 X165.819 Y188.112 E1.57096
G1 X165.685 Y188.245
G1 X165.28 Y188.117
G1 X165.414 Y187.983
G1 X202.983 Y150.414 E1.5826
G1 X203.117 Y150.28
G1 X202.971 Y149.893
G1 X202.838 Y150.026
G1 X165.026 Y187.838 E1.59278
G1 X164.893 Y187.971
G1 X164.505 Y187.825
G1 X164.639 Y187.692
G1 X202.692 Y149.639 E1.60296
G1 X202.825 Y149.505
G1 X202.68 Y149.118
G1 X202.546 Y149.252
G1 X164.252 Y187.546 E1.61313
G1 X164.118 Y187.68
M73 P97 R1
G1 X163.731 Y187.534
G1 X163.864 Y187.4
G1 X202.4 Y148.864 E1.62331
G1 X202.534 Y148.731
G1 X202.377 Y148.354
G1 X202.244 Y148.487
G1 X163.487 Y187.244 E1.63259
G1 X163.354 Y187.377
G1 X162.987 Y187.211
G1 X163.12 Y187.077
G1 X202.077 Y148.12 E1.64105
G1 X202.211 Y147.987
G1 X202.045 Y147.62
G1 X201.911 Y147.753
G1 X162.753 Y186.911 E1.6495
G1 X162.62 Y187.045
G1 X162.253 Y186.878
G1 X162.386 Y186.745
G1 X201.745 Y147.386 E1.65795
G1 X201.878 Y147.253
G1 X201.712 Y146.886
G1 X201.579 Y147.019
M73 P97 R0
G1 X162.019 Y186.579 E1.66641
G1 X161.886 Y186.712
G1 X161.533 Y186.532
G1 X161.666 Y186.398
G1 X201.398 Y146.666 E1.67368
G1 X201.532 Y146.533
G1 X201.346 Y146.185
G1 X201.213 Y146.319
G1 X161.319 Y186.213 E1.6805
G1 X161.185 Y186.346
G1 X160.838 Y186.16
G1 X160.971 Y186.027
G1 X201.027 Y145.971 E1.68731
G1 X201.16 Y145.838
G1 X200.975 Y145.49
G1 X200.841 Y145.624
G1 X182.329 Y164.136 E.77983
G1 X182.195 Y164.27
G1 X182.683 Y163.248
G1 X182.817 Y163.115
G1 X200.655 Y145.276 E.75143
G1 X200.789 Y145.143
G1 X200.588 Y144.81
G1 X200.454 Y144.944
G1 X183.092 Y162.306 E.73139
G1 X182.958 Y162.44
G1 X183.129 Y161.736
G1 X183.262 Y161.603
G1 X200.25 Y144.615 E.7156
G1 X200.384 Y144.482
G1 X200.179 Y144.153
G1 X200.046 Y144.286
G1 X183.358 Y160.974 E.70296
G1 X183.224 Y161.108
G1 X183.271 Y160.528
G1 X183.405 Y160.394
G1 X199.841 Y143.958 E.69237
G1 X199.975 Y143.824
G1 X199.77 Y143.495
G1 X199.637 Y143.629
G1 X183.413 Y159.853 E.68342
G1 X183.279 Y159.986
G1 X183.255 Y159.477
G1 X183.389 Y159.343
G1 X199.418 Y143.315 E.67519
G1 X199.551 Y143.181
G1 X199.329 Y142.87
G1 X199.195 Y143.004
G1 X183.339 Y158.86 E.66793
G1 X183.205 Y158.994
G1 X183.13 Y158.536
G1 X183.263 Y158.402
G1 X198.972 Y142.693 E.66174
G1 X199.106 Y142.56
G1 X198.883 Y142.249
G1 X198.75 Y142.383
G1 X183.165 Y157.968 E.65651
G1 X183.031 Y158.101
G1 X182.915 Y157.684
G1 X183.049 Y157.551
G1 X198.527 Y142.072 E.65202
G1 X198.661 Y141.938
G1 X198.425 Y141.641
G1 X198.291 Y141.775
G1 X182.916 Y157.149 E.64766
G1 X182.783 Y157.283
G1 X182.636 Y156.897
G1 X182.77 Y156.763
G1 X198.051 Y141.482 E.64372
G1 X198.185 Y141.348
G1 X197.944 Y141.055
G1 X197.811 Y141.189
G1 X182.603 Y156.396 E.64061
G1 X182.469 Y156.53
G1 X182.29 Y156.176
G1 X182.424 Y156.042
G1 X197.57 Y140.896 E.63803
G1 X197.704 Y140.762
G1 X197.464 Y140.469
G1 X197.33 Y140.603
G1 X182.233 Y155.7 E.63595
G1 X182.099 Y155.833
G1 X181.895 Y155.505
G1 X182.029 Y155.371
G1 X197.078 Y140.321 E.63397
G1 X197.212 Y140.188
G1 X196.954 Y139.912
G1 X196.821 Y140.046
G1 X181.809 Y155.058 E.63237
G1 X181.675 Y155.191
G1 X181.445 Y154.888
G1 X181.579 Y154.754
G1 X196.563 Y139.77 E.63119
G1 X196.696 Y139.637
G1 X196.438 Y139.361
G1 X196.305 Y139.495
G1 X181.338 Y154.462 E.63046
G1 X181.205 Y154.595
G1 X180.947 Y154.319
G1 X181.081 Y154.186
G1 X196.047 Y139.22 E.63043
G1 X196.18 Y139.086
G1 X195.914 Y138.819
G1 X195.78 Y138.953
G1 X180.814 Y153.919 E.63043
G1 X180.681 Y154.053
G1 X180.405 Y153.795
G1 X180.538 Y153.662
G1 X195.505 Y138.695 E.63046
G1 X195.638 Y138.562
G1 X195.363 Y138.304
G1 X195.229 Y138.437
G1 X180.245 Y153.421 E.6312
G1 X180.112 Y153.555
G1 X179.809 Y153.325
G1 X179.942 Y153.191
G1 X194.954 Y138.179 E.63237
G1 X195.088 Y138.046
G1 X194.812 Y137.788
G1 X194.679 Y137.922
G1 X179.629 Y152.971 E.63397
G1 X179.495 Y153.105
G1 X179.166 Y152.901
G1 X179.3 Y152.767
G1 X194.397 Y137.67 E.63596
G1 X194.531 Y137.536
G1 X194.238 Y137.296
G1 X194.104 Y137.43
G1 X178.958 Y152.576 E.63803
G1 X178.824 Y152.71
G1 X178.47 Y152.53
G1 X178.604 Y152.397
G1 X193.811 Y137.189 E.6406
G1 X193.945 Y137.056
G1 X193.652 Y136.815
G1 X193.518 Y136.949
G1 X178.237 Y152.23 E.64372
G1 X178.103 Y152.364
G1 X177.717 Y152.217
G1 X177.85 Y152.084
G1 X193.225 Y136.709 E.64766
G1 X193.359 Y136.575
G1 X193.061 Y136.339
G1 X192.928 Y136.473
G1 X177.449 Y151.951 E.65202
G1 X177.316 Y152.085
G1 X176.899 Y151.969
G1 X177.032 Y151.835
G1 X192.617 Y136.251 E.65649
G1 X192.751 Y136.117
G1 X192.44 Y135.895
G1 X192.306 Y136.028
G1 X176.597 Y151.737 E.66171
G1 X176.464 Y151.87
G1 X176.006 Y151.795
G1 X176.14 Y151.661
G1 X191.995 Y135.806 E.66789
G1 X192.129 Y135.672
G1 X191.818 Y135.45
G1 X191.684 Y135.584
G1 X175.657 Y151.611 E.67514
G1 X175.523 Y151.745
G1 X175.013 Y151.721
G1 X175.147 Y151.588
G1 X191.371 Y135.363 E.68344
G1 X191.505 Y135.23
G1 X191.176 Y135.025
G1 X191.042 Y135.159
G1 X174.606 Y151.595 E.69238
G1 X174.472 Y151.729
G1 X173.892 Y151.776
G1 X174.026 Y151.642
G1 X190.714 Y134.954 E.70296
G1 X190.847 Y134.821
G1 X190.518 Y134.616
G1 X190.385 Y134.75
G1 X173.397 Y151.738 E.7156
G1 X173.263 Y151.871
G1 X172.56 Y152.042
G1 X172.693 Y151.908
G1 X190.056 Y134.545 E.73139
G1 X190.19 Y134.412
G1 X189.857 Y134.211
G1 X189.723 Y134.345
G1 X171.885 Y152.183 E.75144
G1 X171.751 Y152.317
G1 X170.73 Y152.805
G1 X170.863 Y152.672
G1 X189.376 Y134.159 E.77984
; WIPE_START
M204 S4000
G1 X187.962 Y135.573 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X185.918 Y142.927 Z6.4 F30000
G1 X179.136 Y167.329 Z6.4
G1 Z6
G1 E.8 F1800
G1 F9000
M204 S2000
G1 X160.624 Y185.841 E.77983
G1 X160.49 Y185.975
G1 X160.143 Y185.789
G1 X160.276 Y185.655
G1 X178.115 Y167.817 E.75143
G1 X178.248 Y167.683
G1 X177.44 Y167.958
G1 X177.306 Y168.092
G1 X159.944 Y185.454 E.73139
G1 X159.81 Y185.588
G1 X159.482 Y185.384
G1 X159.615 Y185.25
G1 X176.603 Y168.262 E.7156
G1 X176.737 Y168.129
G1 X176.108 Y168.224
G1 X175.974 Y168.358
G1 X159.286 Y185.046 E.70296
G1 X159.153 Y185.179
G1 X158.824 Y184.975
G1 X158.958 Y184.841
G1 X175.394 Y168.405 E.69237
G1 X175.528 Y168.271
G1 X174.986 Y168.279
G1 X174.853 Y168.413
G1 X158.629 Y184.637 E.68342
G1 X158.495 Y184.77
G1 X158.182 Y184.55
G1 X158.316 Y184.416
G1 X174.343 Y168.389 E.67514
G1 X174.477 Y168.255
G1 X173.994 Y168.205
G1 X173.86 Y168.339
G1 X158.005 Y184.194 E.66789
G1 X157.871 Y184.328
G1 X157.56 Y184.105
G1 X157.694 Y183.972
G1 X173.402 Y168.263 E.66171
G1 X173.536 Y168.13
G1 X173.101 Y168.031
G1 X172.968 Y168.165
G1 X157.383 Y183.749 E.65649
G1 X157.249 Y183.883
G1 X156.938 Y183.661
G1 X157.072 Y183.527
G1 X172.551 Y168.049 E.65202
G1 X172.684 Y167.915
G1 X172.283 Y167.783
G1 X172.149 Y167.916
G1 X156.775 Y183.291 E.64766
G1 X156.641 Y183.425
G1 X156.348 Y183.185
G1 X156.482 Y183.051
G1 X171.763 Y167.77 E.64372
G1 X171.897 Y167.636
G1 X171.53 Y167.47
G1 X171.396 Y167.603
G1 X156.189 Y182.811 E.6406
G1 X156.055 Y182.944
G1 X155.762 Y182.704
G1 X155.896 Y182.57
G1 X171.042 Y167.424 E.63803
G1 X171.176 Y167.29
G1 X170.834 Y167.099
G1 X170.7 Y167.233
G1 X155.603 Y182.33 E.63596
G1 X155.469 Y182.463
G1 X155.188 Y182.212
G1 X155.321 Y182.078
G1 X170.371 Y167.029 E.63397
G1 X170.505 Y166.895
G1 X170.191 Y166.675
G1 X170.058 Y166.809
G1 X155.046 Y181.821 E.63237
G1 X154.912 Y181.954
G1 X154.637 Y181.696
G1 X154.77 Y181.563
G1 X169.754 Y166.579 E.63119
G1 X169.888 Y166.445
G1 X169.595 Y166.205
G1 X169.462 Y166.338
G1 X154.495 Y181.305 E.63046
G1 X154.361 Y181.438
G1 X154.086 Y181.18
G1 X154.22 Y181.047
G1 X169.186 Y166.081 E.63043
G1 X169.319 Y165.947
G1 X169.053 Y165.681
G1 X168.919 Y165.814
G1 X153.953 Y180.78 E.63043
G1 X153.819 Y180.914
G1 X153.562 Y180.638
G1 X153.695 Y180.505
G1 X168.662 Y165.538 E.63046
G1 X168.795 Y165.405
G1 X168.555 Y165.112
G1 X168.421 Y165.245
G1 X153.437 Y180.229 E.63119
G1 X153.304 Y180.363
G1 X153.046 Y180.088
G1 X153.179 Y179.954
G1 X168.191 Y164.942 E.63237
G1 X168.325 Y164.809
G1 X168.105 Y164.495
G1 X167.971 Y164.629
G1 X152.922 Y179.679 E.63397
G1 X152.788 Y179.812
G1 X152.536 Y179.531
G1 X152.67 Y179.397
G1 X167.767 Y164.3 E.63595
G1 X167.901 Y164.166
G1 X167.71 Y163.824
G1 X167.576 Y163.958
G1 X152.43 Y179.104 E.63803
G1 X152.296 Y179.238
G1 X152.056 Y178.945
G1 X152.189 Y178.811
G1 X167.397 Y163.604 E.6406
G1 X167.53 Y163.47
G1 X167.364 Y163.103
G1 X167.23 Y163.237
G1 X151.949 Y178.518 E.64372
G1 X151.815 Y178.652
G1 X151.575 Y178.359
G1 X151.709 Y178.225
M73 P98 R0
G1 X167.084 Y162.85 E.64766
G1 X167.217 Y162.717
G1 X167.085 Y162.316
G1 X166.951 Y162.449
G1 X151.473 Y177.928 E.65203
G1 X151.339 Y178.062
G1 X151.117 Y177.751
G1 X151.25 Y177.617
G1 X166.835 Y162.032 E.65651
G1 X166.969 Y161.899
G1 X166.87 Y161.464
G1 X166.737 Y161.597
G1 X151.028 Y177.307 E.66174
G1 X150.894 Y177.44
G1 X150.671 Y177.13
G1 X150.805 Y176.996
G1 X166.661 Y161.14 E.66793
G1 X166.795 Y161.006
G1 X166.745 Y160.523
G1 X166.611 Y160.657
G1 X150.582 Y176.685 E.67519
G1 X150.449 Y176.819
G1 X150.23 Y176.505
G1 X150.363 Y176.371
G1 X166.587 Y160.147 E.68342
G1 X166.721 Y160.014
G1 X166.729 Y159.472
G1 X166.595 Y159.606
G1 X150.159 Y176.042 E.69238
G1 X150.025 Y176.176
G1 X149.821 Y175.847
G1 X149.954 Y175.713
G1 X166.642 Y159.026 E.70296
G1 X166.776 Y158.892
G1 X166.871 Y158.263
G1 X166.738 Y158.397
G1 X149.75 Y175.385 E.7156
G1 X149.616 Y175.518
G1 X149.412 Y175.19
G1 X149.546 Y175.056
G1 X166.908 Y157.693 E.73139
G1 X167.042 Y157.56
G1 X167.317 Y156.751
G1 X167.183 Y156.885
G1 X149.345 Y174.723 E.75144
G1 X149.211 Y174.857
G1 X149.025 Y174.51
G1 X149.159 Y174.376
G1 X167.672 Y155.863 E.77984
; WIPE_START
M204 S4000
G1 X166.257 Y157.277 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X160.777 Y162.589 Z6.4 F30000
G1 X148.973 Y174.028 Z6.4
G1 Z6
G1 E.8 F1800
G1 F9000
M204 S2000
G1 X189.028 Y133.973 E1.68731
G1 X189.162 Y133.84
G1 X188.815 Y133.654
G1 X188.681 Y133.787
G1 X148.787 Y173.681 E1.6805
G1 X148.654 Y173.815
G1 X148.468 Y173.467
G1 X148.602 Y173.333
G1 X188.333 Y133.602 E1.67368
G1 X188.467 Y133.468
G1 X188.114 Y133.288
G1 X187.98 Y133.421
G1 X148.421 Y172.98 E1.66641
G1 X148.288 Y173.114
G1 X148.122 Y172.747
G1 X148.255 Y172.613
G1 X187.613 Y133.255 E1.65795
G1 X187.747 Y133.122
G1 X187.38 Y132.955
G1 X187.246 Y133.089
G1 X148.089 Y172.246 E1.6495
G1 X147.955 Y172.38
G1 X147.789 Y172.013
G1 X147.923 Y171.879
G1 X186.88 Y132.923 E1.64104
G1 X187.013 Y132.789
G1 X186.646 Y132.623
G1 X186.513 Y132.756
G1 X147.756 Y171.513 E1.63259
G1 X147.623 Y171.646
G1 X147.466 Y171.269
G1 X147.6 Y171.136
G1 X186.136 Y132.6 E1.62331
G1 X186.269 Y132.466
G1 X185.882 Y132.32
G1 X185.748 Y132.454
G1 X147.454 Y170.748 E1.61313
G1 X147.32 Y170.882
G1 X147.175 Y170.495
G1 X147.308 Y170.361
G1 X185.361 Y132.308 E1.60295
G1 X185.495 Y132.175
G1 X185.107 Y132.029
G1 X184.973 Y132.162
G1 X147.162 Y169.973 E1.59278
G1 X147.029 Y170.107
G1 X146.883 Y169.72
G1 X147.017 Y169.586
G1 X184.586 Y132.017 E1.5826
G1 X184.72 Y131.883
G1 X184.315 Y131.754
G1 X184.181 Y131.888
G1 X146.888 Y169.181 E1.57096
G1 X146.754 Y169.315
G1 X146.63 Y168.906
G1 X146.764 Y168.772
G1 X183.772 Y131.764 E1.55895
G1 X183.906 Y131.63
G1 X183.497 Y131.506
G1 X183.363 Y131.64
G1 X146.64 Y168.363 E1.54694
G1 X146.506 Y168.497
G1 X146.382 Y168.087
G1 X146.516 Y167.954
G1 X182.954 Y131.516 E1.53494
G1 X183.087 Y131.382
G1 X182.672 Y131.264
G1 X182.538 Y131.398
G1 X146.398 Y167.538 E1.52239
G1 X146.264 Y167.672
G1 X146.164 Y167.239
G1 X146.297 Y167.106
G1 X182.106 Y131.297 E1.50842
G1 X182.239 Y131.164
G1 X181.807 Y131.063
G1 X181.673 Y131.196
G1 X146.196 Y166.673 E1.49445
G1 X146.063 Y166.807
G1 X145.962 Y166.375
G1 X146.096 Y166.241
G1 X181.241 Y131.096 E1.48049
G1 X181.375 Y130.962
G1 X180.942 Y130.861
G1 X180.809 Y130.995
G1 X145.995 Y165.809 E1.46652
G1 X145.861 Y165.942
G1 X145.785 Y165.485
G1 X145.918 Y165.352
G1 X180.353 Y130.917 E1.45055
G1 X180.487 Y130.783
G1 X180.029 Y130.708
G1 X179.895 Y130.841
G1 X145.842 Y164.894 E1.43447
G1 X145.709 Y165.028
G1 X145.633 Y164.571
G1 X145.766 Y164.437
G1 X179.438 Y130.766 E1.41839
G1 X179.571 Y130.632
G1 X179.114 Y130.557
G1 X178.98 Y130.69
G1 X145.69 Y163.98 E1.40231
G1 X145.557 Y164.113
G1 X145.502 Y163.635
G1 X145.635 Y163.502
G1 X178.501 Y130.636 E1.38447
G1 X178.635 Y130.502
G1 X178.149 Y130.455
G1 X178.015 Y130.588
G1 X145.587 Y163.016 E1.36601
G1 X145.454 Y163.15
G1 X145.406 Y162.664
G1 X145.54 Y162.531
G1 X177.529 Y130.541 E1.34756
G1 X177.663 Y130.407
G1 X177.177 Y130.36
G1 X177.044 Y130.494
G1 X145.492 Y162.045 E1.3291
G1 X145.358 Y162.179
G1 X145.334 Y161.67
G1 X145.468 Y161.536
G1 X176.536 Y130.468 E1.30873
G1 X176.67 Y130.334
G1 X176.153 Y130.317
G1 X176.02 Y130.451
G1 X145.451 Y161.02 E1.28769
G1 X145.317 Y161.153
G1 X145.3 Y160.637
G1 X145.434 Y160.503
G1 X175.503 Y130.434 E1.26666
G1 X175.637 Y130.3
G1 X175.12 Y130.284
G1 X174.986 Y130.418
G1 X145.418 Y159.986 E1.24554
G1 X145.284 Y160.12
G1 X145.302 Y159.568
G1 X145.436 Y159.435
G1 X174.435 Y130.436 E1.22156
G1 X174.568 Y130.302
G1 X174.017 Y130.321
G1 X173.883 Y130.454
G1 X145.454 Y158.883 E1.19757
G1 X145.321 Y159.017
G1 X145.339 Y158.466
G1 X145.472 Y158.332
G1 X173.332 Y130.472 E1.17359
G1 X173.466 Y130.339
G1 X172.894 Y130.377
G1 X172.76 Y130.511
G1 X145.511 Y157.76 E1.14786
G1 X145.377 Y157.894
G1 X145.436 Y157.302
G1 X145.569 Y157.169
G1 X172.169 Y130.569 E1.12049
G1 X172.302 Y130.436
G1 X171.711 Y130.494
G1 X171.577 Y130.627
G1 X145.628 Y156.577 E1.09312
G1 X145.494 Y156.711
G1 X145.564 Y156.107
G1 X145.698 Y155.973
G1 X170.973 Y130.698 E1.06471
G1 X171.107 Y130.565
G1 X170.467 Y130.671
G1 X170.334 Y130.804
G1 X145.803 Y155.335 E1.03332
G1 X145.67 Y155.468
G1 X145.775 Y154.83
G1 X145.909 Y154.696
G1 X169.694 Y130.911 E1.00194
G1 X169.828 Y130.777
G1 X169.176 Y130.896
G1 X169.042 Y131.03
G1 X146.032 Y154.039 E.96928
G1 X145.898 Y154.173
G1 X146.06 Y153.479
G1 X146.193 Y153.345
G1 X168.347 Y131.192 E.9332
G1 X168.48 Y131.058
G1 X167.785 Y131.22
G1 X167.651 Y131.354
G1 X146.354 Y152.651 E.89712
G1 X146.221 Y152.784
G1 X146.421 Y152.05
G1 X146.555 Y151.917
G1 X166.917 Y131.555 E.85773
G1 X167.05 Y131.421
G1 X166.285 Y131.654
G1 X166.151 Y131.787
M73 P99 R0
G1 X146.787 Y151.151 E.8157
G1 X146.654 Y151.285
G1 X146.898 Y150.507
G1 X147.032 Y150.373
G1 X165.373 Y132.032 E.77264
G1 X165.507 Y131.898
G1 X164.652 Y132.22
G1 X164.518 Y132.354
G1 X147.354 Y149.518 E.72306
G1 X147.22 Y149.652
G1 X147.544 Y148.795
G1 X147.678 Y148.661
G1 X163.661 Y132.678 E.6733
G1 X163.795 Y132.544
G1 X162.82 Y132.986
G1 X162.686 Y133.119
G1 X148.119 Y147.686 E.61361
G1 X147.986 Y147.82
G1 X148.463 Y146.809
G1 X148.597 Y146.675
G1 X161.675 Y133.597 E.55091
; WIPE_START
M204 S4000
G1 X160.261 Y135.011 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X160.53 Y134.209 Z6.4 F30000
G1 Z6
G1 E.8 F1800
G1 F9000
M204 S2000
G1 X149.209 Y145.53 E.47686
; WIPE_START
M204 S4000
G1 X150.624 Y144.115 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.012 Y144.193 Z6.4 F30000
G1 Z6
G1 E.8 F1800
G1 F9000
M204 S2000
G1 X159.193 Y135.012 E.38675
; WIPE_START
M204 S4000
G1 X157.779 Y136.426 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X157.522 Y136.15 Z6.4 F30000
G1 Z6
G1 E.8 F1800
G1 F9000
M204 S2000
G1 X151.153 Y142.519 E.26827
; WIPE_START
M204 S4000
G1 X152.568 Y141.105 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X157.296 Y147.097 Z6.4 F30000
G1 X188.263 Y186.342 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.196793
G1 F15000
M204 S4000
G1 X188.063 Y186.49 E.00302
; LINE_WIDTH: 0.152123
G1 X187.956 Y186.564 E.00112
; LINE_WIDTH: 0.109491
G1 X187.849 Y186.638 E.00069
; WIPE_START
G1 X187.956 Y186.564 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X189.409 Y185.729 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.198169
G1 F15000
M204 S4000
G1 X189.258 Y185.841 E.0023
; LINE_WIDTH: 0.154171
G1 X189.108 Y185.953 E.00165
; LINE_WIDTH: 0.110174
G1 X188.957 Y186.064 E.001
; WIPE_START
G1 X189.108 Y185.953 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X190.745 Y184.927 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.203677
G1 F15000
M204 S4000
G1 X190.557 Y185.077 E.00305
; LINE_WIDTH: 0.15747
G1 X190.369 Y185.226 E.00218
; LINE_WIDTH: 0.111264
G1 X190.18 Y185.376 E.0013
; WIPE_START
G1 X190.369 Y185.226 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X192.417 Y183.79 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.209216
G1 F15000
M204 S4000
G1 X192.161 Y184.007 E.00441
; LINE_WIDTH: 0.1608
G1 X191.905 Y184.224 E.00313
; LINE_WIDTH: 0.112383
G1 X191.649 Y184.441 E.00184
; WIPE_START
G1 X191.905 Y184.224 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X197.534 Y179.07 Z6.4 F30000
G1 X197.779 Y178.846 Z6.4
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.108466
G1 F15000
M204 S4000
G1 X197.493 Y179.161 E.0022
; LINE_WIDTH: 0.149075
G1 X197.208 Y179.476 E.00356
; LINE_WIDTH: 0.185194
G1 X196.536 Y180.17 E.01086
; LINE_WIDTH: 0.206262
G3 X194.476 Y182.208 I-32.168 J-30.46 E.0374
; LINE_WIDTH: 0.149071
G1 X194.161 Y182.493 E.00356
; LINE_WIDTH: 0.108474
G1 X193.846 Y182.779 E.0022
; WIPE_START
G1 X194.161 Y182.493 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X199.277 Y176.83 Z6.4 F30000
G1 X199.433 Y176.657 Z6.4
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.11236
G1 F15000
M204 S4000
G1 X199.218 Y176.911 E.00183
; LINE_WIDTH: 0.160748
G1 X199.002 Y177.166 E.0031
; LINE_WIDTH: 0.209136
G1 X198.786 Y177.42 E.00438
; WIPE_START
G1 X199.002 Y177.166 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X200.376 Y175.18 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.111271
G1 F15000
M204 S4000
G1 X200.226 Y175.369 E.0013
; LINE_WIDTH: 0.157486
G1 X200.077 Y175.557 E.00218
; LINE_WIDTH: 0.203701
G1 X199.927 Y175.745 E.00306
; WIPE_START
G1 X200.077 Y175.557 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X201.064 Y173.957 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.110164
G1 F15000
M204 S4000
G1 X200.953 Y174.108 E.001
; LINE_WIDTH: 0.154169
G1 X200.841 Y174.258 E.00165
; LINE_WIDTH: 0.198175
G1 X200.729 Y174.409 E.0023
; WIPE_START
G1 X200.841 Y174.258 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X194.079 Y170.718 Z6.4 F30000
G1 X182.167 Y164.481 Z6.4
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.12482
G1 F15000
M204 S4000
G1 X182.007 Y164.683 E.00166
; LINE_WIDTH: 0.0947665
G1 X181.94 Y164.762 E.00042
; WIPE_START
G1 X182.007 Y164.683 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X179.762 Y166.94 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.0948766
G1 F15000
M204 S4000
G1 X179.682 Y167.008 E.00043
; LINE_WIDTH: 0.121733
G1 X179.544 Y167.117 E.00109
; LINE_WIDTH: 0.161808
G1 X179.407 Y167.226 E.00165
; LINE_WIDTH: 0.192559
G1 X179.27 Y167.335 E.00207
G1 X179.125 Y167.317 E.00173
; WIPE_START
G1 X179.27 Y167.335 E-.34549
G1 X179.407 Y167.226 E-.41451
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X174.16 Y161.683 Z6.4 F30000
G1 X168.06 Y155.238 Z6.4
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.094936
G1 F15000
M204 S4000
G1 X167.992 Y155.319 E.00043
; LINE_WIDTH: 0.121949
G1 X167.864 Y155.479 E.00128
; LINE_WIDTH: 0.162145
G1 X167.737 Y155.64 E.00193
; LINE_WIDTH: 0.202342
G1 X167.609 Y155.801 E.00258
; WIPE_START
G1 X167.737 Y155.64 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X170.518 Y152.833 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.124763
G1 F15000
M204 S4000
G1 X170.317 Y152.993 E.00166
; LINE_WIDTH: 0.0947883
G1 X170.238 Y153.06 E.00042
; WIPE_START
G1 X170.317 Y152.993 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X167.385 Y145.946 Z6.4 F30000
G1 X162.151 Y133.362 Z6.4
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.109464
G1 F15000
M204 S4000
G1 X162.044 Y133.436 E.00068
; LINE_WIDTH: 0.152042
G1 X161.937 Y133.51 E.00112
; LINE_WIDTH: 0.196751
G1 X161.736 Y133.658 E.00303
M204 S10000
G1 X161.042 Y133.936 F30000
; LINE_WIDTH: 0.110174
G1 F15000
M204 S4000
G1 X160.892 Y134.048 E.001
; LINE_WIDTH: 0.154171
G1 X160.741 Y134.159 E.00165
; LINE_WIDTH: 0.198169
G1 X160.591 Y134.271 E.0023
M204 S10000
G1 X159.819 Y134.624 F30000
; LINE_WIDTH: 0.111265
G1 F15000
M204 S4000
G1 X159.631 Y134.774 E.0013
; LINE_WIDTH: 0.157472
G1 X159.443 Y134.923 E.00218
; LINE_WIDTH: 0.203679
G1 X159.254 Y135.073 E.00305
; WIPE_START
G1 X159.443 Y134.923 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X158.35 Y135.559 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.112383
G1 F15000
M204 S4000
G1 X158.094 Y135.776 E.00184
; LINE_WIDTH: 0.160799
G1 X157.838 Y135.994 E.00313
; LINE_WIDTH: 0.209215
G1 X157.582 Y136.211 E.00441
; WIPE_START
G1 X157.838 Y135.994 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X156.153 Y137.222 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.108448
G1 F15000
M204 S4000
G1 X155.839 Y137.507 E.0022
; LINE_WIDTH: 0.148992
G1 X155.524 Y137.792 E.00356
; LINE_WIDTH: 0.184816
G1 X154.819 Y138.476 E.01101
; LINE_WIDTH: 0.205667
G2 X152.792 Y140.524 I30.792 J32.489 E.03705
; LINE_WIDTH: 0.14899
G1 X152.507 Y140.839 E.00356
; LINE_WIDTH: 0.108437
G1 X152.222 Y141.153 E.0022
; WIPE_START
G1 X152.507 Y140.839 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X151.214 Y142.579 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.209148
G1 F15000
M204 S4000
G1 X150.998 Y142.834 E.00438
; LINE_WIDTH: 0.160755
G1 X150.783 Y143.088 E.0031
; LINE_WIDTH: 0.112362
G1 X150.567 Y143.343 E.00183
; WIPE_START
G1 X150.783 Y143.088 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X150.073 Y144.254 Z6.4 F30000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.203689
G1 F15000
M204 S4000
G1 X149.923 Y144.443 E.00305
; LINE_WIDTH: 0.157479
G1 X149.774 Y144.631 E.00218
; LINE_WIDTH: 0.111269
G1 X149.624 Y144.819 E.0013
M204 S10000
G1 X149.271 Y145.591 F30000
; LINE_WIDTH: 0.198175
G1 F15000
M204 S4000
G1 X149.159 Y145.741 E.0023
; LINE_WIDTH: 0.154169
G1 X149.048 Y145.892 E.00165
; LINE_WIDTH: 0.110164
G1 X148.936 Y146.042 E.001
; close powerlost recovery
M1003 S0
; WIPE_START
G1 F15000
G1 X149.048 Y145.892 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z6.4 I1.217 J0 P1  F30000
M106 S0
M106 P2 S0
M981 S0 P20000 ; close spaghetti detector
; FEATURE: Custom
; MACHINE_END_GCODE_START
; filament end gcode 
;========== H2D end ==========
;===== date: 2026/07/29 =====

M1003 S0
M73 P100 R0

G392 S0 ;turn off nozzle clog detect
M993 A0 B0 C0 ; nozzle cam detection not allowed.

M400 ; wait for buffer to clear
G92 E0 ; zero the extruder
M211 Z1

G90
G1 Z6.4 F900 ; lower z a little
M1002 judge_flag timelapse_record_flag
M622 J1
    G150.3
    M400 ; wait all motion done
    M991 S0 P-1 ;end smooth timelapse at safe pos
    M400 S5 ;wait for last picture to be taken
M623  ;end of "timelapse_record_flag"

G90
G1 Z16 F900 ; lower z a little

G90
M141 S0 ; turn off chamber heating
M140 S0 ; turn off bed
M106 S0 ; turn off fan
M106 P2 S0 ; turn off remote part cooling fan
M106 P3 S0 ; turn off chamber cooling fan
M106 P9 S0 ; turn off ext toodhead cooling fan
; pull back filament to AMS
M620 S65535
T65535
G150.2
M621 S65535

M620 S65279
T65279
G150.2
M621 S65279

G150.3

M104 S0 T0; turn off hotend
M104 S0 T1; turn off hotend

M400 ; wait all motion done
M17 S
M17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom

    
        G1 Z103 F600
        G1 Z101
    

M400 P100
M17 R ; restore z current

M220 S100  ; Reset feedrate magnitude
M201.2 K1.0 ; Reset acc magnitude
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 0

M1015.4 S0 K0 ;disable air printing detect

;=====printer finish air purification=========
M622.1 S0
M1002 judge_flag print_finish_air_filt_flag

M622 J1
M1002 gcode_claim_action : 66
M145 P1
M106 P6 S255
M400 S180
M106 P6 S0
M623

M622 J2
M1002 gcode_claim_action : 66
M145 P0
M106 P3 S127
M400 S180
M106 P3 S0
M623
;=====printer finish air purification=========


;=====printer finish  sound=========
M17
M400 S1
M1006 S1
M1006 A53 B10 L99 C53 D10 M99 E53 F10 N99 
M1006 A57 B10 L99 C57 D10 M99 E57 F10 N99 
M1006 A0 B15 L0 C0 D15 M0 E0 F15 N0 
M1006 A53 B10 L99 C53 D10 M99 E53 F10 N99 
M1006 A57 B10 L99 C57 D10 M99 E57 F10 N99 
M1006 A0 B15 L0 C0 D15 M0 E0 F15 N0 
M1006 A48 B10 L99 C48 D10 M99 E48 F10 N99 
M1006 A0 B15 L0 C0 D15 M0 E0 F15 N0 
M1006 A60 B10 L99 C60 D10 M99 E60 F10 N99 
M1006 W
;=====printer finish  sound=========
M400
M18

M141 S0;set chamber_temperature
M73 P100 R0
; EXECUTABLE_BLOCK_END

