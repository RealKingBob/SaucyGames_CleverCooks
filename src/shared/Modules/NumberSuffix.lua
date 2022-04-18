local Suffixes = {
    "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud",
    "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Od", "Nd", "V", "Uv", "Dv"
}

function Suffix(n)
    if (n < 1000) then 
		return n 
	end
    
    local x = math.floor(math.log10(n))
    x = math.floor(x / 3)
	
	-- Get short
	local Short = math.floor((n / 1000 ^ x) * 100) / 100
	
	-- Return a purged version that removes extra 0's
	return string.format("%s%s", Short, Suffixes[x])
end

return Suffix