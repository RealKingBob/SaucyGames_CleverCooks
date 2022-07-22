--[[
    Name: Table API [V1]
    By: Real_KingBob
    Date: 10/2/21
    Description: This module handles all functions that include tables in it for server scripts
]]

local Table = {};

function Table.Find(tbl,val)
    for i, v in pairs(tbl) do
        if v == val then
            return i;
        end;
    end;
end;

function Table.Equals(t1, t2)
	for key, value in pairs(t1) do
		if (t2[key] ~= value) then
			return false;
		end;
	end;
	for key, value in pairs(t2) do
		if (t1[key] ~= value) then
			return false;
		end;
	end;
	return true;
end;

function Table.FindTable(tbl,owner,val)
	for key, value in pairs(tbl) do
		for _,value2 in pairs(value) do
			if value2 == tostring(owner)..tostring(val) then
				return key;
			end;
		end;
	end;
end;

function Table.CheckArrayEquality(t1,t2)
    if #t1~=#t2 then return false end
    for i=1,#t1 do if t1[i]~=t2[i] then return false end end
    return true
end

function Table.CopyTable(tbl)
    local tCopy = {};
    for k,v in pairs(tbl) do
        if (type(v) == "table") then
            tCopy[k] = Table.CopyTable(v);
        else
            tCopy[k] = v;
        end;
    end;
    return tCopy;
end;

function Table.CheckTableEquality(t1,t2)
    for i,v in next, t1 do if t2[i]~=v then return false end end;
    for i,v in next, t2 do if t1[i]~=v then return false end end;
    return true;
end;

function Table.Sync(tbl, templateTbl)
    -- If 'tbl' has something 'templateTbl' doesn't, then remove it from 'tbl'
    -- If 'tbl' has something of a different type than 'templateTbl', copy from 'templateTbl'
    -- If 'templateTbl' has something 'tbl' doesn't, then add it to 'tbl'
    for k,v in pairs(tbl) do
        local vTemplate = templateTbl[k];
        -- Remove keys not within template:
        if (vTemplate == nil) then
            tbl[k] = nil;
            -- Synchronize data types:
        elseif (type(v) ~= type(vTemplate)) then
            if (type(vTemplate) == "table") then
                tbl[k] = Table.CopyTable(vTemplate);
            else
                tbl[k] = vTemplate;
            end;
            -- Synchronize sub-table:
        elseif (type(v) == "table") then
            Table.Sync(v, vTemplate);
        end;
    end;

    -- Add in any missing keys:
    for k,vTemplate in pairs(templateTbl) do
        local v = tbl[k];
        if (v == nil) then
            if (type(vTemplate) == "table") then
                tbl[k] = Table.CopyTable(vTemplate);
            else
                tbl[k] = vTemplate;
            end;
        end;
    end;
end;

return Table;