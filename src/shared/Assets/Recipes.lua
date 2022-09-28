local CookingTimes = {
	["Hard"] = 30;
	["Medium"] = 20;
	["Easy"] = 10;
}

local RecipeRewards = {
	["Hard"] = {1200, 1500}, -- [min, max]
	["Medium"] = {600, 800},
	["Easy"] = {200, 400}
}

local Recipes = {
	["Macaron"] = {
		Name = "Macaron",
		Image = "rbxassetid://8019675976",
		Ingredients = {
			"Sugar Bag",
			"Egg",
			"Lemon",
			"Salt",
			"Wheat Bag"
		},
		Unlockable = false, 
		Difficulty = "Hard"	
	},
	["Ratatouille"] = {	
		Name = "Ratatouille",
		Image = "rbxassetid://8019445605",
		Ingredients = {
			"Red Onion",
			"Garlic",
			"Courgette",
			"Tomato",
			"Yellow Bell Pepper",
			"Red Bell Pepper",
			"Lemon"
		},
		Unlockable = true, 
		Difficulty = "Hard"	
	},
	["Chocolate Mousse"] = {	
		Name = "Chocolate Mousse",
		Image = "rbxassetid://8019447207",
		Ingredients = {
			"Chocolate",
			"Sugar Bag",
			"Salt",
			"Milk"
		},
		Unlockable = false, 
		Difficulty = "Medium"	
	},
	["Cooked Lamb Shank"] = {
		Name = "Cooked Lamb Shank",
		Image = "rbxassetid://8019446978",
		Ingredients = {
			"Raw Lamb Shank",
			"Salt"
		},
		Unlockable = false, 
		Difficulty = "Easy"	
	},
	["Croissant"] = {
		Name = "Croissant",
		Image = "rbxassetid://8019446376",
		Ingredients = {
			"Wheat Bag",
			"Sugar Bag",
			"Salt",
			"Butter",
			"Egg"
		},
		Unlockable = false, 
		Difficulty = "Hard"	
	},
	["Madeleine"] = {	
		Name = "Madeleine",
		Image = "rbxassetid://8019445863",
		Ingredients = {
			"Egg",
			"Sugar Bag",
			"Wheat Bag",
			"Lemon",
			"Butter"
		},
		Unlockable = false, 
		Difficulty = "Hard"
	},
	["Creme Caramel"] = {
		Name = "Creme Caramel",
		Image = "rbxassetid://8019446483",
		Ingredients = {
			"Egg",
			"Milk",
			"Sugar Bag"
		},
		Unlockable = false, 
		Difficulty = "Medium"
	},
	["Creme Brulee"] = {
		Name = "Creme Brulee",
		Image = "rbxassetid://8019446572",
		Ingredients = {
			"Egg",
			"Milk",
			"Sugar Bag"
		},
		Unlockable = false, 
		Difficulty = "Medium"
	},
	--[[["Cooked Steak"] = {
			"Raw Steak",
			"Salt",
			"Pepper",
			"Butter"
	},]]

	
	-- Basic Recipes
	["Fried Egg"] = {
		Name = "Fried Egg",
		Image = "rbxassetid://8019447405",
		Ingredients = {
			"Egg",
		},
		Unlockable = false, 
		Difficulty = "Easy"
	},

	["Cooked Steak"] = {
		Name = "Cooked Steak",
		Image = "rbxassetid://8019446800",
		Ingredients = {
			"Raw Steak",
		},
		Unlockable = false, 
		Difficulty = "Easy"
	},
	["Cooked Chicken Leg"] = {
		Name = "Cooked Chicken Leg",
		Image = "rbxassetid://8019447096",
		Ingredients = {
			"Raw Chicken Leg",
		},
		Unlockable = false, 
		Difficulty = "Easy"	
	},
};

function Recipes:GetCookTime(recipeName : string)
	local recipePackage = self[recipeName];

	if not recipePackage then return false end
	if CookingTimes[recipePackage.Difficulty] then 
		return CookingTimes[recipePackage.Difficulty]
	else
		return 15;
	end
end

function Recipes:GetRecipeRewards(Difficulty)
	return RecipeRewards[Difficulty];
end;

function Recipes:GetRandomRecipe()
	local Array = {};
	for k, v in pairs(self) do
		if type(v) == "table" then
			table.insert(Array, k);
		end;
	end;
    local RandomNumber = math.random(1, #Array)
    local RecipeName = Array[RandomNumber];
	return Recipes[RecipeName];
end;

function Recipes:Copy()
	local function deepCopy(original)
		local copy = {};
		for k, v in pairs(original) do
			if type(v) == "table" then
				v = deepCopy(v);
			end;
			copy[k] = v;
		end;
		return copy;
	end;
	local copiedModule = deepCopy(self);
	return copiedModule;
end;

return Recipes;
