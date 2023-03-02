#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_craftables;

#include scripts\zm\replaced\zm_tomb_craftables;
#include scripts\zm\replaced\zm_tomb_dig;

main()
{
	replaceFunc(maps\mp\zm_tomb_main_quest::watch_staff_ammo_reload, scripts\zm\replaced\zm_tomb_main_quest::watch_staff_ammo_reload);
	replaceFunc(maps\mp\zm_tomb_quest_air::air_puzzle_1_run, scripts\zm\replaced\zm_tomb_quest_air::air_puzzle_1_run);
	replaceFunc(maps\mp\zm_tomb_quest_elec::electric_puzzle_1_run, scripts\zm\replaced\zm_tomb_quest_elec::electric_puzzle_1_run);
	replaceFunc(maps\mp\zm_tomb_quest_fire::fire_puzzle_1_run, scripts\zm\replaced\zm_tomb_quest_fire::fire_puzzle_1_run);
	replaceFunc(maps\mp\zm_tomb_quest_ice::ice_puzzle_1_run, scripts\zm\replaced\zm_tomb_quest_ice::ice_puzzle_1_run);
	replaceFunc(maps\mp\zm_tomb_craftables::quadrotor_control_thread, scripts\zm\replaced\zm_tomb_craftables::quadrotor_control_thread);
	replaceFunc(maps\mp\zm_tomb_dig::increment_player_perk_purchase_limit, scripts\zm\replaced\zm_tomb_dig::increment_player_perk_purchase_limit);
	replaceFunc(maps\mp\zm_tomb_dig::dig_disconnect_watch, scripts\zm\replaced\zm_tomb_dig::dig_disconnect_watch);
}

init()
{
	level.map_on_player_connect = ::on_player_connect;
	level.zombie_init_done = ::zombie_init_done;
	level.special_weapon_magicbox_check = ::tomb_special_weapon_magicbox_check;
	level.custom_magic_box_timer_til_despawn = ::custom_magic_box_timer_til_despawn;
	level.zombie_custom_equipment_setup = ::setup_quadrotor_purchase;

	challenges_changes();
	soul_box_changes();

	level thread increase_solo_door_prices();
	level thread remove_shovels_from_map();
	level thread zombie_blood_dig_changes();
	level thread updatecraftables();
}

on_player_connect()
{
	self thread give_shovel();
}

zombie_init_done()
{
	self.allowpain = 0;
	self thread maps\mp\zm_tomb_distance_tracking::escaped_zombies_cleanup_init();
	self setphysparams( 15, 0, 64 );
}

tomb_special_weapon_magicbox_check(weapon)
{
	if ( weapon == "beacon_zm" )
	{
		if ( isDefined( self.beacon_ready ) && self.beacon_ready )
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	if ( isDefined( level.zombie_weapons[ weapon ].shared_ammo_weapon ) )
	{
		if ( self maps\mp\zombies\_zm_weapons::has_weapon_or_upgrade( level.zombie_weapons[ weapon ].shared_ammo_weapon ) )
		{
			return 0;
		}
	}
	return 1;
}

increase_solo_door_prices()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	flag_wait( "initial_blackscreen_passed" );

	if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		a_door_buys = getentarray( "zombie_door", "targetname" );
		array_thread( a_door_buys, ::door_price_increase_for_solo );
		a_debris_buys = getentarray( "zombie_debris", "targetname" );
		array_thread( a_debris_buys, ::door_price_increase_for_solo );
	}
}

door_price_increase_for_solo()
{
	self.zombie_cost += 250;

	if ( self.targetname == "zombie_door" )
	{
		self set_hint_string( self, "default_buy_door", self.zombie_cost );
	}
	else
	{
		self set_hint_string( self, "default_buy_debris", self.zombie_cost );
	}
}

remove_shovels_from_map()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	flag_wait( "initial_blackscreen_passed" );

	stubs = level._unitriggers.trigger_stubs;
	for(i = 0; i < stubs.size; i++)
	{
		stub = stubs[i];
		if(IsDefined(stub.e_shovel))
		{
			stub.e_shovel delete();
			maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( stub );
		}
	}
}

give_shovel()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	self waittill("spawned_player");

	self.dig_vars[ "has_shovel" ] = 1;
	n_player = self getentitynumber() + 1;
	level setclientfield( "shovel_player" + n_player, 1 );
}

challenges_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	level._challenges.a_stats["zc_points_spent"].fp_give_reward = ::reward_random_perk;
}

