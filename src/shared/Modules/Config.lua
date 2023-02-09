return {
    PLAYER_TAG = "Rat"; --// PLAYER TAG
    CHEF_TAG = "Chef"; --// CHEF TAG
    
    GHOST_TAG = "Ghost"; --// GHOST TAG

    WINNER_TAG = "Winner"; --// WINNER TAG

    CUTSCENE_TAG = "OnCutscene"; --// ON CUTSCENE TAG

    CHEESE_SPAWN = "CheeseSpawner";
    
    RED_TEAM = "RedTeam"; --// RED_TEAM TAG
    BLUE_TEAM = "BlueTeam"; --// BLUE_TEAM TAG
 
    GAME_STATES = {
        NOT_ENOUGH_PLAYERS = 0;
        INTERMISSION = 1;
        GAMEPLAY = 2;
        ENDED = 3;
        FREEPLAY = 4;
    }; --// GAMESTATES FOR THE GAME

    MAPS = {
        {MapName = "Map1", Chance = 10};
        {MapName = "Map2", Chance = 10};
        {MapName = "Map3", Chance = 10};
    }; --// CURRENT MAPS IN PLAY, [MapName : String, Chance : Number]

    WHITELIST = true; --// ALLOWS ONLY QA TEAM WHITELIST TO THE GAME

    SINGLE_PLAYER = false; --// ALLOWS YOU TO BE THE HUNTER AS A SINGLE PLAYER [STUDIO TESTING ONLY]
   
    DEFAULT_SANDBOX_TIME = 350; --in seconds | Default Time: 900;
    DEFAULT_NIGHT_TIME = 30;--100; --in seconds | Default Time: 360;
    DEFAULT_ROUND_TIME = 720; --// IF NO CUSTOM GAMEPLAY TIME THEN USE THIS DEFAULT GAMEPLAY TIME
    DEFAULT_INTERMISSION_TIME = 10; --// IF NO CUSTOM INTERMISSION TIME THEN USE THIS DEFAULT INTERMISSION TIME
    MINIMUM_PLAYERS = 1; --// MINIMUM AMOUNT OF PEOPLE REQUIRED TO START INTERMISSION
    
    DAY_START_SHIFT = 10; --// 10 AM
    DAY_END_SHIFT = 21; --// 9 PM
    NIGHT_START_SHIFT = 0; --// 12 AM
    NIGHT_END_SHIFT = 7; --// 7 AM

    RESET_DAILY_SHOP_DATA = false; -- If shop data needs to be reset then if true player will reset shop data when join.
    GIVE_ALL_INVENTORY = true; --// Gives all items on inventory
    DAILY_SHOP_OFFSET = 19; -- 7 PM EST, 24 hour time

    LOWEST_FALL_HEIGHT = 10; -- 10 studs minimum impact
}
