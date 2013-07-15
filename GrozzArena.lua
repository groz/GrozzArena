local GrozzArena = { }
GrozzArena.eventHandler = CreateFrame("Frame")
GrozzArena.eventHandler.events = { }
GrozzArena.macrosToUpdate = {}
GrozzArena.consoleCommands = {}

----------------------------------------------------------------------------------------------------------
-- MAIN
----------------------------------------------------------------------------------------------------------
function GrozzArena.AddMacroToUpdate(macroName)
	GrozzArena.macrosToUpdate[macroName] = true
	print("Added macro "..macroName.." to update for arena targets")
end

function GrozzArena.RemoveMacroToUpdate(macroName)
	GrozzArena.macrosToUpdate[macroName] = nil
	print("Removed macro "..macroName.." from updates for arena targets")
end

function GrozzArena.UpdateArenaTargetInMacro(macroName, arenaTarget)
	local macroIndex = GetMacroIndexByName(macroName)
	
	if  macroIndex and macroIndex ~= 0 then
	
		local macroBody = GetMacroBody(macroIndex)
		local newMacroBody = macroBody:gsub("arena(%d+)", arenaTarget)
		
		EditMacro(macroIndex, macroName, nil, newMacroBody)
		
		print("Macro '"..macroName.."' retargeted to "..arenaTarget)
	else
		print("Macro '"..macroName.."' not found. Skipped updating.")
	end
end

function GrozzArena.ArenaFrameClickHandler(self, button)
	if button ~= "RightButton" then
		return
	end
	
	--local frameName = self:GetName()	
	local frameName = "ArenaEnemyFrame1"
	
	print("Clicked frame #"..frameName)
	
	local arenaNum = frameName:match("%d+")
	
	if arenaNum then
		for macroName,_ in pairs(GrozzArena.macrosToUpdate) do
			GrozzArena.UpdateArenaTargetInMacro(macroName, "arena"..arenaNum)
		end
	else
		print("Couldn't parse arenaNum in "..frameName)
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

----------------------------------------------------------------------------------------------------------
-- SLASH COMMANDS
----------------------------------------------------------------------------------------------------------
function GrozzArena.consoleCommands.add(macroName)
	GrozzArena.AddMacroToUpdate(macroName)
end

function GrozzArena.consoleCommands.remove(macroName)
	GrozzArena.RemoveMacroToUpdate(macroName)
end

SLASH_GROZZARENA1 = "/ga"
SLASH_GROZZARENA2 = "/grozzarena"

SlashCmdList["GROZZARENA"] = function(msg, editbox)
	local cmd,param = msg:match("(%w-) (.*)")
	local consoleCmdHandler = GrozzArena.consoleCommands[cmd]
	
	if consoleCmdHandler then
		consoleCmdHandler(param)
	end
end