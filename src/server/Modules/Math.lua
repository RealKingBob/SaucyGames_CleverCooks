--[[
    Name: Math API [V1]
    By: Real_KingBob
    Date: 11/9/21
    Description: This module handles all functions that include external math functions in it
]]

local MathAPI = {};

function MathAPI:Find_Closest_Divisible_Integer(a,b)
    local c1 = a - (a % b);
    local c2 = (a + b) - (a % b);
    if (a - c1 > c2 - a) then
        return c2;
    else
        return c1;
    end;
end;

--[[
	I'm no expert, this is just what I've learned when I needed something like this. May be a bit hard to understand at first. a is the series, d is the common difference.
	n/2 [a1*2 + d/2n - d/2]
	n/2 [200 + 50n - 50]
	100n + 25 n^2 - 25n
	25n^2 + (100n - 25n)
	25n^2 + 75n
	
	That is how you'd create the a and b below.
	a = 25
	b = 75
	
	Proof
	n is the term (in this case 3)
	d is the sum you should get.
	an^2 + bn + d
	25*(3^2)+(75*3)-450 = 0
--]]

-- The start variable represents the first term of the arithmetic series. The increment represents the common difference. So the series would be 100, 150, 200, ...
-- The sum of the series would be in order 100, 250, 450, ...
local start = 100;
local increment = 50;

-- Refer to comment at top.
local a = 25;
local b = 75;

function MathAPI:getSum(terms)
    return terms / 2 * (2 * start + (terms - 1) * increment);
end

function MathAPI:getPossibleTerms(sum)
    return math.floor((-b + math.sqrt(b^2 + 4 * a * sum)) / (2 * a));
end
  
  -- What term you can get with 450 as the sum. Prints 3.
  --print(getPossibleTerms(450));
  
  -- How much exp you need for the third level. Prints 450.
  --print(getSum(3));

return MathAPI;