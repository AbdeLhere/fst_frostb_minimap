
local vBitmapTileSizeX = 4500.0
local vBitmapTileSizeY = 4500.0
local vBitmapStartX = -4140.0
local vBitmapStartY = 8400.0

local dummy_blips = {}
scaleform_minimap_main_map_handle = nil


local pauseMenuActive = false
local currentColors = config.hud_customization.colors


local function ApplyHudColors()
    if not config.hud_customization.enabled then return end
    local c = currentColors
    ReplaceHudColourWithRgba(116, c.line.red, c.line.green, c.line.blue, c.line.alpha)
    ReplaceHudColourWithRgba(117, c.background.red, c.background.green, c.background.blue, c.background.alpha)
    ReplaceHudColourWithRgba(142, c.waypoint.red, c.waypoint.green, c.waypoint.blue, c.waypoint.alpha)
end


local function create_dummy_blip(x, y)
    local dummy_blip = AddBlipForCoord(x, y, 1.0)
    SetBlipDisplay(dummy_blip, 4)
    SetBlipAlpha(dummy_blip, 0)

    return dummy_blip
end


function extend_pause_menu_map_bounds()
  
    for _, blip in ipairs(dummy_blips) do
        RemoveBlip(blip)
    end
    dummy_blips = {}

    local keys = get_keys(config.tiles)
    if #keys == 0 then
        return
    end

    local global_x_min = math.huge
    local global_x_max = -math.huge
    local global_y_min = math.huge
    local global_y_max = -math.huge
    local found = false

    local scale_factor = 9216 / 1728.0

    for i = 1, #keys do
        local tile_config = config.tiles[keys[i]]
        local alpha = tonumber(tile_config.alpha) or 100

    
        if tile_config.visible == false or alpha <= 0 then
            goto continue
        end

        local origin_x = vBitmapStartX + (tile_config.x_offset or 0) * vBitmapTileSizeX
        local origin_y = vBitmapStartY - (tile_config.y_offset or 0) * vBitmapTileSizeY

        if tile_config.x then
            origin_x = tile_config.x
        end
        if tile_config.y then
            origin_y = tile_config.y
        end


        local width = vBitmapTileSizeX * math.abs(tonumber(tile_config.x_scale) or 1.0)
        local height = vBitmapTileSizeY * math.abs(tonumber(tile_config.y_scale) or 1.0)

   
        local corners = {}
        if tile_config.centered then
      
            corners = {
                { x = -width / 2, y = height / 2 },  -- Top left
                { x = width / 2,  y = height / 2 },  -- Top right
                { x = -width / 2, y = -height / 2 }, -- Bottom left
                { x = width / 2,  y = -height / 2 }  -- Bottom right
            }
        else
            -- Origin is top left
            corners = {
                { x = 0,     y = 0 },       -- Top left
                { x = width, y = 0 },       -- Top right
                { x = 0,     y = -height }, -- Bottom left
                { x = width, y = -height }  -- Bottom right
            }
        end

        -- Rotate and translate to world space
        local rad = math.rad(-(tile_config.rotation or 0.0))
        local cos_theta = math.cos(rad)
        local sin_theta = math.sin(rad)

        for _, corner in ipairs(corners) do
            -- Apply the rotation matrix
            local rot_x = corner.x * cos_theta - corner.y * sin_theta
            local rot_y = corner.x * sin_theta + corner.y * cos_theta

            -- Translate to game world coordinates
            local world_x = origin_x + rot_x
            local world_y = origin_y + rot_y

            -- Expand the global bounding box
            global_x_min = math.min(global_x_min, world_x)
            global_x_max = math.max(global_x_max, world_x)
            global_y_min = math.min(global_y_min, world_y)
            global_y_max = math.max(global_y_max, world_y)
        end

        found = true
        ::continue::
    end

    if not found then
        return
    end


    table.insert(dummy_blips, create_dummy_blip(global_x_min, global_y_min))
    table.insert(dummy_blips, create_dummy_blip(global_x_max, global_y_max))
end

