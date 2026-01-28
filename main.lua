function _init()
	game_state = "title"
	current_level=1
	input_lock=0
	level_complete_timer=0
	level_start = {
	{x=0,y=120},--l1
	{x=0,y=120},--l2
	{x=8,y=112}--l3
	}

	level_offset_y = (current_level-1)*16

	levels={1,2,3}
	player={
		x=0,
		y=0,
		sprite=1,
		dir=⬇️
		}
	bubble={}
	
	switches = {13,14,15,29}
	
	-- lasers
	lasers={}
	buttons = {}
	button_on_tile = 5
	button_off_tile = 21
	laser_on_tile = 10
	laser_off_tile = 26
	laser_on_light = 24
	laser_off_light = 25
	
	
	lasers_active = true
	lasers_were_active = true
	
end

function _update()

	if game_state == "title" then
		if btnp(❎) then
			reset_level()
			game_state="level_select"
		end
		return
	end
	
	if game_state == "level_select" then
		if btnp(2) then
			current_level-=1
		end
		if btnp(3) then
			current_level+=1
		end
		current_level=mid(1, current_level, #levels)
		
		if btnp(5) then 
			load_level(current_level)
			game_state="game"
		end
	end	
	
	if game_state == "game" then
		if btnp(4) then
			game_state = "pause"
			return
		end
		
		if input_lock > 0 then
			input_lock-=1
			return
		end
		if level_complete_timer > 0 then
			level_complete_timer-=1
			if level_complete_timer == 0 then
				level_complete()
				return
			end
 		end
	end
	
	if game_state == "pause" then
		if btnp(4) then
			game_state = "game"
		end
		if btnp(5) then
			reset_level()
			game_state="game"
		end	
		return	
	end 
	
	if game_state == "level_complete" then
		if btnp(5) then
			current_level+=1
			if current_level > #levels then
				game_state="level_select"
			else
				load_level(current_level)
				game_state="game"
			end
		end
		return
	end
	
	move(player)
	lights()
	
	if btnp(4) then
		reset_level()
	end
	
	if lasers_active != lasers_were_active then -- prevents game from reqriting tiles each frame
		update_lasers()
		update_buttons()
		lasers_were_active = lasers_active
	end
	if btnp(❎) then
		shoot()
		sfx(1)
	end
	for b in all(bubble) do
		local tx = flr(b.x/8)
		local ty = flr(b.y/8)
		local tile = mget(tx,ty)
		
		if b.popping then
			b.poptimer-=1
			if b.poptimer<=0 then
				del(bubble,b)
			end
			
		else
			b.x+=b.dx
			b.y+=b.dy
			
			switch(b)
				
			tx = flr(b.x/8)
			ty = flr(b.y/8)
			tile = mget(tx,ty)
			
			if b.just_turned then
				b.just_turned = false
			else
		
				if collide(b,switches) and not tile_in_list(tile,switches) then
					b.popping=true
					b.poptimer=1		
			 	elseif hit_button(b) then
			 		sfx(3)
				 	press_button_at(b)
				 	b.popping=true
				 	b.poptimer=10
				elseif treasure(b) then
			 		sfx(2)
			 		open_chest_at(b)
			 		level_complete_timer = 20
				 	b.popping=true
				 	b.poptimer=10		
		  		end
		 	end
	 	end
 	end
end
	

function _draw()
	cls()
	
	if game_state == "title" then
		print("octoblast", 45, 40, 7)
		print("press ❎ to start", 35, 60, 7)
		return
	end
	
	if game_state == "game" then
	
		map(0, level_offset_y, 0, 0, 16, 16)
		spr(player.sprite,player.x,player.y)
		
		for b in all(bubble) do
			if b.popping then
				spr(11,b.x,b.y)
			else
				spr(6,b.x,b.y)
			end
		end
	end
	
	if game_state=="level_select" then
		cls()
		print("select level", 40, 20, 7)
		
		for i=1,#levels do
			local col = (i == current_level) and 10 or 7
			print("level"..i, 50, 40 + i*10, col)
		end
		return
	end
	
	if game_state=="pause" then
		rectfill(20, 40, 108, 88, 1)
		print("paused", 50, 50, 7)
		print("❎ reset", 40, 70, 7)
		print("🅾️ resume", 40, 80, 7)
		return
	end
	
	if game_state=="level_complete" then
		cls()
		print("level complete!", 35,40,10)
		print("press ❎", 45, 60, 7)
		return
	end
end



	

