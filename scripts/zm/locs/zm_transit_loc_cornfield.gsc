#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_zonemgr;

struct_init()
{
	scripts\zm\replaced\utility::register_perk_struct("", "", (0, 0, 0), (0, 0, 0)); // need this for pap to work
	scripts\zm\replaced\utility::register_perk_struct("specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", (10460, -564, -220), (0, -35, 0));

	zone_respawnpoints = [];
	respawnpoints = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();

	for (i = 0; i < respawnpoints.size; i++)
	{
		if (isDefined(respawnpoints[i].script_noteworthy) && respawnpoints[i].script_noteworthy == "zone_amb_cornfield")
		{
			if (isDefined(respawnpoints[i].script_string) && respawnpoints[i].script_string == "zgrief_cornfield")
			{
				zone_respawnpoints[respawnpoints[i].script_noteworthy] = respawnpoints[i];
			}
		}
		else if (isDefined(respawnpoints[i].script_noteworthy) && respawnpoints[i].script_noteworthy == "zone_cornfield_prototype")
		{
			zone_respawnpoints[respawnpoints[i].script_noteworthy] = respawnpoints[i];
		}
	}

	level.struct_class_names["targetname"]["player_respawn_point"] = [];
	level.struct_class_names["script_noteworthy"]["initial_spawn"] = [];

	zone = "zone_cornfield_prototype";
	scripts\zm\replaced\utility::register_map_spawn_group(zone_respawnpoints[zone].origin, zone, zone_respawnpoints[zone].script_int);

	respawn_array = getstructarray(zone_respawnpoints[zone].target, "targetname");

	foreach (respawn in respawn_array)
	{
		scripts\zm\replaced\utility::register_map_spawn(respawn.origin + (150, -150, 0), respawn.angles + (0, 180, 0), zone, respawn.script_int);
	}

	zone = "zone_amb_cornfield";
	scripts\zm\replaced\utility::register_map_spawn_group(zone_respawnpoints[zone].origin, zone, zone_respawnpoints[zone].script_int);

	scripts\zm\replaced\utility::register_map_spawn((11986, -1858, -132), (0, 80, 0), zone);
	scripts\zm\replaced\utility::register_map_spawn((12158, -61, -141), (0, -85, 0), zone);
	scripts\zm\replaced\utility::register_map_spawn((11366, 20, -193), (0, -5, 0), zone);
	scripts\zm\replaced\utility::register_map_spawn((11199, -1768, -156), (0, -5, 0), zone);
	scripts\zm\replaced\utility::register_map_spawn((10448, 90, -189), (0, -5, 0), zone);
	scripts\zm\replaced\utility::register_map_spawn((10255, -1698, -186), (0, -5, 0), zone);
	scripts\zm\replaced\utility::register_map_spawn((10046, -591, -192), (0, 0, 0), zone);
	scripts\zm\replaced\utility::register_map_spawn((10036, -967, -186), (0, 0, 0), zone);

	structs = getstructarray("game_mode_object", "targetname");

	foreach (struct in structs)
	{
		if (isDefined(struct.script_noteworthy) && struct.script_noteworthy == "cornfield")
		{
			struct.script_string = "zstandard zgrief";
		}
	}

	intermission_cam = spawnStruct();
	intermission_cam.origin = (10266, 470, -90);
	intermission_cam.angles = (0, -90, 0);
	intermission_cam.targetname = "intermission";
	intermission_cam.script_string = "cornfield";
	intermission_cam.speed = 30;
	intermission_cam.target = "intermission_cornfield_end";
	scripts\zm\replaced\utility::add_struct(intermission_cam);

	intermission_cam_end = spawnStruct();
	intermission_cam_end.origin = (10216, -1224, -199);
	intermission_cam_end.angles = (0, -90, 0);
	intermission_cam_end.targetname = "intermission_cornfield_end";
	scripts\zm\replaced\utility::add_struct(intermission_cam_end);
}

precache()
{

}

main()
{
	treasure_chest_init();
	init_barriers();
	disable_zombie_spawn_locations();
	setup_standard_objects("cornfield");
	scripts\zm\locs\loc_common::init();
}

treasure_chest_init()
{
	chest = getstruct("cornfield_chest", "script_noteworthy");
	level.chests = [];
	level.chests[0] = chest;
	maps\mp\zombies\_zm_magicbox::treasure_chest_init("cornfield_chest");
}

