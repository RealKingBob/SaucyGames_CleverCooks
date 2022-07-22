return {
    PLAYER_TAG = "Rat"; --// PLAYER TAG
    CHEF_TAG = "Chef"; --// CHEF TAG
    
    GHOST_TAG = "Ghost"; --// GHOST TAG

    WINNER_TAG = "Winner"; --// WINNER TAG

    CUTSCENE_TAG = "OnCutscene"; --// ON CUTSCENE TAG
    
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
   
    DEFAULT_GAMEPLAY_TIME = 180; --// IF NO CUSTOM GAMEPLAY TIME THEN USE THIS DEFAULT GAMEPLAY TIME
    DEFAULT_INTERMISSION_TIME = 25; --// IF NO CUSTOM INTERMISSION TIME THEN USE THIS DEFAULT INTERMISSION TIME
    MINIMUM_PLAYERS = 2; --// MINIMUM AMOUNT OF PLAYERS REQUIRED TO START INTERMISSION
    
    RESET_DAILY_SHOP_DATA = false; -- If shop data needs to be reset then if true player will reset shop data when join.
    GIVE_ALL_INVENTORY = false; --// Gives all items on inventory
    DAILY_SHOP_OFFSET = 19 -- 7 PM EST, 24 hour time
}
