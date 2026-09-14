-- Main monitor
hl.monitor({
    output = "eDP-1",
    scale = 1.25,
    mode = "2560x1600@300",
})

-- DP-3
hl.monitor({
    output = "DP-3",
    position = "auto-right",
    scale = 1,
    mode = "1920x1080@75",
})

-- Keyboard layout
hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_variant = ",winkeys",
        kb_options = "grp:win_space_toggle,caps:none",
    }
})
