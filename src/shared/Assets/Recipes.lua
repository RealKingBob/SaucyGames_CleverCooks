local CookingTimes = {
	["Hard"] = 100;
	["Medium"] = 50;
	["Easy"] = 25;
}

local DifficultyPercentages = {
	["Hard"] = 20;
	["Medium"] = 50;
	["Easy"] = 100;
}


--[[
	-- THIS IS OLD 
local RecipeRewards = {
	["Hard"] = {1200, 1500}, -- [min, max]
	["Medium"] = {600, 800},
	["Easy"] = {200, 400}
}]]

--ITS SPLIT BETWEEN COOK AND DELIVER NOW SO BASICALLY 2X IF DO BOTH
local RecipeRewards = {
	["Hard"] = {600, 800}, -- [min, max]
	["Medium"] = {300, 400},
	["Easy"] = {100, 200}
}

local Recipes = {
	["Baguette"] = {
		Name = "Baguette",
		Image = "rbxassetid://12226470654",
		Ingredients = {
			"Wheat Bag-[Blended]",
		},
		Origin = "French",
		Difficulty = "Easy"
	},

	["Onion Soup"] = {
		Name = "Onion Soup",
		Image = "rbxassetid://12226432172",
		Ingredients = {
			"Onion",
			"White Onion",
			"Pepper",
		},
		Origin = "French",
		Difficulty = "Easy"
	},

	["Cooked Chicken Leg"] = {
		Name = "Cooked Chicken Leg",
		Image = "rbxassetid://8019447096",
		Ingredients = {
			"Raw Chicken Leg",
		},
		Origin = "French",
		Difficulty = "Easy"	
	},

	["Cooked Lamb Shank"] = {
		Name = "Cooked Lamb Shank",
		Image = "rbxassetid://12226439149",
		Ingredients = {
			"Raw Lamb Shank",
			"Salt"
		},
		Origin = "French",
		Difficulty = "Easy"	
	},

	["Fried Egg"] = {
		Name = "Fried Egg",
		Image = "rbxassetid://8019447405",
		Ingredients = {
			"Egg",
		},
		Origin = "French",
		Difficulty = "Easy"
	},

	["Cooked Steak"] = {
		Name = "Cooked Steak",
		Image = "rbxassetid://8019446800",
		Ingredients = {
			"Raw Steak",
			"Salt",
			"Pepper",
			"Butter"
		},
		Origin = "French",
		Difficulty = "Easy"
	},

	["French Toast"] = {
		Name = "French Toast",
		Image = "rbxassetid://12226432346",
		Ingredients = {
			"Bread",
			"Mint",
			"Sugar Bag-[Blended]",
			"Butter"
		},
		Origin = "French",
		Difficulty = "Easy"
	},

	["Chocolate Mousse"] = {	
		Name = "Chocolate Mousse",
		Image = "rbxassetid://8019447207",
		Ingredients = {
			"Chocolate-[Blended]",
			"Sugar Bag-[Blended]",
			"Salt",
			"Milk-[Blended]"
		},
		Origin = "French",
		Difficulty = "Medium"	
	},

	["Tarte Tatin"] = {
		Name = "Tarte Tatin",
		Image = "rbxassetid://12226431693",
		Ingredients = {
			"Apple",
			"Wheat Bag-[Blended]",
			"Sugar Bag-[Blended]",
			"Butter",
		},
		Origin = "French",
		Difficulty = "Medium"
	},

	["Cooked Lobster"] = {
		Name = "Cooked Lobster",
		Image = "rbxassetid://12226439007",
		Ingredients = {
			"Raw Lobster",
			"Salt",
			"Pepper",
		},
		Origin = "French",
		Difficulty = "Medium"
	},

	["Creme Caramel"] = {
		Name = "Creme Caramel",
		Image = "rbxassetid://8019446483",
		Ingredients = {
			"Egg",
			"Milk",
			"Sugar Bag"
		},
		Origin = "French",
		Difficulty = "Medium"
	},

	["Clever Soup"] = {
		Name = "Clever Soup",
		Image = "rbxassetid://12226614440",
		Ingredients = {
			"Garlic",
			"Butter",
			"Pepper",
			"Mint",
		},
		Origin = "French",
		Difficulty = "Medium"
	},

	["Creme Brulee"] = {
		Name = "Creme Brulee",
		Image = "rbxassetid://12226438788",
		Ingredients = {
			"Egg",
			"Milk",
			"Sugar Bag"
		},
		Origin = "French",
		Difficulty = "Medium"
	},


	["French Crepes"] = {
		Name = "French Crepes",
		Image = "rbxassetid://12226434184",
		Ingredients = {
			"Wheat Bag-[Blended]",
			"Milk",
			"Raspberries",
			"Blueberries"
		},
		Origin = "French",
		Difficulty = "Medium"
	},

	["Croissant"] = {
		Name = "Croissant",
		Image = "rbxassetid://8019446376",
		Ingredients = {
			"Wheat Bag-[Blended]",
			"Sugar Bag-[Blended]",
			"Salt",
			"Butter-[Blended]",
			"Egg-[Blended]"
		},
		Origin = "French",
		Difficulty = "Hard"	
	},
	
	["Madeleine"] = {	
		Name = "Madeleine",
		Image = "rbxassetid://8019445863",
		Ingredients = {
			"Egg-[Blended]",
			"Sugar Bag-[Blended]",
			"Wheat Bag-[Blended]",
			"Lemon",
			"Butter-[Blended]"
		},
		Origin = "French",
		Difficulty = "Hard"
	},

	["Ratatouille"] = {	
		Name = "Ratatouille",
		Image = "rbxassetid://8019445605",
		Ingredients = {
			"Red Onion",
			"Garlic",
			"Courgette",
			"Tomato-[Blended]",
			"Yellow Bell Pepper",
			"Red Bell Pepper",
			"Lemon"
		},
		Origin = "French",
		Difficulty = "Hard"	
	},
	["Macaron"] = {
		Name = "Macaron",
		Image = "rbxassetid://8019675976",
		Ingredients = {
			"Sugar Bag-[Blended]",
			"Egg-[Blended]",
			"Lemon",
			"Salt",
			"Wheat Bag-[Blended]"
		},
		Origin = "French",
		Difficulty = "Hard"	
	},

	["Canele"] = {
		Name = "Canele",
		Image = "rbxassetid://12226470151",
		Ingredients = {
			"Wheat Bag-[Blended]",
			"Egg",
			"Butter",
			"Olive Oil",
			"Sugar Bag",
		},
		Origin = "French",
		Difficulty = "Hard"
	},

	["Bavarois Mousse"] = {
		Name = "Bavarois Mousse",
		Image = "rbxassetid://12226470417",
		Ingredients = {
			"Wheat Bag-[Blended]",
			"Milk",
			"Butter",
			"Mint",
			"Banana",
		},
		Origin = "French",
		Difficulty = "Hard"
	},

	["Daube"] = {
		Name = "Daube",
		Image = "rbxassetid://12226434480",
		Ingredients = {
			"Raw Steak",
			"Tomato",
			"Olive Oil",
			"Pepper",
			"Mint",
		},
		Origin = "French",
		Difficulty = "Hard"
	},

	--[[["Samosa"] = {
		Name = "Samosa",
		Image = "rbxassetid://12226431948",
		Ingredients = {
			"Wheat Bag",
			"Milk",
			"Pepper",
			"Raw Chicken Leg",
		},
		Origin = "India",
		Difficulty = "Medium"
	},
	
	["Cupcake"] = {
		Name = "Cupcake",
		Image = "rbxassetid://12226434726",
		Ingredients = {
			"Wheat Bag",
			"Egg",
		},
		Origin = "United States",
		Difficulty = "Easy"
	},
	]]

};

function Recipes:GetAllRecipeNames()
	local Array = {};
	for k, v in pairs(self) do
		if type(v) == "table" then
			table.insert(Array, {
				name = k,
				difficulty = v.Difficulty,
				value = 0,
			});
		end;
	end;
	return Array;
end

function Recipes:GetCookTime(recipeName : string)
	local recipePackage = self[recipeName];

	if not recipePackage then return false end
	if CookingTimes[recipePackage.Difficulty] then 
		return CookingTimes[recipePackage.Difficulty]
	else
		return 15;
	end
end

function Recipes:GetImage(recipeName : string)
	local recipePackage = self[recipeName];

	if not recipePackage then return "" end
	if recipePackage.Image then 
		return recipePackage.Image;
	else
		return "";
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