init_barriers()
{
	model = spawn("script_model", (10176.5, -14.8391, -221.988), 1);
	model.angles = (0, 35, 0);
	model setmodel("collision_clip_wall_256x256x10");
	model disconnectpaths();

	model = spawn("script_model", (10002.6, -95.4607, -212.275), 1);
	model.angles = (0, 0, 0);
	model setmodel("collision_clip_wall_128x128x10");
	model disconnectpaths();

	model = spawn("script_model", (10173.4, -1761.36, -217.812), 1);
	model.angles = (0, -60, 0);
	model setmodel("collision_clip_wall_128x128x10");
	model disconnectpaths();

	model = spawn("script_model", (10147.5, -1657.67, -217.208), 1);
	model.angles = (0, 88, 0);
	model setmodel("collision_clip_wall_256x256x10");
	model disconnectpaths();

	model = spawn("script_model", (10082.7, -1528.05, -217.288), 1);
	model.angles = (0, -180, 0);
	model setmodel("collision_clip_wall_128x128x10");
	model disconnectpaths();

	model = spawn("script_model", (10159.6, -1104.45, -214.861), 1);
	model.angles = (0, -30, 0);
	model setmodel("collision_clip_64x64x256");
	model disconnectpaths();

	model = spawn("script_model", (10157.4, -1222.83, -217.875), 1);
	model.angles = (0, 10, 0);
	model setmodel("collision_clip_64x64x256");
	model disconnectpaths();

	model = spawn("script_model", (10216.6, -1134.53, -217.261), 1);
	model.angles = (0, -30, 0);
	model setmodel("collision_clip_64x64x256");
	model disconnectpaths();

	model = spawn("script_model", (10147.4, -1152.83, -217.875), 1);
	model.angles = (0, 10, 0);
	model setmodel("collision_clip_64x64x256");
	model disconnectpaths();

	model = spawn("script_model", (10099.6, -1064.45, -214.861), 1);
	model.angles = (0, -30, 0);
	model setmodel("collision_clip_64x64x256");
	model disconnectpaths();

	model = spawn("script_model", (10016.8, -1490.24, -217.875), 1);
	model.angles = (0, -30, 0);
	model setmodel("collision_clip_128x128x128");
	model disconnectpaths();

	model = spawn("script_model", (10443.9, -353.378, -217.748), 1);
	model.angles = (0, -35, 0);
	model setmodel("collision_clip_128x128x128");
	model disconnectpaths();

	model = spawn("script_model", (10393.5, -421.323, -220.142), 1);
	model.angles = (0, -25, 0);
	model setmodel("collision_clip_128x128x128");
	model disconnectpaths();

	model = spawn("script_model", (10334.9, -544.594, -217.922), 1);
	model.angles = (0, -25, 0);
	model setmodel("collision_clip_128x128x128");
	model disconnectpaths();

	origin = (9720, -1090, -212);
	angles = (0, 90, 0);

	model = spawn("script_model", origin, 1);
	model.angles = angles;
	model setmodel("veh_t6_civ_smallwagon_dead");
	model disconnectpaths();

	model = spawn("script_model", origin + (anglesToRight(angles) * 24) + (anglesToUp(angles) * 128), 1);
	model.angles = angles;
	model setmodel("collision_clip_wall_256x256x10");
	model disconnectpaths();

	origin = (9900, -232, -217);
	angles = (0, -90, 0);

	model = spawn("script_model", origin, 1);
	model.angles = angles;
	model setmodel("veh_t6_civ_microbus_dead");
	model disconnectpaths();

	model = spawn("script_model", origin + (anglesToRight(angles) * -48) + (anglesToUp(angles) * 128), 1);
	model.angles = angles;
	model setmodel("collision_clip_wall_256x256x10");
	model disconnectpaths();
}

disable_zombie_spawn_locations()
{
	for (z = 0; z < level.zone_keys.size; z++)
	{
		if (level.zone_keys[z] != "zone_amb_cornfield")
		{
			continue;
		}

		zone = level.zones[level.zone_keys[z]];

		i = 0;

		while (i < zone.spawn_locations.size)
		{
			if (zone.spawn_locations[i].origin[0] <= 9700)
			{
				zone.spawn_locations[i].is_enabled = false;
			}

			i++;
		}
	}
}