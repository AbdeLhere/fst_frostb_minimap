config = {}
config.scaleform_minimap_main_map = "minimap_main_map"
config.scaleform_minimap = "minimap"
config.offset = 0.1

config.remove_blur = false
config.radar_masks = "radar_masks"

-- Minimap options
config.options = {
    zoom_level = 1100,
    enable_map_zoom_levels = true,
    using_affected_hud = false,
}

-- HUD Color Customization
-- To change colors: modify the RGBA values below and restart the resource
-- RGB values range from 0-255, Alpha ranges from 0-255 (0 = transparent, 255 = opaque)
config.hud_customization = {
    enabled = true,
    colors = {
        line = { red = 255, green = 157, blue = 61, alpha = 255 },       -- Minimap border line
        background = { red = 255, green = 157, blue = 61, alpha = 240 }, -- Minimap background
        pause_bg = { red = 66, green = 194, blue = 189, alpha = 100 },   -- Pause menu background overlay
        waypoint = { red = 255, green = 157, blue = 61, alpha = 255 },   -- GPS / waypoint route
    }
}

config.tiles = {
    ['1'] = { txd = "cayo_2_1", txn = "2_1", x_offset = 1, y_offset = 2, x_scale = 1.0, y_scale = 1.0, rotation = 0.0, alpha = 100, centered = false, visible = true },
    ['2'] = { txd = "cayo_2_2", txn = "2_2", x_offset = 2, y_offset = 2, x_scale = 1.0, y_scale = 1.0, rotation = 0.0, alpha = 100, centered = false, visible = true },
    ['3'] = { txd = "cayo_3_1", txn = "3_1", x_offset = 1, y_offset = 3, x_scale = 1.0, y_scale = 1.0, rotation = 0.0, alpha = 100, centered = false, visible = true },
    ['4'] = { txd = "cayo_3_2", txn = "3_2", x_offset = 2, y_offset = 3, x_scale = 1.0, y_scale = 1.0, rotation = 0.0, alpha = 100, centered = false, visible = true },
}
