return {
    DUCK_TAG = "Duck"; --// DUCK TAG
    ALIVE_TAG = "Alive"; --// ALIVE TAG
    
    GHOST_TAG = "Ghost"; --// GHOST TAG

    NO_POTATO_TAG = "NoPotato"; --// HAS NO POTATO TAG
    POTATO_TAG = "Potato"; --// HAS POTATO BOMB TAG
    HILL_TAG = "Hill"; --// IS ON HILL TAG

    BREAD_TAG = "BreadPlayer"; --// BREAD TAG
    ARENA_TAG = "LobbyArena"; --// BREAD TAG

    WINNER_TAG = "Winner"; --// WINNER TAG

    AFK_TAG = "AFK"; --// AFK TAG
    IDLE_TAG = "IsIdle"; --// IS IDLE TAG
    LOBBY_TAG = "InLobby"; --// IN LOBBY TAG

    CHECKPOINT_TAG = "Checkpoint"; --// ON CUTSCENE TAG
    CUTSCENE_TAG = "OnCutscene"; --// ON CUTSCENE TAG
    
    RED_TEAM = "RedTeam"; --// RED_TEAM TAG
    BLUE_TEAM = "BlueTeam"; --// BLUE_TEAM TAG

    HUNTER_TAG = "Hunter"; --// HUNTER TAG
    PERM_HUNTER_TAG = "PermHunter";

    REGULAR_THRESHOLD = 0.7;
    EXTREME_THRESHOLD = 0.5;
    
    GAME_STATES = {
        NOT_ENOUGH_PLAYERS = 0;
        INTERMISSION = 1;
        GAMEPLAY = 2;
        ENDED = 3;
    }; --// GAMESTATES FOR THE GAME

    T_MAPS = {
        {MapName = "Cave", Chance = 10};
        {MapName = "Desert", Chance = 10};
        {MapName = "Kingdom", Chance = 10};
        {MapName = "Jungle", Chance = 10};
        {MapName = "Candyland", Chance = 10};
        {MapName = "Tropical", Chance = 10};
        {MapName = "Winterland", Chance = 10};
        {MapName = "Wipeout", Chance = 10};
    }; --// CURRENT MAPS IN PLAY, [MapName : String, Chance : Number]

    T_GAMEMODES = {
        {Mode = "RACE MODE", Chance = 10};
        {Mode = "DUCK OF THE HILL", Chance = 10};
        {Mode = "HOT POTATO", Chance = 10};
        {Mode = "DOMINATION", Chance = 10};
        {Mode = "TILE FALLING", Chance = 10};
    }; --// CURRENT MODES IN PLAY 

    MAPS = {
        {MapName = "Cave", Chance = 10};
        {MapName = "Desert", Chance = 10};
        {MapName = "Kingdom", Chance = 10};
        {MapName = "Jungle", Chance = 10};
        {MapName = "Candyland", Chance = 10};
        {MapName = "Tropical", Chance = 10};
        {MapName = "Winterland", Chance = 10};
        {MapName = "Wipeout", Chance = 10};
    }; --// CURRENT MAPS IN PLAY, [MapName : String, Chance : Number]

    GAMEMODES = {
        {Mode = "CLASSIC MODE", Chance = 10};
        {Mode = "RACE MODE", Chance = 10};
        {Mode = "DUCK OF THE HILL", Chance = 10};
        {Mode = "HOT POTATO", Chance = 10};
        --{Mode = "INFECTION MODE", Chance = 10};
        {Mode = "TILE FALLING", Chance = 10};
        {Mode = "DOMINATION", Chance = 10};
        --{Mode = "PROTECT THE DUCK", Chance = 10};
        --{Mode = "DEFORMED MODE", Chance = 10};
    }; --// CURRENT MODES IN PLAY 

    CHECKPOINTS = true; --// Add or remove checkpoints from game
    WHITELIST = true; --// ALLOWS ONLY QA TEAM WHITELIST TO THE GAME

    CUSTOM_MAP = nil; --// CHANGE THIS TO SET CUSTOM MAP DURATION OF PLAYTIME, TYPE NIL FOR NONE
    CUSTOM_MODE = nil; --// CHANGE THIS TO SET CUSTOM MODE DURATION OF PLAYTIME, TYPE NIL FOR NONE
    
    MULTIPLE_ROUNDS_MODE = false; --// If game should be played in multiple rounds
    SINGLE_PLAYER = false; --// ALLOWS YOU TO BE THE HUNTER AS A SINGLE PLAYER [STUDIO TESTING ONLY]
   
    DEFAULT_GAMEPLAY_TIME = 180; --// IF NO CUSTOM GAMEPLAY TIME THEN USE THIS DEFAULT GAMEPLAY TIME
    DEFAULT_HILL_TIME = 150;--150
    DEFAULT_INTERMISSION_TIME = 25; --// IF NO CUSTOM INTERMISSION TIME THEN USE THIS DEFAULT INTERMISSION TIME
    MINIMUM_PLAYERS = 2; --// MINIMUM AMOUNT OF PLAYERS REQUIRED TO START INTERMISSION
    
    RESET_DAILY_SHOP_DATA = false; -- If shop data needs to be reset then if true player will reset shop data when join.
    GIVE_ALL_INVENTORY = false; --// Gives all items on inventory
    DAILY_SHOP_OFFSET = 19 -- 7 PM EST, 24 hour time
}
