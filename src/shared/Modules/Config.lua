return {
    PLAYER_TAG = "Rat"; --// PLAYER TAG
    CHEF_TAG = "Chef"; --// CHEF TAG
    
    GHOST_TAG = "Ghost"; --// GHOST TAG

    WINNER_TAG = "Winner"; --// WINNER TAG

    CUTSCENE_TAG = "OnCutscene"; --// ON CUTSCENE TAG

    CHEESE_SPAWN = "CheeseSpawner";

    GAME_STATES = {
        NOT_ENOUGH_PLAYERS = 0;
        INTERMISSION = 1;
        GAMEPLAY = 2;
        ENDED = 3;
        FREEPLAY = 4;
    }; --// GAMESTATES FOR THE GAME

    DIFFICULTY = {
        [1] = {Easy = 15, Medium = 0, Hard = 0, Extra = "Easy"},
        [2] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Easy"},
        [3] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Easy"},
        [4] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Easy"},
        [5] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Medium"},
        [6] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Medium"},
        [7] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Medium"},
        [8] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Hard"},
        [9] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Hard"},
        [10] = {Easy = 0, Medium = 0, Hard = 0, Extra = "Hard"},
    };

    WHITELIST = true; --// ALLOWS ONLY QA TEAM WHITELIST TO THE GAME

    SINGLE_PLAYER = false; --// ALLOWS YOU TO BE THE HUNTER AS A SINGLE PLAYER [STUDIO TESTING ONLY]
   
    DEFAULT_SANDBOX_TIME = 390; --in seconds | Default Time: 900;
    DEFAULT_NIGHT_TIME = 30;--100; --in seconds | Default Time: 360;
    
    DAY_START_SHIFT = 7; --// 10 AM
    DAY_END_SHIFT = 23; --// 9 PM
    NIGHT_START_SHIFT = 0; --// 12 AM
    NIGHT_END_SHIFT = 7; --// 7 AM

    RESET_DAILY_SHOP_DATA = false; -- If shop data needs to be reset then if true player will reset shop data when join.
    GIVE_ALL_INVENTORY = true; --// Gives all items on inventory
    DAILY_SHOP_OFFSET = 19; -- 7 PM EST, 24 hour time

    LOWEST_FALL_HEIGHT = 20; -- 10 studs minimum impact
}
