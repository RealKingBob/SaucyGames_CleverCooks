--Total: 326,500 [23,321 robux paid]
local French = {
    ["Jump Amount"] = {
        Type = "x";
        Image = "rbxassetid://12395477043";
        Max = 3;
        Data = {
            [1] = { Value = 1; Price = 0; };
            [2] = { Value = 2; Price = 15000; };
            [3] = { Value = 3; Price = 30000; };
        };
    };
    ["Cook Speed"] = {
        Type = "x";
        Image = "rbxassetid://12381763855";
        Max = 6;
        Data = {
            [1] = { Value = 1; Price = 0; };
            [2] = { Value = 1.25; Price = 3000; };
            [3] = { Value = 1.5; Price = 6000; };
            [4] = { Value = 1.75; Price = 10000; };
            [5] = { Value = 2; Price = 15000; };
            [6] = { Value = 2.25; Price = 20000; };
            [7] = { Value = 2.5; Price = 25000; };
            [8] = { Value = 2.75; Price = 30000; };
        };
    };
    ["Boost Stamina"] = {
        Type = "%";
        Image = "rbxassetid://12381764108";
        Max = 6;
        Data = {
            [1] = { Value = 100; Price = 0; }; --100%
            [2] = { Value = 120; Price = 3000; };
            [3] = { Value = 140; Price = 6000; };
            [4] = { Value = 160; Price = 9000; };
            [5] = { Value = 180; Price = 12000; };
            [6] = { Value = 200; Price = 15000; }; --200%
        };
    };
    ["Recipe Luck"] = {
        Type = "x";
        Image = "rbxassetid://12381763041";
        Max = 3;
        Data = {
            [1] = { Value = 1; Price = 0; };
            [2] = { Value = 2; Price = 15000; };
            [3] = { Value = 3; Price = 30000; };
        };
    };
    ["Extra Health"] = {
        Type = " HP";
        Image = "rbxassetid://12381763351";
        Max = 6;
        Data = {
            [1] = { Value = 100; Price = 0; }; --100%
            [2] = { Value = 120; Price = 2500; };
            [3] = { Value = 140; Price = 3000; };
            [4] = { Value = 160; Price = 5000; };
            [5] = { Value = 180; Price = 10000; };
            [6] = { Value = 200; Price = 15000; }; --200%
        };
    };
    ["Multitasking"] = {
        Type = "";
        Image = "rbxassetid://12381763227";
        Max = 2;
        Data = {
            [1] = { Value = false; Price = 0; };
            [2] = { Value = true; Price = 12000; };
        };
    };
    ["Cooking Perfection"] = {
        Type = "";
        Image = "rbxassetid://12381763641";
        Max = 2;
        Data = {
            [1] = { Value = false; Price = 0; };
            [2] = { Value = true; Price = 35000; };
        };
    };
}

function French:Copy()
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


return French