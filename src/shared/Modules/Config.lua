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

    WHITELIST = true; --// ALLOWS ONLY QA TEAM WHITELIST TO THE GAME

    SINGLE_PLAYER = false; --// ALLOWS YOU TO BE THE HUNTER AS A SINGLE PLAYER [STUDIO TESTING ONLY]
   
    DEFAULT_SANDBOX_TIME = 900;
    DEFAULT_ROUND_TIME = 720; --// IF NO CUSTOM GAMEPLAY TIME THEN USE THIS DEFAULT GAMEPLAY TIME
    DEFAULT_INTERMISSION_TIME = 10; --// IF NO CUSTOM INTERMISSION TIME THEN USE THIS DEFAULT INTERMISSION TIME
    MINIMUM_PLAYERS = 1; --// MINIMUM AMOUNT OF PLAYERS REQUIRED TO START INTERMISSION
    
    RESET_DAILY_SHOP_DATA = false; -- If shop data needs to be reset then if true player will reset shop data when join.
    GIVE_ALL_INVENTORY = true; --// Gives all items on inventory
    DAILY_SHOP_OFFSET = 19 -- 7 PM EST, 24 hour time
}
