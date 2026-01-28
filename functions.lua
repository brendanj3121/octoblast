function move(o)
	local lx=o.x
	local ly=o.y

	if btnp(➡️) then
		if o.x==120 then -- prevent moving through walls
		else
	 	o.x+=8
	 	o.sprite=1
	 	o.dir=➡️
	 	end
	end
	if btnp(⬅️) then 
		if o.x==0 then 
		else
	 	o.x-=8
	 	o.sprite=2
		o.dir=⬅️
		end
	end
	if btnp(⬇️) then
		if o.y==120 then
		else
	 	o.y+=8
	 	o.dir=⬇️
	 	end
	end
	if btnp(⬆️) then
		if o.y==0 then
		else
	 	o.y-=8
	 	o.dir=⬆️
	 	end
	end
	
	
	if collide(o) then --if collides, move back
		if push(o,lx,ly) then
			-- allow push and movement
		else
			o.x=lx
			o.y=ly
		end
	end	
end

function collide(o,ignore_list) 
		local tx = flr((o.x + 4) / 8)
 	local ty = flr((o.y + 4)/8) + level_offset_y 
 	local tile = mget(tx,ty)
 
 	if ignore_list and tile_in_list(tile,ignore_list) then
 		return false
 	end
 
 	return fget(tile,0)
end

function hit_button(o)
	local x1=o.x/8
	local y1=o.y/8 + level_offset_y
	local x2=(o.x+7)/8
	local y2=(o.y+7)/8 + level_offset_y
	
	local a=fget(mget(x1,y1),1)
	local b=fget(mget(x1,y2),1)
	local c=fget(mget(x2,y1),1)
	local d=fget(mget(x2,y2),1)
	
	if a or b or c or d then
		return true
	else
		return false
	end
end	

function treasure(o)
	local x1=o.x/8
	local y1=o.y/8 + level_offset_y
	local x2=(o.x+7)/8
	local y2=(o.y+7)/8 + level_offset_y
	
	local a=fget(mget(x1,y1),4)
	local b=fget(mget(x1,y2),4)
	local c=fget(mget(x2,y1),4)
	local d=fget(mget(x2,y2),4)
	
	if a or b or c or d then
		return true
	else
		return false
	end
end	

function push(o,lx,ly)
	local dx=0
	local dy=0
	
	-- set tile push directions
	if o.dir == ➡️ then
		dx = 1
	end
	if o.dir == ⬅️ then
		dx = -1
	end
	if o.dir == ⬆️ then
		dy = -1
	end
	if o.dir == ⬇️ then
		dy = 1
	end
	
	-- tile player is trying to move to
	local tx = flr((lx+dx*8)/8)
	local ty = flr((ly+dy*8)/8) + level_offset_y
	
	local tile = mget(tx,ty)
	
	debug_text = "tile: "..tile
	
	-- check if tile pushable	
	if not fget(tile, 5) then
		return false
	end
	
	-- check if push destination is pushable
	local tx2 = tx+dx
	local ty2 = ty+dy
	
	local tile2 = mget(tx2,ty2)

	-- check push destination for collision
	if fget(tile2, 0) then
		return false
	end
	
	-- move the block
	mset(tx2,ty2,tile)
	mset(tx,ty,3) -- empty tile
	
	return true
	
end	

function lasers_on()
	if lasers_active then return end
	lasers_active = true
end

function lasers_off()
	if not lasers_active then return end
	lasers_active = false
end	
	
function press_button_at(o)
	local x1=flr(o.x/8)
	local y1=flr(o.y/8) + level_offset_y
	local x2=flr((o.x+7)/8)
	local y2=flr((o.y+7)/8) + level_offset_y
	
	local tiles = {
		{x1,y1},
		{x2,y2},
		{x1,y2},
		{x2,y1}
	}
	
	
	lasers_active = not lasers_active
	
	for t in all(tiles) do
		local tx, ty = t[1], t[2]
		local tile = mget(tx,ty)
		
	 if tile == button_off_tile then
	 	lasers_on()
	 elseif tile == button_on_tile then
	 	lasers_off() 
		end
	end
end

