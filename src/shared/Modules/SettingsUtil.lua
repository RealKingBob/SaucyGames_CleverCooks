return {
    ["AFK"] = {
        ["Default"] = "On",
        ["IsMobile"] = false,
        ["Type"] = "Button",
        ["Options"] = {
            ["Off"] = { 1, false },
            ["On"] = { 2, true }
        }
    },
    ["Bubble Chat"] = {
        ["Default"] = "On",
        ["IsMobile"] = false,
        ["Type"] = "Button",
        ["Options"] = {
            ["On"] = { 1, true },
            ["Off"] = { 2, false },
        }
    },
    ["Music"] = {
        ["Default"] = 0.3,
        ["IsMobile"] = false,
        ["Type"] = "Slider",
        ["MaxValue"] = 0.6;
        ["MinValue"] = 0;
    },
    ["Nametags"] = {
        ["Default"] = "Everyone",
        ["IsMobile"] = false,
        ["Type"] = "Button",
        ["Options"] = {
            ["Everyone"] = { 1, true },
            ["Friends"] = { 2, true },
            ["Off"] = { 3, false }
        }
    },
    --[[["Crate Openings"] = {
        ["Default"] = "Automatic",
        ["IsMobile"] = false,
        ["Type"] = "Button",
        ["Options"] = {
            ["Automatic"] = { 1, true },
            ["Manual"] = { 2, true },
        }
    },]]
    ["Auto Jump"] = {
        ["Default"] = "Off",
        ["IsMobile"] = true,
        ["Type"] = "Button",
        ["Options"] = {
            ["Off"] = { 1, false },
            ["On"] = { 2, true }
        }
    },
    --[[ ["Sound Effects"] = {
        ["Default"] = "On",
        ["Options"] = {
            ["On"] = { 1, true },
            ["Off"] = { 2, false }
        }
    },
    ["Character Render Distance"] = {
        ["Default"] = "Low",
        ["Options"] = {
            ["Very Low"] = { 1, true },
            ["Low"] = { 2, true },
            ["Medium"] = { 3, true },
            ["High"] = { 4, true },
            ["Very High"] = { 5, true },
            ["Ultra"] = { 6, true }
        }
    },
    ["Footsteps"] = {
        ["Default"] = "On",
        ["Options"] = {
            ["On"] = { 1, true },
            ["Off"] = { 2, false }
        }
    },
    ["Chat Notifications"] = {
        ["Default"] = "On",
        ["Options"] = {
            ["On"] = { 1, true },
            ["Off"] = { 2, false }
        }
    },
    ["Allow Boomboxes"] = {
        ["Default"] = "On",
        ["Options"] = {
            ["On"] = { 1, true },
            ["Off"] = { 2, false }
        }
    }]]
}