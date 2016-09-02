local myname, ns = ...
local function parseLink(link)
	local index = 0
	local ret = {}
	local temp = {}
	for i in string.gmatch(link, "[^|]+") do
    	temp[index] = i
    	index = index + 1
	end

	local index = 0
	for i in string.gmatch(temp[1], "[^:]+") do
		ret[index] = i
		index = index + 1
	end
	return ret[1]
end

local function getQuests()
	local ret = {}
	entries, quests = GetNumQuestLogEntries()
	for i=entries,1,-1 do
		link = GetQuestLink(i)
		if link ~= nil then
			local temp = {}
			id = parseLink(link)
			temp["index"] = i
			temp["questID"] = id
			ret[i] = temp
		end
	end
	return ret
end

local function getMaps(quests)
	local ret = {}
	for index, info in pairs(quests) do
		local t = {}
		mapID, floorNumber = GetQuestWorldMapAreaID(info["questID"])
		t["index"]=info["index"]
		t["mapID"]=mapID
		t["questID"]=info["questID"]
		ret[index] = t
	end
	return ret
end

function FilterLocalQuests(quests)
	SortQuestWatches()
	local quests = getQuests()
	local maps = getMaps(quests)
	local zone = GetCurrentMapAreaID()
	removed = 0
	added = 0
	for index, info in pairs(maps) do
		isWatched = IsQuestWatched(info["index"]) 
		if zone ~= info["mapID"] then
			if isWatched == true then
				removed = removed + 1
				RemoveQuestWatch(info["index"])
			end
		else 
			if isWatched == nil then
				added = added + 1
				AddQuestWatch(info["index"])
			else	
				AddQuestWatch(info["index"])
			end
		end
	end
	print("Added", added, "quests and removed", removed, "quests from tracker.")
end