function tile_in_list(tile, list)
	for i=1,#list do
		if list[i] == tile then
			return true
		end
	end
	return false
end

function update_lasers()
	for t in all(lasers) do
			if lasers_active then
				mset(t.x, t.y, laser_on_tile)
			else
				mset(t.x, t.y, laser_off_tile)	
		end
	end	
end

function update_buttons()
	for t in all(buttons) do
			if lasers_active then
				mset(t.x, t.y, button_on_tile)
			else
				mset(t.x, t.y, button_off_tile)	
		end
	end	
end

function lights()
	for x=0,127 do
		for y=0,63 do
			local ty=y+level_offset_y
			local tile = mget(x,ty)
			
			if tile == 24 and lasers_active == false then
				mset(x,ty,25)
			elseif tile == 25 and lasers_active == true then
				mset(x,ty,24)
			end
		end
	end 
end

function open_chest_at(o)
	local x1=flr(o.x/8)
	local y1=flr(o.y/8) + level_offset_y
	local x2=flr((o.x+7)/8) 
	local y2=flr((o.y+7)/8) + level_offset_y
	
	local tiles = {
		{x1,y1},
		{x2,y2},
		{x1,y2},
		{x2,y1}
	}
	
	for t in all(tiles) do
		local tx, ty = t[1], t[2]
		local tile = mget(tx,ty)
		
		if tile==7 then
			mset(tx,ty,23)
		end
	end
end

function shoot()
	if player.dir==➡️ then
		add(bubble,{
		x=player.x+4,
		y=player.y,
		dx=2,
		dy=0,
		popping=false,
		poptimer=0,
		just_turned=false
		})
	end
	if player.dir==⬅️ then
		add(bubble,{
		x=player.x-4,
		y=player.y,
		dx=-2,
		dy=0,
		popping=false,
		poptimer=0,
		just_turned=false
		})
	end
	if player.dir==⬇️ then
		add(bubble,{x=player.x,
		y=player.
		y+4,
		dx=0,
		dy=2,
		popping=false,
		poptimer=0,
		just_turned=false
		})
	end
	if player.dir==⬆️ then
		add(bubble,{x=player.x,
		y=player.y-4,
		dx=0,
		dy=-2,
		popping=false,
		poptimer=0,
		just_turned=false
		})
	end
end

-- switch direction with arrow tiles
function switch(o)
	if (o.x % 8 != 0) or (o.y % 8 != 0) then
		return
	end
	
	local tx = flr(o.x/8)
	local ty = flr(o.y/8) + level_offset_y
	local tile = mget(tx,ty)
	
	if tile == 13 then
		o.dx = 0 
		o.dy = -2
		o.just_turned=true
	end
	if tile == 14 then
		o.dx = 0
		o.dy = 2
		o.just_turned=true
	end
	if tile == 15 then
		o.dx = -2
		o.dy = 0
		o.just_turned=true
	end
	if tile == 29 then
		o.dx = 2
		o.dy =	0
		o.just_turned=true
	end
end

function reset_level(n)
	n=n or current_level

	reload(0x2000, 0x2000, 0x1000)
	player.x=level_start[n].x
	player.y=level_start[n].y
	player.dir=⬇️
	player.sprite=1
	
	bubble={}
	
	lasers_active = true
	lasers_were_active = true
end

function load_level(n)
	sfx(5)
	
	current_level=n
	level_offset_y = (current_level-1)*16  -- update offset here!
	player.x=level_start[n].x
	player.y=level_start[n].y
	player.dir=⬇️
	player.sprite=1
	
	bubble={}
	lasers={}
	buttons = {}
	
	
	lasers_active = true
	lasers_were_active = true
	
	for x=0,127 do
		for y=0,63 do
			local ty = y+level_offset_y
			local t = mget(x,ty)
			if t == laser_on_tile or t == laser_off_tile then
				add(lasers, {x=x, y=ty})
			end
			if t == button_on_tile or t == button_off_tile then
				add(buttons, {x=x, y=ty})
			end
		end
	end
	
	input_lock=10
	
	update_lasers()
	update_buttons()
end

function level_complete()
	game_state="level_complete"
end

