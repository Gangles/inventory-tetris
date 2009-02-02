-------------------------------------------------------------------------
-- Inventory Tetris
-- Copyright 2009 Matthew Gallant
-- http://gangles.ca/
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License (COPYING) for more details.
-------------------------------------------------------------------------

function load()
	tile = {}
	tile[0] = love.graphics.newImage( "gfx/blanktile.jpg" )
	tile[1] = love.graphics.newImage( "gfx/uzi/uzitile1.jpg" )
	tile[2] = love.graphics.newImage( "gfx/uzi/uzitile2.jpg" )
	tile[3] = love.graphics.newImage( "gfx/uzi/uzitile3.jpg" )
	tile[4] = love.graphics.newImage( "gfx/uzi/uzitile4.jpg" )
	tile[5] = love.graphics.newImage( "gfx/magnum/magnumtile1.jpg" )
	tile[6] = love.graphics.newImage( "gfx/magnum/magnumtile2.jpg" )
	tile[7] = love.graphics.newImage( "gfx/magnum/magnumtile3.jpg" )
	tile[8] = love.graphics.newImage( "gfx/magnum/magnumtile4.jpg" )
	tile[9] = love.graphics.newImage( "gfx/pistol/pistoltile1.jpg" )
	tile[10] = love.graphics.newImage( "gfx/pistol/pistoltile2.jpg" )
	tile[11] = love.graphics.newImage( "gfx/pistol/pistoltile3.jpg" )
	tile[12] = love.graphics.newImage( "gfx/pistol/pistoltile4.jpg" )
	tile[13] = love.graphics.newImage( "gfx/pills/pillstile1.jpg" )
	tile[14] = love.graphics.newImage( "gfx/pills/pillstile2.jpg" )
	tile[15] = love.graphics.newImage( "gfx/pills/pillstile3.jpg" )
	tile[16] = love.graphics.newImage( "gfx/pills/pillstile4.jpg" )
	tile[17] = love.graphics.newImage( "gfx/grenade/grenadetile1.jpg" )
	tile[18] = love.graphics.newImage( "gfx/grenade/grenadetile2.jpg" )
	tile[19] = love.graphics.newImage( "gfx/grenade/grenadetile3.jpg" )
	tile[20] = love.graphics.newImage( "gfx/grenade/grenadetile4.jpg" )
	tile[21] = love.graphics.newImage( "gfx/shotgun/shotguntile1.jpg" )
	tile[22] = love.graphics.newImage( "gfx/shotgun/shotguntile2.jpg" )
	tile[23] = love.graphics.newImage( "gfx/shotgun/shotguntile3.jpg" )
	tile[24] = love.graphics.newImage( "gfx/shotgun/shotguntile4.jpg" )
	tile[25] = love.graphics.newImage( "gfx/ammo/ammotile1.jpg" )
	tile[26] = love.graphics.newImage( "gfx/ammo/ammotile2.jpg" )
	tile[27] = love.graphics.newImage( "gfx/ammo/ammotile3.jpg" )
	tile[28] = love.graphics.newImage( "gfx/ammo/ammotile4.jpg" )
	
	dead = love.graphics.newImage( "gfx/youaredead.png" )
	title = love.graphics.newImage( "gfx/title_screen.png" )
	
	sound_welcome = love.audio.newSound( "audio/welcome.ogg" )
	sound_thankyou = love.audio.newSound( "audio/thankyou.ogg" )
	sound_bigthankyou = love.audio.newSound( "audio/bigthankyou.ogg" )
	sound_gameover = love.audio.newSound( "audio/gameover.ogg" )
	music = love.audio.newMusic( "audio/eviltetris.ogg" )
	
	love.graphics.setFont(love.graphics.newFont(love.default_font, 12))
	
	-- Time variables
	drop_delay = 0.5
	drop_timer = 0
	control_delay = 0.2
	control_timer = 0
	
	-- Map variables
	map_offset_x = 0
	map_offset_y = 0
	map_display_w = 10
	map_display_h = 18
	tile_w = 42
	tile_h = 42
	
	-- Start background music
	love.audio.play( music )
	
	-- Initialize game
	game_over = false
	game_score = 0
	initialize_maps()
	
	-- Initialize blocks
	math.randomseed(os.date("%S"))
	block_table= {1,2,3,4,5,6,7}
	shuffle(block_table)
	block_counter = 0
	new_piece()
	
	love.audio.play( sound_welcome )
