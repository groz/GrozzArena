----------------------------------------------------------------------------------------------------------
-- MAIN
----------------------------------------------------------------------------------------------------------

local function ArenaFrameClickHandler(self, button)
	if button == "RightButton" then
		print("RIGHT BUTTON")
	else	
		print(self:GetName() .. " clicked with " .. button)
	end
end

local function SetArenaHooks()
	for i = 1,5 do
		local arenaFrameName = "ArenaEnemyFrame"..i
		local arenaFrame = _G[arenaFrameName]

		if (arenaFrame ~= nil) then
			print("Hooking "..arenaFrameName)						
			arenaFrame:HookScript("OnClick", ArenaFrameClickHandler)
		else
			print(arenaFrameName .. " not found")
		end
		
	end
end

----------------------------------------------------------------------------------------------------------
-- HOOKING EVENTS
----------------------------------------------------------------------------------------------------------
local eventHandler = CreateFrame("Frame")

eventHandler:RegisterEvent("PLAYER_LOGIN")
eventHandler:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

eventHandler:SetScript("OnEvent", function(self, event, ...)
	print(event)
	
	--if (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
		SetArenaHooks()
	--end
end)