reward_random_perk( player, s_stat )
{
	if (!isDefined(player.tomb_reward_perk))
	{
		player.tomb_reward_perk = player get_random_perk();
	}
	else if (isDefined( self.perk_purchased ) && self.perk_purchased == player.tomb_reward_perk)
	{
		player.tomb_reward_perk = player get_random_perk();
	}
	else if (self hasperk( player.tomb_reward_perk ) || self maps\mp\zombies\_zm_perks::has_perk_paused( player.tomb_reward_perk ))
	{
		player.tomb_reward_perk = player get_random_perk();
	}

	perk = player.tomb_reward_perk;
	if (!isDefined(perk))
	{
		return 0;
	}

	model = maps\mp\zombies\_zm_perk_random::get_perk_weapon_model(perk);
	if (!isDefined(model))
	{
		return 0;
	}

	m_reward = spawn( "script_model", self.origin );
	m_reward.angles = self.angles + vectorScale( ( 0, 1, 0 ), 180 );
	m_reward setmodel( model );
	m_reward playsound( "zmb_spawn_powerup" );
	m_reward playloopsound( "zmb_spawn_powerup_loop", 0.5 );
	wait_network_frame();
	if ( !maps\mp\zombies\_zm_challenges::reward_rise_and_grab( m_reward, 50, 2, 2, 10 ) )
	{
		return 0;
	}
	if ( player hasperk( perk ) || player maps\mp\zombies\_zm_perks::has_perk_paused( perk ) )
	{
		m_reward thread maps\mp\zm_tomb_challenges::bottle_reject_sink( player );
		return 0;
	}
	m_reward stoploopsound( 0.1 );
	player playsound( "zmb_powerup_grabbed" );
	m_reward thread maps\mp\zombies\_zm_perks::vending_trigger_post_think( player, perk );
	m_reward delete();
	return 1;
}

get_random_perk()
{
	perks = [];
	for (i = 0; i < level._random_perk_machine_perk_list.size; i++)
	{
		perk = level._random_perk_machine_perk_list[ i ];
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			continue;
		}
		else
		{
			if ( !self hasperk( perk ) && !self maps\mp\zombies\_zm_perks::has_perk_paused( perk ) )
			{
				perks[ perks.size ] = perk;
			}
		}
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		random_perk = perks[ 0 ];
		return random_perk;
	}
}

zombie_blood_dig_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	while (1)
	{
		for (i = 0; i < level.a_zombie_blood_entities.size; i++)
		{
			ent = level.a_zombie_blood_entities[i];
			if (IsDefined(ent.e_unique_player))
			{
				if (!isDefined(ent.e_unique_player.initial_zombie_blood_dig))
				{
					ent.e_unique_player.initial_zombie_blood_dig = 0;
				}

				ent.e_unique_player.initial_zombie_blood_dig++;
				if (ent.e_unique_player.initial_zombie_blood_dig <= 2)
				{
					ent setvisibletoplayer(ent.e_unique_player);
				}
				else
				{
					ent thread set_visible_after_rounds(ent.e_unique_player, 3);
				}

				arrayremovevalue(level.a_zombie_blood_entities, ent);
			}
		}

		wait .5;
	}
}

set_visible_after_rounds(player, num)
{
	for (i = 0; i < num; i++)
	{
		level waittill( "end_of_round" );
	}

	self setvisibletoplayer(player);
}

soul_box_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	a_boxes = getentarray( "foot_box", "script_noteworthy" );
	array_thread( a_boxes, ::soul_box_decrease_kill_requirement );
}

soul_box_decrease_kill_requirement()
{
	self endon( "box_finished" );

	while (1)
	{
		self waittill( "soul_absorbed" );

		wait 0.05;

		self.n_souls_absorbed += 10;

		self waittill( "robot_foot_stomp" );
	}
}

custom_magic_box_timer_til_despawn( magic_box )
{
	self endon( "kill_weapon_movement" );
	v_float = anglesToForward( magic_box.angles - vectorScale( ( 0, 1, 0 ), 90 ) ) * 40;
	self moveto( self.origin - ( v_float * 0.25 ), level.magicbox_timeout, level.magicbox_timeout * 0.5 );
	wait level.magicbox_timeout;
	if ( isDefined( self ) )
	{
		self delete();
	}
}