end

function new_piece()
	piece_x = 5
	piece_y = 1
	piece_rotation = 0
	
	block_counter = block_counter + 1
	if block_counter > #block_table then
		shuffle(block_table)
		block_counter = 1
	end
	piece_type = block_table[ block_counter ]
	
	tiles = getTiles(piece_type, piece_x, piece_y, piece_rotation)
	for i=1,#tiles do
		x = tiles[i][1]
		y = tiles[i][2]
		if map[y][x] ~= 0 then
			end_game()
			return
		end
	end
end

function update( dt )
	if love.keyboard.isDown( love.key_m ) then
		love.audio.pause()
	end
	
	if love.keyboard.isDown( love.key_n ) then
		love.audio.resume()
	end
	
	if love.keyboard.isDown( love.key_r ) then
		new_game()
	end
	
	if game_over then
		return
	end
	
	-- Drop the piece by one tile every 0.5 seconds
	drop_timer = drop_timer + dt
	if drop_timer > drop_delay then
		move_down()
		drop_timer = 0
	end
	
	-- Allow a delay for new actions
	if control_timer < 0 then
		control_timer = 0
	else
		control_timer = control_timer - dt
		return
	end
	
	if love.keyboard.isDown( love.key_left ) then
		move_horizontal(-1)
		control_timer = control_delay
	end
	if love.keyboard.isDown( love.key_right ) then
		move_horizontal(1)
		control_timer = control_delay
	end
	if love.keyboard.isDown( love.key_up ) then
		rotate()
		control_timer = control_delay/2
	end
	if love.keyboard.isDown( love.key_down ) then
		move_down()
		control_timer = control_delay/10
	end
end

function move_down()
	tiles = getTiles(piece_type, piece_x, piece_y, piece_rotation)
	for i=1,#tiles do
		pos_x = tiles[i][1]
		pos_y = tiles[i][2]
		
		-- We've reached the bottom
		if pos_y >= map_display_h then
			cement(tiles)
			return
		end
		
		-- There is a block in the way
		pos_next = map[pos_y+1][pos_x]
		if pos_next ~= 0 then
			cement(tiles)
			return
		end
	end
	
	-- Nothing in the way, move down one tile
	piece_y = piece_y+1
end

function move_horizontal(direction)
	tiles = getTiles(piece_type, piece_x, piece_y, piece_rotation)
	for i=1,#tiles do
		pos_x = tiles[i][1]
		pos_y = tiles[i][2]
		
		-- We've reached the edge
		if (pos_x == 1 and direction < 0) or (pos_x == map_display_w and direction > 0) then
			return
		end
		
		-- There is a block in the way
		pos_next = map[pos_y][pos_x+direction]
		if pos_next ~= 0 then
			return
		end
	end
	
	-- Nothing in the way, move left or right one tile
	piece_x = piece_x + direction
end

function rotate()
	tiles = getTiles(piece_type, piece_x, piece_y, piece_rotation + 90)
	for i=1,#tiles do
		pos_x = tiles[i][1]
		pos_y = tiles[i][2]
	
		-- We've passed the horizontal edge
		if pos_x < 1 or pos_x > map_display_w then
			return
		end
		
		-- We've passed the vertical edge
		if pos_y < 1 or pos_y > map_display_h then
			return
		end
	
		-- There is a block in the way
		pos_rotate = map[pos_y][pos_x]
		if pos_rotate ~= 0 then
			return
		end
	end

	-- Nothing in the way, rotate
	piece_rotation = piece_rotation + 90
end

function cement(tiles)
	for i=1,4 do
		-- Record the piece on the map
		pos_x = tiles[i][1]
		pos_y = tiles[i][2]
		map[pos_y][pos_x] = (piece_type-1)*4 + i
		angle_map[pos_y][pos_x] = piece_rotation
	end
	
	detect_full()
	new_piece()
end

