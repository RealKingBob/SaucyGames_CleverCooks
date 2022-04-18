function CommaValue(str)
	str = tostring(str)
	if (#str % 3 == 0) then
		return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():sub(2)
	else
    	return str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	end
end

return CommaValue