Citizen.CreateThread(function()

    for tile_name, tile_config in pairs(config.tiles) do
        config.tiles[tile_name].x_offset = 1.0 * (tile_config.x_offset or 0)
        config.tiles[tile_name].y_offset = 1.0 * (tile_config.y_offset or 0)
        config.tiles[tile_name].x_scale = 1.0 * (tile_config.x_scale or 1.0)
        config.tiles[tile_name].y_scale = 1.0 * (tile_config.y_scale or 1.0)
        config.tiles[tile_name].alpha = math.floor(tonumber(tile_config.alpha) or 100)
        config.tiles[tile_name].rotation = tile_config.rotation or 0.0
        config.tiles[tile_name].centered = tile_config.centered or false
        config.tiles[tile_name].visible = tile_config.visible and config.tiles[tile_name].alpha > 0
    end


    local loaded_texture_dictionaries = load_texture_dictionaries(config.tiles)


    while not IsMinimapRendering() do
        Citizen.Wait(0)
    end

    scaleform_minimap_main_map_handle = load_scaleform(config.scaleform_minimap_main_map)


    BeginScaleformMovieMethod(scaleform_minimap_main_map_handle, "CLEAR_TEXTURES")
    EndScaleformMovieMethod()


    local scaleform_x_origin = 864.0
    local scaleform_y_origin = 1440.0
    local scaleform_mc_width = 1728.0
    local scaleform_mc_height = 2880.0

    local world_width = 9216
    local world_height = 15360.002


    local scale_factor = world_width / scaleform_mc_width

    local x_offset = 360 / scale_factor
    local y_offset = 600 / scale_factor

    scaleform_x_origin_game = scaleform_x_origin
    scaleform_y_origin_game = scaleform_y_origin

    scaleform_x_origin = scaleform_x_origin + x_offset
    scaleform_y_origin = scaleform_y_origin + y_offset
    tile_size = vBitmapTileSizeX / scale_factor

    scaleform_x_origin = scaleform_x_origin - tile_size
    scaleform_y_origin = scaleform_y_origin - 2 * tile_size

    for _, tile_name in ipairs(get_keys(config.tiles)) do
        local tile_config = config.tiles[tile_name]

        if tile_config then
    
            local scaleform_x = scaleform_x_origin + (tile_config.x_offset or 0) * tile_size
            local scaleform_y = scaleform_y_origin + (tile_config.y_offset or 0) * tile_size

        
            if tile_config.x then
                scaleform_x = scaleform_x_origin_game + tile_config.x / scale_factor
            end

            if tile_config.y then
                scaleform_y = scaleform_y_origin_game - tile_config.y / scale_factor
            end

     
            if tile_config.x_offset then
                scaleform_x = scaleform_x - (config.offset * tile_config.x_offset)
            end

            if tile_config.y_offset then
                scaleform_y = scaleform_y - (config.offset * (tile_config.y_offset or 0))
            end

            local scaleform_width = tile_size * (math.abs(tile_config.x_scale) or 1.0)
            local scaleform_height = tile_size * (math.abs(tile_config.y_scale) or 1.0)
            local draw_alpha = tile_config.visible == false and 0 or (tile_config.alpha or 100)

            local tile = {
                name = tostring(tile_name),
                txd = tile_config.txd,
                txn = tile_config.txn,
                x = scaleform_x,
                y = scaleform_y,
                width = scaleform_width,
                height = scaleform_height,
                centered = tile_config.centered or false,
                alpha = draw_alpha,
                rotation = 1.0 * (tile_config.rotation or 0.0),
            }

            draw_tile(scaleform_minimap_main_map_handle, tile)
        end
    end

    while not IsMinimapRendering() do
        Citizen.Wait(0)
    end

 
    refresh_minimap()

 
    for _, texture_dict in ipairs(loaded_texture_dictionaries) do
        if HasStreamedTextureDictLoaded(texture_dict) then
            SetStreamedTextureDictAsNoLongerNeeded(texture_dict)
        end
    end

    extend_pause_menu_map_bounds()

    if config.remove_blur then
        RequestStreamedTextureDict(config.radar_masks)
        while not HasStreamedTextureDictLoaded(config.radar_masks) do
            Citizen.Wait(0)
        end

        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "radar_masks", "radarmasksm")
        AddReplaceTexture("platform:/textures/graphics", "radarmasklg", "radar_masks", "radarmasklg")

        Citizen.Wait(500)

        SetBigmapActive(true, false)
        Citizen.Wait(0)
        SetBigmapActive(false, false)

        DisplayRadar(true)

        if HasStreamedTextureDictLoaded(config.radar_masks) then
            SetStreamedTextureDictAsNoLongerNeeded(config.radar_masks)
        end
    end
end)

-- Map zoom levels configuration
if config.options.enable_map_zoom_levels then
    CreateThread(function()
        SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0)
        SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0)
        SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0)
        SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0)
        SetMapZoomDataLevel(4, 24.3, 0.9, 0.08, 0.0, 0.0)
        SetMapZoomDataLevel(5, 55.0, 0.0, 0.1, 2.0, 1.0)
        SetMapZoomDataLevel(6, 450.0, 0.0, 0.1, 1.0, 1.0)
        SetMapZoomDataLevel(7, 4.5, 0.0, 0.0, 0.0, 0.0)
        SetMapZoomDataLevel(8, 11.0, 0.0, 0.0, 2.0, 3.0)
    end)
end

-- Radar zoom thread for non-affected HUD
if not config.options.using_affected_hud then
    CreateThread(function()
        while true do
            Wait(80)
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) then
                SetRadarZoom(1200)
            elseif IsPedInAnyVehicle(ped, true) then
                SetRadarZoom(config.options.zoom_level)
            end
        end
    end)
end

-- HUD color reapply thread (ReplaceHudColourWithRgba can be reset by the game)
CreateThread(function()
    if not config.hud_customization.enabled then return end
    Wait(1000)
    while true do
        ApplyHudColors()
        Wait(1000)
    end
end)

-- Pause menu background thread
CreateThread(function()
    if not config.hud_customization.enabled then return end
    while true do
        local isPaused = IsPauseMenuActive()
        if isPaused ~= pauseMenuActive then pauseMenuActive = isPaused end
        if pauseMenuActive and currentColors.pause_bg then
            SetScriptGfxDrawBehindPausemenu(true)
            local bg = currentColors.pause_bg
            DrawRect(0.5, 0.5, 1.0, 1.0, bg.red, bg.green, bg.blue, bg.alpha)
            SetScriptGfxDrawBehindPausemenu(false)
            Wait(0)
        else
            Wait(500)
        end
    end
end)