updatecraftables()
{
	flag_wait( "start_zombie_round_logic" );

	wait 1;

	foreach (stub in level._unitriggers.trigger_stubs)
	{
		if(IsDefined(stub.equipname))
		{
			stub.cost = stub scripts\zm\_zm_reimagined::get_equipment_cost();
			stub.trigger_func = ::craftable_place_think;
			stub.prompt_and_visibility_func = ::craftabletrigger_update_prompt;
		}
	}
}

craftable_place_think()
{
    self endon( "kill_trigger" );
    player_crafted = undefined;

    while ( !( isdefined( self.stub.crafted ) && self.stub.crafted ) )
    {
        self waittill( "trigger", player );

        if ( isdefined( level.custom_craftable_validation ) )
        {
            valid = self [[ level.custom_craftable_validation ]]( player );

            if ( !valid )
                continue;
        }

        if ( player != self.parent_player )
            continue;

        if ( isdefined( player.screecher_weapon ) )
            continue;

        if ( !is_player_valid( player ) )
        {
            player thread ignore_triggers( 0.5 );
            continue;
        }

        status = player player_can_craft( self.stub.craftablespawn );

        if ( !status )
        {
            self.stub.hint_string = "";
            self sethintstring( self.stub.hint_string );

            if ( isdefined( self.stub.oncantuse ) )
                self.stub [[ self.stub.oncantuse ]]( player );
        }
        else
        {
            if ( isdefined( self.stub.onbeginuse ) )
                self.stub [[ self.stub.onbeginuse ]]( player );

            result = self craftable_use_hold_think( player );
            team = player.pers["team"];

            if ( isdefined( self.stub.onenduse ) )
                self.stub [[ self.stub.onenduse ]]( team, player, result );

            if ( !result )
                continue;

            if ( isdefined( self.stub.onuse ) )
                self.stub [[ self.stub.onuse ]]( player );

            prompt = player player_craft( self.stub.craftablespawn );
            player_crafted = player;
            self.stub.hint_string = prompt;
            self sethintstring( self.stub.hint_string );
        }
    }

    if ( isdefined( self.stub.craftablestub.onfullycrafted ) )
    {
        b_result = self.stub [[ self.stub.craftablestub.onfullycrafted ]]();

        if ( !b_result )
            return;
    }

    if ( isdefined( player_crafted ) )
    {

    }

    if ( self.stub.persistent == 0 )
    {
        self.stub craftablestub_remove();
        thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.stub );
        return;
    }

    if ( self.stub.persistent == 3 )
    {
        stub_uncraft_craftable( self.stub, 1 );
        return;
    }

    if ( self.stub.persistent == 2 )
    {
        if ( isdefined( player_crafted ) )
            self craftabletrigger_update_prompt( player_crafted );

        if ( !maps\mp\zombies\_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
        {
            self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
            self sethintstring( self.stub.hint_string );
            return;
        }

        if ( isdefined( self.stub.str_taken ) && self.stub.str_taken )
        {
            self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
            self sethintstring( self.stub.hint_string );
            return;
        }

        if ( isdefined( self.stub.model ) )
        {
            self.stub.model notsolid();
            self.stub.model show();
        }

        while ( self.stub.persistent == 2 )
        {
            self waittill( "trigger", player );

            if ( isdefined( player.screecher_weapon ) )
                continue;

            if ( isdefined( level.custom_craftable_validation ) )
            {
                valid = self [[ level.custom_craftable_validation ]]( player );

                if ( !valid )
                    continue;
            }

            if ( !( isdefined( self.stub.crafted ) && self.stub.crafted ) )
            {
                self.stub.hint_string = "";
                self sethintstring( self.stub.hint_string );
                return;
            }

            if ( player != self.parent_player )
                continue;

            if ( !is_player_valid( player ) )
            {
                player thread ignore_triggers( 0.5 );
                continue;
            }

            self.stub.bought = 1;

            if ( isdefined( self.stub.model ) )
                self.stub.model thread model_fly_away( self );

            player maps\mp\zombies\_zm_weapons::weapon_give( self.stub.weaponname );

            if ( isdefined( level.zombie_include_craftables[self.stub.equipname].onbuyweapon ) )
                self [[ level.zombie_include_craftables[self.stub.equipname].onbuyweapon ]]( player );

            if ( !maps\mp\zombies\_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
                self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
            else
                self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX";

            self sethintstring( self.stub.hint_string );
            player track_craftables_pickedup( self.stub.craftablespawn );
        }
    }
    else if ( !isdefined( player_crafted ) || self craftabletrigger_update_prompt( player_crafted ) )
    {
        if ( isdefined( self.stub.model ) )
        {
            self.stub.model notsolid();
            self.stub.model show();
        }

        while ( self.stub.persistent == 1 )
        {
            self waittill( "trigger", player );

            if ( isdefined( player.screecher_weapon ) )
                continue;

            if ( isdefined( level.custom_craftable_validation ) )
            {
                valid = self [[ level.custom_craftable_validation ]]( player );

                if ( !valid )
                    continue;
            }

            if ( !( isdefined( self.stub.crafted ) && self.stub.crafted ) )
            {
                self.stub.hint_string = "";
                self sethintstring( self.stub.hint_string );
                return;
            }

            if ( player != self.parent_player )
                continue;

            if ( !is_player_valid( player ) )
            {
                player thread ignore_triggers( 0.5 );
                continue;
            }

			if (player.score < self.stub.cost)
			{
				self play_sound_on_ent( "no_purchase" );
				continue;
			}

            if ( player has_player_equipment( self.stub.weaponname ) )
                continue;

            if ( isdefined( level.zombie_craftable_persistent_weapon ) )
            {
                if ( self [[ level.zombie_craftable_persistent_weapon ]]( player ) )
                    continue;
            }

            if ( isdefined( level.zombie_custom_equipment_setup ) )
            {
                if ( self [[ level.zombie_custom_equipment_setup ]]( player ) )
                    continue;
            }

            if ( !maps\mp\zombies\_zm_equipment::is_limited_equipment( self.stub.weaponname ) || !maps\mp\zombies\_zm_equipment::limited_equipment_in_use( self.stub.weaponname ) )
            {
				player maps\mp\zombies\_zm_score::minus_to_player_score( self.stub.cost );
				self play_sound_on_ent( "purchase" );

                player maps\mp\zombies\_zm_equipment::equipment_buy( self.stub.weaponname );
                player giveweapon( self.stub.weaponname );
                player setweaponammoclip( self.stub.weaponname, 1 );

                if ( isdefined( level.zombie_include_craftables[self.stub.equipname].onbuyweapon ) )
                    self [[ level.zombie_include_craftables[self.stub.equipname].onbuyweapon ]]( player );
                else if ( self.stub.weaponname != "keys_zm" )
                    player setactionslot( 1, "weapon", self.stub.weaponname );

                if ( isdefined( level.zombie_craftablestubs[self.stub.equipname].str_taken ) )
                    self.stub.hint_string = level.zombie_craftablestubs[self.stub.equipname].str_taken;
                else
                    self.stub.hint_string = "";

                self sethintstring( self.stub.hint_string );
                player track_craftables_pickedup( self.stub.craftablespawn );
            }
            else
            {
                self.stub.hint_string = "";
                self sethintstring( self.stub.hint_string );
            }
        }
    }
}

craftabletrigger_update_prompt( player )
{
    can_use = self.stub craftablestub_update_prompt( player );

	if (can_use && is_true(self.stub.crafted) && !isSubStr(self.stub.craftablespawn.craftable_name, "staff"))
	{
		self sethintstring( self.stub.hint_string, " [Cost: " + self.stub.cost + "]" );
	}
	else
	{
		self sethintstring( self.stub.hint_string );
	}

    return can_use;
}

setup_quadrotor_purchase( player )
{
    if ( self.stub.weaponname == "equip_dieseldrone_zm" )
    {
        if ( players_has_weapon( "equip_dieseldrone_zm" ) )
            return true;

        quadrotor = getentarray( "quadrotor_ai", "targetname" );

        if ( quadrotor.size >= 1 )
            return true;

		player maps\mp\zombies\_zm_score::minus_to_player_score( self.stub.cost );
		self play_sound_on_ent( "purchase" );

        quadrotor_set_unavailable();
        player giveweapon( "equip_dieseldrone_zm" );
        player setweaponammoclip( "equip_dieseldrone_zm", 1 );
        player playsoundtoplayer( "zmb_buildable_pickup_complete", player );

        if ( isdefined( self.stub.craftablestub.use_actionslot ) )
            player setactionslot( self.stub.craftablestub.use_actionslot, "weapon", "equip_dieseldrone_zm" );
        else
            player setactionslot( 2, "weapon", "equip_dieseldrone_zm" );

        player notify( "equip_dieseldrone_zm_given" );
        level thread quadrotor_watcher( player );
        player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "build_dd_plc" );
        return true;
    }

    return false;
}