function detect_full()
	row_range = { map_display_h, 1 }
	row_counter = 0
	
	for y=1,map_display_h do
		product = 1
		for x=1,map_display_w do
			product = product * map[y][x]
		end
		
		-- If the row is full, record it
		if product ~= 0 then
			if y < row_range[1] then
				row_range[1] = y
			end
			if y > row_range[2] then
				row_range[2] = y
			end
			row_counter = row_counter + 1
		end
	end
	
	if row_counter > 0 then
		if row_counter == 4 then
			love.audio.play( sound_bigthankyou )
			game_score = game_score + 800
		else
			love.audio.play( sound_thankyou )
			game_score = game_score + 100 + (row_counter-1) * 200
		end
		
		shift_rows(row_range[1], row_range[2])
	end
end

function shift_rows(lower, upper)
	shift = upper - lower + 1
	for y = upper,1,-1 do
		for x=1,map_display_w do
			if (y-shift) < 1 then
				map[y][x] = 0
				angle_map[y][x] = 0
			else
				map[y][x] = map[y-shift][x]
				angle_map[y][x] = angle_map[y-shift][x]
			end
		end
	end
end

function draw()
	draw_map()
	draw_piece()
	if game_over then
		love.graphics.draw(dead, 230, 300)
	end
	draw_score()
end

function draw_map()
	love.graphics.draw(title, 635, 400)
	for y=1, map_display_h do
        for x=1, map_display_w do                                                         
        	love.graphics.draw(
				tile[map[y][x]],
				(x*tile_w)+map_offset_x,
				(y*tile_h)+map_offset_y,
				angle_map[y][x] )
        end
    end
end

function draw_piece()
	tiles = getTiles(piece_type, piece_x, piece_y, piece_rotation)
	for i=1,#tiles do
		love.graphics.draw(
			tile[(piece_type-1)*4 + i],
			tiles[i][1] * tile_w + map_offset_x,
			tiles[i][2] * tile_h + map_offset_y,
			piece_rotation )
	end
end

function draw_score()
	love.graphics.setColor( love.graphics.newColor( 205, 0, 0 ) ) 
	love.graphics.draw("Score:"..game_score, 20, 13)
end

function end_game()
	game_over = true
	love.audio.play( sound_gameover )
end

function new_game()
	initialize_maps()
	game_over = false
	shuffle(block_table)
	block_counter = 0
	game_score = 0
	new_piece()
end

function getTiles(type, x, y, angle)
	rad_angle = math.rad(angle)
	x_off = round(math.cos(rad_angle))
	y_off = round(math.sin(rad_angle))
	local tiles
	
	-- "T" block
	if type == 1 then
		tiles = {
				{x, y},
				{x + x_off, y + y_off},
				{x - x_off, y - y_off},
				{x - y_off, y + x_off},
			}
	-- "J" block
	elseif type == 2 then
		tiles = {
				{x, y},
				{x + x_off, y + y_off},
				{x - x_off, y - y_off},
				{x + x_off - y_off, y + y_off + x_off},
			}
	-- "L" block
	elseif type == 3 then
				tiles = {
				{x, y},
				{x + x_off, y + y_off},
				{x - x_off, y - y_off},
				{x - x_off - y_off, y - y_off + x_off},
			}
	-- "Z" block
	elseif type == 4 then
		tiles = {
				{x, y},
				{x + x_off - y_off, y + y_off + x_off},
				{x - y_off, y + x_off},
				{x - x_off, y - y_off},
			}
	-- "S" block
	elseif type == 5 then
		tiles = {
				{x, y},
				{x + x_off, y + y_off},
				{x - y_off, y + x_off},
				{x - x_off - y_off, y - y_off + x_off},
			}
	-- "I" block
	elseif type == 6 then
		tiles = {
				{x, y},
				{x + x_off, y + y_off},
				{x + 2*x_off, y + 2*y_off},
				{x - x_off, y - y_off},
			}
	-- "O" block
	elseif type == 7 then
		tiles = {
				{x, y},
				{x + x_off, y + y_off},
				{x - y_off, y + x_off},
				{x + x_off - y_off, y + x_off + y_off},
			}
	end
	return tiles
end

function initialize_maps()
	map={
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		}
	
	angle_map={
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		}
end

-- Utility functions
function shuffle(table)
	for i=1,#table do
		j = math.random(1,7)
		temp = table[j]
		table[j] = table[i]
		table[i] = temp
	end
end

function round(num)
  return math.floor(num + 0.5)
end