local GrozzArena = { }
GrozzArena.eventHandler = CreateFrame("Frame")
GrozzArena.eventHandler.events = { }

----------------------------------------------------------------------------------------------------------
-- MAIN
----------------------------------------------------------------------------------------------------------
function GrozzArena.UpdateArenaTargetInMacro(macroName, arenaTarget)
	local macroIndex = GetMacroIndexByName(macroName)
	local macroBody = GetMacroBody(macroIndex)
	local newMacroBody = macroBody:gsub("arena(%d+)", arenaTarget)
	
	EditMacro(macroIndex, macroName, nil, newMacroBody)
	
	print("Macro "..macroName.." retargeted to "..arenaTarget)
end

function GrozzArena.ArenaFrameClickHandler(self, button)
	print(self:GetName() .. " clicked by " .. button)

	local frameName = "arena1"
	local macroName = "myMacro1"
	
	if button == "RightButton" then
		GrozzArena.UpdateArenaTargetInMacro(macroName, "arena1")
	end
end

function GrozzArena.SetArenaHooks()
	--for i = 1,5 do
		local arenaFrameName = "PlayerFrame" --"ArenaEnemyFrame"..i
		local arenaFrame = _G[arenaFrameName]

		if (arenaFrame ~= nil) then
			print("Hooking "..arenaFrameName)
			arenaFrame:HookScript("OnClick", GrozzArena.ArenaFrameClickHandler)
		else
			print(arenaFrameName .. " not found")
		end
		
	--end
end

----------------------------------------------------------------------------------------------------------
-- HOOKING EVENTS
----------------------------------------------------------------------------------------------------------

GrozzArena.eventHandler:RegisterEvent("PLAYER_LOGIN")
GrozzArena.eventHandler:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

GrozzArena.eventHandler:SetScript("OnEvent", function(self, event, ...)
	print(event)
	
	--if (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
		GrozzArena.SetArenaHooks()
	--end
end)